// Real-hierarchy exercise for the output-after-timing issue.
//
// No probe needed: elaborating csr_utils_pkg.sv itself emits the errors —
// the task output formals `status`/`value` are bound into timed class-task
// output ports (uvm_reg_field::read / uvm_reg::read / write / poke) inside
// fork..join_any + disable fork in csr_rd_sub / csr_wr_and_predict_sub /
// csr_peek-related helpers and the mem backdoor tasks.
//
// Expected: the ~5 csr_utils_pkg "Writing to an output automatic variable
// of a task after a timing control" errors, e.g.
//   csr_utils_pkg.sv:359:45  (.status(status) -> field.read)
module min_tb;
  import csr_utils_pkg::*;
  initial begin end
endmodule
