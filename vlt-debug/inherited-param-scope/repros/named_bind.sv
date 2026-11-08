// FAIL: same as repro.sv — named binding in the extends clause doesn't help.
class mon;
  typedef int ITEM_T;
endclass

class base #(type MONITOR_T = mon);
  MONITOR_T m;
endclass

class bad extends base #(.MONITOR_T(mon));
  typedef MONITOR_T::ITEM_T item_t;
  item_t x;
endclass

module tb;
  bad b;
  initial b = new();
endmodule
