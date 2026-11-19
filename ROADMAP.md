# Roadmap

Goal: make OpenTitan-style UVM verification environments usable on fully
open-source tools (Verilator + the `uvm-verilator` port), consumable by the
community as reusable DV infrastructure rather than a personal bench.

Each phase produces independently useful output: upstream bug reports, a
compat layer, a capability ladder, and finally regression/CI integration.

## Phase 0 — Proof of concept (mostly done)

One OT-style UVM env (`stream_reg`) builds and runs end-to-end on
Verilator + `uvm-verilator` (IEEE 1800.2-2020 port). Workaround catalog
lives in `vlt-debug/` with minimal reproducers.

- [x] `stream_reg` verified the lowRISC way: `dv_lib`/`push_pull_agent`/
      scoreboard env runs end-to-end.
- [ ] Sim completes a `num_trans`-parameterized smoke test with scoreboard
      checking; no hangs; clean objection lifecycle.

## Phase 1 — Upstream what can be upstreamed

Low effort, high value; shrinks the workaround list permanently.

- [ ] File Verilator bug reports from `vlt-debug/` reproducers:
      - dependent-specialization identity failures (`uvm_factory` type paths)
      - automatic-task output formals written from class tasks under fork
      - `const ref` queue captured by nested `join_none` processes
      - time-zero `@event` race in `clk_rst_if` (`.triggered` fix)
- [ ] `uvm-verilator` fork fixes:
      - `uvm_pkg.core`: compile `src/dpi/uvm_dpi.cc` as `cppSource`
        (unity TU), keep the rest `is_include_file`
      - document the required `--vpi` flag (VPI is needed by `uvm_hdl_*`,
        `uvm_cmdline_processor`, `uvm_hdl_polling`)
- [ ] Publish the known-issues / workaround catalog for OT DV on Verilator.

## Phase 2 — Run vendored environments, in dependency order

Working rule: vendored sources stay unmodified. Compatibility deltas live
in the `uvm-verilator` fork (shims) or as tagged workarounds. Each shim is
justified by a real failure — never added speculatively. Per bench below:
elaborate first, classify each failure (Verilator bug -> repro + workaround
+ report draft; UVM-1.2 semantic gap -> shim in `uvm-verilator`; OT defect
-> tagged patch), verify exit criteria, record the shim and its trigger.

### Vendored bench ladder (increasing difficulty)

|    | # | Bench | What it demands / proves |
|----|---|-------|--------------------------|
| [x]| 0 | `stream_reg` (authored)                    | Baseline: dv_lib, push_pull_agent, scoreboard, clk_rst_if working end-to-end |
| [x]| 1 | `prim/pre_dv` scratch — `prim_trivium`     | FuseSoC+Verilator pipeline on vendored cores, no UVM |
| [ ]| 1 | `prim/pre_dv` scratch — `prim_crc32`, `prim_flop_2sync`, `prim_sync_reqack` | Same pipeline, remaining vendored cores |
| [ ]| 2 | `prim_lfsr_sim`                            | Minimal vendored UVM env (builds; run end-to-end pending) |
| [ ]| 3 | `prim_esc`, then `prim_alert`              | First protocol-agent benches. Requires vendoring `esc_agent`/`alert_agent` (new import round) |
| [ ]| 4 | `prim_ascon`, `prim_present`, `prim_prince`, `prim_ram_scr` | DPI reference models inside UVM envs; heavier stimulus |
| [ ]| 5 | `stream_fifo` via `stream_env`             | Reuse proof: second IP on the parameterized env |
| [ ]| 6 | `tlul/generic_dv` xbar                     | tl_agent + RAL + multi-port env — the wall |
| [ ]| 7 | `rv_timer` or `pattgen`                    | Unmodified full CIP IP: csr_utils, common_vseq, interrupts — requires new vendoring round |

Notes: `prim_secded` is skipped (C reference model only, exercised
indirectly via `prim_ram_scr`). Steps 3 and 7 each trigger a `filter-repo`
import round per the vendoring recipe.

### Capability ladder (what the benches exercise)

