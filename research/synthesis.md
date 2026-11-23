# Synthesis: how projects track quality today

Synthesis of survey 1 ([questions](survey-quality-tracking.md), answers in `responses/`). It groups
the answers into patterns a designer can act on. It is not a summary of each answer.

- `surf C2` means `responses/surf.md`, question C2.
- A count is a number of answers unless it says projects. Borderline answers are named.
- Domain terms (requirement, measurement, assessment plan, assessor, target, protected reference,
  gate, ratchet policy) are those of [`docs/design.md`](../docs/design.md).

## 1. Scope

- 26 answers, all dated 2026-11-23 (`date` line of each file).
- 25 distinct projects. 18 answers are beyond10x repositories, named by repository. 8 are projects
  outside beyond10x (`ext-01` to `ext-08`). `ext-03` and `ext-06` describe the same repository from
  two sessions (note in both files), so they count as one project. A count of answers includes both;
  a count of projects merges them.
- Collection: the host operator session sent the survey to the working sessions on one shared
  workstation and returned their answers ([README.md](README.md)).
- Who answered: an agent session in all 26 (`answered by` line). No person answered. 6 answers are
  read-only passes that ran no gate: ess, loom, runbook, slot, spindle, ext-01 (header lines).
- Who does the work: agent sessions in 22 answers, most with one person deciding; people as well
  in 4 (ext-01, ext-02, ext-07, ext-08, all A3).
- Kinds: 20 answers have a Rust code base (17 beyond10x answers, ext-02, ext-04, ext-07). 3
  describe a deployed backend service (ext-01, ext-02, ext-07, all A1). The rest are libraries,
  CLIs, local daemons, tools or specification repositories.
- Age: 6 answers (5 projects) describe a repository at most 3 days old: inbox A3, runbook header,
  swell A3, ux-ui A3, ext-03 A1, ext-06 D4.
- Bias: almost all answers come from agent sessions on one shared, loaded machine. Answers quote
  load averages of 100 or more on the answer day (codespec B2, inference C2, inbox C2, ext-05 C2).
  Findings F1 to F3 are shaped by that. See section 5.

## 2. Findings

### F1. A check went red with nothing wrong in 23 of 26 answers

- 23 answers name at least one case in C2. The other 3: spindle C2 ("Not recorded"), ext-01 C2
  ("I don't know"), ux-ui C2 (a wall time inflated by queue wait, no red result).
- Causes, not exclusive:

| Cause | Answers | Ids (C2 unless noted) |
| --- | --- | --- |
| A time limit hit, or a timing test failed, because of host load or queue wait | 16 (15 projects) | codespec, connectors, cortex, entity-runtime, inbox, inference, runbook, slot, substrate, surf, swell, ext-03 C1, ext-04, ext-05, ext-06, ext-08 |
| The environment: a tool or toolchain other than the pinned one, a variable, a runner capability | 8 | canon, ess, inference, llm, loom, runbook, substrate, ext-04 |
| CI or job infrastructure: no runner, a rate-limited download, a workflow started too early, a host crash | 5 | agentplugins, codespec, connectors, llm, ext-08 C1 |
| A defect in the test itself (a race, one read of a changing value) | 3 | slot, substrate, surf C1 |
| A live model answered differently on a rerun | 2 | ext-02, ext-07 |
| A ratchet moved by unrelated content | 1 | ext-02 |

- "6 CI runs failed on 2026-11-23 with no code fault" after HTTP 429 on tool downloads
  (codespec C2). 47 tests fail when a tool newer than the pinned one is first on PATH (canon C2).

### F2. A wall-time limit on a shared host measures the host

- 16 answers (15 projects) report it: the first row of the F1 table.
- 9 answers name a load-dependent time check as the check they do not trust: connectors,
  entity-runtime, inbox, inference, runbook, slot, surf, swell, ext-04 (all D3).
- The same 71 tests took 19.0 s on the forge and 20 s to 209 s locally; "3 of about 12 local gate
  runs today were red only for that" (surf C2). A release gate "passed every check and exited
  201" on 194.7 s of a 120 s budget at load 65; the same steps took 94.3 s at load 34 (swell C2).
- Queue wait is counted inside the measured time: a step's time limit "counted time spent
  queueing for the shared build pool" (ext-03 C1); a round reported 1912 s and the browser run
  itself was 108.6 s (ux-ui C2); "waited 2356s for a build slot, ran 7s" (inbox D1).
