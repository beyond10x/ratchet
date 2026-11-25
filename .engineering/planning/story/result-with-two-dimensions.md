---
format: aep.planning-md/3
id: story:result-with-two-dimensions
kind: story
status: draft
title: A number result carries its condition cell beside its scope item
summary: A result per scenario and viewport without joining the two into one item name.
relations:
- decomposes: epic:format-gaps-first-format-consumer
revision: 1
---
## Context

The repository `beyond10x/inference` wrote its quality definition against the formats at
commit `f139ecc` (2026-11-25): 3 `ratchet/1` files, 8 `ratchet-assessor/1` declarations and 15
`ratchet-evidence/1` records. It is the first consumer of the formats outside this repository
and of this story. Line numbers below are those of `f139ecc`.

Finding 6. A result belongs to a scenario and to a viewport. A result has one `scope` and one
`item` (`spec/domains/evidence.yaml:337-341`), and `docs/evidence-format.md:599` names "a
result per condition cell" as not covered. The consumer wrote one scope `view` with the item
`<scenario>/<viewport>`: valid, and neither part can be grouped or selected on its own.

## Acceptance

A number result carries the condition cell it was observed in beside its scope item, a
requirement selects or aggregates by one of the two, and two results of one item in two cells
are two entries of the series; before the story the second member is refused as unknown.

## Notes

- The form shown is the consumer's proposal. The story decides the form, declares it in
  `spec/` first (`ess specify validate` passes), and writes it into `docs/design.md` or
  `docs/evidence-format.md` in the same change.
- A new value or field of a released format is an addition: a file written for the format
  before the change stays valid.
- The story is a draft. It was there before the planned waves to 0.1.0 and waits for them.
