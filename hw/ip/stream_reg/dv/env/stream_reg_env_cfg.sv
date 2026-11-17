// Copyright lowRISC contributors (OpenTitan project).
// Generated from lowRISC uvmdvgen templates; modifications by ganoam.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// VLT-WORKAROUND(inherited-randmember-scope): randomize() on a subclass
// handle trips V3Scope "Can't locate varref scope" when the base has a `rand`
// object member whose class has constraints (m_in_agent_cfg here).
// Intended: a thin subclass giving the IP its own factory type:
//
//   class stream_reg_env_cfg extends stream_env_cfg #(DataWidth);
//     `uvm_object_utils(stream_reg_env_cfg)
//     `uvm_object_new
//   endclass
//
// The typedef alias loses per-IP factory registration; restore the class once
// the Verilator bug is fixed.
typedef stream_env_cfg #(DataWidth) stream_reg_env_cfg;
