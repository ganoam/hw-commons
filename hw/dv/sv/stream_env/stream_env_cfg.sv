// Copyright lowRISC contributors (OpenTitan project).
// Modifications by ganoam.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class stream_env_cfg #(parameter int DataWidth = 32)
  extends dv_base_env_cfg;

  `include "uvm_macros.svh"
  `include "dv_macros.svh"

  // ext component cfgs
  rand push_pull_agent_cfg#(.HostDataWidth(DataWidth), .DeviceDataWidth(DataWidth)) m_in_agent_cfg;
  rand push_pull_agent_cfg#(.HostDataWidth(DataWidth), .DeviceDataWidth(DataWidth)) m_out_agent_cfg;

  `uvm_object_param_utils_begin(stream_env_cfg#(DataWidth))
    `uvm_field_object(m_in_agent_cfg, UVM_DEFAULT)
    `uvm_field_object(m_out_agent_cfg, UVM_DEFAULT)
  `uvm_object_utils_end

  `uvm_object_new

  virtual function void initialize(bit inherit_ral_models = 1'b0);
    is_initialized = 1'b1;
    ral_model_names.delete(); // no csr in stream modules

    m_in_agent_cfg  = push_pull_agent_cfg#(.HostDataWidth(DataWidth), .DeviceDataWidth(DataWidth))::type_id::create("m_in_agent_cfg");
    m_out_agent_cfg = push_pull_agent_cfg#(.HostDataWidth(DataWidth), .DeviceDataWidth(DataWidth))::type_id::create("m_out_agent_cfg");

    m_in_agent_cfg.agent_type  = PushAgent;
    m_out_agent_cfg.agent_type = PushAgent;

    m_in_agent_cfg.in_bidirectional_mode = 1'b0;
    m_out_agent_cfg.in_bidirectional_mode = 1'b0;

    m_in_agent_cfg.if_mode = Host;
    m_out_agent_cfg.if_mode = Device;

  endfunction

endclass
