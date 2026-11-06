# Copyright lowRISC contributors (OpenTitan project).
# Modifications by ganoam.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
"""Generate SystemVerilog UVM agent extended from our DV lib
"""

import os
import logging as log

from mako.template import Template
import importlib.resources
from uvmdvgen import VENDOR_DEFAULT
from uvmdvgen import AGENT_VENDOR_DEFAULT


def gen_env(name, is_cip, has_ral, has_interrupts, has_alerts, num_edn,
            env_agents, root_dir, vendor, agent_vendor):
    # yapf: disable
    # flake8: noqa
    # 4-tuple - sub-path, ip name, class name, file ext
    env_srcs = [('dv/env',          name + '_', 'env_cfg',            '.sv'),
                ('dv/env',          name + '_', 'env_cov',            '.sv'),
                ('dv/env',          name + '_', 'env_pkg',            '.sv'),
                ('dv/env',          name + '_', 'scoreboard',         '.sv'),
                ('dv/env',          name + '_', 'virtual_sequencer',  '.sv'),
                ('dv/env',          name + '_', 'env',                '.sv'),
                ('dv/env',          name + '_', 'env',                '.core'),
                ('dv/env/seq_lib',  name + '_', 'base_vseq',          '.sv'),
                ('dv/env/seq_lib',  name + '_', 'smoke_vseq',         '.sv'),
                ('dv/env/seq_lib',  name + '_', 'common_vseq',        '.sv'),
                ('dv/env/seq_lib',  name + '_', 'vseq_list',          '.sv'),
                ('dv',              '',         'tb',                 '.sv'),
                ('dv/sva',          name + '_', 'bind',               '.sv'),
                ('dv/sva',          name + '_', 'sva',                '.core'),
                ('dv/tests',        name + '_', 'base_test',          '.sv'),
                ('dv/tests',        name + '_', 'test_pkg',           '.sv'),
                ('dv/tests',        name + '_', 'test',               '.core'),
                ('dv/cov',          '',         '',                   ''),
                ('dv',              name + '_', 'sim_cfg',            '.hjson'),
                ('doc/dv',          '',         'index',              '.md'),
                ('doc',             '',         'checklist',          '.md'),
                ('data',            name + '_', 'testplan',           '.hjson'),
                ('dv',              name + '_', 'sim',                '.core')]
    # yapf: enable

    if (vendor != VENDOR_DEFAULT and agent_vendor == AGENT_VENDOR_DEFAULT
            and env_agents != []):
        env_core_path = root_dir + "/dv/env/" + name + "_env.core"
        print(
            "WARNING: --vendor is set to '{}' but --env-agents is supplied "
            "without --agent-vendor. Agent dependencies in the generated {} "
            "file will still use vendor '{}'. Please check the VLNV names "
            "if this is not intended.".format(vendor, env_core_path,
                                             agent_vendor))

    for tup in env_srcs:
        path_dir = root_dir + '/' + tup[0]
        src_prefix = tup[1]
        src = tup[2]
        src_suffix = tup[3]

        ftpl = src + src_suffix + '.tpl'
        file_name = src_prefix + src + src_suffix

        if not os.path.exists(path_dir):
            os.system("mkdir -p " + path_dir)
        if file_name == "":
            continue

        # Skip the checklist if it already exists.
        file_path = os.path.join(path_dir, file_name)
        if src == 'checklist' and os.path.exists(file_path):
            continue

        # read template
        tpl = Template(filename=str(importlib.resources.files('uvmdvgen') / ftpl))

        # create rendered file
        with open(file_path, 'w') as fout:
            try:
                fout.write(
                    tpl.render(name=name,
                               is_cip=is_cip,
                               has_ral=has_ral,
                               has_interrupts=has_interrupts,
                               has_alerts=has_alerts,
                               num_edn=num_edn,
                               env_agents=env_agents,
                               vendor=vendor,
                               agent_vendor=agent_vendor))
            except Exception as e:
                log.error(e.text_error_template().render())
