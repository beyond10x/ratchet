# Response: loom

- kind and stack: Rust workspace (agent runtime with its CLI, SDK, Kubernetes operator and Helm chart), Docusaurus docs site
- answered by: read-only survey sub-agent of the loom session, from tag 0.60.0 through `git archive`
- date: 2026-11-23

## A. The project
A1:
- Platform/runtime plus library and CLI: binary `b10x-loom`, SDK `b10x-loom-sdk`, operator `b10x-loom-operator`, chart `charts/loom-agents`, site under `website/` (seen: `AGENTS.md:3-5`, § Releases).
- Size at 0.60.0: 3,285 files (`git ls-tree -r --name-only 0.60.0 | wc -l`), 798 `.rs` files, 386,181 lines under `crates/`, 36 crates. About 500 test binaries (`AGENTS.md` § Gate). CI ran 4,073 tests in 502 binaries (CI run 45240437881, test step line). (seen)
- Users: developers embedding the SDK, operators running agents on Kubernetes, other beyond10x repositories and agent sessions (seen: `AGENTS.md:3-9`, `consumers/pinned/`).

A2: The governed agent runtime. It runs agent work so that the model sees and can do only what the current frontier admits, and authority is checked again before every effect (outcome O1). It runs any harness through metaharness, which observes and compares the sessions (outcome O3) (seen: `AGENTS.md:20-24`).

A3:
- One human operator plus agent sessions (wave lead, implementors, adversary, security reviewer, plan critics). Only the bot commits and pushes (seen: `AGENTS.md` § Never).
- Commits on the 0.60.0 history per week: 152 (2026-10-26), 119 (2026-11-02), 0 (2026-11-09), 678 (2026-11-17..23) (`git rev-list --count --since --until 0.60.0`). (seen)
- Merged PRs: 30 between 2026-10-27 and 2026-11-23, about 7.5 a week, in batches as wave or release PRs; the largest, PR 166, was +260,543/-3,940 lines in 676 files (`gh pr list --state merged --limit 30`). (seen)

## B. What you track today
B1:
- Local `task check` and CI job `loom / task check` run the same list (`Taskfile.yml:20-46`, `.github/workflows/check.yml:22-123`). All of it blocks the merge (inferred: required check).
  - 3 ESS spec validations and 2 ESS hard gates.
  - 4 drift checks on generated files (Rust model, CRD, Commission, intake) and `chart-check` (cmp, `helm lint`, `helm template` x2).
  - 2 `no-hand-model` checks.
  - 3 conformance suites, a dependency guard, `cargo fmt --check`, `clippy -D warnings`.
  - The test step, `durable-check`, `consumer-check` (an outside crate pinned by path), `embedder-check`.
  - `docs-check` (`loom-xtask docs-stamp --check`) and `commission:docs-drift`.
- CI also runs a macOS build/test of the SDK and the intake slice (`check.yml:192-216`), a docs slow lane gated by `docs-stamp --slow-needed` (`check.yml:125-190`), and a docs site build (`pages.yml`). The org-wide `Shared source gates` run on PRs and on pushes to main and tags (`shared-gates.yml:1-19`). (seen)
- Release binaries: refused if the binary links libgit2/libssh2/OpenSSL/zlib or holds the test sync switch (`binaries.yml:40-43`). (seen)
- Not found: coverage, mutation testing in CI, cargo-deny/audit, dependabot or renovate (`deny.toml` and `.github/dependabot.yml` absent; grep for llvm-cov/tarpaulin/cargo-deny/mutants found none). Mutation testing was done once by hand: `docs/qualification/ess-hardening-2026-10-06/commission-mutations.json`. (seen)

B2:
- Test step: 120 s for the step and 60 s per test (`crates/loom-xtask/src/test_step.rs:38,40`; `.config/nextest.toml:8`). Tests in `tree_run` are killed at 20 s each (`.config/nextest.toml:15-17`), may sum to at most 60 s (`test_step.rs:130`), and may start the binary at most 66 times (`START_BUDGETS`, `test_step.rs:145`). The step prints its ten slowest tests. Local and CI, blocking. (seen)
- Measured on CI: 68.9 s of 120 s, 96 tests skipped. Building the test binaries took 547.2 s and is not counted in the budget (run 45240437881 log). (seen)
- Not tracked: build time, gate time as a whole, flaky-test rate. (seen: no check found)
- Slow lane: `task slow`, `suite-generate` and `docs-slow` each get 30 min of build-pool time (`Taskfile.yml:73-99,197-214`). `suite-generate` takes 534.5 s (`AGENTS.md` § Gate, a note, not a check). (seen)

