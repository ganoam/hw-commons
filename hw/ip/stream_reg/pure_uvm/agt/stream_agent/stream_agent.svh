class stream_agent extends uvm_agent;

  `include "uvm_macros.svh"

  `uvm_component_utils(stream_agent)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  uvm_sequencer #(uvm_sequence_item) sqr;
  stream_driver                    drv;
  stream_monitor                   mon;
  // stream_coverage                  cov;
  stream_agent_config              cfg;

  uvm_analysis_port #(uvm_sequence_item) mon_aport;

  function void build_phase(uvm_phase phase);

    if (!uvm_config_db #(stream_agent_config)::
        get(this, "", "cfg", cfg)) begin
      `uvm_fatal("BUILD",
             $sformatf("\nClass %s line %0d: failed to get configuration.",
                       this.get_type_name(), `__LINE__))
    end

    cfg.configure(this);

    mon = stream_monitor::type_id::create("mon", this);

    if (cfg.is_active == UVM_ACTIVE) begin
      sqr = uvm_sequencer #(uvm_sequence_item)::type_id::create("sqr", this);
      drv = stream_driver::type_id::create("drv", this);
    end

    if (cfg.coverage_enable) begin
      // cov = stream_coverage::type_id::create("cov", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);

    mon_aport     = mon.aport;

    if (cfg.is_active == UVM_ACTIVE) begin
      drv.seq_item_port.connect(sqr.seq_item_export);
    end

    if (cfg.coverage_enable) begin
      // mon_aport.connect(cov.analysis_export);
    end
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);

    set_report_verbosity_level_hier(cfg.verbosity);
  endfunction
endclass
