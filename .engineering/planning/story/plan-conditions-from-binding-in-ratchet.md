---
format: aep.planning-md/3
id: story:plan-conditions-from-binding-in-ratchet
kind: story
status: draft
title: ratchet validate resolves a binding that passes the conditions of a plan
summary: 'The command part of story:plan-conditions-from-binding: the binding passes a conditions input, and a value that is no map is refused with a code.'
relations:
- decomposes: epic:preset-catalog
- depends_on: story:plan-conditions-from-binding
- depends_on: story:cli-skeleton-validate
- depends_on: story:preset-binding-resolution
scope:
- confidence: inferred
  path: crates/ratchet-core
- confidence: inferred
  path: crates/ratchet/src/commands/validate.rs
revision: 3
---
## Context

Split on 2026-11-26 from `story:plan-conditions-from-binding`, which adds the input type
`conditions` to `ratchet.specification.InputType`, lets a reference to such an input stand as
the whole value of `observation.conditions` of a preset, gives it to `operation-time@2`, and
makes `spec/presets.test.sh` check where it stands. This story holds the part that needs the
`ratchet` command.

## Acceptance

`ratchet validate` resolves a binding of `operation-time@2` that passes
`conditions: {local: {host_load_per_cpu: {max: 0.5}}, ci: {runner: ci-standard}}` to a plan
with those conditions per class, and refuses a binding whose value for a `conditions` input is
no map from a class to conditions, with a code that names the binding and the input; before the
story no command resolves a binding.

## Notes

- Moved from the acceptance of `story:plan-conditions-from-binding`.
- The story is a draft. It waits for the waves to 0.1.0: `story:cli-skeleton-validate` and
  `story:preset-binding-resolution`.
