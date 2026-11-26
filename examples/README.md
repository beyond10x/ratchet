# Examples

Worked `ratchet/1` specifications for the first milestone of
[`vision.md`](https://github.com/beyond10x/ratchet/blob/main/vision.md), in the shapes of
[`docs/design.md`](https://github.com/beyond10x/ratchet/blob/main/docs/design.md) revision 4. They
were first written against revision 2 and rewritten to revision 3. The gaps found in those two
rounds are listed below, [G1 to G25](#gaps-of-revision-2-and-how-revision-3-closed-them) and
[G26 to G29](#gaps-of-revision-3-and-how-revision-4-closed-them).
Design-phase documents: nothing here runs. One gate step reads them,
`sh spec/example-declarations.test.sh`: every assessor they name has a declaration, each
measurement names an output, a unit and a scope it declares, and each binding under `presets:`
names a preset file of `presets/` with the SHA-256 of that file as its `digest`. No tool has validated them beyond that
and YAML, TOML and JSON syntax.

How to read them:

- Every key is one that `docs/design.md` revision 4 shows or names in §§ 3 to 5. The key names are
  proposals, as that document says. Where an example needed something the design does not say, the
  case is listed under [New gaps](#new-gaps).
- Some values are not shown in the design. They are listed under
  [Values not shown in the design](#values-not-shown-in-the-design).
- A coverage bound is written `{min: 30}` or `{max: 0}`, and an adoption `{from: same_change}`.
  The bare number and the bare word of earlier revisions are not part of 0.1.0 (design § 12,
  taken 2026-11-24).
- Every number comes from a survey answer. `ux-ui B5` means
  [`research/responses/ux-ui.md`](https://github.com/beyond10x/ratchet/blob/main/research/responses/ux-ui.md),
  question B5. `F5` is a finding in
  [`research/synthesis.md`](https://github.com/beyond10x/ratchet/blob/main/research/synthesis.md),
  `gap 2` is a gap in
  [`research/consumer-input-ux-ui.md`](https://github.com/beyond10x/ratchet/blob/main/research/consumer-input-ux-ui.md),
  `§ 5` is a section of `docs/design.md`. Numbers without a source are listed at the end.
- Project names, ids, paths, commands, rule names, runner labels and reason texts are illustrative
  unless a source names them. Each project name is neutral: an example is built from the answers
  named, and is not the specification of any one repository.
- An accepted value is not in a specification file (§ 3). Where an example has one, this page says
  what its reference record would hold.
- D1 to D4 of § 9 are decided, all A (the owner, 2026-11-24). D5 and D6 are open; the examples
  use their recommended default A, as the design does.
  [Where they matter](#decisions-d1-to-d6) says which example uses which.

| File | Integration (`vision.md`) | Audience | Main sources |
| --- | --- | --- | --- |
| [`ess-ui-behavior.ratchet.yaml`](ess-ui-behavior.ratchet.yaml) | ESS UI behavior | end users of a page | ux-ui, consumer input |
| [`ci-turnaround.ratchet.yaml`](ci-turnaround.ratchet.yaml) | CI turnaround | coding agents, developers | slot, ext-02 |
| [`analyzer-findings.ratchet.yaml`](analyzer-findings.ratchet.yaml) | no new analyzer findings | developers, coding agents, API consumers | runbook, substrate, ext-07, ext-02 |
| [`generated-artifact.ratchet.yaml`](generated-artifact.ratchet.yaml) | generated artifact by digest | developers, coding agents, docs readers | canon, runbook |
| [`host-caused-limit.ratchet.yaml`](host-caused-limit.ratchet.yaml) | insufficient evidence on a host-caused limit | coding agents, developers | swell |
| [`production-gate.ratchet.yaml`](production-gate.ratchet.yaml) | the production gate of a spec-executed service | operators, API consumers | a consumer's survey of 2026-11-25, not published |
| [`ratchet.toml`](ratchet.toml) | local config (§ 5) | one checkout | swell |

## 1. ESS UI behavior

[`ess-ui-behavior.ratchet.yaml`](ess-ui-behavior.ratchet.yaml)

**Checks.** Two plans on one page, in the local gate:

- `keyboard-task-completion` imports an ESS UI result for the keyboard-only scenario and enforces
  an assertion with `holds`: every task completes.
- `walks` imports one `ux-eval@1` report for every scenario that the pattern matches. Five
  measurements read that one run: steps and layout shift against accepted values, actions per fix
  and cue accuracy against fixed limits, and page-scoped findings of two severities compared by
  identity against an accepted set.
- `executed: {min: 30}` counts walks, the coverage unit of `ux-eval@1` (§ 3, evidence coverage). The plan
  has one set of counts, whatever the scope of a measurement. A scenario is a scope item and holds
  the values. A walk is what the assessor counts as executed.
- The layout shift has no unit. Its measurement carries no `unit`, and its tolerance of 0.01 is a
  bare number (§ 3, comparisons).

**Audience.** End users of the page. ux-ui E3: "a task takes more clicks or a control drops below
the fold".

**Sources.**

| In the file | Source |
| --- | --- |
| every task completes (`completion_miss` = 0) | ux-ui B5 |
| `not_run: {max: 0}` on the completion plan | ux-ui C1 (2 of 3 sub-tasks never done, counted as no miss) |
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

**Reference records (not in the file).**

- `no-new-page-findings`: the 12 findings filed in the round (ux-ui B4), adopted from observe-mode
  evidence. Each item is `{identity: {rule, node_path, environment}}`, and `environment` is a map of
  viewport, theme and input mode (§ 3).
- `steps-do-not-rise` and `layout-shift-does-not-rise`: one value per scenario, at the scope
  `journey`. A layout-shift value has no `unit` key. The answer gives no values. § 3 reads the 168
  values of the round as 12 scenarios with 14 keys.

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
    {"requirement": "<requirement of the key that moved>", "item": "<scenario>", "from": "23", "to": "0"}
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
- A sub-task that is never done is reported as not run. `not_run: {max: 0}` then makes that run
  insufficient evidence with the cause `coverage_below_plan`, not a held assertion. This reads the
  coverage unit of `ess-ui-report@1` as a task.
- A run that executes 29 walks is below `executed: {min: 30}`: insufficient evidence with the cause
  `coverage_below_plan`, for every requirement of the plan.
- A run of 30 walks that has no value for one scenario of the reference: `steps-do-not-rise` and
  `layout-shift-does-not-rise` return insufficient evidence with the cause `coverage_below_plan`,
  each for itself (§ 3). The two requirements with a fixed limit have no reference and do not see
  it (G31).
- A candidate that adds a scenario under the pattern: not defined (G30).

**Left out.**

- The other metrics of the 14 per walk. Each is one more entry of `measurements`; the answer names
  `false_complete`, no-scroll and always-visible among them (ux-ui B5).
- The keys of the trade-off, as said above.
- How a walk maps to a scenario. The answers do not say (§ 3).

## 2. CI turnaround

[`ci-turnaround.ratchet.yaml`](ci-turnaround.ratchet.yaml)

**Checks.**

- `ci-gate-timing` reads one finished run of the gate workflow and gives two measurements: run time
  and queue wait.
- Run time has a fixed limit and an accepted value. It is judged in `workflow-finished`, a gate
  that a job evaluates after the workflow has ended (§ 7, second placement). A gate inside the
  workflow cannot read that workflow's total time.
- Queue wait has no requirement on that plan. The runs of `ci-gate-timing` are the population of
  `ci-gate-queue-wait`, a time-window plan that `record-series@1` reads from the record store: the
  90th percentile of the queue wait over the runs of one day, on the trusted branch and of every
  candidate (`from: any_revision`). The plan has no `selection` and no conditions of its own
  (§ 3, time windows).
- `ci-gate-queue-wait-does-not-rise` names the window plan and is judged in `build-pool`, an
  operational gate (§ 7, third placement). It decides nothing about a candidate.
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
| queue wait as a 90th percentile over a window | slot E4 (queue-wait p90 over 60 min) |
| commands | slot B1, B2 |
| `rustc` pinned in `rust-toolchain.toml` | slot B1 |
| merge gate judged in CI | slot D1 ("use the forge as the full verdict", inferred there) |
| queue wait in an operational gate | ext-03 C3; ext-08 C3; § 5 |
| no `job_log` in the file | slot B2, B7 (the log is local to the host); § 4 |

**The job log is a local input.** `command-timing@1` declares `job_log` as local (§ 3, § 4), so
`local-gate-run-time` passes no input for it. The input is not required
([`command-timing@1.assessor.yaml`](quality/assessors/command-timing@1.assessor.yaml)): the two
plans that run in `ci` read run time only and have no job log, and a required input without a
value would make them `not_assessable_here` on every runner. The local config of a workstation
checkout of this example supplies it (§ 5, local config, rule 6). The file is `jobs.jsonl`
(slot B2), and the directory is an illustration:

```toml
[inputs.local-gate-run-time]
job_log = "/var/lib/build-pool/jobs.jsonl"
```

**Reference records (not in the file).**

- `ci-gate-turnaround`: the median of the last 10 qualifying runs on the trusted revision. The
  answer has no such figure. Its nearest is 5.4 min, the median of 160 successful runs out of 187
  listed (slot B3), and it does not say whether that includes queue wait.
- `ci-gate-queue-wait-does-not-rise`: the median of the last 10 windows. The `adoption` of a window
  measurement counts windows that an evaluation recorded, and not runs (§ 3, time windows). With a
  window of one day and one evaluation a day, the requirement returns insufficient evidence with
  the cause `reference_missing` for the first 10 days (G32, G33). No answer gives the queue wait of
  a workflow run.

**The milestone on this example.**

1. Observe: `ratchet import` writes the 187 listed forge runs as assessment runs of
   `ci-gate-timing` (§ 6). A run whose runner is unknown extends the series, does not qualify for a
   gate, and is left out of a window's population. Local `task check`: p50 164 s, p90 422 s, 27 of
   40 runs exit 0 (slot B2).
2. Adopt: with 5.4 min as the accepted value, allowed is 5.4 × 1.2 = 6.48 min, and under 30 min.
   The first adoption is a change of its own (D2), and the record is a file in the tree (D1).
3. Reject: a run of 12.3 min (the p90 of slot B3) under qualifying conditions fails with the cause
   `regression`, observed 12.3 min, allowed 6.48 min.
4. Improve: when the median of the last 10 qualifying runs is under 5.4 × 0.8 = 4.32 min,
   `ratchet reference propose` reports it (§ 5 rule 4).

The UI step takes about 45 s on the forge and passed 9 of 19 local runs at host load 50 to 170
(slot C2). Its plan runs in `ci` only.

**The operational gate.**

- `ratchet evaluate --gate build-pool` takes no candidate. It assesses `ci-gate-queue-wait`, and
  the window ends at that moment (§ 5, gate kinds). The run records the bounds of the window, the
  number of runs in it, the time of the newest, and the number of runs left out.
- Fewer than 10 qualifying runs in the day: insufficient evidence with the cause
  `too_few_samples`. No pull request was merged on 3 of 12 days (slot A3).
- A 90th percentile worse than the accepted value by more than 20 %: fail with the cause
  `regression`. The next step is `system`, on the runners, and not `candidate`.
- A second evaluation at the same moment reads the same runs, and a missed day changes nothing:
  the window is the plan's.

**Left out.**

- A pinned tool for the UI step. The answer names `rustc` only, so that plan declares the runner
  alone.
- A tolerance in seconds. `tolerance: {absolute: ...}` exists, and no answer gives one for a
  workflow.
- A fixed limit on the queue wait. No answer gives one for a workflow run, so the requirement has a
  reference alone.
- slot E4 as written: a comparison of 60 minutes after an install with 60 minutes before. A window
  plan gives one value per window (§ 11, not changed).

## 3. No new analyzer findings

[`analyzer-findings.ratchet.yaml`](analyzer-findings.ratchet.yaml)

**Checks.** Four identity sets:

- lint findings, which must be none: `lte 0` on the number of items. The number of items of a set
  has no unit, so neither the measurement nor the `condition` carries one (§ 3, comparisons);
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
- `no-lost-passing-cases`: the ids of the cases that passed when the set was adopted, each
  `{identity: {case_id}}`. The answers give no count.
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
      "identity": {
        "rule": "<rule>",
        "path": "<path of the conformance vectors>"
      },
      "reason": "Signed test tokens in conformance vectors.",
      "owner": "decision:<id>"
    }
  ],
  "conditions": {"tools": {"<scanner>": "<version>"}},
  "evidence": ["run:<id>"],
  "last_change": {"kind": "first_adoption", "authorized_by": "decision:<id>"}
}
```

The item is `{identity, reason, owner}` (§ 3, § 5). `identity` holds exactly the two fields of the
measurement's identity key, and `reason` and `owner` sit beside it. The item has no end date: it is
a permanent false positive, and an accepted item, not an exception.

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
- The lint run executes 3 crates: insufficient evidence with the cause `coverage_below_plan`.
  `executed: {min: 4}` counts crates, read here as the coverage unit of `clippy-report@1`.

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
`executed`. `executed: {min: 18}` is a minimum. Exactly 18 is `{min: 18, max: 18}`. It counts
files, read here as the coverage unit of `generator-check@1`.

## 5. Insufficient evidence on a host-caused limit

[`host-caused-limit.ratchet.yaml`](host-caused-limit.ratchet.yaml)

**Checks.** One plan runs `task test` once and gives two measurements: the test steps within 120 s
and each test within 60 s, as run time without queue wait. The conditions are per target class: a
bound on host load for the workstation, a runner for CI. Either class can clear the gate.
`skipped: {max: 0}` counts tests, the coverage unit of `command-timing@1` (§ 3), once for the run and for
both measurements.

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

**The check before the run is not the evidence.** Both rows are runs that started. The verdict
reads `host_load_per_cpu` as the mean of the 1-minute load over the run (§ 3). With
`skip_sampled_outside_conditions` in [`ratchet.toml`](ratchet.toml), the CLI also reads the load
once before `task test` starts. That single reading decides one thing, whether the run starts
(§ 5, local config, rule 4), and it is in no verdict:

- A reading of 4.06 before the run: the run does not start. It is recorded as skipped locally, and
  a gate that finds only that record returns insufficient evidence with the cause
  `skipped_locally`.
- A reading of 2.0 before the run and a mean of 4.06 over it: the run started, and it is
  insufficient evidence with the cause `conditions_outside_declared`, as in the first row.
- A reading of 2.0 before the run does not make a run qualify. Only the mean over the run does.

**Not in the answer.** It gives one load value per run, and the table reads it as the mean over the
run. The evidence would also hold the minimum and the maximum.

## 6. Production gate of a spec-executed service

[`production-gate.ratchet.yaml`](production-gate.ratchet.yaml)

**Checks.** One gate, `production`, over the seven checks a consumer named for a service that
executes a specification, before the service goes to production. Five of them bind presets of
[`presets/`](https://github.com/beyond10x/ratchet/tree/main/presets) under `presets:`, each with
the digest of the preset file:

| Check | In the file |
| --- | --- |
| 1. Every declared operation is served, and the set of served operations loses no item | `served-operations`, `conformance-cases@1` over the report of served operations: `no-case-lost` |
| 2. Every scenario replay that passed in the accepted run passes; a known-failure list holds the others and gains no item | `replays`, `conformance-cases@1` over the replay report: `no-case-lost`; `replay-known-failures`, `known-failures@1`: `no-new-known-failure` |
| 3. A request without a credential, with an expired one and with one of another tenant is refused | `probes`, `exposure-probes@1`: `requests-without-valid-credential-refused` |
| 4. Console routes cannot be reached through the public proxy | `probes`: `console-not-reachable-through-public-proxy` |
| 5. TLS is on for every public listener | `probes`: `tls-on-every-public-listener` |
| 6. The image has no critical advisory | the plan `image-advisories` of the file, over `advisory-report@1` with `filter: {severity: [critical]}`, and `no-new-critical-advisory` (`no_new_items` against the accepted set) |
| 7. The signatures of the image and of its provenance verify | `signatures`, `artifact-signatures@1`: `every-signature-verifies` |

- Check 6 is a plan of the file because `dependency-advisories@1` takes no filter input. It says
  "no critical advisory that the accepted set does not hold"; a limit of no critical advisory
  at all waits for a severity limit on an identity set.
- The gate is `kind: candidate`. A production gate is evaluated on a deployed environment, and
  an operational gate takes only time-window plans without a `selection`, while the bound
  presets' plans carry `selection: candidate` (§ 5; [`presets/production.md`](https://github.com/beyond10x/ratchet/blob/main/presets/production.md),
  "Not expressible yet").
- Ratchet sends no request, replays no scenario and verifies no signature: each report is
  written by the project's own probe runner, replay runner, scanner or verifier.
- `sh spec/example-declarations.test.sh` reads the plan of check 6 against `advisory-report@1`
  and checks that each binding names a preset file of `presets/` with its digest. The plans of
  the bound presets stand in `presets/`, which `sh spec/presets.test.sh` checks. Nothing checks
  the inputs a binding passes yet.

**Audience.** Operators of the service and its API consumers.

**Sources.** A survey of a consumer that runs a prototype service which executes a
specification (2026-11-25). The survey is not part of this repository, and nothing of the
consumer is named here. The subject names, the paths and the class `staging` are illustrative.

## `ratchet.toml`

[`ratchet.toml`](ratchet.toml) has the seven sections of § 5. It is the local config of a
workstation checkout of example 5.

- `skip_sampled_outside_conditions` holds no number. The bound is the plan's, 2.125 under `local`.
  Its check is one reading of the load before the run and not the evidence (example 5).
- `observe_only` names one requirement of that file. `ratchet status` shows it with its value and
  leaves it out of its summary. The release gate still enforces it: a gate reads no `[local]` key.
- A run skipped under this file is recorded with the cause `skipped_locally` and reported as
  "skipped locally by ratchet.toml", never as a pass.
- In CI, `ratchet evaluate` refuses this file with `local_skips_refused`, because it carries two
  `[local]` skips. `[inputs]` is not a skip and is not refused.
- `[inputs.test-steps]` supplies `job_log`, the local input of `command-timing@1`, to the plan
  `test-steps` (§ 4; § 5, local config, rule 6). The specification passes no input for it, and the
  assessment run records the resolved path. The path is the illustration of § 5: the pool prints
  queue wait per job (swell B2) and another answer names the log `jobs.jsonl` (slot B2). A key
  there for an input that is not local is refused with `input_not_local`.
- The first catalog source is this repository, whose `presets/` holds the catalog. `<commit>` is
  not a commit, so the entry resolves to nothing.
- The second catalog source has no `git`: it is the directory `quality/assessors` of the checkout,
  relative to the root. The declaration of an assessor is a file there, such as
  `command-timing@1.assessor.yaml` (§ 5, local config; § 12). The directory
  [`quality/assessors/`](quality/assessors/) holds the declaration of each of the nine assessors
  the examples name, all but `record-series@1`, which is Ratchet's own and has none.
- `[records] store` names the ref that holds the series, and no path. The records of a local run
  are therefore kept in `.ratchet/records` under the root, as they are without the section (§ 5,
  local config; § 6).

## Decisions D1 to D6

The owner decided D1 to D4 of § 9 on 2026-11-24, all A. D5 and D6 are open with the owner; the
examples, like the design, are written under their recommended default A.

| Decision | Where an example uses it |
| --- | --- |
| D1: reference and trade-off records are files in the tree | the record paths in examples 1 and 3; every reference record named on this page is `ratchet/references/<requirement>.json` |
| D2: a loosening is a change of its own, merged before the candidate | first adoptions in examples 1, 2 and 3; the three exceptions, the allowlist item and a 27th file in example 3 |
| D3: evidence from any one listed class decides | the `merge` gate of example 4, which declares no `evidence`; example 5 writes `evidence: any` |
| D4: an exception ends at a date only | the three exceptions of example 3; the allowlist entry is an accepted item and has no date |
| D5: the evidence of an operational gate is a time-window plan | `ci-gate-queue-wait` and the gate `build-pool` of example 2 |
| D6: an input that differs per machine is declared local by the assessor and supplied by `ratchet.toml` | `[inputs.test-steps]` in `ratchet.toml`; `local-gate-run-time` of example 2 passes no `job_log` |

## Values not shown in the design

The keys are the design's. These values are not in the YAML of § 3. Each is in a list that § 3
leaves to the assessor or to the author, unless the last column says otherwise.

| Key | Value | Where it comes from |
| --- | --- | --- |
| `assessor` | every id except `ux-eval@1`, `command-timing@1`, `generator-check@1` and `record-series@1` | an illustrative id, declared in [`quality/assessors/`](quality/assessors/) |
| `inputs` | `workflow`, `layout_shift_exclusion_ms` | input names, the assessor's |
| `subjects.*.kind` | `api-operation` | free label |
| `audiences` | `end-user`, `api-consumer`, `docs-reader` | free labels |
| `target.kind` | `workflow_run` | closed list of § 3 |
| `target.environments` | `staging` | closed list of § 3 |
| `measurements.*.scope` | `task` | the assessor's |
| `measurements.*.unit` | `min`, `actions`, `percent` | the assessor's |
| `measurements.*.better` | `higher` | closed list of § 3 |
| `measurements.*.output` | every name except `findings`, `steps`, `duration`, `digest` and `queue-wait` | the assessor's |
| `condition.operator` | `gte`, `holds`, `no_lost_items` | closed list of § 3 |
| `window.length` | `1d` | § 3, time windows |
| `gates.*.stage` | `post-workflow` | free label |
| `exceptions.*.created` | a date | § 5, prose |

Coverage units are the assessor's, and no plan names one: each declaration in
[`quality/assessors/`](quality/assessors/) states it as `coverage_unit`. § 3 gives the walk for
`ux-eval@1` and the test for `command-timing@1`. The examples read the others as: the task for
`ess-ui-report@1`, the crate for `clippy-report@1`, the file for `generator-check@1`,
`project-command@1` and `secret-scan-report@1`, the case for `ess-conformance-report@1`, and the
run for `forge-workflow-timing@1`, which reads one finished run of a workflow and whose plan bounds
no count.

Shapes of revision 4 that no example uses: `statements`, with `meaning` and `serves` on a
requirement; `planted_defects`; `paired`; `executed_ids`; `value` on an
exception; `skip` in `ratchet.toml`; `window: {last: N}`; `population: {filter: ...}`;
`from: trusted_revision` on a population; a `selection` on a time-window plan.

## Gaps of revision 2 and how revision 3 closed them

Writing these examples against revision 2 found 25 gaps. Revision 3 closes each one, and
`docs/design.md` § 10 gives the cause of every change. That section cites this list as "Design
gaps found", and cites "Values not shown in the design" and "Numbers without a source" as they
stood then. The full text of each gap (what was needed, what the design lacked, the proposed fix)
is in this file at commit `b7cd992`,
[section "Design gaps found"](https://github.com/beyond10x/ratchet/blob/b7cd992deb4192ef8c4d0f89b0f6c12604b68999/examples/README.md#design-gaps-found).

- **G1. Ratchet policy.** `reference.adoption`: `same_change`, or `{from, runs, aggregation}`. § 5.
  Since 2026-11-24 the first is written `{from: same_change}` (§ 12).
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
  bare number is a minimum for `executed` and a maximum for the others. § 3. Since 2026-11-24 a
  bound is written `{min: N}` or `{max: N}` (§ 12).
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

## Gaps of revision 3 and how revision 4 closed them

Rewriting the examples to revision 3 found four more gaps. Revision 4 closes each one, and
`docs/design.md` § 11 gives the cause of every change. That section cites this list as "New gaps".
The full text of each gap is in this file at commit `a94ab83`,
[section "New gaps"](https://github.com/beyond10x/ratchet/blob/a94ab83f8afb6dcbb8d987a907b41d93039b535d/examples/README.md#new-gaps).

- **G26. The evidence of an operational gate.** Closed. Each requirement of an operational gate
  names a time-window plan. `window` is `{length}`, `{last}` or both, `population` is
  `{runs_of, from}` or `{filter}`, and `min_samples` is required. `record-series@1` reads the runs
  of another plan. § 3 (time windows), § 5 (gate entries, deciding evidence, and gate kinds), § 7;
  D5. Used in example 2.
- **G27. An input that differs per machine.** Closed. The assessor declares the input as local,
  and `[inputs.<assessment>]` in `ratchet.toml` supplies it. § 4 (custom assessors), § 5 (local
  config, rule 6); D6. Used in `ratchet.toml` and in example 2.
- **G28. An item in a reference record of a set.** Closed. An item is `{identity, reason, owner}`,
  and the last two are optional. § 3 (the record of `no-new-search-findings`), § 5 (reference
  records). Used in examples 1 and 3.
- **G29. Coverage of a plan with several measurements.** Closed. Coverage belongs to the plan and
  counts the assessor's coverage unit, declared once per assessor. § 3 (evidence coverage), § 4
  (custom assessors). Used in examples 1, 3, 4 and 5.

Revision 4 also resolves two things these examples carried as notes: a number without a unit takes
no `unit`, so `unit: score` is gone from example 1 (§ 3, comparisons), and a walk is a coverage unit
and not a scenario, so `executed: {min: 30}` has a source (§ 3; ux-ui B4).

## New gaps

Found while rewriting the examples to revision 4. Each: what an example needed, what
`docs/design.md` revision 4 lacks, and a proposed fix.

**G30. A scope item that is new in a run.**
- Needed: a candidate adds a scenario that the pattern `ess-ui:explainer-page/*` matches.
  `steps-do-not-rise` and `layout-shift-does-not-rise` have an accepted value for every other
  scenario (example 1).
- Lacks: § 5 rule 3 covers a requirement with no reference. § 3 covers an item of the reference
  with no value in the run. Nothing covers an item of the run with no value in the reference, and
  § 11 names the case as left open. If the item is `reference_missing`, the candidate cannot
  advance: evidence from before the candidate cannot exist for a scenario that the candidate adds,
  and a first adoption is a change of its own before the candidate (D2).
- Fix: for an exact measurement the candidate adopts the value of a new item in the same change,
  and the gate verifies it against the candidate's evidence, as it does for a tightening. It is
  recorded as a first adoption of that item and loosens nothing, because no value was accepted
  before. For a sampled measurement the item is reported as new and is not judged until the
  `adoption` has its runs. The gate result lists the new items.

**G31. A pattern that matches fewer scenarios, under a coverage that counts walks.**
- Needed: `fix-within-two-actions` and `cues-are-accurate` hold for every scenario of the pattern
  (example 1). They have a fixed limit and no reference.
- Lacks: § 3 says a plan with a pattern declares its coverage, because a pattern can match fewer
  scenarios than before. The coverage counts the coverage unit, a walk for `ux-eval@1`, and § 3
  says that the answers do not relate a walk to a scenario. A reference lists its items, so a
  requirement with one sees a lost scenario. A requirement with a fixed limit has no list: a run of
  30 walks over 11 scenarios passes it.
- Fix: the assessment run records the scope items that each measurement has a value for, and a plan
  can bound their number beside `scenarios`. Or § 3 says that coverage does not answer a shrinking
  pattern where the coverage unit is not the scenario.

**G32. The `from` of an adoption on a window measurement.**
- Needed: an accepted value for the 90th percentile of the queue wait, from the windows of an
  operational gate whose population is `from: any_revision` (example 2).
- Lacks: an `adoption` is `{from: trusted_revision, runs, aggregation}`, and § 5 reads it as the
  last N qualifying runs on the trusted revision. § 3 says that on a window measurement `runs`
  counts the windows that an evaluation recorded. A window has no candidate and no revision of its
  own, and its items are the runs of every candidate. Nothing says what `from: trusted_revision`
  selects there, or whether a window that `ratchet assess` wrote outside an evaluation counts.
- Fix: say that on a window measurement `from: trusted_revision` selects the windows recorded with
  the specification read at the trusted revision, whatever the `from` of the population, and name
  which command's windows count.

**G33. A first window reference from a series that exists.**
- Needed: the first accepted value of `ci-gate-queue-wait-does-not-rise`, once `ratchet import` has
  written the listed forge runs as assessment runs (example 2).
- Lacks: a window ends when its plan is assessed, and an `adoption` counts recorded windows. With
  `runs: 10` and a window of one day the requirement is `reference_missing` for 10 days, whatever
  the series already holds. No command assesses a window that ends in the past.
- Fix: `ratchet assess` takes an end time for a time-window plan over `runs_of`, and the run
  records that it was assessed after the fact. Or the first adoption of a window measurement reads
  the series and cuts the windows itself.

**G34. The target class of a window.**
- Needed: `build-pool` lists `qualifying_environments: [ci]`, and `ci-gate-queue-wait` lists
  `environments: [ci]` (example 2).
- Lacks: on every other plan `environments` lists the classes the plan runs in, and evidence
  records the class it was produced in (§ 3). On a window plan it lists the classes whose runs
  count. `record-series@1` reads the record store, which a workstation has after `git fetch`
  (§ 6). Nothing says whether a window that a workstation assessed over runs of the class `ci` is
  evidence of the class `ci` or `local`, and so whether it qualifies for the gate.
- Fix: say that the class of a window over `runs_of` is the class of its population, wherever
  `record-series@1` ran, and that the run also records the class of the machine that assessed it.

## Numbers without a source

- **Host load bound** (`host_load_per_cpu: {max: 2.125}`). No answer states a load that qualifies
  a timing run. 2.125 is the load of one passing run (swell C2). Another answer passed in 68 s at
  3.4 to 3.75 per CPU (inbox C2: load 68 to 75 on 20 CPUs).
- **`since: 2026-11-23`** (example 2). slot B5 says the Rust test step rule is not enforced, not
  since when. The date is the day of the answer.
- **Tolerance 20 %** (example 2). The two sources apply 20 % to other measurements: step wall time
  per CI job (ext-02 E4) and queue-wait p90 over 60 minutes of a pool's job log (slot E4). The
  example applies it to the run time of one workflow run and to the queue-wait p90 of a window of
  workflow runs.
- **`runs: 10` of the adoption** (example 2). ext-02 E4 names the median of the last 10 runs for
  the wall time of a test step. § 5 gives N no default. On the window measurement the 10 are
  windows, and no answer counts windows.
- **`window: {length: 1d}`** (example 2). No answer gives a window for the queue wait of a workflow
  run. slot E4 uses 60 minutes of a pool's job log. One day is the stage of the gate that reads
  the window, so two windows of consecutive evaluations share no run.
- **`min_samples: 10`** (example 2). No answer gives one. slot B3 lists 187 runs of the workflow and
  does not give the period. § 11 gives a window length and `min_samples` no default.
- **`runs: 1`** (examples 2, 5). The answers run a gate once; none states a run count for a timing
  check of a whole step. Repeats in use are 3 (surf B5, runbook B4, entity-runtime B6) and 5
  (ext-04 B6).
- **Exception texts** (example 3). Exception ids, case ids, reasons and story ids are illustrative.
  Only the count of three and the dates are from the answers.
- **Paths** (examples 1, 2, 3, 4 and `ratchet.toml`). Report paths, reference `paths`, the `when`
  list and the directory of the job log are illustrative. No answer names them.
