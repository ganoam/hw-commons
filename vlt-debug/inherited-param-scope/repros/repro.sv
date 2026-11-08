// FAIL: %Error: Package/class for 'class/package reference' not found: 'MONITOR_T'
// Trigger: an inherited type parameter used as the scope of '::' in a type
// context, while the base class is explicitly specialized: extends base#(...).
class mon;
  typedef int ITEM_T;
endclass

class base #(type MONITOR_T = mon);
  MONITOR_T m;
endclass

class bad extends base #(mon);
  typedef MONITOR_T::ITEM_T item_t;
  item_t x;
endclass

module tb;
  bad b;
  initial b = new();
endmodule
