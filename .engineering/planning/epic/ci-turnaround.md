---
format: aep.planning-md/3
id: epic:ci-turnaround
kind: epic
status: draft
title: 'Integration: CI turnaround and the host-caused limit'
summary: Sampled durations with declared conditions, queue wait apart from run time, insufficient evidence under host load.
relations:
- decomposes: initiative:first-milestone
- depends_on: epic:observe-adopt-reject
revision: 1
---
## Context

Integration 2 of design § 7, the first consumer's gap 4, and the last sentence of `vision.md`
§ "First milestone": a limit crossed because of the host is insufficient evidence
(`conditions_outside_declared`), not a fail. It needs sampled measurements, observed conditions
(`host_load_per_cpu`, tools, runner), local inputs, `[local]` skips, and an importer for a
build pool's job log.

## Done when

`examples/ci-turnaround.ratchet.yaml` and `examples/host-caused-limit.ratchet.yaml` run as
acceptance runs.

## Not decomposed yet

Stories are drafted after `epic:improvement-and-policy`.
