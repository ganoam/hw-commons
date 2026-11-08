// imp IS-A port_base#(if_base#(T)); connect() should accept it
class if_base #(type T); endclass

class port_base #(type IF); endclass

class imp #(type T, type IMP) extends port_base#(if_base#(T)); endclass

class port #(type T);
  function void connect(port_base#(if_base#(T)) provider);
  endfunction
endclass

class item; endclass

module tb;
  port #(item) p;
  imp  #(item, item) i;
  initial p.connect(i);
endmodule
