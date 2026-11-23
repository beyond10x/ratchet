# Response: canon

- kind and stack: library + CLI, Rust workspace, docs site (Docusaurus)
- answered by: the coordinator session of Canon's AEP waves
- date: 2026-11-23

## A. The project
A1: Rust library and CLI (`canon`): crates `b10x-canon`, `canon-cli`, `canon-docs`, `canon-expr`; 1308 tracked files, about 105k lines of Rust (seen: `git ls-files`, `wc -l`). Plus an ESS specification under `ess/` and a docs site under `website/`. Users: coding agents and developers writing protocol files; one downstream repository consumes its output (seen).
A2: Canon reads `protocol/1` files (claims, evidence kinds, actions, outcomes), compiles them to a canonical IR, and checks, simulates, evaluates and generates conformance scenarios for them, so a process can be proven before a runner executes it.
A3: Agent sessions only, steered by one operator (seen). 507 commits on `main` in the last 7 days (seen: `git log --since=2026-11-16 | wc -l`); 8 releases since 2026-10-29, 5 of them 2026-11-21 to 11-23 (seen: tags).

## B. What you track today
B1: Local gate `task check` = build, `task ess-gate` (ESS spec equals the Rust model and CLI, blocking), `cargo fmt --check`, clippy `-D warnings`, `task test` (cargo-nextest), `conform run` against `conformance/requirements.yaml` (requirements implemented vs covered), `task docs-check` (18 generated files byte-equal to sources). CI `check.yml` runs `task check`; `shared-gates.yml` runs a security and privacy scan; `b10x-docs-site.yml` builds the site. All block merge (seen: workflow names, PR check names). No coverage %, no dependency age, no complexity (seen: none in Taskfile).
B2: The test step times itself: a test is killed at 60 s (`.config/nextest.toml:3`, `slow-timeout ... terminate-after = 1`), the step fails over 120 s (`Taskfile.yml:46-48`) and prints the ten slowest tests. Build pool jobs end at 10 min unless they name up to 30 min (host rule). Wall time of a gate step on the shared host is not tracked; today's local gate steps took 1636 s (ess-gate) and 1938 s (clippy) of wall time on a loaded host (seen: gate log), most of it inferred as pool queue and load.
B3: Nothing measured as a metric. CI result is watched by `scripts/ci-watch` (exits non-zero on red). Release frequency is visible only from tags (seen). No lead-time or rollback tracking.
B4: Functional: conformance requirements with scenarios (`conform run`: 31 passed, 32 of 32 requirements covered on the wave branch, seen); about 210 fixtures whose outputs are compared byte-for-byte against the previous build at every unit and review (seen; done by the agents, not by a committed check). Performance: state-space bounds in the product (65536 states, `count` above 64 refused); consumer protocol timings measured by hand in unit reports. No production (it is a CLI).
B5: 60 s per test (nextest, killed = failed); 120 s test step (Taskfile, fails the step); 10 min per build job (host pool, killed); state bound 65536 (product refusal). Each blocks.
B6: Byte identity against the previous build or `main` for every fixture (scratch scripts per unit, not committed: inferred as a gap); generated docs against their sources (`docs-check`, committed); a slow lane (`task test-slow`) regenerates scenario files and compares bytes with the committed ones.
B7: Nothing recorded over time. The ten slowest tests are printed per run and not kept (seen). Wave reports in `docs/plan/` carry numbers as prose.

## C. What went wrong
C1: 2026-11-23 wave review (before release): `canon simulate` counted three records for two children, so a `count: 3` claim was true while a child was unopened. Found by the adversary review of the integrated branch about 2 hours after the merge; it did not reach a release. A property test "simulated child count never exceeds children opened" would have caught it (seen: review finding W14-1).
C2: 47 ESS tests fail when `ess` 0.98.0 is first on PATH outside `task ess-gate`, which pins 0.97.4 (seen in a review run); environment-dependent, every run outside the task.
C3: A fixture that takes 19 s in a debug build was moved to the `SLOW_ONLY` list so the gate-lane test stays under 60 s (seen, 2026-11-23); not moved back. Earlier: none I know of.

## D. Friction
D1: Shared-host pool and load: today a gate's ess-gate step took 1636 s and clippy 1938 s of wall time for work that takes minutes alone (seen: gate log). Disk-full rounds: 4 requests today to free build output.
D2: Byte identity of every fixture against the previous build, the consumer's protocol timings, and "an absent optional key writes nothing" all live in agent brief rules (`common.md` in scratch) and review habit, not in a committed check.
D3: `docs-check` passing does not prove the schema matches validation (the published schema admitted `count: 0` that validation refuses; caught by review, not by a check).
D4: n/a.

## E. Quality in plain words
E1: A protocol file means one thing: every command gives the same bytes for the same input, on every machine. A new optional key changes nothing for files that do not use it. What `canon check` proves holds at runtime, and when it cannot prove something it says so rather than passing. The docs, the schema and the code say the same thing. The tests run in two minutes.
E2: Machine-checkable today: same bytes per input (fixture byte identity, needs committing), docs and code agree (docs-check covers generated pages, not schema-vs-validation), tests in two minutes (enforced). With work: "check's proof holds at runtime" (differential test of check vs simulate vs evaluate on generated protocols). Never fully: "it says so rather than passing" for every limit.
E3: Developers: a protocol that checked clean yesterday now has a finding with no change of theirs. Coding agents: a refusal message that does not name the key or line to change. Consumers of the IR: canonical bytes change for an unchanged protocol. Operators: the gate step over 2 minutes.
E4: Every fixture's output of check, simulate, compile, generate, evaluate and check-set compared by bytes with the committed baseline file, on every pull request; any difference fails unless the same commit updates the baseline.
