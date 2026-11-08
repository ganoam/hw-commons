// Copyright lowRISC contributors (OpenTitan project).
// Generated from lowRISC uvmdvgen templates; modifications by ganoam.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class stream_reg_env extends dv_base_env #(
    .CFG_T              (stream_reg_env_cfg),
    .COV_T              (stream_reg_env_cov),
    .VIRTUAL_SEQUENCER_T(stream_reg_virtual_sequencer),
    .SCOREBOARD_T       (stream_reg_scoreboard)
  );
  `uvm_component_utils(stream_reg_env)

  push_pull_agent #(.HostDataWidth(DataWidth), .DeviceDataWidth(DataWidth)) m_in_agent;
  push_pull_agent #(.HostDataWidth(DataWidth), .DeviceDataWidth(DataWidth)) m_out_agent;

  `uvm_component_new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // create components
    m_in_agent = push_pull_agent#(.HostDataWidth(DataWidth), .DeviceDataWidth(DataWidth))::type_id::create("m_in_agent", this);
    uvm_config_db#(push_pull_agent_cfg#(.HostDataWidth(DataWidth), .DeviceDataWidth(DataWidth)))::set(this, "m_in_agent*", "cfg", cfg.m_in_agent_cfg);
    cfg.m_in_agent_cfg.en_cov = cfg.en_cov;
    // create components
    m_out_agent = push_pull_agent#(.HostDataWidth(DataWidth), .DeviceDataWidth(DataWidth))::type_id::create("m_out_agent", this);
    uvm_config_db#(push_pull_agent_cfg#(.HostDataWidth(DataWidth), .DeviceDataWidth(DataWidth)))::set(this, "m_out_agent*", "cfg", cfg.m_out_agent_cfg);
    cfg.m_out_agent_cfg.en_cov = cfg.en_cov;
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (cfg.en_scb) begin
      m_in_agent.monitor.analysis_port.connect(scoreboard.in_fifo.analysis_export);
      m_out_agent.monitor.analysis_port.connect(scoreboard.out_fifo.analysis_export);
    end
    if (cfg.is_active && cfg.m_in_agent_cfg.is_active) begin
      virtual_sequencer.in_sequencer_h = m_in_agent.sequencer;
    end
    if (cfg.is_active && cfg.m_out_agent_cfg.is_active) begin
      virtual_sequencer.out_sequencer_h = m_out_agent.sequencer;
    end
  endfunction

endclass
