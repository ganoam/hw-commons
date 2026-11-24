# AGENTS.md — notes for anyone working in this repo

Generic binding rules and operating workflow live in
`deps/workflows/agents/` (`rules.md`, `workflow.md`) and apply in
full here. This file holds only repo-specific guidance. Keep it
current per the shared rules.

## What this is

A learning project with an ambition beyond itself: an OpenTitan-style
(lowRISC) UVM verification methodology + infrastructure + IP library,
ported to run on fully open-source tools — Verilator plus the
`uvm-verilator` UVM port — instead of VCS. It started as self-teaching
("For me, to learn") but is meant to become useful to the community:
reusable verification infrastructure others can pick up, not a
one-person experiment.

That ambition shapes how work is done here:

- **Everything is written for an outside reader.** Code and docs must be
  clean, reusable, sustainable, maintainable, extensible — not clever
  shortcuts that only work in this tree.
- **Every binding decision gets documented somewhere** — doc roles per
  `deps/workflows/agents/workflow.md` (layering). Repo-specific
  addition: `vlt-debug/WORKAROUNDS.md` indexes reversible workarounds.

Docs: `README.md` (charter + attribution table), `OT-ROADMAP.md`
(phased port plan), `ROADMAP.md` (IP-level roadmap), `DEVLOG.md`
(chronology), `plan.md`, `debug.md`.

## Repo-specific rules

- **Minimal changes to vendored files.** "You may modify the sv files in
  the repo, but try to touch as little as possible."
- **Never file upstream reports.** Verilator bug reports and PRs (this
  repo or `deps/uvm-verilator`): draft for review, owner posts
  personally. Doubly important here: history rewrites happen and the
  vendored-vs-authored boundary must be reviewed by a human.
- **Reversible workarounds only.** Every Verilator workaround must be
  revertible when the upstream bug is fixed: tag it `VLT-WORKAROUND`,
  show the intended code, register it in `vlt-debug/WORKAROUNDS.md`.
- Commit style: `[area] short lowercase summary` (see `git log`). Git
  history may be rewritten (README warns of force-pushes); vendored
  history is preserved via `git filter-repo` merges (remote `ot-filtered`).
- `DEVLOG.md` is private (`.gitprivate`), dated sections, newest at the
  bottom.
- README upkeep specifics: the **attribution table** must stay true —
  add/adjust a row when vendoring new OpenTitan subtrees or adding
  authored components. Cross-check `ROADMAP.md`/`OT-ROADMAP.md`
  checkboxes when milestones land.
- Non-obvious tool/command knowledge does NOT go in this repo — it lives
  in `deps/workflows/tricks/` (style rules: `agents/workflow.md`).

## Reusable workflows

`deps/workflows/recipes/` documents reusable detailed workflows
(vendoring, upstream bug handling, deps management, ...). When a task
falls under one, read and follow it; the prose targets human readers
but the content binds agents too.

Project-local recipes live in `recipes/` here and layer on top:
`dv-library-extraction.md` (generalizing a testbench into reusable
parameterized infra), `uvm-on-verilator.md` (porting UVM envs to
Verilator: known limits, triage order). Plus `vlt-debug/WORKAROUNDS.md`
(reversible-workaround registry, convention below).

## Branching: public `master` vs. `private`

This repo runs the git-privacy workflow —
`deps/workflows/recipes/git-privacy.md` (model, `.gitprivate`
semantics, `publish.sh` mechanics, graduation recipe). Local instance:

- `origin` = public GitHub repo; private mirror = `self`
  (`hw-commons-private`); `private` branch tracks `self/master` and is
  a superset of `master`. Day-to-day work happens on `private`.
- Private files in `.gitprivate` here: `AGENTS.md`, `DEVLOG.md`,
  `OT-ROADMAP.md`, `debug.md`, `plan.md`, plus tombstones
  `setup/setup-git-hooks.sh`, `setup/publish.sh`.
- Tooling: `deps/scripts` submodule (`git-hooks/`, `git-util/`);
  `deps/scripts/git-util/setup-git-hooks.sh` once per clone.

## Workaround convention (established, use it)

Every source workaround is tagged in place:

```
// VLT-WORKAROUND(<bug-id>): <what it does>
// Intended: <the code that would be written without the bug>
```

