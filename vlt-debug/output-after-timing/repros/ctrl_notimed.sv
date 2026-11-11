// FAIL — callee has NO internal timing; the caller's fork is what matters.
// (The tool cannot prove a class task will not suspend.)
class regfld;
  task automatic read(output int s, output int v);
    s = 1; v = 42;
  endtask
endclass
module tb;
  task automatic outer(output int v, output int s);
    regfld f;
    fork
      begin : iso
        f = new;
        f.read(.s(s), .v(v));   // %Error x2 — still fails
      end
      begin #100; end
    join_any
    disable fork;
  endtask
  int x, y;
  initial begin outer(x, y); $display("x=%0d y=%0d", x, y); end
endmodule
