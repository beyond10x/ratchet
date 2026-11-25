---
format: aep.planning-md/3
id: story:coverage-count-with-reference
kind: story
status: draft
title: A coverage count is a measurement a reference can protect
summary: executed, skipped, not_run and unsupported as measurements with a direction and an accepted value.
relations:
- decomposes: epic:format-gaps-first-format-consumer
revision: 1
---
## Context

The repository `beyond10x/inference` wrote its quality definition against the formats at
commit `f139ecc` (2026-11-25): 3 `ratchet/1` files, 8 `ratchet-assessor/1` declarations and 15
`ratchet-evidence/1` records. It is the first consumer of the formats outside this repository
and of this story. Line numbers below are those of `f139ecc`.

Finding 2. The definition needs "the number of executed units does not fall".
`ratchet.specification.CoverageBounds` holds fixed bounds only
(`spec/domains/specification.yaml:297-314`): no `better`, no accepted value. The design says
coverage counts can be measurements (`docs/design.md` § 4, row "Test evidence"), and no shape
reads a count of the coverage as a measurement. The consumer's example:
a requirement with `coverage: executed` and `reference: {kind: accepted_value}`.

## Acceptance

A plan declares a measurement that reads one coverage count of its run, a requirement compares
it with an accepted value, and a run with a lower `executed` count than the reference gets the
verdict fail; before the story `ratchet validate` refuses the measurement because no output of
the assessor has that name.

## Notes

- The form shown is the consumer's proposal. The story decides the form, declares it in
  `spec/` first (`ess specify validate` passes), and writes it into `docs/design.md` or
  `docs/evidence-format.md` in the same change.
- A new value or field of a released format is an addition: a file written for the format
  before the change stays valid.
- The story is a draft. It was there before the planned waves to 0.1.0 and waits for them.
