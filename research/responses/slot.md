# Response: slot

- kind and stack: CLI and user-level daemon (Rust), web UI (Vue 3 + TypeScript), docs site (Docusaurus)
- answered by: survey sub-agent of a slot maintenance session (read-only)
- date: 2026-11-23

## A. The project
A1:
- CLI plus a daemon that runs as a systemd user service, with an embedded web UI and a public docs site. **seen**
- Stack: Rust (about 36,300 lines of `.rs`), Vue/TypeScript (about 10,300 lines in `ui/src`, `ui/ux` and `website/ux`). 738 tracked files. **seen** (`git ls-tree origin/main`)
- Users: coding agents and developers on a shared build host, plus a plugin for agents (`plugin/`). **seen** (`AGENTS.md` § Ownership)

A2:
- One shared pool of build slots for every build on a machine. `slot serve` owns a GNU-make jobserver FIFO and queues jobs on it; `slot <command>` runs a command through the pool. The daemon records each job and serves a live web view.
- Its purpose: parallel agent sessions do not oversubscribe the CPU, disk or memory, and contention is measured instead of guessed. **seen** (`AGENTS.md`, `docs/design.md` § 1)

A3:
- Agent sessions only. All 130 non-merge commits on `main` are by the delivery bot; the operator directs and decides. **seen** (`git log --format=%an`)
- 72 merged PRs and 38 releases (0.1.0 to 0.30.0) between 2026-11-12 and 2026-11-23. That is about 40 PRs a week, but bursty: 24, 23 and 12 PRs on single days, and none on 3 of the 12 days. **seen** (`gh pr list --state merged`, `gh release list`)
- Median time a PR is open before merge: 7.7 min. **seen**

## B. What you track today
B1:
- The local gate is `task check` (`Taskfile.yml`). It runs `cargo fmt --check`, `cargo clippy --all-targets -D warnings`, `cargo test --workspace --locked`, the UI typecheck and tests, the UI build, the UX gates (`task ui-ux`), the docs build (`task site`) and the docs UX gates (`task site-ux`). It also checks that two generated files are in sync: `cli-reference --check` and `ts-types --check`. It blocks merge: CI runs the same `task check` in `.github/workflows/gate.yml`, a required check. **seen**
- Docs: `Build documentation` (`pages.yml`) checks that the CLI reference is current, builds the site and binds it to its commit (provenance). Required. **seen**
- Security: the required check `common / Security and privacy` comes from a shared reusable workflow (`shared-gates.yml`). Its contents are not read here. **seen**, contents unknown
- Dependencies: `--locked` everywhere, actions pinned by SHA, rustc pinned in `rust-toolchain.toml` (1.99.1). There is no dependency audit, count or age check, no coverage, and no complexity metric. **seen** (absence)
- Doc consistency: `crates/slot-docs/tests/docs_version.rs` (version in docs and plugin manifests). `website/ux/copy.test.ts` checks that "not built" / "planned" text appears only under a "Not built yet" heading, and that the status page agrees with the version. **seen**

B2:
- slot records every job it runs, its own gate included, in `jobs.jsonl`: queue wait, run time, CPU seconds, peak RSS, exit code, cache environment. There is no threshold on these. **seen**
- Local runs of slot's own steps on this host (from that log, run time):
  - `task check`: 40 runs, 27 exit 0, p50 164 s, p90 422 s, max 504 s.
  - `task ui-ux`: 19 runs, 9 exit 0, p50 124 s.
  - `task site-ux`: 5 runs, 0 exit 0, p50 129 s. **seen**
- Step time: `ui-ux` and `site-ux` are wrapped in `ux/deadline.ts 120` and fail at 120 s. Playwright kills a test at 60 s and prints the ten slowest (`ux/slowest.ts`). **seen**
- The Rust test step has no per-test kill and no step deadline: no nextest config, plain `cargo test`. **seen**
- Flaky tests: not tracked. They are told apart by rerunning a test alone (for example 3 of 3, or 40 of 40). **seen** (transcripts)

