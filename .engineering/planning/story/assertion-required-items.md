---
format: aep.planning-md/3
id: story:assertion-required-items
kind: story
status: implemented
title: A plan names the items an assertion must have
summary: An assertion takes no reference, so no set names the expectations that must be there; one bound covers both endpoints of health-readiness@1.
relations:
- decomposes: epic:preset-catalog
- depends_on: story:preset-catalog-runtime
scope:
- confidence: cited
  path: docs/design.md
- confidence: inferred
  path: presets/health-readiness@2.preset.yaml
- confidence: cited
  path: presets/operability.md
- confidence: cited
  path: spec/domains/specification.yaml
revision: 18
transitions:
- {from: "draft", to: "proposed", at: "2026-11-26T21:04:22Z", actor: "human:operator", revision: 16, decided_on: {"recorded":{"review_outcome":4}}}
- {from: "proposed", to: "active", at: "2026-11-26T21:04:22Z", actor: "human:operator", revision: 17, decided_on: {"recorded":{"review_outcome":4}}}
- {from: "active", to: "implemented", at: "2026-11-26T23:39:03Z", actor: "human:operator", revision: 18, decided_on: {"recorded":{"test_result":1,"review_outcome":4}}}
---
## Context

Point 3 of "Not expressible yet" on `presets/operability.md` (`:178-186`,
`story:preset-catalog-runtime`), and finding 3 of
`review-result:adversary-preset-catalog-runtime-attack-1`. First consumer: the catalog, and
every project that binds `health-readiness@1`.

At `7b01ea1`:

- An assertion takes no reference (`docs/design.md:195`, row "Assertion": `holds`, reference
  "None"); `ratchet.specification.ReferenceKind` is `[generated, accepted_value]`
  (`spec/domains/specification.yaml:558-560`). So no accepted set names the expectations that
  must be there, as one does for a set with `no_lost_items`.
- `holds` requires the assertion for every item of the scope, and the result names the items
  where it does not hold (`docs/design.md:199`). Over no item it holds.
- A plan bounds the number of executed units through `CoverageBounds` (`:326-343`), which does
  not see one expectation replaced by another and counts the plan, not a measurement;
  `executed_ids` names an exact set, which a run with one more expectation no longer is.
- In `health-readiness@1` the one `executed` bound (`min_expectations`) is over both endpoints
  (`presets/health-readiness@1.preset.yaml:24`), and the measurements `health` and `readiness`
  read the scope `expectation` (`:25-33`): a report whose expectations are all on the health
  endpoint is inside the bound, and the requirement on readiness reads no item and holds.
- A scope item the reference holds and the evidence does not is insufficient evidence with the
  cause `coverage_below_plan` (`docs/design.md:158`; `spec/domains/gate.yaml:46-52`).

Decision taken (reversible, `AGENTS.md` § "Phase: implementation"): two members of
`ratchet.specification.Measurement`, for a measurement at a scope other than `run`:
`min_items`, the fewest items of its scope the result holds (a bound per group, where each
measurement is a group), and `required_items`, a least set of item names the result holds and
may exceed. A result below either is insufficient evidence with the cause
`coverage_below_plan`, naming the missing items or the count, as for an item of a reference
that the run lacks (`docs/design.md:158`), and not a fail: what is missing was not checked.
They apply to every value type with items, and an assertion is the first user.

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
   `min_items: Optional<Integer>` and `required_items: Optional<List<String>>`: `grep -c
   'name: min_items$\|name: required_items$' spec/domains/specification.yaml` prints 2 (0
   before), and `ess specify validate --path spec --strict-requires` exits 0.
2. `Measurement` states the invariants `min_items >= 1` and that neither member stands on the
   scope `run`, the first written `- any: ["not defined(min_items)", "min_items >= 1"]`:
   `grep -cF '"min_items >= 1"' spec/domains/specification.yaml` prints 1 (0 before).
3. The summaries of the two members hold the phrase "insufficient evidence with the cause
   `coverage_below_plan`". The summaries are folded and the phrase wraps, so the count reads
   the joined text: `tr -s '\n ' '  ' < spec/domains/specification.yaml | grep -o -F
   'insufficient evidence with the cause `coverage_below_plan`' | wc -l` prints 2 more than
   before the story (1 at `7b01ea1`, a summary where the phrase wraps; `grep -c` line by line
   prints 0 there).
4. `docs/design.md` § 3 "Comparisons", the bullet on assertions, holds the phrase "fewer items
   than `min_items` or without an item of `required_items` is insufficient evidence": `grep
   -F` finds it, nothing before.
5. The same bullet holds the phrase "`holds` over no item is no pass where the measurement
   states `min_items`": `grep -F` finds it, nothing before.
6. `docs/design.md` § 3 "Evidence coverage" holds the phrase "`min_items` and
   `required_items` bound the items of one measurement": `grep -F` finds it, nothing before.
7. `presets/health-readiness@2.preset.yaml` exists: `health-readiness@1` with `min_items: 1` on
   `health` and on `readiness` (`grep -c 'min_items: 1'` of the file prints 2).
   `sh spec/presets.test.sh` exits 0 with the file in the catalog; before the story the same
   file is refused there by the rule `place` (`min_items` is no field of `Measurement`).
   `health-readiness@1` stays byte for byte (`git diff --quiet 7b01ea1 --
   presets/health-readiness@1.preset.yaml` exits 0).
8. `presets/operability.md` has the section `health-readiness@2` with the rows of
   `health-readiness@2/probes/health` and `health-readiness@2/probes/readiness`: `grep -c
   '`health-readiness@2/probes/' presets/operability.md` prints 2 (0 before).
9. `presets/operability.md`, "Not expressible yet", point 3, rewritten in place, holds the
   phrase "Answered from `health-readiness@2` on": `grep -F` finds it, nothing before.

## Notes

- The draft said that `ratchet evaluate` fails such a requirement. The story decides
  insufficient evidence with `coverage_below_plan` instead, the verdict the design gives an
  item of a reference that the run lacks; a project that wants the missing item as a fail
  writes `holds` with `required_items` and reads the cause.
- `spec/presets.test.sh` checks no invariant of `Measurement` (its header, "Not checked"); the
  two invariants are checked by the decoder of `story:cli-skeleton-validate`.
- Related and not the same: `story:item-field-values` (the values a field of an item may
  hold), `story:min-samples-per-scope-item` (19, the samples of each item).
- An addition to a released format; a preset that uses it is a new version of the preset.
- The parts that need the command are `story:assertion-required-items-in-ratchet`: the verdict
  of `ratchet evaluate --gate` on a result that lacks a required item. It waits for the waves
  to 0.1.0.
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of `.engineering/waves/0.1.0-ahead-2.md`,
  into one wave built in sequence on one branch: every planned wave starts behind
  `story:cli-skeleton-validate`, which waits for a release of ESS (beyond10x/ess#836), and this
  part needs no `ratchet` command. It is 17 of the 33 in the order of that page.
- The line of the wave's changelog: under `### Added`, naming `min_items` (written by the story
  that closes the wave, `AGENTS.md` § "Changelog lines").
- 18 (`story:list-item-statement`) adds a third member of `Measurement` about scope items after
  it; 19 (`story:min-samples-per-scope-item`) adds a bound per item after that, beside these.
- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s.
