---
format: aep.planning-md/3
id: story:reference-from-another-plan
kind: story
status: draft
title: A reference is adopted from the evidence of another plan
summary: 'The run of a reference implementation as the accepted set of the candidate: a requirement names another assessment as the source of its reference.'
relations:
- decomposes: epic:preset-catalog
- depends_on: story:preset-catalog-functional
scope:
- confidence: cited
  path: docs/design.md
- confidence: inferred
  path: presets/differential-equality@3.preset.yaml
- confidence: cited
  path: presets/functional.md
- confidence: cited
  path: spec/domains/specification.yaml
- confidence: cited
  path: spec/presets.test.sh
revision: 15
---
## Context

The first of three points `presets/functional.md` lists under "Not expressible yet"
(`:220-231` at 7b01ea1, `story:preset-catalog-functional`). First consumer: the catalog, and
behind it every project that binds `differential-equality@2`.

A candidate is compared with a reference implementation: the cases the reference
implementation passes are the accepted set, and the candidate loses none of them. That accepted
set is the evidence of another plan, the run of the reference implementation.
`ratchet.specification.AdoptionSource` has `same_change` and `trusted_revision`
(`spec/domains/specification.yaml:578-580`), and `ratchet.specification.RatchetPolicy` holds
`from`, `runs` and `aggregation` and names no assessment (`:582-600`); the comment above
`ratchet.specification.RunSource` says "An adoption takes `trusted_revision` only"
(`:432-434`). `docs/design.md` § 5 "Protected references" states the two adoptions in the
table under "The ratchet policy" (`:588-593`), and § 3 "Value lists" gives the run source of an
adoption as `trusted_revision` alone (`:225`). A reference is adopted from the runs of its own
plan.

`differential-equality@2` (`presets/differential-equality@2.preset.yaml`) has one assessment,
`comparison`, over `comparison-report@2`; the passing cases of a run are the output
`passing_cases` of `conformance-report@1` (`presets/conformance-report@1.assessor.yaml:11-15`).

Related and not the same: `story:requirement-over-two-measurements` (12 in the order) compares
two measurements of one evaluation, live. This story adopts the value of another plan as the
accepted value, which stays fixed until the next adoption, as every accepted value does
(`docs/design.md:586`).

## Decision

The reversible answer, taken here (AGENTS.md § "Phase: implementation"): a third value of
`AdoptionSource`, `assessment`, and two optional members of `RatchetPolicy`, `assessment` and
`measurement`, present exactly with it:
`adoption: {from: assessment, assessment: <plan>, measurement: <measurement>}`. The value is
that of the named measurement in the last qualifying run of the named plan on the trusted
revision. The named measurement has the value type and the unit of the requirement's own.

## Acceptance

Every outcome below is observable without a `ratchet` command.

1. `spec/domains/specification.yaml`, `ratchet.specification.AdoptionSource` has the variant
   `assessment`: `grep -F 'variants: [same_change, trusted_revision, assessment]'
   spec/domains/specification.yaml` finds it (nothing before), and
   `ess specify validate --path spec --strict-requires` exits 0.
2. `ratchet.specification.RatchetPolicy` has the optional members `assessment` and
   `measurement`, present exactly when `from` is `assessment`: its `invariants:` hold
   `any: ["from != assessment", "defined(assessment)"]`, the same for `measurement`, and
   `any: ["from == assessment", "not defined(assessment)"]`, the same for `measurement`.
   `grep -c 'from != assessment' spec/domains/specification.yaml` prints 2 (0 before), and
   `task check:generated` exits 0.
3. The comment above `ratchet.specification.RunSource` no longer says "An adoption takes
   `trusted_revision` only": `grep -c 'adoption takes `trusted_revision` only'
   spec/domains/specification.yaml` prints 0 (1 before).
4. `docs/design.md` § 5 "Protected references", the table under "The ratchet policy", has a
   row for the third adoption: `grep -F '| `{from: assessment, assessment: <plan>,
   measurement: <measurement>}` |' docs/design.md` finds it (nothing before).
5. `docs/design.md` § 3 "Value lists", the row "Run source (`from`)", names `assessment` for an
   adoption: `grep -F '`trusted_revision`, `assessment` for an adoption' docs/design.md` finds
   it (nothing before).
6. `spec/presets.test.sh` has a new rule `adoption`, listed in its header: an adoption
   `from: assessment` names an assessment of the same preset and a measurement of it with the
   value type and the unit of the requirement's measurement. The case
   `adoption-other-value-type` (a file of the set whose adoption names a measurement of another
   value type) is refused with the message of the rule, and the script exits 0; before the
   story no case of that name exists (`grep -c adoption-other-value-type spec/presets.test.sh`
   prints 0).
7. The case `adoption-other-assessment` of `spec/presets.test.sh`, a copy with a valid adoption
   from another assessment of the preset, is checked with `accepts`: the run exits 0, and a
   rule that refused it would stop the run with
   `presets: refused, and it is valid: adoption-other-assessment`. Before the story the same
   copy is refused by the rule `type` (`assessment` is no variant of
   `ratchet.specification.AdoptionSource`).
8. `presets/differential-equality@3.preset.yaml` (new) holds the plans of `@2`, a plan of the
   reference implementation's run and one of the candidate's over `conformance-report@1`, and
   the requirement "the candidate loses no case the reference implementation passes"
   (`no_lost_items` on the candidate's passing cases, adopted with `from: assessment` from the
   reference run's): `grep -c 'from: assessment' presets/differential-equality@3.preset.yaml`
   prints 1, and the line `presets: <f> of <f> file(s) valid, <r> of <r> measurement(s) with a
   row` of `sh spec/presets.test.sh` counts one file more than before the story, with every
   measurement of the new file with a row.
9. `presets/functional.md` has the section `## \`differential-equality@3\``:
   `grep -c '^## `differential-equality@3`' presets/functional.md` prints 1 (0 before).
10. `presets/functional.md` § "Not expressible yet", point 1 is rewritten in place and says it
    is answered: `grep -F 'answered from `differential-equality@3` on' presets/functional.md`
    finds it (nothing before), and the list keeps its numbering.
11. `presets/differential-equality@1.preset.yaml` and `@2` stay byte for byte:
    `git diff --quiet 7b01ea1 -- presets/differential-equality@1.preset.yaml
    presets/differential-equality@2.preset.yaml` exits 0.

## Notes

- An addition to a released format: a file written before the change stays valid. A preset
  that uses it is a new version of the preset, `differential-equality@3`, unreleased until
  0.0.5.
- `ratchet validate` refusing an adoption that names no assessment or a measurement of another
  value type, with a code, and `ratchet reference adopt` reading the named plan's run, are
  `story:reference-from-another-plan-in-ratchet`, which waits for the waves to 0.1.0
  (`story:reference-adopt-command`, `story:preset-binding-resolution`).
- `docs/design.md` § 5 "Protected references" is changed just before this story by
  `story:new-item-without-accepted-value` (26, "Reference records"); this story changes the
  ratchet policy table below it. `spec/presets.test.sh` gets rules from stories 12 to 23 before
  this one; its rule is added after theirs. `presets/functional.md` is in the set of the broken
  copies of `spec/presets.test.sh` (`set_files`): the section this story adds stands where no
  case edits.
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of `.engineering/waves/0.1.0-ahead-2.md`,
  into one wave built in sequence on one branch: every planned wave starts behind
  `story:cli-skeleton-validate`, which waits for a release of ESS (beyond10x/ess#836), and this
  part needs no `ratchet` command. It is 27 of the 33 in the order of that page.
- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s; new broken
  copies are timed before they are added.
