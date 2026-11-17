// Copyright lowRISC contributors (OpenTitan project).
// Modifications by ganoam.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class stream_base_vseq #(parameter int DataWidth = 32)
  extends dv_base_vseq #(
    .CFG_T               (stream_env_cfg#(DataWidth)),
    .COV_T               (stream_env_cov#(DataWidth)),
    .VIRTUAL_SEQUENCER_T (stream_virtual_sequencer#(DataWidth))
  );
  `include "uvm_macros.svh"
  `include "dv_macros.svh"

  `uvm_object_param_utils(stream_base_vseq#(DataWidth))

  // various knobs to enable certain routines
  bit do_stream_init = 1'b1;
  int num_trans = 10;

  `uvm_object_new

  virtual task dut_init(string reset_kind = "HARD");
    super.dut_init();
    if (do_stream_init) stream_init();
  endtask

  virtual task dut_shutdown();
    // check for pending stream operations and wait for them to complete
    // TODO
  endtask

  // setup basic stream features
  virtual task stream_init();
  endtask

  virtual task body();
    push_pull_host_seq #(.HostDataWidth(DataWidth), .DeviceDataWidth(DataWidth)) m_host_seq;
    m_host_seq = push_pull_host_seq #(.HostDataWidth(DataWidth), .DeviceDataWidth(DataWidth))::type_id::create("m_host_seq");
    m_host_seq.num_trans = num_trans;
    m_host_seq.start(p_sequencer.in_sequencer_h);

  endtask

endclass : stream_base_vseq