B3:
- CI check, last 21 runs (`gh run list --limit 100`, filtered to `check`): median 18.2 min, max 42.8 min, 16 ok / 3 fail / 1 cancel / 1 running. Job limit `timeout-minutes: 60` (`check.yml:26`). (seen)
- `release` workflow: 7/7 green, median 28.4 min, max 58.4 min (same command). (seen)
- Releases: 69 from 0.1.0 (2026-10-05) to 0.60.0 (2026-11-23) (`grep -c '^## \[[0-9]' CHANGELOG.md`). (seen)
- `release-check`: the tag must equal the workspace version, and `CHANGELOG.md` must carry `**Breaking:**` bullets or `No breaking changes.`, the latter only when no stable surface changed since the previous tag (`release.yml:33-36`; `crates/loom-xtask/src/release.rs:5-11`). Blocks the release. (seen)
- PR open-to-merge time: median 24 min, max 329 min (`gh pr list` createdAt/mergedAt). Merge-queue wait, lead time from commit to release, rollbacks: not tracked. Rule: fix forward, never move a tag (`AGENTS.md` § Releases). (seen)

B4:
- Behaviour: 3 conformance suites synthesized from ESS run against the executor, Commission and intake; they fail unless `conformance_status passed`. The ESS gate requires 0 refusals not covered by authored scenarios and no open question (`Taskfile.yml:68-71,170-178`). Local and CI, blocking. (seen)
- `AGENTS.md` § "Checks that hold the rules" maps each rule claim to a named test (75 table lines). (seen)
- Performance: the governor's cost tests bound a ratio against deciding at 40; it measures about 18 (`AGENTS.md` § Gate). (seen)
- Live runs are recorded by hand in 10 dated records under `docs/qualification/`. (seen)
- Kubernetes: Helm lint and render. UI: site build only. Not found: accessibility checks, production errors, SLOs, incident tracking. (seen: none found)

B5:
- 120 s per test step (`test_step.rs:38`) and 60 s per test (`test_step.rs:40`, `.config/nextest.toml:8`): the step fails.
- `tree_run`: 20 s per test (`.config/nextest.toml:17`), 60 s summed (`test_step.rs:130`), 66 binary starts (`test_step.rs:145`): the step fails.
- Slow profile: a test is killed at 20 min (`.config/nextest.toml:25`).
- `clippy -D warnings`, 0 warnings allowed (`Taskfile.yml:40`).
- ESS gate: 0 uncovered refusals and 0 open questions (`Taskfile.yml:69`).
- Governor cost ratio below 40 (`AGENTS.md` § Gate).
- CI job limits: 60, 30 and 15 min (`check.yml:26,128`; `release.yml:18`).
- All seen. Crossing any of them fails the step and blocks the merge or release (inferred for the merge, through required checks).

B6:
- Generated files are compared byte for byte with a fresh generation: drift checks, and the slow lane against `generated/ess/loom/` and its digest file `generated/ess/loom/synthesis.txt`. The committed file is the baseline, rewritten by `task generate`, `suite-generate` or `crd-generate`. (seen)
- Docs stamp `website/docs/reference/.generated.json` against the base branch's copy (`check.yml:178-186`). (seen)
- `release-check` diffs the stable surfaces against the previous tag (`release.yml:25`). (seen)
- One-off baseline: `docs/qualification/ess-hardening-2026-10-06/commission-baseline.json`. (seen)
- No timing or count baseline: the test budget is a fixed number. (seen)

B7:
- `CHANGELOG.md`: 69 releases, 17 `### Fixed` sections (grep). (seen)
- `.engineering/` holds 937 artifacts with timestamped transitions, including 318 review results (`aep plan artifact list --format json`). (seen)
- Dated records in `docs/qualification/`; GitHub Actions run history. (seen)
- Timings are written by hand as prose in `AGENTS.md` and stories, e.g. a `tree_run` table of 145 -> 98.4 -> 129.5 -> 144.5 s (`.engineering/planning/story/tree-run-tests-fit-the-budget.md`). (seen)
- No dashboard or trend store found. (seen: none found)

