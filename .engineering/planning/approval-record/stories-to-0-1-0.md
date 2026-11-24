---
format: aep.planning-md/3
id: approval-record:stories-to-0-1-0
kind: approval-record
status: approved
title: The 12 stories to 0.1.0 are accepted for implementation
relations:
- decides: story:record-formats-in-spec
- decides: story:cli-skeleton-validate
- decides: story:evidence-reader
- decides: story:assessor-declaration
- decides: story:reference-compare
- decides: story:changelog-release-procedure
- decides: story:assess-command
- decides: story:reference-adopt-command
- decides: story:evaluate-command
- decides: story:ui-loop-acceptance
- decides: story:acceptance-in-gate
- decides: story:release-0-1-0
revision: 2
transitions:
- {from: "draft", to: "approved", at: "2026-11-24T13:10:22Z", actor: "agent:ratchet", revision: 2}
---
## Decision

The 12 stories that lead to release 0.1.0 are accepted for implementation, in the six waves
`aep plan artifact waves --kind story` derives and `ROADMAP.md` lists.

## On whose word

- The owner, 2026-11-24, relayed by the operator session of the workstation: "make sure they are
  building stuff and they have a plan and the vision, a trajectory, a direction."
- The brief of the operator session of the same day to the session that owns this repository:
  turn `vision.md` § "First milestone" into epics and stories and start wave 1 in the same step.
- The workspace rule "Goal first": a story starts implementation as soon as its critics approve
  it.

## What the critics said

- Round 1: four verdicts `needs-revision`, 22 findings, 22 recorded as fixed
  (`review-result:*-round-1`).
- Round 2, the last: `review-result:scope-round-2` and `review-result:parallel-safety-round-2`
  approve; `review-result:design-round-2` has 1 finding and `review-result:acceptance-round-2`
  has 2. Two of the three are the same defect (no story made the acceptance run write the
  transcript `story:acceptance-in-gate` reads); the third is a missing case for
  `release-verify.sh` in `story:changelog-release-procedure`.
- The three findings were fixed after round 2 with the remedy each names. No critic read these
  fixes: the panel has two rounds. The stories they touch are in waves 3 to 5.
- Two remarks the critics marked as outside their lane were taken as well: the `spec` module
  takes file contents from a source, so `story:evaluate-command` does not edit it, and the
  default of the local record directory is declared by `story:record-formats-in-spec`.

## Commits this record authorises

Per wave: one commit per story, the closing store commit, and a pull request to `main` merged
through the bot. No tag and no release: those follow `AGENTS.md` § "Release" in
`story:release-0-1-0`.
