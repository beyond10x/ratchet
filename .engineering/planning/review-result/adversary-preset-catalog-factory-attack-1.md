---
format: aep.planning-md/3
id: review-result:adversary-preset-catalog-factory-attack-1
kind: review-result
status: active
title: adversary, story:preset-catalog-factory, attack 1
relations:
- reviews: story:preset-catalog-factory
revision: 1
---
Recorded by the coordinator. The two reports of the adversary are verbatim except that the absolute paths of the workstation are replaced: `<S>` is the adversary's scratch directory, `<C>` the coordinator's directory of work files for the catalog, `<R>` the directory above it, `<W>` the worktree of the unit. The third part is the coordinator's: the adversary prepared the runs and the coordinator started them.

# Part 1: the uncommitted unit over `00a56bd`, reading only

unit: story:preset-catalog-factory, the uncommitted working tree of <W> over HEAD 00a56bd (3 edited files, 24 new files under presets/)
verdict: NEEDS-CHANGE
cases: executed 0→0, red 0
origin: introduced 16 / pre-existing 0 / undecided 2
wrote-outside-worktree: 5 paths
needs-coordinator: (1) the story says "the cache profile is a declared condition" for the slowest single test, and `test-time@1` declares none in its plan (finding 2); (2) the advisory item as the pair of advisory and package against the story's "set of dependencies" (held, your call); (3) no default limit of 120 s and 60 s against the research (finding 18); (4) whether finding 16 counts as a blocker by the letter of the brief; (5) the story's scope line on a script rule, since the unit changed no line of the script.

**No blocker found. Nothing was run: every "refused" and "accepted" below is read from `spec/presets.test.sh`, not run.** The cases line is 0→0 because part 1 starts no test. The last count that a run produced is the wave pre-flight at `791fdc4`: 227 defects, 92 copies. 70 cases are prepared for part 2.

## 1. Diff stat and status of the tree

```
 .engineering/planning/story/assessor-learns-observation.md        | 7 ++++++-
 .../planning/story/specification-answers-first-format-consumer.md | 8 +++++++-
 CHANGELOG.md                                                      | 3 +++
 presets/README.md                                                 | 6 ++++++
 website/docusaurus.config.ts                                      | 2 +-
 5 files changed, 23 insertions(+), 3 deletions(-)
```

`git status --short`: ` M` on those 5 files, `??` on 4 files under `.engineering/planning/story/` and on the 24 files under `presets/`.

- None of it is mine. I edited and created no file in the tree.
- The two modified `.engineering/` files appeared during the pass (the status at my start did not hold them). They are plan records, not my writes.
- `.ess-output/` was never created (`ls -d .ess-output`: no such file).
- `git diff --stat 00a56bd -- spec/` is empty: the script is the bytes of the base.
- I took no Worktree session lease, because the tree is read-only for me.

## 2. Cases prepared, none started

All in `<S>/`. The four scripts are POSIX sh and were parse-checked with `sh -n` only.

| Group | Cases | Expected | What it covers |
| --- | --- | --- | --- |
| A | 55 | refused | Defects in the unit's own files against rules `presets/README.md` states as checked: the six classes of the brief, plus the joins the unit is first to use (`cache_profile`, `better` from an input, a bound on `unsupported`, a list-of-path input, `queue_wait` on an output that lists boundaries, target kind `build`) |
| B | 6 | accepted | Forms no rule reaches (findings 16 and 17, and three listed under "Not checked") |
| C | 6 | accepted | The unchanged catalog, and the valid forms that would close findings 2 and 4 |
| F | 3 | refused | The script without options, with the defect in a file of the unit outside the fixed set of the copies |

`expected.txt` names per case the deciding script lines and the expected message.

## 3. Suite run

None. The build node is down and part 1 is reading only.

**Will the unit pass the script? Yes, by reading: I expect no file of the unit to be refused.** Expected last lines in part 2:

- `presets: 227 of 227 defect(s) refused with the message of their rule`
- `presets: 47 of 47 file(s) valid, 41 of 41 measurement(s) with a row, 92 of 92 broken copies refused`

What I read each of the 24 files against:

