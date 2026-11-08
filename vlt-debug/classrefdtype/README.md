# Verilator bug: `expects CLASSREFDTYPE 'X', got CLASSREFDTYPE 'X'`

Fork: `Verilator 5.055 devel rev v5.054-65-g4dece87d7`
(`~/workspaceconfig/deps/verilator`, uvm-verilator port)

Two error shapes observed in `fusesoc --cores-root=. run --target=lint --setup --build ganoam:dv:stream_reg_sim:0.1`:

1. **Identical types both sides** — `expects 'T#(32,32)', got 'T#(32,32)'`.
2. **Legal is-a rejected** — `connect()` gets `uvm_seq_item_pull_imp` /
   `uvm_analysis_imp` where `uvm_port_base#(<same IF spec>)` is expected;
   the imp classes *extend* exactly that base. Legal UVM connect.

Neither is a real param mismatch: a genuine one prints different values
(`#(32,32)` vs `#(64,64)`). Errors are structural — they'd fire at any
`DataWidth`.

## Confirmed trigger: dependent default param + omitted specialization

```systemverilog
class comp_c #(parameter int W = 32, parameter int D = W);   // D = W
  typedef factory#(comp_c#(W, D)) type_id;
endclass
comp_c #(32, 32) c;
c = comp_c::type_id::create();      // ERROR (repro.sv)
c = comp_c#(32,32)::type_id::create(); // OK
c = comp_c#()::type_id::create();   // ERROR too — NONSTD's #() hint doesn't help
```

Default specialization `comp_c` / `comp_c#()` = `comp_c#(32, W)` — keyed
on the formal, distinct from `comp_c#(32,32)`.

Upstream: **verilator/verilator#8588** (open, filed by lowRISC
collaborator — same bug, direct-assignment repro). Our report adds: the
`T::type_id::create` surface (how OpenTitan `push_pull_agent` hits it) and
that `#()` doesn't fix it. Related: #7892, #7979.

