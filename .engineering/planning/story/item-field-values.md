---
format: aep.planning-md/3
id: story:item-field-values
kind: story
status: draft
title: An assessor declaration states the values of an item field
summary: A closed list of values for an item field, so that a filter on a misspelt value is refused.
relations:
- decomposes: epic:preset-catalog
- depends_on: story:preset-catalog-functional
scope:
- confidence: inferred
  path: CHANGELOG.md
- confidence: inferred
  path: docs/evidence-format.md
- confidence: inferred
  path: presets
- confidence: inferred
  path: spec/domains/assessor.yaml
- confidence: inferred
  path: spec/presets.test.sh
revision: 8
---
## Context

The third of three things `presets/functional.md` lists under "Not expressible yet"
(`presets/functional.md:224-227`, `story:preset-catalog-functional`). First consumer: the
catalog, and every project that writes an assessor declaration with a classified item.

`comparison-report@1` gives each case the item field `class` with one of `equal`, `allowed`
and `different`, and three measurements of `differential-equality@1` select by it with
`filter` (`presets/differential-equality@1.preset.yaml:30`, `:36`, `:42`).
`ratchet.assessor.AssessorOutput.item_fields` is `Optional<List<String>>`: the names of the
fields and not their values (`spec/domains/assessor.yaml:114-118`). `spec/presets.test.sh`
refuses a `filter` field the output does not declare (`:1094-1098`, case `:2412-2414`) and
lists "the values of a `filter`: no declaration lists the values of an item field" under "Not
checked" (`:129`). A `filter` on a misspelt class selects nothing, and no check refuses it.

Four declarations state `item_fields` today: `presets/comparison-report@1.assessor.yaml:17`,
`presets/advisory-report@1.assessor.yaml:17`, `presets/lint-report@1.assessor.yaml:17` and
`examples/quality/assessors/ux-eval@1.assessor.yaml:22`.

## Acceptance

Every outcome below is observable without a `ratchet` command.

1. `spec/domains/assessor.yaml`, `ratchet.assessor.AssessorOutput`: a declaration states the
   closed list of values of an item field, in the form the story decides (a member beside
   `item_fields`, or `item_fields` as a map from a field to its values). A field without a
   list stays open, as today. Checked by `ess specify validate --path spec --strict-requires`,
   which exits 0, and by `task check:generated`.
2. `docs/evidence-format.md` § 10, the table of an output (`:676-686`): the row of the form,
   and the declaration example (`:690-717`) unchanged unless the form renames `item_fields`.
   Checked by `spec/record-fields.test.sh` and `spec/record-types.test.sh`: before the story
   both count 19 rows in the 2 tables of § 10; after, a new member gives 20 rows in both
   scripts' stated counts, or a changed type gives a changed Type cell of the `item_fields`
   row (`:686`) with 19 rows. `spec/contract-examples.test.sh` reads the example and exits 0.
3. `presets/comparison-report@2.assessor.yaml` (new) lists `equal`, `allowed` and `different`
   for `class`, and `presets/differential-equality@2.preset.yaml` (new) names it, with the
   three rows of its measurements on `presets/functional.md`. The files `@1` released in 0.0.2
   stay byte for byte. Checked by `spec/presets.test.sh`, rules `place`, `type` and `row`: its
   last line counts two more files and three more measurements with a row.
4. `spec/presets.test.sh`, rule `assessor`: a `filter` that names a value outside the list of
   its field is refused with a message that names the value, the field and the list. Before
   the story the header lists the values of a `filter` under "Not checked" (`:129`), and a
   copy with `filter: {class: [diferent]}` is accepted. After the story that line is gone, a
   broken copy whose `filter` reads `{class: [diferent]}` against a declaration that lists the
   values of `class` is refused with the message of the rule, and a copy that filters by a
   field declared without a list is accepted with any value.
5. `presets/functional.md`, "Not expressible yet", point 3 (`:224-227`), says that the form
   answers it from `comparison-report@2` on, and `CHANGELOG.md` has its line under
   `## [Unreleased]`. Text only, no case.

## Notes

- The story decides the form, declares it in `spec/` first, and writes it into
  `docs/evidence-format.md` § 10 in the same change. It runs `task check:generated` when it
  edits `spec/domains/`.
- An addition to `ratchet-assessor/1`; a declaration that uses it is a new version of the
  declaration, and a preset that names that version is a new version of the preset.
- The checks of `ratchet validate` and of the evidence reader are
  `story:item-field-values-in-ratchet`, which waits for the waves to 0.1.0.
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them, with eight other drafts, into one wave built in sequence on one
  branch: every planned wave starts behind `story:cli-skeleton-validate`, which waits for a
  release of ESS (beyond10x/ess#836), and this part needs no `ratchet` command. It is 8 of the
  nine in the order of `.engineering/waves/0.1.0-ahead-1.md` and lands after the other changes of
  `spec/presets.test.sh` of the wave.
- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s; the new
  broken copy is timed before it is added.
