---
format: aep.planning-md/3
id: story:condition-on-digest-value-in-ratchet
kind: story
status: draft
title: ratchet validate and ratchet evaluate hold a digest to the value the specification states
summary: 'The command part of story:condition-on-digest-value: the refusal on another value type, and a verdict that names both digests.'
relations:
- decomposes: epic:format-gaps-first-format-consumer
- depends_on: story:condition-on-digest-value
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

Split on 2026-11-26 from `story:condition-on-digest-value`, which declares the member `digest`
of `ratchet.specification.Condition` in `spec/domains/specification.yaml`, writes into
`docs/design.md` § 3 "Comparisons" that a digest is compared with `{operator: eq, digest: ...}`,
and makes `spec/presets.test.sh` hold a preset to that form. This story holds the part that
needs the `ratchet` command.

## Acceptance

`ratchet validate` accepts a requirement with `condition: {operator: eq, digest: "sha256:..."}`
on a measurement whose output its assessor declares with the value type `digest`, and refuses
the same condition on an output of another value type with a code that names the rule; and
`ratchet evaluate --gate <name>` in a fixture whose record holds another digest than the stated
one gives the verdict fail with the cause `limit_crossed`, and its gate decision names the
stated digest (`allowed`) and the observed one; before the story no command reads the form.

## Notes

- Moved from the acceptance of `story:condition-on-digest-value`, verbatim but for the code
  and the cause.
- The story is a draft. It waits for the waves to 0.1.0: `story:cli-skeleton-validate` and
  `story:evaluate-command`.
