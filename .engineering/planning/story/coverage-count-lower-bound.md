---
format: aep.planning-md/3
id: story:coverage-count-lower-bound
kind: story
status: implemented
title: A coverage count the source does not hold is a lower bound or not known
summary: EvidenceCoverage without inventing the counts an imported report lacks.
relations:
- decomposes: epic:format-gaps-first-format-consumer
scope:
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
revision: 20
transitions:
- {from: "draft", to: "proposed", at: "2026-11-26T21:04:20Z", actor: "human:operator", revision: 18, decided_on: {"recorded":{"review_outcome":4}}}
- {from: "proposed", to: "active", at: "2026-11-26T21:04:20Z", actor: "human:operator", revision: 19, decided_on: {"recorded":{"review_outcome":4}}}
- {from: "active", to: "implemented", at: "2026-11-26T23:39:01Z", actor: "human:operator", revision: 20, decided_on: {"recorded":{"test_result":1,"review_outcome":4}}}
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
  required; `at_least` exists on a number result only (`:167`, § 5 U6 `:284-294`).
- The declaration side has the same gap: "A count it does not report is 0 in its documents"
  (`docs/evidence-format.md:744`, `ratchet.assessor.Assessor.coverage`,
  `spec/domains/assessor.yaml:194-200`). An assessor that covers a subset of the packages and
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

Every outcome below is observable without a `ratchet` command. No item cites a line number:
the files are cited by section, type or quoted phrase.

A phrase with a space in it may wrap in a Markdown paragraph or a folded YAML summary. So where
an item says that `grep -F` finds such a phrase in a `.md` or `.yaml` file, that it finds
nothing or the phrase is gone, or that `grep -c` of it prints a count, the check reads the
joined text of the file: `tr -s '\n ' '  ' < <file> | grep -o -F '<phrase>' | wc -l` prints 1
where the item says it is found, 0 where it says nothing or gone, and the count where it names
one. A name without a space, a row of a table, a pattern with `^`, `$` or `-E`, a check that
prints the line it matches and a check that reads the output of another command read the file
line by line, as written.

1. `spec/domains/evidence.yaml`, `ratchet.evidence.EvidenceCoverage`, and
   `docs/evidence-format.md` § 3 `evidence.coverage`: the six counts are `Optional<Integer>`
   and their rows say `no` under Required. `sh spec/record-types.test.sh` holds the two
   together (a row `no` over a field that is not `Optional` fails it); before the story the
   rows say `yes` and the fields are `Integer`.
2. `spec/domains/evidence.yaml`, `ratchet.evidence.EvidenceCoverage`: the member `at_least`,
   `Optional<List<ratchet.assessor.CoverageCount>>`. `grep -c 'name: at_least'
   spec/domains/evidence.yaml` prints 2 (1 before: the member of
   `NumberValue`).
3. `spec/domains/evidence.yaml`, the invariants of `EvidenceCoverage`: one names `at_least`
   (a count named there is present), and `passed <= executed` and `failed <= executed` hold
   only where both counts are present. `grep -A80 'name: ratchet.evidence.EvidenceCoverage'
   spec/domains/evidence.yaml | grep -c 'in: at_least'` prints 1 (0 before), and the same
   block holds `"not defined(passed)"` (absent before); `ess specify validate --path spec
   --strict-requires` exits 0.
4. `ratchet.cli.CoverageRow` (`spec/domains/cli.yaml`) has the same members with the same
   types: `sh spec/cli-coverage-row.test.sh` ends with
   `cli-coverage-row: 10 of 10 coverage fields reported with their type, in 2 of 2 places`
   (9 of 9 before).
5. `task generate` rewrote `crates/ratchet-cli-contract/` after the change of
   `spec/domains/cli.yaml`, and `task check:generated` exits 0; before the rewrite it fails
   on the changed `CoverageRow`.
6. `docs/evidence-format.md` § 3 `evidence.coverage`: the six count rows hold
   `absent: not known` in their meaning: `grep -c 'absent: not known'
   docs/evidence-format.md` prints 6 (0 before).
