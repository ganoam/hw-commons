// PASS — STATIC actuals: the disqualifier is the automatic lifetime.
class regfld;
  task automatic read(output int s, output int v);
    #10 s = 1; v = 42;
  endtask
endclass
module tb;
  int st_x, st_y;               // module-level, static lifetime
  task automatic outer();
    regfld f;
    fork
      begin : iso
        f = new;
        f.read(.s(st_y), .v(st_x));  // static actuals — OK
      end
      begin #100; end
    join_any
    disable fork;
  endtask
  initial begin outer(); $display("x=%0d y=%0d", st_x, st_y); end
endmodule
