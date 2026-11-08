class factory #(type T);
  static function T create();
    return null;
  endfunction
endclass

class comp_c #(parameter int W = 32, parameter int D = W);
  typedef factory#(comp_c#(W, D)) type_id;
endclass

module tb;
  comp_c #(.W(32)) c;   // D omitted -> defaults to W
  initial begin
    c = comp_c::type_id::create();   // also omitted-default specialization
  end
endmodule
