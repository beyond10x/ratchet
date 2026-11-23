# Response: runbook

- kind and stack: agent-workflow tool (CLI, local daemon, web inspector, protocol and spec documents, docs site); Rust (4 crates), POSIX sh and jq glue, Node (Playwright UI tests, Docusaurus site), YAML/JSON documents
- answered by: read-only research sub-agent, orchestrated by the repository's main session
- date: 2026-11-23

Labels: (seen) = read in a file or command output this session; (inferred) = my reading. Paths are repository-relative. The project is 3 days old (first commit 2026-11-21), so every "over time" figure covers 3 days.

## A. The project
A1:
- Kind: CLI plus local daemon and web inspector, with a set of protocol documents and a public docs site; it is also a ledger of measured runs. (seen: `AGENTS.md` "What it is", `README.md`)
- Tracked files by type: 304 `.rs` (about 98,500 lines), 125 `.mjs`, 38 `.sh`, 588 `.yaml`, 736 `.json`, 813 `.md`; 3,071 tracked files in total. (seen: `git ls-files`)
- Users: developers and coding agents running a "runbook" (a fixed, checked way to handle a case, decided by a program from recorded facts, with a model carrying out single steps); an operator inspecting runs in the web view. Source releases only, nothing published to a registry (`docs/releasing.md`, top). (seen)

A2:
- Runbook runs agentic runbooks: a program decides the next step from recorded facts, a model only executes single steps. The first runbook is a software delivery cycle (idea to built, tested product) in eight protocol documents. (seen: `AGENTS.md:3-20`)

A3:
- Agent sessions only: all 1,161 commits are authored by the repository's bot identity, one unit per worktree (seen: `git log --format=%an`; `AGENTS.md` "Commits", "Sessions").
- Rate: 1,161 commits in 3 days (357 on 2026-11-21, 541 on 11-22, 263 on 11-23 so far); 152 first-parent commits on `main`, of which 117 are merges of units, waves or releases (seen: `git log --first-parent`). 17 release tags 0.1.0 to 0.9.1 in 3 days (seen: `git tag`); `CHANGELOG.md` and `docs/releases/0.9.2.md` already hold 0.9.2.

## B. What you track today
B1:
- Tests: Rust tests in cargo-nextest, `task test:runbook` (local gate and CI) and `task test:driver` (local gate only); UI tests in Playwright, `task test:ui` (local gate only). (seen: `Taskfile.yml`, `.github/workflows/pages.yml`)
- Lint: `cargo clippy --locked --all-targets -- -D warnings` on 4 crates, blocks `task check`, local gate only (`Taskfile.yml:21`). No rustfmt check in any task or workflow. (seen)
- Generated files in sync, blocking in `task check`: ESS JSON Schema and OpenAPI (`check:ess-generated`); conformance suite by a digest of its sources (`check:ess-suite:synthesized`, about 1 s); protocol ledger by digest with a seal (`check:protocols`, under 1 s; full regeneration is the slow lane in `protocols.yml`, only when protocols, the Canon pin or the script changed); site protocol data (`sdc-protocol-site check`, CI); golden prompts byte for byte (`driver/tests/bugfix_prompt.rs`). (seen)
- Repository hygiene: `check:unreferenced` lists tracked files nothing refers to (exit 1); `check:ci-paths` runs the CI change classifier on 24 file-list cases and fails when a nextest call lacks `--color never`; `runbook check` checks the text layout of bindings, instructions and views; `aep plan artifact validate` checks the planning store (`task plan`). (seen)
- Docs build: Docusaurus build, refusal of fixture data in the built site, and a Playwright smoke test of every page in two themes and two widths with axe and internal links, in CI (2-minute step limit). (seen)
- Toolchain: `rust-toolchain.toml` pins rustc 1.99.1; the CI step "Check the rustc pin" fails when the workflow differs. (seen)
- Coverage, dependency audit or age, complexity, static analysis, secret scan: none in the repository (grep for audit, deny, llvm-cov, tarpaulin, dependabot, codeql found nothing). The shared gates workflow runs on every pull request and push (`shared-gates.yml`); what it checks is defined in another repository: I don't know. (seen / inferred)

