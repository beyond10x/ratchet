---
format: aep.planning-md/3
id: story:production-gate-kind
kind: story
status: draft
title: A gate states that it is a production gate
relations:
- decomposes: epic:preset-catalog
revision: 1
---
## Context

Named by `story:production-gate-spec-executed-service`. A production gate is evaluated on a
deployed environment, not on a revision. The gate kinds are `candidate` and `operational`
(`spec/domains/specification.yaml:637-639`); an operational gate takes only time-window plans
without a `selection` (`docs/design.md:629`), and the plans of the bound presets carry
`selection: candidate`. The example `examples/production-gate.ratchet.yaml` therefore states
`kind: candidate`, and nothing in the file says that the gate judges a deployment.

## The question

Whether a production gate is a third gate kind, a candidate gate that names the deployment it
judges, or a candidate gate over plans of the target kind `deployment` with nothing new. The
answer is read beside `story:gate-judges-commit-of-a-tag`, which lets a candidate gate name a
revision that is not the candidate of a change.

## Acceptance

A gate of a `ratchet/1` file states that it is a production gate, in the form
the paragraph "Gate kinds" of `docs/design.md` § 5 (`:627`) names after the question is
answered, declared in `spec/domains/` first, and `examples/production-gate.ratchet.yaml` uses
it; before the story the example states `kind: candidate` and that paragraph names no
production gate.

## Notes

- The story is a draft. It waits for the waves to 0.1.0.
