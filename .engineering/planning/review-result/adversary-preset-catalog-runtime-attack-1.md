---
format: aep.planning-md/3
id: review-result:adversary-preset-catalog-runtime-attack-1
kind: review-result
status: active
title: adversary, story:preset-catalog-runtime, attack 1
relations:
- reviews: story:preset-catalog-runtime
revision: 1
---
Recorded by the coordinator from the adversary's report, verbatim except that the absolute paths of the workstation are replaced: `<S>` is the adversary's scratch directory, `<W>` the worktree of the unit.

unit: story:preset-catalog-runtime at e6518eb (base 90924c9), tree <W>
verdict: NEEDS-CHANGE
cases: executed 220→220 in the suite (no tracked file changed); 59 probe cases in scratch (57 catalog copies, 2 script mutants), red 14
origin: introduced 8 / pre-existing 3 / undecided 0
wrote-outside-worktree: 14 files, all under <S>/
needs-coordinator: none to decide. One fact for the brief: a directory `.ess-output/` in the tree turns `task check:spec` red (see "Suite run").

There is no blocker. Every file of the unit is a valid document of its format as far as the script and my reading go, every criterion of the story has a measurement in the named direction, no broken copy passed against a rule `presets/README.md` states as checked (40 of 40 refused with the rule's message), `task check:spec` is green, and the step is far under its budget.

## Diff and status of the tree (after cleanup)

`git --no-pager diff --stat`: empty. `git status --short`: empty. HEAD is e6518eb. `.ess-output/attack/` is removed, and `.ess-output/` with it (it held nothing else). Lease `adversary-runtime-1` released (exit 0).

## Cases added (scratch only) and the red output

Runner: `<S>/run.sh` (POSIX sh, temporary probe). Reproduce: copy `run.sh`, `base/` and `future/` into `<tree>/.ess-output/attack/`, then `cd <tree> && slot sh .ess-output/attack/run.sh` (exit 0; output in `run-1.out`). Each case ran under the unit's script and under the base script (`base=` column).

- Group A, 40 defects in the unit's files against rules README states as checked: 40 refused with the message of the rule, base the same.
- Group C: 5 files of a later build and artifact family (local-free inputs, declared condition, conditions per class with tool pin and load bound, multi-line flow maps, `runs: 1` without aggregation, pass rate with `gte`, tolerance percent plus absolute, target kind from an input default, `adoption: {from: same_change}`, `filter` from a list input) accepted: `presets: 28 of 28 file(s) valid, 33 of 33 measurement(s) with a row`.
- Group F: the run without options in a tree whose defect lies in a file outside the set exits 1 with the rule's message (row of `event-time@1/events/delay` removed; boundary of `start-time@1` not declared).
- Group B, red, 13 of 13 accepted by the unit's script and by the base script, each with `presets: 23 of 23 file(s) valid, 26 of 26 measurement(s) with a row`:
  b01 sampled accepted value without tolerance; b02 without adoption; b03 sampled plan without conditions; b04 percentile without parameter; b05 exact set with `aggregation: {kind: median}`; b06 duration without boundary; b07 set without identity; b08 `adoption: {from: trusted_revision}` without runs; b09 `tolerance: {}`; b10 input required with a default; b11 input neither required nor with a default; b12 declaration input named `out`; b14 percentile parameter 250.
- Mutants: m01 (options line compared with `$summary`) killed; m02 (comparison at `spec/presets.test.sh:1563` removed) survived: `presets: 23 of 23 file(s) valid, 26 of 26 measurement(s) with a row, 90 of 90 broken copies refused`.

## Suite run, verbatim

`cd <tree> && slot sh .ess-output/attack/time.sh`, three jobs (each exit 0), node build-1d, 32 CPUs:

```
node: ... cpus=32 load-before=25.24 27.42 33.89
script: exit=0 wall=6124 ms load-after=26.11 27.57 33.90
presets: 220 of 220 defect(s) refused with the message of their rule
presets: 23 of 23 file(s) valid, 26 of 26 measurement(s) with a row, 90 of 90 broken copies refused
part: check of presets/ alone (--catalog presets): exit=0 wall=56 ms
node: ... cpus=32 load-before=29.78 28.31 34.10
script: exit=0 wall=7216 ms load-after=29.88 28.35 34.09   (same two last lines; part 133 ms)
node: ... cpus=32 load-before=31.57 28.73 34.18
script: exit=0 wall=13693 ms load-after=37.00 30.01 34.54  (same two last lines; part 55 ms)
```

`cd <tree> && slot task check:spec`:
- with `.ess-output/attack/` present: exit 201, every script green, last step red: `error: output root is beneath enrolled or reserved ancestor <W>; use its existing ownership root` / `check:spec: ess generate synthesize --target rust did not emit the specification`. This is the probe directory, not the unit.
- after removing it: exit 0, `gate-inputs: 10 of 10 broken inputs refused`, the two `presets:` lines as above, `214 capabilities: 214 generated, 0 obligation(s), 0 refused`.

`slot task check` (whole gate) was not run by me.

## Findings

| # | Severity | Verdict | Origin | file:line | Finding |
|---|---|---|---|---|---|
| 1 | warning | NEEDS-CHANGE | introduced | presets/event-time@1.preset.yaml:15 | The input `percentile` never reaches the program |
| 2 | warning | CONFIRMED | introduced | presets/latency.md:262 | `runs` and `min_samples` reach no program, and `runs` of the two percentile presets is in no evidence |
| 3 | warning | NEEDS-CHANGE | introduced | presets/operability.md:63 | "name of a metric" has two readings; 0.1.0 judges this set |
| 4 | warning | CONFIRMED | introduced | presets/latency.md:69 | Percentile method and start of a request undefined |
| 5 | warning | CONFIRMED | introduced | presets/resources.md:72 | Four resource definitions with two readings |
| 6 | warning | CONFIRMED | introduced | presets/start.md:62 | Start moment, readiness poll and first request undefined; "run" used two ways |
| 7 | warning | CONFIRMED | introduced | spec/presets.test.sh:100 | Three `ratchet validate` rules for sampled measurements are neither checked nor listed as not checked |
| 8 | note | CONFIRMED | pre-existing | spec/presets.test.sh:100 | Further defects of the design accepted and not listed |
| 9 | note | CONFIRMED | pre-existing | spec/presets.test.sh:1264 | The script takes over 5 s on a node under its CPU count |
| 10 | note | CONFIRMED | pre-existing | spec/presets.test.sh:1563 | No case proves the comparison of the options line |
| 11 | note | CONFIRMED | introduced | presets/latency.md:88 | "No paired run" gives one reason and leaves out the one the format states |

1. `presets/event-time@1.preset.yaml:15` declares `percentile` (default 95) and `:44` uses it as the parameter of the aggregation. `presets/timing-report@1.assessor.yaml:6-8` declares only `report` and `workload`, and the program is passed only declared inputs (`docs/evidence-format.md:611`). The program aggregates (`docs/evidence-format.md:598`), and a measurement reads the result whose aggregation is its own (`:211`). `presets/latency.md:62` says "one result per operation, boundary and aggregation" and names no aggregation. A binding with `percentile: 90` (`latency.md:164-165` invites it) finds no result unless the program happens to return p90 for the event boundary. Command: `grep -n percentile presets/event-time@1.preset.yaml presets/timing-report@1.assessor.yaml` gives lines 15 and 44 of the preset and none of the declaration (exit 0). Smallest change: state on the page which percentiles the program returns per boundary, or drop the input and fix 95.

2. `docs/evidence-format.md:602` says the contract "does not say how an assessor learns the observation of a plan (`scenarios`, `workload`, `command`, `runs`, `min_samples`)". `presets/latency.md:262-268` ("Not expressible yet", point 6) names the workload alone. Yet the pages say "the median of the `runs` runs" (`latency.md:205`, `resources.md:81`, `start.md:67`), which the program cannot know. For `operation-time@1` and `event-time@1`, `samples` counts requests (`latency.md:71`), so the plan's `runs` appears in no record, against `docs/design.md:87` ("The evidence carries the count"): a report of one run with 200 requests satisfies a plan with `runs: 3`. Judgement from reading; the greps are in the sentence. Smallest change: extend point 6 to `runs` and `min_samples`, and say that for a percentile no record carries the number of runs.

3. `presets/operability.md:63-64`: "A name is the name of a metric without its labels". Reading A: the sample name of the scrape (`orders_created_total`, `request_duration_bucket`, `_sum`, `_count`). Reading B: the name of the metric family (`orders_created`, `request_duration`). The page names no scrape format (`grep -n -i -E 'prometheus|openmetrics|exposition|histogram|_bucket|suffix' presets/operability.md` finds nothing but the word "family" of the title, exit 0). Two honest programs return different sets for one scrape, and an accepted set from one fails `no_lost_items` under the other. Also `operability.md:129-130`: "the requirement on that endpoint then holds for no item" reads as passes vacuously or as does not pass. Smallest change: one sentence that fixes the reading (the name as it stands on a sample line, or the family name), and one that says what the requirement returns with no item.

4. `presets/latency.md:69-71`: no percentile method (`grep -n -i -E 'nearest|interpolat|rank' presets/*.md docs/design.md docs/evidence-format.md` finds one unrelated line, exit 0). Nearest rank and linear interpolation differ for p99 of 200 samples; the median of an even count likewise. `latency.md:65-66`: "starts to send the request" with or without connection setup. `latency.md:67-68`: which event counts when a request causes several. Smallest change: name the method (nearest rank) and say whether connection setup is inside.

5. `presets/resources.md:72-73` "the processes that process starts": children or all descendants. `:75-76` "second half of a run": by time or by number of readings. `:77-79` CPU time of a process that ended between two readings is in or out; "number of requests it answered" counts every answer, while throughput counts those "answered as the workload expects" (`latency.md:72-73`). Smallest change: one clause each.

6. `presets/start.md:62-64`: the start of the process (the call that starts it, or the start time the kernel records) and the interval of the readiness poll are not named; `resources.md:89` has such a sentence for its interval, `start.md` has none. `:65-66` with `:23-24`: `ready_to_first_answer` includes the gap until the client sends its first request, which is the tool's. `:22-23` "A run of this plan is one start" against `:33` and `:67` (`runs` is the number of starts, median of the `runs` starts): with `docs/evidence-format.md:611` ("once per run of a plan") one reader invokes the program once per start, another once over a report of all starts. Smallest change: call the unit "a start" throughout and say the program reads all starts of one report.

7. `docs/design.md:92`, `:182`, `:574`: `ratchet validate` reports a sampled measurement with no conditions, one with an accepted value and no tolerance, one with no `adoption`; `:572` "N has no default". Cases b01, b02, b03, b08 are accepted. The base catalog holds no sampled measurement (`grep -c 'kind: sampled'` gives 0 for the three functional presets); the unit adds 12 in 5 presets, so nothing reached these rules before. The header's "Not checked" list (`spec/presets.test.sh:100-123`) does not name them, while `presets/README.md:149-150` says the header says what it does not check. Smallest change: a line in "Not checked" with the reason, or the three rules with one case each.

8. b05 (`docs/design.md:88`, exact: "None, or a sum"), b12 (reserved argument names, `docs/evidence-format.md` § 10) accepted, base the same. b04, b06, b07, b09, b10, b11, b14 are accepted too; I found no sentence of the design that forbids them outright, so they are listed as observed, not as defects. Smallest change: as for 7.

9. Brief's criterion: over 5 s under a load below the CPU count. 6.1 s at 25.2, 7.2 s at 29.8, 13.7 s at 31.6 (rising to 37.0) of 32. Parts: the check of the whole `presets/` takes 55 to 133 ms (20 in a row: 1718 ms); the rest is the harness cases and the 90 copies. Head against base, in turn, in trees of their own (`slot sh .ess-output/attack/time2.sh`, exit 0, load 36): head 4264, 3531, 4859 ms; base 3107, 4331, 3173 ms. The unit did not add a copy; the time is the base script's. The spread does not follow the load figure. Smallest change: none inside this unit; fewer `sh "$self"` starts per copy would be a script story.

10. With the comparison `[ "$(cat "$c.options")" = "$set_summary" ]` removed the script still ends green: no harness case makes the run with `--catalog` and `--spec` print another line. The base has the same construct (`90924c9:spec/presets.test.sh:1511`). Smallest change: one harness case, or leave it.

11. `presets/latency.md:88` says a paired run "needs a program that builds two revisions, and a report holds one". True. `docs/evidence-format.md:596` also lists a paired run as not in version 1 (no field for the second value), which is the stronger reason and is not cited. Smallest change: one clause.

## Attacked and held

- Each `${inputs.<name>}` fits its place by type; every declared input of every preset is referred to; no preset holds a `statements:` map it would need.
- Declarations: identity key only with an identity set, no reserved input name, no document target.
- Story criteria per family: each has a measurement with the named direction and unit; no sampled measurement has a default tolerance; `workload`, `runs`, tolerance and `adoption_runs` are required inputs; `operation-time@1` against `research/candidate-presets.md` § 3.8.
- Rows against presets (direction, unit, tolerance input, evidence) on the four pages; all relative links resolve.
- "Judged by a release" marks against `ROADMAP.md` § Releases: metric names by 0.1.0, assertions and sampled values not yet.
- Each "Not expressible yet" entry names a type that lacks what it says; nothing listed is expressible, apart from the gap of finding 2.
- `presets/README.md` page list, `spec/README.md` item 10 and its count sentences, `AGENTS.md:64`, `CHANGELOG.md` `## [Unreleased]` (7 presets, 5 declarations, four families), the site lede (five families) against the files and the script's last lines (220 defects, 23 files, 26 measurements, 90 copies; pinned line 7 of 7 and 10 of 10).
- The set of files of a copy: a defect in a file outside the set is caught by the whole-catalog check (group F); a later family's valid files are accepted (group C).

## Paths written outside the worktree

All under `<S>/`:
`run.sh`, `time.sh`, `time2.sh` (temporary probes, POSIX sh), `run-1.out`, `time-1.out`, `time-2.out`, `check-spec.out`, `check-spec-2.out`, `base/spec/presets.test.sh`, `future/command-timing@1.assessor.yaml`, `future/test-time@1.preset.yaml`, `future/image-report@1.assessor.yaml`, `future/image-size@1.preset.yaml`, `future/factory.md`.

Inside the tree, ignored and removed again: `.ess-output/attack/` (and the then empty `.ess-output/`). No Python was written.

```findings
- file: presets/event-time@1.preset.yaml
  line: 15
  category: contract-drift
  severity: warning
  verdict: NEEDS-CHANGE
  origin: introduced
  message: the input percentile sets the aggregation of the measurement but is not an input of timing-report@1, so a binding with another value than the program's own percentile finds no result
- file: presets/latency.md
  line: 262
  category: judgement
  severity: warning
  verdict: CONFIRMED
  origin: introduced
  message: the page names the workload as the one input the program does not learn, but runs and min_samples reach no program either, and runs of the two percentile presets is in no evidence
- file: presets/operability.md
  line: 63
  category: judgement
  severity: warning
  verdict: NEEDS-CHANGE
  origin: introduced
  message: the name of a metric reads as the sample name or as the family name and no scrape format is named, so two programs return different sets for the one criterion 0.1.0 judges
- file: presets/latency.md
  line: 69
  category: judgement
  severity: warning
  verdict: CONFIRMED
  origin: introduced
  message: no percentile method is defined, and the start of a request and the event of a request with several events have two readings
- file: presets/resources.md
  line: 72
  category: judgement
  severity: warning
  verdict: CONFIRMED
  origin: introduced
  message: the processes a reading covers, the second half of a run, the CPU time of ended processes and the requests that count each have two readings
- file: presets/start.md
  line: 62
  category: judgement
  severity: warning
  verdict: CONFIRMED
  origin: introduced
  message: the start moment of the process, the readiness poll and the gap to the first request are not defined, and a run means one start in one sentence and the runs input counts starts in another
- file: spec/presets.test.sh
  line: 100
  category: boundary
  severity: warning
  verdict: CONFIRMED
  origin: introduced
  message: a sampled measurement without conditions, without tolerance, without adoption and an adoption without runs are accepted and not named under Not checked, and the unit brings the first 12 sampled measurements
- file: spec/presets.test.sh
  line: 100
  category: boundary
  severity: note
  verdict: CONFIRMED
  origin: pre-existing
  message: an exact set with a median and a declaration input with a reserved argument name are accepted by the script of the unit and of the base and not named under Not checked
- file: spec/presets.test.sh
  line: 1264
  category: property
  severity: note
  verdict: CONFIRMED
  origin: pre-existing
  message: the script ran 6.1, 7.2 and 13.7 s on a 32 CPU node under load 25 to 32, of which the check of the whole catalog is about 0.1 s and the 90 copies the rest, and the base script takes the same time
- file: spec/presets.test.sh
  line: 1563
  category: mutant
  severity: note
  verdict: CONFIRMED
  origin: pre-existing
  message: the script stays green when the comparison of the line printed with --catalog and --spec is removed
- file: presets/latency.md
  line: 88
  category: judgement
  severity: note
  verdict: CONFIRMED
  origin: introduced
  message: the reason given for no paired run leaves out that the evidence format lists a paired run as not in version 1
```

`.ess-output/attack/` is removed from the tree.
