class stream_monitor extends uvm_monitor;
  `uvm_component_utils(stream_monitor);

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // --- Member Variables ---

  // TODO 1: Agent config
  // stream_agent_config cfg;

  virtual stream_max_if vif;


  uvm_analysis_port #(uvm_sequence_item) aport;

  // --- Build Phase ---
  function void build_phase(uvm_phase phase);

    // TODO 1
    // if (!uvm_config_db #(<protocol>_agent_config)::
    //     get(this, "", "cfg", cfg)) begin
    //   `uvm_fatal("BUILD",
    //       $sformatf("\nClass %s line %0d: failed to get agent config.\n",
    //                 this.get_type_name(), `__LINE__))
    // end

    // instantiate analysis port
    aport = new("aport", this);

    // get virtual interface hande
    if (!uvm_config_db#(virtual stream_max_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("BUILD",
          $sformatf("\nClass %s line %0d: failed to get vif.\n",
                      this.get_type_name(), `__LINE__))
    end else begin
      `uvm_info(`gfn, $sformatf("Connected to interface: %s vif=%p", vif.gfn(),vif), UVM_NONE)
    end


  endfunction

  // --- Run Phase ---
  task run_phase(uvm_phase phase);

    stream_item item;

    forever begin
      item = stream_item::type_id::create("item");
      vif.monitor(item);
      `uvm_info(`gfn, item.convert2string(), UVM_HIGH)
      aport.write(item);
    end
  endtask

endclass
