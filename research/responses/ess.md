# Response: ess

- kind and stack: Rust workspace, a CLI and libraries; generates Rust, Go, TypeScript and OpenAPI output; docs site (Docusaurus)
- answered by: one research sub-agent of a coordinating session, read-only (no build, no test run); "seen in session" marks figures from the coordinating session of 2026-11-23
- date: 2026-11-23

## A. The project
A1:
- CLI `ess` plus libraries, one Cargo workspace of 34 crates in 6 areas (`ls -d crates/*/*`, seen); docs site in `website/`, fuzz workspace in `fuzz/`.
- 2,871 `.rs` files, 1,334,902 lines (`git ls-files '*.rs'`, seen); 15,404 `#[test]` attributes, 161 `#[ignore]` (`git grep -c`, seen).
- Users: developers and coding agents writing specifications; downstream repositories consume released `ess/N` formats and generated artifacts (`AGENTS.md` "Agent plugin", seen).
A2:
- Executable System Specifications: system structure, semantics, projections, conformance requirements and infrastructure intent as deterministic typed data (`AGENTS.md` "Serves", seen).
- It validates, compiles, projects (schema, OpenAPI, Rust/Go/web servers), synthesizes conformance suites and mutates them, for people and agents who specify systems.
A3:
- Agent sessions; every commit of the last 7 days is by the bot identity (`git log --since=7.days --format=%an`, seen). Humans direct, I don't know how many commit by hand.
- 4,108 commits total; 279 in 7 days; 1,132 in 30 days; 303 merge commits in 30 days (`git log`, seen). Only 46 subjects in 30 days carry a `(#N)` pull request number (seen), so I don't know the merged-PR count.
- 121 tags; per month by tag date: 62 (Sep), 33 (Oct), 26 (Nov up to the 23rd) (`git tag`, seen).

