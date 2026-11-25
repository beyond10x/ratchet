---
format: aep.planning-md/3
id: story:preset-catalog-factory
kind: story
status: implemented
title: 'The preset catalog: build, artifact and code'
summary: Preset files, assessor declarations and pages for the three families read from a build and from the tree.
relations:
- decomposes: epic:preset-catalog
- depends_on: story:preset-catalog-functional
- depends_on: story:preset-catalog-runtime
scope:
- confidence: inferred
  path: AGENTS.md
- confidence: cited
  path: CHANGELOG.md
- confidence: cited
  path: presets
- confidence: inferred
  path: presets/README.md
- confidence: inferred
  path: spec/README.md
- confidence: inferred
  path: spec/presets.test.sh
- confidence: inferred
  path: website/docusaurus.config.ts
revision: 14
transitions:
- {from: "draft", to: "proposed", at: "2026-11-25T01:07:32Z", actor: "agent:ratchet", revision: 5}
- {from: "proposed", to: "active", at: "2026-11-25T01:09:50Z", actor: "agent:ratchet", revision: 6}
- {from: "active", to: "implemented", at: "2026-11-25T16:01:17Z", actor: "agent:ratchet", revision: 14, decided_on: {"recorded":{"test_result":1,"review_outcome":24}}}
---
## Context

`story:preset-catalog-functional` makes `presets/`, the file names and the check
`spec/presets.test.sh` with its row rule for every page. This story adds the three families
that are read from a build and from the tree, without a running service.

## Acceptance

`sh spec/presets.test.sh` exits 0 and its last line counts the preset files, the assessor
declarations and the measurements of the three families build, artifact and code, with one
row each on `presets/build.md`, `presets/artifact.md` and `presets/code.md`; before the story
those files are absent and the last line holds the counts of the five families before it.

## Scope

- `presets/`: the preset files and declarations of the three families, and the three pages.
  `presets/README.md` gains the three pages in its list.
- `spec/presets.test.sh`: a rule that a family of this story is the first to reach, with a
  defect that is refused with the message of the rule, as the second catalog story added
  three for sampled measurements. A broken copy keeps its fixed set of files.
- `spec/README.md`, `AGENTS.md`: the description of the script, where it changes.
- `website/docusaurus.config.ts`: the sentence that names the families the catalog holds.
- `CHANGELOG.md`: lines under `## [Unreleased]`.

## The three families

- **Build**: cold and warm build time, wall time of the test step, the slowest single test
  (durations, lower is better; the cache profile is a declared condition), and the flake rate
  over N runs (a rate, lower is better, N an input). The presets take the names
  `test-step-time@1` and `test-time@1` where they cover `research/candidate-presets.md` § 3.1
  and § 3.2.
- **Artifact**: container image size (bytes) and layer count, binary size (bytes), direct and
  transitive dependency counts, and the set of published advisories that apply to a
  dependency, one item per pair of an advisory and a package
  (`no_new_items` against the accepted set); lower is better.
- **Code**: generated and hand-written lines (counts with a direction the binding passes,
  because neither is better for every project), obligations a generator left (a set, no new
  item), lint findings (a set by rule id and location, no new item).

## Notes

- The durations and the flake rate are sampled: tolerance and runs are required inputs
  (`docs/design.md:102`, `:999`). The counts and sets are exact with the tolerance zero and no
  input for it. A size in bytes is exact with a tolerance input whose default is zero
  (`epic:preset-catalog` § "Rules of the catalog").
- A value against a reference implementation follows the rule
  `story:preset-catalog-functional` wrote into `docs/design.md` § 4.
- Evidence comes from the project's own tools: a build command, an image inspection, a
  lockfile or build graph, an advisory scanner's report, a line counter, a linter's report.
  Ratchet reimplements none (`AGENTS.md` § "Boundary").
- 0.1.0 judges the exact criteria of this story. The page marks each sampled criterion as
  declared and not yet judged by a release.
- The edge to `story:preset-catalog-runtime` records an order, not a need: both add lines to
  `CHANGELOG.md` under the same heading.
- A thing a family needs and `ratchet/1` cannot say is named on the page and reported; the
  format gets no key here.
- Every example is generic. POSIX sh, no Python. The test step ends within 120 s, no test
  over 60 s.
