// FAIL — minimal repro. Mirrors csr_utils_pkg::csr_rd_sub: an automatic
// task's OUTPUT formals bound into a timed CLASS task's output ports,
// inside fork..join_any + disable fork (the csr_rd watchdog shape).
class regfld;
  task automatic read(output int s, output int v);
    #10 s = 1; v = 42;
  endtask
endclass
module tb;
  task automatic outer(output int v, output int s);
    regfld f;
    fork
      begin : iso
        f = new;
        f.read(.s(s), .v(v));   // %Error x2: on .s(s) and .v(v) actuals
      end
      begin #100; end
    join_any
    disable fork;
  endtask
  int x, y;
  initial begin outer(x, y); $display("x=%0d y=%0d", x, y); end
endmodule
