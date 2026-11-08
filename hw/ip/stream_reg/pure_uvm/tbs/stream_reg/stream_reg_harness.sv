module stream_reg_harness #(parameter int unsigned DataWidth) ();

  import uvm_pkg::*;

  stream_if #(
    .DataWidth(DataWidth)
  ) u_in_if (
    .clk_i (stream_reg.clk_i),
    .rst_ni(stream_reg.rst_ni),
    .valid (stream_reg.in_valid_i),
    .ready (stream_reg.in_ready_o),
    .data  (stream_reg.in_data_i)
  );

  stream_if #(
    .DataWidth(DataWidth)
  ) u_out_if (
    .clk_i (stream_reg.clk_i),
    .rst_ni(stream_reg.rst_ni),
    .valid (stream_reg.out_valid_o),
    .ready (stream_reg.out_ready_i),
    .data  (stream_reg.out_data_o)
  );

  // function void set_in_vif(string path);
  //   uvm_config_db #(virtual stream_max_if)::set(null, path, "vif", u_in_if.u_max_if);
  // endfunction

  // function void set_out_vif(string path);
  //   uvm_config_db #(virtual stream_max_if)::set(null, path, "vif", u_out_if.u_max_if);
  // endfunction

  stream_agent_pkg::stream_info_t stream_info;
  initial stream_info.DataWidth = DataWidth;

  function void set_info(string path);
    uvm_config_db #(stream_agent_pkg::stream_info_t)::set(null, path, "info", stream_info);
  endfunction
endmodule
