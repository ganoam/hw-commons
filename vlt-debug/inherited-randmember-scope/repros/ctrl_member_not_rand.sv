// CONTROL (passes): the object member is not `rand`.
class leaf;
  rand int v;
  constraint c { v inside {[0:10]}; }
endclass
class base;
  leaf f;
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
