class stream_inout_test extends uvm_test;

  `include "uvm_macros.svh"
  `uvm_component_utils(stream_inout_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // (1) Declare member variables
  //     The test class usually contains only Environment,
  //     Test-level configuration instance and clock interface.
  stream_inout_env env;
  stream_inout_test_config cfg;

  virtual clkrst_if clkrst_vif;


  stream_inout_test_base_vsequence vseq;

  function void build_phase(uvm_phase phase);

    // (2) Create the configuration for the test
    cfg = stream_inout_test_config::type_id::create("cfg", this);

    // (3) Call the configuration method to configure itself.
    // Also creates a configuration oject for the environment.
    // Stores both in the configuration database.
    cfg.configure(this);

    // (4) Create the Environment
    env = stream_inout_env::type_id::create("env", this);

    // (5) Get the clock and reset interface
    if (!uvm_config_db #(virtual clkrst_if)::
          get(this, "", "vif", clkrst_vif)) begin
      `uvm_fatal("TEST",
                 "\n\nVirtual clkrst_if handle was not obtained!\n\n");
    end
  endfunction

  // (6) Print the topology for easier debugging
  function void end_of_elaboration_phase(uvm_phase phase);
    $display("\n");            // add some white space before topology report
    uvm_top.print_topology();  // prints out the UVM component hierarchy
  endfunction

  function void connect_phase(uvm_phase phase);
    // (7) Declare and construct the top level virtual sequence
    vseq = stream_inout_test_base_vsequence::type_id::create("vseq");

    // (8) Connect the sequencer handles inside the virtual sequence
    // to the sequencer handles inside the environment
    vseq.in_vsqr     = env.in_vsqr;
    vseq.out_vsqr    = env.out_vsqr;
endfunction

  task run_phase(uvm_phase phase);

    // (9) Raise objections to prevent the run_phase from ending
    phase.raise_objection(this);
      // (10) Start the test processes and drop objection after
      //      everything is done.
      `uvm_info("Reset" ,
                "\n\n\n Waiting for reset to be done... \n\n\n",
                UVM_NONE)
      clkrst_vif.wait_for_reset();
      `uvm_info("Start",
      "\n\n\n Injecting data to the DUT... \n\n\n",
      UVM_NONE)
      // Virtual sequences are started on the `null` sequencer,
      // The actual sequencer handles are passed to the class
      // before hand, such that the relevant sequences inside run
      // on the correct handle.
      vseq.start(null);
    phase.drop_objection(this);
  endtask

endclass
