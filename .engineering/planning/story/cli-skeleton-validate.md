---
format: aep.planning-md/3
id: story:cli-skeleton-validate
kind: story
status: draft
title: Workspace, generated surface and ratchet validate
summary: Cargo workspace, ess-generated CLI and model with a drift check, CI job, and validate on a project's documents.
relations:
- decomposes: epic:runnable-cli
scope:
- confidence: cited
  path: .cargo
- confidence: cited
  path: .config
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
  path: docs/design.md
- confidence: cited
  path: examples
- confidence: cited
  path: rust-toolchain.toml
- confidence: cited
  path: spec/README.md
- confidence: cited
  path: spec/domains/specification.yaml
revision: 2
---
## Context

No code exists. This story lays the workspace every later story builds in, and ends with the first
command a project can run.

Measured on 2026-11-24 with `ess` 0.98.0, on the specification at `7673482`:

- `ess generate cli --path spec --binding spec/cli.yaml --out <dir>` writes a Cargo package
  `ratchet-cli-contract` (10 artifacts; a `Handler` seam, a `ratchet` binary, `help.txt`, a bash
  completion).
- `ess generate synthesize --path spec --target rust --layout crate --out <dir>` refuses the
  specification: three structs declare a `shorthand:` (`MinimumBound`: `min`, `MaximumBound`:
  `max`, `RatchetPolicy`: `from`), and the Rust target decodes a struct from its object only.
  With the three `shorthand:` lines removed it writes one crate with no dependencies (13
  artifacts, 203 capabilities, 0 obligations, 0 refused): one module per domain, typed decoders,
  a JSON reader and writer.

## Decision taken with this story

The three shorthands leave the specification until the ESS Rust target decodes them. In
`ratchet/1` a coverage bound is written `{min: 18}` or `{max: 0}`, and an adoption
`{from: same_change}`. The bare spellings of design § 3 and § 5 can return later without
breaking a document written in the long form. The story writes this into `docs/design.md`,
`spec/README.md` § "Where this specification still departs" and the examples, and names the ESS
refusal text so the gap can be filed with ESS.

## Acceptance

In a clean checkout `slot task check` exits 0, having built the `ratchet` binary from the
generated packages and failed in a test when a generated file was changed by hand, and
`ratchet validate` exits 0 with `valid: true` on a fixture project and exits 1 with the code
`spec_invalid` and a finding `duplicate_id` on a fixture project that declares one id in two
files.

## Scope

- `Cargo.toml`, `Cargo.lock`, `rust-toolchain.toml`, `.cargo/config.toml`, `.config/nextest.toml`
- `crates/ratchet-model/`: the output of `ess generate synthesize --target rust --layout crate`,
  never edited
- `crates/ratchet-cli-contract/`: the output of `ess generate cli`, never edited
- `crates/ratchet-core/`: the hand-written library. This story writes `spec` (find and read
  `ratchet.toml` and the files of `[spec] paths`, YAML to the generated decoders) and `validate`
  (the report), and creates the empty modules `evidence`, `assessor`, `reference`, `compare`,
  `store`, `assess`, `adopt`, `gate`, so later stories each change a file of their own
- `crates/ratchet/`: the binary. It implements the generated `Handler`, one file per command
  under `src/commands/`; `validate` is built, the 15 others return a declared refusal
- `spec/domains/specification.yaml`, `spec/README.md`, `docs/design.md`, `examples/`
- `Taskfile.yml`: `includes` of `acceptance/Taskfile.yml` as optional, `check:scripts` (runs every
  `.github/scripts/*.test.sh`), `check:generated` (both generators with their check mode, or a byte comparison
  with a fresh generation), `check:rust` (fmt, clippy with `-D warnings`), `test`
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

- Red first: the two `validate` fixtures and the drift test fail before the code exists.
- Test budget: one integration-test binary per crate (`tests/main.rs` with modules); nextest
  `slow-timeout` 60 s with `terminate-after`, and the step fails over 120 s and prints its ten
  slowest tests. No test calls `ess`: the drift check is a gate step of its own.
- `rust-toolchain.toml` pins one rustc for the local gate and CI.
- No Python. No `RUSTC_WRAPPER`, `SCCACHE_*` or `CARGO_PROFILE_DEV_DEBUG` setting.
- The CI job needs the `ess` and `aep` binaries at pinned versions; `spec/ess-inputs.yaml` already
  requires `ess 0.98`.
- A required check in the ruleset is the owner's to add; the story reports the job's name.
