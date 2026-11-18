// CONTROL (passes): same randomize() call on the base handle directly.
class leaf;
  rand int v;
  constraint c { v inside {[0:10]}; }
endclass
class base;
  rand leaf f;
endclass
module tb;
  initial begin
    base c;
    c = new;
    void'(c.randomize());
  end
endmodule
