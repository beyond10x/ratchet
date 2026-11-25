---
format: aep.planning-md/3
id: story:workflow-run-target-identifiers
kind: story
status: draft
title: A workflow_run target names its run and its job
summary: Identifiers run_id and job for a target of the kind workflow_run.
relations:
- decomposes: epic:format-gaps-first-format-consumer
revision: 1
---
## Context

The repository `beyond10x/inference` wrote its quality definition against the formats at
commit `f139ecc` (2026-11-25): 3 `ratchet/1` files, 8 `ratchet-assessor/1` declarations and 15
`ratchet-evidence/1` records. It is the first consumer of the formats outside this repository
and of this story. Line numbers below are those of `f139ecc`.

Finding 7. A record of a CI run cannot say which run it is. `identifiers` of a target lists
names per target kind (`spec/domains/evidence.yaml:112-119`), and none is a run id or a job.
The consumer's example: `"identifiers": {"run_id": "<id>", "job": "<workflow> / <job>"}`.

## Acceptance

The specification lists the identifiers of a target of the kind `workflow_run`, a record that
carries them decodes, and two records of two jobs of one run are told apart by them; before
the story `spec/record-examples.test.sh` or the reader of the story refuses the names.

## Notes

- The form shown is the consumer's proposal. The story decides the form, declares it in
  `spec/` first (`ess specify validate` passes), and writes it into `docs/design.md` or
  `docs/evidence-format.md` in the same change.
- A new value or field of a released format is an addition: a file written for the format
  before the change stays valid.
- The story is a draft. It was there before the planned waves to 0.1.0 and waits for them.
