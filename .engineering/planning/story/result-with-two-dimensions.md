---
format: aep.planning-md/3
id: story:result-with-two-dimensions
kind: story
status: draft
title: A number result carries its condition cell beside its scope item
summary: A result per scenario and viewport without joining the two into one item name.
relations:
- decomposes: epic:format-gaps-first-format-consumer
scope:
- confidence: cited
  path: CHANGELOG.md
- confidence: cited
  path: docs/design.md
- confidence: cited
  path: docs/evidence-format.md
- confidence: cited
  path: spec/README.md
- confidence: cited
  path: spec/domains/assessor.yaml
- confidence: cited
  path: spec/domains/evidence.yaml
- confidence: cited
  path: spec/domains/specification.yaml
- confidence: cited
  path: spec/record-examples.test.sh
- confidence: cited
  path: spec/record-fields.test.sh
- confidence: cited
  path: spec/record-types.test.sh
revision: 12
---
## Context

The repository `beyond10x/inference` wrote its quality definition against the formats at
commit `f139ecc` (2026-11-25): 3 `ratchet/1` files, 8 `ratchet-assessor/1` declarations and 15
`ratchet-evidence/1` records. It is the first consumer of the formats outside this repository.
Finding 6: a result belongs to a scenario and to a viewport. The consumer wrote one scope
`view` with the item `<scenario>/<viewport>`: valid, and neither part can be grouped or
selected on its own.

What the formats say at the wave's base, `7b01ea1`:

- `ratchet.evidence.MeasurementResult` has one `scope` and one `item`
  (`spec/domains/evidence.yaml:324-444`, `item` at `:345-349`), and format § 4 rule 3 keeps at
  most one result per `output`, `scope`, `item`, `boundary` and `aggregation`
  (`docs/evidence-format.md:211`).
- `docs/evidence-format.md` § 9 lists "A result per condition cell, such as a viewport and a
  theme" as not in version 1 (`:671`): "A number has no field for it".
- `ratchet.specification.Measurement` selects results by `output`, `scope`, `boundary` and
  `aggregation` (format § 4, `:221`), and a `filter` on an identity set reads item fields
  (`spec/domains/specification.yaml:224-229`); nothing selects by a condition.
- `ratchet.assessor.AssessorOutput` declares scopes, a unit, boundaries and item fields
  (`spec/domains/assessor.yaml:78-131`), and no condition its results are split by.

## Decision

Taken as the reversible answer (`AGENTS.md` § "Phase: implementation"):

- A result gets an optional `cell`: a map from a condition name to the value the result was
  observed under, such as `{"viewport": "narrow"}`. Rule 3 keeps at most one result per
  `output`, `scope`, `item`, `cell`, `boundary` and `aggregation`.
- An output declares the conditions its results are split by as `cells`, a list of names; a
  result has a `cell` exactly when its output declares `cells`, with those names.
- A measurement may select one cell with `cell: {viewport: narrow}`. Without it, the
  measurement reads one value per item and cell, and two results of one item in two cells are
  two entries of the series. An aggregation within the scope may aggregate over the cells.

## Acceptance

Every outcome below is observable without a `ratchet` command.

1. `spec/domains/evidence.yaml`: `MeasurementResult` has `cell`
   (`Optional<Map<String, String>>`); `spec/domains/assessor.yaml`: `AssessorOutput` has
   `cells` (`Optional<List<String>>`); `spec/domains/specification.yaml`: `Measurement` has
   `cell` (`Optional<Map<String, String>>`), with summaries that state the decision. Checked by
   `ess specify validate --path spec --strict-requires` (exit 0).
2. `docs/evidence-format.md` § 3 `evidence.results[]` has a row `cell`: the table holds 11
   rows, and the sentence "There are 79 fields" of 2 reads 80, with 25 `new`. § 10, the
   output table, has a row `cells` and holds 9 rows. Checked by `sh spec/record-fields.test.sh`
   and `sh spec/record-types.test.sh`: the lines of the two tables state 11 and 9 rows in both
   scripts, and their last lines count 101 field rows, 80 of § 3 and 21 of § 10 (99 after 2).
   `spec/README.md` says "80 field rows in 13 tables of § 3 and 21 in 2 tables of § 10".
3. `docs/evidence-format.md` § 6 has an eighth example: two number results of one output, one
   `item`, in two cells (`{"viewport": "narrow"}` and `{"viewport": "wide"}`). `want_examples`
   of `spec/record-examples.test.sh` goes from 7 to 8, and its last line counts the members of
   8 examples, every one decoding. Before the story `cell` is refused there as an undeclared
   member.
4. `docs/evidence-format.md` § 4 rule 3 names `cell` among the members a result is unique by;
   § 9 no longer lists "A result per condition cell". `docs/design.md` § 3 "Scope and
   aggregation" says how a result carries its cell beside its scope item and how a measurement
   selects a cell or reads one value per item and cell. Text only, no case.
5. `CHANGELOG.md` has its line under `## [Unreleased]`. Text only, no case.

## Notes

- An addition to released formats: a record, a declaration and a plan written before the
  change stay valid.
- The reading of `cell` by `ratchet evaluate` and the check of a result's cell against its
  output's `cells` are `story:result-with-two-dimensions-in-ratchet`, which waits for the waves
  to 0.1.0 (`story:evidence-reader`, `story:evaluate-command`).
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of
  `.engineering/waves/0.1.0-ahead-2.md`, into one wave built in sequence on one branch: every
  planned wave starts behind `story:cli-skeleton-validate`, which waits for a release of ESS
  (beyond10x/ess#836), and this part needs no `ratchet` command. It is 4 of the 33 in the
  order of that page. It adds the § 6 example after that of 3 (7 to 8), and the field rows
  after those of 2; 5 adds the next rows to § 3 and § 10.
- It runs `task check:generated` when it edits `spec/domains/`.
- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s.