| Step | Capability | Depends on | Notes |
|------|------------|------------|-------|
| 2.1 | clk/rst + push_pull agents | — | working |
| 2.2 | RAL frontdoor | interface agent (2.4 for TL) | `uvm_reg` model generation via reggen |
| 2.3 | RAL backdoor | VPI (linked) | runtime correctness unverified |
| 2.4 | `tl_agent` (TileLink) | 2.1 | the real wall: a/d channels, FSMs, big agent |
| 2.5 | `csr_utils` suite | 2.2/2.3 | csr_hw_reset, csr_rw, csr_aliasing, bit_bash |
| 2.6 | `common_vseq` suite | 2.4 | stress_all, tl_errors, integrity |
| 2.7 | Interrupts / alerts / mem backdoor | 2.3 | intr_test, alert agents, mem_utils DPI |

### AXI-Lite workstream

Parallel to the TL-UL ladder; feeds on the reuse map appendix.

- [ ] Hand-written AXI register bank
- [ ] Adapt reggen: generate from hjson spec -> autogenerate SW artifacts
      and documentation

## Phase 3 — Known-hard gaps

Be honest about what cannot be fixed in this repo.

- Covergroups: Verilator has no covergroup support. OT DV signoff is
  coverage-driven; near-term options are coverage-less sims, or Verilator
  code coverage (line/toggle/FSM) as a partial proxy. This is an upstream
  feature request, not a port fix.
- SVA: Verilator supports a subset of concurrent assertions. `prim_assert`
  usage across OT needs a survey: which forms elaborate and which are
  silently dropped.
- `uvm_hdl` over VPI: Verilator's VPI resolves public/synthesized names
  only; backdoor into optimized-away internals may fail silently. Needs
  characterization tests.

## Phase 4 — Engineering quality (usable, not just runnable)

- [x] Incremental builds: `--skip-identical`, ccache, `-CFLAGS -O0`,
      `mold`, lint target downgraded to `lint-only` mode.
- [ ] Further: `--output-split` tuning, optional clang++ (needs
      `CXX ?=` in verilated.mk), tmpfs build root, `--build` without
      `--setup`.
- [ ] Regression integration: OT runs `dvsim.py` + hjson cfgs. Either a
      verilator backend for dvsim or a documented parallel flow. This is
      what turns a personal bench into a community tool.
- [x] FST wave dumping.
- [ ] Remove unhooked lowRISC artifacts from tools and documents.
- [x] Consolidate lowRISC instructions and guides into documented own
      workflows (`deps/workflows`: rules, workflow, recipes, tricks).
- [ ] Evaluate the lowRISC methodology against own research: cut
      unnecessary fluff; fix parameter ripple (full-width agents +
      info_t feasible?).

## Phase 5 — Community packaging

- [ ] CI: GitHub Action running `fusesoc run --target sim` on a small IP —
      proves the flow stays green with zero commercial tooling.
- [ ] Docs: setup instructions and a feature support matrix
      (works / stubbed / unsupported).
- [ ] IP ladder: `stream_reg` -> CSR-bearing IP (rv_timer/pattgen) ->
      memory + interrupt IP. Each tier exercises the next capability row.

---

Critical path: Phase 1 and the compat discipline in Phase 2 are
days-to-weeks. `tl_agent` (bench 6 / step 2.4) is the single largest
engineering item — without it, no real OT IP env runs. The covergroup
gap (Phase 3) cannot be closed here — only worked around or upstreamed.

## Appendix: reuse map for AXI-Lite components

Verbatim reusable — take as-is

| Path | What you get |
|------|--------------|
| `hw/dv/sv/dv_lib/` | `dv_base_env`, `dv_base_env_cfg`, `dv_base_scoreboard`, `dv_base_env_cov`, `dv_base_vseq`, `dv_base_test`, `dv_base_virtual_sequencer` — your entire env scaffolding |
| `hw/dv/sv/scoreboard/` | The keyed multi-stream scoreboard + `scoreboard_queue` — ports/queues/policies/`get_queue_name` hook, ready to parameterize on `axi_lite_item` |
| `hw/dv/sv/dv_base_agent/` | Base agent/driver/monitor/sequencer/seq/cfg — plus `dv_reactive_agent`, a reusable responder skeleton (great starting point for your AXI subordinate driver) |
| `hw/dv/sv/dv_utils/` | `DV_CHECK_*` macros, `dv_spinwait`, report catcher/server, `dv_test_status` |
| `hw/dv/sv/dv_utils/dv_fcov_macros.svh` | Functional coverage macros (`DV_FCOV_*`) |
| `hw/dv/sv/str_utils/` | String helpers everything else depends on |
| `hw/dv/sv/common_ifs/` | `clk_rst_if` — clock+reset generator if (every env needs this), `clk_if`, `pins_if` |
| `hw/dv/sv/bus_params_pkg/` | Bus width constants — fork it and add AXI widths |
| `hw/dv/sv/mem_model/` | Associative-array memory model — use as your subordinate reference model |