B2:
- Test step time: measured and bounded. `driver/.config/nextest.toml` and `runbook/.config/nextest.toml`: `slow-timeout` 30 s with `terminate-after` 2, so a test over 60 s is killed and fails; the task prints the ten slowest tests and fails when the run takes over 120 s (`SDC_TEST_BUDGET_SECONDS` moves the 120). Build time is not counted. (seen: `Taskfile.yml` `test:driver`, `test:runbook`)
- UI step: `ui/playwright.config.mjs:5-12` has `BUDGET = {testMs: 60000, runMs: 120000}`, `globalTimeout` 120 s, and a reporter that prints the slowest tests. The site smoke test has the same budget (`docs:test`). (seen)
- Pool limit: a build or test job in the shared pool ends at 10 minutes unless it names up to 30; slow lanes set `SLOT_TIMEOUT: 30m`. (seen: `Taskfile.yml`, folder rules)
- Total gate time (`task check`), clean and incremental build time: nothing recorded. One data point: a review record logs `test run 102.715s of 120s` for the driver step at host load about 101 (seen: `.engineering/planning/review-result/security-driver-test-budget-pass-3.md:16`).
- Flaky tests: not counted anywhere (no retry or flake metric); load-dependent timings are written as prose (see C2). (seen)
- Time an agent waits for a verdict: not recorded except inside such review records.

B3:
- CI: `pages.yml` "Documentation validation", `protocols.yml` "Protocol checks, slow lane", `shared-gates.yml` "Shared source gates", and `b10x-docs-site.yml` which publishes the site from the validated artifact. Job limits: `timeout-minutes` 30 (build, slow lane), 15 (runbook test step), 2 (site smoke test), 5 (site finder). (seen)
- CI duration from `gh run list` (about 10 recent runs, 2026-11-23): Documentation validation 4.5 to 11 min; Protocol checks 8 to 15 min; Shared source gates about 1 min on most runs. Kept on the forge, not in the repository. (seen)
- Time to first failing signal: not measured. A change that is only planning files skips build and test through the classifier in `pages.yml` ("Classify the changed files"), tested by `check:ci-paths`. (seen)
- Merge: a unit merges to `main` through a bot pull request and the merge queue after every CI run of its head is green (`docs/releasing.md` step 1; `AGENTS.md` "Commits"). Queue wait: not measured.
- Release frequency: 17 tags in 3 days, cut after each user-visible improvement (`docs/releasing.md` "Standing rule"). Lead time from commit to release: not recorded (derivable from `git log`). `task release:check VERSION=x` blocks a release when versions in 9 files, `CHANGELOG.md`, `docs/releases/x.md` or the planning store disagree. `task ci:watch SHA=...` exits non-zero unless every forge run of a commit succeeded. (seen)
- Failed or rolled-back releases: none recorded. One feature was reverted before 0.1.1 (`7c5dd5ed` "Revert feat/recorded-replay for 0.1.1"). (seen)
- Local gate versus forge: CI runs `task test:runbook` and the docs checks only. Driver tests, UI tests, clippy, ESS checks, binding checks and `check:unreferenced` run in the local gate and not in CI (seen: `pages.yml` steps against the `check` dependencies in `Taskfile.yml`). The folder rule "the local gate equals the forge" is therefore met for the `runbook` crate only (inferred).

