---
format: aep.planning-md/3
id: story:requirement-states-a-range
kind: story
status: draft
title: A requirement states a range of a number
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
  path: spec/domains/specification.yaml
- confidence: cited
  path: spec/presets.test.sh
revision: 7
---
## Context

Found by a consumer writing a `ratchet/1` file at 0.0.3. A value is good inside a range, such
as 50 to 60 s, and the file needs two requirements to say so.

At `7b01ea1`:

- A requirement compares in up to two ways, `condition` with a fixed limit and `reference` with
  the protected reference (`docs/design.md:188`). `ratchet.specification.QualityRequirement`
  holds one `condition` (`spec/domains/specification.yaml:1002-1003`), and a `Condition` is one
  `operator` with one `value` and a `unit` (`:536-555`).
- `ratchet.specification.ComparisonOperator` is `[lt, lte, gt, gte, eq, no_new_items,
  no_lost_items, holds]` (`:532-534`); the list "Operator" of `docs/design.md` § 3 "Value
  lists" says the same (`:216`), and the table "Comparisons" gives a number and the number of
  items of a set the five operators with a `value` (`:192-193`).
- `ratchet.cli.LimitRow` types its `operator` with that enum (`spec/domains/cli.yaml:53-60`),
  so a new operator reaches the generated crate `crates/ratchet-cli-contract/`.
- `spec/presets.test.sh`, rule `compare`: "`lt`, `lte`, `gt`, `gte` and `eq` take a number or
  a set and have a `value`" (`spec/presets.test.sh:85-89`).
- A range is two requirements on one measurement: two verdicts, two gate entries, and nothing
  that says the two bounds belong together.

Decision taken (reversible, `AGENTS.md` § "Phase: implementation"): the story builds the form
and is not rejected. A new operator `within` takes the members `min` and `max` of the
`Condition`, both in the unit of the measurement and both inclusive, and no `value`. It applies
where the five operators with a `value` apply: a number, and the number of items of a set. An
invariant states `min <= max`, as `ratchet.evidence.EvidenceCoverage` states `passed <=
executed` (`spec/domains/evidence.yaml:271-272`), so the decoder refuses a range whose lower
bound is above its upper bound.

## Acceptance

Every outcome below is observable without a `ratchet` command.

1. `spec/domains/specification.yaml`: `within` is a variant of
   `ratchet.specification.ComparisonOperator` (`:532-534`), and `ratchet.specification.Condition`
   (`:536-555`, with the member `digest` that story 10 added) holds `min` and `max` as
   `Optional<Decimal>`, with the invariants: `within` has both and no `value`; `min` and `max`
   stand on no other operator; `min <= max`. The summary of `Condition` says that a verdict
   outside the range names the bound crossed. Checked by
   `ess specify validate --path spec --strict-requires`, which exits 0.
2. `task check:generated` exits 0: where the new variant changes `crates/ratchet-cli-contract/`
   (through `ratchet.cli.LimitRow.operator`), `task generate` rewrites it in the same change,
   and no hand-written file under `crates/` changes.
3. `docs/design.md` § 3: the table "Comparisons" (`:192-193`) gives a number and the number of
   items of a set `within` with `min` and `max`; a bullet below it says that both bounds hold,
   that each is inclusive and in the unit of the measurement, and that a verdict outside the
   range is a fail with the cause `limit_crossed` that names the bound crossed; the list
   "Operator" of "Value lists" (`:216`) holds `within`. Text only, no case.
4. `spec/presets.test.sh`, rule `compare`: `within` takes a number or a set and has `min` and
   `max` and no `value`. Before the story a preset requirement with
   `condition: {operator: within, min: 50, max: 60, unit: s}` is refused (rule `type`: the
   operator is no variant). After it, a copy with that requirement is accepted, and a copy
   with `within` and a `value`, one with `within` and no `max`, and one with `min` on `lte` are
   each refused with the message of the rule. The line of defects counts the three new ones.
5. `CHANGELOG.md` has its line under `## [Unreleased]`, in the form
   `.github/scripts/release.test.sh` checks.

## Notes

- An addition to a released format: a file written before the change stays valid, and a range
  written as two requirements stays valid.
- The parts that need the command are `story:requirement-states-a-range-in-ratchet`: a verdict
  of `ratchet evaluate --gate` outside the range that names the bound crossed, and the gate
  report of a range as one limit. It waits for the waves to 0.1.0.
- Filed under `epic:format-gaps-first-format-consumer` as the closest epic: it holds the other
  changes to `ratchet.specification.Condition`.
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of `.engineering/waves/0.1.0-ahead-2.md`,
  into one wave built in sequence on one branch: every planned wave starts behind
  `story:cli-skeleton-validate`, which waits for a release of ESS (beyond10x/ess#836), and this
  part needs no `ratchet` command. It is 11 of the 33 in the order of that page.
- 10 (`story:condition-on-digest-value`) adds `digest` to `Condition` and the digest form to
  the rule `compare` and the row "Digest" before it; 12
  (`story:requirement-over-two-measurements`) adds the operator `subset_of` and the member
  `against` after it, in the same places, and `within` takes no `against`.
- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s; new broken
  copies are timed before they are added.
