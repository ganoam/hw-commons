// Copyright lowRISC contributors (OpenTitan project).
// Modifications by ganoam.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// smoke test vseq
class stream_smoke_vseq #(parameter int DataWidth = 32)
  extends stream_base_vseq#(DataWidth);
  `uvm_object_param_utils(stream_smoke_vseq#(DataWidth))

  `uvm_object_new

endclass : stream_smoke_vseq
