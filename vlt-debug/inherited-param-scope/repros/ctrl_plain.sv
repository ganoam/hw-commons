// PASS (control): under the same explicit specialization, the inherited
// params DO resolve for ordinary uses — as a plain type and as a value param.
// Only the '::' type-scope lookup path fails.
class mon;
  typedef int ITEM_T;
endclass

class base #(type MONITOR_T = mon, parameter int W = 8);
  MONITOR_T m;
endclass

class ok extends base #(mon);
  MONITOR_T m2;        // inherited type param as a plain type: OK
  bit [W-1:0] v;       // inherited value param: OK
endclass

module tb;
  ok b;
  initial b = new();
endmodule
