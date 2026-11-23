# Response: swell

- kind and stack: library, an ECMAScript engine written from scratch in Rust (no third-party crate, no unsafe code, no JIT)
- answered by: the coordinating session of the repository (plans stories, verifies and merges the work of implementor sub-agents; writes no code itself)
- date: 2026-11-23

## A. The project
A1: Library. Rust, 8 crates plus one conformance workspace. 1,931 tracked files, 287 Rust files under `crates/` with 160,874 lines (seen: `git ls-files`, `wc -l`). Used by an embedder (a browser built from scratch) and by coding agents that build it.
A2: It parses, compiles to bytecode and interprets JavaScript for a program that embeds it and does not trust the script. Every run has a step budget, a memory budget and depth limits.
A3: Agent sessions only: one coordinator, one implementor sub-agent per story in its own worktree, plan critics, one session for the forge side. First commit 2026-11-21; 476 commits and 183 merges on the working branch in 3 days; 7 releases, the eighth in its gate (seen: `git log`, `git tag`).

## B. What you track today
B1 (all seen in the gate log of 2026-11-23, local gate `task check`, same task in CI job `check.yml`; each blocks):
- tests: `17 test binaries: 1215 passed, 0 failed, 1 ignored`; the engine crate again with a collection at every safe point (934 tests); one injected-fault test; doc tests incl. `compile_fail`.
- clippy with `-D warnings`, `cargo fmt --check`, build refuses a compiler warning.
- `forbid-unsafe-check: 9 crate root(s)`, `Cargo.lock: 8 package(s), none from outside this repository`, `python-check: no Python file among 1931 file(s)`, toolchain pin check.
- generated files in sync: Unicode tables (15), `tests/main.rs` per crate, site status JSON, test262 expected file by digest of its sources.
- `gate-selftest: 65 passed`: 65 planted defects that the gate must refuse.
- test binaries: count and "none with a .debug_ section".
- No coverage number, no complexity number, no dependency age (there are no dependencies). Mutation testing: I do not know.
B2: `gate-time <step> <seconds>` per test step and the ten slowest tests per step, printed by the gate; sum `gate-time test-steps 94.3 of 120` blocks over 120 s; a test is killed at 60 s (`.config/nextest.toml:2`). Per-test CPU bounds (1.5 s default, 2 s collect mode) are a rule for implementors, checked by hand. Queue wait in the shared build pool is printed per job (`waited 1490s ... ran 317s`), not recorded. Build time: not tracked.
B3: CI duration, merge wait, lead time: nothing recorded by this repository (the forge side belongs to another session). Release list with dates in `AGENTS.md` and `CHANGELOG.md`. A lane `slow` (full test262 run from sources, long tests, stack profiles) runs before a release and in `slow.yml`.
B4:
- test262 conformance: counts per directory, per delivery slice and per section, 287 lines in a committed file, compared on every gate run (`test262 total 53801 8982 7 44812 20229 24581 2`). Blocks on any difference, better or worse.
- host interface: 208 numbered requirements, each tied to a test or marked pending for a named slice (`114 test, 94 pending`); blocks on a missing line, a missing test, a pending line of a delivered slice.
- ESS model of the host interface: 58 scenarios, 58 pass on the model's interpreter, 14 on the engine, 44 unsupported with a ceiling.
- host surface snapshot: every public item of the host interface in a committed scan; a change must be named in the changelog's Unreleased section or the gate fails.
- bounds as tests: step budget, memory budget, stack bound per nesting kind (bytes per level under a constant), re-entry depth.
- performance: one measured loop per story that asks for it (e.g. 2.313 → 0.830 CPU s), written in the commit; no standing benchmark, no threshold.
B5:
- test steps ≤ 120 s wall (`Taskfile.yml`, `GATE_TIME_BUDGET`): gate exits non-zero.
- a test ≤ 60 s (`.config/nextest.toml`): killed, counts as failed.
- `SPEC_REFUSALS_MAX=41`, `ESS_UNSUPPORTED_MAX=44` (gate variables): gate fails above.
- `STACK_BYTES_PER_LEVEL` 224 (parser): a test fails for a nesting kind over it.
- pool job ≤ 10 min, ≤ 30 with a named time (host rule): job killed.
B6:
- test262: committed `expected.txt` + digest of its sources; updated by a full run (`task test262-expected`, about 600 s) by the coordinator on each join; a comparison of run lines ("no run that passed fails") is done by hand with awk against the last full run, kept in scratch, not in the repository.
- host surface: `conformance/host/surface.txt`, rewritten at each release.
- step totals of some operations are recorded in tests ("must not move").
B7: Only as text: the gate's numbers block in `AGENTS.md` (replaced each release), numbers per release in `CHANGELOG.md`, a table per wave record under `docs/plan/`. `website/data/status.json` holds the current counts, no history. No trend, no dashboard.

## C. What went wrong
C1: The full test262 run grew to 1,599 s and no longer fit one pool job (10 min limit). Noticed when the run was killed, not by a check; the cause was the cost of an Array index store (inferred: there since the Array was written). Fixed in a story (598 s after). A recorded duration per run with a comparison would have shown it earlier. (seen: changelog of 0.8.0)
C2: The 120 s test-step budget under machine load: release 0.7.0's gate passed every check and exited 201 on `gate-time test-steps 194.7 of 120` at load 65 on 16 cores; the same steps took 94.3 s at load 34. It measures wall time on a shared machine. (seen)
C3: Counts inside two tests were lowered under the collect-at-every-safe-point mode to keep each test under 2 CPU seconds (seen in a unit report; not raised again). The 0.7.0 release went out on the 201 exit above "by the standing rule the forge's run judges the budget". inferred: nobody lists such loosenings in one place.

## D. Friction
D1: (1) The full test262 run on every join: about 10 min of one pool job plus queue wait (30 min today for one job). (2) Queue wait for the gate: 1,490 s waited for 317 s of run (seen today).
D2: Which runs passed before and must still pass (kept as run files in a scratch directory); per-test CPU cost by mode; findings "left open" per wave (prose in wave records); which numbers in a story are stale against the base. Lives in wave records, `AGENTS.md` and the coordinator's notes.
D3: The wall-time budget (C2): its verdict depends on the load of the machine. And the pass count alone: it does not say which cases; a new pass beside a pass turned fail would keep the total.
D4: n/a.

## E. Quality in plain words
E1: A script can never hang, crash or exhaust the program that runs it. What the standard says is what happens, and a part counts as done only when every case of the standard's suite for it passes. A case that passed keeps passing. The host interface does what its numbered requirements say, and a change to it is announced before it ships. The checks answer in two minutes so that nobody is tempted to skip them.
E2: Today: conformance counts, requirement-to-test ties, surface changes named, budgets ending a run (as tests), check time. With work: "a case that passed keeps passing" per run line in the gate; cost per operation over time. Never fully: "can never hang or crash" for every input (fuzzing and bounds approximate it).
E3: Embedder: a public item changes without notice, or a run ends without an outcome it can read. Script author: a case that ran yesterday fails today. Coding agents: the gate takes longer or its verdict depends on load. Operator: a release whose numbers cannot be traced to a run.
E4: Per test262 run line: no run that passed in the last accepted full run fails; compared against the stored run file of the base on every merge to the working branch.
