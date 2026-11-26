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
revision: 4
---
## Context

Split on 2026-11-26 from `story:requirement-over-two-measurements`, which declares the member
`against` and the operator `subset_of` of `ratchet.specification.Condition`, writes them into
`docs/design.md` § 3 "Comparisons", adds `known-failures@2` and `conformance-report@2` to the
catalog, and makes `spec/presets.test.sh` hold a preset to the form. This story holds the part
that needs the `ratchet` command.

## Acceptance

`ratchet validate` accepts a requirement whose condition compares its measurement with another
measurement of the same specification through `against`, and refuses a comparison across two
value types or two units, each with a code that names the rule; and `ratchet evaluate --gate
<name>` in a fixture of `known-failures@2` gives the verdict fail with the cause `new_items`
when a failed case is not on the list, names that case, and lists the runs of both plans in
the decision; before the story no command reads the form.

## Notes

- Moved from the acceptance of `story:requirement-over-two-measurements`, but for the code and
  the cause, which this story decides and writes into `docs/design.md` § 5 "Verdicts".
- The story is a draft. It waits for the waves to 0.1.0: `story:cli-skeleton-validate`,
  `story:assessor-declaration` (the two declarations) and `story:evaluate-command`.
