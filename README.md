# dv - Design Verification Methodology and Infrastructure

This repository defines a reusable design verification methodology
for FPGA and ASIC projects. It hosts shared verification infrastructure
as well as a library of low-level reusable design IP (primitives).

## Getting Started

Install FuseSoC and edalize into a Python virtual environment:

```console
$ python3 -m venv .venv
$ source .venv/bin/activate
$ pip install fusesoc edalize
```

Install Verilator separately, as described in https://verilator.org.
Make sure to build from source using the most recent upstream master branch.

Then try out one of the Verilator scratch testbenches, e.g.:

```console
$ fusesoc --cores-root=. run --setup --build lowrisc:dv_verilator:prim_trivium_tb
$ ./build/lowrisc_dv_verilator_prim_trivium_tb_0/default-verilator/Vprim_trivium_tb --trace
```

See `hw/ip/prim/pre_dv/` for other testbenches and
`doc/getting_started/setup_dv.md` for the full DV workflow.

## Provenance

The content of this repo heavily builds upon, and in some cases directly
taken from [lowRISC](https://github.com/lowRISC) repositories
(lowRISC contributors — see `NOTICE` and the license texts in `LICENSES/`).
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
| `hw/dv/sv/` | Shared SystemVerilog/UVM verification components: `common_ifs` (clock/reset and pin interfaces), `dv_base_agent` (base agent classes), `mem_model` (memory model), `push_pull_agent` (ready/valid and req/ack agent). | [lowRISC/OpenTitan](https://github.com/lowRISC/opentitan) | Apache-2.0 |
| `hw/ip/prim/` | Primitive design IP: reusable fixed-function RTL blocks (FIFOs, arbiters, synchronizers, crypto cores, ...) plus `doc/` design documents, `dv/` simulation testbenches, `fpv/` formal testbenches, `pre_dv/` Verilator scratch testbenches, and `lint/` waivers. | [lowRISC/OpenTitan](https://github.com/lowRISC/opentitan) | Apache-2.0 |
| `hw/ip/prim_generic/` | Generic implementations of technology-dependent primitives (flops, clock cells, pads, RAMs) resolved via FuseSoC virtual cores. | [lowRISC/OpenTitan](https://github.com/lowRISC/opentitan) | Apache-2.0 |
| `util/` | Tooling, primarily `uvmdvgen.py` (`util/uvmdvgen/`): generates boilerplate UVM agents and full testbench environments. | [lowRISC/OpenTitan](https://github.com/lowRISC/opentitan) | Apache-2.0 |
| `DVCodingStyle.md` | lowRISC Design Verification Styleguide | [lowRISC/style-guides](https://github.com/lowRISC/style-guides) | CC-BY-4.0 |
