---
format: aep.planning-md/3
id: approval-record:wave-ahead-1-stories
kind: approval-record
status: approved
title: The nine stories of the wave ahead of 0.1.0 are accepted for implementation
relations:
- decides: story:workflow-run-target-identifiers
- decides: story:candidate-under-merge-result
- decides: story:cache-condition-one-name
- decides: story:specification-answers-first-format-consumer
- decides: story:plan-with-exact-and-sampled-measurements
- decides: story:preset-check-unlisted-forms
- decides: story:value-over-all-runs
- decides: story:item-field-values
- decides: story:production-gate-spec-executed-service
revision: 2
transitions:
- {from: "draft", to: "approved", at: "2026-11-26T05:20:02Z", actor: "human:operator", revision: 2}
---
## Decision

The nine stories of `.engineering/waves/0.1.0-ahead-1.md` are accepted for implementation, in
the order of that record, on one branch merged as one pull request:
`story:workflow-run-target-identifiers`, `story:candidate-under-merge-result`,
`story:cache-condition-one-name`, `story:specification-answers-first-format-consumer`,
`story:plan-with-exact-and-sampled-measurements`, `story:preset-check-unlisted-forms`,
`story:value-over-all-runs`, `story:item-field-values`,
`story:production-gate-spec-executed-service`.

## On whose word

- The owner, 2026-11-26 about 05:18 CET, relayed by the operator session of the workstation:
  plan the next wave with several stories and the open gap closures together, one integration
  branch, one pull request.
- The operator session, deciding D78 for the owner, to the question which stories go into that
  wave, with the options A (five stories whose acceptance needs no `ratchet` command), B (A plus
  the parts of five more stories that need no command, each split) and C (no wave until the ESS
  release of beyond10x/ess#836): "D78 B".

## What the critics said

- Round 1, five stories: acceptance and scope critics, needs-revision, 11 and 16 findings
  (`review-result:critics-acceptance-wave-ahead-1-round-1`,
  `review-result:critics-scope-wave-ahead-1-round-1`). The five stories were revised; five more
  were split into the part buildable now and a draft `<id>-in-ratchet`;
  `story:preset-check-one-start` left the wave.
- Round 2, nine stories: needs-revision, 18 and 11 findings, one blocker each, on the counts of
  the production gate story and on the form of `story:value-over-all-runs`
  (`review-result:critics-acceptance-wave-ahead-1-round-2`,
  `review-result:critics-scope-wave-ahead-1-round-2`). Each finding was answered in the bodies
  with the answer the coordinator fixed; no third round was run. Two drafts were filed for what
  the production gate story leaves out: `story:severity-limit-on-identity-set` and
  `story:production-gate-kind`.

## Decisions of the coordinator

- The condition key is `cache_profile`: seven files released in 0.0.2 write it.
- An empty `scopes: []` of an assessor output is valid: a refusal would change released
  declarations.
- The form of a value computed over all runs is a member of `Measurement`, valid for every
  value of `runs`, and no aggregation at `runs: 1`.
