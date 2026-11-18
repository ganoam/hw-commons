# Extracting a reusable DV library from a concrete testbench

Workflow for generalizing a working per-IP verification environment
into parameterized infrastructure usable by other blocks.

## When to extract

- The concrete environment works end to end first. Do not generalize
  a broken testbench.
- At least one second consumer exists or is clearly coming; otherwise
  the abstraction is speculation.

## Procedure

1. Read every source file of the concrete environment and mark what
   is protocol-generic versus IP-specific (names, register maps,
   transaction fields, sequences).
2. Lift the generic part into a library directory parameterized by
   what actually varies (data width, transaction type). Prefer type
   parameters over string or macro configuration.
3. Reduce the original environment to thin subclasses that bind the
   parameters and keep the original names, so existing tests and
   factory registrations still resolve.
4. Update build manifests (`.core`, filelists) so the library is a
   dependency of the per-IP environment, not a copy.
5. Verify the original test still builds and runs before extending
   to the second consumer.

## Conventions

- One parameter set per real variation axis. Resist speculative
  parameters.
- A typedef alias is acceptable for thin bindings when tool bugs
  make real subclasses expensive; document that choice in the
  workaround index.
- The library gets its own README or package docs: what it
  parameterizes, how a new IP binds it, what it deliberately does
  not cover.
