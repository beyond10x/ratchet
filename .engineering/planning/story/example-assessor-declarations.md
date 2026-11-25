---
format: aep.planning-md/3
id: story:example-assessor-declarations
kind: story
status: draft
title: Each assessor the examples name has a declaration
summary: ratchet-assessor/1 files for the example assessors and a test that compares the examples with them.
relations:
- decomposes: epic:format-gaps-first-format-consumer
revision: 1
---
## Context

The repository `beyond10x/inference` wrote its quality definition against the formats at
commit `f139ecc` (2026-11-25): 3 `ratchet/1` files, 8 `ratchet-assessor/1` declarations and 15
`ratchet-evidence/1` records. It is the first consumer of the formats outside this repository
and of this story. Line numbers below are those of `f139ecc`.

Finding 13. `examples/README.md:496` says every assessor id of the examples but four is a
placeholder, and the only `ratchet-assessor/1` declaration in the repository is the
illustration in `docs/evidence-format.md:691-718`. A reader cannot check the outputs, units and
scopes an example uses against anything, and a consumer has no declaration to copy.

## Acceptance

Each assessor an example names has a `ratchet-assessor/1` declaration file in the repository,
and a script test fails when a measurement of an example names an output, a unit or a scope
its assessor does not declare; before the story the test fails for every example.

## Notes

- The form shown is the consumer's proposal. The story decides the form, declares it in
  `spec/` first (`ess specify validate` passes), and writes it into `docs/design.md` or
  `docs/evidence-format.md` in the same change.
- A new value or field of a released format is an addition: a file written for the format
  before the change stays valid.
- The story is a draft. It was there before the planned waves to 0.1.0 and waits for them.