- **Bytes and names:** the only non-ASCII character is `§`, in pages only; no tab, CR, `#` or `'` in the YAML; every file ends with a line feed; the name and version of all 21 YAML files equal their file names.
- **Types:** every key is a declared field. `cache_profile` passes as a condition both declarations list (L1103-1106). `better: ${inputs.generated_better}` passes at L585-590, where a place of a closed list takes a string input.
- **Joins:** kind, unit, scope, boundary and identity key of all 15 measurements match their declarations (L1045-1091).
- **Comparisons and sampled rules:** all hold (L1139-1192; conditions at L1053).
- **Rows:** 15 rows named as the 15 measurements, 5 cells each, outside fences, one page per preset.

## 4. Findings

All cover the working tree over `00a56bd`. Every finding is backed by reading and text search; no command reproduces any of them.

### Warnings

1. **`presets/test-time@1.preset.yaml:47`, `presets/build.md:250-252`** — introduced, NEEDS-CHANGE.
   - The meaning says "so no test takes longer than the limit", and the page says the limit "holds exactly when it holds for every test". Both are false with `runs` above 1.
   - The value is the median over runs of the slowest execution per run (`:41`, `build.md:245-246`). Slowest per run 50, 55 and 300 s gives 55, which passes a limit of 60.
   - Reached by the page's own binding, `runs: 3` (`build.md:271`).
   - The page's reason for no value per test (`reference_missing` for a new test) is true of the accepted-value requirement only. `docs/design.md:306` and `:364-367` write the limit at `scope: test`.
   - Smallest change: reword the meaning and the page sentence to "the median over the runs of the slowest execution of a run", with the equivalence at `runs: 1` only. The meaning is part of the file's digest, so fix it before the file ships.

2. **`presets/test-report@1.assessor.yaml:9`** — introduced, NEEDS-CHANGE.
   - The declaration lists `cache_profile` for all three of its presets. The plans of `test-time@1` (`:31-34`) and `flake-rate@1` (`:31-33`) declare none.
   - `build.md:180-181`, `:198` and `:258` let a document hold the profile only "where the report names one".
   - By `docs/evidence-format.md:113` and `docs/design.md:774`, a condition the assessor declares and the document lacks is unknown, and the evidence does not qualify for a gate.
   - The story also says the cache profile is a declared condition for the slowest single test.
   - Smallest change: add `cache_profile: warm` to the two plans (case c03, expected accepted) and have the page say the program refuses a report without a profile; or have the page say the program always writes one.

3. **`presets/build.md:68-70`** — introduced, CONFIRMED.
   - `warm` for the test step has two alternatives: after a run of the same command, or after a build of everything the step runs.
   - With a runner that caches test results, the first replays results and the second executes the tests, so the times differ. The flake section (`:296-314`) does not say that replayed runs make every rate 0.
   - Smallest change: one alternative, and a sentence that each run executes its tests.

4. **`presets/flake-rate@1.preset.yaml:30`, `presets/build.md:311-314`** — introduced, CONFIRMED.
   - The page says the rate grows with the number of runs, and the program is not passed `runs` (`build.md:368-369`). A report with fewer runs gives a lower rate and nothing refuses it.
   - The format has `observation.min_samples` (`spec/domains/specification.yaml:467`), which `operation-time@1.preset.yaml:34` uses.
   - Smallest change: `min_samples: ${inputs.runs}` in the plan (case c02, expected accepted), with the page saying `samples` is the number of runs.

9. **`presets/artifact.md:177-178`** — introduced, CONFIRMED.
   - "A package of the project itself ... is no dependency", but the `graph` input (`:163`) holds a name, a version and the depends-on list, with no mark for a project package.
   - A vendored path dependency reads both ways, and `direct` and `transitive` differ.
   - Smallest change: say how a project package is recognised, such as a package without a source outside the tree.

11. **`presets/artifact.md:60`, `:76-77`** — introduced, CONFIRMED.
    - `platform` is "operating system and architecture". An index with two variants of one architecture matches two manifests.
    - An inspection that is one manifest names no platform, so the program takes it or refuses it.
    - Smallest change: say that a variant is part of `platform` where the index has one, and what a single manifest does.

14. **`presets/code.md:179-182`** — introduced, CONFIRMED.
    - `occurrence` orders findings on one line "from the left". A linter that reports no column leaves the order to the report, so an item can be new with no change.
    - Also open: the carriage return of a CRLF line in `line_text`; "the first line the finding points at" with a primary and a secondary location; where a file-level finding (empty text) stands among findings on blank lines.
    - Smallest change: a tie rule (report order is refused, or the message is the next key) and one sentence each for the other three.

