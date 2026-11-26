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
  path: CHANGELOG.md
- confidence: cited
  path: docs/design.md
- confidence: cited
  path: spec/domains/specification.yaml
- confidence: cited
  path: spec/presets.test.sh
revision: 6
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
through `allowed` without a new member there.

## Acceptance

Every outcome below is observable without a `ratchet` command.

1. `spec/domains/specification.yaml`: `ratchet.specification.NumberSource` is declared, and
   `Condition` (`:536-555`, with `digest`, `min`, `max` and `against` that stories 10 to 12
   added) and `Tolerance` (`:562-576`) hold `source: Optional<NumberSource>`; the summaries say
   that the source is printed beside the allowed value and judged by nothing. Checked by
   `ess specify validate --path spec --strict-requires`, which exits 0, and by
   `task check:generated`.
2. `docs/design.md` § 3 "Comparisons": a bullet says that a limit and a tolerance may state
   their source, `source: {cites: decision:2026-03-quality-review, since: 2026-03-01}`, that a
   file without it stays valid, and that `ratchet explain` and the gate report print it beside
   the allowed value; the YAML of § 3 "Illustrative project YAML" (`:231`) shows it once on a condition.
   Text only, no case.
3. `spec/presets.test.sh`: before the story a preset requirement with
   `condition: {operator: lte, value: 3, unit: cases, source: {cites: decision:x}}` is refused
   (rule `place`, `source` is no declared field). After it, a copy with that condition and a
   tolerance with a `source` is accepted, and a copy with `source: {since: 2026-03-01}` and no
   `cites` is refused by the rule `required`.
4. `CHANGELOG.md` has its line under `## [Unreleased]`, in the form
   `.github/scripts/release.test.sh` checks.

## Notes

- An addition to a released format: a file written before the change stays valid.
- The parts that need the command are `story:number-states-its-source-in-ratchet`: the output
  of `ratchet explain` and of the gate report, and the member of `ratchet.cli.LimitRow` that
  carries the source. It waits for the waves to 0.1.0.
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
