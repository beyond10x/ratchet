---
format: aep.planning-md/3
id: story:number-states-its-source-in-ratchet
kind: story
status: draft
title: ratchet explain and the gate report print the source of a limit and a tolerance
summary: 'The command part of story:number-states-its-source: the output of ratchet explain and of the gate report.'
relations:
- decomposes: epic:format-gaps-first-format-consumer
- depends_on: story:number-states-its-source
- depends_on: story:cli-skeleton-validate
- depends_on: story:evaluate-command
scope:
- confidence: inferred
  path: crates/ratchet-core
- confidence: inferred
  path: crates/ratchet/src/commands/evaluate.rs
revision: 8
---
## Context

Split on 2026-11-26 from `story:number-states-its-source`, which declares
`ratchet.specification.NumberSource`, the member `source` of `Condition` and `Tolerance` in
`spec/domains/specification.yaml` and of `ratchet.cli.LimitRow` in `spec/domains/cli.yaml`,
and writes the form into `docs/design.md` § 3. This story holds the part that needs the
`ratchet` command.

## Acceptance

1. `ratchet explain <requirement>` prints the `cites` and the `since` of the limit and of the
   tolerance of a requirement that states them, beside the allowed value; a requirement
   without a source prints as before. Before the story no command reads the form.
2. The gate report of `ratchet evaluate --gate <name>` over the same requirement holds the
   source in the row of the limit: `allowed.source.cites` of its `ratchet.cli.VerdictRow`
   is the text the file states.

## Notes

- Moved from the acceptance of `story:number-states-its-source`. The member of
  `ratchet.cli.LimitRow` is declared by that story; this story fills it and changes no file of
  `spec/`.
- No story builds `ratchet explain` yet (`docs/design.md` § 5 "Proposed CLI"); this story
  waits for the one that does, and for the gate report.
- The story is a draft. It waits for the waves to 0.1.0: `story:cli-skeleton-validate` and
  `story:evaluate-command`.
