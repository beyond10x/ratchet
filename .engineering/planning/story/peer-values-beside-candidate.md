---
format: aep.planning-md/3
id: story:peer-values-beside-candidate
kind: story
status: rejected
title: Values of other implementations stand beside the candidate's
summary: A measurement carries values of named other implementations with version and method; no gate reads them. Or the boundary excludes it, in writing.
relations:
- decomposes: epic:format-gaps-second-format-consumer
scope:
- confidence: inferred
  path: AGENTS.md
- confidence: inferred
  path: CHANGELOG.md
- confidence: inferred
  path: docs/design.md
- confidence: inferred
  path: spec/domains/specification.yaml
revision: 8
transitions:
- {from: "draft", to: "proposed", at: "2026-11-26T23:39:05Z", actor: "human:operator", revision: 7}
- {from: "proposed", to: "rejected", at: "2026-11-26T23:39:05Z", actor: "human:operator", revision: 8}
---
## Context

The repository `beyond10x/swell`, a script engine, drafted its quality definition against the
formats at commit `90924c9` (2026-11-25). It is the first consumer of this story. Line numbers
below are those of `90924c9`.

The consumer shows values of other engines beside its own: a conformance pass count, a binary
size, a start time, the memory of an empty realm, and which limits an engine can enforce at
all. Several peers per measure. A peer value never gates and is never a protected reference.

The formats have no place for it. A reference is `generated` or `accepted_value`
(`ratchet.specification.ReferenceKind`, `spec/domains/specification.yaml:520`), and both
protect the candidate against its own past. `differential-equality@1` compares a candidate
with one reference implementation case by case and records none of the other side's numbers.
Binding a preset once per peer makes each peer a subject judged against its own accepted
values, and a peer build is no candidate revision: a plan has a target of the kind `revision`
or `document` with the selection `candidate` (`docs/evidence-format.md` § 10). The consumer
keeps a table typed by hand and reads it as a `document` target; the evidence then holds no
version of the peer, no date and no method, and nothing relates a peer value to the
candidate's value of the same measurement.

The story first answers whether this is Ratchet's at all: `AGENTS.md` § "Boundary" says what
Ratchet ships, and a comparison of products may belong to the consumer of the records.

## Acceptance

A `ratchet/1` file declares, for a measurement, values of named other implementations with the
version of each and how the value was obtained, `ratchet validate` accepts the file, no gate
reads such a value, and the view of the measurement shows each beside the candidate's value;
or the story is rejected with the written reason that a comparison of implementations is
outside the boundary, and `docs/design.md` says what a consumer does instead. Before the story
the keys are refused and the design is silent.

## Notes

- The consumer invented no field for the finding and says what it left out in the notes of its
  draft. The story decides the form, declares it in `spec/` first (`ess specify validate`
  passes), and writes it into `docs/design.md` or `docs/evidence-format.md` in the same change.
- A new value or field of a released format is an addition: a file written for the format
  before the change stays valid.
- The story is a draft. It was there before the planned waves to 0.1.0 and waits for them.

## Decision

Decided on 2026-11-26 by the operator session acting for the owner (D89 A): a comparison of
implementations is outside the boundary of Ratchet, and the story is rejected with that reason.
B (a measurement carries values of other implementations that no gate reads) and C (leave the
story a draft) were not taken.

The second half of the acceptance, `docs/design.md` saying what a consumer does instead, is a
unit of `.engineering/waves/0.1.0-ahead-2.md`. The story moves to `rejected` with the commit
that writes that paragraph.
