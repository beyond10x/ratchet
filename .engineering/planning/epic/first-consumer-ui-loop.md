---
format: aep.planning-md/3
id: epic:first-consumer-ui-loop
kind: epic
status: draft
title: The first consumer's UI loop runs on ratchet
summary: An acceptance run in the shape of slot's web UI ratchet, counted per step, then part of the gate.
relations:
- decomposes: initiative:first-milestone
revision: 2
---
## Context

The first consumer is the web UI loop of the `slot` repository (`initiative:first-milestone`).
Its ratchet is hand-written: `ui/ux/baseline.json` holds, per scenario and key, an accepted value
and a tolerance; `ui/ux/ratchet-lib.ts` (111 lines) compares a fresh measurement with it; the gate
runs the comparison on every change. The workspace rule "Goal first" asks that the consumer's
acceptance test exists before the waves are ordered, and that each wave names the gap it moved.

The consumer's files were read on 2026-11-24, read-only. Nothing in the consumer changes in this
epic: the migration of its gate is the consumer's own story, after 0.1.0.

## Outcome

The repository holds an acceptance run that plays the consumer's loop against the `ratchet`
binary, in the consumer's shape: values per scenario and key, lower is better, a tolerance per
key, the reference committed in the tree and read from the trusted revision. It prints how many
of its steps pass. When all pass it is part of the gate, and the documentation shows a project
how to do the same.

## Done when

`story:ui-loop-acceptance` and `story:acceptance-in-gate` are implemented. The release that
carries them is `story:release-0-1-0` of `epic:release-line`.
