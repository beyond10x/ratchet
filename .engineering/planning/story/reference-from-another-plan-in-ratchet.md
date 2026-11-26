---
format: aep.planning-md/3
id: story:reference-from-another-plan-in-ratchet
kind: story
status: draft
title: ratchet validate and reference adopt read a reference adopted from another plan
summary: 'The command part of story:reference-from-another-plan: the refusal with a code and the adoption from the named plan''s run.'
relations:
- decomposes: epic:preset-catalog
- depends_on: story:reference-from-another-plan
- depends_on: story:cli-skeleton-validate
- depends_on: story:reference-adopt-command
- depends_on: story:preset-binding-resolution
scope:
- confidence: inferred
  path: crates/ratchet-core
revision: 2
---
## Context

Split on 2026-11-26 from `story:reference-from-another-plan`, which adds
`adoption: {from: assessment, assessment, measurement}` to `spec/domains/specification.yaml`
and `docs/design.md` § 5, makes `spec/presets.test.sh` refuse an adoption from a measurement of
another value type in a preset, and gives `differential-equality@3` the requirement "the
candidate loses no case the reference implementation passes". This story holds the part that
needs the `ratchet` command.

## Acceptance

`ratchet validate` accepts a file whose requirement adopts its reference from another
assessment of the same specification, and refuses one whose adoption names no assessment of
the specification, or a measurement of another value type or unit, with a code that names the
rule; `ratchet reference adopt` on such a requirement writes the value of the named
measurement in the last qualifying run of the named plan on the trusted revision. Before the
story no command reads the form.

## Notes

- Moved from the acceptance of `story:reference-from-another-plan`, verbatim but for the code.
- The story is a draft. It waits for the waves to 0.1.0: `story:cli-skeleton-validate`,
  `story:reference-adopt-command`, and for a binding of `differential-equality@3`,
  `story:preset-binding-resolution`.
