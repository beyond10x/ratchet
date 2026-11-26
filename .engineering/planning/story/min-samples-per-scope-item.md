---
format: aep.planning-md/3
id: story:min-samples-per-scope-item
kind: story
status: draft
title: A plan bounds the samples of each scope item
relations:
- decomposes: epic:ci-turnaround
scope:
- confidence: cited
  path: CHANGELOG.md
- confidence: cited
  path: docs/design.md
- confidence: cited
  path: spec/domains/gate.yaml
- confidence: cited
  path: spec/domains/specification.yaml
revision: 6
---
## Context

Found by a consumer writing a `ratchet/1` file at 0.0.3: `min_samples` applies to a plan, and
the consumer needs it per subject, read here as per scope item. Line numbers are those of
`7b01ea1`.

`min_samples` is a member of `ratchet.specification.ObservationPlan`
(`spec/domains/specification.yaml:507-512`). On a time-window plan it counts the population
items of the window, and below it the verdict is insufficient evidence with the cause
`too_few_samples` (`docs/design.md:173`, the table of § 3 "Time windows"). A window measurement
at a scope other than `run` gives one value per item (`docs/design.md:179`). An item that
appears in 2 of 20 runs then has a value from 2 samples while the window has 20, and the plan's
bound passes it. A result carries its `samples` (`docs/evidence-format.md:168`;
`ratchet.evidence.MeasurementResult.samples`, `spec/domains/evidence.yaml:376-379`), and no
bound reads that number per item. § 5 "Verdicts" (`docs/design.md:619`) already judges a
requirement item by item where it has an accepted value per scope item, with a cause for one
item (`reference_missing`, `coverage_below_plan`).

The decision this story takes, the reversible one (`AGENTS.md` § "Phase: implementation"): the
bound is a member of the measurement, not of the plan. A plan holds measurements at several
scopes (§ 3 "Several measurements from one run", `docs/design.md:128`), so one bound per plan
would also bind the measurement at the scope `run`. The member is `min_samples_per_item`, a
whole number of at least 1, valid on a measurement at a scope other than `run`. Ratchet reads
it against the `samples` of each result; the assessor needs not learn it, so the answer of
`story:assessor-learns-observation` for `min_samples` is not extended to it.

## Acceptance

Every outcome below is observable without a `ratchet` command.

1. `spec/domains/specification.yaml`: `ratchet.specification.Measurement` (`:162`) has the
   member `min_samples_per_item` (`Optional<Integer>`), with the invariants
   `not defined(min_samples_per_item)` or `min_samples_per_item >= 1`, and
   `not defined(min_samples_per_item)` or `scope != "run"` (the form of the invariants of
   `ratchet.specification.AssessmentPlan` that compare with a literal, `:955-958`). Its
   summary says that an item whose result carries fewer `samples` is insufficient evidence with
   the cause `too_few_samples` for that item alone, and the other items are judged. Checked by
   `ess specify validate --path spec --strict-requires`, which exits 0, by step 12 of
   `task check:spec` (`ess generate synthesize`, no declaration refused), and by
   `task check:generated`. Before the story the key is no member of `Measurement`.
2. `docs/design.md` § 3 "Scope and aggregation" (`:120`): a paragraph states the bound per
   scope item, its key, that it is no bound of the plan, that it is refused at the scope `run`,
   and that it reads the `samples` of each result; the row `min_samples` of the table of § 3
   "Time windows" (`:173`) says that it counts the items of the window and that
   `min_samples_per_item` bounds the samples behind one item's value. Text only, no case.
3. `docs/design.md` § 5 "Verdicts", the case "A scope item on one side of a comparison"
   (`:619`): an item below `min_samples_per_item` is insufficient evidence with the cause
   `too_few_samples` for that item, and the other items are judged; the requirement's verdict
   follows the rule of "The verdict of a gate" as for the two causes there. Text only, no case.
4. `spec/domains/gate.yaml`: the comment above `ratchet.gate.InsufficientEvidenceCause`
   (`:46`), "`too_few_samples` covers a window with fewer items than `min_samples`", names the
   item below `min_samples_per_item` too. Checked by `ess specify validate`, exit 0.
5. `CHANGELOG.md` has its line under `## [Unreleased]`. Text only, no case.

## Notes

- Decision taken: a member of the measurement, not of the plan (§ Context). The alternative, a
  member of `ObservationPlan`, is named in the design paragraph of item 2 as not taken, with
  the reason.
- `spec/presets.test.sh` gets no rule: the refusal at the scope `run` is an invariant of the
  type, and its header lists the invariants of the types under "Not checked" (`:169-171`). No
  preset of the catalog uses the member in this story.
- An addition to a released format: a file written before the change stays valid.
- The command part, `ratchet validate` refusing the member at the scope `run` with a code and
  `ratchet evaluate` judging each item against it, is `story:min-samples-per-scope-item-in-ratchet`,
  which waits for the waves to 0.1.0 (`story:cli-skeleton-validate`, `story:evaluate-command`).
- Filed under `epic:ci-turnaround` as the closest epic: it holds sampled measurements and the
  first window.
- Related: `story:assessor-learns-observation` (5 of the wave: how an assessor learns
  `min_samples` of its plan), `story:new-item-without-accepted-value` (26 of the wave, which
  writes into the same case of § 5 "Verdicts" after this story).
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of `.engineering/waves/0.1.0-ahead-2.md`,
  into one wave built in sequence on one branch: every planned wave starts behind
  `story:cli-skeleton-validate`, which waits for a release of ESS (beyond10x/ess#836), and this
  part needs no `ratchet` command. It is 19 of the 33 in the order of that page. Before it,
  `story:list-item-statement` (18) changes `docs/design.md` and
  `spec/domains/specification.yaml`; after it, `story:machine-as-a-condition` (20) changes
  `ratchet.specification.ObservationConditions` and § 3 "Measurement kind and observation
  conditions".
- No script changes. The test step ends within 120 s, no test over 60 s.
