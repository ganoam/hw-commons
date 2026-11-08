// PASS (control): a method call through the same inherited param under the
// same explicit specialization resolves fine — the failure is specific to
// type lookup (typedef/type-member selection), not to all '::' uses.
class mon;
  static function int f();
    return 1;
  endfunction
endclass

class base #(type MONITOR_T = mon);
  MONITOR_T m;
endclass

class ok extends base #(mon);
  function int g();
    return MONITOR_T::f();
  endfunction
endclass

module tb;
  ok b;
  initial b = new();
endmodule
