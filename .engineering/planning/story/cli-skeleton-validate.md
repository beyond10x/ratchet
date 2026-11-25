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
- depends_on: story:workspace-cli-contract
- depends_on: story:changelog-release-procedure
scope:
- confidence: cited
  path: .github/scripts/check-generated.sh
- confidence: cited
  path: AGENTS.md
- confidence: cited
  path: Cargo.lock
- confidence: cited
  path: Cargo.toml
- confidence: cited
  path: crates/ratchet-core
- confidence: cited
  path: crates/ratchet-model
- confidence: cited
  path: crates/ratchet/Cargo.toml
- confidence: cited
  path: crates/ratchet/src/commands/validate.rs
- confidence: cited
  path: crates/ratchet/tests/fixtures/validate
- confidence: cited
  path: crates/ratchet/tests/validate.rs
revision: 27
transitions:
- {from: "draft", to: "proposed", at: "2026-11-24T13:10:21Z", actor: "agent:ratchet", revision: 5, decided_on: {"recorded":{"review_outcome":2}}}
- {from: "proposed", to: "active", at: "2026-11-24T13:10:21Z", actor: "agent:ratchet", revision: 6, decided_on: {"recorded":{"review_outcome":2}}}
---
## Context

`story:workspace-cli-contract` lays the workspace: the manifests, the pinned compiler, the
generated command surface with its drift check, the binary whose 16 commands answer
"unavailable", the gate tasks and the CI job. This story adds the model crate and the
hand-written library, and ends with the first command a project can run.

It waited on one question to the owner: which generated crate `crates/ratchet-model/` holds.
Measured on 2026-11-24 with `ess` 0.98.0:

- `ess generate synthesize --path spec --target rust --layout crate --out <dir>` writes one crate
  with no dependencies: one module per domain, the types, a `broken_constraint` check per type
  with invariants, the entity lifecycles, a JSON reader and writer. It holds no typed decoder:
  ESS emits those only with a server (`review-result:adversary-record-formats-pass-1`,
  finding 5).
- `ess generate types --path spec --target rust --all-types --package ratchet-model --out <dir>`
  writes a serde data library: 191 types that decode and encode, dependencies `serde`,
  `serde_json`, `time`. Its `types-report.json` lists 116 obligations it leaves to the consumer,
  12 of them `model_invariants` (55 statements: 4 types of `ratchet.specification`, 1 of
  `ratchet.config`, 6 of `ratchet.evidence`, 1 of `ratchet.assessor`).
- Both write a package that carries its own `[workspace]` table.

The owner's answer, 2026-11-25: ESS first. `crates/ratchet-model/` is the output of
`ess generate synthesize` and nothing else: the types, the invariant checks, the lifecycles and
the decoders. No model code is written by hand, and `ess generate types` is not used. ESS gets
a story for typed decoders from `generate synthesize` without a server.

The story is not dispatched until an ESS release emits those decoders. What that release has
to give, as sent to the ESS repository on 2026-11-25 with a minimal specification:

1. a typed decoder and encoder for every struct, enum, newtype and entity snapshot, emitted by
   `--layout crate` with no HTTP binding; a decoder refuses an undeclared member of a closed
   struct, ignores one of a struct with `undeclared_fields: ignored`, refuses a value that
   breaks an invariant and names the key path;
2. a name for the package (`--package ratchet-model`): the synthesized package is named after
   the system, which is the name of the binary crate;
3. a package without its own `[workspace]` table;
4. a struct with `shorthand:` in the Rust target;
5. declarations for the rules of the file form (below), so that the decoder applies them;
6. a `.ess-output/state.json` that does not change between two runs on one specification, or
   the rule that the file is not committed: its `anchor_id` is new on every run.

Items 1 to 3 are what this story needs before it starts. Until ESS has items 4 and 5, the
mapping from the file form to the entities is hand-written in `crates/ratchet-core` (`spec`),
outside the model crate, and hands the generated decoders a value tree.

A `ratchet/1` file is not the declared entities written out. `spec/README.md` § "How a
`ratchet/1` file differs from the declared entities" lists the twelve rules a reader applies
(the root, an entity keyed by its id, `project` written once, a bare requirement name, an absent
`serves`, a number as the decimal of its text, the YAML 1.2 core schema).

## Acceptance

`slot task check` exits 0 in a clean checkout, and:

- its test step lists as passed `validate::accepts_valid_project`: in
  `crates/ratchet/tests/fixtures/validate/valid/` (a `ratchet.toml` and two files of one project
  that declare an assessment with a measurement, a requirement that names both and a gate that
  names the requirement) the command exits 0 with `valid: true`;
- its test step lists as passed `validate::reports_duplicate_id`: in
  `crates/ratchet/tests/fixtures/validate/duplicate/` (the same project with one id declared in
  both files) the command exits 1 with code `spec_invalid` and a finding `duplicate_id` for that
  id;
- its test step lists as passed `validate::reports_schema_violation`: in
  `crates/ratchet/tests/fixtures/validate/undeclared-member/` (the valid project with one member
  the format does not declare) the command exits 1 with a finding `schema_violation` that names
  the file and the key path;
- its test step lists as passed `validate::reports_unresolved_reference`: in
  `crates/ratchet/tests/fixtures/validate/unresolved/` (the valid project with a requirement that
  names a measurement no file declares) the command exits 1 with a finding
  `unresolved_reference` for that name;
