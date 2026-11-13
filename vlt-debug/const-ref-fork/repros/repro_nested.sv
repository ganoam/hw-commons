// Nested fork + inner join_none, no foreach: is nesting alone enough?
class c_wrapper;
  task automatic chunk(const ref int q[$]);
    fork : isolation_fork begin
      automatic int v = q[0];
      fork
        $display("v=%0d", v);
      join_none
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
