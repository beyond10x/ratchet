---
format: aep.planning-md/3
id: story:reference-compare
kind: story
status: active
title: Reference records and typed comparison
summary: ratchet-reference/1 read and write, conditions and accepted values with tolerance, verdict and cause per scope item.
relations:
- decomposes: epic:observe-adopt-reject
- depends_on: story:cli-skeleton-validate
- depends_on: story:record-formats-in-spec
scope:
- confidence: cited
  path: crates/ratchet-core/src/compare.rs
- confidence: cited
  path: crates/ratchet-core/src/reference.rs
- confidence: cited
  path: crates/ratchet-core/tests/compare.rs
- confidence: cited
  path: crates/ratchet-core/tests/reference.rs
revision: 5
transitions:
- {from: "draft", to: "proposed", at: "2026-11-24T13:10:22Z", actor: "agent:ratchet", revision: 4, decided_on: {"recorded":{"review_outcome":1}}}
- {from: "proposed", to: "active", at: "2026-11-24T13:10:22Z", actor: "agent:ratchet", revision: 5, decided_on: {"recorded":{"review_outcome":1}}}
---
## Context

A requirement holds through a `condition` (an absolute limit), a `reference` (an accepted value
with a tolerance), or both (design § 3 "Comparisons", § 5 "Protected references"). A reference
record is one JSON file per requirement, `ratchet/references/<requirement>.json`, format
`ratchet-reference/1`, with `values` per scope item or `items` of a set (design § 5 "Reference
records"; D1 decided A). The first consumer's comparator does the same by hand: per scenario and
key a value and a tolerance, lower is better.

## Acceptance

The test run of `ratchet-core` lists as passed the table-driven test `compare::verdicts`, whose
rows cover for `number` each operator `lt`, `lte`, `gt`, `gte`, `eq` and an accepted value with
`better: lower` and `better: higher` under an absolute and a percent tolerance, for
`identity_set` the operators `no_new_items` and `no_lost_items`, a missing reference item
(`reference_missing`), a missing evidence item (`coverage_below_plan`), an incomplete result
(insufficient evidence with the `incomplete.cause` the result carries) and an incomplete result
whose `at_least` is above an upper limit (fail, `limit_crossed`), each row with its verdict, its
cause (`limit_crossed`, `regression`, `new_items`, `lost_items` for a fail) and the observed and
allowed value as decimal text, and the test `reference::round_trip` (a `ratchet-reference/1`
record written and read back is byte-identical).

## Scope

- `crates/ratchet-core/src/reference.rs`: read and write `ratchet-reference/1`
- `crates/ratchet-core/src/compare.rs`: one result against a condition and a reference; pure
  functions, no file access
- `crates/ratchet-core/tests/compare.rs`, `crates/ratchet-core/tests/reference.rs`

## Notes

- `crates/ratchet-core/tests/main.rs`, `Cargo.toml` and `Cargo.lock` are not edited: the
  skeleton declared the test modules and the decimal type.
- Decimal arithmetic on text with the decimal type; no float. A percent tolerance is computed on
  the reference value and compared exactly.
- The readings `reference_missing` and `coverage_below_plan` per scope item are in design § 5
  since `story:record-formats-in-spec`.
- An incomplete result with `at_least` above an upper limit is a fail (`docs/evidence-format.md`
  § 5, U6, E6).
- Not here: a better value that is not adopted (`stale_reference_not_adopted`), sampled
  measurements, generated references. They are in `epic:improvement-and-policy` and
  `epic:generated-artifact`.
- Red first. Budget: no test over 60 s, the step within 120 s.
- No `CHANGELOG.md` line here: `story:acceptance-in-gate` writes the lines of the slice.
