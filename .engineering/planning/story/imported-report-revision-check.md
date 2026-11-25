---
format: aep.planning-md/3
id: story:imported-report-revision-check
kind: story
status: draft
title: An imported report of another revision is refused
summary: A report states the revision or source digest it was produced from, and assess refuses one that is not the candidate's.
relations:
- decomposes: epic:format-gaps-second-format-consumer
scope:
- confidence: inferred
  path: CHANGELOG.md
- confidence: inferred
  path: crates/ratchet-core
- confidence: inferred
  path: docs/evidence-format.md
- confidence: inferred
  path: presets
- confidence: inferred
  path: spec/domains/assessor.yaml
revision: 6
---
## Context

The repository `beyond10x/swell`, a script engine, drafted its quality definition against the
formats at commit `90924c9` (2026-11-25). It is the first consumer of this story. Line numbers
below are those of `90924c9`.

An assessor that imports a report writes the revision it is given and looks none up
(`docs/evidence-format.md:78`, `:627`, Q9). The consumer's conformance run writes a result
file that Git ignores. A file left from a run of another revision is read as it is, and the
evidence names the candidate's revision: a stale report counts as the candidate's. The
consumer guards its own expected file with a digest of its sources; the formats have nothing
for it. `conformance-report@1`, `comparison-report@1` and `case-list@1` of the catalog import
a report in the same way.

## Acceptance

A report that an assessor imports states the revision, or the digest of the sources, it was
produced from, the declaration of the assessor says where, and `ratchet assess` refuses a
report of another revision than the candidate's with a cause that names both; a report that
states none is refused or recorded as unattributed, as the story decides. Before the story a
report of any revision is recorded as the candidate's evidence.

## Notes

- The consumer invented no field for the finding and says what it left out in the notes of its
  draft. The story decides the form, declares it in `spec/` first (`ess specify validate`
  passes), and writes it into `docs/design.md` or `docs/evidence-format.md` in the same change.
- A new value or field of a released format is an addition: a file written for the format
  before the change stays valid.
- The story is a draft. It was there before the planned waves to 0.1.0 and waits for them.
