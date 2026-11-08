interface clkrst_if (
  output logic clk,
  output logic rst
);

  `include "uvm_macros.svh"
  import uvm_pkg::*;

  // --- Member Variables ---
  int unsigned freq_mhz;
  int unsigned clockperiod_ps;
  bit clk_en;

  //timeunit 1ns/1ps;

  clocking cb @(posedge clk);
    inout rst;
  endclocking

  // --- Member Methods ---
  // Note: Scope explicitly automatic!
  task automatic apply_sync_reset();
    @cb;
    cb.rst <= 1'b1;
    repeat(10) @cb;
    cb.rst <= 1'b0;
    @cb;
  endtask

  task automatic wait_for_reset();
    wait(rst==1'b0);
  endtask

  task automatic wait_for_reset_end();
    // reset deassert is always sync.
    @(cb iff cb.rst == 1'b1);
  endtask

  function automatic void set_freq_mhz(int unsigned in_freq);
    freq_mhz = in_freq;
    clockperiod_ps = 1e6 / freq_mhz;
  endfunction

  function automatic void start_clock();
    clk_en = 1'b1;
  endfunction

  function automatic void stop_clock();
    clk_en = 1'b0;
  endfunction


  // --- Run loop ---
  initial begin
    if (clockperiod_ps == 0) `uvm_fatal("CLKRST", "No frequency set")
    clk = 1'b0;

    forever begin
      #((clockperiod_ps / 2) * 1ps)
      if (clk_en == 1'b1) clk = ~clk;
    end
  end

endinterface

