# Response: cortex

- kind and stack: CLI and local service, Rust, spec-first (ESS specification, generated model crate)
- answered by: the cortex maintainer agent session
- date: 2026-11-23

## A. The project
A1: CLI plus a long-running instance process, Rust. 37 files and 43,229 lines under `src/`; 150 `.rs` files under `tests/` (seen, `git ls-tree` on origin/main). Users: developers and coding agents that keep a knowledge store up to date; one consumer repository pins its releases (seen).
A2: Keeps "instances" of a knowledge store (EKR) current: it reads sources (files, web pages, structured records, connectors), has a model extract facts, and applies them to the store with evidence; it answers questions from the store (seen, repository docs).
A3: Agent sessions only, with one human approving releases and policy. 26 merged PRs on `main` in the last 7 days (seen, `git log --first-parent --merges --since='7 days ago'`).

## B. What you track today
B1: (seen, `Taskfile.yml` `check`, `.github/workflows/check.yml`)
- spec validity: `ess specify validate --strict-requires`, local and CI, blocks.
- generated files in sync: `task drift` regenerates `generated/` and `spec/suite.json` and diffs, blocks.
- spec compatibility: `task compat` diffs `spec/` against the newest release tag, `--fail-on breaking-or-unknown`, blocks unless `spec/compat-ack.json` acknowledges.
- `cargo fmt --check`, `clippy -D warnings`, blocks.
- tests with cargo-nextest (1,414 passed, 11 skipped at PR #95's head), blocks.
- docs build (`task docs-check`, CI "Build documentation"), blocks.
- secret and privacy scan of every commit (CI "Security and privacy", b10x-gates policy), blocks; also scanned locally before each commit by the commit bot.
- planning store validity (`aep plan artifact validate`), blocks.
- coverage, complexity, dependency age: nothing.
B2:
- a single test over 60 s is killed and fails (nextest `slow-timeout`, `.config/nextest.toml`), blocks.
- test step wall time printed against 120 s plus ten slowest tests (`Taskfile.yml` `test`); blocks only with `TEST_BUDGET=enforce`, currently `report` (seen).
- each pool job is killed after 10 min by the host's build pool (seen).
- build time, gate time, flaky tests, verdict wait: not recorded.
B3:
- CI `task check` job time is visible per run (3m29s and 5m58s on the last two merges, seen) but not tracked.
- PRs that change only planning or prose skip build and tests (`.github/scripts/scope.sh`, seen).
- release frequency, lead time, failed releases: not tracked. Inferred from tags: 6 releases between 2026-10-17 and 2026-11-23.
B4:
- conformance: ESS scenarios synthesized into `spec/suite.json` and run against the real binary; a test holds the counts of executed scenarios (seen, PR #93 changed them from 92/88 to 102/98).
- end-to-end tests run a real `ekr` binary at the pinned version with a stand-in model (seen, `AGENTS.md`).
- performance, accessibility, production errors, SLOs: nothing; the product runs on the user's machine.
B5:
- test 60 s: `.config/nextest.toml`, test killed and failed.
- test step 120 s: `Taskfile.yml`, `.config/nextest.toml` `global-timeout`, fails only in `enforce` mode.
- pool job 10 min: host build pool, job killed.
- secret-scan candidate size 512 MiB: the scanner's code; crossing it fails the security job (seen 2026-11-23: 512.3 MiB failed `main`).
B6:
- compat: baseline is the newest `v*` tag's `spec/` (`git archive`); acknowledgements in `spec/compat-ack.json`, reset after a release.
- drift: baseline is the committed generated files.
- conformance counts: the accepted numbers in a test, edited by hand.
- secret scan: a baseline commit in the policy file; commits after it are scanned.
B7: nothing over time. Evidence of gate runs is written as JSON under `.engineering/evidence/` per story (seen), and CI keeps the nextest JUnit report as an artifact per run; no trend is computed.

## C. What went wrong
C1: 2026-11-23: `main` went red after a merge because the secret-scan candidate (every commit since the policy baseline) grew to 512.3 MiB, over a fixed 512 MiB limit. Noticed by the CI run on `main` minutes after the merge; the local commit bot refused the next push too. No check tracked the candidate's growth, so nothing warned before the limit (seen). Earlier: an external review of release 0.7.2 found 28 defects, and the consumer repository found further gaps in 0.8.0; no gate caught those (seen).
C2: timing-sensitive tests (wall-clock waits, a quadratic redaction path) ran 11.5-24.9 s and flaked under host load; fixed to 0.1-3.3 s (seen, PR #109). Frequency not recorded.
C3:
- test step budget: left at `report` while CI measured 124 s against 120 s; a story to share one PostgreSQL server across tests is open to switch to `enforce` (seen).
- secret scan: the policy baseline was moved forward to bring the candidate under 512 MiB; a scanner change to count each distinct blob once (316.8 MiB) is in progress (seen).
- compat: 37+ acknowledged incompatible spec changes since the last reset (seen).

## D. Friction
D1:
- waiting in the shared build pool: 200-370 s queue wait per job, clippy 421 s and test build 331 s wall on a loaded host (seen, one gate run on 2026-11-23); 79 jobs queued at 22:29 CET.
- PR merge conflicts in counted or listed files (`CHANGELOG.md`, `spec/compat-ack.json`, conformance counts) with several PRs open; each needs a merge of `main` and a new CI run of 3.5-6 min (seen).
D2: limits of the upstream store and how cortex works around them live in a table in `AGENTS.md` (seen); consumer gaps live in the consumer's notes and messages; which tests are slow under load is known from runs, not recorded.
D3: the conformance count test, because a hand-edited number can be raised to match a lower coverage; the compat check, because acknowledgements accumulate until a release resets them.
D4: n/a.

## E. Quality in plain words
E1:
- A fact cortex writes to the store cites the source it came from, and the same source read twice writes the same facts.
- A run that fails says why, by name, and leaves the store as it was.
- Every behaviour the specification promises is exercised against the real binary.
- The gate gives a verdict within a few minutes, and a red gate on a branch means the branch is wrong.
- A release never breaks a consumer without saying so in its changelog.
E2:
- machine today: specification coverage, gate time, named failures (partly).
- with work: idempotent re-reads (a replay test per source kind), store unchanged after a failed run (a store digest before and after), consumer breakage (run the consumer's acceptance tests against a release candidate).
- never fully: whether an extracted fact is true to its source.
E3:
- end users: an answer cites a source that does not say it.
- developers: the gate takes longer or goes red without a code change.
- coding agents: an error message without a stable name or exit status to branch on.
- operators: a run leaves a lock, a process or a half-written store behind.
- API consumers: a release changes a command's output without a changelog line.
E4: measured: wall time of the test step and of each test; limit: 120 s and 60 s, and no more than 10 % over the previous `main` run; checked: on every PR, blocking.
