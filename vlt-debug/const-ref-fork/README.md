# Verilator: `const ref` formal captured into a spawned fork process → non-const C++ ref ("discards qualifiers")

Fork: `Verilator 5.055 devel rev v5.054-65-g4dece87d7`
(`~/workspaceconfig/deps/verilator`, uvm-verilator port)

A *codegen* (not frontend) blocker in the `ganoam:dv:stream_reg_sim`
build, surfaced after the output-after-timing frontend errors were
worked around. Verilation completes; the generated C++ fails to
compile:

```
Vtb__Classes_2__1.cpp:1346:166: error: binding reference of type
  'VlQueue<VlClassRef<Vtb_uvm_pkg__03A__03Auvm_reg> >&' to
  'const VlQueue<VlClassRef<Vtb_uvm_pkg__03A__03Auvm_reg>>' discards qualifiers
    ... __VnoInFunc_randomize_chunk____Vfork_6__0(...,
        ::VlQueue<...uvm_reg>> &registers, ...)
```

Real source: `hw/dv/sv/csr_utils/csr_aliasing_seq.sv`,
`randomize_chunk(const ref uvm_reg registers[$])`.

## Trigger

All three conditions together:

1. a subroutine with a **`const ref`** formal (here a queue),
2. the formal read inside an outer **`fork ... begin ... end join`** block,
3. that block containing an inner **`fork ... join_none`** — the
   spawned process is emitted as a generated `__Vfork` function whose
   parameters take enclosing-scope variables as **non-const `&`**.

The generated function signature declares `VlQueue& registers`, but
the call site passes the `const` formal — g++ rejects the binding.

```systemverilog
class c_wrapper;
  task automatic chunk(const ref int q[$]);
    fork : isolation_fork begin
      automatic int v = q[0];       // q captured into outer fork scope
      fork
        $display("v=%0d", v);       // spawned process -> __Vfork func
      join_none
      wait fork;
    end join
  endtask
endclass
```

Neither piece alone suffices: top-level `join_none` (+ `wait fork`)
or an outer `fork begin/foreach/end join` without a spawned
sub-process both compile clean.

## What does work (all verified, `verilator --binary --timing`)

| Variant | Result |
|---|---|
| nested fork + inner `join_none` + `const ref` formal | **FAIL** (`repro.sv`, `repro_nested.sv`) |
| `const ref` + `fork begin/foreach/end join`, no spawned process | PASS (`repro_foreach.sv`) |
| `const ref` + `fork/join_none` + `wait fork`, not nested | PASS (`ctrl_joinnone.sv`, `repro_join.sv`) |
| `const ref` + plain `fork/join` | PASS (`repro_min.sv`) |
| `const ref`, no fork at all | PASS (`ctrl_nofork.sv`) |
| same shape, **non-const `ref`** formal | PASS (`ctrl_ref.sv`) |
| same shape, **by-value** formal | PASS (`ctrl_byval.sv`) — applied fix |

## Workaround

Drop the `const`: pass the queue **by value** (or non-const `ref`)
and the formal the generated code binds to is no longer const. Applied
in `csr_aliasing_seq.sv` by matching the sibling task `read_back_chunk`,
which upstream already wrote as `task read_back_chunk(uvm_reg
registers[$])`. A local copy (`uvm_reg l[$] = registers;`) works
equally if the `const ref` signature must be kept.

## Real sites

Only `csr_aliasing_seq.sv` (`randomize_chunk`, decl + def). A sweep of
the build's sources found no other `const ref` captured under a fork:
`sample_reg_list` (same file) and `dv_utils_pkg::max` are unforked
functions and never reach the `__Vfork` codegen path.

## Repro index

- `repros/repro.sv` — exact `randomize_chunk` shape: named outer fork +
  `foreach` + inner `join_none` + `wait fork`. FAILS.
- `repros/repro_nested.sv` — same minus `foreach`. FAILS (trigger is the
  nesting, not the loop).
- `repros/repro_min.sv`, `repro_foreach.sv`, `repro_join.sv`,
  `ctrl_joinnone.sv`, `ctrl_nofork.sv` — passing controls isolating the
  trigger.
- `ctrl_ref.sv`, `ctrl_byval.sv` — passing workaround variants.

## Rig

`rig/` reuses the `output-after-timing` filelist (`min.vc` compiles the
real `csr_utils_pkg.sv`, which `include`s `csr_aliasing_seq.sv`):

```sh
cd rig
verilator --binary --timing -f min.vc --top-module min_tb
```

The failure appears only at the generated-C++ compile stage
(`Vtb__Classes_*`); `--lint-only` cannot see it. The repo now carries
the by-value workaround, so the real-code path compiles clean — use
`repros/` or `git show` on the pre-fix file to reproduce.
