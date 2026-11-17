// Copyright lowRISC contributors (OpenTitan project).
// Modifications by ganoam.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class stream_common_vseq #(parameter int DataWidth = 32)
  extends stream_base_vseq#(DataWidth);
  `uvm_object_param_utils(stream_common_vseq#(DataWidth))

  constraint num_trans_c {
    num_trans inside {[1:2]};
  }
  `uvm_object_new

endclass
