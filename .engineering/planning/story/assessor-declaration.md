---
format: aep.planning-md/3
id: story:assessor-declaration
kind: story
status: active
title: Read ratchet-assessor/1 and validate a plan against it
summary: Declarations from a catalog directory, and the validation codes that join a plan with its assessor.
relations:
- decomposes: epic:observe-adopt-reject
- depends_on: story:cli-skeleton-validate
- depends_on: story:record-formats-in-spec
scope:
- confidence: cited
  path: crates/ratchet-core/src/assessor.rs
- confidence: cited
  path: crates/ratchet-core/src/validate.rs
- confidence: cited
  path: crates/ratchet-core/src/validate/assessor.rs
- confidence: cited
  path: crates/ratchet-core/tests/assessor.rs
- confidence: cited
  path: crates/ratchet-core/tests/fixtures/assessor
revision: 6
transitions:
- {from: "draft", to: "proposed", at: "2026-11-24T13:10:22Z", actor: "agent:ratchet", revision: 5, decided_on: {"recorded":{"review_outcome":1}}}
- {from: "proposed", to: "active", at: "2026-11-24T13:10:22Z", actor: "agent:ratchet", revision: 6, decided_on: {"recorded":{"review_outcome":1}}}
---
## Context

An assessor declares its inputs, coverage unit and outputs in a `ratchet-assessor/1` document
(`docs/evidence-format.md` § 10, E8). `ratchet validate` checks a plan against it: the target
kind, the names and types of the inputs, and for each measurement the output, the scope, the
unit, the boundary and the fields of a `filter` (design § 4). After `story:cli-skeleton-validate`
the command checks a document on its own and no declaration.

Where a declaration is found is declared by `story:record-formats-in-spec`: a catalog source
without `git` is a directory relative to the root, and a declaration is the file
`<name>@<version>.assessor.yaml` in a source. The `git` form is not built in this story.

## Acceptance

`ratchet validate` exits 0 on a fixture project whose plan matches its assessor's declaration,
and for each of the codes `unresolved_reference` (no declaration for the assessor),
`kind_mismatch`, `unit_mismatch`, `unit_missing`, `unit_not_declared`, `scope_mismatch`,
`target_binding_mismatch` and `assessor_configuration_invalid` a fixture project that differs
from the first in one member exits 1 with a finding of that code at that member's key path.

## Scope

- `crates/ratchet-core/src/assessor.rs`: read a declaration, resolve `<name>@<version>` in the
  catalog sources
- `crates/ratchet-core/src/validate/assessor.rs`: the plan against the declaration
- `crates/ratchet-core/src/validate.rs`: one call to the check above
- `crates/ratchet-core/tests/assessor.rs`, fixtures under
  `crates/ratchet-core/tests/fixtures/assessor/`

## Notes

- No specification file and no generated file changes here. `crates/ratchet-core/tests/main.rs`,
  `Cargo.toml` and `Cargo.lock` are not edited: the skeleton declared the test module.
- No other story of this wave edits `crates/ratchet-core/src/validate.rs`.
- Red first: each fixture fails before the check exists.
- Budget: no test over 60 s, the step within 120 s.
- No `CHANGELOG.md` line here: `story:acceptance-in-gate` writes the lines of the slice.