16. **`spec/presets.test.sh:1198-1205`** — origin undecided (not run; the script equals the base), CONFIRMED.
    - `presets/README.md:113-114` says a measurement has its row "on the page of its family". The script checks that the rows of one preset stand on one page.
    - A preset with one measurement can have its row on any page. 9 of the unit's 12 presets have one measurement.
    - The header does not list this under "Not checked". Case b03 moves the row of `binary-size@1` to `build.md` and is expected accepted.
    - The unit's own rows are on the right pages. By the letter of the brief's blocker definition this could count as one; I rate it a warning because no file says which page is a preset's family page.
    - Smallest change: one line under "Not checked", or the page's preset table as the source of the family.

### Notes

5. **`presets/build.md:299-303`** — introduced, CONFIRMED. A flaky test needs an execution "that passed" and one "that failed"; an errored or aborted execution is neither or failed. Change: name the results that count as failed.
6. **`presets/build.md:56-58`** — introduced, CONFIRMED. `run_time` runs from start to exit, and "the wait ... for a build slot is outside it"; a command that queues inside itself reads both ways. Change: say the wait inside the command is in the time.
7. **`presets/build.md:247-248`** — introduced, CONFIRMED. A test ended at the runner's limit carries a plain time, while the step uses `at_least` (`:192-197`), so `lte` at the kill time can pass. Change: say so, or a lower bound.
8. **`presets/build.md:188-191`** — introduced, CONFIRMED. A run that stops at its first failed test is `not_run`, so with a fail-fast runner `flake-rate@1` is insufficient evidence whenever a flake fails. Change: one sentence in the flake section.
10. **`presets/artifact.md:79-81`** — introduced, CONFIRMED. "What a pull into an empty store transfers" contradicts `:86`, where a layer listed twice counts twice. Change: drop or qualify the gloss.
12. **`presets/artifact.md:236-237`** — introduced, CONFIRMED. "The first id the scanner reports" moves when a database reorders aliases, and two entries that are aliases of each other are one item or two. Change: a rule that does not depend on order.
13. **`presets/artifact.md:247`** — introduced, CONFIRMED. The coverage unit `package` is a name and version on `:179` and a name in the advisory identity; the count that `unchecked_packages_max` bounds differs. Change: say which.
15. **`presets/code.md:84-85`** — introduced, CONFIRMED. "Holds a directory it lies under" does not say whether `src/gen` holds `src/generated/a.rs`, or what a trailing slash does. Change: match by whole path parts.
17. **`spec/presets.test.sh:1045`** — origin undecided, CONFIRMED. No rule reads `observation.runs` against an aggregation. A literal `runs: 5` without one (`docs/design.md:88`) and `runs: 1` with one (`docs/design.md:114`) are expected accepted (b01, b02). Neither stands under "Not checked" nor in `story:preset-check-unlisted-forms`; `story:value-over-all-runs` asks the design the first half. Change: add both forms to that draft.
18. **`presets/build.md:156`, `:227`** — introduced, CONFIRMED. The limits have no default; `research/candidate-presets.md:44` and `:67` give defaults of 120 s and 60 s. The page's reason is a catalog choice, not a limit of the format, which can hold a default. Your decision.

## 5. Attacked and held

- **`better` as a reference to an input** — `docs/design.md:522` allows it; the script takes it and refuses a boolean, a list or an undeclared input there (a45-a48).
- **`flake-rate@1` sampled without aggregation at `runs` above 1** — no invariant forbids it; the page names it (`build.md` point 6) and a draft exists (`story:value-over-all-runs`). Its adoption median is over evidence records, which is coherent with `docs/design.md:572`.
- **Target kind `revision` for an image or a binary** — valid; `build` is outside the invocation contract (`artifact.md` point 4, `story:build-target-invocation`).
- **Coverage bounds** — a count a declaration does not report is 0 (`spec/domains/assessor.yaml:185-187`); the unit's bounds match its declarations anyway.
- **Story criteria** — all 15 have a measurement with the named direction and unit.
- **Tolerances** — sampled ones are required inputs without a default; counts and sets have 0 and no input; sizes have an input with default 0.
- **Advisory item as a pair** — stricter than "set of dependencies": a second advisory on an accepted package is a new item.
- **Rows against presets** — all 15 agree; "Not yet: sampled" and "0.1.0" agree with `ROADMAP.md` "Releases".
- **"Not expressible yet"** — the 14 points name types that lack what they say; the only expressible things I found are in findings 1 and 4.
- **Statements** — the three `CHANGELOG.md` lines (12 presets, 9 declarations, 5 + 10 measurements), the page list in `presets/README.md:27-32` and "eight families" in `website/docusaurus.config.ts:71` are true of the files.
- **Names** — no person, employer, customer or product name in the three pages or in my case names.
- **A script rule the unit is first to reach** — none found by reading; no mutant was possible without a run.

