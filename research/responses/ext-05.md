# Response: ext-05

- kind and stack: API specification repository (YAML specification sources, POSIX sh and Python tooling, generated OpenAPI/AsyncAPI/JSON Schema/Rust types) for a backend platform
- answered by: specification-repository coordinator session (agent)
- date: 2026-11-23

## A. The project
A1: Specification repository: about 20 domain files and about 190 scenario files of YAML, plus about 30 shell and Python tools. Users: the backend service (generates its types from it), an end-to-end test repository (runs its conformance suite), coding agents (write it first, then the code). seen
A2: Single source of truth for the platform's API: every route, wire name, type and behaviour is written here first; the backend and its tests are derived from it. seen
A3: Agent sessions do the work, one human decides. About 6 merged changes on the day of answering (seen); a typical week: I don't know.

## B. What you track today
B1: Local gate equals the CI job: specification validates; generated files equal what the generator produces from the sources (drift check, blocks); a source digest check; OpenAPI comparison against the served backend document with an exceptions ledger (blocks); every open question in the sources has a row in a ledger (blocks); every backend line citation names a commit (blocks, added this week); shell and Python unit tests (blocks). No coverage %, no lint score. seen
B2: The whole local/CI check step has a 120 s budget, enforced: over it the step fails and prints the ten slowest sub-steps (added this week). Measured runs: 38-92 s depending on host load. Flaky timing tests were the main cost of building it (5 review rounds). seen
B3: CI per merge request; merge on green automatically. Release frequency, lead time: not tracked in this repository (I don't know). seen/inferred
B4: Conformance: a synthesized scenario suite (about 800 scenarios) runs against the spec's own interpreter (counts compared to a baseline, blocks) and against a real backend deployment in the consumer repository (failed and unsupported counts capped, blocks there). No performance, accessibility or production error tracking here. seen
B5: Check step 120 s (in the repository's task runner, CI variable); single test 60 s (a written rule, not yet enforced: filed as a story); consumer gate caps on the failed and the unsupported scenario counts (consumer repository gate file). Crossing any fails the job. seen
B6: Conformance pass counts against a committed baseline file, rewritten from a merge request's pipeline when the suite changes; spec diff against `main` (breaking vs unknown changes). seen
B7: Badges generated from the baselines; review documents in the consumer repository compare one job's results with an earlier job's by scenario id. No dashboard. seen

## C. What went wrong
C1: Backend line citations in the specification drifted: the backend moved code and the spec cited wrong lines for weeks (over 150 found wrong in two code areas this week). Noticed by an adversarial review agent. A pattern check that every citation names a commit would have flagged them; added this week. seen
C2: Timing-based tests of the 120 s guard: red at host load 126-160 on a shared 20-CPU machine (6 of 6 runs) and 1 of 10 at load 80; rebuilt to wait on events instead of time. seen
C3: Consumer conformance caps are explicitly not raised ("no workarounds"); a known-failing list exists with review dates, one row past its review date. seen

## D. Friction
D1: Shared machine load and a build-slot queue: single runs waited 0.5-19 min for a slot; a hung container command cost over 120 min once. Review rounds on timing-sensitive tests: 5 rounds, about 1-1.5 h each. seen
D2: Which citations are true at their commit (only checked by one-off resolver runs in review, not by a gate); which refusal order the backend uses (in spec comments, partly contradicted by scenarios). Lives in review reports and story bodies. seen
D3: Header-level "all citations here are at commit X" sentences: the check accepts them, but nothing verifies the cited lines hold there. seen
D4: n/a

## E. Quality in plain words
E1: The specification says what the backend does today, and a change is written here before the code. Every claim about the backend points at the exact code and version it was read from. The checks finish within two minutes and give the same answer locally and in CI. A scenario that fails tells you whether the spec, the test driver or the backend is wrong.
E2: Machine today: spec before code (drift checks), check time, local equals CI. With work: citation truth (resolve each at its commit), which side a failing scenario blames. Never fully: whether the spec describes the intended behaviour rather than the current one.
E3: Backend developers: a generated type changes without a spec change. Test repository: a scenario fails for a spec mistake. Coding agents: the check takes over 2 minutes or flakes. API consumers: a route behaves differently from its documented outcome.
E4: Every backend line citation under the specification resolves at its named commit (the cited lines hold the named item), checked in CI on every merge request.
