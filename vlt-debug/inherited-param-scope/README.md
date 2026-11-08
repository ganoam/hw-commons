# Verilator bug: inherited type param unusable as `::` scope under explicit base specialization

Fork: `Verilator 5.055 devel rev v5.054-65-g4dece87d7`
(`~/workspaceconfig/deps/verilator`, uvm-verilator port)

Found while fixing `dv_base_agent.sv:82` for the sim build — the intended
spelling `MONITOR_T::REQ_ITEM_T` inside `push_pull_agent` (a subclass whose
base is explicitly specialized) cannot be expressed.

## Trigger

In a *type* context (`P::typedef`, `P::member_type`), a type parameter
**inherited from an explicitly specialized base** (`extends B#(args)`)
fails to resolve as the scope of `::`:

```systemverilog
class mon;
  typedef int ITEM_T;
endclass
class base #(type MONITOR_T = mon);
  MONITOR_T m;
endclass
class bad extends base #(mon);
  typedef MONITOR_T::ITEM_T item_t;   // %Error: 'MONITOR_T' not found
  item_t x;
endclass
```

```
%Error: Package/class for 'class/package reference' not found: 'MONITOR_T'
```

Not a binding problem — positional vs named binding and concrete vs
parameter-reference bindings all fail identically (`named_bind.sv`,
`param_ref_bind.sv`). What matters is the `#(...)` specialization wrapper
in the extends clause.

## What does work (all verified)

| Variant | Example | Result |
|---|---|---|
| default-spec base | `extends base;` + `MONITOR_T::ITEM_T` | PASS (`ctrl_default.sv`) |
| same-class param | `class c #(type T=mon); typedef T::ITEM_T` | PASS (`ctrl_own_param.sv`) |
| own param shadows | derived `#(type MONITOR_T=mon)` | PASS (`shadow.sv`) |
| explicit spec scope | `base#(mon)::MONITOR_T::ITEM_T` | PASS (`ctrl_spec_scope.sv`) |
| generic scope | `base::MONITOR_T::ITEM_T` | PASS but see trap below |
| plain type / value use | `MONITOR_T m2; bit[W-1:0] v;` | PASS (`ctrl_plain.sv`) |
| method call | `MONITOR_T::f()` | PASS (`ctrl_method.sv`) |

So ordinary name lookup reaches inherited params under explicit
specialization fine; only the `X::type_member` package/class-scope lookup
path fails. Method calls (`X::f()`) take a different resolution path and
work.

## Trap: `B::P::member` resolves the DEFAULT binding

`base::MONITOR_T` looks up the param in the *generic* class — its default
binding — and ignores the specialization the derived class actually used:

```systemverilog
class e extends base #(empty);                    // MONITOR_T bound to empty
  typedef base::MONITOR_T::REQ_ITEM_T t;          // compiles! = mon::REQ_ITEM_T
```

(`trap_default_scope.sv` — compiles cleanly even though `empty` has no
`REQ_ITEM_T`.) Never use `B::P::member` as the workaround unless the
default binding is intended. The correct explicit spelling is
`B#(args)::P::member`.

## Workaround

Spell the scope through the specialized base or the concrete bound class:

```systemverilog
typedef base #(mon)::MONITOR_T::ITEM_T  item_t;   // via base spec
typedef mon::ITEM_T                     item_t;   // via concrete class
```

In the real code (`push_pull_agent extends dv_reactive_agent#(.MONITOR_T(
push_pull_monitor#(HostDataWidth,DeviceDataWidth)), ...)`), the desired
`MONITOR_T::REQ_ITEM_T` must be written
`push_pull_monitor#(HostDataWidth,DeviceDataWidth)::REQ_ITEM_T`.

## Upstream

Related — probably the same mechanism (inherited params under an
explicitly specialized base not resolving in derived scope):

- **verilator/verilator#6814** (open): inherited type params used as
  `#(...)` arguments in the derived class — `extends drv#(my_item)` +
  `port#(REQ,RSP)` member — fails with
  `Parameter type pin value isn't a type` + `PARSEREF` internal error.
  Reproduced on this fork (`param_arg.sv`).
- **#5833** (open): `BUSTYPE::type_id` through a type param — same
  LinkDot/V3Param tension around `::`-through-param resolution.
- **#7000** (open): `X::td_t` typedef access through a forwarded type
  param (interfaces).

Could not find an upstream report of this exact shape
(param-as-`::`-scope vs explicit spec); the repro index below is the
report draft.

## Repro index (`repros/`)

Run each: `verilator --lint-only --timing <file> --top-module tb`

| File | Result | Tests |
|---|---|---|
| `repro.sv` | **FAIL** | minimal: `extends base#(mon)` + `MONITOR_T::ITEM_T` |
| `named_bind.sv` | FAIL | named binding `#(.MONITOR_T(mon))` — same |
| `param_ref_bind.sv` | FAIL | bound to a param ref `#(M2)` — binding irrelevant |
| `two_level.sv` | FAIL | param declared 2 levels up (`mid#(mon)`), real shape |
| `param_arg.sv` | FAIL | #6814 shape: params as `#()` args — different error |
| `ctrl_default.sv` | clean | `extends base` (no spec) — same typedef works |
| `ctrl_spec_scope.sv` | clean | `base#(mon)::MONITOR_T::ITEM_T` — the workaround |
| `ctrl_plain.sv` | clean | `MONITOR_T m;`, `[W-1:0]` — ordinary use resolves |
| `ctrl_method.sv` | clean | `MONITOR_T::f()` — method path unaffected |
| `ctrl_own_param.sv` | clean | same-class `T::ITEM_T` — never affected |
| `shadow.sv` | clean | own `MONITOR_T` param shadows inherited |
| `trap_default_scope.sv` | clean* | `base::MONITOR_T` = DEFAULT binding, silently wrong |

## Using the rig

```shell
cd vlt-debug/inherited-param-scope/rig
verilator --lint-only +define+UVM -f min.vc --top-module min_tb
```

- `min.vc` — same real lint filelist as `../classrefdtype/rig` (uvm-verilator
  + opentitan dv libs + push_pull). Paths are `../../../…` —
  **the rig must stay 3 levels below the repo root**.
- `min_tb.sv` — `probe` (FAIL: `MONITOR_T::REQ_ITEM_T` in a
  `push_pull_agent#(32,32)` subclass, the exact error above) and
  `probe_ok` (clean: `push_pull_monitor#(32,32)::REQ_ITEM_T`). Edit to
  bisect; comment out `probe` to check `probe_ok` alone.
- Expected: exactly one error, `min_tb.sv:16`.
- csr_utils emits ~5 unrelated errors ("output automatic variable after
  timing control") plus ~1100 warnings — filter with `grep "not found"`.

## Relevance to stream_reg_sim

The `connect()` workaround for the classrefdtype bug wants the *exact*
type node a port was specialized with. For monitor ports the natural
spelling is `MONITOR_T::REQ_ITEM_T` / `MONITOR_T::RSP_ITEM_T`, which is
fine inside `dv_reactive_agent` (own param) but unreachable in
`push_pull_agent` (inherited param, spec'd base) — hence
`push_pull_agent.sv` spells it via `push_pull_monitor#(...)`.
