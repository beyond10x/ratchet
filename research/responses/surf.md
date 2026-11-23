# Response: surf

- kind and stack: a web browser for agents and terminals, built from specifications; Rust workspace (22 crates), an ESS specification, a small web page (the live view) with Playwright tests, POSIX sh tasks
- answered by: the coordinating agent session of the repository
- date: 2026-11-23

## A. The project
A1: CLI and daemon binaries (`surf`, `surf-agent`, `surfd`, `surf-session`) plus libraries. Rust; 1,484 tracked files, 366 `.rs` files, 133,802 Rust lines outside `generated/` (seen: `git ls-files`). Users: coding agents (through `surf-agent`), developers at a terminal.
A2: Loads web pages over http (https in work) and shows them as text an agent can act on: follow, fill, press, look, with a "what changed" block per action. A live view page shows a person what the agent's sessions do.
A3: Agent sessions only write; one human operator decides. 45 merges on `main` in 7 days, 585 commits behind them, 6 releases (0.1.0 to 0.6.0) (seen: `git log --first-parent --since`, `git tag`).

## B. What you track today
B1 (all seen, `Taskfile.yml:568-594`, one local gate `task check`, the same task in CI job `check`; each blocks the push to `main`):
- tests: 1,240 workspace tests + 545 TLS tests (cargo-nextest), 71 page tests (Playwright), doc tests; counts printed, not thresholded.
- warnings denied in every build (`RUSTFLAGS: -D warnings`); clippy and rustfmt pinned by `rust-toolchain.toml` (1.99.1).
- generated code in sync with the specification (`generated-check`: 30 artifacts by digest).
- dependencies: `lock-check` holds `Cargo.lock` to an allow-list file (19 lines); 49 packages, 19 from outside. No age or advisory check.
- test layout: one integration-test binary per crate (`test-layout`), with a test of the check itself.
- committed fixtures in sync by digest (`tls-certs-check`, `tls-flights-check`, `doc-tests-check`).
- docs: CI workflows "Documentation validation" and "Documentation site"; a shared source scan ("Shared source gates") for private text in a public tree.
- nothing: coverage, complexity, mutation score (mutants are made by hand by an adversary agent per story, not counted).
B2 (seen): wall time of four test steps, each printed and failed over 120 s (`conformance step`, `test step`, `tls test step`, `page step`), their sum by `step-budgets`; 60 s per test, killed by the runner (`.config/nextest.toml:5`, Playwright `timeout`); the ten slowest tests printed. Gate time is printed (156 s to 912 s today for the same tree size, by host load) and not thresholded. Build time: not tracked. Flaky tests: not counted; each is a story. Since today a task prints the page step's CPU seconds and instructions (`perf stat`), outside the gate.
B3 (seen): the push script waits for the forge's runs and exits non-zero when one is red. Release: a manual trial run of the release workflow, checksums, a binary scan and a smoke test before the tag. Not tracked: CI duration over time, lead time, release frequency, failed releases.
B4 (seen):
- specification scenarios: 201 of 201 on an interpreter and on the Rust system, one suite digest (`conform`, `conform-rust`, `conform-totals`).
- external conformance suites with committed expected counts: html5lib-tests (9,107 cases, 9,095 run and passed), x509-limbo (5,143 cases, 5,089 run, 5,060 passed).
- agent tasks: 4 scripted end-to-end tasks with a status file (`crates/agent-tasks/status.txt`); also run on the release archive.
- page tests of the live view in headless Chromium.
- nothing: latency, binary size threshold, accessibility, production errors (there is no production).
B5 (seen): 120 s per test step and 60 s per test (Taskfile variables; gate fails); `REFUSALS_MAX: 56` specification refusals (`Taskfile.yml:80`; fails above); the allow-list of the lock (fails on a package not listed); expected conformance counts (fails below); page step at most 122 G instructions as a median of three runs (written in `AGENTS.md`; checked by hand, not by the gate).
B6 (seen): conformance counts against committed `expected/` files: below fails, above prints a `raise:` line, and a release is refused while a `raise:` line exists, so the file is raised by a commit. Agent tasks the same way against `status.txt`. Generated files and fixtures against a digest of their sources. Nothing compares against the previous run or against `main`.
B7: no history store. Numbers over time exist only as prose in `AGENTS.md` (2,309 lines, sections "The gate's numbers"), in commit messages, in evidence records of the planning store (`.engineering/evidence/`), and in six badges (`docs/badges/*.svg`) rewritten at a release (seen).

