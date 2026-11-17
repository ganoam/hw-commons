// Copyright lowRISC contributors (OpenTitan project).
// Modifications by ganoam.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Generic UVM environment for single-input, single-output stream modules
// verified through push_pull agents (in-order h_data delivery check).
package stream_env_pkg;
  // dep packages
  import uvm_pkg::*;
  import dv_utils_pkg::*;
  import push_pull_agent_pkg::*;
  import dv_base_agent_pkg::*;
  import dv_lib_pkg::*;

  // macro includes
  `include "uvm_macros.svh"
  `include "dv_macros.svh"

  // package sources
  `include "stream_env_cfg.sv"
  `include "stream_env_cov.sv"
  `include "stream_virtual_sequencer.sv"
  `include "stream_scoreboard.sv"
  `include "stream_env.sv"
  `include "stream_vseq_list.sv"

endpackage
