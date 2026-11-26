---
format: aep.planning-md/3
id: story:requirement-states-a-range-in-ratchet
kind: story
status: draft
title: ratchet evaluate names the bound of a range that a value crosses
summary: 'The command part of story:requirement-states-a-range: the verdict outside the range and the gate report of a range.'
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
  path: spec/domains/cli.yaml
revision: 4
---
## Context

Split on 2026-11-26 from `story:requirement-states-a-range`, which declares the operator
`within` with `min` and `max` on `ratchet.specification.Condition`, writes it into
`docs/design.md` § 3 "Comparisons", and makes `spec/presets.test.sh` hold a preset to it. The
decoder refuses a range whose `min` is above its `max` through an invariant. This story holds
the part that needs the `ratchet` command.

## Acceptance

`ratchet evaluate --gate <name>` in a fixture with a requirement
`condition: {operator: within, min: 50, max: 60, unit: s}` passes on a value of 55, and on a
value of 61 gives the verdict fail with the cause `limit_crossed` and a line that names the
bound `max: 60` as the one crossed (on 49, `min: 50`); the gate report shows the range as one
limit of one entry (`ratchet.cli.LimitRow`, declared in `spec/domains/cli.yaml` first); before
the story no command reads the form.

## Notes

- Moved from the acceptance of `story:requirement-states-a-range`.
- `ratchet.cli.LimitRow` holds one `value` (`spec/domains/cli.yaml:53-60`); the story declares
  how a row holds two bounds before code uses it.
- The story is a draft. It waits for the waves to 0.1.0: `story:cli-skeleton-validate` and
  `story:evaluate-command`.