## C. What went wrong
C1 (seen, today): a test that checks "no process of the run is left" read `/proc` once and failed on a host under load; it was on `main` for hours and made 2 local gates red before a push. Noticed by the gate itself, on an unrelated documents change. No check would have caught it earlier: it passes on an idle host and on CI. A run of the tests under CPU contention would have.
C2 (seen): the page step. The same 71 tests took 19.0 s on the forge and 20 s to 209 s locally, by host load; over 120 s is red. 3 of about 12 local gate runs today were red only for that. A second one: a page test whose "live" marker stays "connecting" for 10 s at a load over 100 (seen in 2 test files, cause not found yet).
C3 (seen): the reverse case is on record: the page step story first set a bound in CPU seconds, could not meet it, and replaced it with a bound in instructions after measurement (CPU seconds moved 60 % with host load, instructions under 2 % within budget); its claim "holds at a load over 100" was withdrawn in writing instead of raising the 120 s. The local gate now waits for a load under 90 before it starts. Earlier: one test's call bound went from 1 s to 10 s (it was a real-call bound mistaken for the test's subject). No allow-list entry was added to pass a change.

## D. Friction
D1: (1) wall-time thresholds on a shared host: 9 gate runs and 42 minutes for one documents-only push this afternoon; a gate needs 2.5 to 15 minutes plus 10 to 16 minutes of queue. (2) Numbers copied by hand: every release a sub-agent rewrites the gate's counts in `README.md`, the website, `AGENTS.md` and a badge (7 files today).
D2: Which claims of a test were proven against a mutant, which tests are sensitive to load, and what was measured before a threshold was chosen. It lives in `AGENTS.md` prose and in per-story evidence records; no check reads either.
D3: Any wall-time number taken on the shared host (see C2), and `node --cpu-prof` seconds under load (it showed 92 s where `perf` counted 14 s). The test counts: a count going up says nothing about what the tests can catch.
D4: n/a

## E. Quality in plain words
E1: What the documents say a command does is what the binary does, and each such sentence has a test that fails when the behaviour is broken on purpose. A hostile page or server cannot make surf use unbounded time or memory, read a secret back, or reach an address the rules forbid. The gate answers within minutes and its verdict is the same on the workstation and on the forge. An agent that reads an answer can tell what changed and what failed, by a name. Nothing personal and no third-party code beyond a short reviewed list is in the public tree.
E2: Today: conformance counts, the dependency list, generated files in sync, step time, the private-text scan. With work: "each documented sentence has a test that fails on a planted fault" (a mutation score per claim; the planted faults exist only in reports), "same verdict here and on the forge" (a record of local-green/forge-red and of red-by-load runs), resource bounds under hostile input (fuzz and budget tests exist per story, no summed measure). Never by a machine alone: whether an answer's text is clear to an agent; the scripted agent tasks approximate it, and a model run would measure it at a cost in money.
E3: Agents: an answer that changes shape without a version, or a failure without a named reason. Terminal users: a page that loads elsewhere and fails here. Developers and agent sessions that build it: a gate that is red for a reason outside the change. The operator: a release whose notes claim something the binary does not do. Embedders of its parts (the script engine's host side): a host call whose cost or outcome is undefined.
E4: "The instructions of each test step (median of three runs, `perf stat`, user mode), compared with the value accepted on `main`: a rise over 5 % fails the gate; a drop over 5 % prints a `raise:` line that must be committed before the next release." It is the same lower-is-better form the conformance counts already use, on a measure that does not move with host load.
