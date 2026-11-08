`include "uvm_macros.svh"
import uvm_pkg::*;

class item #(parameter int W = 32, parameter int D = W) extends uvm_sequence_item;
  `uvm_object_param_utils(item#(W, D))
  function new(string name = "item"); super.new(name); endfunction
endclass

// driver/sequencer reach uvm_* ports through their own param binding layer
class mid_driver #(type ITEM = item) extends uvm_driver#(ITEM);
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
endclass

class my_driver #(parameter int W = 32, parameter int D = W)
    extends mid_driver#(item#(W, D));
  `uvm_component_param_utils(my_driver#(W, D))
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
endclass

class mid_seqr #(type ITEM = item) extends uvm_sequencer#(ITEM);
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
endclass

class my_seqr #(parameter int W = 32, parameter int D = W)
    extends mid_seqr#(item#(W, D));
  `uvm_component_param_utils(my_seqr#(W, D))
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
endclass

// dv_base_agent: driver/sequencer as type params
class base_agent #(type DRIVER_T = uvm_driver, type SEQUENCER_T = uvm_sequencer)
    extends uvm_agent;
  `uvm_component_param_utils(base_agent#(DRIVER_T, SEQUENCER_T))
  DRIVER_T driver;
  SEQUENCER_T sequencer;
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void connect_phase(uvm_phase phase);
    driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction
endclass

// dv_reactive_agent: forwards type params
class mid_agent #(type DRIVER_T = uvm_driver, type SEQUENCER_T = uvm_sequencer)
    extends base_agent#(.DRIVER_T(DRIVER_T), .SEQUENCER_T(SEQUENCER_T));
  `uvm_component_param_utils(mid_agent#(DRIVER_T, SEQUENCER_T))
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
endclass

// push_pull_agent: binds both by parameter reference
class leaf_agent #(parameter int W = 32, parameter int D = W)
    extends mid_agent #(
      .DRIVER_T(my_driver#(W, D)),
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
