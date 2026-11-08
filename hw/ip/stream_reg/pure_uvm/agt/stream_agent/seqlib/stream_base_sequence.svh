class stream_base_sequence extends uvm_sequence#(stream_item);

  `uvm_object_utils(stream_base_sequence)

  function new(string name = "stream_base_sequence");
    super.new(name);
  endfunction

  uvm_sequencer #(uvm_sequence_item) sqr;

  int unsigned num_trans;
  bit eternal = 1'b0;

  stream_item item;
  virtual task body();
    item = stream_item::type_id::create("item", /*empty*/, get_full_name);

    forever begin
      repeat(num_trans) begin
        start_item(item);
        `uvm_info("start_item" ,$sformatf("type=%s null=%0b str =%s", item.get_type_name(), (item == null), item.convert2string()) , UVM_NONE)
        // `uvm_info("start_item" ,$sformatf("item: %s", item.convert2string()) , UVM_NONE)
        if (!item.randomize()) begin
          `uvm_fatal("RAND", $sformatf("Randomization failed in class @s", this.get_type_name()))
        end
        finish_item(item);
        `uvm_info("finish_item" ,"... ", UVM_NONE)
      end
      if (!eternal) break;
    end

  endtask

endclass
