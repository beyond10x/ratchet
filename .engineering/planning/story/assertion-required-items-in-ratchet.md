---
format: aep.planning-md/3
id: story:assertion-required-items-in-ratchet
kind: story
status: draft
title: ratchet evaluate holds an assertion to the items its measurement requires
summary: 'The command part of story:assertion-required-items: insufficient evidence that names the missing items or the count.'
relations:
- decomposes: epic:preset-catalog
- depends_on: story:assertion-required-items
- depends_on: story:cli-skeleton-validate
- depends_on: story:evaluate-command
scope:
- confidence: inferred
  path: crates/ratchet-core
- confidence: inferred
  path: crates/ratchet/src/commands/evaluate.rs
revision: 3
---
## Context

Split on 2026-11-26 from `story:assertion-required-items`, which declares `min_items` and
`required_items` of `ratchet.specification.Measurement`, writes the verdict into
`docs/design.md` § 3, and adds `health-readiness@2`. This story holds the part that needs the
`ratchet` command.

## Acceptance

`ratchet evaluate --gate <name>` in a fixture of `health-readiness@2` whose report holds no
expectation on the readiness endpoint gives the requirement `readiness-answers-hold` the
verdict insufficient evidence with the cause `coverage_below_plan` and names the measurement
and the count 0 against `min_items: 1`; a requirement with `required_items` whose result lacks
one names that item; a report with an expectation on each endpoint is judged by `holds`; before
the story a run with no expectation on one endpoint passes that requirement.

## Notes

- Moved from the acceptance of `story:assertion-required-items`, with the verdict the story
  decided.
- The story is a draft. It waits for the waves to 0.1.0: `story:cli-skeleton-validate` and
  `story:evaluate-command`.
