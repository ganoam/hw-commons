// const ref + fork...join_none (no inner fork): does join_none alone trigger?
class c_wrapper;
  task automatic chunk(const ref int q[$]);
    fork
      $display("q[0]=%0d", q[0]);
    join_none
    wait fork;
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
