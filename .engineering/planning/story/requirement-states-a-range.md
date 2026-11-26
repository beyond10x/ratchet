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
  path: crates/ratchet-cli-contract
- confidence: cited
  path: docs/design.md
- confidence: cited
  path: spec/domains/cli.yaml
- confidence: cited
  path: spec/domains/specification.yaml
- confidence: cited
  path: spec/presets.test.sh
revision: 10
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
executed` (`spec/domains/evidence.yaml:272-273`), so the decoder refuses a range whose lower
bound is above its upper bound, and `spec/presets.test.sh` refuses it in a preset.
`ratchet.cli.LimitRow` (`spec/domains/cli.yaml:53-60`) gets `min` and `max` beside `value`, so
the gate report and `ratchet explain` show a range as one limit; this story declares them, and
`task generate` rewrites the generated crate.

## Acceptance

Every outcome below is observable without a `ratchet` command.

1. `spec/domains/specification.yaml`: `within` is a variant of
   `ratchet.specification.ComparisonOperator`: `grep -cF 'holds, within'
   spec/domains/specification.yaml` prints 1 (0 before; the list ends at `holds`).
2. `ratchet.specification.Condition` holds `min` and `max` as `Optional<Decimal>`:
   `awk '/name: ratchet.specification.Condition$/,/name: ratchet.specification.ReferenceKind$/'
   spec/domains/specification.yaml | grep -c 'name: m[ia][nx]$'` prints 2 (0 before), and
   `ess specify validate --path spec --strict-requires` exits 0.
3. `Condition` states the invariants that `within` has both bounds and no `value`, that `min`
   and `max` stand on no other operator, and the order of the bounds, written
   `- any: ["operator != within", "min <= max"]`: `grep -cF '"min <= max"'
   spec/domains/specification.yaml` prints 1 (0 before).
4. `spec/domains/cli.yaml`: `ratchet.cli.LimitRow` holds `min` and `max` as
   `Optional<String>`, the exact decimal text as its `value` is, so the gate report and
   `ratchet explain` carry a range as one limit: `grep -c 'name: m[ia][nx]$'
   spec/domains/cli.yaml` prints 2 (0 before).
5. `task generate` rewrites `crates/ratchet-cli-contract/` in the same change and
   `task check:generated` exits 0: `grep -c '"within"'
   crates/ratchet-cli-contract/binding.json` prints a number above 0 (0 before), and no
   hand-written file under `crates/` changes.
6. `docs/design.md` § 3 "Comparisons", the table: the rows "Number" and "Identity set" name
   the phrase "`within` with `min` and `max`": `grep -cF` of that phrase in `docs/design.md`
   prints 2 (0 before).
7. `docs/design.md` § 3 "Comparisons", a bullet below the table holds the phrase "both bounds
   are inclusive and in the unit of the measurement": `grep -F` finds it, nothing before.
8. The same bullet holds the phrase "outside the range fails with the cause `limit_crossed`
   and names the bound crossed": `grep -F` finds it, nothing before.
9. `docs/design.md` § 3 "Value lists", the row "Operator", holds `within`: `grep -F '|
   Operator |' docs/design.md` prints a line with `` `within` `` (without it before).
10. `spec/presets.test.sh`, rule `compare`: the accepted copy `compare-within`, whose preset
    requirement has `condition: {operator: within, min: 50, max: 60, unit: s}` on a number
    output in seconds, is accepted. Before the story the same requirement is refused (rule
    `type`: `within` is no variant).
11. `spec/presets.test.sh`: four cases are each refused with the message of the rule
    `compare`, named "a range with a value", "a range without max", "min on the operator
    lte" and "a range whose min is above its max" (`min: 60, max: 50`). Before the story none
    of the four names is in the script (`grep -c` prints 0 for each).

## Notes

- An addition to a released format: a file written before the change stays valid, and a range
  written as two requirements stays valid.
- The parts that need the command are `story:requirement-states-a-range-in-ratchet`: the
  refusal by `ratchet validate` of a range whose `min` is above its `max`, a verdict of
  `ratchet evaluate --gate` outside the range that names the bound crossed, and the gate
  report filling `min` and `max` of `ratchet.cli.LimitRow`. It waits for the waves to 0.1.0.
- It changes `spec/domains/cli.yaml`, so it runs `task generate` and `task check:generated`.
- The line of the wave's changelog: under `### Added`, naming `within` (written by the story
  that closes the wave, `AGENTS.md` § "Changelog lines").
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
