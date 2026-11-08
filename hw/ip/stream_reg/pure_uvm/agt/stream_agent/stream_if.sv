interface stream_max_if (
  input logic clk_i,
  input logic rst_ni
);
  `include "uvm_macros.svh"
  import uvm_pkg::*;
  `include "dv_macros.svh"
  logic valid;
  logic [stream_agent_pkg::MAX_WIDTH-1:0] data;
  logic ready;

  clocking cb @(posedge clk_i);
    inout valid;
    inout data;
    inout ready;
  endclocking

  function string gfn();
    return `gfn;
  endfunction

  task automatic send(stream_agent_pkg::stream_item item);
    int unsigned delay = item.get_delay();
    // `uvm_info("if.send" ,$sformatf("item: %s", item), UVM_NONE)
    //`uvm_info("if.send" ,$sformatf("delay: 0x%x", delay), UVM_NONE)
    repeat(delay) @cb;
    cb.valid <= 1'b1;
    cb.data  <= item.data;
    @(cb iff (cb.ready === 1'b1));
    cb.valid <= 1'b0;
    cb.data  <= 'x;
    //`uvm_info("if.send" ,"\n\n\n if.send end", UVM_NONE)
  endtask

  task automatic recv(stream_agent_pkg::stream_item item);
    int unsigned delay;
    //`uvm_info("if.recv" ,"..." , UVM_NONE)
    fork : recv_fork
      // Randomly toggle
      forever begin
        cb.ready <= 1'b0;
        delay = item.get_delay();
        repeat (delay) @cb;
        cb.ready <= 1'b1;
        delay = item.get_delay();
        if (delay == 0) @cb; // additional delay, in case the randomize delay is in in INSTANT mode.
        repeat (delay) @cb;
      end
      begin
        @(cb iff ((cb.ready === 1'b1) && cb.valid === 1'b1));
        item.data = cb.data;
      end
    join_any;
    disable recv_fork;
    cb.ready <= 1'b0;
  endtask

  task automatic monitor(stream_agent_pkg::stream_item item);
    @(cb iff ((cb.valid === 1'b1) && (cb.ready === 1'b1)));
    item.data = cb.data;
    `uvm_info(`gfn, item.convert2string(), UVM_NONE)
  endtask

endinterface
