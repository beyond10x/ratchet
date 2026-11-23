# Response: llm

- kind and stack: Rust library workspace with one CLI and a Docusaurus docs site
- answered by: the session that shipped llm 0.25.0 and 0.26.0 (wave lead, release, docs UX round)
- date: 2026-11-23

## A. The project
A1:
- Library workspace plus the `llm` command and a docs site. Rust; TypeScript for the site and its UX checks. **seen**
- 20 crates, 374 `.rs` files, 133,222 Rust lines, 3,047 files on `main` 56bc1f39. **seen** (`git ls-tree`, `git grep -c`)
- Used by developers, by other services that pin a release tag (llm-gateway, inference), and by coding agents. **seen** (AGENTS.md § Release)
A2: Neutral types for one model turn, codecs for four wire protocols (Responses, Messages, Chat Completions, Bedrock Converse), routing, credentials, usage and cost. For services that call or relay model providers.
A3:
- Commits are made by agent sessions through one bot identity: 48 commits in 7 days, 48 by the bot; 12 first-parent changes on `main`. **seen** (`git log --since`)
- 3 releases in 14 days (0.24.0, 0.25.0, 0.26.0). **seen** (tags)
- People steer through an operator session and through review findings. **inferred**

## B. What you track today
B1: all block a merge unless noted. **seen** (`gate.yml`, `Taskfile.yml`)
- Format; clippy with warnings denied on all targets and features, plus two crates without default features.
- Tests under cargo-nextest: 2,072 locally, 1,799 in the main CI run.
- A check that every hand-written test runner answers the runner's list call (added today after a miss).
- Generated docs pages equal regeneration; docs site builds.
- Specification validates; planning store validates.
- Shared security-and-privacy scan (`shared-gates.yml`, a pinned commit of the gates repository).
- Native builds on macOS and Windows for two crates.
- Nothing: coverage, dependency audit or age, complexity. A search for llvm-cov, tarpaulin, cargo-audit, cargo-deny finds no gate using them.
B2:
- Test phase time: limit 120 s, each test killed at 60 s, ten slowest printed (`.config/nextest.toml`). Measured 16.0 s locally, 18.97 s in CI. **seen**
- Nothing: clean or incremental build time, whole-gate time, flaky-test count, wait for a verdict.
B3: Nothing recorded. Observed today: required CI job 16 min 34 s; merge of the wave to published release 32 min. **seen**
B4:
- Conformance: 1,049 scenarios synthesized from the specification, run three times, 1,049 pass; blocks. **seen**
- Capability table generated from code: 80 shipped, 3 planned (`website/data/status.json`). **seen**
- Docs site UX gate on pull requests touching the site: axe-core, always-visible elements, a deterministic screen-only user, 2 viewports x 2 themes; blocks. **seen**
- Nothing: performance, production errors, SLOs. It is a library with no deployment. Evidence is fixtures only; no live provider call.
B5:
- 60 s per test, 120 s per test phase: `.config/nextest.toml`; the run fails.
- 0 clippy warnings: `gate.yml`; the job fails.
- 0 serious or critical axe violations, 0 always-visible misses: `ux/baseline.json`; the UX job fails.
- 1,049 of 1,049 conformance scenarios: any failure fails the job.
B6:
- `ux/baseline.json`: 263 lower-is-better values with a tolerance each. The ratchet fails on a worse value, an improvement not written back, a missing value, and compares with `main`'s file. Updated by one command, with a decision id when a value gets worse. **seen**
- Generated pages and the specification projection: compared with a fresh generation. **seen**
B7:
- `ux/rounds/trend.md`: one row per UX round (1 row so far). **seen**
- CHANGELOG, a status document, and one evidence record per delivered story in the planning store. **seen**
- Nothing for test time, CI duration or findings count over time.

## C. What went wrong
C1:
- Release 0.24.0 shipped with defects an outside review found afterwards (16 findings): the command printed nothing when the answer text arrived only in the final object; the same cost was printed whatever model the provider reported. Fixed in 0.25.0. A conformance scenario for a final-only message and a test tying cost to the reported model would have caught them. Time between change and discovery: I don't know. **seen** (findings file, CHANGELOG 0.25.0)
- A docs page said for about a month (last edit 2026-10-22) that the command line does not exist, while the command and its guide existed. Found by a docs pass today. No check compares hand-written status prose with the generated capability table. **seen**
C2:
- Local conformance reports "schema drift" whenever a newer specification tool than the pinned one is first on PATH; every run in that state. **seen**
- The docs publish workflow failed once in 2 releases because the build run for the commit had not finished; a rerun passed. **seen**
- One test took 6.8 s in one run and 16.4 s in another on a loaded shared host. **seen**
C3:
- Two UX gate units are waived (the search page autofocuses its box); not tightened yet, added the same day. **seen**
- A unit's "tests pass" evidence covered 3 of 20 crates, so three test targets the new runner could not list reached integration. Tightened: the gate now checks every such target. **seen**

## D. Friction
D1:
- Waiting in the shared build pool on a loaded host: clippy 1,832 s wall for 268 s of work; the test command 1,576 s wall for 16.0 s of tests; conformance 2,432 s wall for 654 s of work. **seen**
- CI: 16 to 17 min per pull request, plus a macOS runner queue of 10 min or more. **seen**
D2:
- Which behaviours are proven only on recorded fixtures and never against a live provider: prose on the status page.
- Review findings: a file outside the repository; only the fixed ones leave a trace (a test, a CHANGELOG line).
- Which tool versions the gate needs: prose in AGENTS.md and pins in the workflow.
D3:
- "Tests pass" in a unit's evidence, when the command ran a subset of crates.
- Local conformance, when the tool on PATH is not the pinned one.
D4: n/a

## E. Quality in plain words
E1:
- A turn that enters in one protocol and leaves in another loses nothing and invents nothing: each message, tool call and usage counter arrives once.
- A number shown to an operator is what the provider reported, or it says "unknown".
- A release never breaks a consumer without saying so in the changelog.
- The docs say only what the code does.
- A change gets its verdict in minutes, and the local verdict equals CI's.
E2:
- 1: today for the scenarios that exist; more scenarios with work.
- 2: today on fixtures; against live providers with work.
- 3: with work (compare the public API with the last tag).
- 4: today for generated pages; with work for claims in prose that name a command or capability; never for explanation quality.
- 5: today for the test phase; with work for the whole gate and for local-equals-CI.
E3:
- CLI users: text missing from the output, or a cost under the wrong model.
- Developers: a public type changed without a Breaking line.
- Coding agents: a gate over 10 minutes, or green locally and red in CI.
- Consumers of the API (relays): a usage record without the model or a counter.
- Docs readers: a page that names a command that does not exist, or denies one that does.
E4: The public API of every crate, compared with the last release tag: a removed or changed item fails the pull request unless the unreleased changelog section has a Breaking line; checked on every pull request.
