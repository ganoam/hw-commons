module min_tb;
  import push_pull_agent_pkg::*;
  push_pull_agent #(32, 32) agt;
  initial agt = new("agt", null);
endmodule
