package stream_inout_env_pkg;

  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import stream_agent_pkg::*;

  typedef class stream_inout_env;
  typedef class stream_inout_env_config;
  typedef class stream_inout_equal_scoreboard;
  typedef class stream_inout_equal_scoreboard_config;

  `include "stream_inout_env.svh"
  `include "stream_inout_env_config.svh"
  `include "stream_inout_equal_scoreboard.svh"
  `include "stream_inout_equal_scoreboard_config.svh"

endpackage
