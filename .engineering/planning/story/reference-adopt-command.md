---
format: aep.planning-md/3
id: story:reference-adopt-command
kind: story
status: active
title: 'ratchet reference adopt: a reference from recorded evidence'
summary: 'Writes ratchet/references/<requirement>.json from the newest complete run: first adoption, tightening, and the declared refusals.'
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
revision: 6
transitions:
- {from: "draft", to: "proposed", at: "2026-11-24T13:10:22Z", actor: "agent:ratchet", revision: 5, decided_on: {"recorded":{"review_outcome":2}}}
- {from: "proposed", to: "active", at: "2026-11-24T13:10:22Z", actor: "agent:ratchet", revision: 6, decided_on: {"recorded":{"review_outcome":2}}}
---
## Context

A reference is adopted from evidence produced before the candidate it will judge (design § 5
"Protected references", rule 3). `ratchet reference adopt` writes the reference record and the
context of the change into the working tree; the change becomes a reference change when it
reaches the trusted revision (design § 5 "Reference records"). The command declares the refusals
`unknown_requirement`, `no_qualifying_evidence`, `not_better`, `gain_not_shown`,
`unnamed_regression` and, since `story:record-formats-in-spec`, `requirement_without_reference`
(`spec/cli.yaml`).

## Acceptance

The test run of the `ratchet` binary crate lists as passed `reference_adopt::first_adoption`
(with one recorded run and no reference, `ratchet reference adopt <requirement>` exits 0 and
writes `ratchet/references/<requirement>.json` with the value of every scope item of that run or
the items of the set, the revision, the id of the evidence record and the kind of change
`first_adoption`), `reference_adopt::tightening` (with a reference present and every value equal
or better and at least one better, it writes the better values, the previous record id and the
kind `tightening`), and one test per refusal, each leaving the bytes of the reference file as
they were: `not_better` (a second call with the same evidence), `unnamed_regression` (a value
worse than the reference), `unknown_requirement` (no such requirement), `no_qualifying_evidence`
(no complete run) and `requirement_without_reference` (a requirement with a `condition` only).

## Scope

- `crates/ratchet-core/src/adopt.rs`: select the run, build the record
- `crates/ratchet/src/commands/reference_adopt.rs`
- `crates/ratchet/tests/reference_adopt.rs`, fixtures under
  `crates/ratchet/tests/fixtures/reference_adopt/`

## Notes

- `crates/ratchet/tests/main.rs`, `Cargo.toml` and `Cargo.lock` are not edited: the skeleton
  declared the test module and wired the command.
- The run adopted from is the newest complete run of the requirement's plan in the local record
  directory; `--candidate` narrows it to one revision.
- With a reference present the command answers with the three declared outcomes above, so no
  undeclared refusal is needed. "Better" is read as design § 5 "Protected references" words it
  for an exact measurement; the story reports the reading it took.
- Not here: `gain_not_shown` (it needs sampled measurements), `reference propose`, trade-offs,
  the sampled adoption `{from: trusted_revision, runs: N}`, and the fail of a gate when a better
  value was not adopted. They are in `epic:improvement-and-policy`.
- Red first. Budget: no test over 60 s, the step within 120 s.
- No `CHANGELOG.md` line here: `story:acceptance-in-gate` writes the lines of the slice.
