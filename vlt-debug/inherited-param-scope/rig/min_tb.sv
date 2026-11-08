// Real-hierarchy exercise for the inherited-param-scope bug.
//
// push_pull_agent extends dv_reactive_agent#(.MONITOR_T(push_pull_monitor#(W,D)), ...)
// — an explicit specialization. MONITOR_T is declared in dv_reactive_agent /
// dv_base_agent, so in a subclass it is an INHERITED type parameter.
//
//   FAIL: typedef MONITOR_T::REQ_ITEM_T — inherited param as '::' scope.
//   OK:   typedef push_pull_monitor#(W,D)::REQ_ITEM_T — concrete spec scope.
//
// Comment/uncomment the probe classes to bisect.
module min_tb;
  import push_pull_agent_pkg::*;

  // --- FAIL case -------------------------------------------------------
  class probe extends push_pull_agent #(32, 32);
    typedef MONITOR_T::REQ_ITEM_T req_item_t;
    req_item_t x;
  endclass

  // --- workaround (compiles) -------------------------------------------
  class probe_ok extends push_pull_agent #(32, 32);
    typedef push_pull_monitor #(32, 32)::REQ_ITEM_T req_item_t;
    req_item_t x;
  endclass

  initial begin
    probe_ok p;
    p = new("p", null);
  end
endmodule
