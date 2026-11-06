// Copyright lowRISC contributors (OpenTitan project).
// Generated from lowRISC uvmdvgen templates; modifications by ganoam.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class stream_reg_base_vseq extends dv_base_vseq #(
    .CFG_T               (stream_reg_env_cfg),
    .COV_T               (stream_reg_env_cov),
    .VIRTUAL_SEQUENCER_T (stream_reg_virtual_sequencer)
  );
  `uvm_object_utils(stream_reg_base_vseq)

  // various knobs to enable certain routines
  bit do_stream_reg_init = 1'b1;

  `uvm_object_new

  virtual task dut_init(string reset_kind = "HARD");
    super.dut_init();
    if (do_stream_reg_init) stream_reg_init();
  endtask

  virtual task dut_shutdown();
    // check for pending stream_reg operations and wait for them to complete
    // TODO
  endtask

  // setup basic stream_reg features
  virtual task stream_reg_init();
    `uvm_error(`gfn, "FIXME")
  endtask

endclass : stream_reg_base_vseq
