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
- confidence: cited
  path: CHANGELOG.md
- confidence: cited
  path: docs/design.md
- confidence: cited
  path: presets/latency.md
- confidence: inferred
  path: presets/operation-time@2.preset.yaml
- confidence: cited
  path: spec/domains/specification.yaml
revision: 14
---
## Context

Point 5 of "Not expressible yet" on `presets/latency.md` (`:267-271`,
`story:preset-catalog-runtime`). First consumer: the catalog, and every project that binds
`operation-time@1`, `event-time@1` or `workload-throughput@1`.

A run in which requests fail should not qualify for a timing: the failed requests are often
the fast or the slow ones.

At `7b01ea1`:

- `ratchet.specification.CoverageBounds` bounds `executed`, `skipped`, `not_run` and
  `unsupported` and holds `executed_ids`, and has no bound for `failed`
  (`spec/domains/specification.yaml:326-343`). `docs/design.md` § 3 "Evidence coverage" says
  "four count keys" (`:160`) and that a run below the plan's coverage is insufficient evidence
  (`:154`).
- The record counts `failed` already (`ratchet.evidence.EvidenceCoverage.failed`,
  `spec/domains/evidence.yaml:257-259`), and `timing-report@1` lists `failed` under `coverage`
  (`presets/timing-report@1.assessor.yaml`, `coverage: [executed, not_run, passed, failed]`).
- `operation-time@1` bounds `not_run` only (`presets/operation-time@1.preset.yaml:38`). The
  presets leave a failed request out of the samples, and a project judges the failures with
  `conformance-cases@1`, in another plan and another run.

Decision taken (reversible, `AGENTS.md` § "Phase: implementation"): the bound is a member of
`CoverageBounds`, `failed: Optional<MaximumBound>`, written `{max: 0}` like the other
maximums, a number of units and not a share. A run over it is insufficient evidence with the
cause `coverage_below_plan`, as every other coverage bound (`docs/design.md:154`;
`ratchet.gate.InsufficientEvidenceCause`, `spec/domains/gate.yaml:53-69`): the failures say
nothing about the timing, and the failures themselves are judged by a requirement of their
own. A bound on the share of failed units is not built; it is named in the design as a later
addition.

## Acceptance

Every outcome below is observable without a `ratchet` command.

1. `spec/domains/specification.yaml`: `CoverageBounds` (`:326-343`) holds
   `failed: Optional<ratchet.specification.MaximumBound>`, and its summary says that a run over
   it is insufficient evidence with the cause `coverage_below_plan`. Checked by
   `ess specify validate --path spec --strict-requires`, which exits 0, and by
   `task check:generated`.
2. `docs/design.md` § 3 "Evidence coverage" (`:160`): five count keys, `failed` a maximum
   beside `skipped`, `not_run` and `unsupported`, with the reason (a failed unit of a timing
   run is often the fast or the slow one) and the sentence that a share of failed units is not
   a bound yet. Text only, no case.
3. `presets/operation-time@2.preset.yaml` (new) is `operation-time@1` with the required input
   `failed_requests_max` (integer) and the bound `failed: {max: "${inputs.failed_requests_max}"}`
   in its `coverage`; `operation-time@1` stays byte for byte. `presets/latency.md` has the
   section `operation-time@2`, its input row and the rows of
   `operation-time@2/operations/p50`, `p95` and `p99`, and its point 5 (`:267-271`) says that
   the bound answers it from `operation-time@2` on. Checked by `spec/presets.test.sh`, rules
   `place`, `type`, `inputs` and `row`: before the story a preset with `failed` under
   `coverage` is refused (rule `place`), after it its last line counts one more file and three
   more measurements with a row.
4. `CHANGELOG.md` has its line under `## [Unreleased]`, in the form
   `.github/scripts/release.test.sh` checks.

## Notes

- An addition to a released format; a preset that uses it is a new version of the preset.
- `operation-time@2` is unreleased until 0.0.5: 21 (`story:plan-conditions-from-binding`) of
  the same wave adds its conditions from the binding to this same `@2` and makes no `@3`.
- `event-time@1` and `workload-throughput@1` get the bound in a version of their own when a
  consumer asks; this story makes one preset to show it.
- The parts that need the command are `story:coverage-bound-on-failed-units-in-ratchet`:
  `ratchet evaluate --gate` not judging a requirement of a plan whose run is over the bound,
  and naming the bound and the count. It waits for the waves to 0.1.0.
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of `.engineering/waves/0.1.0-ahead-2.md`,
  into one wave built in sequence on one branch: every planned wave starts behind
  `story:cli-skeleton-validate`, which waits for a release of ESS (beyond10x/ess#836), and this
  part needs no `ratchet` command. It is 16 of the 33 in the order of that page.
- 15 (`story:coverage-count-with-reference`) changes `docs/design.md:162` before it, the
  paragraph after `:160`; 17 (`story:assertion-required-items`) changes the coverage of
  `health-readiness` in a version of its own after it.
- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s.
