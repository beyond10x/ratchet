---
format: aep.planning-md/3
id: story:list-item-statement-in-ratchet
kind: story
status: draft
title: ratchet explain and the gate report show the statement of a scope item
summary: 'The command part of story:list-item-statement: the statement beside the result of its item, and a statement about no item.'
relations:
- decomposes: epic:format-gaps-first-format-consumer
- depends_on: story:list-item-statement
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

Split on 2026-11-26 from `story:list-item-statement`, which declares the member `meanings` of
`ratchet.specification.Measurement`, a statement per scope item, the members `meanings` of
`ratchet.cli.Explanation` and `ratchet.cli.VerdictRow` and `meanings_without_result` of
`VerdictRow` in `spec/domains/cli.yaml`, and writes the form into `docs/design.md` § 3 "Scope
and aggregation". This story holds the part that needs the `ratchet` command.

## Acceptance

1. `ratchet explain <requirement>` prints the statement of each item of its measurement's
   `meanings`; before the story no command reads the form.
2. The gate report of `ratchet evaluate --gate <name>` holds the statements in `meanings` of
   the requirement's row, beside the results of their items.
3. A statement whose item no result of the run holds is listed in `meanings_without_result` of
   that row.

## Notes

- Moved from the acceptance of `story:list-item-statement`. The draft had `ratchet validate`
  refuse a statement about an item the list does not hold; the items of a scope are known only
  from a run, so the report names such a statement instead.
- The members of `spec/domains/cli.yaml` are declared by `story:list-item-statement`; this
  story fills them and changes no file of `spec/`.
- No story builds `ratchet explain` yet (`docs/design.md` § 5 "Proposed CLI").
- The story is a draft. It waits for the waves to 0.1.0: `story:cli-skeleton-validate` and
  `story:evaluate-command`.
