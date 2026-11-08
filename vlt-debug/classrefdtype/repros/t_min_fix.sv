`include "uvm_macros.svh"
import uvm_pkg::*;

class my_comp #(parameter int W = 32) extends uvm_component;
  `uvm_component_param_utils(my_comp#(W))
  function new(string name = "my_comp", uvm_component parent = null);
    super.new(name, parent);
  endfunction
endclass

module tb;
  my_comp #(32) c;
  initial begin
    c = my_comp#()::type_id::create("c", null);  // IEEE spelling with #()
  end
endmodule
