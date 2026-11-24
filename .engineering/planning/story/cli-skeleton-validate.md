---
format: aep.planning-md/3
id: story:cli-skeleton-validate
kind: story
status: active
title: Workspace, generated surface and ratchet validate
summary: Cargo workspace, ess-generated CLI and model with a drift check, CI job, and validate on a project's documents.
relations:
- decomposes: epic:runnable-cli
- depends_on: story:record-formats-in-spec
scope:
- confidence: cited
  path: .cargo
- confidence: cited
  path: .config
- confidence: cited
  path: .github/scripts/check-generated.test.sh
- confidence: cited
  path: .github/workflows/gate.yml
- confidence: cited
  path: .github/workflows/pages.yml
- confidence: cited
  path: .gitignore
- confidence: cited
  path: AGENTS.md
- confidence: cited
  path: Cargo.lock
- confidence: cited
  path: Cargo.toml
- confidence: cited
  path: Taskfile.yml
- confidence: cited
  path: crates
- confidence: cited
  path: rust-toolchain.toml
revision: 6
transitions:
- {from: "draft", to: "proposed", at: "2026-11-24T13:10:21Z", actor: "agent:ratchet", revision: 5, decided_on: {"recorded":{"review_outcome":2}}}
- {from: "proposed", to: "active", at: "2026-11-24T13:10:21Z", actor: "agent:ratchet", revision: 6, decided_on: {"recorded":{"review_outcome":2}}}
---
## Context

No code exists. This story lays the workspace every later story builds in, and ends with the first
command a project can run. It starts after `story:record-formats-in-spec`, so both generators run
once, on the specification 0.1.0 is built from.

Measured on 2026-11-24 with `ess` 0.98.0:

- `ess generate cli --path spec --binding spec/cli.yaml --out <dir>` writes a Cargo package
  `ratchet-cli-contract` (10 artifacts; a `Handler` seam, a `ratchet` binary, `help.txt`, a bash
  completion). A command without a handler gets the generated adapter's "unavailable" answer.
- `ess generate synthesize --path spec --target rust --layout crate --out <dir>` writes one crate
  with no dependencies: one module per domain, typed decoders, a JSON reader and writer. Every
  generated file carries a digest of the whole specification.

## Acceptance

`slot task check` exits 0 in a clean checkout, and its output lists as passed the tests
`validate::accepts_valid_project` (exit 0, `valid: true`) and `validate::reports_duplicate_id`
(exit 1, code `spec_invalid`, a finding `duplicate_id` for an id declared in two files) and the
script `.github/scripts/check-generated.test.sh`, which changes one byte of a generated file in a
copy of the tree and gets a non-zero exit from `task check:generated`.

## Scope

- `Cargo.toml`, `Cargo.lock`, `rust-toolchain.toml`, `.cargo/config.toml`, `.config/nextest.toml`
- `crates/ratchet-model/`: the output of `ess generate synthesize --target rust --layout crate`,
  never edited
- `crates/ratchet-cli-contract/`: the output of `ess generate cli`, never edited
- `crates/ratchet-core/`: the hand-written library. This story writes `spec` (find and read
  `ratchet.toml` and the files of `[spec] paths`, YAML to the generated decoders) and `validate`
  (the report). `spec` takes the content of each file from a source the caller gives it, with
  the working tree as the one source built here, so `story:evaluate-command` reads the files of
  a revision in its own module and does not edit `spec`. It creates the empty modules `evidence`, `assessor`, `reference`, `compare`,
  `store`, `assess`, `adopt`, `gate` and `validate/assessor`, and in `tests/main.rs` the empty
  test modules `evidence`, `store`, `assessor`, `compare`, `reference`, each with its file
- `crates/ratchet/`: the binary. It implements the generated `Handler` and wires all 16
  commands. `src/commands/` holds `validate.rs` (built) and `assess.rs`, `reference_adopt.rs`,
  `evaluate.rs` (each returns the unavailable answer); the 12 other commands share one function
  that returns it. `tests/main.rs` declares the test modules `validate`, `assess`,
  `reference_adopt`, `evaluate`, each with its file
- The dependencies of the whole slice, declared here in the manifests: SHA-256, a decimal type,
  a YAML reader, a TOML reader. Git is read through the `git` binary and a child process is
  started with the standard library, so no later story of 0.1.0 edits a `Cargo.toml` or
  `Cargo.lock`
- `Taskfile.yml`: `includes` of `acceptance/Taskfile.yml` as optional, `check:scripts` (runs
  every `.github/scripts/*.test.sh`), `check:generated` (both generators with their check mode,
  or a byte comparison with a fresh generation), `check:rust` (fmt, clippy with `-D warnings`),
  `test`
- `.github/scripts/check-generated.test.sh`
- `.github/workflows/`: a job that runs the gate for a change classified `code`, using the one
  path list the repository already has (`pages.yml`, `task check:ci-paths`)
- `AGENTS.md`: the ownership table, the gate section, how to regenerate
- `.gitignore`

## What `ratchet validate` checks in this story

- `ratchet.toml` is found from the working directory upward; `--spec` overrides `[spec] paths`.
- Every file decodes as a `ratchet/1` document through the generated decoders (`schema_violation`
  with the file and key path).
- The files declare one `format` and one `project`; an id is unique across the files
  (`duplicate_id`, design § 5 "Local config" rule 5).
- A requirement names an assessment and a measurement that exist; a gate names requirements that
  exist (`unresolved_reference`).
- The other codes of `ratchet.cli.ValidationCode` are not built here; the story lists the ones it
  leaves in its report.

## Notes

- Red first: the two `validate` tests and `check-generated.test.sh` fail before the code exists.
- Test budget: one integration-test binary per crate (`tests/main.rs` with modules); nextest
  `slow-timeout` 60 s with `terminate-after`, and the step fails over 120 s and prints its ten
  slowest tests. No cargo test calls `ess`: `check:generated` and its script test are gate steps
  outside the test step. The story times both and reports the two times.
- The story reports the text and the exit status of the unavailable answer.
- A later story that needs a dependency this story did not declare names it in its report, and
  its change merges after the other stories of its wave.
- `rust-toolchain.toml` pins one rustc for the local gate and CI.
- No Python. No `RUSTC_WRAPPER`, `SCCACHE_*` or `CARGO_PROFILE_DEV_DEBUG` setting.
- The CI job needs the `ess` and `aep` binaries at pinned versions; `spec/ess-inputs.yaml` already
  requires `ess 0.98`.
- A required check in the ruleset is the owner's to add; the story reports the job's name.
- No specification file, `docs/design.md` or example changes here: those belong to
  `story:record-formats-in-spec`.
