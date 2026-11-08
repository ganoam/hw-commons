ganoam:dv:stream_reg_sim:0.1
├── ganoam:dv:stream_reg_sva:0.1
├── ganoam:dv:stream_reg_test:0.1
│   └── ganoam:dv:stream_reg_env:0.1
│       ├── lowrisc:dv:dv_lib
│       │   ├── lowrisc:dv:common_ifs → lowrisc:dv:pins_if → lowrisc:prim:assert
│       │   ├── lowrisc:dv:csr_utils → lowrisc:dv:dv_base_reg → [dv_utils, prim:mubi_pkg]
│       │   ├── lowrisc:dv:dv_base_agent → dv_utils
│       │   └── lowrisc:dv:dv_base_reg → [dv_utils, prim:mubi_pkg]
│       ├── lowrisc:dv:push_pull_agent ×2 → dv_lib (same subtree)
│       └── (shared subtree via everything below)
│           └── lowrisc:dv:dv_utils
│               ├── lowrisc:dv:common_ifs, dv_fcov_macros, dv_macros
│               ├── lowrisc:dv:dv_test_status → prim:util → prim:assert
│               ├── lowrisc:dv:str_utils → dv_macros
│               └── lowrisc:opentitan:bus_params_pkg
│                   └── lowrisc:virtual_constants:top_pkg
├── ganoam:dv:uvm_pkg
└── ganoam:ip:stream_reg:0 → prim:assert
