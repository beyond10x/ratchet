---
format: aep.planning-md/3
id: review-result:adversary-workspace-cli-contract-attack-1
kind: review-result
status: active
title: adversary, story:workspace-cli-contract, attack 1 of 2
relations:
- reviews: story:workspace-cli-contract
revision: 1
---
Recorded by the coordinator from the adversary's report, verbatim except that the absolute path of the adversary's scratch directory on the workstation is replaced by `<S>`.

unit: story:workspace-cli-contract, branch head 2d8dab1 against base 9d1399a, attack 1 of 2

findings: 9, of which 8 reproduce with a command (all 9 are warnings; none is the known `CI=true` colour defect)

Covers branch head `2d8dab1`. The cases ran on `git archive bb0bb93` copies; only `.github/scripts/test-budget.test.sh` and `AGENTS.md` differ at `2d8dab1`, and finding 1 and 2 were re-run against the `2d8dab1` script. I wrote nothing in the tree. `S` below is `<S>`.

## Findings

**1. `test-budget.test.sh` accepts three `nextest.toml` forms that break the 60 s kill** (`introduced`)
- **File:** `.github/scripts/test-budget.test.sh:104` (function `limits`, line 97).
- **Command:** `sh S/forge2/.github/scripts/test-budget.test.sh` (the `2d8dab1` script plus the cases in `S/cases/test-budget-added-cases.sh.part`).
- **Output:**
  ```
  FAIL refuse <- ADVERSARY slow-timeout with a period of 600 s written after a grace-period of 1 s: accepted
  FAIL refuse <- ADVERSARY an override that gives every test 300 s, written with dotted keys: accepted
  FAIL refuse <- ADVERSARY slow-timeout with on-timeout = pass: a test ended at 60 s counts as passed: accepted
  test-budget: 8 of 12 broken copies refused
  exit 1
  ```
- **Why:** the awk takes the leftmost `period = "…"`, which is the one inside `grace-period`. It only matches `slow-timeout =`, so `slow-timeout.period = …` in an override is not read. It does not know `on-timeout`.
- **cargo-nextest 0.9.143 honours all three** (`S/logs/mini-nextest.txt`, a 3 s test under a 1 s period): `grace-first` and `dotted-override` give `PASS [ 3.003s]`, exit 0; `on-timeout = "pass"` gives `TIMEOUT-PASS [ 1.002s]`, exit 0.
- **What reaches it:** nobody today; the tree's `nextest.toml` is right. Acceptance bullet 4 says the script "exits 0 only when" the file kills at 60 s, and `AGENTS.md:66` says it "refuses a weaker value"; both are false for these forms.
- **Smallest change:** in `limits`, match `period` only after `{`, `,` or a space that is not preceded by `-`; refuse any line with `slow-timeout.` or `on-timeout`; add the three cases.

**2. `test-budget.test.sh` accepts a `test` task that also runs `cargo test`** (`introduced`)
- **File:** `.github/scripts/test-budget.test.sh:154` (function `step`).
- **Command and output:** same run as finding 1: `FAIL refuse <- ADVERSARY a task test that also runs cargo test, which no file bounds: accepted`.
- **Why:** the stand-in exits 0 for every call that is not `nextest run`, and `step` only greps the calls for `nextest run`.
- **What reaches it:** a later story that adds `cargo test --doc`, since nextest runs no doctests.
- **Smallest change:** refuse any recorded call whose first word is `test`, with this case.

**3. `check:generated` accepts a symbolic link and a mode bit in a generated crate** (`introduced`)
- **File:** `.github/scripts/check-generated.sh:42` (`find . -type f`) and `:75` (`cmp -s`).
- **Command:** `slot sh S/cases/check-generated-holes.test.sh S/copy`
- **Output** (`S/logs/case-check-generated-holes.txt`):
  ```
  FAIL refuse <- crates/ratchet-cli-contract: build.rs added as a symbolic link to a file outside the crate: task check:generated answered pass
  FAIL refuse <- crates/ratchet-cli-contract: a symbolic link to a directory added: task check:generated answered pass
  FAIL refuse <- crates/ratchet-cli-contract: src/lib.rs made executable (git records mode 100755): task check:generated answered pass
  exit 1
  ```
- **Consequence:** with the linked `build.rs`, `cargo metadata --locked` lists a `custom-build` target for `ratchet-cli-contract` while the check prints `10 files as generated`. A build script from outside the generated directory would run in every build.
- **What reaches it:** a commit that adds a link; nobody today. `AGENTS.md:174` ("compares every file … one the generator did not write") is false for links.
- **Smallest change:** list with `find . ! -type d`, refuse any entry that is not a regular file, compare the executable bit; the three cases go into `check-generated.test.sh`.

**4. `check-generated.test.sh` changes one byte in the first file only** (`introduced`)
- **File:** `.github/scripts/check-generated.test.sh:68-77`.
- **Mutant m1:** `check-generated.sh:75` compares content only for `./Cargo.toml`. `slot sh .github/scripts/check-generated.test.sh` then prints `check-generated: 3 of 3 changes refused in 1 generated crate(s)`, exit 0.
- **Case that kills it:** `slot sh S/cases/check-generated-each-file.test.sh S/m1` gives 9 `FAIL refuse` lines (every file but `Cargo.toml`), exit 1; on the unchanged copy it gives 10 `ok`, exit 0.
- **Smallest change:** loop the one-byte case over every file of the crate (one generation takes under a second).

