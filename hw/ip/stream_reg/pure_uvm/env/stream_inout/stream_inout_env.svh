class stream_inout_env extends uvm_env;

  `uvm_component_utils(stream_inout_env)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // TODO 1: Config class
  stream_inout_env_config cfg;

  // --- Member Variables ---
  stream_inout_equal_scoreboard scb;

  stream_agent in_agt;
  stream_agent out_agt;

  uvm_sequencer #(uvm_sequence_item) in_vsqr;
  uvm_sequencer #(uvm_sequence_item) out_vsqr;

  // --- Build Phase ---
  function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(stream_inout_env_config)::get(this, "", "cfg", cfg)) begin
      `uvm_fatal("BUILD",
                 $sformatf("\nClass %s line %0d: failed to get configuration.",
                           this.get_type_name(), `__LINE__))
    end

    cfg.configure(this);

    in_agt = stream_agent::type_id::create("in_agt", this);
    out_agt = stream_agent::type_id::create("out_agt", this);

    scb = stream_inout_equal_scoreboard::type_id::create("scb", this);


  endfunction

  // --- Connect Phase ---
  function void connect_phase(uvm_phase phase);

    in_vsqr = in_agt.sqr;
    out_vsqr = out_agt.sqr;

    // in_agt.mon_aport.connect(scb.in_fifo.analysis_export);
    // out_agt.mon_aport.connect(scb.out_fifo.analysis_export);
    in_agt.mon_aport.connect(scb.in_iexport);
    out_agt.mon_aport.connect(scb.out_iexport);

  endfunction



endclass
