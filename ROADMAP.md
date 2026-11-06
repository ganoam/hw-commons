# Roadmap

- [ ] Verilator compatibility
- [ ] stream_reg: do verification the lowrisc way, evaluate.
    - [ ] naive approach: stream_reg as standalone IP
    - [ ] reuse environment: verify stream_fifo with as little additional code as possible.
- [ ] AXI register bank with DV modeled after lowrisc's TL-UL components.
    - [ ] Hand written AXI regbank
    - [ ] Adapt reggen: generate from hjson spec ->  Autogenerate SW artifacts and Documentation.
- [ ] Remove unhooked lowrisc artifacts from tools and documents
- [ ] Consolidate lowrisc instructions, and guides -> Document my own workflows
- [ ] Evaluate lowrisc methodology
    - [ ] vs. my own research?
    - [ ] Cut down all unnecessary fluff. (what is?)

Notes
- If/when autogenerating my own IPs: Take careto switch the ${vendor} and ${agent_vendor} correctly.
  Best not trust the user to set the vendor flag. try to look it up.
