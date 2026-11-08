class stream_inout_test_base_vsequence extends uvm_sequence #(uvm_sequence_item);

  `uvm_object_utils(stream_inout_test_base_vsequence)

  function new(string name = "stream_inout_test_base_vsequence");
    super.new(name);
  endfunction

  // (2) Declare handles to any sequences we want to run.
  stream_base_sequence in_seq;
  stream_base_sequence out_seq;

  // (3) Declare the sequencer handles which the sequences will run on.
  uvm_sequencer #(uvm_sequence_item) in_vsqr;
  uvm_sequencer #(uvm_sequence_item) out_vsqr;

  // (4) Declare a handle to the base test config class
  stream_inout_test_config cfg;

  // (5) Before starting we need to retrieve the overall test config
  //     from the configuration database.
  //     We need to use a sequencer handle to look into the database
  //     because the `this` sequence is not formally extended from the
  //    `uvm_component` and therefore has no business to look into
  //     the database.
  task pre_start();
    if (!uvm_config_db #(stream_inout_test_config)::
        get(in_vsqr, "*", "cfg", cfg)) begin
      `uvm_error("V_SEQ", "stream_inout_test_base_config object cannot be found!")
    end
  endtask

  // (6) Define the overall sequence for the base test
  task body();
    // (7) Instantiate the base sequences we want to use
    in_seq = stream_base_sequence::type_id::create("in_seq");
    out_seq = stream_base_sequence::type_id::create("out_seq");

    // (8) Make modifications to the instantiated sequences, if any
    // In this basic case we just set the number of stimuli items
    // we want to drive
    in_seq.num_trans = cfg.num_trans;
    out_seq.num_trans = 1;
    out_seq.eternal = 1'b1;

    // (9) Start the sequences on the respective sequencers.
    fork
      out_seq.start(out_vsqr);
    join_none
    in_seq.start(in_vsqr);

  endtask

endclass
