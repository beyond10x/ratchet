---
format: aep.planning-md/3
id: epic:analyzer-findings
kind: epic
status: draft
title: 'Integration: no new findings from an existing analyzer'
summary: Import an analyzer's findings as an identity set and enforce no_new_items with accepted items.
relations:
- decomposes: initiative:first-milestone
- depends_on: epic:observe-adopt-reject
revision: 1
---
## Context

Integration 3 of design § 7: an importer for one existing analyzer's report, accepted items as
`{identity, reason, owner}`, a `filter` on item fields, and the same comparison for the
passing-case set of an ESS conformance report (`no_lost_items`).

## Done when

`examples/analyzer-findings.ratchet.yaml` runs as an acceptance run.

## Not decomposed yet

Stories are drafted after `epic:improvement-and-policy`.
