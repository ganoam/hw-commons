// Copyright lowRISC contributors (OpenTitan project).
// Modifications by ganoam.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/**
 * Covergroups that are dependent on run-time parameters that may be available
 * only in build_phase can be defined here
 * Covergroups may also be wrapped inside helper classes if needed.
 */

class stream_env_cov #(parameter int DataWidth = 32)
  extends dv_base_env_cov #(.CFG_T(stream_env_cfg#(DataWidth)));
  `uvm_component_param_utils(stream_env_cov#(DataWidth))

  // the base class provides the following handles for use:
  // stream_env_cfg: cfg

  // covergroups
  // [add covergroups here]

  function new(string name, uvm_component parent);
    super.new(name, parent);
    // [instantiate covergroups here]
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // [or instantiate covergroups here]
  endfunction

endclass
