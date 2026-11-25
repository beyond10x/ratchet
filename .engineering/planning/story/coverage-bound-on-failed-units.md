---
format: aep.planning-md/3
id: story:coverage-bound-on-failed-units
kind: story
status: draft
title: A plan bounds the failed units of its run
summary: CoverageBounds has no bound for failed, so a run with failed requests qualifies for a timing.
relations:
- decomposes: epic:preset-catalog
- depends_on: story:preset-catalog-runtime
scope:
- confidence: inferred
  path: CHANGELOG.md
- confidence: inferred
  path: docs/design.md
- confidence: inferred
  path: docs/evidence-format.md
- confidence: inferred
  path: presets
- confidence: inferred
  path: spec/domains/specification.yaml
revision: 6
---
## Context

Point 5 of "Not expressible yet" on `presets/latency.md` (`story:preset-catalog-runtime`).
First consumer: the catalog, and every project that binds `operation-time@1`, `event-time@1`
or `workload-throughput@1`.

A run in which requests fail should not qualify for a timing: the failed requests are often
the fast or the slow ones. `ratchet.specification.CoverageBounds` bounds `executed`,
`skipped`, `not_run` and `unsupported` and has no bound for `failed`
(`spec/domains/specification.yaml`). The presets leave a failed request out of the samples,
and a project judges the failures with `conformance-cases@1`, in another plan and another
run.

## Acceptance

A plan bounds the number or the share of failed units of its run, `ratchet evaluate` does not
judge a requirement of a plan whose run is over the bound and names the bound and the count in
the verdict, and `operation-time@1` in a new version takes the bound as a required input;
before the story a run with any number of failed requests qualifies.

## Notes

- The story decides whether the bound is a member of `CoverageBounds` or a condition of the
  plan, and what the verdict of an unqualified run is; it declares the form in `spec/` first
  and writes it into `docs/design.md` and `docs/evidence-format.md` in the same change.
- Related and not the same: `story:coverage-count-lower-bound` and
  `story:coverage-count-with-reference` of `epic:format-gaps-first-format-consumer`.
- An addition to a released format; a preset that uses it is a new version of the preset.
- The story is a draft. It waits for the waves to 0.1.0 and for `ratchet evaluate`.
