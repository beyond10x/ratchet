---
format: aep.planning-md/3
id: story:item-field-values
kind: story
status: draft
title: An assessor declaration states the values of an item field
summary: A closed list of values for an item field, so that a filter on a misspelt value is refused.
relations:
- decomposes: epic:preset-catalog
- depends_on: story:preset-catalog-functional
scope:
- confidence: inferred
  path: CHANGELOG.md
- confidence: inferred
  path: docs/evidence-format.md
- confidence: inferred
  path: presets
- confidence: inferred
  path: spec/domains/assessor.yaml
- confidence: inferred
  path: spec/presets.test.sh
revision: 6
---
## Context

The third of three things `presets/functional.md` lists under "Not expressible yet"
(`story:preset-catalog-functional`). First consumer: the catalog, and every project that
writes an assessor declaration with a classified item.

`comparison-report@1` gives each case the item field `class` with one of `equal`, `allowed`
and `different`, and three measurements of `differential-equality@1` select by it with
`filter`. `ratchet.assessor.AssessorOutput.item_fields` is `Optional<List<String>>`: the names of the
fields and not their values (`spec/domains/assessor.yaml`). A `filter` on a misspelt class
selects nothing, no check refuses it, and `spec/presets.test.sh` cannot refuse it either.

## Acceptance

An assessor declaration states the closed list of values of an item field,
`spec/presets.test.sh` and `ratchet validate` refuse a `filter` of a plan that names a value
outside the list, and an evidence record with an item whose field holds another value is
refused when it is read; before the story `filter: {class: [diferent]}` passes both checks.

## Notes

- The story decides the form, declares it in `spec/` first, and writes it into
  `docs/evidence-format.md` § 9 in the same change. A field without a list of values stays
  open, as today.
- An addition to `ratchet-assessor/1`; a declaration that uses it is a new version of the
  declaration.
- The story is a draft. The check in `spec/presets.test.sh` needs no command and can land
  before 0.1.0; the checks of `ratchet validate` and of the evidence reader wait for them.
