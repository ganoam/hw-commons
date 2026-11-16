// Copyright lowRISC contributors (OpenTitan project).
// Generated from lowRISC uvmdvgen templates; modifications by ganoam.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class stream_reg_base_test extends dv_base_test #(
    .CFG_T(stream_reg_env_cfg),
    .ENV_T(stream_reg_env)
  );

  `include "uvm_macros.svh"
  `include "dv_macros.svh"

  `uvm_component_utils(stream_reg_base_test)
  `uvm_component_new

  // the base class dv_base_test creates the following instances:
  // stream_reg_env_cfg: cfg
  // stream_reg_env:     env

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  // the base class also looks up UVM_TEST_SEQ plusarg to create and run that seq in
  // the run_phase; as such, nothing more needs to be done

  function void end_of_elaboration_phase(uvm_phase phase);
    $display("\n");            // add some white space before topology report
    uvm_top.print_topology();  // prints out the UVM component hierarchy
  endfunction

endclass : stream_reg_base_test
