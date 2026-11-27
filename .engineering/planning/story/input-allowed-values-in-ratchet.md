---
format: aep.planning-md/3
id: story:input-allowed-values-in-ratchet
kind: story
status: draft
title: ratchet validate holds a passed input to its declared values
summary: 'The command part of story:input-allowed-values: a binding or a plan that passes a value outside values is refused with a code.'
relations:
- decomposes: epic:preset-catalog
- depends_on: story:input-allowed-values
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

Split on 2026-11-26 from `story:input-allowed-values`, which adds `values` to
`ratchet.specification.InputDeclaration`, gives it to `code-lines@2`, and makes
`spec/presets.test.sh` refuse a default, a reference and a passed literal outside the values.
This story holds the part that needs the `ratchet` command.

## Acceptance

`ratchet validate` refuses a binding of `code-lines@2` that passes `generated_better: sideways`,
and a plan that passes a value outside the `values` of an input of its assessor's declaration,
each with a code that names the input and the allowed values; a binding that passes `lower` is
accepted. Before the story no command reads `values`.

## Notes

- Moved from the acceptance of `story:input-allowed-values`.
- The story is a draft. It waits for the waves to 0.1.0: `story:cli-skeleton-validate` and
  `story:preset-binding-resolution`.
