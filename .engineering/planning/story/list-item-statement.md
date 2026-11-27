---
format: aep.planning-md/3
id: story:list-item-statement
kind: story
status: implemented
title: An item of a list carries a statement of what it stands for
summary: A plan states per item of a passed list or of a scope what the item bounds or asserts.
relations:
- decomposes: epic:format-gaps-first-format-consumer
scope:
- confidence: cited
  path: crates/ratchet-cli-contract
- confidence: cited
  path: docs/design.md
- confidence: cited
  path: spec/domains/cli.yaml
- confidence: cited
  path: spec/domains/specification.yaml
- confidence: cited
  path: spec/presets.test.sh
revision: 21
transitions:
- {from: "draft", to: "proposed", at: "2026-11-26T21:04:22Z", actor: "human:operator", revision: 19, decided_on: {"recorded":{"review_outcome":4}}}
- {from: "proposed", to: "active", at: "2026-11-26T21:04:22Z", actor: "human:operator", revision: 20, decided_on: {"recorded":{"review_outcome":4}}}
- {from: "active", to: "implemented", at: "2026-11-26T23:39:03Z", actor: "human:operator", revision: 21, decided_on: {"recorded":{"test_result":1,"review_outcome":4}}}
---
## Context

The repository `beyond10x/inference` wrote the second unit of its quality definition against
the formats at commit `f139ecc` (2026-11-25). It is the first consumer of the formats outside
this repository. Finding 23: a list input cannot give one item a meaning of its own. An
assessment of time bounds lists its tests as a declared input, and its record has one result
per test. The list cannot say which constant a test bounds, or whether a test asserts the
default value or only the mechanism.

At `7b01ea1`:

- A declared input has a type, `list`, `required`, a default and `local`, and no text per value
  (`ratchet.specification.InputDeclaration`, `spec/domains/specification.yaml:732-767`).
- A requirement names a whole measurement and no single item of it
  (`ratchet.specification.QualityRequirement`, `:975-1025`); its one text is `meaning`
  (`:989-991`), which `ratchet explain` prints (`docs/design.md:744`).
- A result belongs to one scope item, and the assessor reports each result at the scope where
  it was observed (`docs/design.md` § 3 "Scope and aggregation", `:120-124`); a measurement
  with a scope other than `run` gives one result per item.

Decision taken (reversible, `AGENTS.md` § "Phase: implementation"): the statement belongs to
the measurement, not to the input: a member `meanings` of
`ratchet.specification.Measurement`, a map from a scope item to what it stands for, at a scope
other than `run`. The items of the consumer's list are the items of the scope `test` of its
measurement, so the map says what each test bounds. An item of the map that no result of a run
holds is reported by the command, not refused by the decoder: the items of a scope are known
only from a run. The reports of `ratchet explain` and of the gate (`ratchet.cli.Explanation`
and `ratchet.cli.VerdictRow`, `spec/domains/cli.yaml`) get `meanings`, and the gate row
`meanings_without_result` for a statement whose item no result holds; this story declares
them, and `task generate` rewrites the generated crate.

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

1. `spec/domains/specification.yaml`: `ratchet.specification.Measurement` holds
   `meanings: Optional<Map<String, String>>`: `grep -c 'name: meanings$'
   spec/domains/specification.yaml` prints 1 (0 before), and `ess specify validate --path
   spec --strict-requires` exits 0.
2. `Measurement` states the invariant that `meanings` does not stand on the scope `run`,
   written `- any: ["not defined(meanings)", "scope != run"]`: `grep -cF '"not
   defined(meanings)"' spec/domains/specification.yaml` prints 1 (0 before).
3. The summary of `meanings` holds the phrase "shown beside the result of the item": `grep -F`
   finds it in `spec/domains/specification.yaml`, nothing before.
4. `spec/domains/cli.yaml`: `ratchet.cli.Explanation` and `ratchet.cli.VerdictRow` each hold
   `meanings: Optional<Map<String, String>>`, the statements of the scope items of the
   requirement's measurement, and `VerdictRow` holds `meanings_without_result:
   Optional<List<String>>`, the items of `meanings` that no result of the run holds: `grep -c
   'name: meanings$' spec/domains/cli.yaml` prints 2 and `grep -c 'name:
   meanings_without_result$' spec/domains/cli.yaml` prints 1 (0 before each).
5. `task generate` rewrites `crates/ratchet-cli-contract/` in the same change and
   `task check:generated` exits 0: `grep -c '"meanings_without_result"'
   crates/ratchet-cli-contract/binding.json` prints a number above 0 (0 before), and no
   hand-written file under `crates/` changes.
6. `docs/design.md` § 3 "Scope and aggregation": a paragraph shows a measurement of the scope
   `test` whose `meanings` say what two tests bound, and holds the phrase "a list input gets
   its statements through the measurement whose scope items it names": `grep -F` finds the
   phrase, nothing before.
7. `spec/presets.test.sh`: the accepted copy `measurement-meanings`, whose measurement at a
   scope other than `run` holds `meanings: {case-1: "the default timeout"}`, is accepted.
   Before the story the same measurement is refused (rule `place`: `meanings` is no declared
   field).
8. `spec/presets.test.sh`: the case "a statement of meanings is a number" is refused with the
   message of the rule `type`; before the story the name is not in the script (`grep -c`
   prints 0).

## Notes

- An addition to a released format: a file written before the change stays valid.
- The parts that need the command are `story:list-item-statement-in-ratchet`: `ratchet
  explain` and the gate report showing a statement beside the result of its item, and the
  report naming a statement whose item no result holds, filling the members of
  `spec/domains/cli.yaml` that this story declares. It waits for the waves to 0.1.0.
- It changes `spec/domains/cli.yaml`, so it runs `task generate` and `task check:generated`.
  `ratchet.cli.VerdictRow` is changed again later in the wave by 26
  (`story:new-item-without-accepted-value`) and 32 (`story:gate-joins-revision-and-document`).
- The line of the wave's changelog: under `### Added`, naming `meanings` (written by the story
  that closes the wave, `AGENTS.md` § "Changelog lines").
- The story no longer writes into `docs/evidence-format.md` or `crates/ratchet-core`: a record
  carries no statement, and the code is the command part's.
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of `.engineering/waves/0.1.0-ahead-2.md`,
  into one wave built in sequence on one branch: every planned wave starts behind
  `story:cli-skeleton-validate`, which waits for a release of ESS (beyond10x/ess#836), and this
  part needs no `ratchet` command. It is 18 of the 33 in the order of that page.
- 17 (`story:assertion-required-items`) adds two members of `Measurement` about scope items
  before it; 19 (`story:min-samples-per-scope-item`) adds a bound per scope item after it.
  Related: `story:number-states-its-source` (14), the source of a limit.
- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s; new copies
  are timed before they are added.
