---
format: aep.planning-md/3
id: story:imported-report-revision-check-in-ratchet
kind: story
status: draft
title: ratchet assess refuses an imported report of another revision
summary: 'The command part of story:imported-report-revision-check: a report whose stated revision is not the candidate''s is not recorded as its evidence.'
relations:
- decomposes: epic:format-gaps-second-format-consumer
- depends_on: story:imported-report-revision-check
- depends_on: story:cli-skeleton-validate
- depends_on: story:assessor-declaration
- depends_on: story:assess-command
scope:
- confidence: inferred
  path: crates/ratchet
- confidence: inferred
  path: crates/ratchet-core
revision: 3
---
## Context

Split on 2026-11-26 from `story:imported-report-revision-check`, which declares
`revision_inputs` on a `ratchet-assessor/1` declaration and `revision` on a resolved input of a
`ratchet-evidence/1` record, writes the rule into `docs/evidence-format.md` § 10, and gives it
to `conformance-report@2`. This story holds the part that needs the `ratchet` command.

## Acceptance

`ratchet assess` in a fixture whose stand-in assessor of `conformance-report@2` writes
`inputs.report.revision` another than the candidate's revision records no evidence of the
candidate and reports the run as refused, with a cause that names both revisions; with the
candidate's revision the record is kept. Before the story a report of any revision is recorded
as the candidate's evidence.

## Notes

- Moved from the acceptance of `story:imported-report-revision-check`.
- The story is a draft. It waits for the waves to 0.1.0: `story:cli-skeleton-validate`,
  `story:assessor-declaration` and `story:assess-command`.
