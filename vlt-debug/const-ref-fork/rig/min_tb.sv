// Real-hierarchy exercise for the const-ref-under-fork codegen issue.
//
// csr_utils_pkg.sv `include`s csr_aliasing_seq.sv. Elaboration and
// verilation succeed; the failure only appears when g++ compiles the
// generated Vtb__Classes_*.cpp:
//
//   error: binding reference of type
//     'VlQueue<VlClassRef<Vtb_uvm_pkg__03A__03Auvm_reg> >&' to
//     'const VlQueue<...>' discards qualifiers
//
// NOTE: --lint-only cannot reproduce this; a full --binary (or --cc +
// make) build is required. Since the production workaround (pass
// registers by value) is applied in the repo, the real-code path now
// compiles clean; reproduce with repros/repro.sv or `git show` the
// pre-fix file.
module min_tb;
  import csr_utils_pkg::*;
  initial begin end
endmodule
