`include "uvm_macros.svh"
import uvm_pkg::*;

class item #(parameter int W = 32, parameter int D = W) extends uvm_sequence_item;
  `uvm_object_param_utils(item#(W, D))
  function new(string name = "item"); super.new(name); endfunction
endclass

class my_driver #(type ITEM = item) extends uvm_driver#(ITEM);
  `uvm_component_param_utils(my_driver#(ITEM))
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
endclass

class my_seqr #(type ITEM = item) extends uvm_sequencer#(ITEM);
  `uvm_component_param_utils(my_seqr#(ITEM))
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
endclass

class my_agent #(type ITEM = item) extends uvm_agent;
  `uvm_component_param_utils(my_agent#(ITEM))
  my_driver#(ITEM) driver;
  my_seqr#(ITEM) sequencer;
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void connect_phase(uvm_phase phase);
    driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction
endclass

module tb;
  my_agent#(item#(32,32)) agt;
  initial begin
    agt = my_agent#(item#(32,32))::type_id::create("agt", null);
    agt.connect_phase(null);
  end
endmodule
