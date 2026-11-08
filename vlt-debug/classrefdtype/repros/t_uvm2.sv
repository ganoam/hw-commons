`include "uvm_macros.svh"
import uvm_pkg::*;

class my_seq #(parameter int W = 32, parameter int D = W) extends uvm_sequencer;
  `uvm_component_param_utils(my_seq#(W, D))
  function new(string name = "my_seq", uvm_component parent = null);
    super.new(name, parent);
  endfunction
endclass

class base_agent #(type SEQ_T = uvm_sequencer) extends uvm_agent;
  `uvm_component_param_utils(base_agent#(SEQ_T))
  SEQ_T sequencer;
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  function void build_phase(uvm_phase phase);
    sequencer = SEQ_T::type_id::create("sequencer", this);
  endfunction
endclass

class mid_agent #(type SEQ_T = uvm_sequencer) extends base_agent#(.SEQ_T(SEQ_T));
  `uvm_component_param_utils(mid_agent#(SEQ_T))
  function new(string name, uvm_component parent); super.new(name, parent);
  endfunction
endclass

class leaf_agent #(parameter int W = 32, parameter int D = W)
    extends mid_agent#(.SEQ_T(my_seq#(W, D)));
  `uvm_component_param_utils(leaf_agent#(W, D))
  function new(string name, uvm_component parent); super.new(name, parent);
  endfunction
endclass

// env: member specialized, but create() called on the unparameterized name
class my_env #(parameter int DataWidth = 32) extends uvm_env;
  `uvm_component_utils(my_env#(DataWidth))
  leaf_agent #(.W(DataWidth), .D(DataWidth)) agt;
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void build_phase(uvm_phase phase);
    agt = leaf_agent::type_id::create("agt", this);
  endfunction
endclass

module tb;
  my_env #(32) env;
  initial begin
    env = my_env#(32)::type_id::create("env", null);
    env.build_phase(null);
  end
endmodule
