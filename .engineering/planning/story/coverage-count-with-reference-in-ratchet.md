---
format: aep.planning-md/3
id: story:coverage-count-with-reference-in-ratchet
kind: story
status: draft
title: ratchet validate and ratchet evaluate read a coverage count as a measurement
summary: 'The command part of story:coverage-count-with-reference: the check against the declaration and the verdict against an accepted count.'
relations:
- decomposes: epic:format-gaps-first-format-consumer
- depends_on: story:coverage-count-with-reference
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

Split on 2026-11-26 from `story:coverage-count-with-reference`, which reserves the output name
`coverage.<count>` in `spec/domains/specification.yaml` and `docs/design.md` § 3, and makes
`spec/presets.test.sh` and `spec/example-declarations.test.sh` hold a measurement on it to the
declaration of its assessor. This story holds the part that needs the `ratchet` command.

## Acceptance

`ratchet validate` accepts a measurement with `output: coverage.executed` whose assessor lists
`executed` under `coverage`, and refuses one on a count the assessor does not list, or with a
`unit`, or not `exact`, with a code that names the rule; and `ratchet evaluate --gate <name>`
in a fixture whose run has a lower `executed` count than the accepted value gives the verdict
fail with the cause `regression`; before the story `ratchet validate` refuses the measurement
because no output of the assessor has that name.

## Notes

- Moved from the acceptance of `story:coverage-count-with-reference`.
- A count that the record states as a lower bound or as not known
  (`story:coverage-count-lower-bound`) gives insufficient evidence with the cause
  `coverage_below_plan`; `story:coverage-count-with-reference` writes that into
  `docs/design.md` § 3, and this story makes `ratchet evaluate` give it.
- The story is a draft. It waits for the waves to 0.1.0: `story:cli-skeleton-validate`,
  `story:assessor-declaration` and `story:evaluate-command`.
