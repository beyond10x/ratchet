---
format: aep.planning-md/3
id: story:gate-joins-revision-and-document-in-ratchet
kind: story
status: draft
title: ratchet evaluate joins a document run with the candidate revision in one gate
summary: 'The command part of story:gate-joins-revision-and-document: the join by the digest at the candidate revision, and its cause.'
relations:
- decomposes: epic:ess-ui-behavior
- depends_on: story:gate-joins-revision-and-document
- depends_on: story:cli-skeleton-validate
- depends_on: story:evaluate-command
- depends_on: story:evidence-reader
scope:
- confidence: inferred
  path: crates/ratchet-core
revision: 5
---
## Context

Split on 2026-11-26 from `story:gate-joins-revision-and-document`, which writes into
`docs/design.md` § 5 how a candidate gate joins a run of a `document` target with the
candidate revision (the digest of the file at that revision) and declares the joined document
`document` on `ratchet.gate.RequirementVerdict` and on the report row `ratchet.cli.VerdictRow`.
This story holds the part that needs the `ratchet` command.

## Acceptance

`ratchet evaluate --gate <name>` in a fixture with one gate over a `revision` plan and a
`document` plan passes when both runs qualify for the candidate, writes the document's path
and digest under `document` in the decision and in the gate report, and gives insufficient
evidence with the cause `not_attributable_to_candidate` naming the document when its digest is
not the one at the candidate revision. Before the story the document run never qualifies.

## Notes

- Moved from the acceptance of `story:gate-joins-revision-and-document`, where the members are
  declared; this story fills them.
- The story is a draft. It waits for the waves to 0.1.0: `story:cli-skeleton-validate`,
  `story:evaluate-command`, `story:evidence-reader`.
