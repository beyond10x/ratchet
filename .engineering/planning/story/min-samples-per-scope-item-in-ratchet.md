---
format: aep.planning-md/3
id: story:min-samples-per-scope-item-in-ratchet
kind: story
status: draft
title: ratchet validate and ratchet evaluate hold each scope item to min_samples_per_item
summary: 'The command part of story:min-samples-per-scope-item: the refusal at the scope run with a code, and too_few_samples for one item.'
relations:
- decomposes: epic:ci-turnaround
- depends_on: story:min-samples-per-scope-item
- depends_on: story:cli-skeleton-validate
- depends_on: story:evaluate-command
scope:
- confidence: inferred
  path: crates/ratchet-core
- confidence: inferred
  path: crates/ratchet/src/commands/evaluate.rs
- confidence: inferred
  path: crates/ratchet/src/commands/validate.rs
revision: 4
---
## Context

Split on 2026-11-26 from `story:min-samples-per-scope-item`, which declares
`min_samples_per_item` on `ratchet.specification.Measurement` in `spec/domains/specification.yaml`
(at least 1, refused at the scope `run` by an invariant of the type) and writes into
`docs/design.md` § 3 and § 5 "Verdicts" that an item whose result carries fewer `samples` is
insufficient evidence with the cause `too_few_samples` for that item alone. This story holds the
part that needs the `ratchet` command.

## Acceptance

1. `ratchet validate` on a fixture whose measurement at the scope `run` states
   `min_samples_per_item` exits non-zero with a code that names the rule and the measurement;
   the same member on a measurement at the scope `test` is accepted. Before the story no command
   reads the member.
2. `ratchet evaluate --gate <name>` in a fixture with a window measurement at the scope
   `scenario`, `min_samples_per_item: 5`, and evidence where one scenario's result carries
   `samples: 2` and the others at least 5: the report gives that scenario insufficient evidence
   with the cause `too_few_samples` and names it, and judges the other scenarios against their
   limit or reference.

## Notes

- Moved from the acceptance of `story:min-samples-per-scope-item`.
- The story is a draft. It waits for the waves to 0.1.0: `story:cli-skeleton-validate` and
  `story:evaluate-command`.
