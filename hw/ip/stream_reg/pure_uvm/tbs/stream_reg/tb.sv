module tb #(
  parameter int unsigned DataWidth = 32
);

  // --- UVM infrastructure ---
  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import stream_inout_test_pkg::*;
  import stream_inout_env_pkg::*;
  import stream_agent_pkg::*;

  // TB Constants
  localparam int unsigned CLK_FREQ_MHZ = 250;

  // --- Internal signals ---
  logic clk_i;
  logic rst_i;

  clkrst_if u_clkrst_if (.clk(clk_i), .rst(rst_i));

  stream_max_if u_in_if (
    .clk_i (clk_i),
    .rst_ni(~rst_i)
  );

  stream_max_if u_out_if (
    .clk_i (clk_i),
    .rst_ni(~rst_i)
  );

  // --- DUT instantiation ---
  stream_reg #(
    .DataWidth(DataWidth)
  ) u_dut (
    .clk_i(clk_i),
    .rst_ni(~rst_i),
    .in_valid_i(u_in_if.valid),
    .in_ready_o(u_in_if.ready),
    .in_data_i(u_in_if.data),
    .out_valid_o(u_out_if.valid),
    .out_ready_i(u_out_if.ready),
    .out_data_o(u_out_if.data)
  );


  //bind stream_reg stream_reg_harness #(.DataWidth(DataWidth)) u_harness ();

  // --- Initial block ---
  initial begin
    // uvm_resource_options::turn_on_tracing();
    // Publish interfaces
    uvm_config_db #(virtual clkrst_if)::set(null, "*", "vif", u_clkrst_if);
    uvm_config_db #(virtual stream_max_if)::set(null, "*out_agt*", "vif", u_out_if);
    uvm_config_db #(virtual stream_max_if)::set(null, "*in_agt*", "vif", u_in_if);

    uvm_resource_pool::get().dump();   // shows which inst_name patterns registered
    $display("u_in_if=%p u_out_if=%p", u_in_if, u_out_if);  // are they distinct?

    $display("match out->in: %0b",
        uvm_is_match("*env.out_agt*", "uvm_test_top.env.in_agt.drv"));  // must be 0
    $display("match in->in:  %0b",
        uvm_is_match("*env.in_agt*", "uvm_test_top.env.in_agt.drv"));   // must be 1


    $display("wc: %0b", uvm_has_wildcard("*env.out_agt*"));   // must be 1

    $display("re out->in: %0d",
        uvm_re_match(uvm_glob_to_re("*env.out_agt*"), "uvm_test_top.env.in_agt.drv")); // must be nonzero (no match)


    // u_dut.u_harness.set_info("*");
    $dumpfile("dump.fst");
    $dumpvars(0, tb);

    // Configure and initiate clock / reset
    u_clkrst_if.set_freq_mhz(CLK_FREQ_MHZ);
    `uvm_info("tb", "starting clock", UVM_HIGH)
    u_clkrst_if.start_clock();
    fork
      u_clkrst_if.apply_sync_reset();
    join_none

    run_test("stream_inout_test");

  end

endmodule