Reusable if your components have registers

| Path | What you get |
|------|--------------|
| `util/reggen` | Generates reg-block RTL and the UVM RAL model from an `.hjson` reg description — huge if you adopt their register doc format |
| `hw/dv/sv/dv_base_reg/` | `dv_base_reg_block`/`reg_field`/`reg_map` extensions + shadowed/mubi field cov (probably only need the base classes) |
| `hw/dv/sv/csr_utils/` | RAL-based CSR test sequences (reset value check, HW-reset, aliasing) — protocol-agnostic since they go through `uvm_reg` frontdoor; just write an `axi_lite_reg_adapter` (model on `tl_reg_adapter.sv`) |
| `hw/dv/tools/ralgen/` | RAL generation wrapper |

Clone-and-modify templates (protocol-specific)

- `hw/dv/sv/tl_agent/` — your structural blueprint: `tl_if` -> `axi_lite_if`,
  `tl_host_driver`/`tl_device_driver` -> manager/subordinate drivers,
  `seq_lib/` has good stimulus patterns (`tl_host_protocol_err_seq` —
  error injection idea worth copying).
- `hw/dv/sv/push_pull_agent/` — the streaming agent; closest thing to your
  FIFO-side ports, including host/device seqs with randomized backpressure.
- `hw/ip/tlul/generic_dv/` — the xbar env/tb/test; your multi-port
  (crossbar) template.
- `hw/ip/tlul/doc/TlulProtocolChecker.md` + `hw/ip/tlul/rtl/tlul_assert*.sv`
  — model for your AXI-Lite rule list + SVA checker, using
  `hw/ip/prim/rtl/prim_assert.sv` macros.
- `hw/dv/sv/tl_agent/dv/` — the agent's self-test unit bench (tb +
  mini-env + `tl_agent_sim_cfg.hjson`) — worth replicating so
  `axi_lite_agent` can be verified standalone.

Scaffolding & flow

- `util/uvmdvgen` — generates an entire agent skeleton:
  `util/uvmdvgen.py axi_lite -a -ao <dir>` gives you if/item/monitor/
  drivers/sequencer/agent/pkg/seq_lib/cfg/cov/core files instantly.
  Note: `gen_env` templates are CIP-flavored — ~10 `.tpl` files
  reference `tl_agent`/`cip_lib` (`env.sv.tpl`, `scoreboard.sv.tpl`,
  `tb.sv.tpl`, etc.), so generate the agent verbatim but expect to edit
  or hand-roll the env side.
- `util/dvsim/` — the whole regression flow (hjson sim cfg ->
  compile/run/report/cov-merge). Reusable if you keep their
  `*_sim_cfg.hjson` format; `sim_cfg.hjson.tpl` shows it.
- `hw/dv/tools/` — per-simulator TCL (`vcs/`, `xcelium/`, `questa/`,
  `riviera/`), `common.tcl`, `waves.tcl`.
- Boilerplate: `testplan.hjson.tpl`, `checklist.md.tpl`,
  `cov_excl.el.tpl`, `index.md.tpl`.

Skip

`cip_lib` (hardwired to tl_agent + comportable CSR flow),
`alert_agent`/`esc_agent`/`kmac_app_agent`/`jtag*`/`spi`/`i2c`/`uart`/
`usb20` agents (OT-specific protocols — note: bench step 3 pulls
`esc_agent`/`alert_agent` back in), `rst_shadowed_if`, `sec_cm`,
`mem_bkdr_util` (unless you want hierarchical backdoor mem access),
`entropy_src_xht_agent`.

## Notes and low-prio

- If/when autogenerating own IPs: take care to switch `${vendor}` and
  `${agent_vendor}` correctly. Best not to trust the user to set the
  vendor flag — look it up.
- [x] LSP includes: redundant `` `include "uvm_macros.svh"` `` /
  `` `include "dv_macros.svh"` `` added to classes that inherit their
  inclusions from their packages. Technically no-ops (guarded), but
  keeps the LSP happy — policy going forward.