B3:
- CI duration exists only in GitHub Actions history. `gate` succeeded in 160 of 187 listed runs (18 failed, 9 cancelled). Successful runs: median 5.4 min, p90 12.3 min, max 61.6 min. **seen** (`gh run list --workflow gate.yml`)
- PRs whose files are all planning or prose skip the build and tests: `.github/scripts/pr-scope.sh`, tested by `pr-scope.test.sh`. **seen**
- Release (`release.yml`): the full gate; tag, `Cargo.toml` and `CHANGELOG.md` must agree; two Linux targets are built and smoke-tested. Then manual steps in `AGENTS.md` § Release: `sha256sum -c` on the downloaded assets, and the release author must be the bot. 14 of 14 recent `Release` runs succeeded (median 7 min). **seen**
- Not tracked: release frequency, lead time from commit to release, merge-queue wait. There were 8 patch releases among 38 and no rollbacks. **seen** (CHANGELOG); "no rollbacks" is **inferred**
- After a live install, `AGENTS.md` § Upgrading asks the agent to compare job ids in `/api/state` before and after the reload. This is a manual check. **seen**

B4:
- Functional: about 400 Rust lib tests; integration tests in `crates/slot-cli/tests/` (`handover.rs`, `signals.rs`, `job_tokens.rs`, `gate.rs`); release smoke tests on two targets. **seen**
- UI: the gates run at 1366x768 and 1280x720 against stubbed APIs from `ui/ux/scenarios.ts`. **seen**
  - `gates.spec.ts`: no sideways scroll, axe-core 0 serious or critical.
  - `screen-only.spec.ts`: a bot does each task by pointer and by keyboard in at most 2 actions.
  - `findings.spec.ts`: regression assertions of closed findings (37 findings UXF-001 to UXF-037).
- Docs site: the same kind of gates in both themes, reader tasks in at most 3 actions, 10 findings DXF-001 to DXF-010. **seen**
- Product performance (queue wait, CPUs per slot, lost tokens, cache hit rate) is measured ad hoc on the live host. Results are written in `docs/design.md` §§ 9-26 and `AGENTS.md` § Open work. Not gated. **seen**
- The daemon records host and pool metrics in its state directory: `census.jsonl` every 10 s (load, CPU/IO/memory pressure, slots used, jobs waiting, recommended pool size); `cache.jsonl` every minute (sccache hit and miss counters). No SLO or alert is set on either. **seen**
- Incidents (lost slots, a regression in the CPU hold) are recorded only as CHANGELOG entries and Open work items. **seen**

B5:
- Playwright 60 s per test (`ui/playwright.config.ts`, `website/playwright.config.ts`): the test fails. **seen**
- UX steps 120 s (`Taskfile.yml`, `ux/deadline.ts`): the step is killed and fails. **seen**
- clippy `-D warnings`: the gate fails. **seen**
- UX gates (`ui/ux/*.spec.ts`, `website/ux/*.spec.ts`): 0 sideways scroll, 0 serious or critical axe violations, at most 2 (UI) or 3 (docs) actions per task. A crossing fails the gate. **seen**
- Ratchet tolerances (`ui/ux/baseline.json` "tolerances"): counts 0, `reading_load.*` 10 % (fonts differ between hosts), `layout_shift.total` 0.01. A crossing fails `node ux/ratchet.ts`. **seen**
- CI job limits: `timeout-minutes` 30 for gate and release, 15 for docs. The job is cancelled. **seen**
- The workspace rule of 60 s per Rust test and 120 s for the Rust test step is not enforced in this repository. **seen** (absence)

B6:
- `ui/ux/baseline.json` and `website/ux/baseline.json` hold lower-is-better values per scenario and key. They are written by `node ux/ratchet.ts --update` and committed in the same change. A value made worse must name a decision id: 15 entries do (`R-11-job-tables-first`, `R-11-upgrade-pending-shift`). The baseline changed in 9 commits. **seen**
- The generated CLI reference and UI types are byte-compared with their committed files (`--check`). **seen**
- Rounds are compared with earlier rounds in `ui/ux/rounds/trend.md` and `website/ux/rounds/trend.md`, by hand. **seen**

B7:
- UX rounds R-01 to R-11, each with `report.md`. UI gate problems went from 61 in R-01 to 0 from R-05 on. Docs rounds D-01 and D-02: 124 and 120 gate problems. **seen**
- The daemon's logs, local to the host: `jobs.jsonl` (60,651 jobs since 2026-11-12, every repository on the host), `census.jsonl` every 10 s, `cache.jsonl` every minute. The web view charts the history. **seen**
- `.engineering/evidence/`: 44 evidence JSON files for stories and epics. **seen**
- GitHub Actions run history. There is no dashboard of slot's own gate time or flakiness. **seen**

