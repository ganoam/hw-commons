// CONTROL (passes): the production workaround — make the IP-level name a
// typedef ALIAS of the specialization instead of a subclass. The randomize
// target is then the specialization itself, which has no subclass scope
// problem (equivalent to ctrl_no_subclass).
class leaf #(parameter int W = 32);
  rand int v;
  constraint c { v inside {[0:10]}; }
endclass
class base #(parameter int W = 32);
  rand leaf #(W) f;
endclass
typedef base #(32) sub_t;
module tb;
  initial begin
    sub_t c;
    c = new;
    void'(c.randomize());
  end
endmodule