- its test step lists as passed `validate::accepts_examples`: for each of the five
  `examples/*.ratchet.yaml`, given with `--spec`, the command prints a report with the member
  `valid` and no finding `schema_violation`;
- its test step lists as passed `invariants::each_listed_domain_is_covered`, which fails when an
  invariant of a type of `ratchet.specification` or `ratchet.config` in `spec/domains/` has no
  entry in the list file of its domain, or an entry names no test;
- its step `check:scripts` runs `.github/scripts/check-generated.test.sh`, whose case for
  `crates/ratchet-model/` gets a non-zero exit from `task check:generated` after one byte of a
  file of that crate changed in a copy of the tree.

## Scope

- `crates/ratchet-model/`: the output of `ess generate synthesize`, never edited. The root
  workspace holds it the way `AGENTS.md` records for `crates/ratchet-cli-contract` since
  `story:workspace-cli-contract`
- `crates/ratchet-core/`: the hand-written library. This story writes `spec` (find and read
  `ratchet.toml` and the files of `[spec] paths` into the types of `crates/ratchet-model`, by the
  twelve rules of `spec/README.md`) and `validate` (the report). `spec` takes the content of each
  file from a source the caller gives it, with the working tree as the one source built here, so
  `story:evaluate-command` reads the files of a revision in its own module and does not edit
  `spec`. It creates the empty modules `evidence`, `assessor`, `reference`, `compare`, `store`,
  `assess`, `adopt`, `gate` and `validate/assessor`, and in `tests/main.rs` the test module
  `invariants` and the empty test modules `evidence`, `store`, `assessor`, `compare`,
  `reference`, each with its file
- `crates/ratchet-core/tests/invariants.rs` and `crates/ratchet-core/tests/invariants/`: the
  test that compares the invariants the specification declares with the tests that break them.
  One list file per domain (`specification.txt` and `config.txt` here) names, for each invariant
  of the domain's types, the test or fixture that breaks only it. The test reads
  `spec/domains/*.yaml` and fails for a domain with a list file when an invariant has no entry or
  an entry names no test. A later story adds the list file of its domain and edits no file of
  this story
- `crates/ratchet/src/commands/validate.rs` (built), `crates/ratchet/tests/validate.rs`, where the
  five `validate` tests of the acceptance replace `validate::unavailable`, the fixtures under
  `crates/ratchet/tests/fixtures/validate/`, and `crates/ratchet/Cargo.toml` for the dependency
  on `ratchet-core`
- `Cargo.toml`, `Cargo.lock`: the two crates and the dependencies of the whole slice: SHA-256, a
  decimal type, a YAML reader that gives the text of a scalar as written and reads by the YAML
  1.2 core schema, a TOML reader. Git is read through the `git` binary and a child process is
  started with the standard library, so no later story of 0.1.0 edits a `Cargo.toml` or
  `Cargo.lock`
- `.github/scripts/check-generated.sh`: the line of `crates/ratchet-model/`. The script test
  reads the same lines and is not edited
- `AGENTS.md`: the rows of the ownership table for the two crates, and how to regenerate the model

## What `ratchet validate` checks in this story

- `ratchet.toml` is found from the working directory upward; `--spec` overrides `[spec] paths`.
- Every file decodes as a `ratchet/1` document into the generated types (`schema_violation` with
  the file and key path).
- The files declare one `format` and one `project`; an id is unique across the files
  (`duplicate_id`, design § 5 "Local config" rule 5).
- A requirement names an assessment and a measurement that exist; a gate names requirements that
  exist (`unresolved_reference`).
- The other codes of `ratchet.cli.ValidationCode` are not built here; the story lists the ones it
  leaves in its report.

## Notes

- Red first: the five `validate` tests and the test `invariants` fail before the code exists.
  `check-generated.test.sh` derives its case from the line of `crates/ratchet-model/`, so that
  case exists from the moment the line does; the story shows it red once by running it against
  a copy with one changed byte.
- Test budget: one integration-test binary per crate (`tests/main.rs` with modules); no test over
  60 s, the step within 120 s. No cargo test calls `ess`.
- The story times `task check:generated` and `.github/scripts/check-generated.test.sh` before
  and after the line of `crates/ratchet-model/` and reports the four times; a jump is fixed here.
- The model crate has no dependencies, so it turns on no feature of another crate. The gate of
  this story runs the tests of `story:workspace-cli-contract` with the model crate in the
  build; a test whose answer changes is fixed here.
- Each invariant of a type `validate` reads (`ratchet.specification`, `ratchet.config`) has a test
  with a value that breaks only it, and the test `invariants` fails when the specification holds
  an invariant of those types that no entry names
  (`review-result:adversary-record-formats-pass-2`, finding 4).
- A later story that needs a dependency this story did not declare names it in its report, and
  its change merges after the other stories of its wave.
- `story:changelog-release-procedure` edits `AGENTS.md` too (§ "Release"). It merges before this
  story; the `depends_on` edge to it records that order and nothing else this story reads.
- No Python. No `RUSTC_WRAPPER`, `SCCACHE_*` or `CARGO_PROFILE_DEV_DEBUG` setting.
- No specification file, `docs/design.md` or example changes here: those belong to
  `story:record-formats-in-spec`.
- Not edited here: `rust-toolchain.toml`, `.config/nextest.toml`, `.github/workflows/`,
  `Taskfile.yml`, `.github/scripts/check-generated.test.sh`, `crates/ratchet-cli-contract/`.
