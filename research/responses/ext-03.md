# Response: ext-03

- kind and stack: personal operations control plane; workflow protocols (YAML) run by an external workflow runtime, tools in POSIX sh + jq
- answered by: the coordinating agent session of the repository
- date: 2026-11-23
- note from the survey owner (inferred): ext-06 describes a repository with the same file counts and age, from a second session working in it

## A. The project
A1: Platform/automation repo (other). ~387 tracked files, ~43k lines: 117 md, 109 json, 99 yaml, 41 sh, 8 jq (seen: git ls-files). Users: one operator and coding agents; runs on one workstation. Repo is 2 days old (first commit 2026-11-22, seen).
A2: Turns an operator's recurring engineering work (daily digest, release review, bug-fix delivery, checks and gates) into declared, checked workflows that run unattended and report outcomes.
A3: Agent sessions only, steered by one person. 40 commits in its first 2 days (seen: git log).

## B. What you track today
B1: Static model check of every workflow protocol (state-space check + simulation, ~2 min, local only, blocks nothing automatically, seen). A lint that every program action declares its error exit codes (local, seen). Shell syntax checks ad hoc. No unit tests, no coverage, no CI until this week's change (being added now, inferred).
B2: Nothing recorded. Observed by hand: one release-review run 49 s to ~60 min; a bug-fix run 74.8 min, of which 47 % was waiting in the shared build queue and 2 % model time (seen, retro).
B3: Nothing tracked. Per-run outcome and spend are written to run directories (seen), not aggregated.
B4: Each workflow ends in a named outcome (e.g. reviewed / published / failed / not-written); outcomes recorded per run (seen). A replay mode re-runs a recorded run's calls and diffs outputs byte for byte (seen); used as a regression check by hand. Recall of a knowledge-extraction step judged against 34 hand-picked facts (26 covered / 8 partial / 0 missed, seen).
B5: Thresholds: per-run model spend caps (calls and nominal USD; being made configurable now), per-step timeouts (runtime max 3600 s), a 2-minute target for any test step (written in operator rules, not enforced, seen). Crossing a cap stops the run with a named outcome.
B6: Replay compares against a recorded run (stored as call logs + answers in the run directory). Recall compares against the previous measured round, by hand. No stored baseline file.
B7: Nothing over time. Run directories pile up (7.4 GB in a day, seen) with no trend view.

## C. What went wrong
C1: A step's test time limit counted time spent queueing for the shared build pool; a release run failed at 1500 s although the tests were fine; noticed in the same hour from the run's outcome; a check of queue-vs-run time per step would have caught it (seen).
C2: Bug-fix verdicts: 3 of 4 runs of one ticket ended "not fixed"/"not reproduced" with no code verdict: step timeouts killed by build-queue waits, read as failures (seen, retro).
C3: That step budget was first raised (1500 → 2400 s) to get runs through, then split properly into queue / run / reserve budgets the same day (seen). Two redaction lists drifted apart (one misses three token prefixes) with no check catching it (seen, review).

## D. Friction
D1: Shared build-pool queue: 35.5 of 74.8 min of one run (seen). Second: docs drifting from config (the version of the runtime stated four different ways, seen).
D2: Which workaround exists for which upstream defect and when it can go: in the agent instructions file and session memory only; now being moved to markers checked against pinned versions (inferred plan).
D3: The state-space check: it refuses some valid protocols at its state bound, so a pass/fail there partly reflects protocol shape, not correctness (seen).
D4: Young repo; speed of building first; now adding a gate and CI.

## E. Quality in plain words
E1: A workflow always ends with a named, true outcome; a timeout or a broken tool is never reported as a verdict about the work. It never runs unbounded on money or time. It never leaks a credential into its records. Its documents state each fact once and match the config. It can be replayed to show the same output.
E2: Machine-checkable today: named outcomes, caps, replay equality, protocol model check. With work: credential-shape scan of all run records, docs-vs-config drift, "timeout is not a verdict". Never fully: whether the outcome is true (a reviewer still judges).
E3: Operator: a run reports success but nothing happened. Coding agents: instructions that contradict the config. Downstream teams: a ticket moved or a message posted wrongly. Developers of the runtime: a consumer relying on undocumented internals.
E4: Every run's records are scanned for credential shapes and any finding fails the run, checked at run end and in CI on fixtures.
