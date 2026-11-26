---
format: aep.planning-md/3
id: epic:preset-catalog
kind: epic
status: draft
title: A standard catalog of quality criteria as ratchet/1 presets
summary: presets/ with the preset files and assessor declarations of eight families, a page per family, a check in the gate, and binding resolution.
relations:
- decomposes: initiative:first-milestone
revision: 3
---
## Context

The owner ordered a standard catalog of quality criteria in this repository, as `ratchet/1`
presets (2026-11-24, relayed by the session of the catalog's first consumer), so that every
project rates against the same catalog and binds it instead of copying it.

The first consumer is a private repository that compares two implementations of one backend
service: a reference implementation and a candidate generated from a specification. Both run
under the same synthesized conformance suite while their metrics are observed. Nothing of that
repository is named here, and every example in the catalog is generic.

The design has the preset (`docs/design.md` § 4; `ratchet.specification.Preset`,
`spec/domains/specification.yaml:1106`), the binding (`use`, `digest`, `with`) and the catalog
source (`ratchet.config.CatalogSource`, `spec/domains/config.yaml:38`). The directory `presets/`
does not exist (`docs/design.md:684`), and `research/candidate-presets.md` holds 15 candidates
as expansions, none of them a preset file.

## The criteria the first consumer needs

Eight families:

1. **Functional.** Conformance scenarios passed, failed, skipped and refused. Differential
   equality against a reference implementation: equal, allowed, different. The size of the
   known-failure list.
2. **Latency and throughput** under a fixed functional workload, which is no load test: p50,
   p95 and p99 per route or operation, and the time from a request to the event it causes.
3. **Resources** while that workload runs: peak and steady resident memory, CPU seconds per
   1000 requests, open file descriptors, threads.
4. **Start and readiness.** Process start to ready, ready to first answer.
5. **Build.** Cold and warm build time, wall time of the test step, the slowest single test,
   the flake rate over N runs.
6. **Artifact.** Container image size and layer count, binary size, direct and transitive
   dependency counts, dependencies with known advisories.
7. **Code.** Generated and hand-written lines, obligations a generator left, lint findings.
8. **Operability.** The documented metric names a scrape exposes; health and readiness
   behaviour.

`story:production-gate-spec-executed-service` extends the catalog with a ninth family: probe
assertions and artifact verification of a spec-executed service, with the example
`examples/production-gate.ratchet.yaml`.

For each criterion the consumer asks for: the direction (lower or higher is better), the unit,
a default tolerance where one makes sense, how the evidence is produced (an assessor that runs
a command, or an imported report), and how a value that only means something against a
reference implementation is expressed.

## Outcome

`presets/` in this repository holds the preset files of the eight families and the
`ratchet-assessor/1` declarations they name. A catalog page per family states, per criterion,
the direction, the unit, the tolerance input with its default or the sentence that it has
none, and the source of the evidence. The gate checks every preset file and every declaration
against the specification, and that each measurement of a preset has its row on the page of
its family with those four cells filled, so a renamed field or a criterion without a row fails
the gate. A project binds a preset by name, version and digest, and `ratchet validate`
resolves the binding from a directory. `story:production-gate-spec-executed-service` adds a
ninth family, probe assertions and artifact verification of a spec-executed service, and the
example `examples/production-gate.ratchet.yaml`.

## Rules of the catalog

- A preset is what `docs/design.md` § 4 says: a `ratchet/1` document with a `preset` block,
  declared inputs, no gate, no exception, and no local input.
- **Tolerance.** An exact value (a count, a size in bytes, an identity set) has the tolerance
  zero. A count and a set have no input for it. A size may have a tolerance input with the
  default zero, for a project that accepts a small rise. A sampled value (a duration, memory,
  a rate) has no default tolerance: the format ships none (`docs/design.md:102`, `:999`), so
  the preset declares the tolerance as a required input and the catalog page says so.
- **A value against a reference implementation.** A requirement compares a measurement with a
  fixed limit or a protected reference and not with another measurement. The catalog expresses
  candidate against reference implementation with what `ratchet/1` has: the reference
  implementation's values are the protected reference, adopted under the same declared
  conditions. What that cannot say is named in the catalog page and filed as a draft story;
  the catalog adds no key to the format on its own.
- **Names.** A preset that covers a candidate of `research/candidate-presets.md` takes that
  candidate's name (`conformance-cases@1`, `operation-time@1`, `test-time@1`).
- **Evidence.** A preset names an assessor that runs a project command or imports a report
  (`docs/design.md` § 4 "Custom assessors"). Ratchet reimplements no tool (`AGENTS.md`
  § "Boundary"): no load runner, no scanner, no profiler.
- Nothing private: no name of a consumer, a product or a customer, in a file or in an example.

## Stories

- `story:preset-catalog-functional`: the layout of `presets/`, the file names, the body of a
  preset in the specification, the check in the gate with the row rule for every page, and the
  functional family. The consumer lists this family first.
- `story:preset-catalog-runtime`: latency and throughput, resources, start and readiness,
  operability.
- `story:preset-catalog-factory`: build, artifact, code.
- `story:preset-binding-resolution`: `ratchet validate` resolves a binding from a path source.
  After 0.1.0. A `git` source is a later story, filed when a consumer needs it; until then a
  consumer reads the catalog from a checkout of this repository at a commit.

The wave of `.engineering/waves/0.1.0-ahead-1.md`, chosen by the owner on 2026-11-26, takes
five later stories of this epic ahead of the waves to 0.1.0: `story:cache-condition-one-name`,
`story:preset-check-unlisted-forms`, `story:value-over-all-runs`, `story:item-field-values` and
`story:production-gate-spec-executed-service`. The parts of three of them that need a `ratchet`
command are `story:cache-condition-one-name-in-ratchet`, `story:value-over-all-runs-in-ratchet`
and `story:item-field-values-in-ratchet`, which wait for the waves to 0.1.0.

## Order

The epic is beside the waves to 0.1.0. It changes the content of none of their stories. The
three catalog stories are YAML files, pages and one script test; they need no command of
`ratchet` and no answer to the open question about the generated model crate.

The four stories run one after another: functional, runtime, factory, binding resolution. The
edges record it: each shares `CHANGELOG.md` with the one before, and the last two share
`presets/README.md`.

Files this epic shares with the waves to 0.1.0:

- `CHANGELOG.md` does not exist until `story:changelog-release-procedure` is merged;
  `story:preset-catalog-functional` depends on it. `story:release-0-1-0` cuts the section
  `## [Unreleased]` as it then stands, with or without lines of this epic.
- `Taskfile.yml` (one command in `check:spec`) and the table of `AGENTS.md` § "Ownership"
  (one row) are also edited by `story:cli-skeleton-validate` and `story:acceptance-in-gate`.
  A catalog story is therefore started between two waves, from the `main` of that moment, and
  never beside a wave that edits one of these files.
- `spec/domains/specification.yaml` and `spec/domains/config.yaml`: `story:cli-skeleton-validate`
  generates a model crate from the domains. Whichever of the two lands second runs
  `task generate` in its change.

`story:preset-binding-resolution` needs `ratchet validate` and follows `story:release-0-1-0`.

## What 0.1.0 evaluates of it

0.1.0 judges exact numbers and identity sets with an absolute or percent tolerance
(`ROADMAP.md` § "Releases"). Of the catalog that is every count, size and set: scenario counts
and the set of passing cases, the known-failure list, image and binary size, layer and
dependency counts, the set of advisories, lines, obligations, lint findings, metric names. A
sampled value (latency, memory, CPU, start time, build time, flake rate) is declared in the
catalog and is judged by a later release. Until `story:preset-binding-resolution` a binding is
valid `ratchet/1` that no command resolves.

## Done when

The four stories are implemented. `presets/README.md` says what a project writes before
`ratchet validate` resolves a binding (`story:preset-catalog-functional`). Telling the first
consumer the path and commit of the catalog and which part 0.1.0 evaluates is the
coordinator's act after each catalog story is merged; it is no story.
