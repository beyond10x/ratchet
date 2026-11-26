---
format: aep.planning-md/3
id: story:coverage-count-with-reference
kind: story
status: active
title: A coverage count is a measurement a reference can protect
summary: executed, skipped, not_run and unsupported as measurements with a direction and an accepted value.
relations:
- decomposes: epic:format-gaps-first-format-consumer
scope:
- confidence: cited
  path: docs/design.md
- confidence: cited
  path: docs/evidence-format.md
- confidence: cited
  path: spec/domains/specification.yaml
- confidence: cited
  path: spec/example-declarations.test.sh
- confidence: cited
  path: spec/presets.test.sh
revision: 13
transitions:
- {from: "draft", to: "proposed", at: "2026-11-26T21:04:22Z", actor: "human:operator", revision: 12, decided_on: {"recorded":{"review_outcome":4}}}
- {from: "proposed", to: "active", at: "2026-11-26T21:04:22Z", actor: "human:operator", revision: 13, decided_on: {"recorded":{"review_outcome":4}}}
---
## Context

The repository `beyond10x/inference` wrote its quality definition against the formats at
commit `f139ecc` (2026-11-25). It is the first consumer of the formats outside this
repository. Finding 2: the definition needs "the number of executed units does not fall". The
consumer's proposal: a requirement with `coverage: executed` and
`reference: {kind: accepted_value}`.

At `7b01ea1`:

- `ratchet.specification.CoverageBounds` holds fixed bounds only
  (`spec/domains/specification.yaml:326-343`): no `better`, no accepted value.
- The design says that a coverage count can be a measurement with an accepted value, "so that
  the number of ignored tests may not rise" (`docs/design.md:162`), and the row "Test
  evidence" of § 4 lists the counts "as measurements" (`:503`). No shape reads a count as a
  measurement: a measurement's `output` is an `OutputName` that "an assessor declares"
  (`spec/domains/specification.yaml:86-92`), and the counts are no outputs.
- An assessor lists the counts it reports under `coverage`
  (`ratchet.assessor.Assessor.coverage`, `spec/domains/assessor.yaml:194-199`; the list
  `ratchet.assessor.CoverageCount`, `:41-43`).
- `spec/presets.test.sh`, rule `assessor`, refuses a measurement that names no output of the
  declaration (`spec/presets.test.sh:62-63`), and `spec/example-declarations.test.sh`, case 2,
  does the same for an example (`spec/example-declarations.test.sh:13`).