B4:
- Functional: the nextest suites; one ESS conformance suite synthesized from the specification and committed with a digest (`ess/generated/conformance/DIGEST`); 131 cycle entries as data in `cycles/tree-suite.yaml` run by `runbook test`: 40 converted, 15 pending, 39 held by a Rust test, 37 dropped with the old driver (`docs/cycles-suite.md:106`); the pending list is the gap list. 9 bindings checked by `scripts/check-bindings.sh`; 9 protocols checked by Canon (state space, properties, findings, simulate) through `protocol/check-ledger.json`. (seen)
- Quality of what a runbook delivers: measured by experiments, not by a gate. `experiments/` holds 27 records, each with a hypothesis, settings, 3 runs per cell and a verdict rule (`docs/workflow-metrics.md`); a 23-item rubric scored 9 delivered products once (`docs/quality-0.1.0.md`). `docs/progress.md` shows clean passes of ended runs per release and model setting (0.1.0: 6 of 9; 0.3.1: 7 of 9). Nothing blocks on it. (seen)
- Performance: cost in USD and wall time per run are recorded per experiment; the target is 0.47 USD per run against 5.50 (strong) and 2.55 (mixed) in `experiments/targets.yaml`. Not a gate. Latency, throughput and binary size: nothing. (seen)
- UI and accessibility: Playwright specs at two viewports in `task test:ui`; the UI loop (`task ux`) measures layout, accessibility and a screen-only user bot at four viewports and ratchets against `ui/ux/baseline.json`; it is not in `task check` and not in CI. The docs site runs axe in CI. (seen)
- Errors in production, SLOs, user-facing incidents: none (no hosted service; source releases only). (seen)

B5:
- 60 s per test and 120 s per test step: `driver/.config/nextest.toml`, `runbook/.config/nextest.toml`, `Taskfile.yml`; the test is killed and fails, or the step exits non-zero. UI: `ui/playwright.config.mjs:5`. Site smoke test: 2-minute CI step.
- 10-minute pool limit, 30 for named slow lanes: the job is killed and exits 124.
- Protocol state space: Canon refuses over 65,536 states (`docs/limitations/output.txt` shows a 196,608-state protocol refused); finding counts per protocol are pinned in `protocol/check-ledger.json` (for example `reachable 78 ... findings 1`).
- `ui/ux/baseline.json` tolerances: counts 0, steps 0.05, layout_shift 0.01; a worse value needs a decision id (`--decision D-nnn`).
- CI job limits: 30 min (build, slow lane), 15 min for the runbook test step.
- Pins that fail on drift: rustc (`rust-toolchain.toml` against `pages.yml`), ess (`ess/ess-inputs.yaml` `requires: ess 0.98.0`, `ess-suite:pin`), Loom and Canon commits (`runbook/Cargo.lock`), go-task and nextest by sha256 in CI. (seen)
- Targets with no enforcement: the cost target 0.47 USD (`experiments/targets.yaml`) is a goal, not a gate; the KPI gates of `docs/kpis.md` are mostly "proposed" or "drafted" in its `today` column (inferred).

B6:
- Digest baselines (committed generated file plus a digest of its sources, a fast check compares): protocol ledger with a seal, conformance suite `DIGEST`, ESS schema and OpenAPI, site protocol data, golden prompts. Updated by `--record` or `task ess-suite:record` in the same commit, with the reason in the commit body when a finding set changes (`AGENTS.md` "Rules").
- `ui/ux/baseline.json`: all values lower is better; the ratchet fails on worse beyond the tolerance; `task ux:update` takes improvements; a worse value needs a numbered decision written into the file (10 commits to that file in 3 days).
- Experiments: each release is the next baseline, reused while input sha256, settings and tree match (`docs/improving.md` loop step 1); the verdict comes from a registered rule (`complete-separation`), not from reading numbers.
- Parity: `runbook parity compare` against a committed driver summary must end `parity: identical` (`docs/parity.md`).
- Merges to `main` are not compared against a previous test count or timing; I found no such file. (seen)

