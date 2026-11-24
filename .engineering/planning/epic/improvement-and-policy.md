---
format: aep.planning-md/3
id: epic:improvement-and-policy
kind: epic
status: draft
title: Record an improvement; exceptions and trade-offs
summary: Tightening, the stale-reference fail, reference propose, exceptions with expiry, trade-offs, percent tolerance rounding.
relations:
- decomposes: initiative:first-milestone
- depends_on: epic:observe-adopt-reject
revision: 1
---
## Context

Vision outcome 4 and the first consumer's gaps 2, 3 and 5 (`initiative:first-milestone`): a
better value that is not adopted fails (`stale_reference_not_adopted`), `ratchet reference
adopt` tightens an existing reference and records the previous value, `ratchet reference
propose` prints the change, a worse value is accepted only through an exception with a reason,
an owner and an expiry or through a trade-off that names its gains (design § 5).

## Done when

The first consumer's comparator has no rule that `ratchet` lacks, shown by new steps of the
acceptance run.

## Not decomposed yet

Stories are drafted when `epic:observe-adopt-reject` is in its last wave.
