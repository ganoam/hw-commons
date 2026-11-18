// CONTROL (passes): randomizing the member handle directly is fine — the
// bug is in descending into an inherited `rand` object member.
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
    c.f = new;
    void'(c.f.randomize());
  end
endmodule
