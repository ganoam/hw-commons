// FAIL: the param can be declared two levels up — nearest explicitly-
// specialized ancestor is what matters. Mimics
// dv_base_agent <- dv_reactive_agent <- push_pull_agent forwarding.
class mon;
  typedef int REQ_ITEM_T;
endclass

class base #(type MONITOR_T = mon);
  MONITOR_T m;
endclass

class mid #(type MONITOR_T = mon) extends base #(.MONITOR_T(MONITOR_T));
endclass

// NOTE: 'leaf' has no own MONITOR_T — the name resolves only to the param
// inherited from 'mid', whose base was explicitly specialized.
class leaf extends mid #(mon);
  typedef MONITOR_T::REQ_ITEM_T req_item_t;
  req_item_t x;
endclass

module tb;
  leaf l;
  initial l = new();
endmodule
