---
format: aep.planning-md/3
id: story:requirement-over-two-measurements-in-ratchet
kind: story
status: draft
title: ratchet validate and ratchet evaluate judge a requirement over two measurements
summary: 'The command part of story:requirement-over-two-measurements: the refusal across value types or units, and the verdict over two runs.'
relations:
- decomposes: epic:preset-catalog
- depends_on: story:requirement-over-two-measurements
- depends_on: story:cli-skeleton-validate
- depends_on: story:assessor-declaration
- depends_on: story:evaluate-command
scope:
- confidence: inferred
  path: crates/ratchet-core
- confidence: inferred
  path: crates/ratchet/src/commands/evaluate.rs
- confidence: inferred
  path: crates/ratchet/src/commands/validate.rs
revision: 5
---
## Context

Split on 2026-11-26 from `story:requirement-over-two-measurements`, which declares the member
`against` and the operator `subset_of` of `ratchet.specification.Condition`, names the
validation codes `against_value_type_mismatch` and `against_unit_mismatch`, writes the form
into `docs/design.md` § 3 "Comparisons" and the cause of a `subset_of` that does not hold
(`new_items`) into § 5 "Verdicts", adds `known-failures@2` and `conformance-report@2` to the
catalog, and makes `spec/presets.test.sh` hold a preset to the form. This story holds the part
that needs the `ratchet` command.

## Acceptance

1. `ratchet validate` accepts a requirement whose condition compares its measurement with
   another measurement of the same specification through `against`, and refuses a comparison
   across two value types with the code `against_value_type_mismatch` and one across two units
   with `against_unit_mismatch`; before the story no command reads the form.
2. `ratchet evaluate --gate <name>` in a fixture of `known-failures@2` gives the verdict fail
   with the cause `new_items` when a failed case is not on the list, and names that case.
3. The gate decision of that run lists the runs of both plans under `evidence`.

## Notes

- Moved from the acceptance of `story:requirement-over-two-measurements`. The codes and the
  cause are decided and written by that story (`docs/design.md` § 3 and § 5); this story
  writes no design text.
- The story is a draft. It waits for the waves to 0.1.0: `story:cli-skeleton-validate`,
  `story:assessor-declaration` (the two declarations) and `story:evaluate-command`.
