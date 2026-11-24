---
format: aep.planning-md/3
id: story:assess-command
kind: story
status: active
title: 'ratchet assess: run an assessor and record its evidence'
summary: The invocation and exit-status contract of docs/evidence-format.md § 10, observe mode output.
relations:
- decomposes: epic:observe-adopt-reject
- depends_on: story:evidence-reader
- depends_on: story:assessor-declaration
scope:
- confidence: cited
  path: crates/ratchet-core/src/assess.rs
- confidence: cited
  path: crates/ratchet/src/commands/assess.rs
- confidence: cited
  path: crates/ratchet/tests/assess.rs
- confidence: cited
  path: crates/ratchet/tests/fixtures/assess
revision: 5
transitions:
- {from: "draft", to: "proposed", at: "2026-11-24T13:10:22Z", actor: "agent:ratchet", revision: 4, decided_on: {"recorded":{"review_outcome":3}}}
- {from: "proposed", to: "active", at: "2026-11-24T13:10:22Z", actor: "agent:ratchet", revision: 5, decided_on: {"recorded":{"review_outcome":3}}}
---
## Context

`ratchet assess` is observe mode: it produces evidence and judges nothing (design § 5 "Gate
modes"). `docs/evidence-format.md` § 10 defines how the CLI starts an assessor (`--project`,
`--assessment`, `--root`, `--class`, `--out`, `--revision`, one argument per input), what each
exit status means, and which document the CLI writes when the assessor left none.

## Acceptance

The test run of the `ratchet` binary crate lists as passed `assess::records_run` (in a fixture
project whose assessor is a POSIX sh script, `ratchet assess` exits 0, writes one
`ratchet-evidence/1` record per plan into the local record directory and prints per measurement
and scope item the value with its unit and the record id), `assess::report_file` (`--report
<file>` records an existing document after the same checks without starting the assessor, and a
document that breaks a rule is not recorded as complete), and one test per row of
`docs/evidence-format.md` § 10 "Exit status": an assessor that exits 1 is recorded as
`refused_inputs`, one that exits 2, exits 0 without a document, or exits 0 with a document that
breaks its declaration as `stopped_by_infrastructure`, each with no result.

## Scope

- `crates/ratchet-core/src/assess.rs`: resolve the plans, build the arguments, start the command
  with a time limit, check the document against the rules (`story:evidence-reader`) and the
  declaration (`story:assessor-declaration`), record it
- `crates/ratchet/src/commands/assess.rs`
- `crates/ratchet/tests/assess.rs`, fixtures under `crates/ratchet/tests/fixtures/assess/`

## Notes

- `crates/ratchet/tests/main.rs`, `crates/ratchet/src/commands/mod.rs`, `Cargo.toml` and
  `Cargo.lock` are not edited: the skeleton declared the test module, wired the command and
  declared the dependencies. The child process and its time limit use the standard library.
- `--assessments` selects plans; `--candidate` gives the revision, HEAD by default.
- `[tools]` of `ratchet.toml` says how a `command` is started on this machine; without an entry
  the `command` of the declaration is looked up in `PATH`.
- The class is `ci` when a CI environment is detected, else `[environment] class`, else `local`
  (design § 5 "Local config" rule 3).
- Not here: `[local]` skips, local inputs, sampled measurements and observed conditions, the time
  limit as a declared value (a fixed limit with a test is enough; the story reports the number
  and where the design should name it).
- Red first. Budget: no test over 60 s, the step within 120 s; the sh assessors copy a prepared
  file and start no tool.
- No `CHANGELOG.md` line here: `story:acceptance-in-gate` writes the lines of the slice.
