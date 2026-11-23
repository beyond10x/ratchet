# Response: ext-02

- kind and stack: backend platform service (Rust workspace) with a separate end-to-end test repository (Go runner) and a findings repository (documents, Python checks)
- answered by: testing session of the platform (test setup, CI gates, end-to-end and conformance runs)
- date: 2026-11-23

## A. The project
A1: Backend service plus test repositories. Rust (about 50 test binaries, about 8,800 tests in the workspace; seen in a gate log), Go for the end-to-end runner, Python for findings checks. Used by end users through a console and voice or chat channels, by other services through an API, and by coding agents that develop it.
A2: It runs configurable conversational agents (text and voice) for business accounts. The test repositories judge a deployed build with scenarios and a specification-derived conformance suite.
A3: Both; agent sessions do most commits, a person decides and reviews. Seen today: 13 unit changes merged into one daily batch of the backend, 8 merged changes in the end-to-end repository. Weekly figure: I don't know.

## B. What you track today
B1 (seen): unit and integration tests, lint, format, dependency check, generated contract types in sync with the pinned specification, specification drift check, generated stats block in sync, a host-name check on added lines. All in a local gate script and in CI; all block the merge. A findings repository checks its records against a schema and a base branch. Coverage: I don't know of any measurement.
B2 (seen): test step seconds per pipeline, read from the CI job log by a session, not stored by a tool. The runner kills a test over 60 s and prints the ten slowest. Queue wait and run time per build job are printed by a shared build pool. Flaky tests: a per-run row in a hand-kept findings table. Clean and incremental build time: nothing.
B3 (seen): CI duration is read by hand from pipelines. A watch script exits non-zero on a red pipeline. Release is gated on one scheduled full end-to-end run per day. Lead time, release frequency, rollbacks: nothing recorded as a number (inferred from not finding one).
B4 (seen): end-to-end scenarios against a deployed build (smoke after each merge to the default branch, a full set daily); a conformance suite derived from the specification with counted failures and counted unsupported scenarios; recorded-and-replayed model traffic for part of the scenarios; usage-rollup latency read per run; spend per run and per day; an image digest check after deploy; UI checks on a docs site (layout, accessibility, keyboard actions per scenario). SLOs exist as documents; production error tracking: I don't know.
B5 (seen): test step at most 120 s and no test over 60 s (written in an instruction file and enforced by the runner's kill); conformance caps on counted failures and counted unsupported scenarios (written in the test repository; the job goes red above them); a usage latency limit in milliseconds per run (a scenario fails above it); a daily and a monthly spend limit (a paid run is refused above it); free disk needed before a gate step starts (the gate skips the step and exits non-zero).
B6 (seen): the docs-site UI ratchet compares each of about 200 values against a committed baseline file, lower is better, tolerance 0; a worse value needs a named decision entry committed with the new value. A known-failing list for conformance holds entries with a story reference and a review-by date. The baseline holds the CI image's numbers, so it can only be taken after a CI run or a 10-minute container run.
B7 (seen): a stats block appended to a status file per day (backlog counts); a trend file for UI rounds; spend lines in job logs. No dashboard for test time, CI time or flakiness.

## C. What went wrong
C1 (seen): the conformance gate is red on the count of unsupported scenarios (above its cap) after a specification bump added scenarios the runner cannot drive. Noticed by the gate on the next run, same day. No earlier check could catch it: the count only exists after the suite is synthesized against the new specification.
C2 (seen): a voice scenario failed once in a smoke run and passed on rerun; cause not established; a transcript log line was added so the next occurrence decides between two candidates. Also seen today: a baseline ratchet went red because a new content page shifted a list by one keyboard step; nothing was wrong with the product.
C3 (seen): three conformance scenarios were put on the known-failing list with a story reference and a review date one week out; not yet tightened. A usage latency limit sits at 5 times its target until a backend fix lands; the tightening is a written promise in a session, not a check (inferred risk: it gets lost).

## D. Friction
D1: waiting for a verdict. A full local gate took 36 minutes today on a loaded shared machine, and a single test run waited several minutes for a build slot; a CI pipeline for the backend takes about 18 minutes. Second: numbers live in job logs, so every "before and after" needs a session to fetch and grep traces by hand.
D2: which failures are caused by the test double or the runner and which by the product. It lives in session context and in a hand-kept findings table, and is rebuilt by reading traces. Also: which waits in tests are production constants; that lived nowhere until a story listed them.
D3: the count of "unsupported" conformance scenarios. One first-blocker count suggested a fix would free 188 scenarios; measuring showed 2. A count by first blocker does not say what a fix buys.
D4: n/a

## E. Quality in plain words
E1: A change does what its story says and breaks nothing a user or a caller of the API relies on. The deployed build behaves as the specification says, and where it does not, that is written down with an owner. Checks answer within minutes and mean the same locally and in CI. A red check is always a real problem. Running the checks costs little money.
E2: Today: tests, conformance counts, time limits, spend limits. With work: "a red check is always a real problem" (flake rate per check over time), "same locally and in CI" (compare the two step lists and toolchains), cost per run trend. Never fully: "does what its story says".
E3: End users: a voice call that fails or answers late. API consumers: a response that no longer matches the published contract. Developers and coding agents: a gate that takes longer than last week, or a check that is red for a reason outside their change. Operators: a deploy that restarts a shared test environment without notice, or a rising spend per run.
E4: Per CI job, the wall time of the test step is compared with the median of the last 10 runs on the default branch and the merge is refused above +20 % or above a fixed 120 s, checked on every merge request, with the number stored so the trend can be read without opening a job log.
