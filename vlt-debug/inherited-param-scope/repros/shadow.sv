// PASS: the derived class's OWN parameter of the same name shadows the
// inherited one, so 'MONITOR_T::REQ_ITEM_T' resolves the own param (which is
// never affected). This is why workarounds spelled via the class's own type
// params (e.g. dv_base_agent's 'DRIVER_T::REQ') are safe.
class mon;
  typedef int REQ_ITEM_T;
endclass

class base #(type MONITOR_T = mon);
  MONITOR_T m;
endclass

class leaf #(type MONITOR_T = mon) extends base #(MONITOR_T);
  typedef MONITOR_T::REQ_ITEM_T req_item_t;   // resolves leaf's own param
  req_item_t x;
endclass

module tb;
  leaf l;
  initial l = new();
endmodule
