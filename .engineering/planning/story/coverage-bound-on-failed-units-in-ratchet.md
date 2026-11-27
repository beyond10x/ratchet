---
format: aep.planning-md/3
id: story:coverage-bound-on-failed-units-in-ratchet
kind: story
status: draft
title: ratchet evaluate does not judge a run over its bound on failed units
summary: 'The command part of story:coverage-bound-on-failed-units: insufficient evidence that names the bound and the count.'
relations:
- decomposes: epic:preset-catalog
- depends_on: story:coverage-bound-on-failed-units
- depends_on: story:cli-skeleton-validate
- depends_on: story:evidence-reader
- depends_on: story:evaluate-command
scope:
- confidence: inferred
  path: crates/ratchet-core
- confidence: inferred
  path: crates/ratchet/src/commands/evaluate.rs
revision: 3
---
## Context

Split on 2026-11-26 from `story:coverage-bound-on-failed-units`, which declares the bound
`failed` of `ratchet.specification.CoverageBounds`, writes it into `docs/design.md` § 3
"Evidence coverage", and adds `operation-time@2`, which takes the bound as a required input.
This story holds the part that needs the `ratchet` command.

## Acceptance

`ratchet evaluate --gate <name>` in a fixture of `operation-time@2` with
`failed_requests_max: 0` does not judge the timing of a run that counts one failed request: the
verdict is insufficient evidence with the cause `coverage_below_plan`, and the row names the
bound `failed: {max: 0}` and the count 1; a run with no failed request is judged; before the
story a run with any number of failed requests qualifies.

## Notes

- Moved from the acceptance of `story:coverage-bound-on-failed-units`, with the cause the
  story decided.
- The story is a draft. It waits for the waves to 0.1.0: `story:cli-skeleton-validate`,
  `story:evidence-reader` and `story:evaluate-command`.
