---
format: aep.planning-md/3
id: story:plan-with-exact-and-sampled-measurements
kind: story
status: draft
title: One plan holds exact and sampled measurements of one run
summary: Whether a controlled run may carry exact values beside durations, and what its conditions qualify.
relations:
- decomposes: epic:format-gaps-first-format-consumer
revision: 1
---
## Context

The repository `beyond10x/inference` wrote its quality definition against the formats at
commit `f139ecc` (2026-11-25). It is the first consumer of the formats outside this repository
and of this story. The finding comes from the correction round of that definition.

Finding 18. One command in one run reports twelve exact values (counts per scenario and
viewport, compared with a committed baseline) and two durations (seconds per test, seconds
per run). A plan has one observation kind
(`spec/domains/specification.yaml`, `ObservationPlan`). `controlled_run` with `runs: 1` is true
for the two durations and says nothing about the twelve counts; `snapshot` is true for the
counts and has no place for conditions of a timing. The consumer wrote one plan,
`controlled_run`, `runs: 1`, with measurements of the kinds `exact` and `sampled` side by side.
The smallest example: one browser run that yields `horizontal-scroll = 0 pages` (exact) and
`run-time = 48.0 s` (sampled). The design does not say whether that plan is valid, nor which
conditions apply to its exact measurements.

## Acceptance

The specification says whether one plan may hold exact and sampled measurements, and for the
answer yes which observation kind it declares and that its conditions qualify the sampled
measurements only; `ratchet validate` accepts or refuses the smallest example by that rule
with a code that names it; before the story the document says neither.

## Notes

- The form shown is the consumer's proposal or what it wrote in place of the missing form.
  The story decides the form, declares it in `spec/` first (`ess specify validate` passes), and
  writes it into `docs/design.md` or `docs/evidence-format.md` in the same change.
- A new value or field of a released format is an addition: a file written for the format
  before the change stays valid.
- The story is a draft. It was there before the planned waves to 0.1.0 and waits for them.
