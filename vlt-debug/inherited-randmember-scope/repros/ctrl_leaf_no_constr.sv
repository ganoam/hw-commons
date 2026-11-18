// CONTROL (passes): the member's class has no constraint block.
class leaf;
  rand int v;
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
