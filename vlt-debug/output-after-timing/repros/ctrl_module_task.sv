// PASS — same fork shape, but the callee is a MODULE task, not a class
// task. Module-task calls are resolved/inlined statically.
module tb;
  task automatic rd(output int v, output int s);
    #10 v = 42; s = 1;
  endtask
  task automatic outer(output int v, output int s);
    fork
      begin : iso
        rd(.v(v), .s(s));
      end
      begin #100; end
    join_any
    disable fork;
  endtask
  int x, y;
  initial begin outer(x, y); $display("x=%0d y=%0d", x, y); end
endmodule
