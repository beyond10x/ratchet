---
format: aep.planning-md/3
id: story:coverage-count-lower-bound-in-ratchet
kind: story
status: draft
title: ratchet evaluate reads a coverage count that is not known or is a lower bound
summary: 'The command part of story:coverage-count-lower-bound: a coverage bound over such a count gives insufficient evidence naming the count.'
relations:
- decomposes: epic:format-gaps-first-format-consumer
- depends_on: story:coverage-count-lower-bound
- depends_on: story:cli-skeleton-validate
- depends_on: story:evidence-reader
- depends_on: story:evaluate-command
scope:
- confidence: inferred
  path: crates/ratchet
- confidence: inferred
  path: crates/ratchet-core
revision: 3
---
## Context

Split on 2026-11-26 from `story:coverage-count-lower-bound`, which makes the six coverage
counts of a `ratchet-evidence/1` record optional (absent: not known), adds `at_least` for a
count that is a lower bound, and writes into `docs/design.md` § 3 "Evidence coverage" what a
plan's coverage bound does with such a count. This story holds the part that needs the
`ratchet` command.

## Acceptance

`ratchet evaluate --gate <name>` in a fixture project whose plan declares
`coverage: {skipped: {max: 0}}` and whose record holds no `skipped` returns insufficient
evidence with the cause `coverage_below_plan` and a detail that names `skipped`; with
`coverage: {executed: {min: 400}}` and a record of `"executed": 472, "at_least":
["executed"]` the bound holds; with `{executed: {max: 500}}` over the same record the verdict
is insufficient evidence naming `executed`; a record that writes `"skipped": 0` passes the
first bound. Before the story no command reads a record.

## Notes

- Moved from the acceptance of `story:coverage-count-lower-bound`.
- The story is a draft. It waits for the waves to 0.1.0: `story:cli-skeleton-validate`,
  `story:evidence-reader` and `story:evaluate-command`.
