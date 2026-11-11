# Verilator: output automatic task arg bound to a class-task output under `fork`

Fork: `Verilator 5.055 devel rev v5.054-65-g4dece87d7`
(`~/workspaceconfig/deps/verilator`, uvm-verilator port)

The last frontend blocker in the `ganoam:dv:stream_reg_sim` build — 5
sites in `hw/dv/sv/csr_utils/csr_utils_pkg.sv`, all
`In instance 'tb.dut'`:

```
%Error: csr_utils_pkg.sv:359:45: Writing to an output automatic variable
        of a task after a timing control is not allowed (IEEE 1800-2023 13.2.2)
  359 |   csr_or_fld.field.read(.status(status), .value(value), ...)
```

Note: this is arguably an IEEE-strict check rather than a bug —
commercial simulators accept the pattern permissively.

## Trigger

All three conditions together:

1. a `task automatic` with **`output` formals** (`status`, `value`),
2. those formals bound as actuals to a **class task's** `output` ports
   (`uvm_reg_field::read` / `uvm_reg::read` / `write` / `poke` — which
   suspend on real timing controls),
3. the call inside a **`fork`** (csr_utils wraps the access in
   `isolation_fork` + `join_any` + `disable fork` — a timeout watchdog).

```systemverilog
class regfld;
  task automatic read(output int s, output int v);
    #10 s = 1; v = 42;
  endtask
endclass
task automatic outer(output int v, output int s);
  regfld f;
  fork
    begin : iso
      f = new;
      f.read(.s(s), .v(v));   // %Error x2 on .s(s), .v(v) actuals
    end
    begin #100; end
  join_any
  disable fork;
endtask
```

The error points at the **actual arguments** at the call site, not at
the callee.

## What does work (all verified)

| Variant | Result |
|---|---|
| fork + timed **class** callee + output formals | **FAIL** (`repro.sv`) |
| fork + **untimed** class callee + output formals | **FAIL** (`ctrl_notimed.sv`) |
| no fork + timed class callee | PASS (`ctrl_nofork_timed.sv`) |
| no fork + untimed class callee | PASS (`ctrl_nofork.sv`) |
| fork + timed class callee + **static** actuals | PASS (`ctrl_static.sv`) |
| fork + timed **module-task** callee + output formals | PASS (`ctrl_module_task.sv`) |
| fork + locals bound, copy-out after join | PASS (`fix_locals.sv`) |

So the disqualifier is the **automatic lifetime under a forking caller**:
the callee's copy-out can land after `join_any` + `disable fork` unwound
the frame — which is exactly what the csr_utils timeout branch can do.
The callee's own timing behavior is irrelevant (class dispatch isn't
inlinable, so Verilator can't prove it won't suspend); module tasks are
resolved statically and pass. Static actuals pass because their lifetime
outlives any frame.

## Why the rule exists

Output args are *copy-out*: the callee's formal is copied into the
caller's lvalue at callee completion. Under `fork` (esp.
`join_any`/`join_none` + `disable`), the callee may outlive or be killed
inside the caller's frame — the write would target a dead automatic
variable. IEEE 1800-2023 §13.2.2 forbids the shape rather than define
it. (Same ambiguity raised in sv-ec reflector thread #1206.)

## Workaround

Bind the callee's outputs to **locals**, copy to the output formals
after `join` (`fix_locals.sv`, verified builds + runs):

```systemverilog
uvm_reg_data_t l_value; uvm_status_e l_status;
...
csr_or_fld.field.read(.status(l_status), .value(l_value), ...);
...
join_any; disable fork;
value = l_value; status = l_status;
```

Body writes to output formals after `join` do **not** trip the check —
only the call-site binding into the timed callee does. Semantics are
unchanged (the killed-by-timeout path was already undefined).

## Upstream

- **verilator/verilator#7345** (merged 2026-05): "Support for writing to
  inout in fork after timing" — splits timed task args into a static var
  + port var, lifting this restriction for the *static* case. Not
  present in this fork's rev, and it does not cover automatic outputs
  through class tasks anyway.
- sv-ec thread #1206: the spec-level lifetime ambiguity this check
  encodes.

## Repro index (`repros/`)

Run each: `verilator --lint-only --timing <file> --top-module tb`

| File | Result | Tests |
|---|---|---|
| `repro.sv` | **FAIL** (2 err) | minimal: csr_rd_sub shape |
| `ctrl_notimed.sv` | FAIL | callee untimed — fork is what matters |
| `ctrl_nofork.sv` | clean | no fork in caller |
| `ctrl_nofork_timed.sv` | clean | timed callee OK outside a fork |
| `ctrl_static.sv` | clean | static actuals — it's the automatic lifetime |
| `ctrl_module_task.sv` | clean | module-task callee resolves statically |
| `fix_locals.sv` | clean | the workaround |

## Using the rig

```shell
cd vlt-debug/output-after-timing/rig
verilator --lint-only +define+UVM -f min.vc --top-module min_tb
```

- `min.vc` — same real lint filelist as `../classrefdtype/rig` —
  compiles `csr_utils_pkg.sv` itself, so the **real** errors are emitted
  without any probe. Paths are `../../../…` —
  **the rig must stay 3 levels below the repo root**.
- Expected: the ~5 csr_utils_pkg "output automatic variable" errors
  (plus ~1100 unrelated warnings — filter with `grep "not allowed"`).

## Relevance to stream_reg_sim

Final remaining frontend class — exactly 5 errors, all output *formals*
of an automatic task bound into timed class tasks under `fork`:

- `csr_utils_pkg.sv:359` (×2) — `csr_or_fld.field.read(.status(status),
  .value(value), …)` in `csr_rd_sub`
- `csr_utils_pkg.sv:362` (×2) — `csr_or_fld.csr.read(.status(status),
  .value(value), …)` in `csr_rd_sub`
- `csr_utils_pkg.sv:664` — `ptr.read(.status(status), …, .value(data), …)`
  in the backdoor-read task (`data` is the output formal; `status` is a
  local and is not flagged)

Other `.status(status)` sites (e.g. l. 241 `csr.write`) bind *locals*,
not formals — they pass, confirming only formal outputs are flagged.
One mechanical locals+copy-out transform fixes each flagged site.
