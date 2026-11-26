---
format: aep.planning-md/3
id: epic:format-gaps-first-format-consumer
kind: epic
status: draft
title: The formats say what the first format consumer's quality definition needs
summary: '23 findings from writing the quality definition of beyond10x/inference against the formats, 22 places after one was withdrawn: things a format cannot say, a missing set of declarations, silent or disagreeing places.'
relations:
- decomposes: initiative:first-milestone
revision: 8
---
## Context

The owner, 2026-11-25: "use ratchet to define quality of b10x/inference". The repository
`beyond10x/inference` wrote that definition against the formats at commit `f139ecc`, before any
`ratchet` command is built: 3 `ratchet/1` files (18 assessments, 35 measurements, 27
requirements, 5 gates), 8 `ratchet-assessor/1` declarations and 15 `ratchet-evidence/1` records.
All 15 records decode with `spec/record-examples.test.sh --json`.

Writing it found 16 places (findings 1 to 16) where a format cannot say what the definition
needs, where the specification is silent, or where two documents disagree. The correction round
of the definition found 3 more (findings 17 to 19) and the second quality unit of the consumer 4
more (findings 20 to 23), 23 in all. Finding 9 was withdrawn since, so 22 places remain. Each
is answered by a story of this epic, finding 8 by a story of `epic:preset-catalog`, with
`beyond10x/inference` as its first consumer.

## Outcome

Each of the 22 places has an answer in `spec/` and in the design documents, with a test that
failed before where a script reads the place; where none does, the story names that and
answers in text. The quality definition of `beyond10x/inference` can say in the formats what
it now leaves out or writes in a weaker form.

## Stories

- A thing the formats cannot say (findings 1 to 7 and 12): `story:condition-on-digest-value`,
  `story:coverage-count-with-reference`, `story:gate-entry-unless-only-paths`,
  `story:import-source-tree-file`, `story:coverage-count-lower-bound`,
  `story:result-with-two-dimensions`, `story:workflow-run-target-identifiers`,
  `story:records-tracked-baseline-directory`.
- No declaration for an example assessor (finding 13): `story:example-assessor-declarations`.
- Silent places and two documents that disagree (findings 10, 11 and 14 to 16):
  `story:specification-answers-first-format-consumer`. Finding 8 (`observation.command`) is
  answered by `story:assessor-learns-observation` of `epic:preset-catalog`.
- From the correction round of the definition (findings 17 to 19):
  `story:candidate-under-merge-result` with `story:candidate-under-merge-result-in-ratchet`,
  `story:plan-with-exact-and-sampled-measurements` with
  `story:plan-with-exact-and-sampled-measurements-in-ratchet`, `story:machine-as-a-condition`.
- From the second quality unit of the consumer, measures per adapter and latency defined
  without a number (findings 20 to 23): `story:gate-judges-commit-of-a-tag`,
  `story:plan-never-assessed`, `story:plan-declares-what-its-command-needs`,
  `story:list-item-statement`. A smaller observation of that unit, a coverage count an
  assessor does not report, is a note of `story:coverage-count-lower-bound`.

## Order

The epic is beside the waves to 0.1.0 and changes none of them. Its stories are drafts, except
`story:example-assessor-declarations`, taken ahead of the waves on 2026-11-25: every planned
wave starts behind `story:cli-skeleton-validate`, which waits for a release of ESS, and that
story needs no generated model.

The wave of `.engineering/waves/0.1.0-ahead-1.md`, chosen by the owner on 2026-11-26 for the
same reason, takes four of its stories ahead: `story:workflow-run-target-identifiers`,
`story:candidate-under-merge-result`, `story:specification-answers-first-format-consumer` and
`story:plan-with-exact-and-sampled-measurements`. The parts of two of them that need a
`ratchet` command are split into `story:candidate-under-merge-result-in-ratchet` and
`story:plan-with-exact-and-sampled-measurements-in-ratchet`, which wait for the waves to 0.1.0.

A story that changes a type the slice of 0.1.0 reads (`ratchet.evidence.EvidenceCoverage`,
`ratchet.evidence.ImportSourceKind`, `ratchet.specification.Condition`) is built after the wave
that reads the type, or with it when the wave's story is amended.

## Done when

The nineteen stories of this epic listed above are implemented or rejected with a written reason, and the consumer has been
told which key of its files each answer changes.
