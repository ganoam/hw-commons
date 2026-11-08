// Copyright lowRISC contributors (OpenTitan project).
// Generated from lowRISC uvmdvgen templates; modifications by ganoam.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
module tb;
  // dep packages
  import uvm_pkg::*;
  import dv_utils_pkg::*;
  import stream_reg_env_pkg::*;
  import stream_reg_test_pkg::*;

  // macro includes
  `include "uvm_macros.svh"
  `include "dv_macros.svh"

  wire clk, rst_n;

  // interfaces
  clk_rst_if u_clk_rst_if(.clk(clk), .rst_n(rst_n));
  push_pull_if #(.HostDataWidth(DataWidth), .DeviceDataWidth(DataWidth)) u_in_if(.clk(clk), .rst_n(rst_n));
  push_pull_if #(.HostDataWidth(DataWidth), .DeviceDataWidth(DataWidth)) u_out_if(.clk(clk), .rst_n(rst_n));


  // dut
    stream_reg #(
      .DataWidth(DataWidth)
    ) dut (
    .clk_i(clk),
    .rst_ni(rst_n),
    .in_valid_i(u_in_if.valid),
    .in_ready_o(u_in_if.ready),
    .in_data_i(u_in_if.h_data),
    .out_valid_o(u_out_if.valid),
    .out_ready_i(u_out_if.ready),
    .out_data_o(u_out_if.d_data)
  );

  initial begin
    // drive clk and rst_n from clk_if
    u_clk_rst_if.set_active();
    uvm_config_db#(virtual clk_rst_if)::set(null, "*.env", "clk_rst_vif", u_clk_rst_if);
    uvm_config_db#(virtual push_pull_if#(.HostDataWidth(DataWidth), .DeviceDataWidth(DataWidth)))::set(null, "*.env.m_in_agent*", "vif", u_in_if);
    uvm_config_db#(virtual push_pull_if#(.HostDataWidth(DataWidth), .DeviceDataWidth(DataWidth)))::set(null, "*.env.m_out_agent*", "vif", u_out_if);
    $timeformat(-12, 0, " ps", 12);
    run_test();
  end

endmodule
