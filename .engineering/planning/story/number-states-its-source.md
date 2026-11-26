---
format: aep.planning-md/3
id: story:number-states-its-source
kind: story
status: draft
title: A limit or a tolerance of a ratchet/1 file states its source
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
revision: 11
---
## Context

Found by a consumer writing a `ratchet/1` file at 0.0.3: the file has no field for the source
of a number, read here as where a limit or a tolerance of the file comes from (a decision, a
commitment to someone, an earlier measurement) and since when it holds.

At `7b01ea1`:

- A `Condition` holds `operator`, `value` and `unit` (`spec/domains/specification.yaml:536-555`),
  and a `Tolerance` holds `percent` and `absolute` (`:562-576`).
- The only text on a requirement is `meaning`, free prose that `ratchet explain` prints
  (`:989-991`; `docs/design.md:744`).
- A gate decision records the limit as a `Condition` (`ratchet.gate.RequirementVerdict.allowed`,
  `spec/domains/gate.yaml:241-243`), and an exception that raises a limit holds a `Condition`
  too (`ratchet.specification.Exception.value`, `spec/domains/specification.yaml:1146-1150`).
  The gate report types a limit as `ratchet.cli.LimitRow` (`operator`, `value`, `unit`;
  `spec/domains/cli.yaml:53-60`).
- The records hold a source only for an imported run (`docs/evidence-format.md` § 3,
  `evidence.source`).
- A date of a file is a `ratchet.specification.CalendarDate` (`:28-35`).

Decision taken (reversible, `AGENTS.md` § "Phase: implementation"): a new struct
`ratchet.specification.NumberSource` with `cites` (required text: a path, a URL, or an id such
as `decision:<id>`) and `since` (an optional `CalendarDate`), and a member
`source: Optional<NumberSource>` on `Condition` and on `Tolerance`. It is prose for a reader:
no rule reads it, and no verdict depends on it. On `Condition` it reaches the gate decision
through `allowed` without a new member there. The gate report and `ratchet explain` type a
limit as `ratchet.cli.LimitRow`, which gets the member `source` of the same type in this
story, so `task generate` rewrites the generated crate.

## Acceptance

Every outcome below is observable without a `ratchet` command.

1. `spec/domains/specification.yaml` declares the struct `ratchet.specification.NumberSource`
   with `cites` (`String`) and `since` (`Optional<ratchet.specification.CalendarDate>`):
   `grep -c 'name: ratchet.specification.NumberSource$' spec/domains/specification.yaml`
   prints 1 (0 before).
2. `ratchet.specification.Condition` and `ratchet.specification.Tolerance` each hold
   `source: Optional<ratchet.specification.NumberSource>`: `grep -cF 'type:
   Optional<ratchet.specification.NumberSource>' spec/domains/specification.yaml` prints 2 (0
   before), and `ess specify validate --path spec --strict-requires` exits 0.
3. The summary of `NumberSource` holds the phrase "printed beside the allowed value and judged
   by nothing": `grep -F` finds it in `spec/domains/specification.yaml`, nothing before.
4. `spec/domains/cli.yaml`: `ratchet.cli.LimitRow` holds
   `source: Optional<ratchet.specification.NumberSource>`, so the gate report and
   `ratchet explain` carry the source of a limit: `grep -cF 'type:
   Optional<ratchet.specification.NumberSource>' spec/domains/cli.yaml` prints 1 (0 before).
5. `task generate` rewrites `crates/ratchet-cli-contract/` in the same change and
   `task check:generated` exits 0: `grep -c '"cites"' crates/ratchet-cli-contract/binding.json`
   prints a number above 0 (0 before), and no hand-written file under `crates/` changes.
6. `docs/design.md` § 3 "Comparisons", a bullet holds the example
   `source: {cites: decision:2026-03-quality-review, since: 2026-03-01}` and says that a file
   without it stays valid and that `ratchet explain` and the gate report print it beside the
   allowed value: `grep -F 'cites: decision:2026-03-quality-review' docs/design.md` finds it,
   nothing before.
7. `docs/design.md` § 3 "Illustrative project YAML" shows `source:` once on a condition, so
   `grep -c 'source: {cites:' docs/design.md` prints 2, the bullet of item 6 and the YAML (0
   before).
8. `spec/presets.test.sh`: the accepted copy `condition-and-tolerance-with-source`, whose
   requirement has `condition: {operator: lte, value: 3, unit: cases, source: {cites:
   decision:x}}` and a tolerance with a `source`, is accepted. Before the story the same
   requirement is refused (rule `place`: `source` is no declared field).
9. `spec/presets.test.sh`: the case "a source without cites" (`source: {since: 2026-03-01}`)
   is refused with the message of the rule `required`; before the story the name is not in
   the script (`grep -c` prints 0).

## Notes

- An addition to a released format: a file written before the change stays valid.
- The parts that need the command are `story:number-states-its-source-in-ratchet`: the output
  of `ratchet explain` and of the gate report, filling the member `source` of
  `ratchet.cli.LimitRow` that this story declares. It waits for the waves to 0.1.0.
- It changes `spec/domains/cli.yaml`, so it runs `task generate` and `task check:generated`;
  11 (`story:requirement-states-a-range`) changed `LimitRow` before it.
- The line of the wave's changelog: under `### Added`, naming `NumberSource` (written by the story
  that closes the wave, `AGENTS.md` § "Changelog lines").
- Filed under `epic:format-gaps-first-format-consumer` as the closest epic: an addition to
  `ratchet/1` for a consumer's definition. Related: `story:list-item-statement` (18), a
  statement on an item of a list.
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of `.engineering/waves/0.1.0-ahead-2.md`,
  into one wave built in sequence on one branch: every planned wave starts behind
  `story:cli-skeleton-validate`, which waits for a release of ESS (beyond10x/ess#836), and this
  part needs no `ratchet` command. It is 14 of the 33 in the order of that page.
- 10 to 12 change `Condition` and the bullets of "Comparisons" before it; this story adds the
  last member of the wave to `Condition`.
- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s; new copies
  are timed before they are added.
