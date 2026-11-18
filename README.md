# hw-commons - Design Verification Methodology, Infrastructure and IP library

A reusable DV **methodology + infrastructure + primitive-IP library**,
built as an **independent framework on top of the lowRISC/OpenTitan baseline.**

- Aims to provide a project-independent library of fully verified IP
- Uses open-source tools only (OpenTitan uses vcs simulator, we will try to use verilator)

---

## Current state

| already in the repo | gives you | source |
|---|---|---|
| `hw/dv/sv/` | agents, scoreboard, RAL bases, `csr_utils`, `common_ifs` | opentitan [1] |
| `util/reggen`, `util/uvmdvgen` | register + env generators | opentitan [1] |
| `hw/ip/prim(+generic)` | reusable low-level design IP | opentitan |
| `doc/contributing/dv/` | methodology documents | opentitan |
| `deps/uvm-verilator` | UVM-on-Verilator port | uvm-verilator |
| `hw/ip/stream_reg/` | pilot IP: RTL + testplan | ganoam |
| `./stream_reg/pre_dv` | ad-hoc TB | ganoam |
| `./dv` | OT-generated env + hand edits | ganoam |
| `hw/uvm-pure/` | hand-rolled UVM bench | ganoam |
| `vlt-debug/` | Verilator bug repros + workaround docs | ganoam (+ AI) |

[1] with  Verilator workarounds in `dv_base_agent`/`push_pull_agent`, minor uvmdvgen vendor/template fixes

---
## Why it exists: For me, to learn.

- Verification has not been taught in enough detail for my taste.
- So I am building this project to teach myself.
- Potentially to be useful, one day.
---
## The plan

- ✔ **Baseline**:  lowRISC methodology, libraries, generators vendored;
    FuseSoC + Verilator flow up, scratch benches running
