---
format: aep.planning-md/3
id: story:result-with-two-dimensions-in-ratchet
kind: story
status: draft
title: ratchet evaluate reads a result per scope item and condition cell
summary: 'The command part of story:result-with-two-dimensions: selection by cell, one series entry per item and cell, refusal of an undeclared cell.'
relations:
- decomposes: epic:format-gaps-first-format-consumer
- depends_on: story:result-with-two-dimensions
- depends_on: story:cli-skeleton-validate
- depends_on: story:assessor-declaration
- depends_on: story:evidence-reader
- depends_on: story:evaluate-command
scope:
- confidence: inferred
  path: crates/ratchet
- confidence: inferred
  path: crates/ratchet-core
revision: 3
---
## Context

Split on 2026-11-26 from `story:result-with-two-dimensions`, which gives a result of a
`ratchet-evidence/1` record a `cell` beside its scope item, gives an output of a declaration
its `cells` and a measurement a `cell` selection, and writes the rules into
`docs/evidence-format.md` § 3, § 4 and `docs/design.md` § 3. This story holds the part that
needs the `ratchet` command.

## Acceptance

In a fixture project with one output that declares `cells: [viewport]` and a record of two
results of one item in the cells `narrow` and `wide`, `ratchet evaluate --gate <name>` judges
a measurement with `cell: {viewport: narrow}` on the narrow value alone, and a measurement
without `cell` as two entries of the series, one per cell; the evidence reader refuses a
result whose `cell` names a condition its output does not declare, and `ratchet validate`
refuses a measurement whose `cell` names one, each with a code that names the rule. Before
the story no command reads a record.

## Notes

- Moved from the acceptance of `story:result-with-two-dimensions`.
- The story is a draft. It waits for the waves to 0.1.0: `story:cli-skeleton-validate`,
  `story:assessor-declaration`, `story:evidence-reader` and `story:evaluate-command`.