## B. What you track today
B1:
- Local gate and CI, all blocking: `task check` = fmt-check, clippy, test, test-slow, doc-check, example-check, projection-check, support-check, fuzz-check, release-check, action-check (`Taskfile.yml:709-729`, seen). `consumer-check` is parked behind `CONSUMER_CHECKS=true` (`Taskfile.yml:721-726`, seen).
- Lint: clippy `all` + `pedantic` warn, `missing_docs` warn, `unsafe_code` forbid (`Cargo.toml:112-122`, seen), run with `-D warnings`.
- Generated files in sync: `projection-check` (schema, `site-data --check`), committed example trees under `generated/` compared byte for byte, `fuzz/Cargo.lock` via `fuzz-check` (`AGENTS.md`, seen).
- Docs: `task site-build` (network, not in the offline gate); `cargo xtask docs` counts a `Language:` line per changelog section (`crates/edge/ess-xtask/src/docs.rs:731`, seen).
- MSRV: CI job `msrv` runs `cargo check --workspace --all-targets --locked` on `rust-version = "1.85"` (`Cargo.toml:57`, `ci.yml:862`, seen).
- Nothing found for coverage, `cargo-deny`/audit, complexity or dependency age: no match in `Taskfile.yml` or `ci.yml`, no `deny.toml` (seen; the absence is inferred for other files).
B2:
- Test step per shard: nextest profile `ci` reports a test over 60 s but does not kill it (`.config/nextest.toml:19-20`, no `terminate-after`, seen); profile `slow` kills after 120 s x 10 (`:26-27`, seen).
- Each nextest task prints its ten slowest tests from JUnit (`crates/edge/ess-xtask/tests/test_budget.rs:230`, seen).
- Slow lane: tests marked `#[ignore = "slow lane: <reason>"]` run only in `task test-slow`; `cargo xtask slow-list` names them; `slow_lane.rs` pins the list (seen).
- Seen in session: 74 tests ran over 60 s on the forge in one run (21 in one binary, 19 in another); `task test-xtask` took 165.5 s at load 28 against the 120 s budget; the longest shard of one run took 48.3 min.
- Build time, clean or incremental: not measured by any check (I don't know of one). Flaky tests: no tracking found (inferred).
B3:
- One pull-request run is 29 jobs: `diff`, `checks`, `build-tests`, `build-feature-off`, 20 `test` shards, `slow`, `transport-network`, `msrv`, 2 macOS witnesses, `gate` (`ci.yml:63-965`, seen; counted in session).
- Plan-only pull requests skip all test jobs (`ci.yml:63-140`, `ci_lanes.rs`, seen). `Gate` carries the joint result.
- `release.yml` reuses a prior green gate on the same tree or runs the full gate; `release-record.yml` and `task release-status` check every tag has a release (`AGENTS.md`, seen).
- Seen in session: slow lane took 19.9 of its 30 min; build slots on the shared dev host waited 20-30 min on a busy day.
- Release frequency: 121 tags, 26 in November to the 23rd (seen). Lead time and failed releases: I don't know; `0.97.2` was tagged and never released (`CHANGELOG.md`, seen).
B4:
- Functional: conformance suites synthesized and run (`ess-conformance`), mutation (`ess verify conform mutate`), command smoke tests (`ci-smoke`), byte-pin tests such as `synthesis_suite_bytes_table` (`AGENTS.md`, seen).
- Tests that compile and run generated Rust and Go servers; Firefox browser tests (`task test-browser-product`, in no CI lane, `AGENTS.md`, seen).
- Performance: only ad hoc. `cargo xtask synth-jobs` measures one synthesis at 1, 2, 4 jobs and refuses differing suites (`Taskfile.yml:731`, seen); changelog entries quote instruction counts by hand (seen). No threshold gate.
- Accessibility, SLOs, production errors: n/a (a CLI and libraries).
B5:
- 60 s per test in the `ci` profile (`.config/nextest.toml:20`): reported, not killed (seen). The runner-kill is a story of the current wave (`.engineering/waves/wave-2026-11-23.md:47`, seen).
- Job timeouts: 30 min on most jobs, 285 min on `test`, 5 min on `gate` (`ci.yml`, seen). `msrv` = 1.85 (`Cargo.toml:57`). `infra-ir/1` rejects unknown fields.
- Changelog limits: release notes over 900 characters (1,200 with more than 3 breaking bullets) are refused (`release_notes.rs`, `AGENTS.md`, seen).
B6:
- Byte comparison against committed files: example trees under `generated/`, committed schema, `site-data`, and a sources digest stamp for the synthesis byte table (`CHANGELOG.md` Unreleased, seen). Updated by regenerating and committing.
- `consumer-check` has `initial-baseline.json`, parked (`AGENTS.md`, seen). No baseline for timing or size (inferred).
B7:
- Nothing recorded over time by a check (inferred; none found). Tags and `CHANGELOG.md` are the only history; timings sit in prose in changelog entries and wave pages (seen).

## C. What went wrong
C1:
- Seen in session: an adversary review of one wave (21 units, 101 files, about +9,968 -466 lines) found 12 defects after all unit tests and CI were green: 6 documents that said what the code did not do, 3 tools that listed or skipped a test wrongly, 1 fast-step test marked for the slow lane.
- Seen: 0.87.0's queue run found nine red byte-pin tests that a gate of named targets missed (`AGENTS.md`). The pinned byte tables now sit in a list of targets, kept by hand.
- Seen: 0.97.3 repeats 0.97.2 because 0.97.2's release gate failed on two tables that did not pin new fixtures (`CHANGELOG.md`).
C2:
- Seen: `observed_bindings::tests::an_output_created_after_preflight_is_preserved` fails whenever `TMPDIR` is inside a Git checkout (`AGENTS.md`). Environment-dependent; frequency: I don't know.
- Seen: a wall-clock-ratio test is serialized because neighbours skewed it (`.config/nextest.toml:15-17`, issue 85).
- Seen in session: the parallel-synthesis estimate of 3.5x did not hold (1 job 67.9 s, 2 jobs 36.5 s, 4 jobs 41.6 s).
C3:
- Seen: `test` job `timeout-minutes: 285` (`ci.yml:494`); commit `a5824dd17` gave each archive download 40 min. Not tightened (inferred: the value is still there).
- Seen: 161 `#[ignore]`; the slow-lane marker moved 9+ tests out of the fast step this wave rather than making them fast (`slow_lane.rs`, `CHANGELOG.md`). The 2-minute end state is not reached (`wave-2026-11-23.md:24`).
- Seen: 9 of 13 byte-pin targets stay in the test step (`wave-2026-11-23.md:139`).
- Seen: `consumer-check` parked since 2026-09-25 (`AGENTS.md`); not re-enabled.

## D. Friction
D1:
- Test step and gate time: 20 shards, longest 48.3 min, 74 tests over the 60 s bound in one run, `task test-xtask` 165.5 s for a 120 s budget (seen in session).
- Waiting for build slots on the shared host, 20-30 min on a busy day; full local gate builds about 45 GiB (`AGENTS.md`) and builds hold when free disk is under 40 GB (seen in session).
D2:
- Facts that live in `AGENTS.md` prose: which byte-pin targets a named-target gate must include, which tasks must be run after a `RawSpecFile` or version change, `TMPDIR` outside a checkout, `ESS_TYPES_NODE` and global `npm` tools for local runs (seen).
- Doc accuracy: no check compares a design page status line or a sentence like "the gate is offline" with the code (seen in session: 6 such defects).
- Review habit: an adversary pass per unit or per wave; not recorded as a metric.
D3:
- The fast-step/slow-lane split: a test can be marked wrongly and a tool can skip a test wrongly (seen in session, 1 and 3 cases).
- A gate of named test targets (it missed 9 byte pins in 0.87.0).
- Estimated speedups before measurement (the 3.5x estimate).
D4:
- n/a: a lot is tracked. What is missing is trend data and performance thresholds, for lack of a format that declares them (inferred).

## E. Quality in plain words
E1:
- The same specification gives the same bytes on every run and every machine; a generated artifact never drifts from its source.
- A format never changes meaning silently: a change that moves identity, names or canonical bytes gets a new format version and an old-reader test.
- What the documents say is what the code does; a refusal names the key and where to put it.
- The gate gives a verdict quickly and the same one locally and on the forge; no test runs longer than 60 s.
E2:
- Machine today: determinism and drift (byte pins, projection-check), format compatibility (`infra-ir/1` unknown fields), MSRV, lints, test time bounds in the report.
- With work: the kill at 60 s and the 2-minute step; the same-locally-as-forge rule (pin the toolchain, diff local and CI job lists); a performance ratchet on synthesis time.
- Hard or never: documents matching behaviour in every sentence (needs a review); a refusal message being useful.
E3:
- Users of the CLI: a spec that validated before is refused, or the output bytes change without a format bump.
- Developers: the gate takes longer or needs more disk and local passes while CI fails.
- Coding agents: a hint that does not say what to do, or a document that contradicts the code.
- Operators of CI: wait for a shard or build slot grows (48 min for the longest shard today).
- Consumers of generated artifacts: a regenerated tree differs without a changelog line.
E4:
- Wall time of the test step and of each test, compared with the budget (60 s per test, 120 s per step) and with `main`'s last green value; a test over its limit fails the pull request, checked on every pull request.
