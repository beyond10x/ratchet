---
format: aep.planning-md/3
id: story:example-release-quality
kind: story
status: draft
title: An example plan for the quality of a release
summary: 'examples/release-quality.ratchet.yaml: exact counts with better: lower under a gate that starts report-only.'
relations:
- decomposes: epic:runnable-cli
- depends_on: story:cli-skeleton-validate
scope:
- confidence: inferred
  path: CHANGELOG.md
- confidence: inferred
  path: docs/design.md
- confidence: inferred
  path: examples
- confidence: inferred
  path: examples/README.md
- confidence: inferred
  path: examples/release-quality.ratchet.yaml
revision: 7
---
## Context

A consumer reviews each release of a product and wants its review written as a `ratchet/1`
file: measurements that are exact counts where a lower value is better, and a gate that starts
report-only (2026-11-25, routed by the operator session of the workstation). It asks for an
example to copy, `examples/release-quality.ratchet.yaml`. Nothing of the consumer is named
here.

What the format says today: the direction of a measurement is the key `better` with the value
`lower` (`docs/design.md` § 3, the value list "Direction"), and a gate
entry with `mode: report` and `since` (`docs/design.md` § 3 and § 5;
`examples/ci-turnaround.ratchet.yaml`, the gate entry of `rust-test-step-budget`). The five
examples under `examples/` hold no plan whose subject is a release, and none whose
measurements are all exact counts under a gate that only reports.

What checks an example today: nothing reads a `ratchet/1` YAML file in the gate.
`story:preset-catalog-functional` builds the first check of such files
(`spec/presets.test.sh`), and `ratchet validate` is built by `story:cli-skeleton-validate`.

## Acceptance

`examples/release-quality.ratchet.yaml` declares a release as its subject, at least three
measurements that are exact counts with `better: lower`, a requirement on each against
an accepted reference, and a gate whose every entry has `mode: report`, and `ratchet validate
examples/release-quality.ratchet.yaml` exits 0; before the story the file does not exist.

## Scope

- `examples/release-quality.ratchet.yaml`, `examples/README.md`.
- `examples/`: the `ratchet-assessor/1` declaration of each assessor the example names.
- `docs/design.md`: one line where the examples are listed.
- `CHANGELOG.md`.

## Notes

- First consumer: the repository that reviews releases. The story is a draft behind the waves
  to 0.1.0; it needs `ratchet validate` (`story:cli-skeleton-validate`) for its acceptance. In
  its own change it adds the declaration of each assessor it names that has none in
  `examples/quality/assessors/` or `presets/`, and `spec/example-declarations.test.sh` of
  `story:example-assessor-declarations` checks it.
- The counts of the example are generic: open defects of the release, failed checks of its
  run, reverted changes since the release before. No name of a product or a tracker.
- A thing the example needs and the format cannot say is named in the report and filed as a
  draft of `epic:format-gaps-first-format-consumer`; the example gets no key the
  specification does not declare.
- How a record names the released version is decided by `story:record-series-git-ref`; the
  example uses the target kind that story settles, or `revision` until then.