## 6. Paths written outside the worktree

All under `<S>/`:

- `run.sh` (the 70 cases, one line each; stops itself at 100 s)
- `time.sh` (unit against base, three alternating rounds with the load, then the check of 47 against 23 files)
- `prepare.sh` (workstation, no slot: writes `.ess-output/attack/` and the base files by `git archive 00a56bd`)
- `cleanup.sh` (workstation, no slot: removes `.ess-output/attack/`)
- `expected.txt`

No Python and no temporary probe was used.

## 7. What part 2 has to run

Budgets: no test over 60 s, the test step within 120 s, a pool job within 10 minutes. Each step starts with `cd <W> &&`.

1. `slot task check` — the gate, with the 24 new files in `check:spec` and `check:ci-paths`. Run it before step 2 or after step 5, because `.ess-output/` makes `check:spec` fail.
2. `sh <scratch>/prepare.sh` — no slot.
3. `slot sh .ess-output/attack/run.sh` — exit 0 means all 70 cases went as `expected.txt` says. A group A case with `got=accepted` is a blocker; c01 refused is a blocker.
4. `slot sh .ess-output/attack/time.sh` — item 7 of the brief; it prints the load before each run and compares with the base.
5. `sh <scratch>/cleanup.sh` — no slot; then `git status --short` shows no `.ess-output`.

Not prepared: mutants of the script (the unit changed no line of it), and the `dash` and `mawk` runs, which only the forge has.

```findings
- file: presets/test-time@1.preset.yaml
  line: 47
  category: contract-drift
  severity: warning
  verdict: NEEDS-CHANGE
  origin: introduced
  message: the meaning and presets/build.md:250-252 say no test takes longer than the limit, which is false with runs above 1 because the value is the median over runs of the slowest execution per run
- file: presets/test-report@1.assessor.yaml
  line: 9
  category: contract-drift
  severity: warning
  verdict: NEEDS-CHANGE
  origin: introduced
  message: the declaration lists cache_profile while test-time@1 and flake-rate@1 declare none and the page lets a document lack it, which docs/evidence-format.md:113 makes unknown and not qualifying
- file: presets/build.md
  line: 68
  category: judgement
  severity: warning
  verdict: CONFIRMED
  origin: introduced
  message: warm for the test step has two alternatives that give different times with a runner that caches test results, and the flake section does not exclude replayed runs
- file: presets/flake-rate@1.preset.yaml
  line: 30
  category: judgement
  severity: warning
  verdict: CONFIRMED
  origin: introduced
  message: the rate grows with the number of runs and nothing refuses a report with fewer runs than the binding names, though observation.min_samples could state the fewest
- file: presets/build.md
  line: 299
  category: judgement
  severity: note
  verdict: CONFIRMED
  origin: introduced
  message: the definition of a flaky test does not say whether an errored or aborted execution counts as failed
- file: presets/build.md
  line: 56
  category: judgement
  severity: note
  verdict: CONFIRMED
  origin: introduced
  message: run_time from start to exit and the wait for a build slot outside it read two ways for a command that queues inside itself
- file: presets/build.md
  line: 247
  category: judgement
  severity: note
  verdict: CONFIRMED
  origin: introduced
  message: a test ended at the runner's time limit carries a plain time and no lower bound, so a limit equal to the kill time can pass
- file: presets/build.md
  line: 188
  category: judgement
  severity: note
  verdict: CONFIRMED
  origin: introduced
  message: a run stopped at its first failed test is not_run, so with a fail-fast runner flake-rate@1 is insufficient evidence whenever a flake fails, and the flake section does not say so
- file: presets/artifact.md
  line: 177
  category: judgement
  severity: warning
  verdict: CONFIRMED
  origin: introduced
  message: a package of the project itself is no dependency, and the graph input carries no mark that tells one from a vendored dependency
- file: presets/artifact.md
  line: 79
  category: judgement
  severity: note
  verdict: CONFIRMED
  origin: introduced
  message: the gloss that size is what a pull into an empty store transfers contradicts line 86, where a layer listed twice counts twice
- file: presets/artifact.md
  line: 60
  category: judgement
  severity: warning
  verdict: CONFIRMED
  origin: introduced
  message: platform as operating system and architecture matches two manifests where an index holds two variants, and a single manifest names no platform
- file: presets/artifact.md
  line: 236
  category: judgement
  severity: note
  verdict: CONFIRMED
  origin: introduced
  message: the first id the scanner reports depends on the order of aliases, so an item can be new with no change
- file: presets/artifact.md
  line: 247
  category: judgement
  severity: note
  verdict: CONFIRMED
  origin: introduced
  message: the coverage unit package is a name and version on line 179 and a name in the advisory identity, so the count that unchecked_packages_max bounds has two readings
- file: presets/code.md
  line: 179
  category: judgement
  severity: warning
  verdict: CONFIRMED
  origin: introduced
  message: occurrence orders findings on one line from the left, which a linter without columns cannot give, and line_text is open for CRLF ends, secondary locations and file-level findings
- file: presets/code.md
  line: 84
  category: judgement
  severity: note
  verdict: CONFIRMED
  origin: introduced
  message: a file is generated when generated_paths holds a directory it lies under, without saying that the match is by whole path parts
- file: spec/presets.test.sh
  line: 1198
  category: boundary
  severity: warning
  verdict: CONFIRMED
  origin: undecided
  message: the one row of a preset with one measurement is accepted on the page of another family, against the README rule of a row on the page of its family, and the header does not list it as not checked
- file: spec/presets.test.sh
  line: 1045
  category: boundary
  severity: note
  verdict: CONFIRMED
  origin: undecided
  message: no rule reads a literal observation.runs against an aggregation, so runs 5 without one and runs 1 with one are accepted and neither is listed as not checked
- file: presets/build.md
  line: 156
  category: acceptance
  severity: note
  verdict: CONFIRMED
  origin: introduced
  message: the limits of test-step-time@1 and test-time@1 have no default where the research names 120 s and 60 s, and the reason given is a catalog choice and no limit of the format
```

