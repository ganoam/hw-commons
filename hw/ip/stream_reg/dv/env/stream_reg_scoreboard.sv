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
  uvm_tlm_analysis_fifo #(push_pull_item#(.HostDataWidth(DataWidth), .DeviceDataWidth(DataWidth))) in_fifo;
  uvm_tlm_analysis_fifo #(push_pull_item#(.HostDataWidth(DataWidth), .DeviceDataWidth(DataWidth))) out_fifo;

  // local queues to hold incoming packets pending comparison
  push_pull_item#(.HostDataWidth(DataWidth), .DeviceDataWidth(DataWidth)) expected_items[$];
  push_pull_item#(.HostDataWidth(DataWidth), .DeviceDataWidth(DataWidth)) actual_items[$];

  // Statistic counter
  int unsigned       num_of_check_pass;
  int unsigned       num_of_check_fail;

  `uvm_component_new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    in_fifo = new("in_fifo", this);
    out_fifo = new("out_fifo", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    fork
      process_in_fifo();
      process_out_fifo();
    join_none
  endtask

  virtual task process_in_fifo();
    push_pull_item#(.HostDataWidth(DataWidth), .DeviceDataWidth(DataWidth)) item;
    forever begin
      in_fifo.get(item);
      expected_items.push_back(item);
      `uvm_info(`gfn, $sformatf("received push_pull item:\n%0s", item.sprint()), UVM_HIGH)
    end
  endtask

  virtual task process_out_fifo();
    push_pull_item#(.HostDataWidth(DataWidth), .DeviceDataWidth(DataWidth)) item;
    bit check_pass;
    forever begin
      out_fifo.get(item);
      actual_items.push_back(item);
      if (expected_items.size() > 0) begin
        if (actual_items[0].compare(expected_items[0])) begin
          `uvm_info(get_full_name(), $sformatf(
                    "IN ORDER CHECK PASS:\n Expected item:\n%0s Actual item:\n%0s",
                    expected_items[0].sprint(), actual_items[0].sprint()), UVM_HIGH)
           num_of_check_pass++;
           check_pass = 1'b1;
        end else begin
          `uvm_error(get_full_name(), $sformatf(
                     "IN ORDER CHECK FAIL:\n Expected item:\n%0s Actual item:\n%0s",
                     expected_items[0].sprint(), actual_items[0].sprint()))
           num_of_check_fail++;
           check_pass = 1'b0;
        end
      end else begin
          `uvm_error(get_full_name(), $sformatf(
                     "IN ORDER CHECK FAIL:\n Expected item:\n%0s Actual item:\n%0s",
                     expected_items[0].sprint(), actual_items[0].sprint()))
      end


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
