---
format: aep.planning-md/3
id: story:min-samples-per-scope-item
kind: story
status: active
title: A plan bounds the samples of each scope item
relations:
- decomposes: epic:ci-turnaround
scope:
- confidence: cited
  path: docs/design.md
- confidence: cited
  path: spec/domains/gate.yaml
- confidence: cited
  path: spec/domains/specification.yaml
revision: 11
transitions:
- {from: "draft", to: "proposed", at: "2026-11-26T21:04:22Z", actor: "human:operator", revision: 10, decided_on: {"recorded":{"review_outcome":4}}}
- {from: "proposed", to: "active", at: "2026-11-26T21:04:22Z", actor: "human:operator", revision: 11, decided_on: {"recorded":{"review_outcome":4}}}
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

A phrase with a space in it may wrap in a Markdown paragraph or a folded YAML summary. So where
an item says that `grep -F` finds such a phrase in a `.md` or `.yaml` file, that it finds
nothing or the phrase is gone, or that `grep -c` of it prints a count, the check reads the
joined text of the file: `tr -s '\n ' '  ' < <file> | grep -o -F '<phrase>' | wc -l` prints 1
where the item says it is found, 0 where it says nothing or gone, and the count where it names
one. A name without a space, a row of a table, a pattern with `^`, `$` or `-E`, a check that
prints the line it matches and a check that reads the output of another command read the file
line by line, as written.

1. `spec/domains/specification.yaml`: `ratchet.specification.Measurement` has the member
   `min_samples_per_item` (`Optional<Integer>`). Check: `grep -c 'name: min_samples_per_item'
   spec/domains/specification.yaml` prints 1 (0 before); `ess specify validate --path spec
   --strict-requires` exits 0, and the synthesis line of `task check:spec` still ends
   `, 0 refused`.
2. `Measurement` holds the two invariants `not defined(min_samples_per_item)` or
   `min_samples_per_item >= 1`, and `not defined(min_samples_per_item)` or `scope != "run"`,
   in the form of the invariants of `ratchet.specification.AssessmentPlan` that compare with a
   literal (`- any: [...]`). Check: `grep -c 'not defined(min_samples_per_item)'
   spec/domains/specification.yaml` prints 2 (0 before).
3. The summary of `Measurement.min_samples_per_item` holds the phrase "`too_few_samples` for
   that item alone". Check: `grep -F` of that phrase in `spec/domains/specification.yaml`
   finds one line (none before).
4. `docs/design.md` § 3 "Scope and aggregation" holds a paragraph that states the bound per
   scope item, that it is no bound of the plan, that it is refused at the scope `run`, that it
   reads the `samples` of each result, and the member of `ObservationPlan` as the form not
   taken. Check: `awk '/^### Scope and aggregation$/,/^### Evidence coverage$/' docs/design.md
   | grep -c min_samples_per_item` prints a number above 0 (0 before).
5. `docs/design.md` § 3 "Time windows", the row `min_samples` of the key table, says that it
   counts the items of the window and names `min_samples_per_item` for the samples behind one
   item's value. Check: `awk '/^### Time windows$/,/^### Comparisons$/' docs/design.md | grep
   '^| `min_samples`' | grep -c min_samples_per_item` prints 1 (0 before).
6. `docs/design.md` § 5 "Verdicts", the case "A scope item on one side of a comparison": an
   item below `min_samples_per_item` is insufficient evidence with the cause `too_few_samples`
   for that item, and the other items are judged. Check: `awk '/^### Verdicts$/,/^### Gate
   modes$/' docs/design.md | grep -c min_samples_per_item` prints a number above 0 (0
   before).
7. `spec/domains/gate.yaml`: the comment above `ratchet.gate.InsufficientEvidenceCause` that
   says "`too_few_samples` covers a window with fewer items than `min_samples`" goes on with
   the phrase "and a scope item whose result carries fewer samples than
   `min_samples_per_item`". `ess specify validate` does not read a comment, so the check is
   `grep -c 'min_samples_per_item' spec/domains/gate.yaml`, which prints 1 (0 before).

## Notes

- Decision taken: a member of the measurement, not of the plan (§ Context). The alternative, a
  member of `ObservationPlan`, is named in the design paragraph of item 4 as not taken, with
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
