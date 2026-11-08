// PASS (workaround): scope the param through the explicit specialization.
// base#(mon)::MONITOR_T resolves to the binding of that specialization, then
// ::ITEM_T resolves inside it. This gives the CORRECT specialized binding.
class mon;
  typedef int ITEM_T;
endclass

class base #(type MONITOR_T = mon);
  MONITOR_T m;
endclass

class ok extends base #(mon);
  typedef base #(mon)::MONITOR_T::ITEM_T item_t;
  item_t x;
endclass

module tb;
  ok b;
  initial b = new();
endmodule
