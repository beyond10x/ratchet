---
format: aep.planning-md/3
id: story:plan-with-exact-and-sampled-measurements-in-ratchet
kind: story
status: draft
title: ratchet validate judges one plan of exact and sampled measurements by the rule of the design
summary: 'The command part of story:plan-with-exact-and-sampled-measurements: the smallest example accepted or refused with a code.'
relations:
- decomposes: epic:format-gaps-first-format-consumer
- depends_on: story:plan-with-exact-and-sampled-measurements
- depends_on: story:cli-skeleton-validate
revision: 1
---
## Context

Split on 2026-11-26 from `story:plan-with-exact-and-sampled-measurements`, which writes into
`docs/design.md` § 3 and `spec/domains/specification.yaml` whether one plan may hold exact and
sampled measurements of one run, which observation kind it then declares and which of its
conditions qualify its exact measurements. This story holds the part that needs the `ratchet`
command.

The smallest example (finding 18 of the first format consumer): one browser run that yields
`horizontal-scroll = 0 pages` (exact) and `run-time = 48.0 s` (sampled), in one plan
`controlled_run` with `runs: 1`.

## Acceptance

`ratchet validate` accepts or refuses the smallest example by that rule with a code that names
it; before the story no command reads the rule.

## Notes

- Moved verbatim from the acceptance of `story:plan-with-exact-and-sampled-measurements`.
- The story is a draft. It waits for the waves to 0.1.0: `story:cli-skeleton-validate`.
