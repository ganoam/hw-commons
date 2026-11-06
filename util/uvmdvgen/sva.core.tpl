CAPI=2:
# Copyright lowRISC contributors (OpenTitan project).
# Generated from lowRISC uvmdvgen templates; modifications by ganoam.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
name: "ganoam:dv:${name}_sva:0.1"
description: "${name.upper()} assertion modules and bind file."
filesets:
  files_dv:
    depend:
      - ganoam:tlul:headers
% if has_ral:
      - ganoam:fpv:csr_assert_gen
% endif
    files:
      - ${name}_bind.sv
    file_type: systemVerilogSource

  files_formal:
    depend:
      - ganoam:ip:${name}

% if has_ral:
generate:
  csr_assert_gen:
    generator: csr_assert_gen
    parameters:
      spec: ../../data/${name}.hjson
% endif

targets:
  default: &default_target
    filesets:
      - files_dv
% if has_ral:
    generate:
      - csr_assert_gen
  formal:
    <<: *default_target
    filesets:
      - files_formal
      - files_dv
    toplevel: ${name}
% endif