7. The same table has a row `at_least` and holds 13 rows, and `spec/record-fields.test.sh`
   states 13 for it: `awk '/^### `evidence.coverage`$/,/^### `evidence.results\[\]`$/'
   docs/evidence-format.md | grep -c '^| `at_least` |'` prints 1 (0 before), the same range
   piped to `grep -c '^| `'` prints 13 (12 before), and `grep -c -F
   '"ratchet.evidence.EvidenceCoverage", 13)' spec/record-fields.test.sh` prints 1 (0 before;
   the line states 12).
8. The sentence of § 3 that counts the fields reads "There are 79 fields: 48 `spec`, 7
   `changed`, 24 `new`": `tr -s '\n ' '  ' < docs/evidence-format.md | grep -c -F 'There are
   79 fields: 48 `spec`, 7 `changed`, 24 `new`'` prints 1 (0 before, when the sentence reads
   "There are 78 fields: 48 `spec`, 7 `changed`, 23 `new`").
9. `sh spec/record-fields.test.sh` ends with `record-fields: 99 of 99 field rows declared`,
   and `sh spec/record-types.test.sh` with
   `record-types: 99 of 99 field rows as declared, 99 of 99 declared fields have a row`
   (98 before, in both).
10. `spec/README.md`, the paragraph that begins "Each script states how much it reads", where
    the sentence wraps: it says "79 field rows in 13 tables of § 3": `tr -s '\n ' '  ' <
    spec/README.md | grep -c -F '79 field rows in 13 tables of § 3'` prints 1 (0 before), and
    the same check of '78 field rows in 13 tables of § 3' prints 0 (1 before).
11. `docs/evidence-format.md` § 6 has a sixth example: an imported run (`source.kind:
    junit`) whose coverage is `"executed": 472, "at_least": ["executed"]` with no `skipped`
    and no `not_run`. The assignment `want_examples` of `spec/record-examples.test.sh` goes
    from 5 to 6, and the script ends with
    `record-examples: <n> of <n> members of 6 example(s) decode under the specification`.
    Before the story a record without `skipped` is refused there as a required member that
    is absent.
12. `spec/README.md`, the same paragraph: it says "6 examples in § 6 (`record-examples`)":
    `tr -s '\n ' '  ' < spec/README.md | grep -c -F '6 examples in § 6'` prints 1 (0
    before), and the same check of '5 examples in § 6' prints 0 (1 before).
13. `docs/evidence-format.md` § 4 rule 4 says "A count that a record leaves out is not known"
    (`grep -F` finds it; nothing before).
14. `docs/evidence-format.md` § 5 U6 says what a count named under `at_least` means: the
    phrase "A count named under `at_least`" (`grep -F` finds it; nothing before).
15. `docs/evidence-format.md` § 10, the row `coverage` of the declaration table, and the
    summary of `Assessor.coverage` in `spec/domains/assessor.yaml`, a folded YAML summary
    whose lines wrap: both say "leaves a count it does not report out of its documents", and
    neither says "is 0 in its documents". For each of the two files,
    `tr -s '\n ' '  ' < <file> | grep -c -F 'leaves a count it does not report out of its
    documents'` prints 1 (0 before), and the same check of 'is 0 in its documents' prints 0
    (1 before).
16. `docs/design.md` § 3 "Evidence coverage" states the rule for a bound over a count that is
    not known or is a lower bound: the phrase "a count that the run does not know" stands in
    that section beside `coverage_below_plan`: `awk '/^### Evidence coverage$/,/^### Time
    windows$/' docs/design.md | tr -s '\n ' '  ' | grep -c -F 'a count that the run does not
    know'` prints 1 (0 before). This is the rule `story:coverage-count-with-reference` (15)
    points to for a count that is not known or is a lower bound.

## Notes

- An addition to a released format: a record written before the change, with all six counts,
  stays valid and reads as before, a written 0 included. An assessor that wrote a 0 it did not
  observe stops writing it in its next version.
- The verdict of `ratchet evaluate` on a plan whose bound reads a count that is not known is
  `story:coverage-count-lower-bound-in-ratchet`, which waits for the waves to 0.1.0
  (`story:evidence-reader`, `story:evaluate-command`).
- Its line of `CHANGELOG.md` is written by the closing commit of the wave (`AGENTS.md`
  § "Changelog lines"; the wave record names the heading and the phrase of the line).
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of
  `.engineering/waves/0.1.0-ahead-2.md`, into one wave built in sequence on one branch: every
  planned wave starts behind `story:cli-skeleton-validate`, which waits for a release of ESS
  (beyond10x/ess#836), and this part needs no `ratchet` command. It is 2 of the 33 in the
  order of that page. It is the first of the four stories that add a § 6 example (5 to 6);
  3, 4 and 7 follow, and 4 and 5 change the field tables of § 3 after it.
- It changes `spec/domains/cli.yaml`, so it runs `task generate` and `task check:generated`.
- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s.
