---
format: aep.planning-md/3
id: story:reference-compare
kind: story
status: draft
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
revision: 2
---
## Context

A requirement holds through a `condition` (an absolute limit), a `reference` (an accepted value
with a tolerance), or both (design § 3 "Comparisons", § 5 "Protected references"). A reference
record is one JSON file per requirement, `ratchet/references/<requirement>.json`, format
`ratchet-reference/1`, with `values` per scope item or `items` of a set (design § 5 "Reference
records"; D1 decided A). The first consumer's comparator does the same by hand: per scenario and
key a value and a tolerance, lower is better.

## Acceptance

A table-driven test covers, for the value type `number`, each operator `lt`, `lte`, `gt`, `gte`
and `eq` and an accepted value with `better: lower` and `better: higher` under an absolute and a
percent tolerance, and for `identity_set` the operators `no_new_items` and `no_lost_items`, and
each row yields the verdict and cause design § 5 "Verdicts" names (`limit_crossed`, `regression`,
`new_items`, `lost_items`, `reference_missing`, and the cause of an incomplete result), with the
observed and the allowed value as decimal text; a reference record written and read back is
byte-identical.

## Scope

- `crates/ratchet-core/src/reference.rs`: read and write `ratchet-reference/1`
- `crates/ratchet-core/src/compare.rs`: one result against a condition and a reference; pure
  functions, no file access
- `crates/ratchet-core/tests/`: module `compare`, module `reference`

## Notes

- Decimal arithmetic on text with a decimal type; no float. A percent tolerance is computed on
  the reference value and compared exactly.
- A scope item in the evidence that the reference does not hold is `reference_missing` for that
  item; a scope item the reference holds and the evidence does not is `coverage_below_plan`.
  Both are insufficient evidence. The story reports the two readings as decisions taken, and
  `story:evaluate-command` writes them into `docs/design.md` § 5.
- An incomplete result with `at_least` above an upper limit is a fail (`docs/evidence-format.md`
  § 5, U6, E6).
- Not here: a better value that is not adopted (`stale_reference_not_adopted`), sampled
  measurements, generated references. They are in `epic:improvement-and-policy` and
  `epic:generated-artifact`.
- Red first. Budget: no test over 60 s, the step within 120 s.
