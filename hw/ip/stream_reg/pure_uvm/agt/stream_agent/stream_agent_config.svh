class stream_agent_config extends uvm_component;

  `uvm_component_utils(stream_agent_config);

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  uvm_active_passive_enum is_active = UVM_PASSIVE;
  bit coverage_enable = 1'b0;
  bit is_slave        = 1'b0;
  int verbosity       = UVM_LOW;

  virtual function void configure(uvm_agent agent);
    // Override sub-components if needed
    // stream_driver::type_id::
        // set_inst_override(extended_stream_driver::get_type(), "*tx_agt*");
    // ... and other overrides
  endfunction
endclass
