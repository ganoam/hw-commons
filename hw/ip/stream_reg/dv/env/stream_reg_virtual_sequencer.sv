// Copyright lowRISC contributors (OpenTitan project).
// Generated from lowRISC uvmdvgen templates; modifications by ganoam.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class stream_reg_virtual_sequencer extends dv_base_virtual_sequencer #(
    .CFG_T(stream_reg_env_cfg),
    .COV_T(stream_reg_env_cov)
  );
  `uvm_component_utils(stream_reg_virtual_sequencer)

  push_pull_sequencer in_sequencer_h;
  push_pull_sequencer out_sequencer_h;

  `uvm_component_new

endclass
