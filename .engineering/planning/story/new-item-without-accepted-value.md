---
format: aep.planning-md/3
id: story:new-item-without-accepted-value
kind: story
status: draft
title: A scope item with no accepted value of its own can be judged
relations:
- decomposes: epic:improvement-and-policy
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

Found by a consumer writing a `ratchet/1` file at 0.0.3: a new subject has no accepted value,
so values per subject cannot ratchet, only the level of the whole series.

Where a requirement has an accepted value per scope item, an item that the evidence holds and
the reference does not is `reference_missing` for that item, insufficient evidence
(`docs/design.md:619`, § 5 "Verdicts", "A scope item on one side of a comparison"). A reference
is adopted from evidence produced before the candidate (`:581`, rule 3 of "Protected
references"), and a gate with an enforced requirement of insufficient evidence does not pass
(`:623`, "The verdict of a gate"). When new items keep arriving, each one is
`reference_missing` on its first run, and a per-item requirement in an enforced entry never
passes. What remains is a measurement at the scope `run` that aggregates over the items.

`ratchet.specification.ReferenceDeclaration` (`spec/domains/specification.yaml:602`) holds
`kind`, `paths`, `tolerance` and `adoption`, and nothing that says how an item without a value
is judged. `ratchet.gate.RequirementVerdict` (`spec/domains/gate.yaml:195`) has one `cause`
for the requirement and no list of items left unjudged. "Adding an item is a loosening"
(`docs/design.md:597`, "Reference records") is written for an item of an accepted set; it says
nothing of a value per scope item. `ratchet.reference.ReferenceChangeKind`
(`spec/domains/reference.yaml:44-46`) has `first_adoption`, `regeneration`, `tightening`,
`loosening` and `trade_off`.

## Decision

The reversible answer, taken here (AGENTS.md § "Phase: implementation"): an optional member
`new_items` of `ReferenceDeclaration` with two values, `insufficient_evidence` (the default,
today's rule) and `not_judged`. Under `not_judged` an item the reference does not hold is left
out of the comparison, the requirement is judged over the other items, and the verdict lists
the item as not judged until a value for it is adopted. Adopting the value of such an item is
the first adoption of that item (`first_adoption`), not a loosening; adding an item to an
accepted set stays a loosening. The other form of the draft, judging the new item against a
value the reference holds for the series, is not taken: it needs a value for the series that
no reference record holds.

## Acceptance

Every outcome below is observable without a `ratchet` command.

1. `spec/domains/specification.yaml`: `ReferenceDeclaration` (`:602`) has the optional member
   `new_items` of a new closed enum with `insufficient_evidence` and `not_judged`, whose summary
   says that absent means `insufficient_evidence` and that it applies only where the reference
   holds a value per scope item. `spec/domains/gate.yaml`: `RequirementVerdict` (`:195`) has a
   list of the items not judged, empty when none. Checked by
   `ess specify validate --path spec --strict-requires`, which exits 0, and by
   `task check:generated`.
2. `docs/design.md` § 5 "Verdicts", the case "A scope item on one side of a comparison"
   (`:619`): the item the reference does not hold is `reference_missing` unless the reference
   declares `new_items: not_judged`, and then it is listed as not judged and the requirement is
   judged over the other items; the table of § 3 "Value lists" names the two values. Text only,
   no case.
3. `docs/design.md` § 5 "Protected references", "Reference records" (`:597`): adopting the value
   of a scope item the reference did not hold is that item's first adoption and no loosening;
   adding an item to an accepted set stays a loosening. Text only, no case.
4. `CHANGELOG.md` has its line under `## [Unreleased]`. Text only, no case.

## Notes

- An addition to a released format: a file without `new_items` keeps today's rule and stays
  valid.
- The verdict of an item not judged, the gate's verdict over the other items, and
  `ratchet reference adopt` writing the new item's value as a first adoption are
  `story:new-item-without-accepted-value-in-ratchet`, which waits for the waves to 0.1.0
  (`story:evaluate-command`, `story:reference-adopt-command`).
- Related: `story:min-samples-per-scope-item` (19 in the order) bounds the samples of each
  scope item; an item below that bound is `too_few_samples`, and this story's `not_judged`
  applies only to an item with no accepted value.
- `docs/design.md` § 5 is changed after this story by `story:reference-from-another-plan`
  ("Protected references", the ratchet policy table) and by stories 28 to 32 (local config,
  gate entries and kinds); `spec/domains/gate.yaml` `RequirementVerdict` is changed again by
  `story:gate-joins-revision-and-document` (32).
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of `.engineering/waves/0.1.0-ahead-2.md`,
  into one wave built in sequence on one branch: every planned wave starts behind
  `story:cli-skeleton-validate`, which waits for a release of ESS (beyond10x/ess#836), and this
  part needs no `ratchet` command. It is 26 of the 33 in the order of that page.
- Related: `story:reference-compare`, `story:reference-adopt-command`.
