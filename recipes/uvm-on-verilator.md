# Porting a UVM environment to Verilator

Workflow for getting an OpenTitan-style UVM testbench running on
Verilator plus a UVM port (e.g. `uvm-verilator`), when the original
target was a commercial simulator.
The content of this file is unconfirmed and evolving.

## Known limits to design around first

- No covergroups. Functional coverage intent must be documented or
  reimplemented, not ported.
- SVA support is partial. Simple immediate/concurrent assertions
  mostly work; sequence-heavy properties may not.
- `uvm_hdl` / backdoor access is limited. Prefer frontdoor or
  interface-based access where possible.
- Timing constructs in classes (delays, event waits inside automatic
  tasks) hit elaboration bugs more often than module-level code.

## Triage order for failures

1. Build with maximum verbosity; separate elaboration errors from
   compile errors and runtime hangs.
2. For each error, classify: legal SV that Verilator mishandles
   (tool bug, see `upstream-bugs.md`) versus project code that was
   never legal and only tolerated elsewhere.
3. Internal errors (`V3*.cpp` assertions, `Can't locate varref
   scope`) are always tool bugs; isolate and document.
4. Check type-identity problems early: dependent-default
   specialization, inherited parameter scope, and `connect()`
   signature matching fail in characteristic ways.

## Keep working

- Workarounds tagged and indexed (see `upstream-bugs.md`); expect
  them to be reverted when the tool fixes land.
- Time-zero event races: replace `wait`/event handshakes at time
  zero with delta-safe or explicit ordering constructs.
- Queues/refs captured by nested `fork` constructs and `const ref`
  formals in forked code are recurring triggers; check there first.