- 5 answers say a runner or pool reports wait and run time apart: slot B2, swell B2, inbox D1,
  ext-02 B2, ext-08 C2. 2 answers give the two their own budgets (ext-03 C3, ext-08 C3).
- A limit widened to absorb noise stops catching regressions: a timing limit set to 2.0x after an
  unchanged build moved up to 1.94x "misses a 1.68x regression" (entity-runtime C2, C3).

### F3. Time to a verdict is the top cost in 24 of 26 answers

- 24 answers give time waiting for a verdict as a top cost in D1, with a number. The other 2:
  spindle D1 (no timing data), ext-01 D1 (documents and code disagree).
- 17 of the 24 (16 projects) give a figure for queue wait for a build slot or a CI runner:
  codespec, connectors, cortex, entity-runtime, ess, inbox, llm, substrate, surf, swell, ux-ui,
  ext-02, ext-03, ext-05, ext-06, ext-07, ext-08 (all D1).
- Examples: 15 to 31 minutes of queue per job (connectors D1); 35.5 of 74.8 minutes of one run
  (ext-06 D1); "9 gate runs and 42 minutes for one documents-only push" (surf D1); 3 to 40 reruns
  of a test to tell a load failure from a break (slot D1).

### F4. Load-independent measures are in use in 8 answers

| Measure | Status | Id |
| --- | --- | --- |
| 55 deterministic counters: bytes, opens, fsyncs, allocation bytes | compared with a baseline; job not required | entity-runtime B4, B5 |
| Instructions and syscalls of frozen scenarios, allocations per request | blocks the merge | ext-04 B4, B5 |
| Instructions of a test step, median of three runs | written limit, checked by hand | surf B2, B5 |
| Binary starts per test group (66), summed test time (60 s) | blocks | loom B2 |
| "a store replays at most once on a read invoke" | blocks | connectors B5 |
| Step totals of some operations ("must not move") | in tests | swell B6 |
| Summed case time, CPU time, process starts per case | measured after a failure | inbox C1 |
| Instruction counts quoted in changelog entries | by hand | ess B4 |

- Why: "CPU seconds moved 60 % with host load, instructions under 2 %" (surf C3). A rise of 0.24 %
  in the instructions of one scenario was refused before release (ext-04 C1).
- It has its own dependency: "the counts depend on glibc, compiler versions and CPU, so a distro
  update can refuse a merge that changed no code" (ext-04 D2).

### F5. The most common baseline is a committed generated file, compared by bytes or digest

- 21 answers block on a generated or derived file that differs from a fresh generation: canon,
  codespec, connectors, cortex, entity-runtime, ess, inbox, llm, loom, runbook, slot, spindle,
  substrate, surf, swell, ext-02, ext-04, ext-05, ext-07, ext-08 (all B1), inference B6.
- The convention: zero tolerance, and the generator rewrites the committed file in the same change
  (codespec B6, connectors B6, inbox B6).
- Gaps: a passing drift check "does not prove the schema matches validation" (canon D3); a merge
  can leave a generated file stale without a conflict (runbook C1).

### F6. 18 answers keep accepted values in a file their own tool compares

- 18 answers have a committed file of accepted numbers or counts and a repository-own tool that
  compares against it: agentplugins, codespec, cortex, entity-runtime, inference, llm, runbook,
  slot, spindle, substrate, surf, swell, ux-ui, ext-02, ext-04, ext-05, ext-07, ext-08 (all B6).
  Not counted: ess B6 (a baseline behind a parked check), loom B6 (a one-off baseline).
- 12 of them run the same kind of UI loop with a lower-is-better baseline per scenario and key:
  agentplugins, codespec, inference, llm, runbook, slot, spindle, substrate, ux-ui, ext-02, ext-04,
  ext-08 (B4 or B6). One answer counted that loop "7 times in 3 languages" in one organization
  (ux-ui Notes).
- Other forms: expected-count files (surf B6, swell B6), a list of executed scenario ids
  (spindle B5), constants in a test (cortex B6, substrate B5), failure manifests (ext-07 B6).
- Conventions that recur:

