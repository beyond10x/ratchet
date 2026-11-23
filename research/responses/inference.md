# Response: inference

- kind and stack: Rust library workspace with provider adapters and a Docusaurus docs site
- answered by: the session that shipped inference 0.32.0 and 0.33.0
- date: 2026-11-23

Only what differs from the llm response (`llm.md`).

## A. The project
A1: 26 crates, 829 `.rs` files, 322,277 Rust lines, 2,111 files on `main` 745fe77b. Library only, no CLI for users. **seen**
A2: Composes speech-to-text, model turns and text-to-speech into streaming sessions (pipelines, duplex sessions, built-in recipes), with usage accounting. For developers of voice agents.
A3: 34 commits in 7 days, all by the bot; 7 first-parent changes; 7 releases in 14 days. **seen**

## B. What you track today
B1: as llm, plus: docs built with warnings denied; a stack-size test without default features; doc tests; compile-fail snapshots in a slow lane that runs only when its sources change; each adapter's published claims held equal to its code by a test; a native library archive pinned by SHA-256. 3,215 tests. **seen**
B2: each test killed at 60 s, ten slowest printed. The 120 s limit for the step is a workspace rule and is not enforced here: the CI test step took 154 s and 137 s today. A story is drafted. **seen**
B3: job timeout 45 min (`check.yml`). Observed: 8 min 44 s to 30 min per run, queue included. Nothing recorded. **seen**
B4: a conformance target synthesizes the suite from the specification and runs it in process. Docs UX gate as llm. No performance check, though the product is real-time audio. **seen**
B5: 60 s per test; 45 min per job; 0 warnings (lint, docs); 0 serious axe violations. The 120 s step limit has no enforcement.
B6: `ux/baseline.json` with 80 values; compile-fail snapshots (compiler messages, valid for one pinned compiler version); adapter claim records; generated pages. **seen**
B7: `ux/rounds/trend.md` (2 rows); a CHANGELOG index of every release with a Breaking section. **seen**

## C. What went wrong
C1: Release 0.31.0 shipped with defects an outside review found afterwards (17 findings): a completed chat lost its only usage record; a graph with two outputs counted one request twice; the second message of a two-message reply was lost before speech. Fixed in 0.32.0 and 0.33.0. A scenario asserting one usage event per model call per recipe would have caught the first two. **seen**
C2:
- 9 timing tests (a ticker gap, a 28 s deadline, a stall, a paced replay) fail and 11 suite-synthesis tests pass 60 s on the shared host at load 120 to 139; all pass in CI. 4 of them fail on the previous `main` too. **seen**
- Compile-fail snapshots failed locally on compiler 1.99.1 while CI had 1.100, until one version was pinned for both. **seen**
C3:
- The 120 s step limit was left unenforced until CI had measured the step; the step is now known to be over (137 s, 154 s) and the limit is still not enforced. **seen**
- A load test was made smaller to fit the 60 s per-test bound. Not restored. **seen**

## D. Friction
D1: The local gate on the shared host: clippy 863 s, test build 525 s, test run 448 s against a 120 s budget; one integration took about 2.4 hours, most of it waiting. **seen**
D2: Latency and audio timing behaviour: no check records them; they live in a design document and in timing tests that depend on host load.
D3: The timing tests when run locally: red under load, green in CI.

## E. Quality in plain words
E1:
- Every model call a session makes is counted once, whatever the shape of the pipeline.
- Speech and text reach the listener complete and in order; an interruption cuts only what it should.
- A session under pressure (a full queue, a lost frame) fails in a way the caller can retry, and never hangs.
- A release never breaks a consumer without saying so.
- A change gets its verdict in minutes.
E2: 1 and 2: today for the cases that have a scenario. 3: with work (fault injection per ingress). 4: with work. 5: with work; the test step is over its budget now.
E3:
- Developers: a usage total that does not match the provider's bill.
- End listeners (through a consumer): a reply cut short, or audio that stutters.
- Coding agents: a local test run that is red for load reasons.
- Consumers of the API: a moved type without a Breaking line.
E4: Seconds of the CI test step, limit 120: the pull request fails when the step is over; checked on every pull request.
