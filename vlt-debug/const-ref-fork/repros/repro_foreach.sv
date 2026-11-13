// const ref + fork begin/end + foreach, but NO inner join_none:
class c_wrapper;
  task automatic chunk(const ref int q[$]);
    fork : isolation_fork begin
      foreach (q[i]) begin
        $display("q[%0d]=%0d", i, q[i]);
      end
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
