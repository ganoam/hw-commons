`uvm_analysis_imp_decl(_in)
`uvm_analysis_imp_decl(_out)

class stream_inout_equal_scoreboard  extends uvm_scoreboard;

  `uvm_component_utils(stream_inout_equal_scoreboard)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  stream_inout_equal_scoreboard_config cfg;

  uvm_analysis_imp_in#(uvm_sequence_item, stream_inout_equal_scoreboard) in_iexport;
  uvm_analysis_imp_out#(uvm_sequence_item, stream_inout_equal_scoreboard) out_iexport;

  // uvm_tlm_analysis_fifo #(uvm_sequence_item) in_fifo;
  // uvm_tlm_analysis_fifo #(uvm_sequence_item) out_fifo;

  // in and out item templates
  // To be overrideden by configuration class
  stream_item in_item;
  stream_item out_item;
  stream_item pred_item;

  uvm_tlm_analysis_fifo #(stream_item) predictions_fifo;

  bit ok_to_end;

  // Statistics
  int unsigned num_passed;
  int unsigned num_failed;
  int unsigned num_checked;

  function void build_phase(uvm_phase phase);

    if (!uvm_config_db#(stream_inout_equal_scoreboard_config)::get(this, "", "cfg", cfg)) begin
       `uvm_fatal("BUILD",
                  $sformatf("\nClass %s line %0d: failed to get configuration.",
                            this.get_type_name(), `__LINE__))
    end

    cfg.configure(this);

    in_iexport = new("in_iexport", this);
    out_iexport = new("out_iexport", this);

    //in_fifo = new("in_fifo", this);
    //out_fifo = new("out_fifo", this);
    predictions_fifo = new("predictions_fifo", this);
    set_report_verbosity_level_hier(cfg.verbosity);

  endfunction

  function write_in(uvm_sequence_item generic_item);
    if (!$cast(in_item, generic_item)) begin
      `uvm_fatal("CAST", $sformatf("Failed to cast %s to %s",
                                   generic_item.get_type_name(),
                                   in_item.get_type_name()))
    end
    `uvm_info(`gfn, $sformatf("\n\n\nwrite_in: %s", in_item.convert2string()), UVM_HIGH)

    if (!predictions_fifo.try_put(in_item)) `uvm_fatal("blub","blub");

  endfunction

  function write_out(uvm_sequence_item generic_item);

    if (!$cast(out_item, generic_item)) begin
      `uvm_fatal("CAST", $sformatf("Failed to cast %s to %s",
                                    generic_item.get_type_name(),
                                    out_item.get_type_name()))
    end
    `uvm_info(`gfn, {"write_out; out_item:", out_item.convert2string()}, UVM_HIGH)

    if (!predictions_fifo.try_get(pred_item)) begin
      `uvm_error("UNEXP", $sformatf("Unexpected item: %s", out_item.convert2string()))
    end

    `uvm_info(`gfn, {"write_out; pred_item:", pred_item.convert2string()}, UVM_HIGH)

    if (out_item.compare(pred_item) == 1'b0) begin
      `uvm_error("SCB", $sformatf("Expected: %s, Actual: %s",
                                  pred_item.convert2string(),
                                  out_item.convert2string()))
      num_failed += 1;
    end else begin
      num_passed  += 1;
    end
    num_checked += 1;

  endfunction


  function void report_phase(uvm_phase phase);
    `uvm_info(`gfn, $sformatf("\n checked: %0d, passed: %0d, failed: %0d", num_checked, num_passed, num_failed), UVM_LOW)
  endfunction


endclass
