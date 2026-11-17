// Copyright lowRISC contributors (OpenTitan project).
// Modifications by ganoam.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class stream_virtual_sequencer #(parameter int DataWidth = 32)
  extends dv_base_virtual_sequencer #(
    .CFG_T(stream_env_cfg#(DataWidth)),
    .COV_T(stream_env_cov#(DataWidth))
  );
  `uvm_component_param_utils(stream_virtual_sequencer#(DataWidth))

  push_pull_sequencer #(.HostDataWidth(DataWidth),.DeviceDataWidth(DataWidth)) in_sequencer_h;
  push_pull_sequencer #(.HostDataWidth(DataWidth),.DeviceDataWidth(DataWidth)) out_sequencer_h;

  `uvm_component_new

endclass