## C. What went wrong
C1:
- 0.25.0 to 0.25.1, the same day (2026-11-23). The CPU hold kept a job's first hold clock while the job then waited for disk. After a disk hold of about 44 min, 5 jobs started at once on the live host. The operator's session noticed this on the live daemon from the job log ("28 starts"), within hours of the release. **seen** (CHANGELOG 0.25.1, transcripts)
- A test that combines a disk hold with a CPU hold would have caught it; the fix added that regression test. **seen**
- An older case, 0.21.1: lost jobserver tokens stayed lost for up to 173 min on a busy pool. It was found from live measurement, not by a check. **seen**

C2:
- `evict::tests::a_target_a_process_runs_from_is_in_use_until_it_ends` went red on CI 3 times on one PR. The defect was in the test, not the code, and the test was fixed. **seen**
- `jobserver::tests::switching_between_slots_and_shares_keeps_every_token_placed` read the token count while a token was in flight: red once on CI. After the fix it passed 40 of 40 runs locally. **seen**
- Under host load: `a_stream_of_short_jobs_does_not_hold_a_longer_job_past_the_bound` failed once and then passed 3 of 3 alone. The handover test failed 1 to 2 of 6 runs at load 98 to 123. **seen** (transcripts)
- The local UX steps fail on the 120 s deadline at host load 50 to 170 (`AGENTS.md` Open work (l)). Locally `ui-ux` passed 9 of 19 runs and `site-ux` 0 of 5. On the forge, `ui-ux` finishes in about 45 s. **seen**

C3:
- Round keys `reading_load.*` and `layout_shift.total` were made worse in R-11 under named decisions (15 baseline entries). They were not tightened again. The round ratchet (`--round`) fails until a round takes them in (Open work (q)). **seen**
- `reading_load.*` has a 10 % tolerance because fonts differ between hosts. **seen**
- No timeout was raised to get a change through. A CI gate that hit its time limit was rerun, not extended. **seen** (transcripts)

## D. Friction
D1:
- The local gate on a shared, loaded host. `task check` takes p50 164 s and p90 422 s, and only 27 of 40 local runs exited 0. The UX steps often stop at their own 120 s deadline because the host is busy, not because of the change. Agents then use the forge as the full verdict (median 5.4 min, p90 12.3 min). **seen** (job log, gh); "use the forge as the verdict" is **inferred**
- Deciding whether a failure is a real break or a load flake costs reruns of tests alone (3 to 40 runs each). **seen**

D2:
- Product behaviour at scale: queue wait p90, CPUs per slot, slot-hours held idle, lost tokens. It lives only in measurements in `docs/design.md` and `AGENTS.md` § Open work, taken by agents with jq on the job log. **seen**
- That a live reload kept every job is a manual `AGENTS.md` step. One integration test covers the handover. **seen**
- `slot headroom --base machine` has never run against a live `systemctl` in a test (Open work (f)). **seen**

D3:
- Local UX gates and timing-based Rust tests under host load: a red result says more about the load than about the change. **seen**
- The round ratchet: it is known to fail until a round takes in the new header height (Open work (q)). **seen**
- `reading_load`: depends on host fonts, hence the 10 % tolerance. **seen**

D4: n/a

## E. Quality in plain words
E1:
- Every build on the machine goes through one pool, and no slot is lost or used twice.
- A job waits only as long as the machine is really busy, and the reason it waits is shown.
- Upgrading the daemon never drops or reruns a job that has started.
- An agent or a person sees what runs, what waits and why, without scrolling or hunting.
- The docs say only what the released version does.

E2:
- Checked today: no lost or double-used slot (unit tests and live recovery), upgrade keeps started jobs (handover integration test), the view is readable without hunting (UX gates and ratchet), the docs match the release (copy and version tests). **seen**
- Checkable with work: wait only as long as the machine is busy, as queue wait and CPUs per slot from the job log against a previous window after each release. **inferred**
- Never fully: whether the shown reason for waiting is understood by its reader. **inferred**

E3:
- Agents and developers: a `slot <command>` that queues longer than before while CPUs sit idle, or a job killed or dropped on reload.
- Operators: slots held by no live process, or a reload that needs a full restart.
- UI users: a job, or the reason it waits, not visible without scrolling.
- API and plugin consumers: a field missing in `/api/state`, or an older client failing against a newer daemon.

E4: After each live install, measure queue-wait p90 and CPUs per slot from `jobs.jsonl` over 60 min and compare them with the 60 min before the reload; a value worse by more than 20 % fails the release check unless it names a decision. (Proposal, not built.)

Not answered: the contents of the shared `common / Security and privacy` workflow (another repository, not read); CI history of non-gate workflows before 2026-11-22 is partial; the local `task check` pass rate mixes real failures with load timeouts.
