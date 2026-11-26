---
format: aep.planning-md/3
id: story:production-gate-kind-in-ratchet
kind: story
status: draft
title: ratchet evaluate judges the revision deployed in the class a production gate names
summary: 'The command part of story:production-gate-kind: a gate with judges: {deployment: <class>} judges the revision the design says is deployed in that class.'
relations:
- decomposes: epic:preset-catalog
- depends_on: story:production-gate-kind
- depends_on: story:cli-skeleton-validate
- depends_on: story:evaluate-command
- depends_on: story:preset-binding-resolution
scope:
- confidence: inferred
  path: crates/ratchet-core
revision: 7
---
## Context

Split on 2026-11-26 from `story:production-gate-kind`, which declares
`judges: {deployment: <target class>}` on a candidate gate in
`spec/domains/specification.yaml`, writes into `docs/design.md` § 5 "Gate kinds" that such a
gate is a production gate, names there which revision is deployed in the class as left open,
and gives the form to the gate of `examples/production-gate.ratchet.yaml`. This story holds the
part that needs the `ratchet` command.

## Acceptance

`ratchet evaluate --gate production` on `examples/production-gate.ratchet.yaml` judges, as the
candidate of the gate, the revision that `docs/design.md` § 5 "Gate kinds" says is deployed in
`staging`, and a gate without `judges` judges the candidate of a change as before. Before the
story no command reads `judges: {deployment: ...}`.

## Notes

- Moved from the acceptance of `story:production-gate-kind`. The rule that every requirement
  of such a gate names a plan that runs in the class, and a refusal by it, are not part of the
  story: neither the story, `epic:preset-catalog` nor D88 A asks for them.
- The story cannot be implemented while `docs/design.md` § 5 "Gate kinds" names the question
  which revision is deployed in the class as open; the answer is a change of the design, not
  of this draft.
- The story is a draft. It waits for the waves to 0.1.0: `story:cli-skeleton-validate`,
  `story:evaluate-command`, and for the bindings of the example,
  `story:preset-binding-resolution`.
