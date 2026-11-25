---
format: aep.planning-md/3
id: story:preset-catalog-runtime
kind: story
status: proposed
title: 'The preset catalog: latency, resources, start and operability'
summary: Preset files, assessor declarations and pages for the four families observed while a fixed workload runs.
relations:
- decomposes: epic:preset-catalog
- depends_on: story:preset-catalog-functional
scope:
- confidence: cited
  path: CHANGELOG.md
- confidence: cited
  path: presets
revision: 7
transitions:
- {from: "draft", to: "proposed", at: "2026-11-25T01:07:32Z", actor: "agent:ratchet", revision: 7}
---
## Context

`story:preset-catalog-functional` makes `presets/`, the file names and the check
`spec/presets.test.sh` with its row rule for every page. This story adds the four families
that are observed while a fixed functional workload runs against a started service.

## Acceptance

`sh spec/presets.test.sh` exits 0 and its last line counts the preset files, the assessor
declarations and the measurements of the four families latency and throughput, resources,
start and readiness, and operability, with one row each on `presets/latency.md`,
`presets/resources.md`, `presets/start.md` and `presets/operability.md`; before the story
those files are absent and the last line holds the counts of the functional family alone.

## Scope

- `presets/`: the preset files and declarations of the four families, and the four pages.
  `presets/README.md` and `spec/presets.test.sh` are not edited: the script reads every file
  of the directory.
- `CHANGELOG.md`: lines under `## [Unreleased]`.

## The four families

- **Latency and throughput**, under a fixed functional workload that is no load test: p50, p95
  and p99 per operation (`aggregation: {kind: percentile, parameter: <n>}`, scope operation,
  unit `ms` or `s`, lower is better), and the time from a request to the event it causes (a
  duration with a declared boundary). The preset takes the name `operation-time@1` where it
  covers `research/candidate-presets.md` § 3.8. Requests per second of the same run, higher is
  better.
- **Resources** while the workload runs: peak and steady resident memory (bytes), CPU seconds
  per 1000 requests, open file descriptors, threads; lower is better.
- **Start and readiness**: process start to ready, ready to first answer; durations with
  declared boundaries, lower is better.
- **Operability**: the set of documented metric names a scrape exposes (`no_lost_items`
  against the accepted set, and no name outside the documented list), and assertions on the
  health and readiness answers (`holds`).

## Notes

- Every duration, memory value and rate here is sampled. It has no default tolerance
  (`docs/design.md:102`, `:999`): the tolerance, the number of runs and the workload are
  required inputs, and the page says so in one sentence per family.
- The workload is an input: a path or a name of the project's own workload. Ratchet ships no
  workload and no load runner (`AGENTS.md` § "Boundary").
- A value against a reference implementation follows the rule
  `story:preset-catalog-functional` wrote into `docs/design.md` § 4.
- 0.1.0 judges the exact criteria of this story (the metric names). The page marks each
  sampled criterion as declared and not yet judged by a release.
- A thing a family needs and `ratchet/1` cannot say is named on the page and reported; the
  format gets no key here.
- Every example is generic. POSIX sh, no Python. The test step ends within 120 s, no test
  over 60 s.
