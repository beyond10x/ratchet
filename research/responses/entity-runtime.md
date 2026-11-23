# Response: entity-runtime

- kind and stack: Rust library collection plus a CLI (deterministic entity kernel, storage providers, an MCP server), with a Docusaurus docs site
- answered by: coordinator session of the eventlog/entity-runtime review follow-up
- date: 2026-11-23

## A. The project
A1:
- Library collection plus one command (`entity`), Rust: 17 crates under `crates/`, 194 `.rs` files, ~124k lines on `origin/main` (seen: `git ls-tree`, line count). Docs site under `website/` (TypeScript/Docusaurus); 3 Python scripts under `scripts/` (seen).
- Users: other beyond10x repositories pin a release tag (connectors and others), coding agents, developers via the CLI and MCP (seen, AGENTS.md "Consumers"; inferred for agents).
A2:
- An IO-free, deterministic kernel runs entity types declared as data (state, lifecycle, legal moves, rules, events); provider crates keep recorded state on file, SQLite, PostgreSQL and Eventlog stores, for applications that need decisions as data with evidence (seen, AGENTS.md:17-34).
A3:
- Agent sessions only: all 126 commits on `main` 2026-11-16..23 by one bot account; 25 merges that week vs 33 commits in the 3 weeks before (seen, `git log`).
- 12 releases 2026-10-03..2026-11-23, 3 in the last 2 days (0.32.0, 0.33.0, 0.33.1) (seen).

