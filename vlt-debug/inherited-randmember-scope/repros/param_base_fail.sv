// FAILING: the production shape — the subclass explicitly specializes a
// parameterized base (stream_reg_env_cfg extends stream_env_cfg#(D,D)).
// Parameterization is not required for the bug (see min_fail.sv) but this
// is the form that occurs in the real DV code.
class leaf #(parameter int W = 32);
  rand int v;
  constraint c { v inside {[0:10]}; }
endclass
class base #(parameter int W = 32);
  rand leaf #(W) f;
endclass
class sub extends base #(32);
endclass
module tb;
  initial begin
    sub c;
    c = new;
    void'(c.randomize());
  end
endmodule
