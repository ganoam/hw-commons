// PASS (control): identical to repro.sv except the base is extended with its
// default specialization — 'extends base', no '#(...)' wrapper.
class mon;
  typedef int ITEM_T;
endclass

class base #(type MONITOR_T = mon);
  MONITOR_T m;
endclass

class ok extends base;
  typedef MONITOR_T::ITEM_T item_t;
  item_t x;
endclass

module tb;
  ok b;
  initial b = new();
endmodule
