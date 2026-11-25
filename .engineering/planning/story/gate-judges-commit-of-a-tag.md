---
format: aep.planning-md/3
id: story:gate-judges-commit-of-a-tag
kind: story
status: draft
title: A gate states that it judges the commit of a tag
summary: A candidate gate names the revision it judges when that is not the candidate of a change, first the commit a tag points at.
relations:
- decomposes: epic:format-gaps-first-format-consumer
scope:
- confidence: inferred
  path: CHANGELOG.md
- confidence: inferred
  path: crates/ratchet-core
- confidence: inferred
  path: docs/design.md
- confidence: inferred
  path: spec/domains/specification.yaml
revision: 5
---
## Context

The repository `beyond10x/inference` wrote the second unit of its quality definition against
the formats at commit `f139ecc` (2026-11-25): measures per adapter, and latency defined
without a number. It is the first consumer of the formats outside this repository and of this
story. An adversary pass of the consumer read the finding against the specification at that
commit. Line numbers below are those of `f139ecc`.

Finding 20. A gate cannot say that it judges the commit a tag points at. The stage of a gate
is a free label (`ratchet.specification.Stage`, `spec/domains/specification.yaml:622-628`), so
a gate `release` can be written and can require what the gates of a merge require. A gate has
no field for what it judges (`ratchet.specification.Gate`, `:953-992`): the candidate is given
when the gate is evaluated, and the selection of a target is the candidate or its merge result
(`ratchet.specification.Selection`, `:227-229`). Nothing in the file binds the gate to a tag,
so the file holds a release to nothing a reader can see. The consumer left the gate out.

## Acceptance

A candidate gate of a `ratchet/1` file states which revision it judges when it is not the
candidate of a change, with the commit of a tag as the first form, `ratchet validate` accepts
the file, and `ratchet evaluate --gate <name>` refuses a candidate that is not such a revision
with a cause that names the gate; before the story the key is refused, and a gate named
`release` passes for any revision.

## Notes

- The consumer invented no field for the finding and says what it left out on a page of its
  quality unit. The story decides the form, declares it in `spec/` first (`ess specify
  validate` passes), and writes it into `docs/design.md` or `docs/evidence-format.md` in the
  same change.
- A new value or field of a released format is an addition: a file written for the format
  before the change stays valid.
- The story is a draft. It was there before the planned waves to 0.1.0 and waits for them.
