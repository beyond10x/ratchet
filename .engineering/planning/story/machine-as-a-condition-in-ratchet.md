---
format: aep.planning-md/3
id: story:machine-as-a-condition-in-ratchet
kind: story
status: draft
title: ratchet evaluate judges the machine conditions of a plan and of its reference
summary: 'The command part of story:machine-as-a-condition: conditions_outside_declared and reference_not_comparable naming the machine key.'
relations:
- decomposes: epic:format-gaps-first-format-consumer
- depends_on: story:machine-as-a-condition
- depends_on: story:cli-skeleton-validate
- depends_on: story:evaluate-command
- depends_on: story:reference-compare
scope:
- confidence: inferred
  path: crates/ratchet-core
- confidence: inferred
  path: crates/ratchet/src/commands/evaluate.rs
revision: 3
---
## Context

Split on 2026-11-26 from `story:machine-as-a-condition`, which gives
`ratchet.specification.ObservationConditions` four more conditions with a defined meaning,
`cpu_model`, `memory`, `accelerator` and `build_profile`, held in a record under
`evidence.conditions.other` by the same names, and writes them into `docs/design.md` § 3 and
§ 5 "Protected references", rule 5. This story holds the part that needs the `ratchet` command.

## Acceptance

1. `ratchet evaluate --gate <name>` in a fixture whose plan declares `build_profile: release`
   for the class of its run: a record with `other.build_profile: debug` gives insufficient
   evidence with the cause `conditions_outside_declared` and a message that names
   `build_profile`; a record with `release` is judged. A record without the member gives
   insufficient evidence for an unknown declared condition (`docs/evidence-format.md` § 3,
   "Unknown, or not applicable").
2. A reference adopted from runs with `cpu_model` of one value is not compared with evidence
   whose `cpu_model` has another: the verdict is insufficient evidence with the cause
   `reference_not_comparable` and names the key.

## Notes

- Moved from the acceptance of `story:machine-as-a-condition`.
- The story is a draft. It waits for the waves to 0.1.0: `story:cli-skeleton-validate`,
  `story:evaluate-command` and `story:reference-compare`.
