// PASS — but silently resolves the WRONG type. 'base::MONITOR_T' looks up the
// parameter in the GENERIC class, i.e. its DEFAULT binding ('mon'), ignoring
// the specialization the derived class actually used ('empty'). If it had
// respected the specialization, 'empty::REQ_ITEM_T' would not exist and this
// would error. Do not use 'B::P::member' as a workaround unless the default
// binding is what is wanted — use 'B#(args)::P::member' (ctrl_spec_scope.sv).
class mon;
  typedef int REQ_ITEM_T;
endclass

class empty;
endclass

class base #(type MONITOR_T = mon);
  MONITOR_T m;
endclass

class e extends base #(empty);
  typedef base::MONITOR_T::REQ_ITEM_T req_item_t;   // = mon::REQ_ITEM_T (!)
  req_item_t x;
endclass

module tb;
  e v;
  initial v = new();
endmodule
