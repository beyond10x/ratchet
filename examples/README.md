# Examples

Worked `ratchet/1` specifications for the first milestone of [`vision.md`](../vision.md), written to
test [`docs/design.md`](../docs/design.md) against cases from survey 1. Design-phase documents:
nothing here runs, and no tool has validated them beyond YAML and TOML syntax.

How to read them:

- Every field name is one that the YAML of `docs/design.md` § 3 shows. The field names are
  proposals, as that document says. Where an example needed a field the design does not show, the
  field is left out and the case is listed under [Design gaps found](#design-gaps-found).
- Some values are not shown in the design. They are listed under
  [Values not shown in the design](#values-not-shown-in-the-design).
- Every number comes from a survey answer. `ux-ui B5` means
  [`research/responses/ux-ui.md`](../research/responses/ux-ui.md), question B5. `F5` is a finding in
  [`research/synthesis.md`](../research/synthesis.md), `gap 2` is a gap in
  [`research/consumer-input-ux-ui.md`](../research/consumer-input-ux-ui.md), `§ 5` is a section of
  `docs/design.md`. Numbers without a source are listed at the end.
- Project names, ids, commands, rule names and reason texts are illustrative unless a source names
  them. Each project name is neutral: an example is built from the answers named, and is not the
  specification of any one repository.
- An accepted value is not in a specification file (§ 3). Where an example has one, this page says
  what its reference record would hold.

| File | Integration (`vision.md`) | Audience | Main sources |
| --- | --- | --- | --- |
| [`ess-ui-behavior.ratchet.yaml`](ess-ui-behavior.ratchet.yaml) | ESS UI behavior | end users of a page | ux-ui, consumer input |
| [`ci-turnaround.ratchet.yaml`](ci-turnaround.ratchet.yaml) | CI turnaround | coding agents, developers | slot, ext-02 |
| [`analyzer-findings.ratchet.yaml`](analyzer-findings.ratchet.yaml) | no new analyzer findings | developers, coding agents, API consumers | runbook, ext-07, ext-02 |
| [`generated-artifact.ratchet.yaml`](generated-artifact.ratchet.yaml) | generated artifact by digest | developers, coding agents, docs readers | canon, runbook |
| [`host-caused-limit.ratchet.yaml`](host-caused-limit.ratchet.yaml) | insufficient evidence on a host-caused limit | coding agents, developers | swell |
| [`ratchet.toml`](ratchet.toml) | local config ([brainstorm](../docs/product-brainstorm.md) § 2) | one checkout | swell |

## 1. ESS UI behavior

[`ess-ui-behavior.ratchet.yaml`](ess-ui-behavior.ratchet.yaml)

**Checks.** One keyboard-only journey on one page, in the local gate:

- an imported ESS UI result with an assertion: no task left incomplete;
- three exact values from `ux-eval@1`: steps against an accepted value, actions per fix and cue
  accuracy against fixed limits;
- page-scoped findings compared by identity against an accepted set.

**Audience.** End users of the page. ux-ui E3: "a task takes more clicks or a control drops below
the fold".

**Sources.**

| In the file | Source |
| --- | --- |
| `completion_miss` at most 0 | ux-ui B5 |
| steps, tolerance 5 % | ux-ui B5 |
| at most 2 actions per fix | ux-ui B5 |
| cue accuracy at least 95 % | ux-ui B5 |
| findings scoped to the page | gap 2; ux-ui D3 (one defect counted 12 times) |
| identity `rule`, `node_path`, `environment` | gap 4; § 3 |
| scenario `keyboard-only` | ux-ui C1 |
| local gate only | ux-ui B3 (no CI, no remote), E4 |

**Expected verdicts.**

- First run: `steps-do-not-rise` and `no-new-page-findings` return insufficient evidence, because
  no reference adopted from earlier evidence exists (§ 5 rule 3). In the round the baseline was
  written from the round's own walks and the first pass "compared a value with itself" (ux-ui B6).
- The round measured 20 of 74 gating tests red and filed 12 findings (ux-ui B4). Adopted in
  observe mode, those 12 are the first accepted set.

**Left out, because the design cannot express it.** The layout shift tolerance of 0.01 (gap G8);
`false_complete` and the other metrics of the 14 per walk (G4); the other 29 walks (G5); "serious
and critical" as a filter (G11); the trade-off that moved one value from 23 to 0 and made 20 of 168
worse (G3); the sub-tasks that were never done and counted as no miss (ux-ui C1; G10).

## 2. CI turnaround

[`ci-turnaround.ratchet.yaml`](ci-turnaround.ratchet.yaml)

**Checks.** The run time of the candidate's CI gate workflow against a fixed limit and an accepted
value; the UI test step against its budget; the Rust test step in report mode. Queue wait of the
workflow and the run time of the local gate have no requirement, so they are in observe mode.

**Audience.** Coding agents and developers who wait for the verdict (F3: the top cost in 24 of 26
answers).

**Sources.**

| In the file | Source |
| --- | --- |
| workflow limit 30 min | slot B5 (`timeout-minutes` 30) |
| tolerance 20 % | ext-02 E4 (step wall time per CI job, +20 %); slot E4 (20 %, queue wait) |
| UI step at most 120 s | slot B5 |
| Rust test step 120 s, not enforced | slot B5 |
| `queue-wait` apart from `run-time` | slot B2 (job log); § 3 |
| commands | slot B1, B2 |
| pinned toolchain | slot B1 |
| merge gate judged in CI | slot D1 ("use the forge as the full verdict", inferred there) |

**Reference record (not in the file).** `ci-gate-turnaround`: 5.4 min, the median of 160 successful
runs out of 187 listed (slot B3). ext-02 E4 asks for the median of the last 10 runs on the default
branch as the source of such a value. The answer does not say whether 5.4 min includes queue wait.

**The milestone on this example.**

1. Observe: the two assessments without a requirement record a series. Local `task check`: p50
   164 s, p90 422 s, 27 of 40 runs exit 0 (slot B2).
2. Adopt: 5.4 min becomes the accepted value. Allowed: 5.4 × 1.2 = 6.48 min, and under 30 min.
3. Reject: a run of 12.3 min (the p90 of slot B3) under qualifying conditions fails with observed
   12.3 min, allowed 6.48 min.
4. Improve: repeated runs under 5.4 × 0.8 = 4.32 min make the reference stale, and
   `ratchet reference propose` collects them (§ 5 rule 4).

The UI step takes about 45 s on the forge and passed 9 of 19 local runs at host load 50 to 170
(slot C2). Local evidence does not qualify for this gate.

**Left out.** The workflow name and the job log path (G13); how 5.4 min is adopted (G1, G2); a
tolerance in seconds, which § 5's own 6-minute example uses (G8).

## 3. No new analyzer findings

[`analyzer-findings.ratchet.yaml`](analyzer-findings.ratchet.yaml)

**Checks.** Three identity sets:

- lint findings, which must be none;
- files that nothing refers to, compared with an accepted set from the first run;
- failing conformance cases on a deployed build, compared with an accepted set, with three dated
  exceptions. § 7 applies the same comparison to cases.

**Audience.** Developers and coding agents for the source tree; API consumers for the contract.

**Sources.**

| In the file | Source |
| --- | --- |
| lint blocks on any finding | runbook B1; spindle B5; substrate B5 |
| lint and the file check run only locally | runbook B3 |
| `task check:unreferenced` | runbook B1 |
| no new failure outside an accepted list | ext-07 B5 |
| three known-failing cases | ext-07 C3; ext-02 C3 |
| owner is a story reference | ext-07 B6; ext-02 B6 |
| `expires: 2026-11-30` | ext-07 C3, ext-02 C3: "one week out" from 2026-11-23 |

**Reference record (not in the file).** `no-new-unreferenced-files`: the 26 files the first run
found, kept "as unexamined" (runbook C3).

**Expected verdicts.**

- The list has 27 lines now (runbook C3). A candidate that adds the 27th file fails, and the result
  names the file. The answer gives no reason, owner or date for that line, so it cannot be written
  as an exception.
- After 2026-11-30 the three exceptions no longer apply and the three cases count as new failures.
  Today "the review-by dates exist; I have not seen one enforced" (ext-07 C3).
- In CI the two source checks are reported as not run (§ 3), not as passed.

**Left out.** A scan allowlist entry with a written reason and no end date (substrate C3;
ext-08 C3: 27 lines; G12); the report path of each tool (G13); a severity filter (G11).

## 4. Generated artifact by digest

[`generated-artifact.ratchet.yaml`](generated-artifact.ratchet.yaml)

**Checks.** Committed files equal a fresh run of their generator, by digest, tolerance 0. A fast
check runs before merge, a full regeneration before promotion.

**Audience.** Developers, coding agents and docs readers. F17: 20 answers say good quality means
documents, specification, generated files and code say the same thing.

**Sources.**

| In the file | Source |
| --- | --- |
| `task docs-check`, 18 generated files | canon B1 |
| `task test-slow` regenerates and compares bytes | canon B6 |
| pinned tool | canon C2 |
| fast check and slow lane as two checks | runbook B1, B6 |
| the practice | F5 (21 answers) |

**Expected verdicts.**

- A committed file differs from a fresh generation: fail, naming the file.
- The candidate regenerates the file in the same change: pass. It is recorded as a reference change
  and needs no authorization (§ 5).
- The specification tool on the path is 0.98.0 and the pin is 0.97.4: insufficient evidence, next
  step on the assessment. Today that state fails 47 tests (canon C2).

**Left out.** The count of 18 files as coverage (G10); the pinned version (G19); the merged tree
as the target, although a merge can leave a file stale without a conflict (runbook C1; G20); a
slow lane that runs only when its sources changed (runbook B1; G16).

## 5. Insufficient evidence on a host-caused limit

[`host-caused-limit.ratchet.yaml`](host-caused-limit.ratchet.yaml)

**Checks.** The test steps of a release gate within 120 s and each test within 60 s, as run time
without queue wait, with a bound on host load as a qualifying condition.

**Audience.** Coding agents and developers. swell E3: "the gate takes longer or its verdict depends
on load".

**Sources.**

| In the file | Source |
| --- | --- |
| test steps at most 120 s | swell B2, B5 |
| a test at most 60 s | swell B2, B5 |
| pinned toolchain | swell B1 |
| queue wait recorded apart | swell B2 (`waited 1490s ... ran 317s`); ux-ui C2 |
| local and CI run the same task | swell B1 |
| `host_load_per_cpu` 2.125 | swell C2: load 34 on 16 cores; see [Numbers without a source](#numbers-without-a-source) |

**Expected verdicts**, on the two runs of swell C2:

| Run | Host load | Per CPU | Observed | Verdict |
| --- | --- | --- | --- | --- |
| Gate of release 0.7.0 | 65 on 16 cores | 4.06 | 194.7 s | insufficient evidence: load outside the plan; next step on the assessment |
| The same steps | 34 | 2.125 | 94.3 s | pass |

- A qualifying run that reaches 120 s is a fail with the observed value "at least 120 s" (§ 3).
- A test killed at 60 s above the load bound is insufficient evidence. It is not a failed test and
  not a result about the subject (§ 3; ext-06 C2: 3 of 6 runs in one day ended with a verdict that
  a killed step produced).
- A round of 1912 s with a browser run of 108.6 s (ux-ui C2) is judged on 108.6 s.

**Left out.** That the forge's run decides when the local one cannot (swell C3; G15); the runner,
which differs between the two classes (G14).

## `ratchet.toml`

[`ratchet.toml`](ratchet.toml) has the six sections of the brainstorm § 2. It is the local config
of a workstation checkout of example 5.

- `skip_sampled_when_load_above` repeats the load bound of the plan.
- `observe_only` names one requirement of that file.
- The catalog entry is the brainstorm's placeholder. No `ratchet-presets` repository exists (the
  link does not open), and `<commit>` is not a commit.
- A run under this file reports the skipped requirements as "skipped locally by ratchet.toml",
  never as pass (brainstorm § 2; G22).

## Values not shown in the design

The fields are the design's. These values are not in the YAML of § 3:

| Field | Value | Where it comes from |
| --- | --- | --- |
| `assessor` | every id except `ux-eval@1` and `command-timing@1` | placeholder |
| `subjects.*.kind` | `codebase`, `api-operation` | § 1, prose |
| `audiences` | `end-user`, `api-consumer`, `docs-reader` | free labels |
| `target.kind` | `workflow-run` | § 1, prose |
| `target.environment` | `staging` | § 3, prose |
| `measurement.scope` | `test` | § 1, prose |
| `measurement.scope` | `file` | not in the design |
| `measurement.boundary` | `queue-wait` | shown under `also_record` only |
| `measurement.unit` | `min`, `steps`, `actions`, `percent` | not in the design |
| `condition.operator` | `gte` | not in the design |
| `reference.kind` | `generated-reference` | § 1 and § 5, prose |

Three shapes are also not shown: a requirement with a `reference` and no `condition`
(`steps-do-not-rise`, both requirements of example 4), a sampled measurement with `runs: 1` and no
`aggregation` (examples 2 and 5), and `conditions` on a snapshot (example 2).

## Design gaps found

Each gap: what an example needed, what `docs/design.md` lacks, and a proposed fix. Items that
[`research/candidate-presets.md`](../research/candidate-presets.md) § 6 already lists are marked
`presets n`.

**G1. Ratchet policy.**
- Needed: "the median of the last 10 runs" as the source of an accepted value (example 2, ext-02
  E4); an improvement written into the baseline in the same merge (example 1, ux-ui B6).
- Lacks: § 1 defines a ratchet policy and `vision.md` lists it as one of five parts. No field
  carries it; `reference` has `kind` and `tolerance`.
- Fix: `reference.adoption: {from: trusted-revision, runs: 10, aggregation: median}` for sampled
  values and `adoption: same-change` for exact ones.

**G2. Reference record.**
- Needed: the adopted value in every example (5.4 min, 26 files, 12 findings).
- Lacks: § 6 lists the context of a reference change. No document shape, no file location.
- Fix: one illustrative record next to the YAML of § 3: requirement, kind, value or items,
  conditions, evidence ids, authorizing revision.

**G3. Trade-off.**
- Needed: one change that moved a value from 23 to 0 and made 20 of 168 worse (example 1, gap 1).
- Lacks: § 5 describes the record and shows no shape. It lists requirements, and the 168 values
  are scenario and key pairs inside one requirement.
- Fix: `trade_off: {gains: [...], loosens: [...], reason, owner}` in the reference change, each
  entry `{requirement, scenario, value}`.

**G4. Several outputs from one run.**
- Needed: 14 metrics per walk (example 1); step time and time per test from one `task test`
  (example 5); run time and queue wait of one workflow run (example 2).
- Lacks: `measurement` has one `output`. A second output is a second assessment with the same
  assessor, target and observation, and nothing says the tool runs once.
- Fix: a `measurements` map under one assessment, with requirements naming
  `<assessment>.<measurement>`; or one sentence that equal plans share a run.

**G5. Several scenarios in one plan.**
- Needed: 30 walks (example 1; ux-ui B4).
- Lacks: `scenario` is one string.
- Fix: `scenario` takes a list or a pattern, and the scope keeps one result per journey.

**G6. Direction of a comparison.**
- Needed: cue accuracy at least 95 %; "lower is better" for steps (example 1).
- Lacks: the operators shown are `lt`, `lte` and `no-new-items`. A requirement with only a
  `reference` does not say which way is worse. (`presets 3`)
- Fix: list the operators, with `gt`, `gte` and `eq`; add `better: lower | higher` to the
  measurement.

**G7. Operators on an identity set.**
- Needed: "no finding at all" on a set (example 3, lint); "no accepted case fails or stops
  running" (§ 4).
- Lacks: whether `lte` on a set compares its size; an operator for lost items. Example 3 inverts
  the set to failing cases, which does not see a deleted case. (`presets 3`)
- Fix: state that `lt` and `lte` on a set compare the item count; add `no-lost-items`.

**G8. Absolute tolerance.**
- Needed: layout shift 0.01 (example 1; ux-ui B5, spindle B5, slot B5); the 30-second tolerance of
  § 5's own example (example 2).
- Lacks: `tolerance` shows `percent` only.
- Fix: `tolerance: {absolute: 0.01}`, allowed beside `percent`; the wider one applies.

**G9. An assertion as a measurement.**
- Needed: "import a structured result and enforce an assertion" (§ 7, integration 1).
- Lacks: § 1 names an assertion and "a scenario passing". No output or operator for a verdict;
  example 1 counts misses and writes `lte 0`.
- Fix: say that an assertion is a count of failed expectations with `lte 0`, or add
  `operator: passes`.

**G10. Coverage keys.**
- Needed: "not run" at 0 (example 1; ux-ui C1); 18 files and 4 crates executed (examples 4, 3); an
  exact set of 79 executed ids (spindle B5).
- Lacks: § 3 names executed, skipped, not run and unsupported, and an exact set. The YAML shows
  `skipped` and `unsupported`, and does not say whether a number is a maximum.
- Fix: fix the four keys (`executed`, `skipped`, `not_run`, `unsupported`), each a number or
  `{min, max}`, and `executed_ids` naming a file.

**G11. A filter on findings.**
- Needed: serious and critical findings only (example 1; ux-ui B5, slot B5).
- Lacks: § 1 says "of a specified severity". No field.
- Fix: `measurement.filter: {severity: [serious, critical]}`.

**G12. An acceptance without a date.**
- Needed: an allowlist entry with a written reason that is a permanent false positive (example 3;
  substrate C3, ext-08 C3); a failure accepted until a finding is fixed (spindle C3).
- Lacks: an exception must expire on a date. An item of an accepted set carries no reason.
  (`presets 5`)
- Fix: an item of an accepted set may carry `reason` and `owner`; `expires` also takes an event,
  `{when: closed, ref: <owner reference>}`.

**G13. Inputs of an assessor.**
- Needed: the workflow to read and the job log (example 2); a report path (examples 1, 3); an
  exclusion inside a measurement (ux-ui C3).
- Lacks: § 4 says an assessor declares configuration inputs. `observation` shows `command`,
  `scenario` and `workload` only. (`presets 1`)
- Fix: `observation.inputs: {...}`, validated against what the assessor declares.

**G14. Conditions per target class.**
- Needed: one plan for local and CI evidence, with a load bound for the workstation and a runner
  for CI (examples 2, 5).
- Lacks: one `conditions` block for all of `environment: [local, ci]`. It is also not said when
  host load is read (swell gives one value, inbox C2 a range of 82 to 112).
- Fix: `conditions` keyed by environment class. Define host load as the mean 1-minute load over the
  run divided by the CPU count, and record its minimum and maximum.

**G15. Which evidence decides.**
- Needed: the local run is insufficient evidence and the forge's run passes; the rule in use is
  "the forge's run judges the budget" (example 5; swell C3; F10: 9 answers get two results for one
  tree).
- Lacks: `qualifying_environments` is a list. It does not say whether one pass clears the
  requirement or whether a fail in another class blocks.
- Fix: `evidence: any | all | <class>` per gate, default `all`.

**G16. A requirement that applies to some changes.**
- Needed: a full regeneration only when its sources changed (example 4; runbook B1).
- Lacks: `requires` has `requirement`, `mode` and `since`.
- Fix: `{requirement: x, when: {changed: [paths]}}`. Where it does not apply, the result says "not
  applicable", not pass.

**G17. Generated reference.**
- Needed: the reference kind and the committed paths (example 4).
- Lacks: § 5 defines the kind. The YAML shows `accepted-value` only, and no field names the files.
  (`presets 3, 9`)
- Fix: `reference: {kind: generated-reference, paths: [...]}`; digest and tolerance 0 follow from
  the kind.

**G18. A committed file of measured results.**
- Needed: a file of conformance counts that a full run writes and a digest of its sources guards
  (swell B4, B6; ext-02 C1).
- Lacks: such a file fits both kinds. As a generated reference the candidate may rewrite it, and a
  regression goes in with it.
- Fix: in § 5: a file is a generated reference only when its generator reads sources. A file made
  by running the candidate is an accepted value.

**G19. Tool pin.**
- Needed: the generator at 0.97.4 (example 4; canon C2).
- Lacks: `toolchain: pinned` names no tool, no version and no pin file. § 3 lists "tool version"
  as a condition in prose.
- Fix: `conditions: {tools: {<name>: <version or pin file>}}`.

**G20. The merged tree as target.**
- Needed: the comparison on the merge result (example 4; runbook C1; § 5 says so).
- Lacks: `selection` shows `candidate` only.
- Fix: `selection: merge-result`.

**G21. One sample per candidate.**
- Needed: one workflow run and one gate run per candidate (examples 2, 5). Three runs of a 120 s
  step exceed the budget they measure.
- Lacks: § 3 asks for N runs and an aggregation. § 5 judges one 7-minute run.
- Fix: say that `runs: 1` without `aggregation` is valid for a gate, and that only an adoption
  needs repeats.

**G22. A local skip is not a verdict.**
- Needed: "skipped locally by ratchet.toml" (`ratchet.toml`, brainstorm § 2).
- Lacks: § 5 has three verdicts and no local config. The skip rule of the file repeats the load
  bound of the plan with no unit, and several `paths` have no rule for how files or ids combine.
- Fix: a local skip is coverage "not run" with the cause "local config" and the verdict
  insufficient evidence. The skip rule reads the bound from the plan.

**G23. A requirement about the host.**
- Needed: a limit on queue wait (example 2 leaves it in observe mode; ext-03 C3, ext-08 C3).
- Lacks: § 3 allows a requirement per part and an "operational gate". A gate has a stage and no
  kind, and queue wait is not attributable to a candidate. (`presets 6`)
- Fix: `gates.*.kind: candidate | operational`. An operational gate never blocks a merge.

**G24. Evidence that exists after the stage.**
- Needed: the run time of the workflow that itself runs `ratchet evaluate` (example 2).
- Lacks: a `pre-merge` gate evaluated inside the workflow cannot read that workflow's total time.
- Fix: say in § 7 that the assessor runs in a later job or reads the last finished run, and which
  stage that gate has.

**G25. Value lists.**
- Needed: scope `file`, target kind `workflow-run`, subject kinds, units, a release stage (all
  examples).
- Lacks: § 1 and § 3 give examples of each and do not say whether the lists are closed.
  (`presets 2, 7`)
- Fix: publish each list in § 3, or state that they are open strings checked against the
  assessor's declaration.

## Numbers without a source

- **Host load bound** (`host_load_per_cpu: {max: 2.125}`, `skip_sampled_when_load_above = 2.125`).
  No answer states a load that qualifies a timing run. 2.125 is the load of one passing run
  (swell C2). Another answer passed in 68 s at 3.4 to 3.75 per CPU (inbox C2: load 68 to 75 on 20
  CPUs).
- **`since: 2026-11-23`** (example 2). slot B5 says the Rust test step rule is not enforced, not
  since when. The date is the day of the answer.
- **Tolerance 20 % on workflow run time** (example 2). The two sources apply 20 % to other
  measurements: step wall time per CI job (ext-02 E4) and queue-wait p90 (slot E4).
- **`runs: 1`** (examples 2, 5). The answers run a gate once; none states a run count for a timing
  check of a whole step. Repeats in use are 3 (surf B5, runbook B4, entity-runtime B6) and 5
  (ext-04 B6).
- **Exception texts** (example 3). Case ids, reasons and story ids are illustrative. Only the
  count of three and the date are from the answers.
