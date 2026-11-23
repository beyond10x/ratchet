# Response: codespec

- kind and stack: library + CLI with language adapters; Rust core, adapters in Go, Rust, Java, Groovy, C, Elixir, Gleam, Odin; Docusaurus docs site
- answered by: coordinating agent session for the codespec maintainer-review wave
- date: 2026-11-23

## A. The project
A1:
- Library + CLI (`codespec`) plus reader/writer adapter programs per language, and a docs site (seen).
- Size: 4,591 tracked files; ~110,600 lines of Rust, ~21,000 lines of Go (seen: `git ls-files`, `wc -l`).
- Users: developers and coding agents (translation, static checks, queries over code); other repositories use its conformance kit (inferred from README/AGENTS.md).
A2: Lifts source code into a typed intermediate representation (`cir/1`), rewrites it, writes it out in another language, and proves the translation by running original and output on the same inputs byte for byte; also checks, queries and an evaluator over that representation.
A3:
- Agent sessions only; commits and pushes are made by the org bot (seen: AGENTS.md § Delivery, every commit author `b10x-bot[bot]`).
- Last 7 days: 59 commits and 20 merges on main; 6 releases in 13 days (0.7.0 on 11-10 to 0.12.0 on 11-23) (seen: `git log --since`, `git tag`).

## B. What you track today
B1:
- Local gate `task check` = CI `check.yml`: fmt, clippy `-D warnings`, every cargo test target, gofmt + go vet on adapters, examples read twice and byte-equal to checked-in, generated files current (`docs-check`), conformance kit packed and run (seen: AGENTS.md § Gate).
- A check compares the CI part list (`scripts/check-parts.txt`) with cargo's test-target inventory, so a test target in no CI job fails the gate (seen, added in PR #33).
- Shared security/privacy scan (`shared-gates.yml`, "common / Security and privacy"), required (seen: ruleset).
- No coverage, complexity, dependency age or build-warning count tracked (inferred: none in workflows).
B2:
- Nothing measured automatically. Test-step budget (≤120 s step, ≤60 s per test) is an organization rule in the workspace AGENTS.md, not enforced by codespec's runner (seen).
- Measured by hand on 2026-11-23 under host load 100-180: eval suite ~497 s serial; single test binaries 52-328 s (seen, recorded in draft story `test-budget-existing-suites`).
B3:
- CI required on PRs (3 required checks; ruleset not strict) (seen: rulesets API).
- Release: tag → `release-build.yml` builds 3 targets + kit + SHA256SUMS; release only after checksums verify (seen: AGENTS.md § Release, done for 0.11.0).
- Not measured: CI duration, queue wait, lead time (I don't know of any record).
B4:
- Conformance: `codespec conform` per adapter and role against a kit of feature cases; reports checked in under `website/data/conformance/*.json` and drift-checked (seen).
- Comparison harness: original and translations run 200 seeds × 300 commands, byte-equal (seen: `task harness`, `examples-*`).
- Evaluator kit: 145 cases (seen: `task eval-kit` output via an agent report).
- Docs site UI: a Playwright loop under `ux/` with `baseline.json` ratchets (seen: directory; in progress on a branch).
- No production; no SLOs (n/a).
B5:
- Byte equality (zero tolerance): examples, generated files, conformance reports, harness traces; written in Taskfile/AGENTS.md; crossing fails the gate (seen).
- Conformance: every claimed feature must pass; `conform --check` fails on any drift (seen).
- The host's shared build pool kills a build job at 10 min (host rule, not repo) (seen).
B6:
- Checked-in files are the baseline: `*.read.cir.json`, `out/**`, `website/data/conformance/*.json`, `expected.txt`; updated only by generator tasks in the same commit (seen: AGENTS.md § Generated files).
- `ux/baseline.json` for UI ratchets (seen file; how it is updated: I don't know).
B7:
- Git history of checked-in reports and `CHANGELOG.md`; `ux/rounds/trend.md` for UI rounds (seen). No dashboard.

## C. What went wrong
C1:
- An external maintainer review of 0.10.0 found 35 defects on main: e.g. Go writer dropped all but one `init()`, C writer stored into the wrong element, Rust writer panicked on a rebound slice, query cache readable from the input directory (seen: review document).
- Noticed by manual review 10 days after the 0.10.0 release; checks that could have caught them: differential tests against the native toolchain per construct, property tests, and running the evaluator/effects suites in CI (CI did not run 25 test targets until PR #33) (seen).
C2:
- CI downloads of go-task and Groovy got HTTP 429: 6 CI runs failed on 2026-11-23 with no code fault; fixed by downloading once per run into a cache (PR #40) (seen).
- Some test binaries exceed 60 s only under host load (one eval test failed once at load ~170, passed on rerun) (seen).
C3:
- None seen in codespec. Agents re-ran pool jobs with `--timeout 30m` after the 10-min kill (3 times), raising the host limit for that job (seen).

## D. Friction
D1:
- CI runner queue: 10 PRs × ~21 jobs each waited roughly 30-90 min for runners on 2026-11-23 (inferred from check-run states polled during the day).
- Slow existing test binaries (52-328 s each) on a loaded shared host; whole-crate test runs hit the 10-min pool kill (seen).
D2:
- Whether a translation is correct for constructs outside the kit and examples: only the review knew (35 findings). Lives nowhere but the review document and stories (seen).
- Which tests are slow: measured by hand into a draft story, no check (seen).
D3:
- A green `task check` before PR #33: it skipped the evaluator and effects integration suites while looking complete (seen).
D4: n/a.

## E. Quality in plain words
E1:
- A translated program does what the original does, for every construct the tool says it supports.
- Anything the tool cannot express is refused loudly with a reason, never approximated.
- The same input always gives the same bytes out.
- A change that breaks a supported construct fails a check before merge, within minutes.
E2:
- Machine-checkable today: same bytes out (examples, reports); claimed features pass conformance.
- With work: "every supported construct behaves like the original" (differential test per construct against the native toolchain, generated cases); "fails within minutes" (test budget enforced).
- Never fully: "every construct" in the open-ended sense; the kit can only sample.
E3:
- Developers/agents using the CLI: a translation that compiles but computes a different value.
- Adapter authors (consumers of the conformance kit): a kit or report format change without a version bump.
- Coding agents working in the repo: a gate that takes over 2 minutes or goes red without a code change.
- Release operators: a release archive missing a program the guide says it ships.
E4: Test step wall time per CI part and per test, compared with 120 s / 60 s, checked on every PR, failing the PR when exceeded.
