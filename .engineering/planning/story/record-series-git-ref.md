---
format: aep.planning-md/3
id: story:record-series-git-ref
kind: story
status: draft
title: A command appends records to the series on refs/ratchet/records
summary: 'One record per released version on the git ref: the command, the layout of the ref and how a record names a release.'
relations:
- decomposes: epic:observe-adopt-reject
- depends_on: story:evidence-reader
- depends_on: story:cli-skeleton-validate
scope:
- confidence: inferred
  path: CHANGELOG.md
- confidence: inferred
  path: crates
- confidence: inferred
  path: docs/design.md
- confidence: inferred
  path: docs/evidence-format.md
- confidence: inferred
  path: spec/cli.yaml
- confidence: inferred
  path: spec/domains/cli.yaml
- confidence: inferred
  path: spec/domains/config.yaml
revision: 8
---
## Context

A consumer reviews each release of a product and wants the numbers of that review kept as a
series: one record per released version, on the git ref `refs/ratchet/records` (2026-11-25,
routed by the operator session of the workstation). Nothing of the consumer is named here.

What exists: the specification declares the record store in two parts
(`spec/domains/config.yaml`, entity `ratchet.config.RecordStore`; `docs/design.md` § 6). A run
hands its records over as a CI artifact, and one job on the trusted branch appends them to the
git ref `refs/ratchet/records`; it is the only writer, and gates, views and `ratchet history`
read the ref.

What is missing:

- No command of `spec/cli.yaml` appends to the ref. The 16 commands write the local record
  directory (`assess`, `import`) or read (`history`, `status`, `diff`). The design names the
  writer as "one job" and no command the job runs.
- No accepted story builds the series. `story:evidence-reader` builds the local record
  directory, and 0.1.0 reads records from there.
- A released version as the thing a record is about. The target kinds are `revision`, `build`,
  `deployment`, `workflow_run`, `telemetry_population` and `document`
  (`spec/domains/specification.yaml`, `ratchet.specification.TargetKind`). Whether a release
  is a `build` with its version, or a `revision` at a tag, is not said, and neither is what
  refuses a second record for the same version.

## Acceptance

A command declared in `spec/cli.yaml` appends the records of a local record directory to the
series on `refs/ratchet/records` of a repository, `ratchet history` lists one run per released
version from that ref in the order of the versions, and a second append of the same record
changes nothing; before the story no command writes the ref and `ratchet history` reads the
local record directory alone.

## Scope

- `spec/cli.yaml`, `spec/domains/cli.yaml`: the command, its input, result and refusals,
  declared and validated before code uses it.
- `spec/domains/config.yaml`, `docs/design.md` § 3 and § 6: the layout of the ref, the
  identity of a record on it, and how a record names a released version.
- `crates/`: the writer and the reader of the ref.
- `docs/evidence-format.md`, `CHANGELOG.md`.

## Notes

- First consumer: the repository that reviews releases. The story is a draft behind the waves
  to 0.1.0; it builds on `story:evidence-reader` (the record id and the local record
  directory) and `story:cli-skeleton-validate`.
- Decisions the story takes: the name of the command (the design leaves it open); the layout
  of the commits on the ref; what a concurrent append does. The push right of the writer, the
  author of its commits and any retention are the owner's to set
  (`spec/domains/config.yaml`, `ratchet.config.RecordStore`).
- Ratchet reimplements no tool: it writes the ref with git and reads no forge API.
- No Python. The test step ends within 120 s, no test over 60 s; a test of the ref runs on a
  repository the test creates on disk and reaches no network.
