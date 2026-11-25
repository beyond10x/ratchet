---
format: aep.planning-md/3
id: approval-record:preset-catalog-stories
kind: approval-record
status: approved
title: The four stories of the preset catalog are accepted for implementation
relations:
- decides: story:preset-catalog-functional
- decides: story:preset-catalog-runtime
- decides: story:preset-catalog-factory
- decides: story:preset-binding-resolution
revision: 2
transitions:
- {from: "draft", to: "approved", at: "2026-11-25T01:09:50Z", actor: "agent:ratchet", revision: 2}
---
## Decision

The four stories of `epic:preset-catalog` are accepted for implementation:
`story:preset-catalog-functional`, `story:preset-catalog-runtime`,
`story:preset-catalog-factory` and `story:preset-binding-resolution`.

## On whose word

- The owner ordered the catalog on 2026-11-24 (relayed by the session of its first consumer).
- The operator session of the workstation, 2026-11-25 02:10 CET, deciding for the owner under
  his delegation of 2026-11-23, to the question "accept the 4 stories of the preset catalog
  for implementation?" with the options A (all four), B (only the functional story) and C
  (none until 0.1.0): "D33 = A, accept all 4 stories of `epic:preset-catalog`". Its reason: the
  owner ordered the catalog, the critics approve in round 2 with no finding, a consumer waits
  for it, and the step is reversible.

## What the critics said

- Round 1: four verdicts `needs-revision`, 23 findings (`review-result:*-catalog-round-1`).
  The epic and the four stories were revised for each.
- Round 2: four verdicts `approve`, no finding (`review-result:*-catalog-round-2`).

## Order

`story:preset-catalog-functional` starts after wave 3 is merged, beside the release 0.0.1.
`story:preset-catalog-runtime` and `story:preset-catalog-factory` follow, one after another.
`story:preset-binding-resolution` waits for 0.1.0. Wave 3 and a release keep priority over the
catalog where they collide. A catalog story starts between two waves, from the `main` of that
moment (`epic:preset-catalog` § "Order").
