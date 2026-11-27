---
format: aep.planning-md/3
id: story:requirement-states-a-range-in-ratchet
kind: story
status: draft
title: ratchet validate refuses a range whose bounds are reversed and ratchet evaluate names the bound a value crosses
summary: 'The command part of story:requirement-states-a-range: the refusal of a range whose min is above its max, the verdict outside the range and the gate report of a range.'
relations:
- decomposes: epic:format-gaps-first-format-consumer
- depends_on: story:requirement-states-a-range
- depends_on: story:cli-skeleton-validate
- depends_on: story:evaluate-command
scope:
- confidence: inferred
  path: crates/ratchet-core
- confidence: inferred
  path: crates/ratchet/src/commands/evaluate.rs
- confidence: inferred
  path: crates/ratchet/src/commands/validate.rs
revision: 9
---
## Context

Split on 2026-11-26 from `story:requirement-states-a-range`, which declares the operator
`within` with `min` and `max` on `ratchet.specification.Condition` with the invariant
`min <= max`, adds `min` and `max` to `ratchet.cli.LimitRow` in `spec/domains/cli.yaml`, writes
the form into `docs/design.md` § 3 "Comparisons", and makes `spec/presets.test.sh` hold a
preset to it, refusing a range whose `min` is above its `max`. This story holds the part that
needs the `ratchet` command.

## Acceptance

1. `ratchet validate` in a fixture project whose requirement states
   `condition: {operator: within, min: 60, max: 50, unit: s}` exits non-zero and names the
   requirement and the two bounds; the same file with `min: 50, max: 60` is accepted. Before
   the story no command reads the form.
2. `ratchet evaluate --gate <name>` in a fixture with a requirement
   `condition: {operator: within, min: 50, max: 60, unit: s}` passes on a value of 55, and on a
   value of 61 gives the verdict fail with the cause `limit_crossed` and a line that names the
   bound `max: 60` as the one crossed (on 49, `min: 50`).
3. The gate report of that run shows the range as one limit of one entry: its `allowed`
   (`ratchet.cli.LimitRow`) holds `operator: within`, `min: "50"` and `max: "60"` and no
   `value`.

## Notes

- Moved from the acceptance of `story:requirement-states-a-range`. The refusal of a range
  whose lower bound is above its upper bound was promised by the original story; the decoder
  refuses it through the invariant, and this story makes `ratchet validate` report it.
- `ratchet.cli.LimitRow.min` and `max` are declared by `story:requirement-states-a-range`; this
  story fills them and changes no file of `spec/`.
- The story is a draft. It waits for the waves to 0.1.0: `story:cli-skeleton-validate` and
  `story:evaluate-command`.
