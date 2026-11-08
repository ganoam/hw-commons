package stream_agent_pkg;

  `include "uvm_macros.svh"
  import uvm_pkg::*;
  `include "dv_macros.svh"

  // localparam int unsigned MAX_WIDTH = 1 << 12;  // maximum width supported.
  localparam int unsigned MAX_WIDTH=32;

  typedef struct {int unsigned DataWidth;} stream_info_t;

  typedef class stream_agent;
  typedef class stream_agent_config;
  typedef class stream_item;
  typedef class stream_monitor;
  typedef class stream_driver;

  `include "stream_sequence_list.svh"
  `include "stream_agent.svh"
  `include "stream_agent_config.svh"
  `include "stream_item.svh"
  `include "stream_monitor.svh"
  `include "stream_driver.svh"

endpackage
