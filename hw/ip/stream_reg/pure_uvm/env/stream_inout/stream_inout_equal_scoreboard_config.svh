class stream_inout_equal_scoreboard_config extends uvm_component;

  `uvm_component_utils(stream_inout_equal_scoreboard_config)

  // TODO XXX
  // uvm_sequence_item in_item_prototype;
  // uvm_sequence_item out_item_prototype;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  int unsigned wait_num_checks = 0;
  int verbosity = UVM_LOW;

  virtual function void configure(stream_inout_equal_scoreboard scb);
    // TODO XXX: Check if this works, instead of direct setting from
    // stream_inout_env_config

    // uvm_sequence_item::set_inst_override(in_item_prototype.get_type_name(), "*scb.in_item");
    // uvm_sequence_item::set_inst_override(out_item_prototype.get_type_name(), "*scb.out_item");
    // uvm_sequence_item::set_inst_override(out_item_prototype.get_type_name(), "*scb.pred_item");
  endfunction

endclass
