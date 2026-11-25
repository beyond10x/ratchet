---
format: aep.planning-md/3
id: story:gate-entry-unless-only-paths
kind: story
status: draft
title: A gate entry is skipped when every changed path is in a list
summary: 'The negative form of when: {changed} on a gate entry.'
relations:
- decomposes: epic:format-gaps-first-format-consumer
revision: 1
---
## Context

The repository `beyond10x/inference` wrote its quality definition against the formats at
commit `f139ecc` (2026-11-25): 3 `ratchet/1` files, 8 `ratchet-assessor/1` declarations and 15
`ratchet-evidence/1` records. It is the first consumer of the formats outside this repository
and of this story. Line numbers below are those of `f139ecc`.

Finding 3. The definition needs "this gate entry does not apply when every changed path is
planning or prose". `ratchet.specification.ChangedPaths` is positive only
(`spec/domains/specification.yaml:652-663`): `when: {changed: [paths]}` applies when the change
touches a listed path. A list of every path that is no planning file cannot be written as
patterns without negation. The consumer's example:
`when: {not_only: [".engineering/**", "**/*.md"]}`.

## Acceptance

A gate entry with the new form applies to a change that touches one path outside the list and
does not apply to a change whose paths are all in the list, and the gate report names the entry
as not applicable with the reason; before the story `ratchet validate` refuses the key.

## Notes

- The form shown is the consumer's proposal. The story decides the form, declares it in
  `spec/` first (`ess specify validate` passes), and writes it into `docs/design.md` or
  `docs/evidence-format.md` in the same change.
- A new value or field of a released format is an addition: a file written for the format
  before the change stays valid.
- The story is a draft. It was there before the planned waves to 0.1.0 and waits for them.
