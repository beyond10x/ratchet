---
format: aep.planning-md/3
id: story:specification-answers-first-format-consumer
kind: story
status: draft
title: The specification answers seven places the first format consumer could not read
summary: 'observation.command, holds per item, scopes: [], a value aggregated in one run, units, comments, the evidence digest.'
relations:
- decomposes: epic:format-gaps-first-format-consumer
revision: 1
---
## Context

The repository `beyond10x/inference` wrote its quality definition against the formats at
commit `f139ecc` (2026-11-25): 3 `ratchet/1` files, 8 `ratchet-assessor/1` declarations and 15
`ratchet-evidence/1` records. It is the first consumer of the formats outside this repository
and of this story. Line numbers below are those of `f139ecc`.

Findings 8 to 11 and 14 to 16: seven places where the specification is silent or two documents
disagree.

- **8, `observation.command`.** `spec/domains/specification.yaml:461-463` says a command
  assessor runs it; `docs/evidence-format.md:602` says the invocation does not say how an
  assessor learns the observation. 13 of the consumer's 18 assessments carry their meaning in
  that key.
- **9, `holds` at a scope other than `run`.** `specification.yaml:489-494`. The consumer read
  it as "holds for every item". Not stated.
- **10, an assessor with only `run`-scope outputs.** `spec/domains/assessor.yaml:94-98`:
  `scopes` is required and lists the scopes "beside `run`". 6 of the consumer's 8 declarations
  write `scopes: []`. Whether the empty list is valid is not stated.
- **11, a value aggregated inside one run.** `specification.yaml:182-188`: `aggregation` is
  absent with `runs: 1`. `spec/domains/evidence.yaml:368-375`: a result carries `samples` and
  `aggregation`. The case: one command prints a median of three.
- **14, one unit per output.** `specification.yaml:176-181`. 45 minutes is written `2700`;
  `examples/ci-turnaround.ratchet.yaml` uses `min` and `s` for the same kind of value.
- **15, comments.** `spec/README.md:207` does not say whether a `ratchet/1` file may hold
  comments.
- **16, the evidence digest by hand.** `docs/evidence-format.md` § 2: the record id is the
  SHA-256 of the file; the evidence digest needs the byte span of one member, and no command
  or recipe computes it.

## Acceptance

Each of the seven places has one answer, written in `spec/` and in the document that was
silent or disagreed, and for each a case of a script test under `spec/` fails when the answer
is removed: an example document that the answer makes valid or invalid.

## Notes

- The form shown is the consumer's proposal. The story decides the form, declares it in
  `spec/` first (`ess specify validate` passes), and writes it into `docs/design.md` or
  `docs/evidence-format.md` in the same change.
- A new value or field of a released format is an addition: a file written for the format
  before the change stays valid.
- The story is a draft. It was there before the planned waves to 0.1.0 and waits for them.
