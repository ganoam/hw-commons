// Copyright lowRISC contributors (OpenTitan project).
// Generated from lowRISC uvmdvgen templates; modifications by ganoam.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class stream_reg_scoreboard extends dv_base_scoreboard #(
    .CFG_T(stream_reg_env_cfg),
    .COV_T(stream_reg_env_cov)
  );
  `uvm_component_utils(stream_reg_scoreboard)

  // local variables

  // TLM agent fifos
  uvm_tlm_analysis_fifo #(push_pull_item) push_pull_fifo;
  uvm_tlm_analysis_fifo #(push_pull_item) push_pull_fifo;

  // local queues to hold incoming packets pending comparison
  push_pull_item push_pull_q[$];
  push_pull_item push_pull_q[$];

  `uvm_component_new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    push_pull_fifo = new("push_pull_fifo", this);
    push_pull_fifo = new("push_pull_fifo", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    fork
      process_push_pull_fifo();
      process_push_pull_fifo();
    join_none
  endtask

  virtual task process_push_pull_fifo();
    push_pull_item item;
    forever begin
      push_pull_fifo.get(item);
      `uvm_info(`gfn, $sformatf("received push_pull item:\n%0s", item.sprint()), UVM_HIGH)
    end
  endtask

  virtual task process_push_pull_fifo();
    push_pull_item item;
    forever begin
      push_pull_fifo.get(item);
      `uvm_info(`gfn, $sformatf("received push_pull item:\n%0s", item.sprint()), UVM_HIGH)
    end
  endtask

  virtual function void reset(string kind = "HARD");
    super.reset(kind);
    // reset local fifos queues and variables
  endfunction

  function void check_phase(uvm_phase phase);
    super.check_phase(phase);
    // post test checks - ensure that all local fifos and queues are empty
  endfunction

endclass