| Convention | Answers | Ids |
| --- | --- | --- |
| A worse value needs a named decision id | 9 | llm B6, runbook B5, slot B6, spindle B6, substrate B6, ux-ui B6, ext-02 B6, ext-04 C3, ext-08 B6 |
| The new value is committed in the same change | 8 | agentplugins B6, codespec B6, connectors B6, inbox B6, runbook B6, slot B6, substrate B6, ux-ui B6 |
| Tolerance per key: 0 for counts, a small band for noisy keys | 7 | agentplugins B5, entity-runtime B5, runbook B5, slot B5, spindle B5, ux-ui B5, ext-04 B5 |
| An improvement not written back fails, or blocks a release | 5 | llm B6, substrate B6, surf B6, ux-ui B6, ext-08 B6 |
| The baseline file is compared with the copy on `main` | 4 | llm B6, spindle B6, ux-ui B6, ext-08 B6 |

### F7. Ways a baseline failed to protect

| Failure | Answers | Ids and example |
| --- | --- | --- |
| The candidate can change the value it is judged by | 3 | entity-runtime C1: the commit that caused a regression "re-recorded a worse counter ... which the ratchet allows". cortex D3: "a hand-edited number can be raised to match a lower coverage". ux-ui E3: "a gate they can make green by editing the baseline or the scenarios" |
| The first baseline is compared with itself | 1 | ux-ui B6: "the first ratchet 'pass' compared a value with itself" |
| The baseline is stale after an improvement | 1 | entity-runtime C3: 27 counters "improved: re-record" from 02:45 to 15:34, "so regressions up to each improvement would have passed" |
| A count does not say which cases | 3 | swell D3: "a new pass beside a pass turned fail would keep the total". ext-01 D3: 18 of 50 scenarios fail and "nothing records which ones or why". ext-02 D3: a count by first blocker suggested 188 scenarios, measuring showed 2 |
| A count does not say what the cases can catch | 2 | surf D3, spindle D3 |
| The values depend on the environment that produced them | 4 | ext-02 B6 (the baseline holds the CI image's numbers), ext-04 D2, slot C3, inference B6 (snapshots valid for one compiler version) |
| The reference lives outside the repository | 4 (3 projects) | swell B6 (run files in scratch, compared by hand), canon B6 (scratch scripts), ext-03 B6, ext-06 B6 (git-ignored run directories) |
| The measurement itself was wrong | 1 | ux-ui C1: a "not done" result counted as no miss; the trend said 2, the true count was 12 |

### F8. Checks that report but do not block

- 7 answers have a check that runs in CI and reports a problem while the change merges or the
  release goes out:

| Check | Why it does not block | Id |
| --- | --- | --- |
| Skills against newest CLI releases, red on `main` | not a required check; reason not given | agentplugins B4, C1 |
| Test step budget in `report` mode | CI measured 124 s against 120 s | cortex B2, C3 |
| Timing A/B with `continue-on-error`; counters job not required | shared-runner noise | entity-runtime B5, C3 |
| 60 s per test "reported, not killed" | the kill is a story of the current wave | ess B2, B5 |
| A Windows job red "since at least 2 releases" | known cause, fix pending | connectors C3 |
| A code scanner and a macOS build | not required; reason not given | substrate B1 |
| A conformance gate red "for a while by decision" | "its colour no longer carries information; only the counts do" | ext-07 D3 |

- A test-time rule of 2 minutes per test step is written in 21 answers; 19 of them also write 60 s
  per test (not ext-03, ext-08). In 10 answers (9 projects) at least one part of it is prose or a
  report and is not enforced in the repository: codespec B2, cortex B2, entity-runtime B5, ess B2,
  inference B2, slot B5, ext-03 B5, ext-05 B5, ext-06 B5, ext-08 B5.
- In 6 of those 10 the measured value was over the rule: codespec B2 (test binaries of 52 to
  328 s), cortex C3 (124 s), entity-runtime B2, ess B2 (74 tests over 60 s in one run),
  inference B2 (154 s and 137 s), ext-08 D1 (1016 s at the last measured run). In 4 answers the
  step to enforcement is an open story: cortex C3, entity-runtime C3, inference B2, ext-05 B5.
- Checks run only by hand or only locally: a UX ratchet (spindle B4, runbook B4, ext-08 B4),
  fixture byte identity "done by the agents, not by a committed check" (canon B4).

### F9. Green without evidence

- 10 answers report a green result that covered less than it appeared to:

| What was missing | Id |
| --- | --- |
| 96 tests skipped for a missing prerequisite: "green says nothing about delegated confinement on CI" | loom D3 |
| Cases skipped when a prerequisite is absent, "and the exit status is 0 either way" | substrate D3 |
| A line prints "not run" for database tests "and the gate still exits 0" | ext-07 D3 |
| 87 of 119 scenarios unsupported over HTTP pass the gate | inbox B4, D3 |
| A live evaluation skipped unless labelled; the last 5 runs were skipped | agentplugins D3 |
| A gate that skipped two suites "while looking complete" | codespec D3 |
| "Tests pass" evidence that covered 3 of 20 crates | llm C3 |
| A gate of named test targets that missed nine red tests | ess C1 |
| A ratchet that is green on its first run | ux-ui D1 |
| A green dry run: "it proves the wiring, not the checks" | ext-06 D3 |

- The reverse also occurs: a step killed by its time limit was recorded as "not reproduced" or
  "not fixed" in 3 of 6 runs in one day (ext-06 C2, also ext-03 C2; one project).
- 9 answers already put a number on evidence coverage (executed, skipped, unsupported, failed or
  ignored counts): spindle B5 (`skipped = 0` and an exact executed set), substrate B5, swell B5,
  ext-02 B5, ext-05 B5, ext-07 B5, cortex B4, surf B4, ext-04 C3.
- A subject that answers differently per run needs more than one run: "one red run in ten says
  little, and one green run says little too" (ext-07 D3). Repeats are in use in 4 answers: 3 runs
  per cell (runbook B4), a median of three (surf B5), the best of 3 rounds per side
  (entity-runtime B6), 5 runs for a recorded count file (ext-04 B6).

### F10. The local gate and CI disagree in 14 answers

- 14 answers report a different check set or a different result for the same tree. runbook,
  spindle and substrate report both.
- Different check set (8): runbook B3, entity-runtime D2, spindle B1, ess B4, loom C3, ext-07 D3,
  ext-08 B4, substrate D2.
- Different result (9): spindle C1, substrate C2, inference C2, llm C2, runbook C2, slot C2,
  surf C2, swell C3, ext-06 C2.
- Examples: CI runs one crate's tests and the docs checks while lint and UI tests run only
  locally, so "a green CI means less than a green local gate" (runbook B3, D3). A suite failed 5
  of 341 scenarios under host load and passed 341 of 341 in CI on the same commit (ext-06 C2).
- Agents then take the forge as the verdict (slot D1, swell C3).

### F11. Numbers are not kept over time; they are copied into prose by hand

- No answer reports a stored series of CI duration, CI queue wait or lead time, or a comparison
  against one (B3 in all 26). Figures given were read from the forge or a job log on the answer
  day (loom B3, slot B3, runbook B3, ext-02 B3). The limits that exist are job timeouts
  (agentplugins B5, loom B5, spindle B2).
- 4 answers have a tool that writes a series of results: a JSONL history per run with a trend page
  (ext-04 B7); a job log of queue wait, run time and CPU seconds for every job on the host
  (slot B2, B7); a release ledger with a staleness check (runbook B7); per-run result archives as
  a CI artifact (ext-07 B7). None puts a threshold on gate time (ext-04 B2, slot B2, runbook B2).
- 10 answers keep a trend table with one row per UI round: codespec, inference, llm, runbook,
  slot, spindle, substrate, ux-ui, ext-02, ext-08 (all B7).
- 16 answers (15 projects) keep measured numbers as hand-written prose in an agent instruction
  file, a story, a changelog, a commit message or a document: canon B7, codespec B2,
  connectors D2, entity-runtime B2, ess B7, inbox B7, loom B7, runbook B2, slot B4, substrate D2,
  surf B7, swell B7, ext-02 B2, ext-03 B2, ext-06 B7, ext-07 B3.
- "Every release a sub-agent rewrites the gate's counts in `README.md`, the website, `AGENTS.md`
  and a badge (7 files today)" (surf D1). "Nothing checks that those numbers are still true"
  (loom D2).
- A value that grows toward a fixed limit is seen only when it hits the limit (4): a scan input
  at 512.3 MiB against 512 MiB (cortex C1), a test step at 120 s (inbox C1), a full run that
  outgrew a 10-minute job (swell C1), a test binary at 145 s (loom C1). "A recorded duration per
  run with a comparison would have shown it earlier" (swell C1).
- Coverage is not gated anywhere. 1 answer has a committed coverage output (ext-01 B1). 23 report
  none or do not know of one (B1). inference refers to llm; ext-04 does not mention it.

### F12. Loosenings stay loose

- 23 answers report at least one loosening in C3. None: agentplugins, inbox, ext-04.
- 18 of the 23 say it was not tightened, or that they do not know: canon, connectors, cortex,
  entity-runtime, ess, inference, llm, runbook, slot, spindle, swell, ux-ui, ext-01, ext-02,
  ext-05, ext-06, ext-07, ext-08. 4 report one tightened again: llm, loom, entity-runtime, ext-03.

| Kind | Ids (C3) |
| --- | --- |
| A test moved to a slow lane, ignored or skipped | canon, ess, loom, runbook, spindle |
| A time or resource limit raised | codespec, ess, surf, ext-01, ext-03, ext-06, ext-07, ext-08 |
| A known-failing list, accepted failure, waiver or allowlist entry | connectors, cortex, llm, runbook, spindle, substrate, ext-02, ext-05, ext-07, ext-08 |
| A worse baseline value accepted under a decision id | runbook, slot, spindle |
| Enforcement left off or parked | cortex, entity-runtime, ess, inference |
| A test made smaller to fit a bound | inference, swell |
| A measurement exclusion | ux-ui |

- 3 answers give each exception a story reference and a review-by date (ext-02 B6, ext-05 C3,
  ext-07 B6). No answer reports a check on the date: "one row past its review date" (ext-05 C3);
  "the review-by dates exist; I have not seen one enforced" (ext-07 C3).
- Exceptions accumulate: "37+ acknowledged incompatible spec changes since the last reset"
  (cortex C3); a 27-line scan allowlist "never observed tightened" (ext-08 C3).
- 8 answers state a rule against loosening or report a refusal to loosen: connectors, inbox,
  runbook, slot, substrate, surf, ext-04, ext-05 (all C3).

### F13. Regressions are found by review and by consumers more often than by a comparison

| Noticed by | Answers | Ids (C1) |
| --- | --- | --- |
| A review after the gates were green (adversary, external, independent) | 11 | canon, codespec, cortex, ess, inference, llm, loom, runbook, spindle, ux-ui, ext-05 |
| The project's own check or fixed limit, once the change was on `main`, in a release or in a run | 9 (8 projects) | agentplugins, cortex, inbox, substrate, surf, swell, ext-02, ext-03, ext-06 |
| A consumer, a user, a manual test or a live measurement | 6 | connectors, cortex, entity-runtime, slot, ext-01, ext-07 |
| A check before merge or release | 3 | ext-04, entity-runtime, spindle |
| No regression known | 1 | ext-08 |

- cortex is in three rows, entity-runtime and spindle in two. 2 of the 3 in row 4 compare with a
  reference: the last release (ext-04 C1), a local timing A/B against the base (entity-runtime C1).
- An external review found 35 defects on `main`, 10 days after a release (codespec C1); other
  reviews found 28, 17 and 16 (cortex C1, inference C1, llm C1). A downstream repository measured
  about one third more CPU per batch; "no entity-runtime check caught it" (entity-runtime C1).
- Review results are not checks: mutants tried in a review are "not re-run later" (inbox D2).

### F14. Quality knowledge lives in prose

- All 26 answers name knowledge that no check records (D2). 15 name the agent instruction file
  as where it lives: cortex, entity-runtime, ess, llm, loom, runbook, slot, spindle, substrate,
  surf, swell, ext-03, ext-04, ext-06, ext-08 (all D2). Other places: review records (canon D2,
  codespec D2, ext-05 D2), messages between sessions (connectors D2, ext-06 D2), a consumer's
  code (ext-01 D2).
- 9 answers report a document, schema or skill that said something the code or config did not do:
  agentplugins C1, canon D3, entity-runtime B1, ess C1, llm C1, loom D3, ext-01 D1, ext-03 D1,
  ext-05 C1. A docs page said for about a month that a command does not exist (llm C1). Over 150
  code citations in a specification were wrong for weeks (ext-05 C1).
- 6 answers tie each requirement, rule or status item to a named test or scenario: canon B1,
  connectors B4, entity-runtime B1, loom B4, spindle B1, swell B4.

### F15. 8 answers test that a check can fail

- 8 answers plant a defect or test the check itself: 65 planted defects the gate must refuse
  (swell B1), 8 broken copies (ux-ui B1), a test of a test-layout check (surf B1), tests of the CI
  path classifier (slot B3, entity-runtime B3, runbook B1), 116 offline cases for a release
  workflow (substrate B3), tests of a time guard (ext-05 C2).
- 3 answers run mutants by hand, uncounted and outside the gate: inbox B1, surf B1, loom B1.

### F16. Money is a measured quantity in 6 answers

- 6 answers (5 projects) bound or record money per run or per day for runs that call a paid
  model: agentplugins B5, runbook B4, ext-02 B5, ext-03 B5, ext-06 B5, ext-07 B5. A crossed cap
  refuses or stops the run (ext-02 B5, ext-03 B5, ext-07 B5).

### F17. What "good quality" has in common (E1)

| Theme | Answers | Ids (E1) |
| --- | --- | --- |
| Documents, specification, generated files and code say the same thing | 20 | agentplugins, canon, connectors, cortex, entity-runtime, ess, inbox, llm, loom, runbook, slot, spindle, surf, swell, ext-01, ext-02, ext-03, ext-05, ext-07, ext-08 |
| The checks give a verdict in minutes | 16 | canon, codespec, cortex, entity-runtime, ess, inbox, inference, llm, loom, runbook, substrate, surf, swell, ext-02, ext-05, ext-07 |
| It says so when it cannot tell, and refuses in place of a silent downgrade | 12 (11 projects) | canon, codespec, connectors, llm, loom, runbook, spindle, substrate, ext-03, ext-06, ext-07, ext-08 |
| A release does not break a consumer without saying so | 11 | connectors, cortex, entity-runtime, ess, inference, llm, loom, substrate, swell, ext-01, ext-02 |
| The same input gives the same output | 7 (6 projects) | canon, codespec, cortex, entity-runtime, ess, ext-03, ext-06 |
| The verdict is the same locally and in CI | 7 | ess, llm, runbook, surf, ext-02, ext-05, ext-07 |
| What worked keeps working; cost does not rise | 6 | connectors, entity-runtime, swell, ux-ui, ext-04, ext-07 |
| A red check means the change is wrong | 4 | cortex, entity-runtime, inbox, ext-02 |

- 6 answers word a sentence as a comparison with an earlier state (row 7).
- What a machine cannot check (E2): 23 answers name something; ext-01, ext-04, inference do not.
  Whether a text is clear or useful to its reader (8): agentplugins, ess, inbox, llm, loom, slot,
  spindle, surf. Whether a judged result is true or right (8, 7 projects): cortex, runbook,
  ext-02, ext-03, ext-05, ext-06, ext-07, ext-08. Whether the cases cover an open input space
  (4): canon, codespec, substrate, swell. Other (3): connectors, entity-runtime, ux-ui.

### F18. The one-line rules (E4), by kind

| Kind | Answers | Ids (E4) |
| --- | --- | --- |
| Wall time of the test step or of each test, against a budget | 8 | codespec, cortex, ess, inference, runbook, substrate, ext-02, ext-08 |
| Load-independent cost against an accepted value (counters, instructions, syscalls, bytes, summed case time) | 5 | connectors, entity-runtime, inbox, surf, ext-04 |
| A count or set of cases that may not get worse (executed, skipped, passed per case) | 3 | loom, spindle, swell |
| Contract pinning (public API, answers a consumer branches on, tool versions) | 3 | llm, ext-01, agentplugins |
| Traceability (finding to regression test, citation to commit) | 2 | ux-ui, ext-05 |
| Outcome honesty at run end (credential scan, a time-out is an error) | 2 (1 project) | ext-03, ext-06 |
| Byte identity of every fixture output | 1 | canon |
| Pass rate over the last 10 runs per scenario | 1 | ext-07 |
| Operational window: 60 minutes after an install against 60 minutes before | 1 | slot |

- 13 of 26 rules are about time or cost (rows 1 and 2). 10 of the 13 measure the project's own
  test step; 3 measure the product (connectors, entity-runtime, ext-04).
- 18 rules compare with a stored accepted value (`main`, the last release, a committed file, the
  last 10 runs): canon, connectors, cortex, entity-runtime, ess, inbox, llm, loom, runbook, slot,
  spindle, substrate, surf, swell, ext-02, ext-04, ext-07, ext-08. 2 use a fixed number only:
  codespec, inference.
- 6 of the 8 wall-time rules add a comparison to the fixed budget: +10 % over the previous `main`
  run (cortex, runbook), `main`'s last green value (ess), 2x the committed value (substrate),
  +20 % over the median of the last 10 runs (ext-02), "a baseline file that only lowers" (ext-08).
- 7 rules say how a worse value may be accepted: the same commit updates the baseline (canon), a
  named exception (entity-runtime), a commit that "says why" (inbox), a changelog Breaking line
  (llm), a decision id (runbook, slot, spindle).
- When: 19 rules run on every pull request or merge, 3 in the gate on every change (inbox, surf,
  ux-ui), 4 at a release, a daily run or the end of a run (slot, ext-07, ext-03, ext-06).

## 3. Audiences (E3)

What each audience would call worse quality. One answer can appear in several rows.

| Audience | What makes quality worse | Answers | Ids (E3) |
| --- | --- | --- | --- |
| Coding agents and developers who build the project | The gate gets slower, or goes red for a reason outside the change | 20 | canon, codespec, connectors, cortex, entity-runtime, ess, inbox, inference, llm, loom, runbook, spindle, surf, swell, ux-ui, ext-02, ext-04, ext-05, ext-07, ext-08 |
| Coding agents | An error, refusal or stop that names no cause, no code and no next step | 7 | canon, connectors, cortex, ess, runbook, substrate, surf |
| Coding agents, docs readers | Instructions or documents that contradict the code or config, or are stale | 7 (6 projects) | agentplugins, ess, llm, spindle, ext-01, ext-03, ext-06 |
| Coding agents | A gate they can make green by editing the baseline | 1 | ux-ui |
| API and format consumers | A published output, type, format or contract changes or breaks, most often with no version or changelog note | 21 | canon, codespec, connectors, cortex, entity-runtime, ess, inbox, inference, llm, loom, runbook, slot, spindle, substrate, surf, swell, ext-01, ext-02, ext-05, ext-07, ext-08 |
| API consumers, end users | An operation costs more or takes longer than before | 5 | entity-runtime, slot, ext-01, ext-02, ext-04 |
| End users, including developers who use the product | The product does something wrong, or something that worked fails | 21 | canon, codespec, cortex, ess, inbox, inference, llm, loom, runbook, slot, spindle, substrate, surf, swell, ux-ui, ext-01, ext-02, ext-03, ext-04, ext-07, ext-08 |
| End users of a UI | A task takes more actions, or a needed element is out of view | 4 | agentplugins, slot, spindle, ux-ui |
| Operators | A release or upgrade needs a hand step, a restart or a migration, or cannot be verified | 7 | agentplugins, codespec, connectors, entity-runtime, slot, substrate, ext-07 |
| Operators | A run leaves something behind, or reports a state that is not true | 9 (8 projects) | cortex, inbox, runbook, slot, spindle, ext-01, ext-03, ext-06, ext-08 |
| Operators, testers | A shared environment restarts without notice, or spend per run rises | 3 | ux-ui, ext-02, ext-07 |

- All 26 answers name agents in E3, as builders of the project or as users of the product. For
  the agent as builder, the complaint is about the checks, not the product (row 1): "a gate that
  takes longer than last week or goes red on an unchanged tree" (inbox E3).
- For consumers, the complaint is the silent change: "without a version bump" (codespec E3),
  "without a changelog line" (cortex E3), "without a Breaking line" (inference E3).
- 5 answers word the end-user item as a before and after: canon, ess, runbook, spindle, swell (E3).

## 4. Implications for the design

Stated as implications. Design changes are a separate document.

1. **A duration is not comparable evidence unless its conditions are recorded.** Queue wait, run
   time and host load arrive as one number today. An assessment plan for a time measurement would
   need to say which it measures, and the evidence would need to carry the others. (F1, F2, F3)
2. **A limit hit because of the host is not a verdict about the candidate.** The design lists a
   timed-out assessor under insufficient evidence. The harder case in the answers: when the
   measurement is a duration, the timeout is both the limit and the result. (F2, F9)
3. **Counts of work are measurements projects already trust.** Instructions, syscalls, bytes and
   process starts need units, and conditions of their own: toolchain, loader, CPU. (F4, F18)
4. **Two kinds of reference exist, with different update rules.** A generated file is a reference
   the candidate may rewrite in the same change, because a generator can reproduce it. A measured
   value is one the candidate must not rewrite unchecked. "Policy from a trusted revision" fits
   the second and would refuse today's practice for the first. The decision id is the existing
   form of an authorized update. (F5, F6, F7)
5. **A protected reference fails at three points in the answers.** Adoption: a first reference
   compared with itself passes. Staleness: an improvement not written back lets a later regression
   pass. Environment: a reference holds for the image, toolchain or host that made it. (F6, F7)
6. **Comparison by identity applies beyond analyzer findings.** The design says it for findings.
   The answers say it for test cases, executed scenarios and skipped tests. (F7, F9, F18)
7. **Evidence coverage is part of the verdict.** The causes of insufficient evidence in the design
   would need four more: skipped, not run, unsupported, "ran a subset". (F9)
8. **Observe mode is where requirements stay.** A budget is left as a report or as prose while the
   measured value is over it (6 answers). The step from observed to enforced would need to be
   visible, with the time a requirement has spent unenforced. (F8)
9. **An exception needs a reason, an end date and a check on that date.** Three answers record a
   story reference and a review-by date. None checks the date. (F12)
10. **The local gate and CI are different targets.** Evidence would need to record where it was
    produced, and a gate would need to say which target class qualifies. (F10)
11. **History has to come from outside the repository.** No project stores CI duration or lead
    time. Three answers read forge run history by hand (loom B3, slot B3, runbook B3). Growth
    toward a fixed limit shows only in a series. (F11)
12. **Records must be citable, because prose will keep citing them.** Numbers are copied by hand
    into instruction files, READMEs and badges. A record that prose can point at, or that
    generates the prose block, removes the copying. (F11, F14)
13. **Some requirements have a review as their only assessor.** 11 answers report a regression
    found by a review after green gates, and 23 name something no machine can check. A review
    result tied to the revision it judged is evidence in the same sense as a report. (F13, F17)
14. **A check needs proof that it can fail.** An assessor that has never returned fail has the
    same standing as a first baseline. (F15, F7)
15. **Subjects that vary per run need repeated runs and an aggregation.** Medians, best-of-N and
    pass rates are in use or proposed. Money per run is a unit in the same plans. (F9, F16, F18)
16. **The coding agent is an audience with its own subjects:** the gate, the error text and the
    instruction file. 10 of the 26 proposed rules measure the project's own test step. This
    supports the design's "Development" and "CI and release" preset families. (F17, F18, section 3)
17. **The survey gives little for time-window evidence.** 3 of 26 answers describe a deployed
    service and 1 cites a production incident (ext-01 C1). (sections 1 and 5)

## 5. Limits of this survey

- One day, one host. All 26 answers are dated 2026-11-23 and almost all come from sessions on one
  shared workstation under load. F1 to F3 describe that machine on that day. I don't know whether
  the load was typical.
- Self-report by agent sessions. No person answered. The answers label claims "seen" or
  "inferred"; this synthesis re-checked neither kind against the repositories.
- One organization dominates. 18 of 25 projects are beyond10x repositories with shared rules: the
  test-time rule, the UI loop, the shared security gate. A count of a shared convention measures
  that organization, not 18 independent choices.
- Few deployed products: 3 answers describe a deployed service (section 1).
- `ext-03` and `ext-06` are one repository. Their figures differ in places (recall of 26/8/0 in
  ext-03 B4 against 27/7/0 in ext-06 B4). This synthesis did not reconcile them.
- inference states only what differs from llm; it is counted only where its own file says
  something. `ext-*` answers are generic by the confidentiality rule, so detail that would explain
  a number is missing.
- The questions shape the findings. Counts, and the themes in F17 and section 3, are this
  document's classification of free text, not categories the respondents chose.
- Not known from the answers: how often a false red occurs per project over a longer period; what
  the shared security gate checks (slot B1 and spindle B1 did not read it); whether older
  loosenings were later tightened (ext-08 C3: "I cannot say").
