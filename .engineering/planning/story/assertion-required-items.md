---
format: aep.planning-md/3
id: story:assertion-required-items
kind: story
status: draft
title: A plan names the items an assertion must have
summary: An assertion takes no reference, so no set names the expectations that must be there; one bound covers both endpoints of health-readiness@1.
relations:
- decomposes: epic:preset-catalog
- depends_on: story:preset-catalog-runtime
scope:
- confidence: cited
  path: CHANGELOG.md
- confidence: cited
  path: docs/design.md
- confidence: inferred
  path: presets/health-readiness@2.preset.yaml
- confidence: cited
  path: presets/operability.md
- confidence: cited
  path: spec/domains/specification.yaml
revision: 12
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

1. `spec/domains/specification.yaml`: `Measurement` (`:162-230`) holds
   `min_items: Optional<Integer>` and `required_items: Optional<List<String>>`, with the
   invariants `min_items >= 1` and that neither stands on the scope `run`; the summaries give
   the verdict and the cause. Checked by `ess specify validate --path spec --strict-requires`,
   which exits 0, and by `task check:generated`.
2. `docs/design.md` § 3 "Comparisons" (the bullet on assertions, `:199`): a requirement over a
   measurement with `min_items` or `required_items` is insufficient evidence with the cause
   `coverage_below_plan` when its result holds fewer items or lacks one, and names them;
   `holds` over no item is no pass where the measurement states `min_items`. § 3 "Evidence
   coverage" says that these bound the items of one measurement and the coverage bounds the
   units of the plan. Text only, no case.
3. `presets/health-readiness@2.preset.yaml` (new) is `health-readiness@1` with `min_items: 1`
   on `health` and on `readiness`; `health-readiness@1` stays byte for byte.
   `presets/operability.md` has the section `health-readiness@2` with its rows, and its point 3
   (`:178-186`) says that `min_items` answers it from `health-readiness@2` on. Checked by
   `spec/presets.test.sh`, rules `place`, `type` and `row`: before the story a preset with
   `min_items` is refused (rule `place`), after it its last line counts one more file and two
   more measurements with a row.
4. `CHANGELOG.md` has its line under `## [Unreleased]`, in the form
   `.github/scripts/release.test.sh` checks.

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
- 18 (`story:list-item-statement`) adds a third member of `Measurement` about scope items after
  it; 19 (`story:min-samples-per-scope-item`) adds a bound per item after that, beside these.
- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s.
