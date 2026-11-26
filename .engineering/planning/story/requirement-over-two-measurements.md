---
format: aep.planning-md/3
id: story:requirement-over-two-measurements
kind: story
status: draft
title: A requirement compares two measurements
summary: A subset between two identity sets and a comparison of two numbers of one unit, for the known-failure list and the reference implementation.
relations:
- decomposes: epic:preset-catalog
- depends_on: story:preset-catalog-functional
scope:
- confidence: cited
  path: CHANGELOG.md
- confidence: cited
  path: crates/ratchet-cli-contract
- confidence: cited
  path: docs/design.md
- confidence: inferred
  path: presets/conformance-report@2.assessor.yaml
- confidence: cited
  path: presets/functional.md
- confidence: inferred
  path: presets/known-failures@2.preset.yaml
- confidence: cited
  path: spec/domains/specification.yaml
- confidence: cited
  path: spec/presets.test.sh
revision: 18
---
## Context

Point 2 of "Not expressible yet" on `presets/functional.md` (`:232-238`,
`story:preset-catalog-functional`), repeated on `presets/latency.md` (`:253-256`) and
`presets/operability.md` (`:172-177`). First consumer: the catalog, and every project that
binds `known-failures@1` or `differential-equality@1`.

Two requirements of the functional family read two measurements: "every failed case is on the
known-failure list" (the set of failed cases is a subset of the listed set) and "the candidate
passes no fewer cases than the reference implementation" (one count against another).

At `7b01ea1`:

- `ratchet.specification.QualityRequirement` names one `assessment` and one `measurement`
  (`spec/domains/specification.yaml:997-1001`), `ratchet.specification.Condition.value` is a
  `Decimal` (`:546-550`), and `ratchet.specification.ComparisonOperator` (`:532-534`) has no
  operator between two sets. A requirement compares one measurement with a number or with its
  own reference (`docs/design.md:188`).
- `known-failures@1` judges the list alone (`presets/known-failures@1.preset.yaml`, one plan
  over `case-list@1`), and `presets/functional.md:236-238` says it does not see whether the
  list matches the failures of the suite.
- `conformance-report@1` declares the set `passing_cases` and the number `failed`, and no set
  of failing cases (`presets/conformance-report@1.assessor.yaml:11-19`).
- A gate decision lists the runs it read (`evidence` of
  `ratchet.gate.RequirementVerdict` is a `List<ratchet.evidence.RunId>`,
  `spec/domains/gate.yaml:256`), so a verdict over two runs needs no new member there.

Decision taken (reversible, `AGENTS.md` § "Phase: implementation"): a `Condition` gets a member
`against`, a new struct `ratchet.specification.MeasurementRef` of `assessment` and an optional
`measurement` (left out where the plan has one, as on a requirement), naming another
measurement of the same specification. With `against`, `lt`, `lte`, `gt`, `gte` and `eq`
compare two numbers of one unit, or the numbers of items of two sets, and a new operator
`subset_of` holds when every item of the measured set is in the other set. `against` takes no
`value`. Within a preset, `against` names an assessment of the preset. A comparison with the
measurement of another binding (the reference implementation) is written by a project in its
own file, and the preset form waits for `story:reference-from-another-plan`.

## Acceptance

Every outcome below is observable without a `ratchet` command.

1. `spec/domains/specification.yaml`: `subset_of` is a variant of `ComparisonOperator`
   (`:532-534`, with `within` that story 11 added); `ratchet.specification.MeasurementRef` is
   declared; `Condition` (`:536-555`) holds `against: Optional<MeasurementRef>` with the
   invariants: `against` and `value`, `against` and `digest`, `against` and `min`/`max` are
   never both; `subset_of` has `against`. Checked by
   `ess specify validate --path spec --strict-requires`, which exits 0.
2. `task check:generated` exits 0: where the new variant changes `crates/ratchet-cli-contract/`
   (through `ratchet.cli.LimitRow.operator`, `spec/domains/cli.yaml:53-60`),
   `task generate` rewrites it in the same change, and no hand-written file under `crates/`
   changes.
3. `docs/design.md` § 3 "Comparisons" (`:186-203`): the table gives a number and an identity
   set the comparison with another measurement through `against`, and an identity set
   `subset_of`; a bullet says that the two measurements are of one value type and, for
   numbers, of one unit, that `against` takes no `value`, and that the verdict names the runs
   of both plans; the list "Operator" (`:216`) holds `subset_of`. Text only, no case.
4. `spec/presets.test.sh`, rule `compare`: `against` names an assessment and a measurement of
   the preset, of the value type of the compared measurement and, for a number, of its unit;
   `subset_of` takes two sets and has `against`. Before the story a preset requirement with
   `against` is refused (rule `place`). After it, a copy whose requirement compares the
   failing cases of one plan with the listed cases of another through `subset_of` is
   accepted, and a copy with `against` on a set and a number, one with two numbers of two
   units, one with `against` naming an assessment the preset does not hold, and one with
   `subset_of` and no `against` are each refused with the message of the rule.
5. `presets/conformance-report@2.assessor.yaml`, which `story:imported-report-revision-check`
   (8 in the order) creates in this wave and no release holds yet, also declares the set
   `failing_cases` (identity key `[case_id]`): this story extends that file and makes no
   `@3`;
   `presets/known-failures@2.preset.yaml` (new) holds the plan of `known-failures@1`, a plan
   over `conformance-report@2` that takes the input `report`, and the requirement
   `every-failed-case-listed`: `failing-cases` `subset_of` `listed-cases`. `known-failures@1`
   and `conformance-report@1` stay byte for byte. `presets/functional.md` has the section
   `known-failures@2` with its rows and the requirement, and its point 2 (`:232-238`) says that
   the first requirement is answered from `known-failures@2` on, and the second waits for a
   reference from another plan. Checked by `spec/presets.test.sh`, rules `place`, `type`,
   `assessor`, `compare` and `row`: its last line counts one more file and the measurements
   of `known-failures@2` with a row.
6. `CHANGELOG.md` has its line under `## [Unreleased]`, in the form
   `.github/scripts/release.test.sh` checks.

## Notes

- An addition to a released format; a preset that uses it is a new version of the preset, and
  a declaration with a new output a new version of the declaration.
- The parts that need the command are `story:requirement-over-two-measurements-in-ratchet`:
  `ratchet validate` refusing a comparison across two value types or two units, which reads the
  declarations of two assessors, and `ratchet evaluate --gate` judging a requirement over two
  runs. It waits for the waves to 0.1.0.
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of `.engineering/waves/0.1.0-ahead-2.md`,
  into one wave built in sequence on one branch: every planned wave starts behind
  `story:cli-skeleton-validate`, which waits for a release of ESS (beyond10x/ess#836), and this
  part needs no `ratchet` command. It is 12 of the 33 in the order of that page.
- 11 (`story:requirement-states-a-range`) adds `within`, `min` and `max` to the same type and
  rule before it; 14 (`story:number-states-its-source`) adds `source` to `Condition` after it.
  27 (`story:reference-from-another-plan`) adds a reference from another assessment; with it a
  preset can say "no fewer passed cases than the reference implementation".
- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s; new broken
  copies are timed before they are added.
