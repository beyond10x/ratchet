---
format: aep.planning-md/3
id: story:item-field-values-in-ratchet
kind: story
status: draft
title: ratchet validate and the evidence reader hold an item field to its declared values
summary: 'The command part of story:item-field-values: a filter on a value outside the list, and a record item with another value, are refused.'
relations:
- decomposes: epic:preset-catalog
- depends_on: story:item-field-values
- depends_on: story:cli-skeleton-validate
- depends_on: story:assessor-declaration
- depends_on: story:evidence-reader
revision: 1
---
## Context

Split on 2026-11-26 from `story:item-field-values`, which declares the closed list of values of
an item field in `spec/domains/assessor.yaml` and `docs/evidence-format.md` § 10, gives
`comparison-report@2` the values of `class`, and makes `spec/presets.test.sh` refuse a
`filter` on a value outside the list. This story holds the part that needs the `ratchet`
command: the same rule in `ratchet validate`, and the evidence reader.

`ratchet validate` checks the fields of a `filter` against the declaration
(`story:assessor-declaration`); the evidence reader reads the items of a result
(`story:evidence-reader`). Neither reads a value of an item field.

## Acceptance

`ratchet validate` refuses a `filter` of a plan that names a value outside the list of its
field, and an evidence record with an item whose field holds another value is refused when it
is read; before the story `filter: {class: [diferent]}` passes both checks.

## Notes

- Moved verbatim from the acceptance of `story:item-field-values`, less its check of
  `spec/presets.test.sh`, which stays there.
- A field without a list of values stays open in both checks.
- The story is a draft. It waits for the waves to 0.1.0: `story:cli-skeleton-validate`,
  `story:assessor-declaration` and `story:evidence-reader`.