## C. What went wrong
C1:
- A credential-shaped stderr line reached `SessionReport::transcript` and the event observer. The adversary review of wave 2026-10-28-w1 found it; 0.57.1 fixed it on 2026-11-05, 8 days later (`CHANGELOG.md:255-263`; `.engineering/planning/story/session-transcript-withholds-stderr-credentials.md:36-39`). A related escape-sequence case was found by a security review and fixed in 0.57.2 (`CHANGELOG.md:242-253`). (seen)
- Check that could have caught it (inferred): one property test that runs the credential walk over every output channel.
- Process regression on main: the `tree_run` test binary grew to 145 s, over the budget. Found by measurement, it became a budget-defect story (`story/tree-run-tests-fit-the-budget.md`, table near line 151). (seen)

C2:
- CI run 45194449550: delegated-cgroup tests of the embedder fixture failed (6 shown). The runner could start a delegated scope but could not move a process into it, so the failure depended on the environment (log; `AGENTS.md` § Gate). (seen)
- CI run 44900979058 (`release/0.58.0`): 3 failures in `adversary2_executor_guard`, a test that finds its binary by Cargo's layout path (`AGENTS.md` § Gate); whether that was the cause: I don't know.
- Rate: 3 failures in 21 `check` runs. How many were false reds: I don't know.

C3:
- By rule, a test that cannot meet the budget is renamed `slow_...` and moved to the slow lane, never deleted (`AGENTS.md` § Gate). (seen)
- On CI, 96 delegated tests skip when the probe fails, because `LOOM_REQUIRE_DELEGATION` is not set (run 45240437881; `check.yml:103-120`). (seen)
- Tightened later: `tree_run` got a 20 s per-test kill and a 60 s sum (`.config/nextest.toml:15-17`). (seen)
- Whether a specific threshold was raised and later tightened: I don't know.

## D. Friction
D1:
- Waiting for the CI verdict: median 18.2 min and max 42.8 min per `check` run. 547.2 s of one run build test binaries against 68.9 s of tests (`gh run list`; run 45240437881). (seen)
- Red-and-rerun cycles: PR 166 took 329 min from open to merge, with 2 failed and 1 cancelled `check` runs on its branch before green (`gh pr list`; `gh run list`). (seen)
- `suite-generate` takes 534.5 s per batch (`AGENTS.md` § Gate). (seen)

D2:
- Most of it lives in `AGENTS.md` (3,229 lines) as prose with measurements: fsync counts, opt-level timings, why tests use virtual clocks, a CI-only metaharness failure (PR 144, run 40766941531). (seen)
- The rest is in AEP stories and review results. Nothing checks that those numbers are still true. (inferred)

D3:
- CI's test step with 96 skipped tests: green says nothing about delegated confinement on CI. (seen: run 45240437881)
- `AGENTS.md:475` says "There is no `rust-toolchain.toml`: CI builds on `stable`", but every workflow pins 1.99.1 (`check.yml:37`, `release.yml:31`). The rule text has drifted from the workflows, and there is no `rust-toolchain.toml` (seen: `ls`).
- `check.yml:3-7` has no path filter, so planning-only PRs run the full gate, against the folder rule (seen).

D4: n/a

## E. Quality in plain words
E1:
- The model can do only what the case's current state allows, and every effect is checked again just before it runs.
- When something fails, Loom does less, not more, and says what it doesn't know.
- What the specification says and what the code does stay the same, and generated files are never edited by hand.
- A consumer reading the changelog knows exactly what broke.
- The tests are fast enough to run on every change.

E2:
- Machine-checked today: specification against code (conformance, drift), changelog breaks (`release-check`), test speed (test step budget).
- Checkable with work: authority rechecked before every effect, and fail-toward-less-authority. Partly covered by named tests in "Checks that hold the rules"; full coverage would need a mutation or adversarial lane in CI.
- Never fully: "says what it doesn't know" stays a review judgement. (inferred)

E3:
- End users / operators: an agent did something its mandate did not allow, or a credential showed up in a transcript or log.
- Developers / SDK consumers: a path on the SDK stability page broke without a `**Breaking:**` bullet.
- Coding agents: the gate is green locally and red on CI, or it gets slower (over 120 s for the step, or minutes of build).
- API consumers (A2A): a stream or turn that hangs past its documented bounds.
- All inferred.

E4: The count of tests skipped for a missing prerequisite in CI's test step (96 in run 45240437881) must not exceed the value recorded on `main`; checked by `loom-xtask test-step` on every PR.

Not fully answered: C2 (how many of the 3 failures were false reds), C3 (whether a threshold was raised and later tightened), B3 (lead time from commit to release, merge-queue wait).
