---
format: aep.planning-md/3
id: story:preset-catalog-functional
kind: story
status: active
title: 'The preset catalog: layout, the check in the gate and the functional family'
summary: presets/ with file names declared in the specification, spec/presets.test.sh in check:spec, and the presets for conformance, differential equality and the known-failure list.
relations:
- decomposes: epic:preset-catalog
- depends_on: story:changelog-release-procedure
scope:
- confidence: cited
  path: .github/workflows/pages.yml
- confidence: cited
  path: AGENTS.md
- confidence: cited
  path: CHANGELOG.md
- confidence: cited
  path: Taskfile.yml
- confidence: inferred
  path: crates/ratchet-cli-contract
- confidence: inferred
  path: crates/ratchet-model
- confidence: cited
  path: docs/design.md
- confidence: cited
  path: presets
- confidence: cited
  path: spec/README.md
- confidence: cited
  path: spec/domains/config.yaml
- confidence: cited
  path: spec/domains/specification.yaml
- confidence: cited
  path: spec/presets.test.sh
revision: 16
transitions:
- {from: "draft", to: "proposed", at: "2026-11-25T01:07:31Z", actor: "agent:ratchet", revision: 15}
- {from: "proposed", to: "active", at: "2026-11-25T01:09:50Z", actor: "agent:ratchet", revision: 16}
---
## Context

`epic:preset-catalog` promises `presets/` with the preset files of eight families. This story
makes the directory, decides what a file in it is called, declares the body of a preset,
builds the check of the gate, and delivers the first family, which the first consumer lists
first: functional.

What exists: the entity `ratchet.specification.Preset` with a name, a version and inputs
(`spec/domains/specification.yaml:1106-1131`), the binding (`:1133`), the catalog source
(`spec/domains/config.yaml:38`), and the rule that an assessor declaration is the file
`<name>@<version>.assessor.yaml` in a source. The statements, assessments and requirements of
a preset are named in the summary of the entity only: no field declares them. No rule names
the file of a preset. The script tests under `spec/` check JSON records against the
specification (`spec/record-examples.test.sh`); nothing checks a `ratchet/1` YAML file.

## Acceptance

`sh spec/presets.test.sh`, a command of `task check:spec`, exits 0 on the files of the
functional family (at least the presets `conformance-cases@1` and `differential-equality@1`,
the assessor declarations they name, and the page `presets/functional.md`), prints as its
last line `presets: <f> of <f> file(s) valid, <r> of <r> measurement(s) with a row,
<c> of <c> broken copies refused`, and exits 1 when one of its broken copies is accepted;
before the story the script and `presets/` are absent.

## Scope

- `spec/domains/specification.yaml`, `spec/domains/config.yaml`, `spec/README.md`, declared
  before a file uses them: the file name of a preset in a source; and the body of a preset,
  which is the statements, assessments and requirements of a project by the same types, with
  no gate, no exception and no binding of its own.
- `presets/` (new): the preset files of the functional family and the `ratchet-assessor/1`
  declarations they name; `presets/README.md` (what the catalog is, the rules of
  `epic:preset-catalog`, how a project binds a preset, what a project writes before
  `ratchet validate` resolves a binding, and that every other `*.md` in the directory is the
  page of one family); `presets/functional.md` (the page of the family).
- `spec/presets.test.sh` (new). What it checks in every file under `presets/`:
  - a preset file and a declaration hold only keys the specification declares at that place,
    and only values of a closed list where the list is closed;
  - a preset holds no gate, no exception and no local input, and refers to no input
    (`${inputs.<name>}`) it does not declare;
  - every assessor a preset names has its declaration in the directory, and every measurement
    names an output, a unit and a scope the declaration declares;
  - every measurement of a preset has one row on the page of its family, and the four cells
    of the row (direction, unit, tolerance, source of the evidence) are not empty; a row that
    names no measurement of a preset fails.
  One broken copy per rule; the script fails when a copy is accepted. It reads YAML with the
  tools the gate already needs; where it needs one more tool, the tool is pinned by version
  and digest in the job `gate` of `pages.yml` in the same change.
- `Taskfile.yml`: the script as one command of `check:spec`.
- `.github/workflows/pages.yml`: every file under `presets/`, a `*.md` page included, is a
  change the job `gate` runs `task check:spec` for; two cases in `task check:ci-paths`, a YAML
  file and a page, and one for a `*.md` outside `presets/` that stays `planning`.
- `docs/design.md` § 4, § 5: the file name; the body of a preset; how candidate against
  reference implementation is expressed; `presets/` exists.
- `AGENTS.md`: one row for `presets/` in § "Ownership".
- `CHANGELOG.md`: lines under `## [Unreleased]`.
- `crates/ratchet-cli-contract/` (inferred): no type the command surface reads changes, so
  `task check:generated` stays green without a regeneration. Where it does not, `task generate`
  runs in the same change.

## The functional family

Criteria, each with direction, unit, tolerance and evidence source on the page:

- Conformance scenarios: the set of passing cases by case id (`no_lost_items` against the
  accepted set) and the counts passed, failed, skipped and refused. The preset takes the name
  `conformance-cases@1` (`research/candidate-presets.md` § 3.5). Evidence: an imported
  conformance report.
- Differential equality against a reference implementation: per case one of equal, allowed,
  different. The set of cases that differ gains no item, and the count of them has a limit the
  binding passes. The preset is `differential-equality@1`. Evidence: an imported comparison
  report with a case id and a class per case.
- The known-failure list: its size does not rise, and it gains no item. It is a third preset
  or part of `conformance-cases@1`; the story decides.

## Notes

- Decisions this story takes and writes into the design: the file name of a preset (proposal:
  `<name>@<version>.preset.yaml`, beside `<name>@<version>.assessor.yaml`); the names of the
  inputs; how a page names the measurement of a row; where the known-failure list lives.
- A thing the family needs and `ratchet/1` cannot say is not added to the format here. It is
  named on the page and reported, and the coordinator files it as a draft story.
- Every example is generic: `service`, `orders-api`, `case-0042`. No name of a consumer.
- Specification first: `ess specify validate --path spec --strict-requires` passes with the
  file-name rule and the body of a preset before a preset file exists.
- `CHANGELOG.md` is made by `story:changelog-release-procedure`, hence the edge.
  `Taskfile.yml` and the table of `AGENTS.md` § "Ownership" are also edited by stories of the
  waves to 0.1.0: this story starts between two waves, from the `main` of that moment
  (`epic:preset-catalog` § "Order").
- The script test is timed before it is added; it makes no network request and builds
  nothing. The test step ends within 120 s, no test over 60 s.
- POSIX sh. No Python in anything committed.
