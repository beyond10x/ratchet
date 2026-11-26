---
format: aep.planning-md/3
id: story:production-gate-kind-in-ratchet
kind: story
status: draft
title: ratchet validate and evaluate hold a production gate to the deployment it judges
summary: 'The command part of story:production-gate-kind: the refusal of a plan outside the judged class, and the class in the decision.'
relations:
- decomposes: epic:preset-catalog
- depends_on: story:production-gate-kind
- depends_on: story:cli-skeleton-validate
- depends_on: story:evaluate-command
- depends_on: story:preset-binding-resolution
scope:
- confidence: inferred
  path: crates/ratchet-core
- confidence: inferred
  path: spec/domains/gate.yaml
revision: 3
---
## Context

Split on 2026-11-26 from `story:production-gate-kind`, which declares
`judges: {deployment: <target class>}` on a candidate gate in
`spec/domains/specification.yaml`, writes into `docs/design.md` § 5 "Gate kinds" that such a
gate is a production gate, and gives it to the gate of `examples/production-gate.ratchet.yaml`.
This story holds the part that needs the `ratchet` command.

## Acceptance

`ratchet validate` accepts `examples/production-gate.ratchet.yaml` with its gate
`judges: {deployment: staging}`, and refuses a copy in which one requirement of that gate names
a plan that does not run in `staging`, with a code that names the gate and the requirement;
`ratchet evaluate --gate production` records the class judged in the gate decision and in its
report. Before the story no command reads the form.

## Notes

- Moved from the acceptance of `story:production-gate-kind`.
- Which revision is deployed in the class, and how `ratchet evaluate` learns it, is this
  story's to decide and write into `docs/design.md`; a deployment target's evidence names its
  revision (`docs/evidence-format.md` § 3, `evidence.target`).
- The story is a draft. It waits for the waves to 0.1.0: `story:cli-skeleton-validate`,
  `story:evaluate-command`, and for the bindings of the example,
  `story:preset-binding-resolution`.
