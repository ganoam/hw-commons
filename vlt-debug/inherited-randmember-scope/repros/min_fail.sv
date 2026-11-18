// FAILING: h.randomize() where h is a concrete subclass whose base has a
// `rand` class-handle member, and the member's class has a constraint block.
class leaf;
  rand int v;
  constraint c { v inside {[0:10]}; }
endclass
class base;
  rand leaf f;
endclass
class sub extends base;
endclass
module tb;
  initial begin
    sub c;
    c = new;
    void'(c.randomize());
  end
endmodule