# Part 2, step A: the committed unit `09a48ee`, reading only

unit: story:preset-catalog-factory, commit 09a48ee over base 00a56bd in <W> (27 files, `spec/` unchanged)
verdict: NEEDS-CHANGE
cases: executed 0→0, red 0
origin: introduced 6 / pre-existing 0 / undecided 1
wrote-outside-worktree: 4 paths rewritten, 1 removed (all in my scratch directory)
needs-coordinator: (1) finding 25: the script ran 79 s in job 67255 against "no test over 60 s", and the gate has no run, so the 120 s step bound is open; (2) findings 19 and 20 are two page sentences that the format does not back, your ruling whether they change before the merge or go to a story; (3) step B waits for your word.

**No blocker. Nothing was run in step A: every "refused" and "accepted" is read from `spec/presets.test.sh`, read, not run.** All 16 corrections close their findings. Seven new findings, numbered 19 to 25: two warnings on sentences the corrections added to `presets/build.md`, four notes, one warning on the run time of the script.

## 1. Tree

- `git --no-pager diff --stat`: 3 files, 16 insertions, 4 deletions, all under `.engineering/planning/story/` (`assessor-learns-observation.md`, `preset-catalog-factory.md`, `specification-answers-first-format-consumer.md`).
- `git status --short`: those 3 as ` M`, and `??` on `build-target-invocation.md`, `cache-condition-one-name.md`, `input-allowed-values.md`, `value-over-all-runs.md` in the same directory.
- None of these is mine. `.ess-output` does not exist. HEAD is 09a48ee.
- I edited no tracked file, wrote nothing under `.engineering/`, and took no Worktree lease (the tree is read-only for me).

## 2. Findings 1 to 15 and 18

| Finding | State |
| --- | --- |
| 1 | closed |
| 2 | closed |
| 3 | closed |
| 4 | closed |
| 5 | closed |
| 6 | closed |
| 7 | closed |
| 8 | closed |
| 9 | closed |
| 10 | closed |
| 11 | closed |
| 12 | closed |
| 13 | closed |
| 14 | closed |
| 15 | closed |
| 18 | closed |

Three remarks that do not reopen anything:
- **4:** the sentence added with it is finding 19.
- **12 and 15:** each leaves a residue, findings 22 and 24.
- **14:** the correction is more than needed. `occurrence` counts 1..N among findings that agree in rule, path and `line_text`, so the order never changes the identity set.

## 3. Findings of step A

