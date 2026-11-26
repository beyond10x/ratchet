---
format: aep.planning-md/3
id: story:coverage-count-lower-bound
kind: story
status: draft
title: A coverage count the source does not hold is a lower bound or not known
summary: EvidenceCoverage without inventing the counts an imported report lacks.
relations:
- decomposes: epic:format-gaps-first-format-consumer
scope:
- confidence: cited
  path: CHANGELOG.md
- confidence: cited
  path: crates/ratchet-cli-contract
- confidence: cited
  path: docs/design.md
- confidence: cited
  path: docs/evidence-format.md
- confidence: cited
  path: spec/README.md
- confidence: cited
  path: spec/domains/assessor.yaml
- confidence: cited
  path: spec/domains/cli.yaml
- confidence: cited
  path: spec/domains/evidence.yaml
- confidence: cited
  path: spec/record-examples.test.sh
- confidence: cited
  path: spec/record-fields.test.sh
- confidence: cited
  path: spec/record-types.test.sh
revision: 14
---
## Context

The repository `beyond10x/inference` wrote its quality definition against the formats at
commit `f139ecc` (2026-11-25): 3 `ratchet/1` files, 8 `ratchet-assessor/1` declarations and 15
`ratchet-evidence/1` records. It is the first consumer of the formats outside this repository.
Finding 5: an imported report states that at least 472 units ran and gives no count of skipped
or not run units. The consumer's proposal: `"executed_at_least": 472`.

What the formats say at the wave's base, `7b01ea1`:

- `ratchet.evidence.EvidenceCoverage` requires six integers, `executed`, `skipped`, `not_run`,
  `unsupported`, `passed` and `failed` (`spec/domains/evidence.yaml:228-288`), and so does
  `ratchet.cli.CoverageRow`, which `spec/cli-coverage-row.test.sh` holds to the same fields and
  types (`spec/domains/cli.yaml:63-88`). A record must write a count it does not have.
- `docs/evidence-format.md` § 3 `evidence.coverage` (`:125-145`) marks the six counts
  required; `at_least` exists on a number result only (`:168`, § 5 U6 `:284-294`).
- The declaration side has the same gap: "A count it does not report is 0 in its documents"
  (`docs/evidence-format.md:744`, `ratchet.assessor.Assessor.coverage`,
  `spec/domains/assessor.yaml:191-196`). An assessor that covers a subset of the packages and
  reports no `skipped` writes a 0 it did not observe.
- A plan bounds the counts (`docs/design.md` § 3 "Evidence coverage", `:152-162`); nothing says
  what a bound does with a count the run does not know.

## Decision

Taken as the reversible answer (`AGENTS.md` § "Phase: implementation"):

- The six counts of `EvidenceCoverage` become optional. An absent count is not known.
- A new optional member `at_least`, a list of count names (`ratchet.assessor.CoverageCount`),
  names the counts whose value is a lower bound, in the words of U6: `"executed": 472,
  "at_least": ["executed"]`. A count named there is present.
- An assessor leaves a count it does not report out of its documents. A count that a record
  holds is read as written, 0 included: a record written before the change reads as before,
  and only an absent count is not known. (The other reading, a count the declaration does not
  list read as not known also where a record writes 0, would change what a released record
  means; it was left out.)
- A coverage bound of a plan over a count that is not known gives insufficient evidence with
  the cause `coverage_below_plan`, naming the count. A lower bound meets a `min` bound it
  reaches; any other bound over a lower bound gives the same insufficient evidence.

## Acceptance

Every outcome below is observable without a `ratchet` command.

1. `spec/domains/evidence.yaml`, `ratchet.evidence.EvidenceCoverage`: the six counts are
   `Optional<Integer>`, the new member `at_least` is `Optional<List<ratchet.assessor.CoverageCount>>`,
   an invariant says that a count named under `at_least` is present, and the invariants
   `passed <= executed` and `failed <= executed` hold where both are present.
   `ratchet.cli.CoverageRow` (`spec/domains/cli.yaml`) has the same members with the same
   types. Checked by `ess specify validate --path spec --strict-requires` (exit 0), by
   `sh spec/cli-coverage-row.test.sh` (its last line counts one more coverage field, 10 of
   10, in 2 of 2 places), and by `task check:generated` after `task generate` rewrote
   `crates/ratchet-cli-contract/`.
2. `docs/evidence-format.md` § 3 `evidence.coverage`: the six count rows say "no" under
   Required and "absent: not known" in their meaning, and a row `at_least` follows them. The
   table holds 13 rows; the sentence "There are 78 fields: 48 `spec`, 7 `changed`, 23 `new`"
   (`:52`) reads 79 fields and 24 `new`. Checked by `sh spec/record-fields.test.sh` and
   `sh spec/record-types.test.sh`: the table line for `evidence.coverage` states 13 rows in
   both scripts, and their last lines count 99 field rows, 79 of § 3 and 20 of § 10 (98
   before).
   `spec/README.md` says "79 field rows in 13 tables of § 3".
3. `docs/evidence-format.md` § 6 has a sixth example: an imported run (`source.kind:
   junit`) whose coverage is `"executed": 472, "at_least": ["executed"]` with no `skipped` and
   no `not_run`. `want_examples` of `spec/record-examples.test.sh` (`:46`) goes from 5 to 6,
   and its last line counts the members of 6 examples, every one decoding. Before the story a
   record without `skipped` is refused there as a required member that is absent.
4. `docs/evidence-format.md` § 4 rule 4 and § 5 U6 say what a count that is not known and a
   count that is a lower bound mean; § 10, the row `coverage` of the declaration table
   (`:744`), says that an assessor leaves a count it does not report out of its documents,
   and that an absent count is read as not known; "A count it does not report is 0 in its
   documents" is gone.
   `spec/domains/assessor.yaml`, the summary of `Assessor.coverage`, says the same. Text
   only, no case.
5. `docs/design.md` § 3 "Evidence coverage" states the rule for a bound over a count that is
   not known or is a lower bound (the cause `coverage_below_plan`, naming the count). Text
   only, no case.
6. `CHANGELOG.md` has its line under `## [Unreleased]`. Text only, no case.

## Notes

- An addition to a released format: a record written before the change, with all six counts,
  stays valid and reads as before, a written 0 included. An assessor that wrote a 0 it did not
  observe stops writing it in its next version.
- The verdict of `ratchet evaluate` on a plan whose bound reads a count that is not known is
  `story:coverage-count-lower-bound-in-ratchet`, which waits for the waves to 0.1.0
  (`story:evidence-reader`, `story:evaluate-command`).
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of
  `.engineering/waves/0.1.0-ahead-2.md`, into one wave built in sequence on one branch: every
  planned wave starts behind `story:cli-skeleton-validate`, which waits for a release of ESS
  (beyond10x/ess#836), and this part needs no `ratchet` command. It is 2 of the 33 in the
  order of that page. It is the first of the four stories that add a § 6 example (5 to 6);
  3, 4 and 7 follow, and 3 and 4 change the field tables of § 3 after it.
- It changes `spec/domains/cli.yaml`, so it runs `task generate` and `task check:generated`.
- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s.
