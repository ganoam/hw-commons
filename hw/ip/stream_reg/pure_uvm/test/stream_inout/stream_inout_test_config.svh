class stream_inout_test_config extends uvm_component;

  `uvm_component_utils(stream_inout_test_config);

  // (1) Declare environment-level config class
  stream_inout_env_config env_cfg;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // (2) Declare test-level configuration knobs as needed
  int unsigned num_trans = 12;
  int verbosity          = UVM_HIGH;
  bit coverage_enable    = 1'b0; // Set coverage to disabled by default.

  // (3) Mandatory function to configure the test and publish the
  //     environment config.
  virtual function void configure(uvm_test test);

    // (4) Parse the simulator plusargs to look for a UVM coverage
    //     enable flag
    if ($test$plusargs("UVM_COVERAGE")) begin
      `uvm_info("COV", "*** Functional coverage enabled ***", UVM_NONE)
      this.coverage_enable = 1'b1;
    end

    // (5) Create environment configuration instance and set the
    //     environment-level config knobs.
    env_cfg = stream_inout_env_config::type_id::create("env_cfg", this);
    env_cfg.is_active       = UVM_ACTIVE;
    env_cfg.wait_num_checks = this.num_trans;
    env_cfg.verbosity       = this.verbosity;
    env_cfg.coverage_enable = this.coverage_enable;


    // (6) Publish the test level config class to the entire
    //     class hierarchy (`test.*`)
    uvm_config_db#(stream_inout_test_config)::set(test, "*", "cfg", this);
    // (7) Publish the environment level config class to all hkk
    //     component below the configured environment (`test.env*`)
    uvm_config_db#(stream_inout_env_config)::set(test, "env*", "cfg", env_cfg);

  endfunction

endclass
