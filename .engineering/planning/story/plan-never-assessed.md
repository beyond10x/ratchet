---
format: aep.planning-md/3
id: story:plan-never-assessed
kind: story
status: draft
title: A plan that was never assessed is told apart from a plan whose record is missing
summary: A plan in observe mode with no run is reported as never assessed, and a file can state that no run is expected yet.
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
  path: spec/cli.yaml
- confidence: inferred
  path: spec/domains/specification.yaml
revision: 6
---
## Context

The repository `beyond10x/inference` wrote the second unit of its quality definition against
the formats at commit `f139ecc` (2026-11-25): measures per adapter, and latency defined
without a number. It is the first consumer of the formats outside this repository and of this
story. An adversary pass of the consumer read the finding against the specification at that
commit. Line numbers below are those of `f139ecc`.

Finding 21. A file cannot say that no evidence was ever collected for a plan. "An assessment
with no requirement in any gate is in observe mode"
(`spec/domains/specification.yaml:850-851`, `docs/design.md` § 5). A plan in observe mode whose
command never ran and a plan whose record is missing look the same in the file and in a
verdict. The consumer has 26 latency measures of that kind: the command is billed by a
provider and no run was kept. It says so on a page, with the line "Baseline: none.".

## Acceptance

A plan in observe mode that has no assessment run is reported as never assessed, apart from a
plan whose run is missing from the record store, by `ratchet validate` or by the command that
lists the state of the plans, and a `ratchet/1` file can state for a plan that no run is
expected yet, with a reason; before the story both cases give the same line, and the file has
no place for the statement.

## Notes

- The consumer invented no field for the finding and says what it left out on a page of its
  quality unit. The story decides the form, declares it in `spec/` first (`ess specify
  validate` passes), and writes it into `docs/design.md` or `docs/evidence-format.md` in the
  same change.
- A new value or field of a released format is an addition: a file written for the format
  before the change stays valid.
- The story is a draft. It was there before the planned waves to 0.1.0 and waits for them.
