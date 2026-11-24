---
format: aep.planning-md/3
id: story:assess-command
kind: story
status: draft
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
revision: 2
---
## Context

`ratchet assess` is observe mode: it produces evidence and judges nothing (design § 5 "Gate
modes"). `docs/evidence-format.md` § 10 defines how the CLI starts an assessor (`--project`,
`--assessment`, `--root`, `--class`, `--out`, `--revision`, one argument per input), what each
exit status means, and which document the CLI writes when the assessor left none.

## Acceptance

In a fixture project whose assessor is a POSIX sh script, `ratchet assess` exits 0, writes one
`ratchet-evidence/1` record per plan into the local record directory and prints per measurement
and scope item the value with its unit and the record id; and for an assessor that exits 1, exits
2, exits 0 without a document, and exits 0 with a document that breaks its declaration, the
recorded run has the completion `refused_inputs`, `stopped_by_infrastructure`,
`stopped_by_infrastructure` and `stopped_by_infrastructure`, and no result.

## Scope

- `crates/ratchet-core/src/assess.rs`: resolve the plans, build the arguments, start the command
  with a time limit, check the document against the rules (`story:evidence-reader`) and the
  declaration (`story:assessor-declaration`), record it
- `crates/ratchet/src/commands/assess.rs`
- `crates/ratchet/tests/`: module `assess`, fixtures under `tests/fixtures/assess/`

## Notes

- `--assessments` selects plans; `--candidate` gives the revision, HEAD by default.
- `--report <file>` records a document that already exists, after the same checks, without
  starting the assessor.
- `[tools]` of `ratchet.toml` says how a `command` is started on this machine; without an entry
  the `command` of the declaration is looked up in `PATH`.
- The class is `ci` when a CI environment is detected, else `[environment] class`, else `local`
  (design § 5 "Local config" rule 3).
- Not here: `[local]` skips, local inputs, sampled measurements and observed conditions, the time
  limit as a declared value (a fixed limit with a test is enough; the story reports the number
  and where the design should name it).
- Red first. Budget: no test over 60 s, the step within 120 s; the sh assessors copy a prepared
  file and start no tool.
