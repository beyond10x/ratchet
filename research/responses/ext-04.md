# Response: ext-04

- kind and stack: language toolchain (compiler with two native backends, evaluator, std library), Rust
- answered by: wave coordinator session
- date: 2026-11-23

## A. The project
A1: compiler + CLI + standard library; Rust; 5,484 tracked files, ~236k lines of Rust, 673 source files in the language itself (seen, git ls-files). Users: developers writing programs in the language, coding agents that build it.
A2: compiles one source language to native executables through two backends (LLVM, generated Rust) plus an evaluator, and plans/applies small services written in it.
A3: agent sessions coordinated in waves, with one person approving; 9 commits on main in the week before (seen, git log); a wave is 4-10 units, ~1 wave per day when running.

## B. What you track today
B1: (seen) fmt, clippy -D warnings, ~4,800 tests (workspace + 904 in one integration binary), a differential runner over 989 corpus units (evaluator vs both backends must agree), diagnostic fixtures (339), generated docs/pages in sync. All in a local gate; there is no CI on main. Blocks the merge.
B2: (seen) gate time is not tracked as a metric; it is ~2.5 h on a loaded shared machine and above the build pool's 30-min job cap, so it runs in 8 shards. Flaky tests not counted.
B3: (seen) release rule: one after every third wave, or a patch release; 5 releases 2026-11-12 to 11-14 (git tags). No lead-time or failed-release metric.
B4: (seen) 42 quality rows in one file: 14 gates, 27 ratchets, 1 hill-climb: diagnostics, backend agreement, allocations per request (valgrind memcheck), instructions and syscalls of frozen scenarios (callgrind, strace), binary size, timing rows on a dedicated cloud host per release, website layout/a11y/screen-only-user ratchet (Playwright). No production telemetry.
B5: (seen) gates: fixed 0 (e.g. backend disagreements 0, accepted programs failing in a backend 0); path cost: a band of 0.1 % floor up to 10 % of the recorded value, measured again up to 3 times before refusing; UX: per-metric tolerance (Count(0), Percent(5)). Crossing refuses the merge.
B6: (seen) ratchets compare against a JSON baseline in the repo, blessed with an env var by a test; path cost against count files recorded at the last release tag (5 runs); timing rows against the last release tag on a dedicated host, interleaved.
B7: (seen) yes: a JSONL history per run and a generated trend page in the repo; per-release row in release notes.

## C. What went wrong
C1: (seen, today) a change in the Rust generator added 0.24 % instructions to one frozen build scenario; the path-cost check caught it at the integration gate, ~3 h after the unit was written; it went back to the unit and came in at 0.09 %. Nothing reached a release.
C2: (seen, today) under load 35-90 on 20 CPUs: socket reads with EAGAIN in a 65,537-request test (4 runs), process-timeout tests, a scheduler syscall count, a website layout check (1 of 389) — each passed on rerun. One test fails because another session installed an extra cross target on the shared machine.
C3: (seen) no; the rule is that a loosened bar needs a named decision, and an ignored test counts against a bar (ignored tests may not rise), so red adversary cases are removed and cited in a draft story instead of ignored.

## D. Friction
D1: (seen) gate length vs the 30-min job cap: ~2 h of gate runs stopped and rerun today; valgrind unusable on the host after a distro update (debug info no longer served): 1 h 45 min of retries, then a container route that costs ~7 min per check.
D2: (seen) the counts depend on glibc, compiler versions and CPU, so a distro update can refuse a merge that changed no code; this lives in the agent instructions file, not in a check.
D3: (inferred) timing-sensitive tests on the shared machine; their red does not distinguish a regression from load.
D4: n/a

## E. Quality in plain words
E1: Every program the checker accepts runs and gives the same answer on both backends and the evaluator. A wrong program gets one diagnostic at the right place. Each release is no slower and allocates no more than the last on the paths users run. The docs and website stay usable.
E2: sentences 1-3: checked today; 4: checked partly (layout, a11y, a scripted user).
E3: developers: a program that checks and then fails to build; agents: a gate that is red for a reason unrelated to their change; end users of built services: more allocations or syscalls per request.
E4: instructions and syscalls of each frozen scenario, under a recorded toolchain and loader, ≤ last release + band, checked on every merge, with the toolchain pinned so the baseline survives a machine update.
