// Copyright lowRISC contributors (OpenTitan project).
// Generated from lowRISC uvmdvgen templates; modifications by ganoam.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class stream_reg_base_vseq extends dv_base_vseq #(
    .CFG_T               (stream_reg_env_cfg),
    .COV_T               (stream_reg_env_cov),
    .VIRTUAL_SEQUENCER_T (stream_reg_virtual_sequencer)
  );
  `include "uvm_macros.svh"
  `include "dv_macros.svh"

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
    //`uvm_error(`gfn, "FIXME")
  endtask

  push_pull_item item;
  virtual task body();
    item = push_pull_item::type_id::create("item", /*empty*/, get_full_name);

    forever begin
      repeat(num_trans) begin
        start_item(item);
        `uvm_info("start_item" ,$sformatf("type=%s null=%0b str =%s", item.get_type_name(), (item == null), item.convert2string()) , UVM_NONE)
        // `uvm_info("start_item" ,$sformatf("item: %s", item.convert2string()) , UVM_NONE)
        if (!item.randomize()) begin
          `uvm_fatal("RAND", $sformatf("Randomization failed in class @s", this.get_type_name()))
        end
        finish_item(item);
        `uvm_info("finish_item" ,"... ", UVM_NONE)
      end
      //if (!eternal) break;
    end
  endtask

endclass : stream_reg_base_vseq