**19. warning, introduced, NEEDS-CHANGE. `presets/build.md:338-340`.**
- Sentence: "The plan declares `min_samples` with the value of `runs`, so a report with fewer runs than the binding names is insufficient evidence, with the cause `too_few_samples`."
- The format names that cause for a window only: `docs/design.md:155`, `spec/domains/gate.yaml:46`, `spec/domains/evidence.yaml:68-69` ("a window with fewer items than `min_samples`").
- For another plan `spec/domains/specification.yaml:467` says only "The fewest samples that qualify."
- `too_few_samples` is one of the seven causes an assessor writes (`docs/evidence-format.md:261`, `:212`), and the program is passed neither `runs` nor `min_samples` (`docs/evidence-format.md:602`, `build.md:403-405`).
- No sentence says the gate compares `samples` of a result with `min_samples` of a `controlled_run` plan.
- Reading 1: the gate refuses with `too_few_samples`. Reading 2: nobody refuses, because the program cannot know the number and the gate has no rule; a report of 2 runs under `runs: 5` is then judged.
- Smallest change: say what the format says (evidence with fewer samples than `min_samples` does not qualify), and say under "Not expressible yet" point 5 that the program cannot write the cause because it is not passed `min_samples`.

**20. warning, introduced, NEEDS-CHANGE. `presets/build.md:264-268`, with `:278-279` and the bindings at `:214/:218`, `:288/:292`, `:359/:363`.**
- Sentence: "With `runs: 1` that is the time of the slowest execution, and `slowest-test-within-limit` then says that no test takes longer than the limit."
- The program returns the median of the runs its report holds and is not passed `runs` (`build.md:82-86`), so the sentence holds for a report of one run, not for a binding with `runs: 1`.
- The page's own examples break it: the three bindings read one report `target/test/runs.json` with `runs` 3, 1 and 5, and `:278-279` says one report serves the presets that read it.
- A project that copies the three examples gets a report of 5 runs. `test-time@1` then returns a median, the 300 s example of `:266-267` passes, and nothing refuses it.
- Smallest change: "with a report of one run" at `:264` and `:268`, and one `runs` in the three example bindings or a report of its own for `test-time@1`.

**21. note, introduced, CONFIRMED. `presets/build.md:340-341`.**
- Sentence: "A report with more runs is not refused by that: the tool of the project makes `runs` runs."
- The same page says at `:336-338` that the rate grows with the number of runs.
- A report with more runs than `runs` is judged against a value adopted from fewer, and the page names no guard.
- Smallest change: one clause that this case is not caught. It folds into the change of 19.

**22. note, introduced, CONFIRMED. `presets/artifact.md:242-247`.**
- Sentence: "two entries of a report that share an id are one advisory with the ids of both."
- Reading 1: an alias is another id of the same flaw, so the merge is safe.
- Reading 2: a bulletin id that a database lists on several flaws merges them into one item, and a flaw added later under that bulletin is no new item unless its own id sorts first.
- Two honest programs differ in the number of items.
- Smallest change: say an alias is an id of the same flaw, and that an id which covers several flaws is not used to merge.

**23. note, introduced, CONFIRMED. `presets/code.md:193-195`.**
- Sentence: "Where the linter marks none, it stands at the location with the lowest line in the file the finding is reported for."
- With several locations in several files and none primary, "the file the finding is reported for" is the first listed location's file (reading 1) or undetermined (reading 2).
- `path` is part of the identity key, so the two readings give different items.
- Smallest change: one tie rule, such as the first path by bytes, then the lowest line.

**24. note, introduced, CONFIRMED. `presets/code.md:85-87`.**
- Sentence: "it is compared by whole parts between `/`".
- Not said: whether `./src/gen` is `src/gen`, whether `.` names the whole tree, and what a `..` part is.
- Reading 1 normalises; reading 2 compares parts literally, so `./src/gen` holds nothing.
- The two programs differ in the generated and hand-written counts.
- Smallest change: one sentence that a leading `./` is dropped, and that `.` and `..` parts are refused or compared literally.

**25. warning, undecided, NEEDS-CHANGE, needs-coordinator. `spec/presets.test.sh` (whole script).**
- Job 67255 ran the script for 79 s (`<C>/scratch-factory/task2-script.log`, `waited 59s for a build slot, ran 79s`). The bound is no test over 60 s.
- Earlier runs on the other node were 3 to 14 s. The unit changed no line of the script and adds 24 files to the one check of the whole directory; the 92 copies hold a fixed set of 8 files (L1299).
- So the rise is more likely the host under load than the unit. I cannot decide that by reading, and the brief forbids a timing run.
- The gate has no run (job 67264 was cancelled), so the 120 s step bound is open too.
- This is your log, not a run of mine. It relates to `story:preset-check-one-start`.
- Smallest change: read `ran <n>s` of the script in the gate run of step B. If it is over 60 s again, it is a budget defect with its own story before the next feature.

