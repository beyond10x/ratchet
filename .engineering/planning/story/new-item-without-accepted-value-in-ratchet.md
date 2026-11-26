---
format: aep.planning-md/3
id: story:new-item-without-accepted-value-in-ratchet
kind: story
status: draft
title: ratchet evaluate and reference adopt judge a scope item with no accepted value as the reference declares
summary: 'The command part of story:new-item-without-accepted-value: an item not judged in the verdict, and its first adoption.'
relations:
- decomposes: epic:improvement-and-policy
- depends_on: story:new-item-without-accepted-value
- depends_on: story:cli-skeleton-validate
- depends_on: story:evaluate-command
- depends_on: story:reference-adopt-command
scope:
- confidence: inferred
  path: crates/ratchet-core
revision: 5
---
## Context

Split on 2026-11-26 from `story:new-item-without-accepted-value`, which declares
`new_items: not_judged` on a protected reference in `spec/domains/specification.yaml`, the
member `items_not_judged` on `ratchet.gate.RequirementVerdict` and on the report row
`ratchet.cli.VerdictRow`, and writes into `docs/design.md` § 5 how such an item is judged and
that adopting its value is a first adoption. This story holds the part that needs the
`ratchet` command.

## Acceptance

In a fixture with a requirement that has an accepted value per scope item and
`new_items: not_judged`, and evidence with one item the reference does not hold,
`ratchet evaluate --gate <name>` judges the other items, writes the new item under
`items_not_judged` in the gate report and in the decision, and passes when the other items
pass; with the default the same fixture gives insufficient evidence with `reference_missing`
for that item. `ratchet reference adopt` then writes the new item's value as a reference change
of the kind `first_adoption` for that item, not `loosening`. Before the story neither command
reads the member.

## Notes

- Moved from the acceptance of `story:new-item-without-accepted-value`. The members of the
  gate report and the decision are declared there; this story fills them.
- The story is a draft. It waits for the waves to 0.1.0: `story:cli-skeleton-validate`,
  `story:evaluate-command`, `story:reference-adopt-command`.
