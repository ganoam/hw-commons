// PASS — same binding, no fork in the caller.
class regfld;
  task automatic read(output int s, output int v);
    s = 1; v = 42;
  endtask
endclass
module tb;
  task automatic outer(output int v, output int s);
    regfld f;
    f = new;
    f.read(.s(s), .v(v));
  endtask
  int x, y;
  initial begin outer(x, y); $display("x=%0d y=%0d", x, y); end
endmodule
