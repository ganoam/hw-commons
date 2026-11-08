// FAIL: the binding value is irrelevant — MONITOR_T bound to a parameter
// reference (M2) rather than a concrete class fails identically. The bug is
// about the '#(...)' specialization wrapper in the extends clause, not what
// the parameter is bound to.
class mon;
  typedef int ITEM_T;
endclass

class base #(type MONITOR_T = mon);
  MONITOR_T m;
endclass

class bad #(type M2 = mon) extends base #(M2);
  typedef MONITOR_T::ITEM_T item_t;
  item_t x;
endclass

module tb;
  bad b;
  initial b = new();
endmodule
