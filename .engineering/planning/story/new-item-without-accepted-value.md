---
format: aep.planning-md/3
id: story:new-item-without-accepted-value
kind: story
status: active
title: A scope item with no accepted value of its own can be judged
relations:
- decomposes: epic:improvement-and-policy
scope:
- confidence: cited
  path: crates/ratchet-cli-contract
- confidence: cited
  path: docs/design.md
- confidence: cited
  path: spec/domains/cli.yaml
- confidence: cited
  path: spec/domains/gate.yaml
- confidence: cited
  path: spec/domains/specification.yaml
revision: 13
transitions:
- {from: "draft", to: "proposed", at: "2026-11-26T21:04:24Z", actor: "human:operator", revision: 12, decided_on: {"recorded":{"review_outcome":4}}}
- {from: "proposed", to: "active", at: "2026-11-26T21:04:24Z", actor: "human:operator", revision: 13, decided_on: {"recorded":{"review_outcome":4}}}
---
## Context

Found by a consumer writing a `ratchet/1` file at 0.0.3: a new subject has no accepted value,
so values per subject cannot ratchet, only the level of the whole series.

Where a requirement has an accepted value per scope item, an item that the evidence holds and
the reference does not is `reference_missing` for that item, insufficient evidence
(`docs/design.md:619` at 7b01ea1, § 5 "Verdicts", "A scope item on one side of a comparison").
A reference is adopted from evidence produced before the candidate (`:581`, rule 3 of
"Protected references"), and a gate with an enforced requirement of insufficient evidence does
not pass (`:623`, "The verdict of a gate"). When new items keep arriving, each one is
`reference_missing` on its first run, and a per-item requirement in an enforced entry never
passes. What remains is a measurement at the scope `run` that aggregates over the items.

`ratchet.specification.ReferenceDeclaration` (`spec/domains/specification.yaml:602` at
7b01ea1) holds `kind`, `paths`, `tolerance` and `adoption`, and nothing that says how an item
without a value is judged. `ratchet.gate.RequirementVerdict` (`spec/domains/gate.yaml:195`)
and the report row `ratchet.cli.VerdictRow` (`spec/domains/cli.yaml:298`) have one `cause` for
the requirement and no list of items left unjudged. "Adding an item is a loosening"
(`docs/design.md:597`, "Reference records") is written for an item of an accepted set; it says
nothing of a value per scope item. `ratchet.reference.ReferenceChangeKind`
(`spec/domains/reference.yaml:44-46`) has `first_adoption`, `regeneration`, `tightening`,
`loosening` and `trade_off`.

## Decision

The reversible answer, taken here (AGENTS.md § "Phase: implementation"): an optional member
`new_items` of `ReferenceDeclaration`, of a new closed enum
`ratchet.specification.NewItemRule` with two values, `insufficient_evidence` (the default,
today's rule) and `not_judged`. Under `not_judged` an item the reference does not hold is left
out of the comparison, the requirement is judged over the other items, and the verdict lists
the item under `items_not_judged` until a value for it is adopted. Adopting the value of such
an item is the first adoption of that item (`first_adoption`), not a loosening; adding an item
to an accepted set stays a loosening. The other form of the draft, judging the new item against
a value the reference holds for the series, is not taken: it needs a value for the series that
no reference record holds.

The list is declared on both the verdict and the report row in this story, as a format change;
filling it is the command's.

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

1. `spec/domains/specification.yaml` declares the closed enum
   `ratchet.specification.NewItemRule` with the variants `insufficient_evidence` and
   `not_judged`: `grep -c 'name: ratchet.specification.NewItemRule'
   spec/domains/specification.yaml` prints 1 (0 before), and
   `ess specify validate --path spec --strict-requires` exits 0.
2. `ratchet.specification.ReferenceDeclaration` has the optional member `new_items` of that
   enum: `grep -c 'type: Optional<ratchet.specification.NewItemRule>'
   spec/domains/specification.yaml` prints 1 (0 before).
3. The summary of `new_items` says what an absent member means and where it applies:
   `grep -F 'Absent means `insufficient_evidence`' spec/domains/specification.yaml` finds it,
   and `grep -F 'only where the reference holds a value per scope item'
   spec/domains/specification.yaml` finds it (neither before).
4. `ratchet.gate.RequirementVerdict` in `spec/domains/gate.yaml` has the member
   `items_not_judged`, a `List<String>` of scope items, empty when none:
   `grep -c 'name: items_not_judged' spec/domains/gate.yaml` prints 1 (0 before).
5. `ratchet.cli.VerdictRow` in `spec/domains/cli.yaml` has the same member with the same type:
   `grep -c 'name: items_not_judged' spec/domains/cli.yaml` prints 1 (0 before).
6. The generated crate follows: after `task generate`, `task check:generated` exits 0 and
   `grep -rl items_not_judged crates/ratchet-cli-contract/` prints at least one file (none
   before).
7. `docs/design.md` § 5 "Verdicts", the case "A scope item on one side of a comparison", says
   that the item is `reference_missing` unless the reference declares `not_judged`, and then
   is listed as not judged while the requirement is judged over the other items:
   `grep -F 'unless its reference declares `new_items: not_judged`' docs/design.md` finds it
   (nothing before).
8. `docs/design.md` § 3 "Value lists" has a row for the two values:
   `grep -F '| New items (`new_items`) | `insufficient_evidence`, `not_judged` | Ratchet, closed |'
   docs/design.md` finds it (nothing before).
9. `docs/design.md` § 5 "Protected references", the paragraph "Reference records", says that
   adopting the value of a scope item the reference did not hold is that item's first
   adoption: `grep -F 'is the first adoption of that item, not a loosening' docs/design.md`
   finds it (nothing before), and `grep -F 'Adding an item to an accepted set is a loosening'
   docs/design.md` finds the rule kept for a set (the base text reads "Adding an item is a
   loosening").

## Notes

- An addition to a released format: a file without `new_items` keeps today's rule and stays
  valid.
- The verdict of an item not judged, filling `items_not_judged` in the gate report and the
  decision, the gate's verdict over the other items, and `ratchet reference adopt` writing the
  new item's value as a first adoption are `story:new-item-without-accepted-value-in-ratchet`,
  which waits for the waves to 0.1.0 (`story:evaluate-command`,
  `story:reference-adopt-command`).
- It changes `spec/domains/cli.yaml`, so it runs `task generate` and `task check:generated`.
- Related: `story:min-samples-per-scope-item` (19 in the order) bounds the samples of each
  scope item; an item below that bound is `too_few_samples`, and this story's `not_judged`
  applies only to an item with no accepted value.
- `docs/design.md` § 5 is changed after this story by `story:reference-from-another-plan`
  ("Protected references", the ratchet policy table) and by stories 28 to 32 (local config,
  gate entries and kinds); `RequirementVerdict` and `VerdictRow` are changed again by
  `story:gate-joins-revision-and-document` (32).
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of `.engineering/waves/0.1.0-ahead-2.md`,
  into one wave built in sequence on one branch: every planned wave starts behind
  `story:cli-skeleton-validate`, which waits for a release of ESS (beyond10x/ess#836), and this
  part needs no `ratchet` command. It is 26 of the 33 in the order of that page.
- Related: `story:reference-compare`, `story:reference-adopt-command`.
