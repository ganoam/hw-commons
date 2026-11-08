// PASS (control): a type parameter declared in the SAME class always works
// as a '::' scope — the bug requires the param to be inherited from an
// explicitly specialized base.
class mon;
  typedef int ITEM_T;
endclass

class ok #(type T = mon);
  typedef T::ITEM_T item_t;
  item_t x;
endclass

module tb;
  ok b;
  initial b = new();
endmodule
