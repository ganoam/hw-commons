# Devlog

Chronology of work on this repository (reconstructed from shell history and git log).

## Pre-history [inferred from git log]: `~/code/dv` scratch environment

Before this repo existed, experiments happened in a scratch checkout:

- Hand-rolled Verilator TB for `stream_reg` (`ganoam:util:stream_reg_tb:0`), iterated `fusesoc run --target=sim/--target=lint` + binary runs
- `deps/` submodule setup: `fusesoc`, `verilator`, `opentitan` (sparse checkout), `bin/fusesoc` wrapper scripts
- `gen_flist.py` driven filelists (`toplevels.list` -> `vcode.f`)

Conclusion: submodules+sparse-checkout for OpenTitan was awkward; switched to vendoring with `git filter-repo` instead.

## 2026-11-04 [inferred from git log]: repo setup and OpenTitan vendoring

- `mv dv hw-commons`; initial README
- `git clone` OpenTitan -> `git filter-repo --path ...` (several rounds refining the path list): `hw/dv/sv/{dv_base_agent,push_pull_agent,common_ifs,mem_model,...}`, `hw/ip/prim_generic`, `util/uvmdvgen`, methodology docs
- Merge filtered tree via `remote add ot-filtered /tmp/opentitan` + `git merge --allow-unrelated-histories`
- Second filter-repo pass for `hw/ip/prim` and `DVCodingStyle.md`
- `LICENSES/` + per-part license column + attribution table in README
- Several `git rebase -i HEAD^^` cleanup cycles on the merge artifacts

## 2026-11-05 [inferred from git log]: UVM-on-Verilator bring-up

- Added `deps/uvm-verilator` submodule (`ganoam/uvm-verilator` fork of the IEEE 1800.2 UVM kit); fumbled branch config (dev -> master)
- `prim_lfsr_sim` made Verilator-compatible (`mode: binary`, `--timing`, `-Wno-fatal`, FST trace opts in the `.core`); builds via `fusesoc --target=sim lowrisc:dv:prim_lfsr_sim:0.1`
- `prim_trivium_tb` pre_dv scratch bench verified end-to-end
- Wrote `plan.md` (reusability map for AXI-Lite work) and `ROADMAP.md`

## 2026-11-06 [inferred from git log]: stream_reg DV environment

- Generated skeleton: `./util/uvmdvgen.py -ea push_pull push_pull -e -eo hw/ip/stream_reg/ stream_reg` -> `hw/ip/stream_reg/dv/` artifacts
- `uvmdvgen` templates renamed `lowrisc` -> `ganoam` (VLNV namespace)
- Vendored missing deps from `ot-filtered`: `hw/dv/sv/csr_utils`, `hw/dv/sv/dv_base_reg` (`dv_lib`/`scoreboard` wouldn't compile without)
- README attribution table updated for the new vendored parts
- Whole-history `git rebase -i --root` with a `GIT_SEQUENCE_EDITOR` awk script to move all own commits on top of upstream history; force-pushed
- `// Generated from lowRISC uvmdvgen templates; modifications by ganoam.` added to all `util/uvmdvgen/*.tpl` headers (sed, comment-prefix-aware)

## Current state [inferred from git log]

- `fusesoc --cores-root=. run --setup --build --target sim ganoam:dv:stream_reg_sim:0.1` fails on `ganoam:tlul:headers` dep in `stream_reg_sva.core` (uvmdvgen boilerplate; tlul not vendored)
- Next: fix generated env (double-named `push_pull_agent_agent` members, `top_pkg` import, empty bind), wire `tb.sv`, implement scoreboard + smoke vseq, see `plan.md`/`ROADMAP.md`

## 2026-11-08: Verilator UVM debugging

- `vlt-debug/classrefdtype/`: characterized the `expects CLASSREFDTYPE 'X', got CLASSREFDTYPE 'X'` bug (upstream #8588): dependent default param + omitted specialization.
  Repros + real-filelist rig.
- `vlt-debug/inherited-param-scope/`: second bug found while working around the first: inherited type params can't serve as `::` scope in type context when the base is explicitly specialized (`extends B#(...)`); `B::P` resolves the *default* binding (silent wrong type), `B#(a)::P` works.
  Related upstream #6814 (params as `#()` args also broken).
- Applied `connect()`/`fifo.get()` workarounds across dv_base_agent / dv_reactive_{agent,monitor,sequencer} / push_pull_agent / push_pull_device_seq using typedef members resolved through the provider class's own specialization (param-member `::` spellings hit REFDTYPE unlinks).
  Fixed bare `push_pull_item` in stream_reg_scoreboard.
- Build now reaches `csr_utils_pkg.sv` "output automatic variable after timing control" errors (Verilator --timing restriction), the next blocker.
- `hw/ip/stream_reg/pre_dv/stream_reg_tb.sv`: ad-hoc UVM-free TB (~200 lines): directed fill/drain + randomized soak (2000 tx, variable backpressure), queue scoreboard.
  `fusesoc run --target sim ganoam:pre_dv:stream_reg_tb:0` → TEST PASSED, 2007 transfers, ~0.01 s walltime.
  No fst emitted despite --trace-fst (uninvestigated).

## 2026-11-11: vlt-debug: output-after-timing documented

Third characterized Verilator blocker (the last frontend error class in `stream_reg_sim`): output *formals* of an automatic task bound into a timed **class** task's output ports under `fork` (IEEE 1800-2023 §13.2.2).
Refined the trigger: the caller's `fork` is what matters (callee internal timing irrelevant, class dispatch non-inlinable); static actuals and module-task callees pass.
Workaround verified: bind to locals, copy-out after `join`.
5 real errors: `csr_utils_pkg.sv` 359/362 (`csr_rd_sub` reads) + 664 (backdoor `ptr.read`, `data` formal).
Docs + repros + rig in `vlt-debug/output-after-timing/`.
Upstream context: verilator/verilator#7345 (merged, static-arg case only).

## 2026-11-13: vlt-debug: const-ref-under-fork documented + fixed

Fourth blocker, a codegen (not frontend) one: a `const ref` task formal read inside an outer `fork` block that spawns an inner `join_none` process is emitted as a non-const `&` parameter of the generated `__Vfork` function; g++ rejects binding the const actual ("discards qualifiers").
Only real site: `csr_aliasing_seq::randomize_chunk`.
Fix: pass the queue by value, matching sibling `read_back_chunk`.
Also applied the output-after-timing locals+copy-out fix to `csr_rd_sub`/`mem_rd_sub`.
Docs + repros in `vlt-debug/const-ref-fork/`.

## 2026-11-19: ROADMAP consolidation

- snippet: `deps/workflows` pin bumped.
- snippet: `master` merged into `private`.
- snippet: overall ROADMAP consolidated; disjointed planning documents removed, content now in `ROADMAP.md`.

## 2026-11-20: devlog rework

- Reworked DEVLOG.md onto `recipes/devlog.md` + MdStyle conventions: ISO-dated sections, one sentence per line, no em-dashes; sections before Nov 8 tagged `[inferred from git log]` (reconstructed when the log was started, not contemporaneously).
- snippet: `AGENTS.md` reworked for agent onboarding (slimmed onto the shared template).
- snippet: `deps/scripts` and `deps/workflows` pins bumped.

## 2026-11-24: bump workflows 7ea49fa9...720c0a39 (35 commits)
