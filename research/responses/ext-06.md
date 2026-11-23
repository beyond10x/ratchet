# Response: ext-06

- kind and stack: operations control repository: declarative workflow definitions (YAML) run by an external workflow runner, with POSIX sh + jq tools as the workflows' program steps
- answered by: agent session that drives a bug-fix workflow from this repository against two product repositories
- date: 2026-11-23
- note from the survey owner (inferred): ext-03 describes a repository with the same file counts and age, from a second session working in it

## A. The project
A1: Kind: other (operations workflows). 387 tracked files: 117 Markdown, 109 JSON, 99 YAML (12.4k lines), 41 sh files (10.9k lines), 8 jq (seen: `git ls-files` counts). Used by one operator and by coding-agent sessions.
A2: It holds the workflows an engineering lead runs through agents: reading sources into a knowledge store, release review, repository preflight, deploy verification, and the per-repository test commands for an automated bug-fix workflow.
A3: Agent sessions only, steered by one person. 40 commits in its first 2 days, all direct to the default branch (seen: `git log --since`). 2 to 3 sessions commit in parallel (seen).

## B. What you track today
B1: seen: (1) a script checks that every program step declares the same list of error exit codes; local task, blocks nothing by itself. (2) a model check and a simulation of every workflow specification, pinned to one checker version, about 2 min; local task. (3) a catalogue build that checks ids, children, cycles and file existence. (4) `sh -n` per script, by habit. No unit tests, no lint (no shell linter installed), no coverage, no security scan, no CI file in the repository.
B2: nothing recorded by a tool. One hand-written retro of one workflow run split its 74.8 min into 1.7 min model time, 35.5 min build-pool queue, 36.4 min build and test (seen). The runner truncates a step's log when the step's next command starts, so build vs test time is known for 1 of 5 jobs (seen).
B3: nothing. No CI, no merge queue, no release; a push to the default branch is the delivery (seen).
B4: seen: each workflow run ends in a named outcome and each view lists its good outcomes; parity scripts compare a ported tool's exit code and every output line with the old tool on the same input tree; a replay answers every external call from a recording and the outputs must be byte-equal; a judged recall count for the knowledge store (27 covered, 7 partial, 0 missed of 34 in one run). None blocks a commit.
B5: seen: per-step time limit in the workflow's binding file (the step is killed); spend cap, model-call cap and wall cap per run as task variables (the run stops); a state-count bound in the model checker (the specification is refused); a store gate (at most 5 unrestored placeholders, else the write is undone). A test-time budget (step under 2 min, no test over 60 s) exists as a prose rule in an instruction file and is not enforced here.
B6: seen: parity (baseline = the old tool's output on the same tree) and replay (baseline = a recorded run). Both baselines live in git-ignored run directories; the numbers are copied by hand into the agent instruction file. No stored accepted value that a tool updates.
B7: Only as prose: measured numbers with a run id and a date in the agent instruction file and in docs (seen). One spend ledger file per workflow. No trend, no dashboard.

## C. What went wrong
C1: seen: all workflows shared one spend ledger; after one workflow booked a small cost, every workflow with a near-zero cap stopped before its first step. Noticed at the next manual run, hours later. A check that runs every workflow once in dry mode after a change to shared settings would have caught it.
C2: seen: a step killed by its time limit was recorded as a verdict about the code ("not reproduced", "not fixed"). 3 of 6 bug-fix runs in one day ended that way; the cause was queue wait on a shared build pool at high host load. Also seen: a BDD suite of a target repository failed 5 of 341 scenarios under host load and passed 341 of 341 in CI on the same commit (fixed ports, a 30 s step limit, a 60 s boot limit).
C3: seen: reader step deadlines were raised under load (one from 540 s to 1500 s); the pool job time was raised from 10 min to 30 min for the checks; jobs were marked high priority, as were 14 repositories, so the mark stopped meaning anything. I don't know of one that was tightened again.

## D. Friction
D1: Waiting for a verdict on a shared, loaded build pool: 35.5 of 74.8 min in one run was queue; a 1 s check waited 444 s for a slot. Second: a lost run costs a full rerun (about 75 min and model cost) because a time-out and a real failure look the same in the result.
D2: Under which host load a number was measured; which outcome labels are trustworthy; that a time-out is an error and not a verdict. It lives as prose in an agent instruction file of several hundred lines and in messages between sessions.
D3: The outcome label of a run whose step timed out (see C2). A green dry run: it proves the wiring, not the checks. Numbers in the instruction file: copied by hand, no tool re-reads them.
D4: n/a for specifications (tracked). For the sh tools: the repository is 2 days old and nobody asked for a gate yet (inferred).

## E. Quality in plain words
E1: A workflow gives the same answer on the same input, and says "I could not tell" when it could not read something. It never reports a verdict it did not measure. A step that writes to the outside world is preceded by a recorded approval or a standing grant. Every number in a report can be traced to the run that produced it. A run finishes in a time the operator can wait for.
E2: Machine-checkable today: same answer on same input (replay, parity). With work: "never a verdict it did not measure" (classify every step end as verdict, error or time-out), traceable numbers (a tool writes them, not a session), run time (record queue wait and run time per step). Never fully: whether the outside write was the right one.
E3: Operator: a run that ends with a wrong or unexplained outcome. Coding agents: an instruction file whose numbers or version names are stale. Maintainers of the runner: a defect report without the run's evidence. Owners of the target repositories: a merge request whose tests were never run green.
E4: Per step, queue wait and run time are recorded; a run in which any step ended by its time limit closes as "error", never with a verdict; checked when the run closes.