## 4. Attacked and held

- **`at_least` (§ 4, rule 6):** `docs/evidence-format.md:204` says it appears only on an incomplete result. A killed test's run came to its end, so a plain value is right.
- **`coverage_below_plan` for a fail-fast runner:** `build.md:346-350` agrees with `docs/evidence-format.md:272`.
- **"unknown and does not qualify" (§ 3):** `docs/evidence-format.md:113`.
- **`min_samples` beside `runs` without an aggregation:** valid. `spec/domains/specification.yaml:445-449` constrains a time window only, and `docs/design.md:249` has `min_samples` on a `controlled_run` plan. `samples` as the number of runs agrees with `docs/evidence-format.md:158`.
- **`default: 120` on a `decimal` input:** a valid literal (L621 takes an integer or a float literal), and job 67255 exited 0 on the committed files.
- **A limit on a sampled measurement without a band:** the design's own form, `docs/design.md:364-367`.
- **Rows:** `step-time` (`build.md:169`), `slowest-test` (`:240`) and `flake-rate` (`:312`) agree with their presets.
- **`CHANGELOG.md`:** the three lines under `## [Unreleased]` are true of the files, the third with the defaults 120 s and 60 s.
- **`presets/README.md`:** § "Tolerance" (lines 96-101), lines 59-60 and line 196 stay true with the two defaults.
- **Second-tool definitions:** I found no two readings for the roots of a graph, the variant and single manifest, the coverage unit `package`, the order on one line, the results that count as failed, or a wait inside a command.

## 5. Cases: 70 before, 77 now

A has 61, B has 10, C has 6, F has none.

**Changed**
- a01, a02: also drop `cache_profile: warm`, which is new in the plans.
- a55: the pattern names the place (`observation.runs`), since `min_samples` reads the same input now.
- a37: renamed, and judged by the line of `cold-build-time@1`.

**Replaced** (the old forms are the committed files)
- c02: `flake-rate@1` without `min_samples`, expected accepted.
- c03: `default: 120.0`, expected accepted.

**Removed**
- f01, f02, f03: three starts of the whole script, 79 s each in the pool. Reading covers them: the run without options calls the same `check_catalog` (L1255-1262) as `--catalog` (L1242-1250). Read, not run.
- `time.sh` and its section in `expected.txt`.

**Added, expected refused**
- a56: the `limit_s` input line dropped while `value: ${inputs.limit_s}` stays (L571-572).
- a57: `default: fast` on the decimal input (L968-974, L621).
- a58: `limit_s` without `required` (L542-549).
- a59: `min_samples: ${inputs.tolerance}` (L586, L590).
- a60: `min_samples: all` (L527).
- a61: `test-report@1` with `conditions: []` (L1103-1106).

**Added, expected accepted**
- b07: `cache_profile: warm` dropped from `test-time@1` again. No rule keeps correction 4 in place; only the page does.
- b08: literals `runs: 3` and `min_samples: 5`.
- b09: `required: true` beside `default: 120`.
- b10: `limit_s` with `required: false` and no default.
- b08, b09 and b10 are forms for `story:preset-check-unlisted-forms`, not findings against the unit.

**Runner**
- `run.sh` now packs defects of different files into one copy: 13 starts with `--catalog` for the 77 cases.
- A case whose line is missing in its shared copy is judged again alone, and that result counts.
- It still prints one line per case and stops itself after 240 s.
- `prepare.sh` copies `run.sh` only: no base tree, no `git archive`.
- `sh -n` passes on `run.sh`, `prepare.sh` and `cleanup.sh`. All 77 ids are defined once and listed once.

## 6. Step B commands, on your word only

Run them in this order. The gate comes first, because `.ess-output` in the tree makes `task check:spec` fail.

1. Gate:
   `cd <W> && slot env PATH=<R>/tools/ess-dl/ess-0.98.0-x86_64-unknown-linux-gnu:$PATH task check`
2. Prepare, no slot:
   `cd <W> && sh <S>/prepare.sh`
3. The cases, once:
   `cd <W> && slot sh .ess-output/attack/run.sh > <S>/run.out 2>&1`
