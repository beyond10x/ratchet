---
format: aep.planning-md/3
id: story:min-samples-per-scope-item
kind: story
status: draft
title: A plan bounds the samples of each scope item
relations:
- decomposes: epic:ci-turnaround
revision: 1
---
## Context

Found by a consumer writing a `ratchet/1` file at 0.0.3: `min_samples` applies to a plan, and
the consumer needs it per subject, read here as per scope item.

`min_samples` is a member of `ratchet.specification.ObservationPlan`
(`spec/domains/specification.yaml:507-512`). On a time-window plan it counts the population
items of the window, and below it the verdict is `too_few_samples` (`docs/design.md:173`). A
window measurement at a scope other than `run` gives one value per item
(`docs/design.md:179`). An item that appears in 2 of 20 runs then has a value from 2 samples
while the window has 20, and the plan's bound passes it. A result carries its `samples`
(`docs/evidence-format.md:168`), and no bound reads that number per item.

## Acceptance

- A plan or a measurement states the fewest samples each scope item needs, and an item below it
  is insufficient evidence with the cause `too_few_samples` for that item alone, while the other
  items are judged; before the story the bound is the plan's and an item with 2 samples is
  judged.
- `ratchet validate` accepts the form and refuses it on a measurement at the scope `run`. The
  check in `ratchet evaluate` waits for the waves to 0.1.0.

## Notes

- The story decides the form and where it lives (plan or measurement), declares it in `spec/`
  first (`ess specify validate` passes), and writes it into `docs/design.md` § 3. An addition
  to a released format: a file written before the change stays valid.
- Filed under `epic:ci-turnaround` as the closest epic: it holds sampled measurements and the
  first window. No epic holds this consumer's gaps.
- Related: `story:assessor-learns-observation` (the assessor learns `min_samples`),
  `story:new-item-without-accepted-value`.
