// S::type_id resolves a typedef inside the type-parameter's class,
// mirroring uvm_component_param_utils -> uvm_component_registry#(T)
class factory #(type T);
  static function T create();
    return null;
  endfunction
endclass

class seq_c #(parameter int W = 32, parameter int D = W);
  typedef factory#(seq_c#(W, D)) type_id;
endclass

class base #(type S = seq_c);
  S seq;
  function void build();
    seq = S::type_id::create();
  endfunction
endclass

class child #(parameter int W = 32, parameter int D = W)
    extends base #(.S(seq_c#(W, D)));
endclass

module tb;
  child #(32, 32) c;
  initial begin
    c = new();
    c.build();
  end
endmodule
