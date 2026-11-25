---
format: aep.planning-md/3
id: story:member-for-some-input-values
kind: story
status: draft
title: A preset leaves a member out for some values of an input
summary: 'A reference to an input stands for a value and no key, so a preset declares an aggregation for runs: 1 too.'
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

Point 4 of "Not expressible yet" on `presets/latency.md`, repeated on `presets/resources.md`
and `presets/start.md` (`story:preset-catalog-runtime`). First consumer: the catalog.

`ratchet.specification.Measurement` says of `aggregation` that it is absent with `runs: 1`,
and a plan declares `paired` or leaves it out. `ratchet.specification.InputReference` stands
for a value and for no key (`spec/domains/specification.yaml`), so a preset cannot leave a
member out when the binding passes `runs: 1`. `workload-throughput@1`, `process-resources@1`
and `start-time@1` therefore always declare the median of the runs, also for `runs: 1`, where
the type says that `aggregation` is absent.

## Acceptance

A preset states that a member of a plan or a measurement is there for some values of an input,
`ratchet validate` resolves a binding of `workload-throughput@1` with `runs: 1` to a
measurement without `aggregation` and one with `runs: 3` to the median, and refuses a preset
whose condition names an input it does not declare; before the story the preset declares the
aggregation for every value of `runs`.

## Notes

- The story first answers whether the format needs this at all: the other answer is that a
  sampled measurement of the catalog requires at least two runs, stated on the pages and
  checked by `spec/presets.test.sh`. It writes the answer into `docs/design.md`.
- An addition to a released format if it is built; a preset that uses it is a new version.
- The story is a draft. It waits for the waves to 0.1.0 and for
  `story:preset-binding-resolution`.
