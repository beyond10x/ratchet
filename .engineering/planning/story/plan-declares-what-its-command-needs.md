---
format: aep.planning-md/3
id: story:plan-declares-what-its-command-needs
kind: story
status: draft
title: A plan declares what its command needs before it runs
summary: A credential, an environment variable or a device by name, and whether a run is billed; a machine that lacks one is not assessable there.
relations:
- decomposes: epic:format-gaps-first-format-consumer
scope:
- confidence: inferred
  path: CHANGELOG.md
- confidence: inferred
  path: crates/ratchet-core
- confidence: inferred
  path: docs/design.md
- confidence: inferred
  path: spec/domains/specification.yaml
revision: 5
---
## Context

The repository `beyond10x/inference` wrote the second unit of its quality definition against
the formats at commit `f139ecc` (2026-11-25): measures per adapter, and latency defined
without a number. It is the first consumer of the formats outside this repository and of this
story. An adversary pass of the consumer read the finding against the specification at that
commit. Line numbers below are those of `f139ecc`.

Finding 22. An observation has one `command` and nothing for what the command needs before
it can run (`ratchet.specification.ObservationPlan`, `spec/domains/specification.yaml:461-463`):
a credential, environment variables, a device, or the fact that a provider bills the run. A
machine that lacks one of them starts the command and gets a failed run, which reads as a
failed measurement. `story:machine-as-a-condition` declares the machine a sampled measurement
depends on; this finding is about what a run needs to start at all.

## Acceptance

A plan declares what its command needs before it runs, by name and never by value (a
credential, an environment variable, a device) and whether a run is billed, `ratchet validate`
accepts the file, and `ratchet assess` on a machine that lacks a declared need does not start
the command and reports the requirement as not assessable there, with a cause that names the
need; before the story the keys are refused and the command is started.

## Notes

- The consumer invented no field for the finding and says what it left out on a page of its
  quality unit. The story decides the form, declares it in `spec/` first (`ess specify
  validate` passes), and writes it into `docs/design.md` or `docs/evidence-format.md` in the
  same change.
- A new value or field of a released format is an addition: a file written for the format
  before the change stays valid.
- The story is a draft. It was there before the planned waves to 0.1.0 and waits for them.
