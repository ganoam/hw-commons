// minimal repro: classrefdtype identity through type-parameter specialization
class factory #(type T);
  static function T create();
    return null;
  endfunction
endclass

class seq_c #(parameter int W = 32, parameter int D = W);
endclass

class base #(type S = seq_c);
  S seq;
  function void build();
    seq = factory#(S)::create();   // RHS type S via factory#(S)
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
