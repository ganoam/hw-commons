class stream_driver extends uvm_driver #(uvm_sequence_item);

  `uvm_component_utils(stream_driver)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // --- Member Variables ---

  // TODO 1: Agent config
  stream_agent_config cfg;


  // TODO 2: Clkrst interface
  // virtual clkrst_if clkrst_vif;

 virtual stream_max_if vif;

  // --- Build Phase ---
  function void build_phase(uvm_phase phase);

    // get protocol interface
    if (!uvm_config_db#(virtual stream_max_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("BUILD",
          $sformatf("\nClass %s line %0d: failed to get vif.\n",
                      this.get_type_name(), `__LINE__))
    end else begin
      `uvm_info(`gfn, $sformatf("Connected to interface: %s", vif.gfn()), UVM_NONE)
    end


    if (!uvm_config_db #(stream_agent_config):: get(this, "", "cfg", cfg)) begin
      `uvm_fatal("BUILD",
          $sformatf("\nClass %s line %0d: failed to get agent config.\n",
                    this.get_type_name(), `__LINE__))
    end

    // TODO 2
    //  if (!uvm_config_db#(virtual clkrst_if)get(this, "", "vif", clkrst_vif))
    //    `uvm_fatal("STREAM_DRIVER",
    //               "\n\nVirtual clkrst_if handle was not obtained!\n\n");
    //   end
  endfunction

  // --- Run Phase ---
  task run_phase(uvm_phase phase);
    uvm_sequence_item generic_item;
    stream_item item;
    `uvm_info(`gfn, $sformatf("is_slave: 0x%x", cfg.is_slave), UVM_HIGH)
    forever begin
      seq_item_port.get_next_item(generic_item);
      `uvm_info(`gfn, generic_item.convert2string(), UVM_HIGH)
      if (!$cast(item, generic_item)) begin
        `uvm_fatal(`gfn, $sformatf("Failed to cast %s to %s", generic_item.get_type_name(), item.get_type_name()))
      end
      if (cfg.is_slave) begin
        vif.recv(item);

      end else begin
        vif.send(item);
      end
      seq_item_port.item_done();
    end
  endtask

endclass
