// PASS — the workaround: bind the callee's outputs to LOCALS (not output
// formals), copy out after join. Body writes post-join do not trip the rule.
class regfld;
  task automatic read(output int s, output int v);
    #10 s = 1; v = 42;
  endtask
endclass
module tb;
  task automatic outer(output int v, output int s);
    int l_v, l_s;
    regfld f;
    fork
      begin : iso
        f = new;
        f.read(.s(l_s), .v(l_v));
      end
      begin #100; end
    join_any
    disable fork;
    v = l_v;
    s = l_s;
  endtask
  int x, y;
  initial begin outer(x, y); $display("x=%0d y=%0d", x, y); end
endmodule
