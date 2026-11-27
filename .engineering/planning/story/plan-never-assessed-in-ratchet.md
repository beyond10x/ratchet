---
format: aep.planning-md/3
id: story:plan-never-assessed-in-ratchet
kind: story
status: draft
title: ratchet status tells a plan never assessed from one whose record is missing
summary: 'The command part of story:plan-never-assessed: plan_state in the rows of ratchet status, with the reason of no_run_expected.'
relations:
- decomposes: epic:format-gaps-first-format-consumer
- depends_on: story:plan-never-assessed
- depends_on: story:cli-skeleton-validate
- depends_on: story:evidence-reader
scope:
- confidence: inferred
  path: crates/ratchet-core
- confidence: inferred
  path: crates/ratchet/src/commands/status.rs
revision: 7
---
## Context

Split on 2026-11-26 from `story:plan-never-assessed`, which declares `no_run_expected` with a
`reason` on `ratchet.specification.AssessmentPlan` and `plan_state`
(`assessed`, `never_assessed`, `no_run_expected`) on `ratchet.cli.StatusRow`, and writes into
`docs/design.md` § 5 "Gate modes" how the three states differ. This story holds the part that
needs the `ratchet` command.

## Acceptance

`ratchet status` in a fixture with three plans in observe mode, one with a run in the local
record directory, one with none, and one with none whose file states `no_run_expected` with a
reason: each row of their requirements has `plan_state` `assessed`, `never_assessed` and
`no_run_expected`, and the third prints the reason. Before the story the command answers
`cli_handler_unavailable`.

## Notes

- Moved from the acceptance of `story:plan-never-assessed`.
- `ratchet validate` refuses nothing for `no_run_expected`: an enforced entry over such a plan
  is valid and gives `evidence_missing` in a gate, as any entry without a qualifying run.
- The story is a draft. It waits for the waves to 0.1.0: `story:cli-skeleton-validate` and
  `story:evidence-reader` (the local record directory).
