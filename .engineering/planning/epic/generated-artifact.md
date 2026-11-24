---
format: aep.planning-md/3
id: epic:generated-artifact
kind: epic
status: draft
title: 'Integration: a generated artifact compared by digest'
summary: 'generator-check: run a generator, compare the committed files by digest, the candidate may regenerate.'
relations:
- decomposes: initiative:first-milestone
- depends_on: epic:observe-adopt-reject
revision: 1
---
## Context

Integration 4 of design § 7 and the most common baseline of the survey (21 answers): a reference
of the kind `generated` with `paths`, compared by digest with tolerance 0 on the merge result,
with `when: {changed: [...]}` on the gate entry. The first use is this repository's own
generated crates.

## Done when

`examples/generated-artifact.ratchet.yaml` runs as an acceptance run, and this repository's
drift check is a `ratchet` gate.

## Not decomposed yet

Stories are drafted when `epic:observe-adopt-reject` is in its last wave.
