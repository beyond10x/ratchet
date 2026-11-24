---
format: aep.planning-md/3
id: story:workspace-cli-contract
kind: story
status: active
title: Workspace, generated command surface and the gate for code
summary: Cargo workspace, ess-generated CLI crate with a drift check, the binary answering unavailable for 16 commands, gate tasks and the CI job.
relations:
- decomposes: epic:runnable-cli
- depends_on: story:record-formats-in-spec
scope:
- confidence: cited
  path: .cargo
- confidence: cited
  path: .config
- confidence: cited
  path: .github/scripts/check-generated.sh
- confidence: cited
  path: .github/scripts/check-generated.test.sh
- confidence: cited
  path: .github/scripts/test-budget.test.sh
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
  path: crates/ratchet
- confidence: cited
  path: crates/ratchet-cli-contract
- confidence: cited
  path: rust-toolchain.toml
revision: 21
transitions:
- {from: "draft", to: "proposed", at: "2026-11-24T18:13:29Z", actor: "agent:ratchet", revision: 20, decided_on: {"recorded":{"review_outcome":18}}}
- {from: "proposed", to: "active", at: "2026-11-24T18:13:29Z", actor: "agent:ratchet", revision: 21, decided_on: {"recorded":{"review_outcome":18}}}
---
## Context

No code exists. This story lays the workspace every later story builds in: the manifests, the
pinned compiler, the generated command surface with its drift check, the binary, the gate tasks
and the CI job.

It is the part of `story:cli-skeleton-validate` that one open question does not change. The
crate that `ess generate synthesize` writes holds no typed decoder
(`review-result:adversary-record-formats-pass-1`, finding 5), so which generated crate holds the
model, and what reads a file into it, is a question to the owner with three options. Nothing in
this story reads a project's file or depends on the model crate, so it is built while the
question is open. `story:cli-skeleton-validate` keeps the model crate, `ratchet-core` and
`ratchet validate`.

Measured on 2026-11-24 with `ess` 0.98.0:

- `ess generate cli --path spec --binding spec/cli.yaml --out <dir>` writes a Cargo package
  `ratchet-cli-contract` (10 artifacts: a library `cli_contract` with a `Handler` seam, a
  `ratchet` binary, `help.txt`, a bash completion, `binding.json`, `manifest.json`). Its
  dependencies are `clap`, `clap_complete`, `serde`, `serde_json`, `rpassword` and `rustix`. The
  package carries its own `[workspace]` table. The command has a `--check` mode.
- A command without a handler gets the generated adapter's answer: exit status 1, nothing on
  standard output, the line `cli_handler_unavailable` on standard error (`src/runtime.rs` of the
  generated package, the arms `HandlerReply::Unavailable` and `failure`).
- Every generated file carries a digest of the whole specification.

## Acceptance

`slot task check` exits 0 in a clean checkout of this story's merge commit, its output shows the
steps `check:rust`, `check:generated`, `check:scripts` and `test`, and:

- its test step lists as passed `commands::unbuilt_commands_answer_unavailable`: the `ratchet`
  binary of `crates/ratchet`, run once for each of the 12 commands of `spec/cli.yaml` that no
  story of 0.1.0 builds, with the arguments the command's declaration requires, exits 1 with
  nothing on standard output and the line `cli_handler_unavailable` on standard error;
- its test step lists as passed `validate::unavailable`, `assess::unavailable`,
  `reference_adopt::unavailable` and `evaluate::unavailable`: the same answer from each of the
  four commands a later story builds;
- its step `check:scripts` runs `.github/scripts/check-generated.test.sh`, and that script exits
  0 only when `task check:generated` exits 0 on a copy of the tree and non-zero on the same copy
  after one byte of a generated file changed;
- its step `check:scripts` runs `.github/scripts/test-budget.test.sh`, and that script exits 0
  only when `.config/nextest.toml` kills a test at 60 s and the `test` task fails over 120 s and
  prints its ten slowest tests;
