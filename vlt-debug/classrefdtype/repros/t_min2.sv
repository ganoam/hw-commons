`include "uvm_macros.svh"
import uvm_pkg::*;

class my_comp #(parameter int W = 32) extends uvm_component;
  `uvm_component_param_utils(my_comp#(W))
  function new(string name = "my_comp", uvm_component parent = null);
    super.new(name, parent);
  endfunction
endclass

class my_env #(parameter int W = 32) extends uvm_component;
  `uvm_component_utils(my_env#(W))
  my_comp #(W) c;    // member type spelled via parameter reference
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void build_phase(uvm_phase phase);
    c = my_comp::type_id::create("c", this);   // bare class name -> default specialization
  endfunction
endclass

module tb;
  my_env #(32) env;
  initial begin
    env = my_env#(32)::type_id::create("env", null);
    env.build_phase(null);
  end
endmodule