Decision taken (reversible, `AGENTS.md` § "Phase: implementation"): no new key. The output name
`coverage.<count>` is Ratchet's, as `run`, `run_time` and `queue_wait` are (`docs/design.md`
§ 3 "Value lists"): a measurement with `output: coverage.executed` reads the count `executed`
of the run's `evidence.coverage`, for a count its assessor lists under `coverage`. Such a
measurement is `exact`, a number, at the scope `run`, with no `unit` (it counts units of the
assessor's `coverage_unit`, which the evidence names), and it takes `better` and a reference
as any number does. The consumer's spelling, a key `coverage` on the requirement, is not
taken: a requirement names a measurement, and the measurement keeps the direction.

## Acceptance

Every outcome below is observable without a `ratchet` command.

A phrase with a space in it may wrap in a Markdown paragraph or a folded YAML summary. So where
an item says that `grep -F` finds such a phrase in a `.md` or `.yaml` file, that it finds
nothing or the phrase is gone, or that `grep -c` of it prints a count, the check reads the
joined text of the file: `tr -s '\n ' '  ' < <file> | grep -o -F '<phrase>' | wc -l` prints 1
where the item says it is found, 0 where it says nothing or gone, and the count where it names
one. A name without a space, a row of a table, a pattern with `^`, `$` or `-E`, a check that
prints the line it matches and a check that reads the output of another command read the file
line by line, as written.

1. `spec/domains/specification.yaml`: the summary of `ratchet.specification.OutputName` names
   the reserved form `coverage.<count>`, the counts of `ratchet.assessor.CoverageCount`, and
   that such a measurement is `exact`, at the scope `run` and without `unit`: `grep -cF
   'coverage.<count>' spec/domains/specification.yaml` prints a number above 0 (0 before), and
   `ess specify validate --path spec --strict-requires` exits 0.
2. `docs/design.md` § 3 "Evidence coverage": the sentence "A coverage count can also be a
   measurement with an accepted value" shows the form
   `ignored: {kind: exact, output: coverage.skipped, scope: run, better: lower}`: `grep -F
   'output: coverage.skipped' docs/design.md` finds it, nothing before.
3. `docs/design.md` § 3 "Value lists", the row "Scope, unit, output, ...": its last cell names
   `coverage.<count>` beside `run`, `run_time` and `queue_wait` as Ratchet's: `grep -F
   '`queue_wait`, and `coverage.<count>` are Ratchet' docs/design.md` finds it (before the
   cell ends "`run`, `run_time`, and `queue_wait` are Ratchet’s").
4. `docs/evidence-format.md` § 3, the text of `evidence.coverage`, holds the phrase "a
   measurement may read a count from here as `coverage.<count>`; it is no entry of `results`":
   `grep -F` finds it, nothing before.
5. `spec/presets.test.sh`, rule `assessor`: the accepted copy `coverage-count-measurement`,
   with a requirement `executed-does-not-fall` on a measurement with `output:
   coverage.executed` of `conformance-cases@1`, `better: higher` and an accepted value, is
   accepted. Before the story the same measurement is refused with the message that the
   declaration declares no such output.
6. `spec/presets.test.sh`: four cases are each refused with the message of the rule
   `assessor`, named "a coverage count the declaration does not list", "a coverage count with
   a unit", "a coverage count that is sampled" and "a coverage name that is no count"
   (`coverage.passed_ids`). Before the story none of the four names is in the script
   (`grep -c` prints 0 for each).
7. `spec/example-declarations.test.sh`, case 2: the copy `valid-forms` holds an example
   measurement on `coverage.<count>` of a count its assessor lists, and is accepted: `grep -c
   'coverage\.' spec/example-declarations.test.sh` prints a number above 0 (0 before).
8. `spec/example-declarations.test.sh`: the broken copy `rule-2-coverage-count`, an example
   measurement on a count its assessor does not list, is refused with the message of case 2:
   `grep -c '^copy rule-2-coverage-count$' spec/example-declarations.test.sh` prints 1 (0
   before).

## Notes

- An addition to a released format: a file written before the change stays valid. The name
  `coverage.<count>` is reserved, and no output of the catalog or the examples has a name with
  a dot.
- A count that a record leaves out or names under `at_least`: this story writes no rule for
  it. The rule is unit 2's, `story:coverage-count-lower-bound`, which writes into
  `docs/design.md` § 3 "Evidence coverage" what a bound does with "a count that the run does
  not know" (its item 16), and `story:coverage-count-lower-bound-in-ratchet` makes the verdict.
- The parts that need the command are `story:coverage-count-with-reference-in-ratchet`:
  `ratchet validate` holding the form to the declaration with a code, and
  `ratchet evaluate --gate` giving fail when `executed` is below the accepted value. It waits
  for the waves to 0.1.0.
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of `.engineering/waves/0.1.0-ahead-2.md`,
  into one wave built in sequence on one branch: every planned wave starts behind
  `story:cli-skeleton-validate`, which waits for a release of ESS (beyond10x/ess#836), and this
  part needs no `ratchet` command. It is 15 of the 33 in the order of that page.
- 2 (`story:coverage-count-lower-bound`) changes `ratchet.evidence.EvidenceCoverage` and
  `docs/evidence-format.md` § 3 `evidence.coverage` before it; 16
  (`story:coverage-bound-on-failed-units`) changes the paragraph of § 3 "Evidence coverage"
  that names the count keys of a plan, the one before the sentence this story changes, after
  it.
- The line of the wave's changelog: under `### Added`, naming `coverage.<count>` (written by
  the story that closes the wave, `AGENTS.md` § "Changelog lines").
- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s; new broken
  copies are timed before they are added.
