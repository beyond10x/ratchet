---
format: aep.planning-md/3
id: story:result-with-two-dimensions
kind: story
status: active
title: A number result carries its condition cell beside its scope item
summary: A result per scenario and viewport without joining the two into one item name.
relations:
- decomposes: epic:format-gaps-first-format-consumer
scope:
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
revision: 17
transitions:
- {from: "draft", to: "proposed", at: "2026-11-26T21:04:21Z", actor: "human:operator", revision: 16, decided_on: {"recorded":{"review_outcome":4}}}
- {from: "proposed", to: "active", at: "2026-11-26T21:04:21Z", actor: "human:operator", revision: 17, decided_on: {"recorded":{"review_outcome":4}}}
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

Every outcome below is observable without a `ratchet` command. No item cites a line number.

A phrase with a space in it may wrap in a Markdown paragraph or a folded YAML summary. So where
an item says that `grep -F` finds such a phrase in a `.md` or `.yaml` file, that it finds
nothing or the phrase is gone, or that `grep -c` of it prints a count, the check reads the
joined text of the file: `tr -s '\n ' '  ' < <file> | grep -o -F '<phrase>' | wc -l` prints 1
where the item says it is found, 0 where it says nothing or gone, and the count where it names
one. A name without a space, a row of a table, a pattern with `^`, `$` or `-E`, a check that
prints the line it matches and a check that reads the output of another command read the file
line by line, as written.

1. `spec/domains/evidence.yaml`, `ratchet.evidence.MeasurementResult`: the member `cell`,
   `Optional<Map<String, String>>` (`grep -c 'name: cell$' spec/domains/evidence.yaml`
   prints 1; 0 before).
2. `spec/domains/assessor.yaml`, `ratchet.assessor.AssessorOutput`: the member `cells`,
   `Optional<List<String>>` (`grep -c 'name: cells$' spec/domains/assessor.yaml` prints 1; 0
   before).
3. `spec/domains/specification.yaml`, `ratchet.specification.Measurement`: the member `cell`,
   `Optional<Map<String, String>>`, whose summary says "one value per item and cell"
   (`grep -c 'name: cell$' spec/domains/specification.yaml` prints 1 and `grep -F 'one value
   per item and cell' spec/domains/specification.yaml` finds the summary; neither before).
   `ess specify validate --path spec --strict-requires` exits 0.
4. `docs/evidence-format.md` § 3 `evidence.results[]` has a row `cell`, so the table holds 11
   rows, and the sentence of § 3 reads "There are 80 fields: 48 `spec`, 7 `changed`, 25
   `new`". § 10, the output table, has a row `cells` and holds 9 rows. The scripts end with
   `record-fields: 101 of 101 field rows declared` and
   `record-types: 101 of 101 field rows as declared, 101 of 101 declared fields have a row`
   (99 after story 2).
5. `spec/README.md`, the paragraph that begins "Each script states how much it reads": it
   says "80 field rows in 13 tables of § 3 and 21 in 2 tables of § 10". The sentence wraps,
   so the check joins the lines: `tr -s '\n ' '  ' < spec/README.md | grep -c -F '80 field
   rows in 13 tables of § 3 and 21 in 2 tables of § 10'` prints 1 (0 before), and the same
   check of '79 field rows in 13 tables of § 3 and 20 in 2 tables of § 10' prints 0 (1
   before, after story 2).
6. `docs/evidence-format.md` § 6 has an eighth example: two number results of one output, one
   `item`, in two cells (`{"viewport": "narrow"}` and `{"viewport": "wide"}`). The assignment
   `want_examples` of `spec/record-examples.test.sh` goes from 7 to 8, and the script ends
   with `record-examples: <n> of <n> members of 8 example(s) decode under the specification`.
   Before the story `cell` is refused there as no field of `MeasurementResult`.
7. `spec/README.md`, the same paragraph: it says "8 examples in § 6 (`record-examples`)"
   (`tr -s '\n ' '  ' < spec/README.md | grep -c -F '8 examples in § 6'` prints 1, 0 before;
   the same check of '7 examples in § 6' prints 0, 1 before).
8. `docs/evidence-format.md` § 4 rule 3 names `cell` among the members a result is unique
   by: the rule reads "per `output`, `scope`, `item`, `cell`, `boundary`, and `aggregation`"
   (`grep -F` finds it; the rule without `cell` before).
9. `docs/evidence-format.md` § 9 no longer lists the bullet "A result per condition cell"
   (`grep -c 'A result per condition cell' docs/evidence-format.md` prints 0; 1 before).
10. `docs/design.md` § 3 "Scope and aggregation" says how a measurement selects a cell or
    reads one value per item and cell: the phrase "one value per item and cell" stands in
    that section (`grep -F` finds it in `docs/design.md`; nothing before).

## Notes

- An addition to released formats: a record, a declaration and a plan written before the
  change stay valid.
- The reading of `cell` by `ratchet evaluate` and the check of a result's cell against its
  output's `cells` are `story:result-with-two-dimensions-in-ratchet`, which waits for the waves
  to 0.1.0 (`story:evidence-reader`, `story:evaluate-command`).
- Its line of `CHANGELOG.md` is written by the closing commit of the wave (`AGENTS.md`
  § "Changelog lines"; the wave record names the heading and the phrase of the line).
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of
  `.engineering/waves/0.1.0-ahead-2.md`, into one wave built in sequence on one branch: every
  planned wave starts behind `story:cli-skeleton-validate`, which waits for a release of ESS
  (beyond10x/ess#836), and this part needs no `ratchet` command. It is 4 of the 33 in the
  order of that page. It adds the § 6 example after that of 3 (7 to 8), and the field rows
  after those of 2; 5 adds the next rows to § 3 and § 10.
- It runs `task check:generated` when it edits `spec/domains/`.
- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s.
