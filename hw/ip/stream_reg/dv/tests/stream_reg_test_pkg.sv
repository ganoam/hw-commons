// Copyright lowRISC contributors (OpenTitan project).
// Generated from lowRISC uvmdvgen templates; modifications by ganoam.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

package stream_reg_test_pkg;
  // dep packages
  import uvm_pkg::*;
  import dv_lib_pkg::*;
  import stream_reg_env_pkg::*;

  // macro includes
  `include "uvm_macros.svh"
  `include "dv_macros.svh"

  // local types
  class stream_reg_pp_item extends push_pull_agent_pkg::push_pull_item #(.HostDataWidth(DataWidth), .DeviceDataWidth(DataWidth));
    `uvm_object_utils(stream_reg_pp_item)
    `uvm_object_new
    constraint d_data_zero_c { d_data == '0; }
  endclass

  // functions

  // package sources
  `include "stream_reg_base_test.sv"

endpackage
