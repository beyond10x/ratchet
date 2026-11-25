---
format: aep.planning-md/3
id: story:plan-conditions-from-binding
kind: story
status: draft
title: A binding passes the conditions of a plan
summary: The conditions of a plan are a map per class and no input type holds a map, so each preset fixes them.
relations:
- decomposes: epic:preset-catalog
- depends_on: story:preset-catalog-runtime
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

Point 3 of "Not expressible yet" on `presets/latency.md`, repeated on `presets/resources.md`
and `presets/start.md` (`story:preset-catalog-runtime`). First consumer: the catalog, and every
project that binds a preset with a sampled measurement.

Sampled evidence qualifies under the conditions its plan declares (`docs/design.md` § 3,
"Measurement kind and observation conditions"). A project may want a bound on the host load
for the class `local` and a runner for the class `ci`.
`ratchet.specification.ObservationPlan` holds `conditions` as a map from a class to its
conditions, and `ratchet.specification.InputType` has no type for a map: an input stands for a
scalar or a list of scalars (`spec/domains/specification.yaml`). So each preset of the four
families fixes the form, a `runner` in every class, and a project that needs another condition
copies the preset.

## Acceptance

A binding passes the conditions of a plan of its preset per class, `ratchet validate` accepts a
preset that takes them from an input and refuses a binding whose value is no map from a class
to conditions, and `operation-time@1` in a new version takes its conditions from the binding;
before the story a preset writes its conditions out and a binding cannot change them.

## Notes

- The story decides the form (an input type for a map, or a member of the binding beside
  `inputs`), declares it in `spec/` first and writes it into `docs/design.md` in the same
  change.
- An addition to a released format; a preset that uses it is a new version of the preset.
- The story is a draft. It waits for the waves to 0.1.0 and for
  `story:preset-binding-resolution`.
