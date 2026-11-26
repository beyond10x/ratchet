---
format: aep.planning-md/3
id: story:list-item-statement
kind: story
status: draft
title: An item of a list carries a statement of what it stands for
summary: A plan states per item of a passed list or of a scope what the item bounds or asserts.
relations:
- decomposes: epic:format-gaps-first-format-consumer
scope:
- confidence: cited
  path: CHANGELOG.md
- confidence: cited
  path: docs/design.md
- confidence: cited
  path: spec/domains/specification.yaml
- confidence: cited
  path: spec/presets.test.sh
revision: 13
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
only from a run.

## Acceptance

Every outcome below is observable without a `ratchet` command.

1. `spec/domains/specification.yaml`: `Measurement` (`:162-230`, with `min_items` and
   `required_items` that story 17 added) holds `meanings: Optional<Map<String, String>>`, with
   the invariant that it does not stand on the scope `run`; its summary says that `ratchet
   explain` and the gate report show the statement beside the result of the item. Checked by
   `ess specify validate --path spec --strict-requires`, which exits 0, and by
   `task check:generated`.
2. `docs/design.md` § 3 "Scope and aggregation" (`:120-124`): a paragraph with a measurement of
   the scope `test` whose `meanings` say what two tests bound, and the sentence that a list
   input gets its statements through the measurement whose scope items it names. Text only,
   no case.
3. `spec/presets.test.sh`: before the story a preset measurement with `meanings` is refused
   (rule `place`). After it, a copy whose measurement at a scope other than `run` holds
   `meanings: {case-1: "the default timeout"}` is accepted, and a copy whose `meanings` holds
   a number as a statement is refused by the rule `type`.
4. `CHANGELOG.md` has its line under `## [Unreleased]`, in the form
   `.github/scripts/release.test.sh` checks.

## Notes

- An addition to a released format: a file written before the change stays valid.
- The parts that need the command are `story:list-item-statement-in-ratchet`: `ratchet
  explain` and the gate report showing a statement beside the result of its item, and the
  report naming a statement whose item no result holds. It waits for the waves to 0.1.0.
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
