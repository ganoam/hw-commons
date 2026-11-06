// Copyright lowRISC contributors (OpenTitan project).
// Generated from lowRISC uvmdvgen templates; modifications by ganoam.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

package stream_reg_env_pkg;
  // dep packages
  import uvm_pkg::*;
  import top_pkg::*;
  import dv_utils_pkg::*;
  import push_pull_agent_pkg::*;
  import push_pull_agent_pkg::*;
  import dv_base_agent_pkg::*;
  import dv_lib_pkg::*;

  // macro includes
  `include "uvm_macros.svh"
  `include "dv_macros.svh"

  // parameters

  // types
  typedef dv_base_reg_block stream_reg_reg_block;

  // functions

  // package sources
  `include "stream_reg_env_cfg.sv"
  `include "stream_reg_env_cov.sv"
  `include "stream_reg_virtual_sequencer.sv"
  `include "stream_reg_scoreboard.sv"
  `include "stream_reg_env.sv"
  `include "stream_reg_vseq_list.sv"

endpackage
