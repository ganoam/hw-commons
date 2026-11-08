// %Error: Assign RHS expects a CLASSREFDTYPE 'comp_c#(32,32)',
//                   got CLASSREFDTYPE 'comp_c#(32,32)'
// Trigger: a class parameter that defaults to another parameter (D = W),
// combined with the default specialization (bare name / #()).
class factory #(type T);
  static function T create();
    return null;
  endfunction
endclass

class comp_c #(parameter int W = 32, parameter int D = W);
  typedef factory#(comp_c#(W, D)) type_id;
endclass

module tb;
  comp_c #(32, 32) c;
  initial begin
    c = comp_c::type_id::create();      // default specialization -> fails
    // c = comp_c#(32, 32)::type_id::create();  // explicit params -> works
  end
endmodule
