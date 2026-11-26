---
format: aep.planning-md/3
id: story:requirement-states-a-range
kind: story
status: draft
title: A requirement states a range of a number
relations:
- decomposes: epic:format-gaps-first-format-consumer
revision: 1
---
## Context

Found by a consumer writing a `ratchet/1` file at 0.0.3. A value is good inside a range, such
as 50 to 60 s, and the file needs two requirements to say so.

A requirement compares in up to two ways, `condition` with a fixed limit and `reference` with
the protected reference (`docs/design.md:188`). `ratchet.specification.QualityRequirement` holds
one `condition` (`spec/domains/specification.yaml:1002`), and a `Condition` is one `operator`
with one `value` (`spec/domains/specification.yaml:536-555`). A range is two requirements on one
measurement: two verdicts, two gate entries, and nothing that says the two bounds belong
together.

## Acceptance

- A requirement of a `ratchet/1` file states a lower and an upper bound of one number
  measurement, both must hold, and a verdict outside the range names the bound crossed; before
  the story a second comparison in one requirement is refused.
- Or the story is rejected with the written reason, and `docs/design.md` § 3 "Comparisons" says
  that a range is two requirements and how a gate lists them.
- `ratchet validate` accepts the form and refuses a range whose lower bound is above its upper
  bound. This part waits for the waves to 0.1.0.

## Notes

- The story decides the form, declares it in `spec/` first (`ess specify validate` passes), and
  writes it into `docs/design.md` § 3 in the same change. An addition to a released format: a
  file written before the change stays valid.
- Filed under `epic:format-gaps-first-format-consumer` as the closest epic: it holds the other
  change to `ratchet.specification.Condition` (`story:condition-on-digest-value`), and no epic
  holds this consumer's gaps.
- Related: `story:condition-on-digest-value`, `story:requirement-over-two-measurements`.