4. Cleanup, no slot, also when step 3 failed or was killed:
   `cd <W> && sh <S>/cleanup.sh`

- Exit codes of step 3: 0 all as expected, 1 at least one case differs, 3 stopped itself at 240 s, 2 not started from the tree root.
- I need back: `run.out`, the `ran <n>s` line of the gate and of step 3, and the gate's ten slowest tests.
- Bounds: test step within 120 s, no test over 60 s, a pool job ended after 10 minutes. No Python. `prepare.sh` and `cleanup.sh` only copy and remove, so they start without `slot`.

## 7. Paths written

All in `<S>/`:
- `run.sh` (rewritten)
- `expected.txt` (rewritten)
- `prepare.sh` (rewritten)
- `cleanup.sh` (header updated)
- `time.sh` (removed)

```findings
- file: presets/build.md
  line: 338
  category: contract-drift
  severity: warning
  verdict: NEEDS-CHANGE
  origin: introduced
  message: the page says a report with fewer runs than min_samples is insufficient evidence with the cause too_few_samples; the format names that cause for a time window only, the program is passed neither runs nor min_samples, and no sentence says the gate compares samples with min_samples on a controlled_run plan
- file: presets/build.md
  line: 264
  category: contract-drift
  severity: warning
  verdict: NEEDS-CHANGE
  origin: introduced
  message: "with runs 1 no test takes longer than the limit" holds for a report of one run only; the program returns the median of the runs its report holds, and the three example bindings read one report with runs 3, 1 and 5
- file: presets/build.md
  line: 340
  category: contract-drift
  severity: note
  verdict: CONFIRMED
  origin: introduced
  message: a report with more runs than the binding names is not refused although the page says the rate grows with the number of runs; no guard is named
- file: presets/artifact.md
  line: 245
  category: ambiguity
  severity: note
  verdict: CONFIRMED
  origin: introduced
  message: merging entries that share an id has two readings where one id covers several flaws; two programs return different numbers of items
- file: presets/code.md
  line: 193
  category: ambiguity
  severity: note
  verdict: CONFIRMED
  origin: introduced
  message: a finding with several locations in several files and no primary one has no determined path; "the file the finding is reported for" has two readings and path is part of the identity
- file: presets/code.md
  line: 85
  category: ambiguity
  severity: note
  verdict: CONFIRMED
  origin: introduced
  message: whole path parts for generated_paths do not say whether a leading ./ is dropped or what . and .. parts are; two programs differ in the generated and hand-written counts
- file: spec/presets.test.sh
  line: 1
  category: test-budget
  severity: warning
  verdict: NEEDS-CHANGE
  origin: undecided
  message: the script ran 79 s in pool job 67255 against the bound of 60 s per test; the unit changed no line of it and adds 24 files to one check, the gate has no run, and the cause cannot be decided by reading
```

# Part 2, step B: the runs, started by the coordinator on `dd2cba5`

`dd2cba5` holds the corrections of findings 19 to 24 over `09a48ee`: three pages, no preset
and no declaration.

- The gate: `slot task check` in the pool of the workstation, with the release 0.98.0 of
  `ess` that `spec/ess-inputs.yaml` pins first in `PATH`, exit 0, 16:52 CET. Its lines of the
  preset check: `presets: 227 of 227 defect(s) refused with the message of their rule` and `presets: 47 of 47 file(s) valid, 41 of 41 measurement(s) with a row, 92 of 92 broken copies refused`. The whole gate took 45 s of wall time at a load of 2 to 5.
- The adversary's runner, one job, 13 starts of the script with `--catalog` for 77 cases,
  1 s: exit 0, 0 cases not as expected. The 61 defects of group A are refused, each by a line
  that names its file and the words of its rule. The 10 forms of group B and the 6 valid
  forms of group C are accepted, as expected.
- A first start of the same job did not run its cases: the pool sent it to a build node, and
  the runner stands in an ignored directory that the sync to a node does not carry
  (`sh: .ess-output/attack/run.sh: No such file or directory`, exit 127).
- Finding 25: the 79 s of the preset check in one earlier job fell into minutes in which the
  pool had no free slot. In the gate above the check ran inside 45 s for the whole gate.
- Not run: the timing loop of part 1 against the base commit (the pool of the workstation
  takes no run that is repeated to time it); mutants of the script (the unit changed no line
  of it); `dash` and `mawk`, which only the forge has.