- ▸ **Pilot**: `stream_reg`
    - ✔ Pure-UVM testbench running
    - ✔ First module to exercise the opentitan flow
        - refine verification methods:
            - coverage collection
    - Test verilator maturity, [find bugs](https://github.com/verilator/verilator/issues?q=is%3Aissue+author%3Aganoam), [fixes](https://github.com/verilator/verilator/pulls?q=is%3Apr+author%3Aganoam), and workarounds
        - report remaining bugs in vlt-debug
- → **Grow the library**:
    - Explore and exercise and opentitan frameworks, improve verilator compatibilities
    - Not yet used: `mem_model`, `csr_utils`, RAL layers.
- → **Consolidate Guides and Instructions**:
    - Make it easy for people to find their way
    - Encourage other engineers to use and contribute


## Getting Started

Clone this repository including its submodules (`git clone --recursive`,
or `git submodule update --init` in an existing clone). The submodule in
`deps/uvm-verilator` provides the UVM package required by the UVM
testbenches. `deps/scripts` provides git utility scripts and hooks.

Once per clone, run the hook setup to point git at the hooks shipped in
`deps/scripts/git-hooks/`:

```console
$ deps/scripts/git-util/setup-git-hooks.sh
```

This sets `core.hooksPath` relative to the repo root, so submodule
updates refresh the hooks automatically. If the submodule is not
checked out, the hooks silently do not run.

Install FuseSoC and edalize into a Python virtual environment:

```console
$ python3 -m venv .venv
$ source .venv/bin/activate
$ pip install fusesoc edalize
```

Install Verilator separately, as described in https://verilator.org.
Make sure to build from source using the most recent upstream master branch.

Then run one of the Verilator testbenches, e.g. the ad-hoc `stream_reg`
testbench (builds and runs, ends with `TEST PASSED`):

```console
$ fusesoc --cores-root=. run --target=sim ganoam:pre_dv:stream_reg_tb
```

or the pure-UVM `stream_reg` testbench (requires the `deps/uvm-verilator`
submodule):

```console
$ fusesoc --cores-root=. run --target=sim ganoam:uvm_pure:stream_reg_tb
```

> [!WARNING]
> For the time being, I do not expect outside contributers.
> Breaking changes and git history rewrites are possible at any time.

## Attribution

The content of this repo heavily builds upon, and is in some cases directly
taken from [lowRISC](https://github.com/lowRISC) repositories
(lowRISC contributors:  see `NOTICE` and the license texts in `LICENSES/`).
It serves as the baseline on which an independent DV methodology is
being built. Future work may modify and / or build upon the lowRISC work.
The full git history of all files will remain available, documenting original
work and modifications.

The following table indicates the extent of the initial direct copy from the
lowrisc repositories, and the license covering each part. License texts are
provided in `LICENSES/`. Content originating in this repository (original
work) is Apache-2.0.

| Path | Description | Provenance | License |
|------|-------------|------------|---------|
| `doc/` | Methodology documentation. `doc/contributing/dv/methodology/README.md` is the core DV methodology document (UVM constrained-random simulation, FPV, verification stages, coverage closure, X-propagation); `doc/getting_started/setup_dv.md` is the getting-started guide. | [lowRISC/OpenTitan](https://github.com/lowRISC/opentitan) | Apache-2.0 |
| `hw/dv/sv/` | Shared SystemVerilog/UVM verification components: `bus_params_pkg` (bus parameter definitions), `common_ifs` (clock/reset and pin interfaces), `csr_utils` (CSR test sequences operating on the UVM RAL model), `dv_base_agent` (base agent classes), `dv_base_reg` (base RAL model classes incl. shadowed/mubi field coverage), `dv_lib` (base environment and test classes), `dv_utils` (DV macros and utility packages), `mem_model` (memory model), `push_pull_agent` (ready/valid and req/ack agent), `scoreboard` (generic scoreboard), `str_utils` (string utilities). | [lowRISC/OpenTitan](https://github.com/lowRISC/opentitan) | Apache-2.0 |
| `hw/dv/tools/` | DV tooling: `ralgen`, a FuseSoC generator that creates the UVM RAL package and inserts it into the dependency tree. | [lowRISC/OpenTitan](https://github.com/lowRISC/opentitan) | Apache-2.0 |
| `hw/ip/prim/` | Primitive design IP: reusable fixed-function RTL blocks (FIFOs, arbiters, synchronizers, crypto cores, ...) plus `doc/` design documents, `dv/` simulation testbenches, `fpv/` formal testbenches, `pre_dv/` Verilator scratch testbenches, and `lint/` waivers. | [lowRISC/OpenTitan](https://github.com/lowRISC/opentitan) | Apache-2.0 |
| `hw/ip/prim_generic/` | Generic implementations of technology-dependent primitives (flops, clock cells, pads, RAMs) resolved via FuseSoC virtual cores. | [lowRISC/OpenTitan](https://github.com/lowRISC/opentitan) | Apache-2.0 |
| `hw/ip/tlul/` | TL-UL bus interface IP: adapters, sockets, and FIFO/synchronizer crossings. | [lowRISC/OpenTitan](https://github.com/lowRISC/opentitan) | Apache-2.0 |
| `hw/lint/` | Shared lint configuration cores (`common`, `comportable`). | [lowRISC/OpenTitan](https://github.com/lowRISC/opentitan) | Apache-2.0 |
| `hw/check_tool_requirements.*`, `hw/tool_requirements.py` | FuseSoC generator and script enforcing minimum tool versions (Python, edalize, Verilator). | [lowRISC/OpenTitan](https://github.com/lowRISC/opentitan) | Apache-2.0 |
| `hw/ip/stream_reg/` | Original work: the `stream_reg` IP, its `pre_dv/` scratch testbench, and the `pure_uvm/` UVM environment (incl. `stream_agent`, `stream_inout` env/test, `clkrst_if`). `dv/` contains a UVM environment generated from lowRISC `uvmdvgen` templates (see header comments). | Original (this repository); `dv/` generated from lowRISC templates | Apache-2.0 |
| `hw/top_dummy/` | Dummy `top_pkg` satisfying `prim` package dependencies. | Original (this repository) | Apache-2.0 |
| `deps/uvm-verilator/` | IEEE 1800.2 UVM reference implementation adapted for Verilator (git submodule). | [ganoam/uvm-verilator](https://github.com/ganoam/uvm-verilator), fork of the Accellera UVM kit | Apache-2.0 |
| `util/` | Tooling: `reggen` (`util/reggen/`), the register generation package (regtool) producing RTL, UVM RAL models and documentation from register hjson specs; and `uvmdvgen.py` (`util/uvmdvgen/`), which generates boilerplate UVM agents and full testbench environments. | [lowRISC/OpenTitan](https://github.com/lowRISC/opentitan) | Apache-2.0 |
| `DVCodingStyle.md` | lowRISC Design Verification Styleguide | [lowRISC/style-guides](https://github.com/lowRISC/style-guides) | CC-BY-4.0 |

### Import history

Running index of vendored imports: `git filter-repo` rounds merged
with `--allow-unrelated-histories` (later flattened by rebase). The
upstream SHA is the tip of the filtered history: the newest upstream
commit touching the imported paths at import time. Add a row for each
new import.

| Import date | Source repository | Upstream SHA | Imported paths |
|-------------|-------------------|--------------|----------------|
| 2026-11-04 | [lowRISC/opentitan](https://github.com/lowRISC/opentitan) | [`9a6a31d`](https://github.com/lowRISC/opentitan/commit/9a6a31d0430709e4b97b1268232533af9827b244) | `hw/ip/prim` |
| 2026-11-04 | [lowRISC/opentitan](https://github.com/lowRISC/opentitan) | [`531b4bd`](https://github.com/lowRISC/opentitan/commit/531b4bd99bc6ff124b08a000f120e417eecdef80) | `doc/`, `hw/dv/sv/{common_ifs,dv_base_agent,mem_model,push_pull_agent}`, `hw/ip/prim_generic`, `util/uvmdvgen` |
| 2026-11-04 | [lowRISC/style-guides](https://github.com/lowRISC/style-guides) | [`735d911`](https://github.com/lowRISC/style-guides/commit/735d9112220033467e930b9afff250f76794a6fd) | `DVCodingStyle.md` |
| 2026-11-05 | [lowRISC/opentitan](https://github.com/lowRISC/opentitan) | [`eca6e35`](https://github.com/lowRISC/opentitan/commit/eca6e356681128b84276e7b2c5b31f49e724feb6) | `hw/dv/sv/{bus_params_pkg,dv_lib,dv_utils,scoreboard,str_utils}`, `hw/dv/tools/ralgen` |
| 2026-11-05 | [lowRISC/opentitan](https://github.com/lowRISC/opentitan) | [`8b74538`](https://github.com/lowRISC/opentitan/commit/8b745386bce195f5a0d4b7b781d2a457ad43b494) | `util/reggen` |
| 2026-11-06 | [lowRISC/opentitan](https://github.com/lowRISC/opentitan) | [`d87f8dc`](https://github.com/lowRISC/opentitan/commit/d87f8dca16128e729442251d894dffc9496f48b4) | `hw/dv/sv/{csr_utils,dv_base_reg}` |
| 2026-11-06 | [lowRISC/opentitan](https://github.com/lowRISC/opentitan) | [`3e8d137`](https://github.com/lowRISC/opentitan/commit/3e8d137fa29ce026b0365dcfb8c622aeada39a4d) | `hw/ip/tlul` |
| 2026-11-08 | [lowRISC/opentitan](https://github.com/lowRISC/opentitan) | [`e5dcea7`](https://github.com/lowRISC/opentitan/commit/e5dcea7e552c6dcbda5f79a3c107431f116d5267) | `hw/lint`, `hw/check_tool_requirements.*` |
| 2026-11-08 | [lowRISC/opentitan](https://github.com/lowRISC/opentitan) | [`dd5aa7f`](https://github.com/lowRISC/opentitan/commit/dd5aa7f65f1503c352adcde627aae537eadd7f36) | `hw/tool_requirements.py` |
