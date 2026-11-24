---
format: aep.planning-md/3
id: story:reference-adopt-command
kind: story
status: draft
title: 'ratchet reference adopt: first adoption from recorded evidence'
summary: Writes ratchet/references/<requirement>.json from the newest complete run.
relations:
- decomposes: epic:observe-adopt-reject
- depends_on: story:evidence-reader
- depends_on: story:reference-compare
scope:
- confidence: cited
  path: crates/ratchet-core/src/adopt.rs
- confidence: cited
  path: crates/ratchet/src/commands/reference_adopt.rs
- confidence: cited
  path: crates/ratchet/tests/fixtures/reference_adopt
- confidence: cited
  path: crates/ratchet/tests/reference_adopt.rs
revision: 2
---
## Context

A reference is adopted from evidence produced before the candidate it will judge (design § 5
"Protected references", rule 3). `ratchet reference adopt` writes the reference record and the
context of the change into the working tree; the change becomes a reference change when it
reaches the trusted revision (design § 5 "Reference records").

## Acceptance

In a fixture project with one recorded run and no reference, `ratchet reference adopt
<requirement>` exits 0 and writes `ratchet/references/<requirement>.json` holding the value of
every scope item of that run (or the items of the set), the revision, the id of the evidence
record and the kind of change `first_adoption`; a second call with unchanged evidence writes the
same bytes; and it exits 1 with a declared refusal when the requirement does not exist, when no
complete run is recorded, and when the requirement has no `reference`.

## Scope

- `crates/ratchet-core/src/adopt.rs`: select the run, build the record
- `crates/ratchet/src/commands/reference_adopt.rs`
- `crates/ratchet/tests/`: module `reference_adopt`, fixtures under
  `tests/fixtures/reference_adopt/`

## Notes

- The run adopted from is the newest complete run of the requirement's plan in the local record
  directory; `--candidate` narrows it to one revision.
- Not here: tightening an existing reference, `reference propose`, trade-offs, the sampled
  adoption `{from: trusted_revision, runs: N}`. With a reference present the command refuses and
  names `epic:improvement-and-policy`'s command surface as not built.
- Red first. Budget: no test over 60 s, the step within 120 s.
