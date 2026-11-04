# dv - Design Verification Methodology and Infrastructure

This repository defines a reusable design verification methodology
for FPGA and ASIC projects and hosts shared verification infrastructure.

## Provenance

The content of this repo heavily builds upon, and in some cases directly
taken from [lowRISC](https://github.com/lowRISC) repositories
(lowRISC contributors, Apache License 2.0 — see `LICENSE` and `NOTICE`).
It serves as the baseline on which an independent DV methodology is
being built. Future work may modify and / or build upon the lowRISC work
The full git history of all files will remain available, documenting original
work and modifications.

The following table indicates the extent of the initial direct copy from the
lowrisc repositories.

| Path | Description | Provenance |
|------|-------------|------------|
| `doc/` | Methodology documentation. `doc/contributing/dv/methodology/README.md` is the core DV methodology document (UVM constrained-random simulation, FPV, verification stages, coverage closure, X-propagation); `doc/getting_started/setup_dv.md` is the getting-started guide. | [lowRISC/OpenTitan](https://github.com/lowRISC/opentitan)|
| `hw/dv/sv/` | Shared SystemVerilog/UVM verification components: `common_ifs` (clock/reset and pin interfaces), `dv_base_agent` (base agent classes), `mem_model` (memory model), `push_pull_agent` (ready/valid and req/ack agent). | [lowRISC/OpenTitan](https://github.com/lowRISC/opentitan)|
| `hw/ip/prim/` | Primitive library: reusable fixed-function RTL blocks plus `doc/` design documents, `dv/` simulation testbenches, `fpv/` formal testbenches, `pre_dv/` Verilator scratch testbenches, and `lint/` waivers. | [lowRISC/OpenTitan](https://github.com/lowRISC/opentitan)|
| `hw/ip/prim_generic/` | Generic implementations of technology-dependent primitives (flops, clock cells, pads, RAMs) resolved via FuseSoC virtual cores. | [lowRISC/OpenTitan](https://github.com/lowRISC/opentitan)|
| `util/` | Tooling, primarily `uvmdvgen.py` (`util/uvmdvgen/`): generates boilerplate UVM agents and full testbench environments. | [lowRISC/OpenTitan](https://github.com/lowRISC/opentitan)|
| DVCodingStyle.md | lowRISC Design Verification Styleguide | [lowRISC/style-guides](https://github.com/lowRISC/style-guides)|
