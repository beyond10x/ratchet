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
  path: presets/latency.md
- confidence: cited
  path: presets/operability.md
- confidence: cited
  path: spec/domains/specification.yaml
- confidence: cited
  path: spec/presets.test.sh
revision: 22
---
## Context

Point 2 of "Not expressible yet" on `presets/functional.md` (`:232-238`,
`story:preset-catalog-functional`), repeated on `presets/latency.md` (`:253-256`) and
`presets/operability.md` (`:172-177`). First consumer: the catalog, and every project that
binds `known-failures@1` or `differential-equality@1`. The point 2 of `presets/artifact.md`,
`build.md`, `code.md`, `start.md` and `resources.md` names a ratio of two measurements ("at
most twice the size", "at most a tenth", "at least half"), and each says only that a
requirement names one measurement.

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

1. `spec/domains/specification.yaml`: `subset_of` is a variant of
   `ratchet.specification.ComparisonOperator`, after `within` of story 11: `grep -cF 'within,
   subset_of' spec/domains/specification.yaml` prints 1 (0 before).
2. `ratchet.specification.MeasurementRef` is declared, a struct of `assessment` and an optional
   `measurement`: `grep -c 'name: ratchet.specification.MeasurementRef$'
   spec/domains/specification.yaml` prints 1 (0 before).
3. `ratchet.specification.Condition` holds `against: Optional<ratchet.specification.MeasurementRef>`:
   `grep -cF 'type: Optional<ratchet.specification.MeasurementRef>'
   spec/domains/specification.yaml` prints 1 (0 before), and `ess specify validate --path spec
   --strict-requires` exits 0.
4. `Condition` states the invariants that `against` stands with none of `value`, `digest`,
   `min` and `max`, and that `subset_of` has `against`, the last written
   `- any: ["operator != subset_of", "defined(against)"]`: `grep -cF '"defined(against)"'
   spec/domains/specification.yaml` prints 1 (0 before), and `grep -cF '"not defined(against)"'`
   prints 4 (0 before).
5. The summary of `against` names the two validation codes of a comparison across two value
   types and across two units, `against_value_type_mismatch` and `against_unit_mismatch`:
   `grep -c 'against_value_type_mismatch' spec/domains/specification.yaml` prints 1 (0
   before).
6. `task generate` rewrites `crates/ratchet-cli-contract/` in the same change, where the new
   variant reaches it through `ratchet.cli.LimitRow.operator`, and `task check:generated`
   exits 0: `grep -c '"subset_of"' crates/ratchet-cli-contract/binding.json` prints a number
   above 0 (0 before), and no hand-written file under `crates/` changes.
7. `docs/design.md` § 3 "Comparisons", the table: the row "Identity set" names
   "`subset_of` with `against`": `grep -cF` of that phrase in `docs/design.md` prints 1 (0
   before).
8. `docs/design.md` § 3 "Comparisons", a bullet below the table states the form
   `{operator: subset_of, against: {assessment: listed-cases}}` and holds the phrase "the two
   measurements are of one value type and, for numbers, of one unit": `grep -F` finds the
   phrase, nothing before.
9. The same bullet holds the phrase "`against` takes no `value`": `grep -F` finds it, nothing
   before.
10. The same bullet holds the phrase "the verdict names the runs of both plans": `grep -F`
    finds it, nothing before.
11. `docs/design.md` § 5 "Verdicts", below the table of causes, holds the phrase "A
    `subset_of` that does not hold is the cause `new_items`" and says that the result names
    the items of the measured set that the other set lacks: `grep -F` finds the phrase,
    nothing before. (Moved here from `story:requirement-over-two-measurements-in-ratchet`,
    which decided it before.)
12. `docs/design.md` § 3 "Value lists", the row "Operator", holds `subset_of`: `grep -F '|
    Operator |' docs/design.md` prints a line with `` `subset_of` `` (without it before).
13. `spec/presets.test.sh`, rule `compare`: the accepted copy `compare-subset-of`, whose
    requirement compares the failing cases of one plan with the listed cases of another plan
    of the preset through `subset_of` and `against`, is accepted. Before the story the same
    requirement is refused (rule `place`: `against` is no declared field).
14. `spec/presets.test.sh`: four cases are each refused with the message of the rule
    `compare`, named "against compares a set with a number", "against compares two units",
    "against names an assessment the preset does not hold" and "subset_of without against".
    Before the story none of the four names is in the script (`grep -c` prints 0 for each).
15. `presets/conformance-report@2.assessor.yaml`, which `story:imported-report-revision-check`
    (8 in the order) creates in this wave and no release holds yet, declares the set
    `failing_cases` with the identity key `[case_id]`: `grep -c 'failing_cases'` of the file
    prints a number above 0 (0 before); no file `conformance-report@3` exists.
16. `presets/known-failures@2.preset.yaml` exists, a plan over `conformance-report@2` that takes
    the input `report` beside the plan of `known-failures@1`, and the requirement
    `every-failed-case-listed` (`failing-cases` `subset_of` `listed-cases`): `grep -c
    'every-failed-case-listed:' presets/known-failures@2.preset.yaml` prints 1, and
    `sh spec/presets.test.sh` exits 0 with the file in the catalog (before the story the
    file is refused there by the rule `place`). `known-failures@1` and `conformance-report@1`
    stay byte for byte (`git diff --quiet 7b01ea1 -- presets/known-failures@1.preset.yaml
    presets/conformance-report@1.assessor.yaml` exits 0).
17. `presets/functional.md` has a section `known-failures@2` with a row
    `known-failures@2/known-failures/failing-cases`: `grep -c
    '`known-failures@2/' presets/functional.md` prints a number above 0 (0 before).
18. `presets/functional.md`, "Not expressible yet", point 2, rewritten in place, holds the
    phrase "Answered for the known-failure list from `known-failures@2` on" and says that
    "no fewer passed cases than the reference implementation" waits for a reference from
    another plan: `grep -F` finds the phrase, nothing before.
19. `presets/operability.md`, "Not expressible yet", point 2, rewritten in place: the claim
    that `ratchet.specification.ComparisonOperator` "has no operator between two sets" is gone
    from it, and it holds the phrase "`subset_of` with `against` states it once the list is a
    measurement of a plan" and says that `metrics-scrape@1` stays as released: `grep -F`
    finds the phrase, nothing before.
20. `presets/latency.md`, "Not expressible yet", point 2, rewritten in place, holds the phrase
    "`against` compares two numbers of one unit, with no tolerance" and says that the band of
    10 percent over the binding for the reference implementation waits for a reference from
    another plan: `grep -F` finds the phrase, nothing before.

## Notes

- An addition to a released format; a preset that uses it is a new version of the preset, and
  a declaration with a new output a new version of the declaration.
- The parts that need the command are `story:requirement-over-two-measurements-in-ratchet`:
  `ratchet validate` refusing a comparison across two value types or two units, which reads the
  declarations of two assessors, and `ratchet evaluate --gate` judging a requirement over two
  runs. It waits for the waves to 0.1.0. The cause of a `subset_of` that does not hold and the
  two validation codes are decided here (items 5 and 11), not in that draft.
- Point 2 of `presets/artifact.md`, `build.md`, `code.md`, `start.md` and `resources.md` is
  not rewritten: each names a ratio of two measurements, which `against` does not state (it
  compares with the other value as it is, with no factor), and the one claim each makes, that
  a requirement names one measurement, stays true. Point 2 of `latency.md` and `operability.md`
  is rewritten because `against` and `subset_of` answer part of it (items 19 and 20).
- `presets/functional.md` is in the set of the broken copies of `spec/presets.test.sh`
  (`set_files`): the rewritten point 2 and the new section stand where no case edits.
- It does not change `spec/domains/cli.yaml`; the generated crate follows the new variant of
  `ComparisonOperator` through `ratchet.cli.LimitRow.operator`.
- The line of the wave's changelog: under `### Added`, naming `subset_of` (written by the story
  that closes the wave, `AGENTS.md` § "Changelog lines").
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