`<bug-id>` names a directory under `vlt-debug/` (README + minimal repros
+ real-filelist rig). Find all sites: `grep -rn "VLT-WORKAROUND" hw/`.
The reversal-tracking index is **`vlt-debug/WORKAROUNDS.md`** — update it
when adding/removing a site. Do NOT tag `` `ifdef VERILATOR `` feature
gates or `/* verilator lint_off */` pragmas — those are legitimate
platform gates, not workarounds to revert.

## Layout: vendored vs. authored

The README attribution table is authoritative. ~95% vendored from
lowRISC/OpenTitan: `hw/dv/sv/` shared DV libs, `hw/ip/prim*` + `hw/ip/tlul`,
`util/reggen` + `util/uvmdvgen`, `doc/contributing/dv/methodology`,
`DVCodingStyle.md`. Authored here: `hw/ip/stream_reg/` (pilot IP: RTL,
`pre_dv/` ad-hoc TB, `pure_uvm/` hand-rolled UVM bench, `dv/` generated
env), `hw/dv/sv/stream_env/` (reusable parameterized env generalized out
of the stream_reg env), `vlt-debug/`, `hw/top_dummy/`, top-level docs.

`deps/uvm-verilator/` is a git submodule — a fork of the Accellera
IEEE 1800.2 UVM kit adapted for Verilator. **Version skew matters**: OT
code is written against UVM 1.2 idioms; the port is 1800.2-2020 with
lazily-initialized `phase_done` objections (one shim already needed —
see OT-ROADMAP Phase 2; prefer a compat layer over patching OT files).

## Toolchain and build

- FuseSoC: `/home/ng/workspaceconfig/envs/main/bin/fusesoc`
  (2.4.8.dev15+g2ed5d3364); edalize 0.6.9.dev33; Python 3.14.
- Verilator: `/home/ng/workspaceconfig/deps/verilator/bin/verilator` —
  **the owner's source-built fork** (5.055 devel v5.054-65-g4dece87d7)
  carrying the uvm-verilator port, NOT a release. That checkout has its
  own `AGENTS.md` + `src/AGENTS.md` — read them before touching it.
- `mold` linker speeds builds; `-CFLAGS -O0`, `-skip-identical`, `-j 16`,
  ccache are already configured. FST dumping: `--trace-fst
  --trace-structs`. `--vpi` is required by UVM (`uvm_hdl_*`,
  `uvm_cmdline_processor`). `+define+UVM` set in the sim core.

```console
$ git submodule update --init
$ fusesoc --cores-root=. run --target=sim  ganoam:pre_dv:stream_reg_tb     # ad-hoc TB (TEST PASSED)
$ fusesoc --cores-root=. run --target=sim  ganoam:uvm_pure:stream_reg_tb   # hand-rolled UVM
$ fusesoc --cores-root=. run --target=sim  ganoam:dv:stream_reg_sim:0.1   # OT-style env
$ fusesoc --cores-root=. run --target=lint --setup --build ganoam:dv:stream_reg_sim:0.1  # fast verilation check only
```

Build artifacts: `build/ganoam_dv_stream_reg_sim_0.1/{lint,sim}-verilator`.

## The Verilator bug catalog (`vlt-debug/`)

All characterized on the fork above. Each dir: README (trigger analysis)
+ `repros/` (minimal cases, controls that pass) + `rig/` (real-filelist
reproducer). Bug-report drafts exist for review; **none filed**.

| Bug ID | Trigger | Workaround sites |
|---|---|---|
| `classrefdtype` | Dependent default param + omitted specialization → broken type identity: `expects CLASSREFDTYPE 'X', got CLASSREFDTYPE 'X'`; also rejects legal `connect()` of imp classes (upstream #8588). Fix: explicit `#(...)` + provider-side typedefs + `$cast`. | 7 sites in `dv_base_agent/` and `push_pull_agent/` |
| `inherited-param-scope` | Inherited type param unusable as `::` scope in type context under explicitly specialized base; `B::P` silently binds the *default* param — silent wrong-type hazard (#6814 related). | avoided spelling in `push_pull_agent.sv` |
| `output-after-timing` | IEEE §13.2.2: automatic-task output formals bound into timed class-task outputs under `fork` rejected (arguably strict check, not a bug). Fix: locals + copy-out after `join`. | 2 sites in `csr_utils_pkg.sv` |
| `const-ref-fork` | Codegen: `const ref` queue captured by outer fork + inner `join_none` → non-const `&` in `__Vfork` → g++ "discards qualifiers". Fix: pass by value. | `csr_aliasing_seq.sv` (`randomize_chunk`, `read_back_chunk`) |
| `inherited-randmember-scope` | `.randomize()` on handle typed as concrete subclass of parameterized base with `rand` object member + constraints → `V3Scope.cpp:120` internal error. Fix: typedef alias instead of subclass (costs per-IP factory registration). | `stream_reg_env_cfg.sv` |

Also fixed along the way: `clk_rst_if` time-zero `@event`/`.triggered`
race; `uvm-verilator` `uvm_pkg.core` (`uvm_dpi.cc` as `cppSource`).

## stream_env design decisions (do not re-litigate)

- New `stream_env` components take a single `DataWidth` param, NOT the
  `push_pull_*` pair. `HostDataWidth`/`DeviceDataWidth` are *direction*
  widths (req vs rsp) on one interface — a width-converter IP would need
  `InDataWidth`/`OutDataWidth` per interface instead. That refactor was
  discussed and deliberately NOT applied; if needed later: env gets
  `#(InDataWidth, OutDataWidth = InDataWidth)` and each agent binds both
  direction widths to its own side's width.
- Thin per-IP subclasses exist because factory/type identity needs
  concrete classes — except `stream_reg_env_cfg`, which is a `typedef`
  alias of the specialization (workaround above).
- `push_pull_item` is overridden with `d_data == '0` (non-bidirectional);
  only `h_data` is used.
- Redundant `` `include "uvm_macros.svh"`/`"dv_macros.svh"` `` in class
  files are intentional (LSP) — don't remove as dupes.

## Known limitations (do not "fix" here)

- No covergroups in Verilator — OT signoff is coverage-driven; near-term
  proxy is line/toggle/FSM code coverage (OT-ROADMAP Phase 4).
- SVA subset only; `prim_assert` elaboration coverage unsurveyed.
- `uvm_hdl`/VPI resolves public/synthesized names only; backdoor into
  optimized-away internals can fail silently. RAL frontdoor/backdoor
  unverified at runtime; `dv_base_reg_block` typedef in the generated
  env_pkg may be dead (`debug.md`).

## Current state and next steps

- `stream_reg_sim` builds and runs end-to-end; scoreboard checks;
  runtime issues already worked through (objection lifecycle, agent
  `if_mode`, item compare, auto device-sequence response).
- `stream_env` refactor landed (`20c35ae5`): parameterized env +
  thin `stream_reg` subclasses.
- Next (OT-ROADMAP): verify `num_trans`-parameterized smoke test
  end-to-end; file `vlt-debug` bug reports (draft only — owner files);
  reuse `stream_env` on `stream_fifo` to prove reusability; RAL +
  `tl_agent` is the big wall for real OT IPs.
