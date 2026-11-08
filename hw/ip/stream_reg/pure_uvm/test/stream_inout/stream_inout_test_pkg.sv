package stream_inout_test_pkg;

  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import stream_agent_pkg::*;
  import stream_inout_env_pkg::*;

  typedef class stream_inout_test_config;
  typedef class stream_inout_test;

  typedef stream_agent_config;

  `include "stream_inout_test_sequence_list.svh"
  `include "stream_inout_test_config.svh"
  `include "stream_inout_test.svh"

endpackage
