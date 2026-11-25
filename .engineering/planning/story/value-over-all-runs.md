---
format: aep.planning-md/3
id: story:value-over-all-runs
kind: story
status: draft
title: A sampled measurement states a value computed over all runs
summary: No aggregation kind gives one value over all runs, so flake-rate@1 declares none with runs above 1.
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

The entry "A value over the runs that no aggregation of the format gives" under "Not
expressible yet" on `presets/build.md` (`story:preset-catalog-factory`). First consumer: the
catalog, and every project that binds `flake-rate@1`.

`ratchet.specification.AggregationKind` has `sum`, `median`, `percentile`, `best_of_n` and
`pass_rate` (`spec/domains/specification.yaml`). The flake rate is one value over all runs of
a report: the share of tests that passed in one run and failed in another. It is no median of
a value per run, and `pass_rate` aggregates an assertion. So `flake-rate@1` declares no
`aggregation`, also where `runs` is above 1, though `ratchet.specification.Aggregation` says
that one is declared where a sampled plan has more than one run or sample.

## Acceptance

A sampled measurement states that its value is computed over all runs of its plan by the
assessor, `ratchet validate` accepts it with `runs` above 1 and refuses a measurement with
`runs` above 1 that states neither this nor an aggregation, and `flake-rate@1` in a new
version states it; before the story the preset leaves `aggregation` out and no rule says
whether that is valid.

## Notes

- The story first answers whether `validate` reports a sampled measurement with more than one
  run and no aggregation today (`docs/design.md` § 3), and writes the answer into the design.
- It decides the form (a kind of `AggregationKind`, or a member of the measurement), declares
  it in `spec/` first and says what the evidence carries as the count of samples.
- An addition to a released format; a preset that uses it is a new version of the preset.
- The story is a draft. It waits for the waves to 0.1.0 and for `ratchet evaluate`.
