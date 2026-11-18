# Verilator bug: `randomize()` on a subclass can't scope inherited `rand` object members

Fork: `Verilator 5.055 devel rev v5.054-65-g4dece87d7`
(`~/workspaceconfig/deps/verilator`, uvm-verilator port)

Found while refactoring `stream_reg`'s DV env into a reusable
parameterized `stream_env` library — `stream_reg_env_cfg` became a
concrete subclass of `stream_env_cfg#(HostDataWidth, DeviceDataWidth)`,
and `dv_base_test.sv`'s `cfg.randomize()` then crashed the compiler:

```
%Error: Internal Error: .../dv_base_test.sv:76:15:
    ../V3Scope.cpp:120: Can't locate varref scope
           : ... note: In instance 'stream_reg_env_pkg::stream_reg_env_cfg'
   76 |       `DV_CHECK_RANDOMIZE_FATAL(cfg)
      |               ^ (expands to cfg.randomize())
```

## Trigger

Calling `.randomize()` on a handle typed as a **subclass** fails when the
inherited base has a **`rand` class-handle member whose class has a
constraint block**:

```systemverilog
class leaf;
  rand int v;
  constraint c { v inside {[0:10]}; }   // member class has constraints
endclass
class base;
  rand leaf f;                          // `rand` OBJECT member in the base
endclass
class sub extends base;
endclass
// ...
sub c = new;
void'(c.randomize());                   // V3Scope.cpp:120 internal error
```

All three ingredients are required:

| Ingredient | Removing it |
|---|---|
| subclass handle (`sub` vs `base`) | `base c` randomizes fine (`ctrl_no_subclass`) |
| `rand` on the object member | non-`rand leaf f` fine (`ctrl_member_not_rand`) |
| constraint inside the member class | `leaf` without `constraint` fine (`ctrl_leaf_no_constr`) |

Class parameterization is **not** required — a plain `extends base`
crashes identically (`min_fail.sv` has no parameters at all). In the
production code it only *looked* parameter-related because the subclass
happened to specialize a parameterized base (`param_base_fail.sv`).

No `--timing` needed — plain `verilator --lint-only` crashes.

## What's probably happening

`obj.randomize()` is lowered to a per-class `__Vrandomize`/`__Vrand`
skeleton that walks the class's `rand` members. For an *object* member,
the walk descends into the member's class to inline its constraint
solve. The member's varref scope is looked up in the specialization
scope of the *declaring* class (`base`) — but the specialization being
elaborated is the **subclass** (`sub`), which inherited `f` without
re-declaring it, so the varref's scope can't be located. Direct call
`c.f.randomize()` works (`ctrl_member_randomize`) because then `leaf`
itself is the specialization under elaboration.

Same family as `../inherited-param-scope` (scope bookkeeping across an
inheritance boundary), different path: this one is dotted-call/randomize
lowering in `V3Randomize`/`V3Scope`, not `::`-scope resolution in
`V3LinkDot`.

## Why it matters for OpenTitan-style DV

`dv_base_test::build_phase` calls `cfg.randomize()` on `CFG_T cfg` —
`CFG_T` is bound to a *concrete* cfg class (`stream_reg_env_cfg`). The
moment a reusable cfg base class gains a `rand <agent_cfg_class>` member
(e.g. `rand push_pull_agent_cfg m_in_agent_cfg` — the standard OT cfg
shape), any concrete subclass breaks `randomize()`. That is exactly the
pattern a shared env library forces, so the refactor can't proceed with
subclasses until this is fixed.

## Workaround

Give the IP-level cfg name as a `typedef` alias of the base
specialization, not a `class ... extends`:

```systemverilog
// typedef stream_env_cfg #(.HostDataWidth(D), .DeviceDataWidth(D))
//     stream_reg_env_cfg;                    // works (ctrl_typedef_alias)
class stream_reg_env_cfg extends stream_env_cfg #(...);  // crashes
```

Loses: a distinct factory-registered type for the IP (no per-IP
`uvm_object_utils`, no `set_type_override` target of that name). For
`stream_reg` that's acceptable — cfg customization can still come from a
base-class-member constraint or a factory override on `push_pull_item`.

Alternative workaround: constrain/rand_mode the member explicitly and
avoid `.randomize()` on the subclass handle — fragile, not recommended.

## Upstream

Not yet filed. Worth checking against the `V3Randomize` object-member
descent before submitting; `docs/internals.rst` pass order puts the
scope clone in `V3Scope` after `V3Param`.

## Repro index (`repros/`)

Run each: `verilator --lint-only --timing <file> --top-module tb`

| File | Result | Tests |
|---|---|---|
| `min_fail.sv` | **FAIL** | minimal: sub + inherited `rand leaf f` + constraint in `leaf` |
| `param_base_fail.sv` | FAIL | production shape: `extends base#(W)` (param irrelevant to bug) |
| `ctrl_no_subclass.sv` | clean | `base` handle — specialization IS the declaring class |
| `ctrl_member_not_rand.sv` | clean | object member without `rand` — not descended into |
| `ctrl_leaf_no_constr.sv` | clean | member class without constraints — nothing to inline |
| `ctrl_member_randomize.sv` | clean | `c.f.randomize()` — member class is the specialization |
| `ctrl_typedef_alias.sv` | clean | the production workaround |
