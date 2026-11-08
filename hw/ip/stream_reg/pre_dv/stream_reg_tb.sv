// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Ad-hoc (pre-DV) testbench for stream_reg — no UVM.
//
// DUT: 2-entry ready/valid skid buffer
// Stimulus: directed fill/drain phases + randomized soak with variable
// backpressure on both interfaces. Checking: queue scoreboard plus the
// inline SVAs in the DUT itself.
//
// All BFM sampling/driving is done in @(posedge clk) blocks: reads observe
// pre-edge values (NBA updates land later in the timestep), writes are
// nonblocking. This avoids any active/NBA race against the DUT.

`timescale 1ns/1ps

module stream_reg_tb;

  localparam int unsigned DataWidth = 32;
  localparam int unsigned NumTx     = 2000;    // soak-phase transfers
  localparam int unsigned MaxCycles = 200000;  // global watchdog

  // ------------------------------------------------------------------
  // Clock / reset / DUT
  // ------------------------------------------------------------------

  logic clk = 1'b0;
  always #5 clk = ~clk;

  logic rst_n;

  logic                 in_valid;
  logic                 in_ready;
  logic [DataWidth-1:0] in_data;
  logic                 out_valid;
  logic                 out_ready;
  logic [DataWidth-1:0] out_data;

  stream_reg #(.DataWidth(DataWidth)) dut (
    .clk_i       (clk),
    .rst_ni      (rst_n),
    .in_valid_i  (in_valid),
    .in_ready_o  (in_ready),
    .in_data_i   (in_data),
    .out_valid_o (out_valid),
    .out_ready_i (out_ready),
    .out_data_o  (out_data)
  );

  // ------------------------------------------------------------------
  // Scoreboard
  // ------------------------------------------------------------------

  logic [DataWidth-1:0] exp_q[$];
  int unsigned          num_sent;
  int unsigned          num_checked;
  int unsigned          num_errors;

  // Output monitor: a posedge with out_valid && out_ready transfers the
  // current out_data — pop the queue and compare in order.
  always @(posedge clk) begin
    if (rst_n === 1'b1 && out_valid && out_ready) begin
      logic [DataWidth-1:0] got;
      logic [DataWidth-1:0] exp;
      got = out_data;
      if (exp_q.size() == 0) begin
        $error("%0t: unexpected output data 'h%h", $time, got);
        num_errors++;
      end else begin
        exp = exp_q.pop_front();
        if (exp !== got) begin
          $error("%0t: data mismatch: expected 'h%h, got 'h%h", $time, exp, got);
          num_errors++;
        end else begin
          num_checked++;
        end
      end
    end
  end

  // ------------------------------------------------------------------
  // BFMs
  // ------------------------------------------------------------------

  // Push one item: assert in_valid with a random idle gap, hold data stable
  // until the transfer completes. push_back happens on the accept edge, so
  // exp_q order == in-interface order.
  task automatic send(input logic [DataWidth-1:0] data,
                      input int  unsigned         max_delay = 3);
    repeat ($urandom_range(0, max_delay)) @(posedge clk);
    in_valid <= 1'b1;
    in_data  <= data;
    do @(posedge clk); while (!in_ready);
    in_valid <= 1'b0;
    exp_q.push_back(data);
    num_sent++;
  endtask

  // Receiver backpressure: out_ready asserted with recv_pct% probability
  // each cycle. Single driver process; stimulus only sets the percentage.
  int unsigned recv_pct = 0;
  always @(posedge clk) begin
    if (!rst_n) out_ready <= 1'b0;
    else        out_ready <= ($urandom_range(0, 99) < recv_pct);
  end

  // Wait for DUT + scoreboard to drain (assumes recv_pct allows progress).
  task automatic wait_idle(input int unsigned max_cycles = 200);
    int unsigned c;
    while ((exp_q.size() != 0 || in_valid || out_valid) && c < max_cycles) begin
      @(posedge clk);
      c++;
    end
    if (c >= max_cycles) begin
      $error("%0t: timeout waiting for drain (exp_q=%0d)", $time, exp_q.size());
      num_errors++;
    end
    repeat (2) @(posedge clk);  // settle before next phase
  endtask

  // ------------------------------------------------------------------
  // Stimulus
  // ------------------------------------------------------------------

  initial begin : stimulus

    $dumpfile("dump.fst");
    $dumpvars(0, tb);

    in_valid <= 1'b0;
    in_data  <= '0;
    rst_n     = 1'b0;
    repeat (5) @(posedge clk);
    rst_n = 1'b1;
    repeat (2) @(posedge clk);

    // -- Phase 1: directed single transfer ------------------------------
    recv_pct = 100;
    send(32'hdead_beef, 0);
    wait_idle();

    // -- Phase 2: full-buffer backpressure ------------------------------
    // Fill both entries with the receiver stalled, then check in_ready
    // deasserts and out_valid stays put, then drain in order.
    recv_pct = 0;
    send(32'hcafe_f00d, 0);
    send(32'hbadc_0ffe, 0);
    repeat (2) @(posedge clk);
    if (in_ready  !== 1'b0) begin
      $error("in_ready high while buffer full"); num_errors++;
    end
    if (out_valid !== 1'b1) begin
      $error("out_valid low with data buffered"); num_errors++;
    end
    // open the receiver after 4 stalled cycles; the sends below stall on
    // !in_ready in the meantime (single driver — sends stay sequential)
    fork
      begin
        repeat (4) @(posedge clk);
        recv_pct = 100;
      end
    join_none
    send(32'ha5a5_5a5a, 0);   // stalls until a slot frees
    send(32'h1234_5678, 0);
    wait fork;
    wait_idle();

    // -- Phase 3: mid-test reset ----------------------------------------
    rst_n = 1'b0;
    repeat (3) @(posedge clk);
    if (out_valid !== 1'b0 || in_ready !== 1'b1) begin
      $error("outputs not in reset state: out_valid=%b in_ready=%b",
             out_valid, in_ready);
      num_errors++;
    end
    rst_n = 1'b1;
    repeat (2) @(posedge clk);
    send(32'h5555_5555, 0);
    send(32'haaaa_aaaa, 0);
    wait_idle();

    // -- Phase 4: randomized soak ---------------------------------------
    // Variable backpressure on the receiver, random gaps on the sender;
    // the recv_pct knob is re-rolled periodically to sweep regimes.
    recv_pct = 50;
    for (int i = 0; i < NumTx; i++) begin
      if (i % 100 == 0) recv_pct = $urandom_range(10, 90);
      send(DataWidth'($urandom()), 4);
      if (i % 500 == 499) $display("%0t: soak %0d/%0d done", $time, i + 1, NumTx);
    end
    recv_pct = 100;
    wait_idle(1000);

    // -- Report ----------------------------------------------------------
    if (num_errors == 0 && num_checked == num_sent) begin
      $display("TEST PASSED: %0d transfers checked", num_checked);
    end else begin
      $display("TEST FAILED: %0d errors, %0d/%0d transfers checked",
               num_errors, num_checked, num_sent);
    end
    $finish;
  end

  // Watchdog
  initial begin
    repeat (MaxCycles) @(posedge clk);
    $fatal(1, "watchdog timeout after %0d cycles", MaxCycles);
  end

endmodule