Workarounds (verified): explicit `T#(...)::type_id::create(...)`, or omit
the dependent param in declarations (`#(.W(32))` matches bare-name create;
only valid while the default value is what's wanted).

## Unresolved trigger: the connect() errors

Five errors, all "In instance 'tb.dut'":

- `dv_base_agent.sv:84` — `driver.seq_item_port.connect(sequencer.seq_item_export)`
- `dv_reactive_agent.sv:54,57`, `push_pull_agent.sv:40` — `*_analysis_port.connect(*_analysis_fifo.analysis_export)`
- `push_pull_device_seq.sv:57` — `p_sequencer.req_analysis_fifo.get(req)` (identical-print shape)

NOT reproduced in isolation. Leading hypothesis: specialization identity
splits across *module-instance elaboration context* — every error is
inside `tb.dut`.

## Repro index (`repros/`)

| File | Result | Tests / rules out |
|---|---|---|
| `repro.sv` | **FAIL** | 20-line UVM-free minimal: `D=W` + bare `T::type_id::create` |
| `t_min3.sv` | FAIL | same, UVM version (env member spelled via param refs) |
| `t_min3_fix.sv` | FAIL | `T#()::` spelling — error survives, NONSTD gone |
| `t_uvm2.sv` | FAIL | first UVM hit; env member `leaf_agent#(W,D)` + bare create |
| `a.sv` | FAIL | literal member + bare create → member spelling irrelevant |
| `t_min.sv` `t_min_fix.sv` `t_min2.sv` | warn only | single param, or param-ref member — D=W required |
| `b.sv` `c.sv` | clean | explicit `T#(32,32)::type_id::create` — the workaround |
| `omit_d.sv` | clean | omit `D` in decl → both sides use omitted-default spec |
| `t1/t2/t3.sv` | clean | pure-SV factory+typedef paths — need `D=W`, not just params |
| `t_uvm.sv` | clean | UVM param-class chain, explicit create — not the trigger alone |
| `conn1.sv` | clean | concrete derived→base arg check works |
| `conn_uvm*.sv` | clean | seq_item + analysis connects via 2-level type-param forwarding, dependent-default item, bare-name create — none trigger |
| `rig/` | bisect rig | real filelist minus `hw/ip/stream_reg`; see below |

## Using the rig

```shell
cd vlt-debug/classrefdtype/rig
verilator --lint-only +define+UVM -f min.vc --top-module min_tb
```

- `min.vc` — the real lint filelist (uvm-verilator + opentitan dv libs +
  push_pull) minus `hw/ip/stream_reg`. Paths are `../../../…` —
  **the rig must stay 3 levels below the repo root** or they break.
- `min_tb.sv` — edit this: instantiate/elaborate whatever you suspect.
  Baseline (clean): `push_pull_agent#(32,32) agt; agt = new("a", null);`
- Filter noise: `… 2>&1 | grep CLASSREFDTYPE` — csr_utils emits ~5
  unrelated errors ("output automatic variable after timing control")
  plus ~1100 warnings.
- +define+UVM is required (dv_macros `` `gfn `` → `$sformatf` without it).

Tried in min_tb, all clean (no CLASSREFDTYPE): standalone
`push_pull_agent#(32,32)` via `new`; bare `push_pull_agent::type_id::create`
(reproduces only the #8588 assign error, no connect errors); env-class
(`class min_env #(parameter int DataWidth=32) extends uvm_env`) member
`agt` created via explicit `push_pull_agent#(.)::type_id::create`.

Next hypothesis to test: instantiate the agent inside a `dut` module
*instance* under `tb` — real errors all note "In instance 'tb.dut'", the
one context not yet replicated.

## Fix sites applied (stream_reg_sim)

- `stream_reg_env.sv:22,26` — `push_pull_agent#(.)::type_id::create` explicit
- consistent explicit spec advised for `uvm_config_db#(push_pull_agent_cfg)::set`,
  env_cfg members/creates, vseq `*_sequencer_h` (runtime `$cast`, not lint)
- separate bug: `env.sv:38,41` references `virtual_sequencer.push_pull_sequencer_h`
  (members are `in_/out_sequencer_h` — undeclared member) — FIXED

## Workarounds applied to reach elaboration (Nov 8)

Strategy: every `port.connect(export)` / `fifo.get(item)` argument whose type
splits across specialization identities is routed through a variable declared
with a *typedef member of the provider's own class specialization* — the only
spelling found that reliably produces the formal's exact node under `tb.dut`
elaboration. `PARAM::member`, `Spec#(a)::PARAM` and inherited-param `::`
scopes all hit separate Verilator bugs (see `../inherited-param-scope/`).

- `dv_base_driver.sv` — added `typedef uvm_port_base#(uvm_sqr_if_base#(ITEM_T,
  RSP_ITEM_T)) sqr_prov_t` (own params → concrete typedef member; bound
  node-wise to uvm_driver's REQ/RSP).
- `dv_base_agent.sv` — `connect_phase` now `$cast`s `sequencer.seq_item_export`
  into `_drv_prov_t prov` (= `DRIVER_T::sqr_prov_t`) before
  `driver.seq_item_port.connect(prov)`.
- `dv_reactive_monitor.sv` — added `req_port_base_t`/`rsp_port_base_t` typedefs
  (`uvm_port_base#(uvm_tlm_if_base#(REQ_ITEM_T/RSP_ITEM_T, same))`).
- `dv_reactive_agent.sv` — req/rsp analysis-fifo connects go through
  `MONITOR_T::req_port_base_t`/`rsp_port_base_t` + `$cast`.
- `push_pull_agent.sv` — device-mode `req_analysis_port.connect` goes through a
  local `typedef push_pull_item#(H,D)` + `uvm_port_base#(uvm_tlm_if_base#(...))`
  `prov` + `$cast` (`MONITOR_T::REQ_ITEM_T` impossible: inherited-param-scope
  bug; `push_pull_monitor#(H,D)::ITEM_T` also fails: REFDTYPE unlink).
- `dv_reactive_sequencer.sv` — added `item_t`/`rsp_item_t` typedefs for the
  same reason.
- `push_pull_device_seq.sv` — `req_analysis_fifo.get(req)` now gets into
  `push_pull_sequencer#(H,D)::item_t _req`, then `void'($cast(req, _req))`.
- `stream_reg_scoreboard.sv` — all six bare `push_pull_item` spellings
  (fifo decls, queues, task locals) made explicit
  `push_pull_item#(.HostDataWidth(DataWidth), .DeviceDataWidth(DataWidth))`:
  the bare name is the omitted-dependent-default spec `#(32,W-formal)`, a
  different node than `#(32,32)` — this is the classrefdtype trigger itself.

Result: all CLASSREFDTYPE / param-scope errors cleared. Remaining build
blocker: 5 unrelated `csr_utils_pkg.sv` errors ("output automatic variable
of a task after a timing control", IEEE 1800-2023 13.2.2 — a Verilator
--timing restriction; pre-existing, next to fix).
