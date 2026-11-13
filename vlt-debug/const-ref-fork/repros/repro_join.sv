// const ref + inner fork...join_none but OUTER join_none too:
class c_wrapper;
  task automatic chunk(const ref int q[$]);
    fork
      $display("q[0]=%0d", q[0]);
    join_none
    $display("after");
  endtask
endclass

module tb;
  initial begin
    automatic c_wrapper c = new();
    automatic int q[$] = '{1, 2, 3};
    c.chunk(q);
    #1;
    $finish;
  end
endmodule
