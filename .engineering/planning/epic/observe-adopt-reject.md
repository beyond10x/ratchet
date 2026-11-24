---
format: aep.planning-md/3
id: epic:observe-adopt-reject
kind: epic
status: draft
title: Observe, adopt a gate, reject a regression with the evidence named
summary: 'assess, reference adopt and evaluate for exact numbers and identity sets: the slice of 0.1.0.'
relations:
- decomposes: initiative:first-milestone
- depends_on: epic:runnable-cli
revision: 1
---
## Context

The smallest slice of the first milestone that runs end to end: a project observes a measurement,
adopts a reference and a gate, and a candidate that is worse than the reference is rejected with
the evidence named (`vision.md`, outcomes 1 and 2). It is the first gap of the first consumer
(`initiative:first-milestone`).

## Outcome

With the `ratchet` binary and a `ratchet/1` document a project can:

1. run `ratchet assess`, which starts each assessor by the contract of `docs/evidence-format.md`
   § 10 and records a `ratchet-evidence/1` document per run;
2. run `ratchet reference adopt <requirement>`, which writes the first reference record from
   recorded evidence into `ratchet/references/<requirement>.json`;
3. run `ratchet evaluate --gate <name>`, which judges the candidate's evidence by the
   specification and the references of the trusted revision and exits 0 only on a pass.

A fail names the requirement, the scope item, the observed and the allowed value, the cause and
the id of the evidence record. A missing reference, a missing run, a run that did not complete and
coverage below the plan are insufficient evidence, each with its cause.

## In this slice

- Value types `number` and `identity_set`; measurement kind `exact`.
- Conditions `lt`, `lte`, `gt`, `gte`, `eq`, `no_new_items`, `no_lost_items`; an accepted value
  with an absolute or percent tolerance and `better`.
- Candidate gates with entries in the modes enforce and report.
- The local record directory (the hand-over of design § 6).

## Not in this slice

Sampled measurements and declared conditions, generated references, `when`, exceptions,
trade-offs, tightening and the stale-reference fail, operational gates and time windows, the git
ref `refs/ratchet/records`, presets, `ratchet prove`. Each is in a later epic of
`initiative:first-milestone`.

## Done when

The six stories that decompose this epic are implemented.
