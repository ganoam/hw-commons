class stream_inout_env_config extends uvm_component;

  `uvm_component_utils(stream_inout_env_config)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // (1) Declare agent-level configs
  stream_agent_config in_agt_cfg;
  stream_agent_config out_agt_cfg;

  stream_inout_equal_scoreboard_config scb_cfg;

  // (2) declare environment-level configuration knobs
  // Set passive per default.
  uvm_active_passive_enum is_active = UVM_PASSIVE;
  // Number of checks for the scoreboard to wait for
  int unsigned wait_num_checks = 0;
  // Set coverage to disabled by default.
  bit coverage_enable = 1'b0;
  // Set default verbosity
  int verbosity = UVM_LOW;

  virtual function void configure (uvm_env env);
    // uvm_agent::type_id::set_inst_override(stream_agent::get_type(), "*env.in_agt*");
    // uvm_agent::type_id::set_inst_override(stream_agent::get_type(), "*env.out_agt*");

    // uvm_scoreboard::type_id::set_inst_override(stream_inout_equal_scoreboard::get_type(), "*scb");

    // Create agent configuration instances and set the config knobs.
    in_agt_cfg  = stream_agent_config::type_id::create("in_agt_cfg", this);

    out_agt_cfg = stream_agent_config::type_id::create("out_agt_cfg", this);

    scb_cfg = stream_inout_equal_scoreboard_config::type_id::create("scb_cfg", this);

    // Configuration knobs
    in_agt_cfg.is_slave        = 1'b0;
    in_agt_cfg.is_active       = this.is_active;
    in_agt_cfg.coverage_enable = this.coverage_enable;
    in_agt_cfg.verbosity       = this.verbosity;

    out_agt_cfg.is_slave        = 1'b1;
    out_agt_cfg.is_active       = this.is_active;
    out_agt_cfg.coverage_enable = this.coverage_enable;
    out_agt_cfg.verbosity       = this.verbosity;

    scb_cfg.wait_num_checks = this.wait_num_checks;
    scb_cfg.verbosity       = this.verbosity;

    uvm_sequence_item::type_id::set_inst_override(stream_item::get_type(), "*scb.in_item");
    uvm_sequence_item::type_id::set_inst_override(stream_item::get_type(), "*scb.out_item");
    uvm_sequence_item::type_id::set_inst_override(stream_item::get_type(), "*scb.pred_item");

    // TODO XXX
    // uvm_sequence_item::set_inst_override(stream_item::get_type(), "*scb_cfg.in_item_prototype");
    // uvm_sequence_item::set_inst_override(stream_item::get_type(), "*scb_cfg.out_item_prototype");


    // Publish the agent-level config classes to all  testbench
    // components at // or below the respective agent's hierarchy level.
    uvm_config_db #(stream_agent_config)::set(env,
                                              "in_agt*",
                                              "cfg",
                                              in_agt_cfg);
    uvm_config_db #(stream_agent_config)::set(env,
                                               "out_agt*",
                                               "cfg",
                                               out_agt_cfg);

    uvm_config_db #(stream_inout_equal_scoreboard_config)::set(env,
                                                              "scb*",
                                                              "cfg",
                                                              scb_cfg);
  endfunction
endclass