- the workflow job that runs `task check` ends green on this story's pull request, and its log
  shows `rustc` at the channel `rust-toolchain.toml` names.

## Scope

- `Cargo.toml`, `Cargo.lock`, `rust-toolchain.toml`, `.cargo/config.toml`, `.config/nextest.toml`
- `crates/ratchet-cli-contract/`: the output of `ess generate cli`, never edited
- `crates/ratchet/`: the binary. It implements the generated `Handler` and wires all 16
  commands. `src/commands/` holds `validate.rs`, `assess.rs`, `reference_adopt.rs` and
  `evaluate.rs` (each returns the unavailable answer); the 12 other commands share one function
  that returns it. `tests/main.rs` declares the test modules `commands`, `validate`, `assess`,
  `reference_adopt`, `evaluate`, each with its file. The test `unavailable` of a command is in
  that command's test file, so the story that builds the command replaces it there and edits no
  file another story edits
- `.github/scripts/check-generated.sh`: the drift check. It holds one line per generated crate
  (the directory and the generator line) and, for each, uses the generator's check mode or
  compares bytes with a fresh generation. A second generated crate is one more line and no other
  edit
- `.github/scripts/check-generated.test.sh`: reads the same lines and runs its one-byte case
  once per line, so a second crate needs no edit of this script
- `.github/scripts/test-budget.test.sh`: reads `.config/nextest.toml` and the `test` task and fails
  when the 60 s kill, the 120 s bound of the step or the list of the ten slowest tests is missing
- `Taskfile.yml`: `includes` of `acceptance/Taskfile.yml` as optional, `check:scripts` (runs
  every `.github/scripts/*.test.sh`), `check:generated` (runs `check-generated.sh`), `check:rust`
  (fmt and clippy with `-D warnings` on the hand-written crates; a generated crate is never
  edited, so it is neither formatted nor linted), `test`. `check` runs the four after
  `check:spec`. The cases of `check:ci-paths` stay as they are: they hold both sides of the
  path list already
- `.github/workflows/pages.yml`: the job that runs the gate for a change classified `code`. It
  goes in this file because the classifier step and the repository's one path list are here; the
  job reads that step's result and repeats no path: its steps run for the class `code`, and for
  the other classes the job exits 0 without building. No new workflow file
- `AGENTS.md`: the ownership table, the gate section, how to regenerate, and how the root
  workspace holds a generated package that carries its own `[workspace]` table, so the next
  generated crate is held the same way
- `.gitignore`

## Notes

- Red first: the tests, `check-generated.test.sh` and `test-budget.test.sh` fail before the code
  exists.
- The tests run the binary in its default output mode: with `--output json` the answer is a JSON
  object on standard error.
- The acceptance is judged at this story's merge commit: each of the four `unavailable` tests of
  a built command is replaced by the story that builds the command.
- If the generated adapter answers a command without a handler differently from the answer the
  acceptance names, the story stops and reports the answer.
- Test budget: one integration-test binary per crate (`tests/main.rs` with modules); nextest
  `slow-timeout` 60 s with `terminate-after`, and the step fails over 120 s and prints its ten
  slowest tests. No cargo test calls `ess`: `check:generated` and its script test are gate steps
  outside the test step. The story times both and reports the two times.
- `rust-toolchain.toml` pins one rustc for the local gate and CI; the CI job reads the channel
  from that file.
- No Python. No `RUSTC_WRAPPER`, `SCCACHE_*` or `CARGO_PROFILE_DEV_DEBUG` setting.
- The CI job needs the `ess` and `aep` binaries at pinned versions; `spec/ess-inputs.yaml` already
  requires `ess 0.98`. `check:spec` needs `jq`.
- A required check in the ruleset is the owner's to add; the story reports the job's name.
- No specification file, `docs/design.md` or example changes here.
- No `crates/ratchet-model/` and no `crates/ratchet-core/` here: `story:cli-skeleton-validate`
  adds both, with the dependencies they need.
