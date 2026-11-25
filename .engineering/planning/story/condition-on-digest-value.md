---
format: aep.planning-md/3
id: story:condition-on-digest-value
kind: story
status: draft
title: A requirement compares a digest with a value the specification states
summary: A condition with eq on a digest measurement and a pinned sha256 value.
relations:
- decomposes: epic:format-gaps-first-format-consumer
revision: 1
---
## Context

The repository `beyond10x/inference` wrote its quality definition against the formats at
commit `f139ecc` (2026-11-25): 3 `ratchet/1` files, 8 `ratchet-assessor/1` declarations and 15
`ratchet-evidence/1` records. It is the first consumer of the formats outside this repository
and of this story. Line numbers below are those of `f139ecc`.

Finding 1. The definition needs "the SHA-256 of a downloaded archive equals a pinned value".
`ratchet.specification.Condition` holds `value` as a Decimal
(`spec/domains/specification.yaml:489-494`, `:933`; `docs/design.md:36`), so
`condition: {operator: eq, value: "sha256:..."}` has no form. A digest can be compared with a
reference (`reference: {kind: generated}` or an accepted value) and not with a value the
specification states. The consumer wrote an assertion in its place, which loses the two
digests in the verdict.

## Acceptance

A requirement on a measurement whose value type is a digest states the expected digest in the
specification, `ratchet validate` accepts it and refuses the same condition on a number
measurement, and a verdict on it names both digests; before the story the document is refused
because `value` is not a decimal.

## Notes

- The form shown is the consumer's proposal. The story decides the form, declares it in
  `spec/` first (`ess specify validate` passes), and writes it into `docs/design.md` or
  `docs/evidence-format.md` in the same change.
- A new value or field of a released format is an addition: a file written for the format
  before the change stays valid.
- The story is a draft. It was there before the planned waves to 0.1.0 and waits for them.
