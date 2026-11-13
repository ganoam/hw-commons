// Non-const ref: binds fine, no const to discard.
class c_wrapper;
  task automatic chunk(ref int q[$]);
    fork : isolation_fork begin
      foreach (q[i]) begin
        automatic int v = q[i];
        fork
          $display("v=%0d", v);
        join_none
      end
      wait fork;
    end join
  endtask
endclass

module tb;
  initial begin
    automatic c_wrapper c = new();
    automatic int q[$] = '{1, 2, 3};
    c.chunk(q);
    $finish;
  end
endmodule
