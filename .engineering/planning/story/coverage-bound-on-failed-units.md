---
format: aep.planning-md/3
id: story:coverage-bound-on-failed-units
kind: story
status: implemented
title: A plan bounds the failed units of its run
summary: CoverageBounds has no bound for failed, so a run with failed requests qualifies for a timing.
relations:
- decomposes: epic:preset-catalog
- depends_on: story:preset-catalog-runtime
scope:
- confidence: cited
  path: docs/design.md
- confidence: cited
  path: presets/latency.md
- confidence: inferred
  path: presets/operation-time@2.preset.yaml
- confidence: cited
  path: spec/domains/specification.yaml
revision: 20
transitions:
- {from: "draft", to: "proposed", at: "2026-11-26T21:04:22Z", actor: "human:operator", revision: 18, decided_on: {"recorded":{"review_outcome":4}}}
- {from: "proposed", to: "active", at: "2026-11-26T21:04:22Z", actor: "human:operator", revision: 19, decided_on: {"recorded":{"review_outcome":4}}}
- {from: "active", to: "implemented", at: "2026-11-26T23:39:02Z", actor: "human:operator", revision: 20, decided_on: {"recorded":{"test_result":1,"review_outcome":4}}}
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

A phrase with a space in it may wrap in a Markdown paragraph or a folded YAML summary. So where
an item says that `grep -F` finds such a phrase in a `.md` or `.yaml` file, that it finds
nothing or the phrase is gone, or that `grep -c` of it prints a count, the check reads the
joined text of the file: `tr -s '\n ' '  ' < <file> | grep -o -F '<phrase>' | wc -l` prints 1
where the item says it is found, 0 where it says nothing or gone, and the count where it names
one. A name without a space, a row of a table, a pattern with `^`, `$` or `-E`, a check that
prints the line it matches and a check that reads the output of another command read the file
line by line, as written.

1. `spec/domains/specification.yaml`: `ratchet.specification.CoverageBounds` holds
   `failed: Optional<ratchet.specification.MaximumBound>`: `grep -c 'name: failed$'
   spec/domains/specification.yaml` prints 1 (0 before), and `ess specify validate --path
   spec --strict-requires` exits 0.
2. The summary of `CoverageBounds` holds the phrase "a run over `failed` is insufficient
   evidence with the cause `coverage_below_plan`": `grep -F` finds it in
   `spec/domains/specification.yaml`, nothing before.
3. `docs/design.md` § 3 "Evidence coverage": the paragraph of the count keys says "five count
   keys" and names `failed` a maximum beside `skipped`, `not_run` and `unsupported`: `grep -cF
   'has five count keys' docs/design.md` prints 1, and `grep -cF 'has four count keys'` prints
   0 (1 before).
4. The same paragraph holds the reason, the phrase "a failed unit of a timing run is often the
   fast or the slow one": `grep -F` finds it, nothing before.
5. The same paragraph holds the phrase "a share of failed units is not a bound yet": `grep -F`
   finds it, nothing before.
6. `presets/operation-time@2.preset.yaml` exists: `operation-time@1` with the required input
   `failed_requests_max` (integer) and the bound `failed: {max: "${inputs.failed_requests_max}"}`
   in its `coverage`. `sh spec/presets.test.sh` exits 0 with the file in the catalog; before
   the story the same file is refused there by the rule `place` (`failed` is no field of
   `CoverageBounds`). `operation-time@1` stays byte for byte (`git diff --quiet 7b01ea1 --
   presets/operation-time@1.preset.yaml` exits 0).
7. `presets/latency.md` has the section `operation-time@2` with its input row and the rows of
   `operation-time@2/operations/p50`, `p95` and `p99`: `grep -c '`operation-time@2/operations/'
   presets/latency.md` prints 3 (0 before).
8. `presets/latency.md`, "Not expressible yet", point 5, rewritten in place, holds the phrase
   "Answered from `operation-time@2` on": `grep -F` finds it, nothing before.

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
- 15 (`story:coverage-count-with-reference`) changes the paragraph after the one of the count
  keys before it; 17 (`story:assertion-required-items`) bounds the items of a measurement of
  `health-readiness` in a version of its own after it.
- `spec/presets.test.sh` is not changed: it reads the new preset and page as it reads every
  file of the catalog.
- The line of the wave's changelog: under `### Added`, naming `operation-time@2` (written by
  the story that closes the wave, `AGENTS.md` § "Changelog lines").
- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s.
