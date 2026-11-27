---
format: aep.planning-md/3
id: story:window-over-outside-population-in-ratchet
kind: story
status: draft
title: ratchet assess passes a window over an outside population and refuses a record outside it
summary: 'The command part of story:window-over-outside-population: the window and the population fields reach the assessor, and a record outside the window is refused.'
relations:
- decomposes: epic:ci-turnaround
- depends_on: story:window-over-outside-population
- depends_on: story:cli-skeleton-validate
- depends_on: story:assess-command
- depends_on: story:evidence-reader
scope:
- confidence: inferred
  path: crates/ratchet
- confidence: inferred
  path: crates/ratchet-core
revision: 3
---
## Context

Split on 2026-11-26 from `story:window-over-outside-population`, which writes into
`docs/evidence-format.md` § 10 how an assessor of a population outside the record store learns
its window (the window keys of `observation_inputs`) and its population fields, and covers a
time-window plan without a selection. This story holds the part that needs the `ratchet`
command.

## Acceptance

`ratchet assess` on a time-window plan with `population: {filter: {service: portal}}` and
`window: {length: 7d}` starts a stand-in assessor in a fixture with `--service portal` and the
inputs its declaration maps the window keys to, passes no `--revision`, and refuses a record
whose `target.window` starts before the window it passed or ends after it, with a cause that
names the plan; before the story no command starts an assessor.

## Notes

- Moved from the acceptance of `story:window-over-outside-population`.
- The story is a draft. It waits for the waves to 0.1.0: `story:cli-skeleton-validate`,
  `story:assess-command` and `story:evidence-reader`.
