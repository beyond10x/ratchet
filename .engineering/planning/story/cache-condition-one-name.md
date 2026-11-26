---
format: aep.planning-md/3
id: story:cache-condition-one-name
kind: story
status: implemented
title: The cache condition has one name in a plan and in a record
summary: A plan writes cache and a record holds cache_profile; no rule joins the two.
relations:
- decomposes: epic:preset-catalog
- depends_on: story:preset-catalog-factory
scope:
- confidence: inferred
  path: CHANGELOG.md
- confidence: inferred
  path: docs/design.md
- confidence: inferred
  path: docs/evidence-format.md
- confidence: inferred
  path: presets
- confidence: inferred
  path: spec/domains/assessor.yaml
- confidence: inferred
  path: spec/domains/evidence.yaml
- confidence: inferred
  path: spec/domains/specification.yaml
revision: 15
transitions:
- {from: "draft", to: "proposed", at: "2026-11-26T05:20:02Z", actor: "human:operator", revision: 13}
- {from: "proposed", to: "active", at: "2026-11-26T05:20:02Z", actor: "human:operator", revision: 14}
- {from: "active", to: "implemented", at: "2026-11-26T07:54:30Z", actor: "human:operator", revision: 15, decided_on: {"recorded":{"test_result":1,"review_outcome":1}}}
---
## Context

Found by the implementor of `story:preset-catalog-factory` on 2026-11-25; it was there before
that unit.

The condition that says whether a build ran with a warm cache has two names. A plan and a
declaration write `cache`: the example of `docs/design.md` § 3 (`cache: warm` under
`conditions.all`, `:296`), the summary of `ratchet.specification.ObservationConditions`
(`spec/domains/specification.yaml:348-350`) and the summary of `conditions` of
`ratchet.assessor.Assessor` (`spec/domains/assessor.yaml:172-176`). An evidence record holds
`cache_profile`: `ratchet.evidence.ObservedConditions.cache_profile`
(`spec/domains/evidence.yaml:194`) and the field table of `docs/evidence-format.md` § 3
(`:110`). The same record has `other` for "every further condition that the plan or the
assessor declares" (`:111`), so a program that follows the plan writes `other.cache`, and no
sentence says that a declared `cache` is read from `cache_profile`.

The five presets of the build family write `cache_profile` (`cold-build-time@1:34`,
`warm-build-time@1:34`, `test-step-time@1:35`, `test-time@1:35`, `flake-rate@1:35`), and their
two declarations declare it (`build-report@1:9`, `test-report@1:9`), the name of the evidence
member, so that the declared condition and the observed one have one name. All seven were
released in 0.0.2. `spec/presets.test.sh` uses `cache` in three of its own copies
(`:1758`, `:1760`, `:1884`) and accepts it where the copied declaration lists it (`:1761`).

The key is a condition name under `ratchet.specification.ObservationConditions` and a member
of `ratchet.evidence.ObservedConditions`. It is none of the three types that
`epic:format-gaps-first-format-consumer` holds back until the wave that reads them
(`ratchet.specification.Condition`, `ratchet.evidence.EvidenceCoverage`,
`ratchet.evidence.ImportSourceKind`).

## Acceptance

The condition is named `cache_profile` in a plan, a declaration and a record; the name is
fixed here and is not reopened by the story. Every outcome below is observable without a
`ratchet` command.

1. `spec/domains/specification.yaml` (summary of `ObservationConditions`, `:347-350`) and
   `spec/domains/assessor.yaml` (summary of `Assessor.conditions`, `:174-176`) state that a
   plan and a declaration write the cache condition as `cache_profile` and under no other
   name, and `spec/domains/evidence.yaml` (summary of `ObservedConditions`, `:175-183`) says
   that a declared `cache_profile` is held in `cache_profile` and not under `other`. Checked
   by `ess specify validate --path spec --strict-requires`, which exits 0, and by
   `task check:generated`; the sentences are text, no case.
2. `docs/design.md` § 3: the example writes `cache_profile: warm` (`:296`), and the text
   beside it states that a plan and a declaration write the cache condition as
   `cache_profile` and under no other name. Text only, no case: no script reads that example.
3. `docs/evidence-format.md` § 3, below the table of `evidence.conditions` (`:100-113`): one
   sentence that a plan and a declaration write the cache condition as `cache_profile`, the
   key of the row, and under no other name, and that a record holds it there and not under
   `other`. Text only, no case; the rows stay, and `spec/record-fields.test.sh` and
   `spec/record-types.test.sh` keep their count of 78 rows in § 3.
4. `examples/quality/assessors/command-timing@1.assessor.yaml` declares
   `conditions: [cache_profile]`, the condition its plan in `docs/design.md` § 3 uses
   (finding 7 of `review-result:adversary-example-assessor-declarations-attack-1`). Text only,
   no case: `spec/example-declarations.test.sh` does not read the conditions of a plan or a
   declaration (its header, `:38-40`).
5. `spec/presets.test.sh`, rule `assessor`: a condition `cache` of a plan, and an item `cache`
   of the `conditions` of a declaration, are refused with a message that names
   `cache_profile`. The source of the refusal is the sentence of items 1 to 3 that a plan and
   a declaration write `cache_profile` and no other name; the struct stays open
   (`spec/domains/specification.yaml:345`, `undeclared_fields: ignored`) for every other
   condition an assessor declares. Before the story a copy whose declaration lists `cache` and whose plan
   writes `cache: warm` is accepted (`:1758-1761`). After the story those copies write
   `cache_profile` and are accepted, a broken copy that writes `cache` in both places is
   refused with the message of the rule, and the copy at `:1884` writes `cache_profile`.
   `presets/` does not change, and the script's last line counts the same files.
6. `CHANGELOG.md` has its line under `## [Unreleased]`. Text only, no case.

## Notes

- Why `cache_profile`: it is the member of the record and the key of the seven released
  files, and `cache` stands only in two summaries, one design example and the copies of the
  script. The presets and declarations of 0.0.2 stay as released.
- It runs `task check:generated` when it edits `spec/domains/`.
- The refusal by `ratchet validate`, and the reading of a declared `cache_profile` from a
  record, are `story:cache-condition-one-name-in-ratchet`, which waits for the waves to 0.1.0.
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them, with eight other drafts, into one wave built in sequence on one
  branch: every planned wave starts behind `story:cli-skeleton-validate`, which waits for a
  release of ESS (beyond10x/ess#836), and this part needs no `ratchet` command. It is 3 of the
  nine in the order of `.engineering/waves/0.1.0-ahead-1.md`.
- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s; the new
  broken copy is timed before it is added.
