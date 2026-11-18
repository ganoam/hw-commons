# Verilator workaround index

Every source workaround for a Verilator limitation is tagged in-place:

```
// VLT-WORKAROUND(<bug-id>): <what it does>
// Intended: <the code that would be written without the bug>
```

`<bug-id>` names a directory in `vlt-debug/` containing a minimal reproducer
and README. Find all sites:

```sh
grep -rn "VLT-WORKAROUND" hw/
```

When a bug is fixed upstream: verify the reproducer in `vlt-debug/<bug-id>/`
passes, restore the "Intended:" code at each site below, delete the marker,
and update the status here.

| Bug ID | Sites | Status |
|---|---|---|
| `classrefdtype` | `hw/dv/sv/dv_base_agent/dv_base_driver.sv` (`sqr_prov_t` typedef) | open, not filed |
| | `hw/dv/sv/dv_base_agent/dv_base_agent.sv` (`_drv_prov_t`, connect_phase `$cast`) | |
| | `hw/dv/sv/dv_base_agent/dv_reactive_monitor.sv` (`req/rsp_port_base_t`) | |
| | `hw/dv/sv/dv_base_agent/dv_reactive_agent.sv` (`_mon_req/rsp_prov_t`) | |
| | `hw/dv/sv/dv_base_agent/dv_reactive_sequencer.sv` (`item_t`, `rsp_item_t`) | |
| | `hw/dv/sv/push_pull_agent/push_pull_agent.sv` (connect_phase `$cast`) | |
| | `hw/dv/sv/push_pull_agent/seq_lib/push_pull_device_seq.sv` (`_req` intermediate) | |
| `inherited-param-scope` | `hw/dv/sv/push_pull_agent/push_pull_agent.sv` (`MONITOR_T::REQ_ITEM_T` spelling avoided) | open, not filed |
| `output-after-timing` | `hw/dv/sv/csr_utils/csr_utils_pkg.sv` (2 sites: `value`/`status`/`data` copy-out locals) | open, not filed; arguably IEEE-strict, not a bug |
| `const-ref-fork` | `hw/dv/sv/csr_utils/csr_aliasing_seq.sv` (`randomize_chunk`, `read_back_chunk` pass-by-value) | open, not filed |
| `inherited-randmember-scope` | `hw/ip/stream_reg/dv/env/stream_reg_env_cfg.sv` (typedef instead of subclass) | open, not filed |

Not marked — these are platform gates, not workarounds to revert:

- `` `ifdef VERILATOR `` feature gates (`prim_assert.sv`, `pins_if.sv`,
  `dv_fcov_macros.svh`, `tlul_assert.sv`, `prim_lfsr.sv`, ...)
- `/* verilator lint_off */` pragmas — normal lint control
- `deps/uvm-verilator/` — the port itself; its changes belong upstream
