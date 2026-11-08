class factory #(type T);
  static function T create();
    return null;
  endfunction
endclass

class seq_c #(parameter int W = 32, parameter int D = W);
  typedef factory#(seq_c#(W, D)) type_id;
endclass

// dv_base_agent: member of the type-parameter type, created via S::type_id
class base #(type S = seq_c);
  S seq;
  function void build();
    seq = S::type_id::create();
  endfunction
endclass

// dv_reactive_agent: forwards its own type param into base's
class mid #(type S = seq_c) extends base #(.S(S));
endclass

// push_pull_agent: binds S by parameter reference
class leaf #(parameter int W = 32, parameter int D = W)
    extends mid #(.S(seq_c#(W, D)));
endclass

module tb;
  leaf #(32, 32) c;
  initial begin
    c = new();
    c.build();
  end
endmodule