B7:
- `experiments/releases.yaml` (release ledger), `docs/progress.md`, `docs/progress.json`, `docs/img/progress.svg`, all written by `sdc-experiment progress`; `sdc-experiment check --all` fails when they are stale. `experiments/INDEX.md`. `ui/ux/rounds/R-01` to `R-03` with `trend.md`. `CHANGELOG.md` and 18 files in `docs/releases/`. The planning store `.engineering/` holds 53 review records and 24 approval records. `git log`. (seen)
- No dashboard, no CI-duration or test-time history in the repository; the forge keeps run times.

## C. What went wrong
C1:
- No single "last regression" is recorded; the repository has no incident log. What the records show, all caught before a release unless noted:
  - A feature (recorded replay) was reverted before 0.1.1 (`7c5dd5ed`, re-merged as `8a96b504`). The reason is not in the subject: I don't know.
  - Adversary pass 1 of unit `bindings-state-their-exits` found 2 committed driver tests left red by the unit and a guard that accepted a tree that was a file; caught at head `208ed8a7`, before merge (`.engineering/planning/review-result/adversary-bindings-state-their-exits-pass-1.md`).
  - A merge of `main` into a long branch was found red by a narrow check (`adversary-line2-main-merge-pass-1.md`).
  - `AGENTS.md` notes that a merge "can leave `website/data/protocols/index.json` stale without a conflict"; the post-merge `scripts/check-bindings.sh` catches it.
  - Experiment `parity-loom-strong` ended in its first model step before any model call (the adapter found no login under Loom); caught by the run's own summary (`experiments/INDEX.md`).
  - Delivered product: in 0.1.0, 3 of 6 SDC products failed rubric items F3, S3 or O7; found by the one-off rubric, about a day after the release (`docs/quality-0.1.0.md`). No gate could have caught it: no product check exists.
- Regressions that reached a user: none known (inferred: no users yet).

C2:
- Load-dependent timeouts (seen): `task test:bugfix-slow` took 17 to 30 s at load 44 to 45 and 49 s and 61.5 s at load 130, so the 60 s kill can fail it (`Taskfile.yml`, `docs/cycles-suite.md:336`). 7 of 8 re-run cycle entries ended `CycleTimedOut` at the 60 s bound at host load 94 to 156 (`docs/cycles-suite.md:121`). The replay setup step took 88 s at load 70 to 90 and over 180 s at load 100 to 127 (`docs/loom-run.md:461`).
- Environment-dependent (seen): the host's `ess` reached tests and passed locally while failing on the forge; now a trap `ess` comes first on the PATH (`scripts/host-tool-traps/ess`). The forge sets `CARGO_TERM_COLOR=always`, which broke the log parsing of the test tasks; now `--color never` plus a check for it. A run started as a unit has a German locale and a decimal comma in a bash timestamp (`AGENTS.md`).
- How often: not counted.

C3:
- Moved out of or around a limit:
  - The replay tests and 2 bug-fix tests are `#[ignore]`d out of the default step into slow lanes because they would exceed the budget (`Taskfile.yml` `test:replay`, `test:bugfix-slow`); the replay setup step may take 300 s while a test may take 60 s (`runbook/.config/nextest.toml`). Not tightened.
  - `SDC_TEST_BUDGET_SECONDS` lets the 120 s budget be moved through the environment (`Taskfile.yml`).
  - `driver/unreferenced-keep.txt` allows 26 files that the first run "found, as unexamined" (`CHANGELOG.md:258`); 27 lines now, not reduced as far as I can tell.
  - 15 cycle entries are kept as `pending` instead of failing the suite.
  - `ui/ux/baseline.json` decision D-002 took values that got worse on purpose into the baseline (more reading load, more actions per fix because tasks now complete).
- Counter-example (seen): the 60 s bound of the bug-fix slow lane "is not raised" although it can fail at load 130 (`docs/cycles-suite.md:336`).
- Tightened again afterwards: no record found; I don't know.

