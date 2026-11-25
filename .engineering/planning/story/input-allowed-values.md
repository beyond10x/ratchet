---
format: aep.planning-md/3
id: story:input-allowed-values
kind: story
status: draft
title: An input of a preset declares the values it may have
summary: An input has a type and no list of values, so a wrong direction word is found where it is used.
relations:
- decomposes: epic:preset-catalog
- depends_on: story:preset-catalog-factory
scope:
- confidence: inferred
  path: CHANGELOG.md
- confidence: inferred
  path: docs/design.md
- confidence: inferred
  path: presets
- confidence: inferred
  path: spec/domains/specification.yaml
revision: 5
---
## Context

The entry "The values an input may have" under "Not expressible yet" on `presets/code.md`
(`story:preset-catalog-factory`). First consumer: the catalog, and every project that binds
`code-lines@1`.

Neither more nor fewer generated lines is better for every project, so `code-lines@1` takes
the direction of its two counts from the binding: the inputs `generated_better` and
`handwritten_better` hold `lower` or `higher`, and `better` of each measurement is a reference
to one. `ratchet.specification.InputDeclaration` has a type and no list of the values an input
may have (`spec/domains/specification.yaml`). So the preset file does not say which words a
binding may pass, and a wrong word is found where the value is used and not at the input.

## Acceptance

An input of a preset declares the values it may have, `ratchet validate` refuses a binding
that passes another value and names the input and the allowed values, and refuses a preset
that uses such an input where a value of the list is not allowed; `code-lines@1` in a new
version declares `lower` and `higher` for its two inputs; before the story any text is
accepted at the input.

## Notes

- The story decides the form (a member `values` of the declaration, or an input type per
  closed list of the format), declares it in `spec/` first and writes it into
  `docs/design.md` § 4 in the same change.
- An addition to a released format; a preset that uses it is a new version of the preset.
- The story is a draft. It waits for the waves to 0.1.0 and for
  `story:preset-binding-resolution`.