**5. A documents-only change can break `task check` and the job `gate` does not run it** (`introduced`)
- **File:** `.github/workflows/pages.yml:124` (`planning | docs-site) run=false`).
- **Command:** `slot sh S/cases/docs-change-skips-gate.test.sh S/copy`
- **Output:** `FAIL <- docs/evidence-format.md: line 50 removed, spec/record-fields.test.sh fails (record-fields: 96 of 96 field rows declared, 0 missing, and the sections or tables are not as this script states them), and the class is docs-site: task check runs: false`
- **Why:** `check:spec` reads `docs/evidence-format.md` and `docs/design.md`, and the classifier puts `docs/*` in `docs-site`. The story's scope prescribes "for the other classes the job exits 0", so this is the story's design, not a slip of the implementor.
- **What reaches it:** any pull request that edits a field table of `docs/evidence-format.md`; the next `code` pull request then goes red.
- **Smallest change:** run `task check:spec` in the job for `docs-site`, or classify the two documents as `code` with a case in `check:ci-paths`.

**6. The binary cannot print its version** (`introduced`)
- **File:** `crates/ratchet/src/main.rs:10`; the generated parser (`crates/ratchet-cli-contract/src/runtime.rs:257`) declares no version.
- **Case:** `S/copy/crates/ratchet/tests/version.rs`, test `version::prints_the_workspace_version`.
- **Output** (`S/logs/case-rust.txt`):
  ```
  left: (Some(2), "", "cli_parse\n")
  right: (Some(0), "ratchet 0.0.0\n", "")
  ```
- **What reaches it:** `story:changelog-release-procedure` (`release-verify.sh`: "the binary of the `x86_64` archive prints the version"). Its own test uses a stub binary, so its gate would stay green and the real binary would fail at the release. That story's scope holds no file of `crates/`.
- **Smallest change:** answer `--version` in `main.rs` before `cli_contract::run`, with this test; or a generator story in ess.

**7. A reader that closes the pipe makes the binary panic** (`introduced`)
- **File:** `crates/ratchet/src/main.rs:16` (`print!`).
- **Case:** `S/copy/crates/ratchet/tests/closed_pipe.rs`, test `closed_pipe::reader_gone_is_no_panic`: `status Some(101)`, `failed printing to stdout: Broken pipe (os error 32)`.
- **By hand:** `ratchet --help | true` gave exit 101 with the panic text 3 of 3 times. `ratchet completions bash | head -n 1` did not panic.
- **What reaches it:** any pipe into a reader that exits first; every later command's output goes through this line. The generated `main.rs` has the same line.
- **Smallest change:** write with `std::io::Write` and end quietly on `BrokenPipe`.

**8. No test observes which handler a command reaches** (`introduced`)
- **File:** `crates/ratchet/src/commands/mod.rs:20-23`.
- **Mutant m2:** keys `"valid8"` and `"reference_adopt"`, `assess` and `evaluate` swapped. `slot task check:rust` exit 0; `slot task test` 5 of 5 passed, exit 0.
- **What holds:** every command reaches `Commands::call` (`cli_handler_unavailable` has one source, `runtime.rs:864`), and the four keys equal the callables of `spec/cli.yaml` today.
- **What reaches it:** the four stories that are told to edit neither `mod.rs` nor `main.rs`; a wrong key would only show in their own test.
- **Smallest change:** hold the four as a table of `(callable, fn)` and unit-test that each key is a callable of `cli_contract::plan()`. A swap stays unobservable until two handlers differ.

**9. Two tools of the job `gate` are not pinned by checksum** (`introduced`, not reproduced with a command)
- **File:** `.github/workflows/pages.yml:160-163` (`arduino/setup-task`, `version: 3.54.0`, no checksum) and `:157` (`node-version: "22"`).
- **Context:** `ess`, `aep` and `cargo-nextest` carry a SHA-256 in the same job; a sibling repository's workflow pins `task` with one. `jq` and `awk` come from the unpinned `ubuntu-latest`.
- **Smallest change:** download `task` by URL with a SHA-256 like the three others.

## Mutants

- m1: `check-generated.sh:75` compares content only for `./Cargo.toml` -> `check-generated.test.sh` exit 0 (survives; finding 4)
- m2: all four arms of `commands/mod.rs` mis-wired -> `check:rust` exit 0, `test` exit 0 (survives; finding 8)
- m3: `serve` removed from `spec/cli.yaml` -> `check:generated` exit 201; after `task generate`, `test` exit 201 with `commands::unbuilt_commands_answer_unavailable` failed (killed)
- budget copies: `grace-period` first, dotted override, `on-timeout = "pass"`, `cargo test` beside -> `test-budget.test.sh` accepts all four (findings 1 and 2)
- drift copies: linked `build.rs`, linked directory, executable bit -> `check:generated` exit 0 (finding 3)