## D. Friction
D1:
- The 120 s test-step budget is close to the real run time on a loaded shared host: the driver step took 102.7 s of 120 s at load about 101, and each review pass reruns it (seen above). Timing checks therefore depend on host load.
- Waiting for slow checks: the protocol slow lane took 7.4 minutes at load 95 to 131 (a full protocol check was about 590 s before the digest ledger; `AGENTS.md`, `CHANGELOG.md:349`); CI takes 4.5 to 15 minutes per pull request and an agent waits for all runs before a unit merges (`gh run list`). Review passes: 53 review records for 297 stories, several units need 4 to 5 passes (`adversary-check-bindings-exits-reads-any-runbook-pass-1` to `-5`, `security-inspector-step-products-pass-1` to `-5`).

D2:
- Known and unchecked: (a) whether the product a runbook delivers works: `docs/progress.md` limit "No run starts the delivered product and no oracle check runs"; the 0.1.0 rubric was manual and one-off. (b) Runs are not reproducible from a pin: "every run so far used the canon binary of the canon checkout at run time, which no record pins" (`docs/progress.md`). (c) Experiment records were written after the runs, so none decides anything (same file). (d) The thoroughness of reviews lives in agent review records and the coordinator's habit (adversary and security passes per unit), not in a gate. (e) The rule "cut a release after every improvement" lives in `docs/releasing.md` and the operator's words, not in CI. (f) Rules on Rust only, no host paths in committed files and no new bash tools live in `AGENTS.md` and are only partly enforced.

D3:
- Timing checks under load (C2): a red can mean a busy host.
- The "clean pass" metric: a Canon outcome closed by rule, not a product seen working (`docs/progress.md` limits).
- The review gate: pass results are text records, not machine-checked against the head that merged (inferred).
- A green CI means less than a green local gate, because CI is narrower than `task check` (B3) (inferred).

D4:
- Mostly n/a. Untracked areas (coverage, dependency audit, formatting, CI-time history, flake rate, production errors): not needed yet, nobody asked, and no hosted product (inferred). The project is 3 days old; its recorded priorities are behaviour measured by experiments and fast tests.

## E. Quality in plain words
E1:
- A runbook run does what its protocol allows and nothing else: a program decides each step from recorded facts, and the model does a single step whose output is validated.
- Every check is quick and gives the same answer locally and on the forge: a test over a minute or a step over two minutes is a defect.
- Generated files, protocols and documents are never stale: they are regenerated or compared by digest, not edited by hand.
- A change merges only after tests written first, adversary and security passes and a green CI on its head; a release follows each improvement and says plainly what it does not do.
- A claim about quality names the run, file and line it comes from, and marks what was not observed.

E2:
- Machine-checkable today: sentence 2 (budgets, timeouts, pins), sentence 3 (digests, `--check` lanes), part of 1 (protocols checked by Canon, fixture runs, ESS conformance), part of 4 (CI green, `release:check`).
- With work: sentence 1 for the product a model delivers (an oracle that starts the product, named in `docs/progress.md` as missing); the review passes of sentence 4 (a record per unit tied to the merged head); sentence 2 on the forge (run the whole local gate in CI).
- Never fully: whether an adversary pass was good enough; whether a protocol models the right case.

E3:
- End users: a delivered product fails a requirement that passed in the previous release (for example offline edit in the 0.1.0 rubric).
- Developers: `task check` or its test step goes over 120 s, or a test passes locally and fails in CI.
- Coding agents: a run stops with a cause that is not named, or instructions and golden prompts change without a digest or test failing.
- Operators: a run is left waiting with nobody working on it, or the inspector shows a live run as stopped.
- Consumers of an API or format: the OpenAPI or run directory format changes without the committed generated file changing.

E4:
- Measured: wall time of the test step of `task check` (per crate and for the UI). Limit: no more than the last green run on `main` plus 10 percent and never over 120 s, compared with a committed baseline file. Checked: on every pull request, locally and in CI; raising the baseline needs a numbered decision recorded in the file.
