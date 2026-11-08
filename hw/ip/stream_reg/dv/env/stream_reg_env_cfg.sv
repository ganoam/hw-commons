// Copyright lowRISC contributors (OpenTitan project).
// Generated from lowRISC uvmdvgen templates; modifications by ganoam.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class stream_reg_env_cfg extends dv_base_env_cfg;

  // ext component cfgs
  rand push_pull_agent_cfg m_in_agent_cfg;
  rand push_pull_agent_cfg m_out_agent_cfg;

  `uvm_object_utils_begin(stream_reg_env_cfg)
    `uvm_field_object(m_in_agent_cfg, UVM_DEFAULT)
    `uvm_field_object(m_out_agent_cfg, UVM_DEFAULT)
  `uvm_object_utils_end

  `uvm_object_new

  virtual function void initialize(bit inherit_ral_models = 1'b0);
    // create push_pull agent config obj
    m_in_agent_cfg = push_pull_agent_cfg::type_id::create("m_in_agent_cfg");
    // create push_pull agent config obj
    m_out_agent_cfg = push_pull_agent_cfg::type_id::create("m_out_agent_cfg");
  endfunction

endclass