## B. What you track today
B1:
- Local gate `task check` (Taskfile.yml:5-22), 14 steps: fmt, clippy `-D warnings` (`missing_docs` fatal, `unsafe_code = forbid`), `cargo test --workspace`, rustdoc `-D warnings`, docs-check (generated docs current, every status item names an existing test), example-check, req-check (every requirement cited by a live test), pin-check (fixture hashes), postgres-check, eventlog runtime check on Rust 1.91, notes-check, ci-paths-check, ESS conformance, provider ESS conformance (seen, AGENTS.md:185-200).
- CI `gate.yml`: same steps except pin-check and notes-check; jobs `Gate` (stable), `MSRV 1.85` (build only), `Eventlog runtime (Rust 1.91)`; conformance evidence uploaded as artifact (seen, gate.yml:63-103).
- Docs: `Build Docusaurus` (typecheck, vendored-guard, build, generated pages bound to source commit) (seen, pages.yml).
- Security: weekly `npm audit --audit-level=high` for the website (seen, audit.yml); shared `common / Security and privacy` required (seen). No Rust advisory scan (cargo audit/deny) in workflows (seen: none found).
- Not tracked: coverage, mutation testing, dependency count/age, complexity (seen).
- Blocking on `main`: `gate / Gate`, `gate / MSRV 1.85`, `Build Docusaurus`, `common / Security and privacy`, `planning validate` (seen in runs); AGENTS.md:294 lists only the first three (seen, stale).
- Defect against org rules: the gate runs Python (`scripts/check-requirements.py`, gate.yml:84) (seen).
B2:
- Nothing in the repo measures build, test or gate time; no step timer, no "ten slowest tests" (seen).
- Tests run with `cargo test` (gate.yml:70); no nextest config, so no test is killed at 60 s (seen); a story moving to nextest is in progress (seen).
- Two draft budget stories: entity-eventlog tests of 23.1/18.2/15.2/14.2 s (earlier one test 51.8 s, crate 166 s); forge provider-contracts step 156 s, test step 61 s; local under load test step 391 s, provider ESS 303 s (seen, `.engineering/planning/story/`).
- CI `timeout-minutes` 20-30 per job, none per step (seen, gate.yml:31,109,132).
- Under load 211 two entity-eventlog tests ran over 60 s; same binary 14 s next run (seen).
B3:
- Only job-level CI timeouts; nothing records CI duration, queue wait, lead time or release frequency (seen).
- Planning-only/prose PRs skip build, test and KPI jobs: path list `scripts/ci-paths.sh`, tested both sides by `scripts/ci-paths-test.sh` in `planning validate` (seen, PR #99).
- `release.yml`: tag, Cargo version and changelog agree; re-runs full gate; builds per target; runs `entity-store` tests; writes `SHA256SUMS` (seen, release.yml:34-138).
- Shared build pool queue waits 1.5-38 min per build step (seen); one PR rebuilt after a push hook refused a forge update-branch merge (seen).
B4:
- Functional: executable ESS conformance for library and SQLite provider contracts, gate and CI (seen, gate.yml:89-93,178-181); requirements register links every requirement to a test (seen, AGENTS.md:154); purity/determinism tests on the kernel (seen, AGENTS.md:84-99).
- Performance: `checks/kpi` (`er-kpi`, kpis.yaml): 55 deterministic counters (bytes read/written, opens, fsyncs, allocation bytes, history loads, PostgreSQL shared buffers); timing KPIs (latency per provider, throughput, CLI wall time) only via A/B on one machine (seen).
- Production errors, SLOs, incidents: n/a (library); no consumer telemetry I know of. Accessibility/visual: nothing (seen).
B5:
- Counter tolerance per counter in kpis.yaml (e.g. `tolerance: 0.005` + `slack: 256`; 0 where none); worse than baseline fails `KPI counters`, which is not a required check, so it does not block merge (seen, kpi.yml:37-117).
- Timing `max_ratio: 2.0` on 12 gated timings (kpis.yaml:280+); `er-kpi ab` exits non-zero above it (ab.rs:288); job has `continue-on-error: true` (kpi.yml:123), so never blocks (seen).
- Lint `-D warnings` + `missing_docs`: blocking. MSRV 1.85: blocking. npm audit high: weekly, not blocking (seen).
- No test-time threshold enforced here; the org rule (60 s/test, 120 s/step) is written, not enforced (seen).
B6:
- Counters vs `checks/kpi/baseline.json`, updated by a commit (`er-kpi record`), storing host, CPU, load, rustc; improvements reported as "improved (re-record to ratchet)", never written back automatically (seen, AGENTS.md:279-282).
- Timing vs the PR's merge base, built and run interleaved on the same runner, 3 rounds, best round per side compared (seen, kpi.yml:181, ab.rs:268-270).
- Generated CLI snapshot and docs compared with committed files (seen).
B7:
- Only git history of baseline.json (4 commits, all 2026-11-23); no dashboard or trend (seen). CI keeps conformance reports per run as artifacts, not as a trend (seen).

## C. What went wrong
C1:
- 0.33.0 slowed `execute` on Eventlog stores: commit 23cd3e50 made records name their definition by digest, then the definition was decoded again on every append and read, ~1/3 more CPU per batch (seen, CHANGELOG 0.33.1).
- Noticed by the downstream connectors repository after pinning 0.33.0; no entity-runtime check caught it (seen). 0.33.1 shipped the fix (7ad58845) ~4 h after the cause commit (seen).
- Still open: connectors measured 0.33.1 ~25 % more CPU per read invoke than 0.32.0 (171-177 vs 138-143 ms) -> a story (seen).
- Could have caught it: counters had no decode/CPU counter on that path; the cause commit itself re-recorded a worse counter (`blob_read_opens` 78->81, 603->606), which the ratchet allows (seen, `git show 23cd3e50`). Counter `eventlog.warm_batch.definition_decodes.b2` added after (eb89b6f9) fails with the fix disabled (6 vs 0) (seen). A timing A/B limit near 1.3x might have (inferred); 2.00x would not, and the job does not block (inferred).
- Caught before merge: an unmerged branch made PostgreSQL create 1.68x slower (7.37 -> 12.38 ms); the local A/B caught it, the CI 2.00x limit would have passed it (seen).
C2:
- Sibling repo eventlog: `KPI timing` failed once at 1.525x (limit 1.50) on a PR with no source change, base/head spread 94 %/61 %; green on re-run (seen). entity-runtime: an A/A run on a shared 20-CPU workstation at load 20-200 moved up to 1.94x, hence the 2.0 limit (seen, AGENTS.md:275-276).
- Local test times depend on host load (two tests over 60 s at load 211, 14 s next run) (seen).
- `KPI timing` on PR #101 (Eventlog 0.9.4 -> 0.10.0 bump) could not build its base side because the harness pinned the new Eventlog tag; fixed in a70fa659 (each side built on its own tag) (seen). How often overall: I don't know.
C3:
- Timing limit set to 2.0x to absorb shared-host noise (AGENTS.md:275), never tightened; misses a 1.68x regression (seen).
- `KPI timing` is continue-on-error and `KPI counters` not required: both can be red and the PR still merges (seen).
- The baseline was re-recorded worse in the same commit that caused C1 (seen, 23cd3e50).
- Baseline stale 02:45-15:34 with 27 counters "improved: re-record", so regressions up to each improvement would have passed; tightened by db4b8ed0; story `kpi-baseline-matches-main` still draft (seen).
- Test-budget defects turned into stories rather than fixed before the next feature (seen).

## D. Friction
D1:
- Shared build pool queue waits: 1.5-38 min per build step (seen).
- Long, load-dependent test steps: locally eventlog runtime tests 391 s, provider ESS 303 s under load; forge provider-contracts 156 s (seen).
D2:
- Downstream CPU per invoke matters and how much: only connectors measures it; no entity-runtime check does (seen).
- Local-vs-CI differences live in AGENTS.md prose, not enforced: no `rust-toolchain.toml` (CI uses current stable) (AGENTS.md:208); some feature-gated tests run in no gate (AGENTS.md:214-217); pin-check and notes-check run only locally (seen).
- The per-test time budget lives only in the org-wide AGENTS.md rule and two draft stories (seen).
D3:
- CI KPI timing: at 2.0x on shared runners it is too loose for a 25-70 % slowdown and still noisy enough to fail on no change (seen, C1/C2).
- Local timings on the shared workstation at load 50-200: load moves them more than code does (seen).
- Counter baseline: only as strict as its last re-record; a commit can re-record a worse value next to its own change (seen).
D4:
- n/a: tracking exists; gaps are CPU cost per operation, test time, and KPI jobs not blocking.

## E. Quality in plain words
E1 (inferred, condensed from AGENTS.md invariants and today's events):
- The kernel gives the same decision for the same inputs, byte for byte, and touches no clock, file, network or randomness.
- Every behaviour the docs and specification promise is held by a test or conformance scenario that runs, and the docs say only what the code holds.
- A store written by an older release still opens and verifies; nothing a consumer pinned breaks without a written migration.
- A release never makes a consumer's common operation (create, execute, read) cost more CPU, IO or memory than the release before, unless the changelog names that cost.
- The gate gives its verdict in a few minutes, and red always means something is wrong.
E2:
- Machine-checked today: determinism/purity (tests), spec behaviour (ESS conformance), docs vs code (docs-check), IO/alloc counters (er-kpi, not blocking) (seen).
- With work: CPU per operation (decode/serialisation counters per operation, or instruction counts on the runner, vs the previous tag); compatibility (a fixture store from each release opened by the new one); gate time (nextest 60 s kill + step timer) (inferred).
- "Never slower for a consumer": only partly, since the consumer's workload is not here; needs a replayed consumer workload (inferred). "Red always means wrong": approachable, not provable (inferred).
E3:
- API consumers (connectors and others): a release costs more CPU per invoke than the one before (seen: ~25 % today).
- Developers: a pinned tag no longer compiles or reads their store (inferred).
- Coding agents: the gate takes over 2 minutes or goes red without cause, so they re-run it (seen).
- Hosted PostgreSQL operators: an upgrade needs an undocumented migration or grant (inferred).
- End users: n/a.
E4:
- On every PR, deterministic work counters per operation (decodes, serialisations, bytes, opens, allocations) on the common execute and read paths must not rise against the merge base; the job is a required check, and the baseline cannot be re-recorded worse in the same PR without a named exception.
