# Examples

Worked `ratchet/1` specifications for the first milestone of [`vision.md`](../vision.md), in the
shapes of [`docs/design.md`](../docs/design.md) revision 3. They were first written against
revision 2, and the gaps found then are listed
[below](#gaps-of-revision-2-and-how-revision-3-closed-them).
Design-phase documents: nothing here runs, and no tool has validated them beyond YAML, TOML and JSON
syntax.

How to read them:

- Every key is one that `docs/design.md` revision 3 shows or names in §§ 3 to 5. The key names are
  proposals, as that document says. Where an example needed a key the design does not have, the key
  is left out and the case is listed under [New gaps](#new-gaps).
- Some values are not shown in the design. They are listed under
  [Values not shown in the design](#values-not-shown-in-the-design).
- Every number comes from a survey answer. `ux-ui B5` means
  [`research/responses/ux-ui.md`](../research/responses/ux-ui.md), question B5. `F5` is a finding in
  [`research/synthesis.md`](../research/synthesis.md), `gap 2` is a gap in
  [`research/consumer-input-ux-ui.md`](../research/consumer-input-ux-ui.md), `§ 5` is a section of
  `docs/design.md`. Numbers without a source are listed at the end.
- Project names, ids, paths, commands, rule names, runner labels and reason texts are illustrative
  unless a source names them. Each project name is neutral: an example is built from the answers
  named, and is not the specification of any one repository.
- An accepted value is not in a specification file (§ 3). Where an example has one, this page says
  what its reference record would hold.
- D1 to D4 of § 9 are decided, all A (the owner, 2026-11-24; `docs/design.md` § 9). [Where they matter](#decisions-d1-to-d4) says
  which example uses which.

| File | Integration (`vision.md`) | Audience | Main sources |
| --- | --- | --- | --- |
| [`ess-ui-behavior.ratchet.yaml`](ess-ui-behavior.ratchet.yaml) | ESS UI behavior | end users of a page | ux-ui, consumer input |
| [`ci-turnaround.ratchet.yaml`](ci-turnaround.ratchet.yaml) | CI turnaround | coding agents, developers | slot, ext-02 |
| [`analyzer-findings.ratchet.yaml`](analyzer-findings.ratchet.yaml) | no new analyzer findings | developers, coding agents, API consumers | runbook, substrate, ext-07, ext-02 |
| [`generated-artifact.ratchet.yaml`](generated-artifact.ratchet.yaml) | generated artifact by digest | developers, coding agents, docs readers | canon, runbook |
| [`host-caused-limit.ratchet.yaml`](host-caused-limit.ratchet.yaml) | insufficient evidence on a host-caused limit | coding agents, developers | swell |
| [`ratchet.toml`](ratchet.toml) | local config (§ 5) | one checkout | swell |

## 1. ESS UI behavior

[`ess-ui-behavior.ratchet.yaml`](ess-ui-behavior.ratchet.yaml)

**Checks.** Two plans on one page, in the local gate:

- `keyboard-task-completion` imports an ESS UI result for the keyboard-only scenario and enforces
  an assertion with `holds`: every task completes.
- `walks` imports one `ux-eval@1` report for all 30 walks, matched by a scenario pattern. Five
  measurements read that one run: steps and layout shift against accepted values, actions per fix
  and cue accuracy against fixed limits, and page-scoped findings of two severities compared by
  identity against an accepted set.

**Audience.** End users of the page. ux-ui E3: "a task takes more clicks or a control drops below
the fold".

**Sources.**

| In the file | Source |
| --- | --- |
| every task completes (`completion_miss` = 0) | ux-ui B5 |
| `not_run: 0` on the completion plan | ux-ui C1 (2 of 3 sub-tasks never done, counted as no miss) |
| 30 walks, 14 metrics each, in one run | ux-ui B4 |
| steps, tolerance 5 % | ux-ui B5 |
| layout shift, tolerance 0.01 | ux-ui B5; spindle B5; slot B5 |
| layout shift within 500 ms after a scripted action excluded | ux-ui C3 |
| at most 2 actions per fix | ux-ui B5 |
| cue accuracy at least 95 % | ux-ui B5 |
| serious and critical findings | ux-ui B4, B5 |
| findings scoped to the page | gap 2; ux-ui D3 (one defect counted 12 times) |
| identity `rule`, `node_path`, `environment` | gap 4; § 4 |
| scenario `keyboard-only` | ux-ui C1 |
| local gate only | ux-ui B3 (no CI, no remote), E4 |

**Reference records (not in the file).** `no-new-page-findings`: the 12 findings filed in the round
(ux-ui B4), adopted from observe-mode evidence. `steps-do-not-rise` and
`layout-shift-does-not-rise`: one value per walk. The answer gives no values.

**Trade-off record (not in the file).** The round's change to in-page navigation moved one value
from 23 to 0 and made 20 of 168 worse: one more click per task, 12 Tab stops (gap 1). As
`ratchet/trade-offs/in-page-navigation.json` (D1):

```json
{
  "format": "ratchet-trade-off/1",
  "id": "in-page-navigation",
  "reason": "<why the gain is worth the loss>",
  "owner": "decision:in-page-navigation",
  "gains": [
    {"requirement": "<requirement of the key that moved>", "item": "<walk>", "from": "23", "to": "0"}
  ],
  "loosens": [
    {"requirement": "steps-do-not-rise", "item": "ess-ui:explainer-page/keyboard-only", "from": "<old>", "to": "<new>"}
  ]
}
```

`loosens` has 20 entries, and one is shown. Gap 1 names neither the key that moved from 23 to 0 nor
the 20 old and new values, so they are placeholders. A gain needs the requirement of its key (§ 5).
One reference change per loosened requirement names the trade-off.

**Expected verdicts.**

- First run: `steps-do-not-rise`, `layout-shift-does-not-rise` and `no-new-page-findings` return
  insufficient evidence with the cause `reference_missing` (§ 5 rule 3). In the round the baseline
  was written from the round's own walks and the first pass "compared a value with itself"
  (ux-ui B6).
- The round measured 20 of 74 gating tests red and filed 12 findings (ux-ui B4). The first adoption
  of those 12 is a change of its own, merged before a candidate is judged by them (D2).
- A sub-task that is never done is reported as not run. `not_run: 0` then makes that run
  insufficient evidence with the cause `coverage_below_plan`, not a held assertion.
- The pattern matches 29 walks after one is deleted: `executed: 30` fails the same way.

**Left out.**

- The other metrics of the 14 per walk. Each is one more entry of `measurements`; the answer names
  `false_complete`, no-scroll and always-visible among them (ux-ui B5).
- The keys of the trade-off, as said above.
- What `executed: 30` counts when the measurements of one plan have two scopes (G29).

## 2. CI turnaround

[`ci-turnaround.ratchet.yaml`](ci-turnaround.ratchet.yaml)

**Checks.**

- `ci-gate-timing` reads one finished run of the gate workflow and gives two measurements: run time
  and queue wait.
- Run time has a fixed limit and an accepted value. It is judged in `workflow-finished`, a gate
  that a job evaluates after the workflow has ended (§ 7, second placement). A gate inside the
  workflow cannot read that workflow's total time.
- Queue wait is judged in `build-pool`, an operational gate. It decides nothing about a candidate.
- The UI test step and the Rust test step end before `ratchet evaluate` and stay in the pre-merge
  gate (§ 7, first placement), the Rust step in report mode.
- The run time of the local gate has no requirement, so it is in observe mode.

**Audience.** Coding agents and developers who wait for the verdict (F3: the top cost in 24 of 26
answers).

**Sources.**

| In the file | Source |
| --- | --- |
| workflow `gate.yml` | slot B1, B3 |
| workflow limit 30 min | slot B5 (`timeout-minutes` 30) |
| tolerance 20 % | ext-02 E4 (step wall time per CI job, +20 %); slot E4 (20 %, queue wait) |
| adoption from the median of 10 runs on the trusted revision | ext-02 E4 |
| UI step at most 120 s | slot B5 |
| Rust test step 120 s, not enforced | slot B5 |
| `queue_wait` apart from `run_time` | slot B2 (job log); § 3 |
| job log `jobs.jsonl` | slot B2 |
| commands | slot B1, B2 |
| `rustc` pinned in `rust-toolchain.toml` | slot B1 |
| merge gate judged in CI | slot D1 ("use the forge as the full verdict", inferred there) |
| queue wait in an operational gate | ext-03 C3; ext-08 C3; § 5 |

**Reference records (not in the file).** `ci-gate-turnaround`: the median of the last 10
qualifying runs on the trusted revision. The answer has no such figure. Its nearest is 5.4 min, the
median of 160 successful runs out of 187 listed (slot B3), and it does not say whether that
includes queue wait. `ci-gate-queue-wait-does-not-rise`: no answer gives the queue wait of a
workflow run, so the requirement returns insufficient evidence with the cause `reference_missing`
until 10 runs are in the series.

**The milestone on this example.**

1. Observe: `ratchet import` writes the 187 listed forge runs as assessment runs (§ 6). A run whose
   runner is unknown extends the series and does not qualify for a gate. Local `task check`: p50
   164 s, p90 422 s, 27 of 40 runs exit 0 (slot B2).
2. Adopt: with 5.4 min as the accepted value, allowed is 5.4 × 1.2 = 6.48 min, and under 30 min.
   The first adoption is a change of its own (D2), and the record is a file in the tree (D1).
3. Reject: a run of 12.3 min (the p90 of slot B3) under qualifying conditions fails with the cause
   `regression`, observed 12.3 min, allowed 6.48 min.
4. Improve: when the median of the last 10 qualifying runs is under 5.4 × 0.8 = 4.32 min,
   `ratchet reference propose` reports it (§ 5 rule 4).

The UI step takes about 45 s on the forge and passed 9 of 19 local runs at host load 50 to 170
(slot C2). Its plan runs in `ci` only.

**Left out.**

- Which runs the operational gate reads (G26).
- The place of the job log on each machine (G27). The file has the name the answer gives.
- A pinned tool for the UI step. The answer names `rustc` only, so that plan declares the runner
  alone.
- A tolerance in seconds. `tolerance: {absolute: ...}` exists now, and no answer gives one for a
  workflow.
- slot E4 as written: a comparison of 60 minutes after an install with 60 minutes before (§ 10,
  not changed).

## 3. No new analyzer findings

[`analyzer-findings.ratchet.yaml`](analyzer-findings.ratchet.yaml)

**Checks.** Four identity sets:

- lint findings, which must be none: `lte 0` on the number of items;
- files that nothing refers to, compared with an accepted set from the first run;
- secret-scan findings, compared with an accepted set whose one item is an allowlist entry with a
  reason and an owner;
- passing conformance cases on a deployed build, with `no_lost_items`: no accepted case fails or
  stops running. Three cases have a dated exception.

**Audience.** Developers and coding agents for the source tree; API consumers for the contract.

**Sources.**

| In the file | Source |
| --- | --- |
| lint blocks on any finding | runbook B1; spindle B5; substrate B5 |
| lint on 4 crates | runbook B1 |
| `rustc` pinned in `rust-toolchain.toml` | runbook B1 |
| lint and the file check run only locally | runbook B3 |
| `task check:unreferenced` | runbook B1 |
| a secret scan in the local gate | substrate B1 |
| scan findings identified by rule and path | substrate C3 |
| no accepted case fails or stops running | § 4; swell D3, E4; ext-07 B5 |
| three known-failing cases | ext-07 C3; ext-02 C3 |
| owner is a story reference | ext-07 B6; ext-02 B6 |
| `created: 2026-11-23`, `expires: 2026-11-30` | ext-07 C3, ext-02 C3: added that day, "one week out" |

**Reference records (not in the file).**

- `no-new-unreferenced-files`: the 26 files the first run found, kept "as unexamined"
  (runbook C3).
- `no-lost-passing-cases`: the ids of the cases that passed when the set was adopted. The answers
  give no count.
- `no-new-secret-findings`: one item, the allowlist entry for signed test tokens in conformance
  vectors (substrate C3). As `ratchet/references/no-new-secret-findings.json` (D1):

```json
{
  "format": "ratchet-reference/1",
  "requirement": "no-new-secret-findings",
  "kind": "accepted_value",
  "revision": "<commit the set was adopted at>",
  "items": [
    {
      "rule": "<rule>",
      "path": "<path of the conformance vectors>",
      "reason": "Signed test tokens in conformance vectors.",
      "owner": "decision:<id>"
    }
  ],
  "conditions": {"tools": {"<scanner>": "<version>"}},
  "evidence": ["run:<id>"],
  "last_change": {"kind": "first_adoption", "authorized_by": "decision:<id>"}
}
```

The item has no end date: it is a permanent false positive, and an accepted item, not an
exception. § 3 shows a record with `values` and none with `items`, so the item's shape is a guess
(G28).

**Expected verdicts.**

- The file list has 27 lines now (runbook C3). A candidate that adds the 27th file fails with the
  cause `new_items`, and the result names the file. Taking it into the set is a loosening: a change
  of its own, before the candidate (D2). The item may carry a reason and an owner, and the answer
  gives neither.
- A second allowlist entry is the same: "widening it is a security change" (substrate C3). Another
  answer keeps 27 lines with a written reason each (ext-08 C3).
- A case of the accepted set that fails, or that no longer runs, fails with the cause `lost_items`.
  A set of failing cases would not see the second.
- After 2026-11-30 the three exceptions no longer apply and the three cases count as lost. Today
  "the review-by dates exist; I have not seen one enforced" (ext-07 C3).
- In CI the three source checks return insufficient evidence with the cause `not_assessable_here`
  (§ 3). They are not left out and not passed.

**Left out.**

- A failure accepted until a finding is fixed (spindle C3). An exception ends at a date only (D4).
- A report path for the two plans with a `command`. The assessor runs the tool and reads its
  output; the two plans that import a report name its path in `inputs`.
- A severity filter. The lint blocks on any finding, and the answers give no severities for the
  other sets.

## 4. Generated artifact by digest

[`generated-artifact.ratchet.yaml`](generated-artifact.ratchet.yaml)

**Checks.** Committed files equal a fresh run of their generator, by digest, tolerance 0, on the
merged tree. The fast check runs before every merge. The full regeneration runs before a merge
only when its sources changed, and before every promotion.

**Audience.** Developers, coding agents and docs readers. F17: 20 answers say good quality means
documents, specification, generated files and code say the same thing.

**Sources.**

| In the file | Source |
| --- | --- |
| `task docs-check`, 18 generated files | canon B1 |
| `task test-slow` regenerates and compares bytes | canon B6 |
| `ess` at 0.97.4 | canon C2 |
| fast check and slow lane as two checks | runbook B1, B6 |
| slow lane only when its sources changed | runbook B1 |
| the merged tree as target | runbook C1 |
| the practice | F5 (21 answers) |

**Expected verdicts.**

- A committed file differs from a fresh generation: fail with the cause
  `generated_reference_differs`, naming the file.
- The candidate regenerates the file in the same change: pass. It is recorded as a reference change
  and needs no authorization (§ 5).
- A merge leaves a file stale without a conflict: fail, because the target is `merge_result`.
- `ess` on the path is 0.98.0 and the plan names 0.97.4: insufficient evidence with the cause
  `tool_mismatch`, next step on the assessment. Today that state fails 47 tests (canon C2).
- The docs check executes 17 files: insufficient evidence with the cause `coverage_below_plan`.
- A change that touches neither `spec/**` nor `conformance/**`: the entry of
  `scenario-files-current` in `merge` is not applicable, and the gate result lists it with the
  reason. `promote` has the same requirement without `when`, so a path list that misses a source
  does not let a stale file through (§ 5).
- `merge` lists `local` and `ci` and declares no `evidence`: one pass from either class clears a
  requirement, and a fail from either blocks (D3).

**Left out.** The number of scenario files; canon B6 gives none, so the slow lane declares no
`executed`. `executed: 18` is a minimum. Exactly 18 is `{min: 18, max: 18}`.

## 5. Insufficient evidence on a host-caused limit

[`host-caused-limit.ratchet.yaml`](host-caused-limit.ratchet.yaml)

**Checks.** One plan runs `task test` once and gives two measurements: the test steps within 120 s
and each test within 60 s, as run time without queue wait. The conditions are per target class: a
bound on host load for the workstation, a runner for CI. Either class can clear the gate.

**Audience.** Coding agents and developers. swell E3: "the gate takes longer or its verdict depends
on load".

**Sources.**

| In the file | Source |
| --- | --- |
| test steps at most 120 s | swell B2, B5 |
| a test at most 60 s | swell B2, B5 |
| step time and time per test from one run | swell B2 |
| pinned toolchain | swell B1 |
| queue wait recorded apart | swell B2 (`waited 1490s ... ran 317s`); ux-ui C2 |
| local and CI run the same task | swell B1 |
| `evidence: any` | swell C3 ("the forge's run judges the budget"); D3 |
| `host_load_per_cpu` 2.125 | swell C2: load 34 on 16 cores; see [Numbers without a source](#numbers-without-a-source) |

**Expected verdicts**, on the two runs of swell C2:

| Run | Host load | Per CPU | Observed | Verdict |
| --- | --- | --- | --- | --- |
| Gate of release 0.7.0, local | 65 on 16 cores | 4.06 | 194.7 s | insufficient evidence, cause `conditions_outside_declared`; next step on the assessment |
| The same steps, local | 34 | 2.125 | 94.3 s | pass |

- The first run does not block the release when the forge's run of the same tree passes: with
  `evidence: any`, insufficient evidence from another class does not block. A fail from either
  class blocks.
- The gate is evaluated on the workstation after `git fetch` brought the forge's records (§ 6).
  Evaluated in CI it reads the forge's records only, and records of a local run stay on the
  machine.
- A qualifying run that reaches 120 s is a fail with the observed value "at least 120 s" (§ 3).
- A test killed at 60 s above the load bound is insufficient evidence. It is not a failed test and
  not a result about the subject (§ 3; ext-06 C2: 3 of 6 runs in one day ended with a verdict that
  a killed step produced).
- A round of 1912 s with a browser run of 108.6 s (ux-ui C2) is judged on 108.6 s.

**Not in the answer.** It gives one load value per run, and the table reads it as the mean over the
run that § 3 defines. The evidence would also hold the minimum and the maximum.

## `ratchet.toml`

[`ratchet.toml`](ratchet.toml) has the six sections of § 5. It is the local config of a workstation
checkout of example 5.

- `skip_sampled_outside_conditions` holds no number. The bound is the plan's, 2.125 under `local`.
- `observe_only` names one requirement of that file. `ratchet status` shows it with its value and
  leaves it out of its summary. The release gate still enforces it: a gate reads no `[local]` key.
- A run skipped under this file is recorded with the cause `skipped_locally` and reported as
  "skipped locally by ratchet.toml", never as a pass.
- In CI, `ratchet evaluate` refuses this file with `local_skips_refused`, because it carries two
  `[local]` skips.
- The catalog source is this repository. `presets/` does not exist in it yet, and `<commit>` is
  not a commit, so the entry resolves to nothing.

## Decisions D1 to D4

The owner decided the four questions of § 9 on 2026-11-24, all A.

| Decision | Where an example uses it |
| --- | --- |
| D1: reference and trade-off records are files in the tree | the record paths in examples 1 and 3; every reference record named on this page is `ratchet/references/<requirement>.json` |
| D2: a loosening is a change of its own, merged before the candidate | first adoptions in examples 1, 2 and 3; the three exceptions, the allowlist item and a 27th file in example 3 |
| D3: evidence from any one listed class decides | the `merge` gate of example 4, which declares no `evidence`; example 5 writes `evidence: any` |
| D4: an exception ends at a date only | the three exceptions of example 3; the allowlist entry is an accepted item and has no date |

## Values not shown in the design

The keys are the design's. These values are not in the YAML of § 3. Each is in a list that § 3
leaves to the assessor or to the author, unless the last column says otherwise.

| Key | Value | Where it comes from |
| --- | --- | --- |
| `assessor` | every id except `ux-eval@1`, `command-timing@1` and `generator-check@1` | placeholder |
| `inputs` | `workflow`, `job_log`, `layout_shift_exclusion_ms` | input names, the assessor's |
| `subjects.*.kind` | `api-operation` | free label |
| `audiences` | `end-user`, `api-consumer`, `docs-reader` | free labels |
| `target.kind` | `workflow_run` | closed list of § 3 |
| `target.environments` | `staging` | closed list of § 3 |
| `measurements.*.scope` | `task` | the assessor's |
| `measurements.*.unit` | `min`, `actions`, `percent`, `score` | the assessor's |
| `measurements.*.better` | `higher` | closed list of § 3 |
| `measurements.*.output` | every name except `findings`, `steps`, `duration` and `digest` | the assessor's |
| `condition.operator` | `gte`, `holds`, `no_lost_items` | closed list of § 3 |
| `gates.*.stage` | `post-workflow` | free label |
| `exceptions.*.created` | a date | § 5, prose |

`unit: score` stands for a layout shift, which has no unit. § 3 does not say whether a number may
leave `unit` out.

Shapes of revision 3 that no example uses: `statements`, with `meaning` and `serves` on a
requirement; a `presets` binding; `planted_defects`; `paired`; `window` and `population`;
`aggregation` on a measurement; `executed_ids`; `value` on an exception; `skip` in `ratchet.toml`.

## Gaps of revision 2 and how revision 3 closed them

Writing these examples against revision 2 found 25 gaps. Revision 3 closes each one, and
`docs/design.md` § 10 gives the cause of every change. That section cites this list as "Design
gaps found", and cites "Values not shown in the design" and "Numbers without a source" as they
stood then. The full text of each gap (what was needed, what the design lacked, the proposed fix)
is in this file at commit `b7cd992`.

- **G1. Ratchet policy.** `reference.adoption`: `same_change`, or `{from, runs, aggregation}`. § 5.
- **G2. Reference record.** Fields, one illustrative record, one file per requirement. § 3, § 5;
  the place is D1.
- **G3. Trade-off.** A record of its own with `gains` and `loosens`, each entry
  `{requirement, item, from, to}`. § 5, § 6.
- **G4. Several outputs from one run.** A plan holds a map of `measurements` and runs once. § 3.
- **G5. Several scenarios in one plan.** `scenarios` is a list and takes a pattern. § 3.
- **G6. Direction of a comparison.** Operators `gt`, `gte` and `eq`; `better` on a measurement.
  § 3.
- **G7. Operators on an identity set.** The number operators compare the item count;
  `no_lost_items`. § 3, § 4.
- **G8. Absolute tolerance.** `tolerance: {absolute: ...}` beside `percent`; the wider band
  applies. § 3.
- **G9. An assertion as a measurement.** Assertion is a value type, with the operator `holds`.
  § 3, § 7.
- **G10. Coverage keys.** `executed`, `skipped`, `not_run`, `unsupported` and `executed_ids`; a
  bare number is a minimum for `executed` and a maximum for the others. § 3.
- **G11. A filter on findings.** `filter` on a measurement of an identity set. § 3.
- **G12. An acceptance without a date.** An item of an accepted set can carry `reason` and
  `owner`. § 5. An exception that ends at an event: D4, a date only.
- **G13. Inputs of an assessor.** Declared inputs with a name and a type; a plan passes `inputs`.
  § 4.
- **G14. Conditions per target class.** `conditions` keyed by class, with `all`; host load defined
  as a mean per CPU. § 3.
- **G15. Which evidence decides.** `evidence: any` or `all` on a gate. § 5; the default is D3,
  `any`.
- **G16. A requirement that applies to some changes.** `when: {changed: [paths]}` on a gate entry;
  the state "not applicable". § 5.
- **G17. Generated reference.** `reference: {kind: generated, paths: [...]}`. § 5.
- **G18. A committed file of measured results.** It is an accepted value; a generated reference is
  a function of sources in the tree. § 5.
- **G19. Tool pin.** The condition `tools` names each tool with a version or a pin file. § 3.
- **G20. The merged tree as target.** `selection: merge_result`. § 3, § 5.
- **G21. One sample per candidate.** `runs: 1` without an aggregation is valid. § 3.
- **G22. A local skip is not a verdict.** "Skipped locally" is a state, recorded with the cause
  `skipped_locally`; the skip rule holds no number. § 5, local config.
- **G23. A requirement about the host.** Gate kind `candidate` or `operational`. § 1, § 5.
- **G24. Evidence that exists after the stage.** Three placements; a stage is a free label. § 7.
- **G25. Value lists.** Closed lists, assessor's lists and free labels; Ratchet's values in
  snake_case. § 3.

## New gaps

Found while rewriting the examples to revision 3. Each: what an example needed, what
`docs/design.md` revision 3 lacks, and a proposed fix.

**G26. The evidence of an operational gate.**
- Needed: queue wait of the gate workflow, judged once a day (example 2).
- Lacks: an operational gate has no candidate. Nothing says which runs `ratchet evaluate --gate
  build-pool` reads: the last finished run, every run since the last evaluation, or a window. § 7
  says "the series of finished runs on the trusted branch", and the plan that feeds it has
  `selection: candidate`. The YAML of § 3 has the same shape (`queue-wait-budget`). A time-window
  plan could answer it, and `population` has no shape yet.
- Fix: say which records an operational gate reads, as a key of the gate (`over: {runs: N}` or a
  window) or by requiring a `time_window` plan, and show `window` and `population` in YAML.

**G27. An input that differs per machine.**
- Needed: the place of the build pool's job log (example 2; slot B2).
- Lacks: `inputs` is part of the specification, which is read from the trusted revision. The log
  is in a state directory of each machine. `ratchet.toml` locates tools as commands and has no
  place for an input.
- Fix: an assessor declares an input as local, and `ratchet.toml` supplies it under `[inputs]`.
  The value locates a file and carries no policy.

**G28. An item in a reference record of a set.**
- Needed: an allowlist entry with a reason and an owner (example 3); the 12 findings (example 1).
- Lacks: § 3 shows `values` and says that `items` are "keyed by the identity key of the set". With
  an identity of several fields it is open whether an item is an object with those fields, and
  where `reason` and `owner` sit beside them.
- Fix: show one record with `items`, each `{identity: {...}, reason, owner}`.

**G29. Coverage of a plan with several measurements.**
- Needed: 30 walks executed, for measurements at the scopes journey and page (example 1); tests
  not skipped, for measurements at the scopes run and test (example 5).
- Lacks: `coverage` is one block per plan, and § 4 has the assessor declare coverage counts per
  output. Nothing says which item a count of the plan counts.
- Fix: say that a plan's coverage counts the items of one scope that the assessor names, or let a
  measurement carry `coverage`.

## Numbers without a source

- **Host load bound** (`host_load_per_cpu: {max: 2.125}`). No answer states a load that qualifies
  a timing run. 2.125 is the load of one passing run (swell C2). Another answer passed in 68 s at
  3.4 to 3.75 per CPU (inbox C2: load 68 to 75 on 20 CPUs).
- **`since: 2026-11-23`** (example 2). slot B5 says the Rust test step rule is not enforced, not
  since when. The date is the day of the answer.
- **Tolerance 20 %** (example 2). The two sources apply 20 % to other measurements: step wall time
  per CI job (ext-02 E4) and queue-wait p90 over 60 minutes (slot E4). The example applies it to
  the run time and the queue wait of one workflow run.
- **`runs: 10` of the adoption** (example 2). ext-02 E4 names the median of the last 10 runs for
  the wall time of a test step. § 5 gives N no default.
- **`runs: 1`** (examples 2, 5). The answers run a gate once; none states a run count for a timing
  check of a whole step. Repeats in use are 3 (surf B5, runbook B4, entity-runtime B6) and 5
  (ext-04 B6).
- **`executed: 30`** (example 1). ux-ui B4 counts 30 walks. Whether a walk is one scenario of the
  pattern is not in the answer: 168 values (gap 1) at 14 metrics are 12 scenarios.
- **Exception texts** (example 3). Exception ids, case ids, reasons and story ids are illustrative.
  Only the count of three and the dates are from the answers.
- **Paths** (examples 1, 3, 4). Report paths, reference `paths` and the `when` list are
  illustrative. No answer names them.
