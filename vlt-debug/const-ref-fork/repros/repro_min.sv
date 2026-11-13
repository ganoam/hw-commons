// Minimal trigger candidate: const-ref actual read directly inside a
// forked block, no nested join_none needed?
class c_wrapper;
  task automatic chunk(const ref int q[$]);
    fork begin
      $display("q[0]=%0d", q[0]);
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
