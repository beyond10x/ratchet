---
format: aep.planning-md/3
id: epic:ess-ui-behavior
kind: epic
status: draft
title: 'Integration: ESS UI behavior'
summary: Import an ESS UI report, enforce an assertion with holds, and read the second consumer's ux-static@1 evidence in a gate.
relations:
- decomposes: initiative:first-milestone
- depends_on: epic:observe-adopt-reject
revision: 1
---
## Context

Integration 1 of design § 7. The second consumer, `uxui`, writes `ratchet-evidence/1` with its
assessor `ux-static@1` for a target of the kind `document` (`docs/evidence-format.md` § 6,
§ 10). This epic adds the operator `holds`, the value type `assertion`, the target kind
`document`, and an assessor that imports an `ess-ui` report.

## Done when

`examples/ess-ui-behavior.ratchet.yaml` runs as an acceptance run, and a gate in the second
consumer's repository is evaluated by `ratchet`.

## Not decomposed yet

Stories are drafted after `epic:improvement-and-policy`.
