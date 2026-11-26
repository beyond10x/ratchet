---
format: aep.planning-md/3
id: story:new-item-without-accepted-value
kind: story
status: draft
title: A scope item with no accepted value of its own can be judged
relations:
- decomposes: epic:improvement-and-policy
revision: 1
---
## Context

Found by a consumer writing a `ratchet/1` file at 0.0.3: a new subject has no accepted value,
so values per subject cannot ratchet, only the level of the whole series.

Where a requirement has an accepted value per scope item, an item that the evidence holds and
the reference does not is `reference_missing` for that item, insufficient evidence
(`docs/design.md:619`). A reference is adopted from evidence produced before the candidate
(`docs/design.md:581`), and a gate with an item of insufficient evidence does not pass
(`docs/design.md:623`). When new items keep arriving, each one is `reference_missing` on its
first run, and a per-item requirement in an enforced entry never passes. What remains is a
measurement at the scope `run` that aggregates over the items.

## Acceptance

- A requirement with accepted values per scope item states how an item with no accepted value
  of its own is judged: against a value the reference holds for the series, or left out of the
  gate until a value is adopted, as the story decides. A verdict on such an item names which.
  Before the story the item is `reference_missing` and the gate's verdict is insufficient
  evidence.
- `ratchet reference adopt` adds the value of a new item without counting it as a loosening.
- `ratchet validate` accepts the form. The parts in `ratchet evaluate` and
  `ratchet reference adopt` wait for the waves to 0.1.0.

## Notes

- The story decides the form, declares it in `spec/` first (`ess specify validate` passes), and
  writes it into `docs/design.md` § 5 "Protected references" and "Verdicts". Adding an item to
  an accepted set is a loosening today (`docs/design.md` § 5 "Reference records"); the story
  says whether a value per scope item differs.
- Filed under `epic:improvement-and-policy` as the closest epic: adoption and loosening rules.
- Related: `story:reference-compare`, `story:reference-adopt-command`,
  `story:min-samples-per-scope-item`.
