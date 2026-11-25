---
format: aep.planning-md/3
id: story:list-item-statement
kind: story
status: draft
title: An item of a list carries a statement of what it stands for
summary: A plan states per item of a passed list or of a scope what the item bounds or asserts.
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
  path: docs/evidence-format.md
- confidence: inferred
  path: spec/domains/specification.yaml
revision: 6
---
## Context

The repository `beyond10x/inference` wrote the second unit of its quality definition against
the formats at commit `f139ecc` (2026-11-25): measures per adapter, and latency defined
without a number. It is the first consumer of the formats outside this repository and of this
story. An adversary pass of the consumer read the finding against the specification at that
commit. Line numbers below are those of `f139ecc`.

Finding 23. A list input cannot give one item a meaning of its own. An assessment of time
bounds lists its tests as a declared input, and its record has one result per test. The list
cannot say which constant a test bounds, or whether a test asserts the default value or only
the mechanism. A declared input has a type, a default and no text per value
(`ratchet.specification.InputDeclaration`, `spec/domains/specification.yaml:692-727`), and a
requirement names the whole measurement and no single item of it
(`ratchet.specification.QualityRequirement`, `:901-936`).

## Acceptance

A plan states, for an item of a list it passes or for an item of a measurement's scope, what
that item stands for, `ratchet validate` accepts the file and refuses a statement about an
item the list does not hold, and a verdict or a view shows the statement beside the result of
the item; before the story the file has no place for it and the key is refused.

## Notes

- The consumer invented no field for the finding and says what it left out on a page of its
  quality unit. The story decides the form, declares it in `spec/` first (`ess specify
  validate` passes), and writes it into `docs/design.md` or `docs/evidence-format.md` in the
  same change.
- A new value or field of a released format is an addition: a file written for the format
  before the change stays valid.
- The story is a draft. It was there before the planned waves to 0.1.0 and waits for them.
