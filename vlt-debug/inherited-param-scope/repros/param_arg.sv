// FAIL (different error): upstream verilator/verilator#6814 shape.
// Inherited type params used as '#(...)' arguments in the derived class:
//   %Error: Parameter type pin value isn't a type: Param '__paramNumberN'
//   + Internal Error: AstNode is not of expected type, but instead has type 'PARSEREF'
// Probably the same mechanism: under an explicitly specialized base,
// references to inherited params don't resolve through the specialization.
class item;
endclass

class port #(type T1 = item, type T2 = T1);
  T1 a;
  T2 b;
endclass

class drv #(type REQ = item, type RSP = REQ);
  port #(REQ, RSP) p;   // same-class params: fine
endclass

class my_item extends item;
endclass

class my_drv extends drv #(my_item);
  port #(REQ, RSP) p2;  // REQ/RSP inherited from explicitly-spec'd base: FAIL
endclass

module tb;
  my_drv d;
  initial d = new();
endmodule
