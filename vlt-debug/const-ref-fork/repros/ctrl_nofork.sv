// const ref without any fork: no fork-process capture, no error.
class c_wrapper;
  task automatic chunk(const ref int q[$]);
    foreach (q[i]) $display("q[%0d]=%0d", i, q[i]);
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