## Suite

- Test step with my two Rust cases (`S/copy`, `slot task test`): `7 tests run: 5 passed, 2 failed`, exit 201. Executed 5 -> 7, red 2.
- Whole gate on the unchanged copy (`S/clean`, `slot task check`, no `.git`): exit 0, 5 tests, `26 cases`, the four steps shown.

## Held

- The gate passes in a clean archive of the commit.
- Under dash and mawk (cached `ubuntu:24.04`, `--network none`): `spec/*.test.sh` (all but the jq ones), `check:generated`, `check-generated.test.sh`, `check:ci-paths` and `test-budget.test.sh` of `2d8dab1` with `GITHUB_ACTIONS` unset and `true`, all exit 0.
- A second generated crate as one more line (`ess generate synthesize --layout crate`): `--write`, the check and the script test pass with no other script edit (6 of 6 refused).
- Cargo resolves the synthesized package, although it is also named `ratchet` (1.0.0 beside 0.0.0).
- `task generate` reproduces the committed crate byte for byte.
- The generator refuses the tree directory (`unowned output destination`).
- `global-timeout` ends the run with exit 100.
- Local versions equal the pins (task 3.54.0, nextest 0.9.143, ess 0.98.0, aep 0.80.0, rustc 1.99.1); the ess and nextest checksums equal those in sibling workflows.
- No private data in the added lines.
- I hold no second form of the `CI=true` colour defect. The `GITHUB_ACTIONS` form I found at `bb0bb93` is closed at `2d8dab1`.

## Not tested

- The forge itself: release asset names, the aep 0.80.0 checksum (no second local source), and whether `aep plan artifact validate` can fetch its pinned protocol revision on a runner. It does a `git` fetch of `beyond10x/aep` when its cache is empty.
- `record-examples.test.sh` and `gate-inputs.test.sh` under dash and mawk: the image has no `jq`.
- The cargo steps and `site` under dash and mawk.

## To know

- My empty-`HOME` probe of `aep plan artifact validate` made that same protocol fetch from the forge once.
- Everything I wrote is under `S` (`cases/`, `logs/`, the copies `copy`, `clean`, `m1`, `m2`, `e2`, `forge`, `forge2`, `mini`, `emptyhome`); their `target/` directories are removed. `S/forge` holds the m3 mutation and `S/e2` the second crate.
- Where the cases belong: `version.rs` and `closed_pipe.rs` in `crates/ratchet/tests/` with their `mod` lines in `tests/main.rs`; the budget cases in `test-budget.test.sh`; the drift cases in `check-generated.test.sh`; the documents case in `check:ci-paths`.

```findings
[
  {"file": ".github/scripts/test-budget.test.sh", "line": 104, "category": "acceptance", "severity": "warning", "origin": "introduced", "message": "The awk of limits accepts a 600 s period written after grace-period, an override with dotted slow-timeout keys and on-timeout = pass, all of which cargo-nextest 0.9.143 honours."},
  {"file": ".github/scripts/test-budget.test.sh", "line": 154, "category": "mutant", "severity": "warning", "origin": "introduced", "message": "A test task that also runs cargo test, which no file bounds, is accepted because step only looks for the nextest run call."},
  {"file": ".github/scripts/check-generated.sh", "line": 42, "category": "boundary", "severity": "warning", "origin": "introduced", "message": "The drift check lists regular files only and compares content only, so a symbolic link such as a build.rs pointing outside the crate and an executable bit are accepted."},
  {"file": ".github/scripts/check-generated.test.sh", "line": 68, "category": "mutant", "severity": "warning", "origin": "introduced", "message": "The one-byte case changes the first file only, so a drift check that compares the content of Cargo.toml alone passes the script test."},
  {"file": ".github/workflows/pages.yml", "line": 124, "category": "contract-drift", "severity": "warning", "origin": "introduced", "message": "A change of docs/evidence-format.md that makes task check:spec fail is class docs-site, for which the job gate does not run task check."},
  {"file": "crates/ratchet/src/main.rs", "line": 10, "category": "contract-drift", "severity": "warning", "origin": "introduced", "message": "ratchet --version exits 2 with cli_parse and no invocation prints a version, which the release verification of story:changelog-release-procedure reads from the binary."},
  {"file": "crates/ratchet/src/main.rs", "line": 16, "category": "boundary", "severity": "warning", "origin": "introduced", "message": "print! panics with exit 101 when the reader of standard output is gone, as in ratchet --help | true."},
  {"file": "crates/ratchet/src/commands/mod.rs", "line": 20, "category": "mutant", "severity": "warning", "origin": "introduced", "message": "With every handler arm mis-keyed or swapped, check:rust and the five tests stay green, so the wiring the four command stories rely on is unobserved."},
  {"file": ".github/workflows/pages.yml", "line": 160, "category": "judgement", "severity": "warning", "origin": "introduced", "message": "The task binary is installed by version without a checksum and Node by a floating major, while ess, aep and cargo-nextest in the same job carry a SHA-256."}
]
```
