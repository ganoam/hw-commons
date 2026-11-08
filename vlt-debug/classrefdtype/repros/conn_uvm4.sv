`include "uvm_macros.svh"
import uvm_pkg::*;

class item #(parameter int W = 32, parameter int D = W) extends uvm_sequence_item;
  `uvm_object_param_utils(item#(W, D))
  function new(string name = "item"); super.new(name); endfunction
endclass

// monitor with analysis port, item bound through param layer
class mid_mon #(type ITEM = item) extends uvm_monitor;
  uvm_analysis_port #(ITEM) req_analysis_port;
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
endclass

class my_mon #(parameter int W = 32, parameter int D = W)
    extends mid_mon#(item#(W, D));
  `uvm_component_param_utils(my_mon#(W, D))
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
endclass

// sequencer holding a tlm_analysis_fifo, item bound through param layer
class mid_seqr #(type ITEM = item) extends uvm_sequencer#(ITEM);
  uvm_tlm_analysis_fifo #(ITEM) req_analysis_fifo;
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
endclass

class my_seqr #(parameter int W = 32, parameter int D = W)
    extends mid_seqr#(item#(W, D));
  `uvm_component_param_utils(my_seqr#(W, D))
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
endclass

class base_agent #(type MONITOR_T = uvm_monitor, type SEQUENCER_T = uvm_sequencer)
    extends uvm_agent;
  `uvm_component_param_utils(base_agent#(MONITOR_T, SEQUENCER_T))
  MONITOR_T monitor;
  SEQUENCER_T sequencer;
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void connect_phase(uvm_phase phase);
    monitor.req_analysis_port.connect(sequencer.req_analysis_fifo.analysis_export);
  endfunction
endclass

class leaf_agent #(parameter int W = 32, parameter int D = W)
    extends base_agent #(
      .MONITOR_T(my_mon#(W, D)),
      .SEQUENCER_T(my_seqr#(W, D)));
  `uvm_component_param_utils(leaf_agent#(W, D))
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
endclass

module tb;
  leaf_agent#(32, 32) agt;
  initial begin
    agt = leaf_agent#(32, 32)::type_id::create("agt", null);
    agt.connect_phase(null);
  end
endmodule
