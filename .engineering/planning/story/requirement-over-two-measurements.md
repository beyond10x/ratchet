---
format: aep.planning-md/3
id: story:requirement-over-two-measurements
kind: story
status: draft
title: A requirement compares two measurements
summary: A subset between two identity sets and a comparison of two numbers of one unit, for the known-failure list and the reference implementation.
relations:
- decomposes: epic:preset-catalog
- depends_on: story:preset-catalog-functional
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

The second of three things `presets/functional.md` lists under "Not expressible yet"
(`story:preset-catalog-functional`). First consumer: the catalog, and every project that binds
`known-failures@1` or `differential-equality@1`.

Two requirements of the functional family read two measurements: "every failed case is on the
known-failure list" (the set of failed cases is a subset of the listed set) and "the candidate
passes no fewer cases than the reference implementation" (one count against another).
`ratchet.specification.QualityRequirement` names one `assessment` and one `measurement`,
`ratchet.specification.Condition.value` is a `Decimal`, and
`ratchet.specification.ComparisonOperator` has no operator between two sets
(`spec/domains/specification.yaml`). A requirement compares one measurement with a number or
with its own reference.

## Acceptance

A requirement of a `ratchet/1` file compares one measurement with another measurement of the
same specification, for two identity sets (subset) and for two numbers of one unit,
`ratchet validate` accepts the file and refuses a comparison across two value types or two
units, and `known-failures@1` gains the requirement "every failed case is listed" with its
row; before the story the form is refused and the page lists both requirements under "Not
expressible yet".

## Notes

- The story decides the form and the operators, declares them in `spec/` first, and writes
  them into `docs/design.md` § 3 in the same change. What the verdict names as evidence when
  two runs are read is part of it (`docs/evidence-format.md`).
- An addition to a released format; a preset that uses it is a new version of the preset.
- The story is a draft. It waits for the waves to 0.1.0 and for `ratchet evaluate`.
