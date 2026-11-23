# Ratchet

**Proposed repository:** `beyond10x/ratchet`  
**Status:** Design proposal  
**Evidence:** revised from survey 1 of 2026-11-23 ([synthesis](../research/synthesis.md), [consumer input from `ux-ui`](../research/consumer-input-ux-ui.md)). § 8 lists each change and the finding it rests on.

Ratchet specifies how to specify software quality. It defines a versioned YAML format for declaring what quality means for a project, how to assess it, and what evidence a candidate must produce before it can advance. The repository ships the specification, a CLI, a catalog of reusable YAML presets, and assessors that run or wrap existing tools. An agent or developer can use the same format to add a measurement specific to their repository.

The primary outcome is **regression prevention**. A brownfield team can start by measuring current quality, turn selected findings into enforceable requirements, and use the same evidence to evaluate improvements and track them over time.

Survey 1 asked 26 agent sessions how their projects track quality. Three practices are common: a committed generated file compared by bytes (21 answers), a committed file of accepted values compared by the project’s own tool (18), and a written time budget for the test step (21). The survey also shows where they fail. A check failed with nothing wrong in 23 answers. A passing result covered less than it appeared to in 10. In 18, a loosening was not tightened again or nobody knows whether it was. This revision makes the format carry what those cases lacked: the kind of a measurement, the conditions it was observed under, how much of the plan ran, and who may change a reference.

## 1. Domain language

Quality has a **subject** and an **audience**. The subject is the thing assessed, such as a search interaction, an API operation, a codebase, or a release workflow. The audience experiences the quality. It can include users, developers, coding agents, maintainers, or operators. The same subject can matter to several audiences for different reasons.

A coding agent that builds the project is an audience with subjects of its own: the gate, the text of an error or refusal, and the instruction file. In 20 of 26 answers, quality is worse for that audience when the gate gets slower or fails for a reason outside the change. In 7, it is worse when an error names no cause and no next step (synthesis § 3).

| Term | Meaning |
| --- | --- |
| Quality specification | A project’s versioned declaration of subjects, audiences, requirements, assessment plans, and gates. |
| Quality requirement | A condition the project expects to hold, such as p95 latency below 100 ms, zero new analyzer findings of a specified severity, or a scenario passing. |
| Measurement | The value or assertion being evaluated, with a defined kind, unit, scope, and aggregation where applicable. |
| Measurement kind | **Exact** or **sampled**. An exact measurement gives the same value for the same input under the same conditions: a count, bytes, instructions, a digest, a modelled metric. A sampled measurement varies between runs: wall time, or the pass rate of a subject that answers differently per run. |
| Scope | The unit one result belongs to: a state, a journey, a page, a test, a variant, or a run. |
| Identity set | A set of items with stable identities, such as findings or passing cases, compared item by item. |
| Assessment plan | The instructions for collecting evidence. It binds a measurement to an assessor, a target, and observation conditions. |
| Assessor | A tool or adapter that runs a check or reads an existing result and returns structured evidence. |
| Target | The concrete repository revision, build, deployed service, workflow run, or telemetry population from which evidence is collected. |
| Evidence coverage | How much of the plan a run executed: counts of executed, skipped, not run, and unsupported items. |
| Protected reference | An accepted state used for regression comparisons. It is either a **generated reference**, a committed artifact that a generator reproduces and that is compared by bytes or digest, or an **accepted value**, a measured value or identity set. It has a revision, the conditions that produced it, and evidence supporting its adoption. |
| Gate | A decision at a workflow stage, such as merge or promotion, that requires specified verdicts before a candidate can advance. A gate lists each requirement as enforced or report-only. |
| Ratchet policy | The rule for when an evidenced improvement can tighten a requirement or replace its protected reference. |
| Exception | An accepted departure from a requirement: a waived finding, a known-failing case, a raised limit. It carries a reason, an owner reference, and an expiry date. |
| Trade-off | One reference change that accepts worse values for some requirements and names the better values it buys. |

KPI, SLI, SLO, and SLA can keep their usual meanings. A KPI is a selected measure of an important outcome. A service SLI can be represented as a measurement and an SLO as an objective over a defined window. An SLA adds a customer commitment. These are useful domain concepts within the model. General quality requirements also cover static checks, behavioral assertions, and development workflows.

## 2. What the repository ships

| Surface | Responsibility |
| --- | --- |
| Specification | Defines YAML document shapes, reference resolution, measurement kinds and scopes, typed comparisons, evidence and coverage requirements, exceptions, and gate semantics. Publishes a machine-readable schema for authoring and validation. |
| CLI | Resolves presets, validates configuration, runs or imports assessments, evaluates gates, checks exception expiry, and writes human-readable and machine-readable results. It can also generate a block of numbers in a document from records. |
| Preset catalog | Supplies versioned YAML instances of the specification for common concerns. Each preset declares its inputs, expected evidence, and defaults where they are meaningful. |
| Assessors | Built-in or separately packaged adapters for scenario runners, analyzers, benchmarks, CI systems, telemetry, reviews, and repo-specific tools. |
| Agent integration | A skill or plugin guides agents through choosing presets, authoring custom checks, running them, and interpreting results. It uses the same specification and CLI as CI. |

Project specifications live alongside the project code. A project pins the presets and assessor versions it uses, binds them to its subjects and targets, and supplies thresholds that fit its workload. Presets use the same schema as locally authored checks, so teams can inspect them, configure their declared inputs, or use them as examples for a custom check. Validation resolves references and catches mismatched measurement kinds, units, scopes, and target bindings before a run.

## 3. Requirements, evidence, and targets

A requirement describes **what must hold**. An assessment plan describes **how we can know**. For example, “search request p95 is below 100 ms” belongs in a requirement. The endpoint or scenario, timing boundaries, workload, dataset, minimum sample count, and environment belong in the assessment plan. A gate identifies which requirements are mandatory at a given stage and which evidence qualifies for that decision.

| Observation | What it answers | Example |
| --- | --- | --- |
| Snapshot | What holds for this revision, build, or run? | Resolved dependency count at a commit, current code analysis findings, or the duration of a particular CI workflow run. |
| Controlled run | How does this candidate behave under a repeatable workload? | Browser search p95 on an ephemeral deployment with fixed data, traffic, and sample requirements. A run can collect many samples and still produce one result for the candidate. |
| Time window | What happened across a defined population and interval? | Successful requests over a rolling 30-day production window, or median CI turnaround across seven days of eligible workflow runs. |

**History** is a separate concern. Storing snapshots and controlled runs over time creates a trend. A windowed measurement specifies the time interval and population as part of the evidence itself.

Record both the **expected target** in the plan and the **resolved target** in the evidence. For source checks, this may be a commit and lockfile. For a deployed benchmark, it may be an ephemeral environment ID, the candidate’s artifact digest, and the workload version. For production telemetry, it may be a service, region, traffic filter, deployment or cohort identifier where available, and exact window bounds. Local, CI, ephemeral, staging, and production are explicit target classes. A pre-release gate can use an ephemeral environment with declared production-like conditions. A production window with mixed revisions describes that population and can support an operational gate, such as pausing a rollout. Candidate-specific verdicts require evidence attributable to that candidate.

The local gate and CI are different targets, even for the same tree. 14 answers report a different check set or a different result between the two (F10). Evidence records where it was produced: the target class, the runner, and the toolchain. A gate names the classes whose evidence qualifies. A requirement that a location cannot assess is reported there as not run. It is not left out of the list, and the run does not exit 0 as if it had passed (ext-07 D3).

### Measurement kind and observation conditions

A measurement declares its **kind**. The kind decides how many runs are needed, which conditions the evidence records, and what tolerance makes sense. The survey shows what happens when the two kinds share one rule: 16 answers report a time limit hit because of host load or queue wait (F2), and 8 answers already use counts of work because those do not move with load (F4).

| | Exact | Sampled |
| --- | --- | --- |
| Examples | Finding count, bytes, instructions, syscalls, allocations, process starts, a digest, a modelled UI metric | Wall time, a latency percentile, throughput, the pass rate of a subject that answers differently per run |
| Runs | One, unless the plan says more | N runs or N samples, declared. The evidence carries the count. |
| Aggregation | None, or a sum within the declared scope | Declared: median, percentile, best of N, or pass rate |
| Tolerance | 0 by default. A small declared band where the tool varies. | A declared band |
| Conditions that decide comparability | Toolchain, loader and libraries, CPU, tool version | Host load, runner, cache profile, toolchain |

Sampled evidence states the conditions it was observed under. The plan declares the conditions that qualify. Evidence observed outside them does not qualify, and the verdict is insufficient evidence. This covers a limit that was crossed: when host load is above the declared bound, the result says nothing about the candidate. In one answer a release gate failed on 194.7 s against a 120 s budget at load 65, and the same steps took 94.3 s at load 34 (swell C2). `ratchet validate` reports a sampled measurement that declares no conditions.

When the measurement is a duration, the assessor’s timeout and the requirement’s limit can be the same number. The rule does not change. Under qualifying conditions, a run that reaches the limit is a fail with the observed value “at least the limit”. Outside them it is insufficient evidence. A killed run is never recorded as a result about the subject, such as “not reproduced” (ext-06 C2).

A duration has parts. Evidence records **queue wait** and **run time** as separate values where the runner or build pool reports them, and the measurement’s `boundary` says which part the requirement is about. Each part can have its own requirement (ext-03 C3, ext-08 C3). Without the split, one round reported 1912 s for a browser run of 108.6 s (ux-ui C2).

A wider tolerance does not solve noise. A timing limit set to 2.0x, after an unchanged build moved up to 1.94x, would miss a 1.68x regression (entity-runtime C2, C3). The format offers three other answers:

- **An exact measurement of the same subject**, where one exists. CPU seconds moved 60 % with host load and instructions under 2 % (surf C3).
- **A median of N runs**, with N in the evidence. Repeats are in use in 4 answers (F9; consumer gap 3).
- **A paired run.** The assessor measures the reference and the candidate interleaved on the same runner and compares the two. No stored value has to match the present host (entity-runtime B6, ext-04 B6).

Exact measurements have conditions too. Instruction and syscall counts depend on the C library, the compiler version, and the CPU, so a system update can refuse a merge that changed no code (ext-04 D2). The plan names those conditions and the evidence records them. A mismatch with the reference’s conditions is insufficient evidence, and it starts a new evidence series as § 5 describes for protocol changes. A tool version other than the pinned one is handled the same way (canon C2).

Cost has units of its own: money per run or per day, and model calls per run. 6 answers bound or record money for runs that call a paid model, and in 3 a crossed cap refuses or stops the run (F16).

### Scope and aggregation

A result belongs to one **scope**: a UI state, a journey, a page, a test, a design variant, or a whole run. The assessor reports each result at the scope where it was observed. Aggregation is declared per measurement and does not repeat a result outside its scope. A page-level accessibility finding is one finding for the page, however many journeys visit that page. In the first consumer’s round, one page-level defect was summed per journey and counted 12 times (ux-ui D3; consumer gap 2).

The same holds for time. A limit per test and a limit for the test step are two requirements at two scopes; 19 answers write both (F8). A pass rate over the last 10 runs of one scenario aggregates the run scope per scenario (ext-07 E4).

### Evidence coverage

Every assessment run reports how much of the plan it executed: counts of **executed**, **skipped**, **not run**, and **unsupported** items, next to passed and failed. The plan declares the coverage that qualifies, as bounds on those counts or as an exact set of executed item ids (spindle B5). A run below it is insufficient evidence. That includes a run that executed a subset of what its name claims.

10 answers report a passing result that covered less than it appeared to: 96 tests skipped for a missing prerequisite, 87 of 119 scenarios unsupported and still passing, “tests pass” evidence that covered 3 of 20 crates (F9). 9 answers already put a number on coverage. An assessor that prints “not run” and exits 0 has returned no evidence. A coverage count can also be a measurement with an accepted value, so that the number of ignored tests may not rise (ext-04 C3).

### Illustrative project YAML

The field names and commands in this document are proposals. This example shows a sampled measurement against an absolute limit, an identity set scoped to a page, and a sampled duration compared with an accepted value under declared conditions.

```yaml
format: ratchet/1
project: partner-portal

subjects:
  partner-search:
    kind: user-interaction
    audiences: [portal-user]
  test-step:
    kind: development-workflow
    audiences: [coding-agent, developer]

assessments:
  search-request-latency:
    subject: partner-search
    assessor: browser-request-timing@1
    target:
      kind: deployment
      environment: ephemeral
      selection: candidate
    observation:
      kind: controlled-run
      scenario: ess-ui:partner-portal/partner-search
      workload: workloads/partner-search.yaml
      min_samples: 200
      conditions: {runner: dedicated}
    measurement:
      kind: sampled
      output: search_request_duration
      boundary: request-start-to-response-complete
      scope: journey
      aggregation: p95
      unit: ms

  search-ui-findings:
    subject: partner-search
    assessor: ux-eval@1
    target: {kind: revision, environment: [local, ci]}
    observation:
      kind: snapshot
      scenario: ess-ui:partner-portal/partner-search
      coverage: {skipped: 0, unsupported: 0}
    measurement:
      kind: exact
      output: findings
      scope: page
      identity: [rule, node_path, environment]

  test-step-time:
    subject: test-step
    assessor: command-timing@1
    target: {kind: revision, environment: ci}
    observation:
      kind: controlled-run
      command: task test
      runs: 3
      conditions:
        runner: ci-standard
        toolchain: pinned
        cache: warm
        host_load_per_cpu: {max: 1.0}
      coverage: {skipped: 0}
    measurement:
      kind: sampled
      output: duration
      boundary: run-time
      also_record: [queue-wait]
      scope: run
      aggregation: median
      unit: s

requirements:
  search-latency-budget:
    assessment: search-request-latency
    condition: {operator: lt, value: 100, unit: ms}
  no-new-search-findings:
    assessment: search-ui-findings
    condition: {operator: no-new-items}
    reference: {kind: accepted-value}
  test-step-budget:
    assessment: test-step-time
    condition: {operator: lte, value: 120, unit: s}
    reference: {kind: accepted-value, tolerance: {percent: 10}}

gates:
  merge:
    stage: pre-merge
    qualifying_environments: [ci]
    requires:
      - no-new-search-findings
      - {requirement: test-step-budget, mode: report, since: 2026-11-23}
  promote:
    stage: pre-promotion
    requires: [search-latency-budget]

exceptions:
  - requirement: no-new-search-findings
    item: {rule: target-size, node_path: /search/filters/reset, environment: {viewport: narrow}}
    reason: The filter bar is replaced in the next release.
    owner: story:filter-bar
    expires: 2026-12-15
```

The sample count illustrates a project choice. A real plan also defines how the assessor selects the request, handles errors and timeouts, and versions the workload. For user-perceived latency, the measurement would instead span the input action to the expected result becoming visible. Both measurements can use the same interaction.

The accepted values are not in this file. They live in reference records that the `ratchet reference` commands write (§ 5, § 6). The specification names the kind of reference and the tolerance.

## 4. Presets and custom assessors

The catalog should grow across product quality and the quality of the software factory itself.

| Domain | Candidate preset families | Evidence source |
| --- | --- | --- |
| Web | UI behavior, keyboard interaction, accessibility, actions per task, page or interaction latency, bundle size | ESS UI reports, `ux-ui` evaluations, browser runners, scanners, build outputs |
| Backend | Contract conformance by case, latency, error rate, throughput, cost per operation (instructions, syscalls, allocations, bytes) | ESS conformance reports, load runners, counters and profilers, service telemetry |
| Code quality | Static analysis findings, lint, complexity, coverage, dependency count | Existing analyzers, coverage reports, lockfiles or build graphs |
| Consistency | Generated files match their generator; numbers in documents match records | Generators, Ratchet records |
| Development | Clean and incremental build time, test turnaround, time per test and per test step, gate run time and queue wait | Build and test commands under a declared toolchain and cache profile, build pool logs |
| CI and release | Time to first actionable verdict, total workflow duration, queue wait, release lead time | Workflow stage events, CI runs, release records |
| Spend | Money and model calls per run or per day | Run logs, provider usage reports |
| Review | Open findings of an adversarial or independent review at a revision | Review records |

For code quality, an assessor can wrap the project’s existing tool or import a report already generated by CI. Preserve findings with rule IDs, severity, and locations so the agent can act on them. A brownfield project can gate on **new findings** by comparing stable finding identities against an accepted set. A total count alone can let a new violation hide behind the removal of an unrelated one.

The same comparison applies beyond analyzer findings (F7, F9, F18). A total of passing cases has the weakness of a total of findings: “a new pass beside a pass turned fail would keep the total” (swell D3). A conformance or test report can be compared as an identity set: no case in the accepted set fails or stops running. The answers name three such identities: the run lines of a conformance suite (swell E4), the ids of executed scenarios (spindle B5), and scenario ids compared between two jobs (ext-05 B7). For UI findings the identity is the rule id, the `ess-ui` node path, and the environment: viewport, theme, and input mode (consumer gap 4). An assessor declares the identity key of each set it returns.

**Reviews as assessors.** 11 answers report a regression found by a review after the gates had passed, and 23 name something a machine cannot check (F13, F17). A review assessor imports a review’s findings as an identity set tied to the revision the review judged. A requirement can then ask for no open finding above a severity at the candidate revision. A review of another revision does not qualify. Review results are otherwise “not re-run later” (inbox D2). A closed finding names the test that failed before its fix (ux-ui E4), and from then on an automated assessor carries it.

**Proof that a check can fail.** A check that has never returned fail has the standing of a first reference compared with itself. 8 answers plant a defect or test the check itself: 65 planted defects a gate must refuse, 8 broken copies of a manifest (F15). A requirement can declare planted defects, which are inputs the assessor must refuse. `ratchet prove` runs them and records how many were refused. A gate report marks an enforced requirement with no proof record and no recorded fail as unproven.

A custom assessor can run as a project command or import a structured report. It declares supported targets, configuration inputs, output types, and a version. For each output it also declares the kind, the scope, the identity key of a set, and the coverage counts it reports. It returns evidence in the same format as bundled assessors. The CLI validates those outputs and applies the project’s comparison rules. This keeps custom measurements usable in the same gates and history from their first run.

## 5. Agent workflow and enforcement

1. **Baseline.** Add presets or custom checks in observe mode. Collect comparable evidence and use audience impact to prioritize the requirements worth protecting. A first reference is adopted from this evidence, not from the run it is first compared with.
2. **Protect.** Apply absolute limits, regression comparisons, or both. For every candidate, run fast checks locally or in early CI, then gather deployment or windowed evidence at the stage that can produce it.
3. **Improve.** Use candidate and reference evidence to confirm the gain. Adopt a better reference when it meets the ratchet policy’s evidence criteria.
4. **Track.** Retain runs, gate decisions, and reference changes so developers and agents can identify where quality is improving or degrading.

A lower-is-better CI check might start with a protected reference of **6 minutes** and a **30-second regression tolerance** under a declared runner and cache profile. A candidate taking **7 minutes** fails. A candidate taking **5 minutes** can pass, and repeated comparable results can support tightening the reference to 5 minutes. The accepted reference stays fixed between adoption decisions, so the same tolerance cannot accumulate across successive merges. The declared conditions are part of the comparison: a 7-minute result on an overloaded runner, or one whose 7 minutes include queue wait, is insufficient evidence and not a fail.

### Protected references

The survey shows two kinds of reference in use, with different update rules (F5, F6).

| | Generated reference | Accepted value |
| --- | --- | --- |
| What it is | A committed file that a generator reproduces: a schema, generated documentation, a CLI snapshot | A measured value, a count, or an identity set recorded from evidence |
| Comparison | Bytes or digest against a fresh generation, tolerance 0 | Typed comparison with a tolerance per key: 0 for exact values, a band for sampled ones |
| Who may change it | The candidate, in the same change, by running the generator | The candidate may tighten it with its own evidence. Loosening is a policy change. |
| In use | 21 answers | 18 answers |

A generated reference proves that the file matches its generator. It does not prove that the generator is right (canon D3). A merge can leave the file stale without a conflict, so the gate compares on the merged tree (runbook C1).

“Policy from a trusted revision” fits the accepted value. Applied to a generated reference it would refuse the practice of 21 answers, so the format keeps the two kinds apart. An accepted value follows six rules. Each answers a failure in the survey (F7).

1. **Judged by the trusted copy.** The gate reads the reference from the trusted revision, such as the copy on `main`, and not from the candidate’s tree. 4 answers compare this way (F6).
2. **No loosening by the candidate.** A worse value recorded by the candidate does not change what the candidate is judged by. In one answer the commit that caused a regression re-recorded the counter it had moved, and the tool allowed it (entity-runtime C1). A worse value is accepted only through an exception or a trade-off, described below.
3. **First adoption from prior evidence.** A reference is adopted from evidence produced before the candidate, such as observe-mode runs on the trusted revision. Until one exists, the regression comparison returns insufficient evidence. A first run compared with itself passes and proves nothing (ux-ui B6, D1).
4. **Stale after an improvement.** When candidate evidence is better than the reference by more than the tolerance, the gate reports the reference as stale. For an exact measurement the candidate adopts the better value in the same change, and the gate fails when it does not; 5 answers fail the check or block a release on this (F6). For a sampled measurement, `ratchet reference propose` first collects repeated comparable results. In one answer 27 counters stayed “improved: re-record” from 02:45 to 15:34, so a regression up to each improvement would have passed (entity-runtime C3).
5. **Comparable conditions.** A reference records the toolchain, image, runner, and host class that produced it. Evidence from other conditions is not compared with it (F7, 4 answers). A project can produce the reference where the gate runs (ext-02 B6), pin the conditions (ext-04 E4), or use a paired run (§ 3).
6. **Stored where the gate can read it.** A reference lives in the repository or with the Ratchet records. A run file in a scratch directory or in a git-ignored directory is not a reference (swell B6, canon B6, ext-03 B6).

A stored series can supply the evidence for an adoption, for example the median of the last 10 runs on the default branch (ext-02 E4, ext-07 E4). Once adopted, the value stays fixed until the next adoption decision.

### Verdicts

A required check returns **pass**, **fail**, or **insufficient evidence**. Only a pass clears the gate. Insufficient evidence covers cases such as too few samples, a timed-out assessor, stale telemetry, or an incompatible target. The survey adds five causes: observation conditions outside the declared ones, including a limit crossed because of the host; coverage below the plan (skipped, not run, unsupported, or a subset); an assessor stopped by its infrastructure, such as a failed tool download or a missing runner; a tool or toolchain other than the declared one; and a reference that is missing or not comparable (F1, F2, F9).

Insufficient evidence does not clear the gate. What it changes is the next step: run the assessment again under qualifying conditions, and leave the candidate as it is. 12 answers describe good quality as a system that says so when it cannot tell (F17).

Results include the requirement ID, target revision, observed and allowed values, coverage counts, observed conditions, and pointers to the relevant logs, traces, or findings. Each result that is not a pass names its cause and says whether the next step is on the candidate or on the assessment. The agent can then determine whether to fix the candidate or recover the assessment.

### Gate modes

A gate lists each requirement as **enforce** or **report**. An assessment with no requirement in any gate is in observe mode. A report-mode requirement is evaluated and shown with its verdict, and it does not block. 7 answers have such a check today, through a `continue-on-error` flag, a job that is not required, or a `report` setting (F8).

Requirements tend to stay in that state. In 6 answers a written time budget was not enforced while the measured value was over it. Report mode is therefore visible. Each gate result lists its report-mode requirements with the verdict, the observed and allowed values, and the date since which the requirement has not been enforced. A gate result with failing report-mode requirements says so in its summary line. Without that, a gate that fails “by decision” stops carrying information: “only the counts do” (ext-07 D3).

### Policy changes, exceptions, and trade-offs

A candidate’s gate uses policy from a trusted revision. Proposed changes to thresholds, assessor versions, measurement conditions, or protected references are evaluated as policy changes. An explicitly authorized update records the previous value, supporting evidence, and new value. Protocol changes that affect comparability establish a new evidence series or use documented overlap to relate it to the old one.

Two updates need no separate authorization, because the gate can verify them: a candidate that regenerates a generated reference, and a candidate that tightens an accepted value its own qualifying evidence meets. Both are still recorded as reference changes.

**Exceptions.** 23 of 26 answers report at least one loosening. 18 of those say it was not tightened again, or that they do not know (F12). The forms are a skipped or ignored test, a raised limit, a known-failing list, an allowlist entry, and a worse accepted value. In the format each is an **exception**: a record that names the requirement, the item or value excepted, a reason, an owner reference such as a story or decision id, and an expiry date. 9 answers already require a decision id for a worse value. 3 record a review-by date, and none checks it (F6, F12). `ratchet evaluate` checks the date. An expired exception no longer applies, so the requirement is evaluated without it. Adding or extending an exception is a policy change. Every gate result lists the active exceptions with their age and expiry, because they accumulate: one answer counts 37 acknowledged incompatible changes since the last reset (cortex C3).

**Trade-offs.** One change can make some values better and others worse on purpose. In the first consumer’s round, a change to in-page navigation moved one value from 23 to 0 and made 20 of 168 values worse (consumer gap 1). With one reference per requirement, that change needs 20 exceptions, and none of them says what was gained. A **trade-off** is one reference change that lists the requirements it loosens with their new values, and the requirements whose gain it buys. The CLI checks both lists against the candidate’s evidence: the named gains are present, and nothing outside the first list got worse. It carries a reason and an owner reference, as an exception does. The loosened values become the references, so a trade-off has no expiry. A worse value that buys no named gain remains an exception and expires.

### Proposed CLI

| Command | Purpose |
| --- | --- |
| `ratchet init` | Create a project spec and bind selected catalog presets. |
| `ratchet validate` | Check the spec, resolve references, and validate assessor configuration. Report sampled measurements without declared conditions and exceptions without a reason, an owner, or an expiry. |
| `ratchet assess` | Run selected assessors or ingest their results and produce structured evidence. |
| `ratchet evaluate --gate promote` | Evaluate a named gate using qualifying evidence and emit a report with an exit status CI can enforce. The report lists report-mode requirements, active and expired exceptions, and coverage. |
| `ratchet reference propose` | Produce an evidence-backed proposal to adopt a stronger protected reference, or a trade-off that names its gains. |
| `ratchet prove` | Run a requirement’s planted defects and record that the check refuses each. |
| `ratchet render` | Write a block of numbers in a document from records. With `--check`, compare the block with a fresh one. |

## 6. Results and visualization

Store observations, decisions, and reference changes as separate records. This makes it possible to re-evaluate old evidence against a new requirement and still see which policy governed the original decision.

| Record | Required context |
| --- | --- |
| Assessment run | Candidate identity, resolved target and its class, assessor and protocol versions, timestamps or window bounds, values with kind, unit, and scope, sample or run count, coverage counts, observed conditions (runner, host load, toolchain, cache profile), queue wait and run time, and artifact references. |
| Gate decision | Candidate, gate and policy version, evidence IDs, protected reference or absolute limit, the mode of each requirement, exceptions applied, verdict, and reason. |
| Reference change | Requirement, kind of reference, previous and adopted references, the conditions of the adopted one, supporting evidence, the gains named by a trade-off, and the revision or decision that authorized adoption. |
| Exception | Requirement, excepted item or value, reason, owner reference, creation and expiry dates, and the decision that authorized it. |

Start with versioned JSON records and CI artifacts. A database can index those records for cross-project queries and dashboards. Useful views include observed values alongside the enforced boundary, a history of gate decisions, and a breakdown of time to first verdict by CI stage. Label protocol changes and environment changes on charts so a change to the runner or workload remains visible. The survey asks for four more views: queue wait apart from run time, report-mode requirements with the time each has gone unenforced, active exceptions by expiry, and coverage counts per run.

**A series per measurement.** No answer reports a stored series of CI duration, queue wait, or lead time. The figures given were read from the forge or from a job log on the day (F11). 4 answers saw a value grow toward a fixed limit and noticed when it reached the limit: a scan input at 512.3 MiB against 512 MiB, a test step at 120 s. One record per run shows the distance to the limit before that. Much of the data exists outside the repository. The forge keeps run history, and a build pool can log queue wait, run time, and CPU seconds for every job (slot B2, B7). An assessor imports it from there.

**Numbers in documents come from records.** 16 answers keep measured numbers as hand-written prose in an instruction file, a changelog, a story, or a README, and nothing checks that they are still true (F11, F14). One answer rewrites the gate’s counts in 7 files at every release (surf D1). Each record has a stable id that prose can cite. `ratchet render` writes a marked block in a document from records, and `ratchet render --check` fails when the block differs from a fresh one. The block is then a generated reference (§ 5). 3 answers already generate a statistics block or badges from a source and do not write them by hand (ext-02 B1, ext-05 B7, ext-07 B1).

## 7. ESS integration and first implementation

ESS provides authored conformance scenarios and reports. ESS UI provides named interactions and expectations over canonical node paths, fixture-backed reads, virtual time, and a Playwright projection. Ratchet can import the verdict from a fixture-backed test for fast behavioral feedback. A separate deployed assessor can reference the same interaction and reuse supported steps and node addresses while collecting wall-clock evidence against the real deployment. [ESS conformance](https://beyond10x.github.io/docs/ess/guides/verify-conformance/) · [ESS UI test reference](https://beyond10x.github.io/ess/docs/reference/ess-ui-test)

The `ux-ui` repository has offered to be the first consumer of the ESS UI integration. It plans a preset family `web-ux@1` and an assessor `ux-eval@1` that evaluates design variants of an `ess-ui/1` document with no I/O and emits Ratchet evidence ([consumer input](../research/consumer-input-ux-ui.md)). Its measurements are exact, which suits fixture-backed feedback. §§ 3 to 5 answer the four gaps it reported.

The first proposal named three integrations to prove the shared contract. The survey shows which practices are most common: a generated file compared by bytes (21 answers), a file of accepted values per key (18, of which 12 are one kind of UI loop), and a time budget for the test step (21 write the rule; 13 of 26 proposed one-line rules are about time or cost). The three integrations still fit, each with a wider contract, and the survey adds a fourth.

1. **ESS UI behavior.** Import a structured result and enforce an assertion. With `ux-ui` as the first consumer, the import also carries exact values per scenario and key under accepted values, page-scoped findings compared by identity, and a trade-off. 12 answers run a UI loop of this shape with their own comparison tool, and one answer counted that loop 7 times in 3 languages in one organization (F6).
2. **CI turnaround.** Read workflow timings, establish a protected reference, and catch a regression under comparable conditions. The survey supports this one most: time to a verdict is the top cost in 24 of 26 answers (F3). It reads queue wait and run time apart, covers the local gate and the test step as well as CI workflows, and returns insufficient evidence for a limit crossed under host load. 10 of the 13 time or cost rules measure the project’s own test step (F18).
3. **Code quality.** Import findings from an existing analyzer and enforce a no-new-findings requirement. The survey says little about accepted sets of analyzer findings. Where the answers describe lint, it blocks on any finding, which is a fixed zero (spindle B5, substrate B1). The nearest cases are scan allowlists: one scoped by rule and path (substrate C3), one with a written reason per entry (ext-08 C3). The identity comparison this integration proves is asked for more often for cases, so the same comparison also takes the passing-case set of an ESS conformance report (F7, F9).
4. **Generated artifact.** Run a generator and compare the committed file by digest, tolerance 0. This is the most common baseline in the survey (F5) and the one kind of reference the candidate may rewrite. The first implementation needs it to prove both update rules of § 5.

Then add deployed browser timing to exercise candidate attribution and controlled sampling, and production telemetry to exercise windowed assessment. The survey gives little evidence for these two: 3 of 26 answers describe a deployed service and 1 cites a production incident (synthesis § 4, implication 17). Their design is unchanged. The same specification should carry through all six cases. The first end-to-end milestone is a project that can start in observe mode, adopt a gate, reject a regression with actionable evidence, and record an improvement as a new protected reference. It also returns insufficient evidence, and not a fail, when the host and not the candidate caused a limit to be crossed.

## 8. Changes from survey 1

`F` numbers are findings in the [synthesis](../research/synthesis.md), `implication` numbers are its § 4, `gap` numbers are the [consumer input from `ux-ui`](../research/consumer-input-ux-ui.md), and `id Xn` is question `Xn` of `research/responses/<id>.md`.

| Change | Where | Evidence |
| --- | --- | --- |
| Coding agent as an audience with its own subjects (gate, error text, instruction file) | § 1 | synthesis § 3; implication 16 |
| Measurement kind: exact or sampled, with runs, aggregation, and tolerance per kind | § 1, § 3 | F2, F4, F9; gap 3 |
| Observation conditions recorded in evidence and declared in the plan; evidence outside them is insufficient evidence | § 3, § 6 | F1, F2; implications 1, 2 |
| A limit crossed because of the host is insufficient evidence; a killed run is not a result about the subject | § 3, § 5 | F2; swell C2; ext-06 C2; implication 2 |
| Queue wait and run time recorded apart; `boundary` names the part measured | § 3, § 6 | F2, F3; ux-ui C2; ext-03 C3; ext-08 C3 |
| Paired run as a comparison for sampled measurements | § 3 | entity-runtime B6, C1; ext-04 B6 |
| Conditions for exact measurements (toolchain, libraries, CPU, tool version) | § 3 | F4; ext-04 D2; canon C2; implication 3 |
| Money and model calls as units; “Spend” preset family | § 3, § 4 | F16; ux-ui E3 |
| Scope of a result, and aggregation that respects it | § 1, § 3 | gap 2; ux-ui D3; F8; ext-07 E4 |
| Evidence coverage counts; coverage below the plan is insufficient evidence | § 1, § 3, § 5, § 6 | F9; spindle B5; ext-04 C3; implication 7 |
| Local and CI as separate target classes; a gate names the classes that qualify | § 3 | F10; implication 10 |
| Identity sets beyond analyzer findings: passing cases, executed scenario ids, UI findings by rule, node path, and environment | § 1, § 4 | F7, F9, F18; swell D3, E4; spindle B5; ext-05 B7; gap 4; implication 6 |
| Review as an assessor, tied to the revision judged | § 2, § 4 | F13, F17; inbox D2; ux-ui E4; implication 13 |
| Proof that a check can fail: planted defects, `ratchet prove`, “unproven” in gate reports | § 4, § 5 | F15; implication 14 |
| Two kinds of protected reference with different update rules | § 1, § 5 | F5, F6; canon D3; runbook C1; implication 4 |
| Six rules for an accepted value: trusted copy, no loosening by the candidate, first adoption from prior evidence, stale after an improvement, comparable conditions, readable storage | § 5 | F6, F7; entity-runtime C1, C3; ux-ui B6, D1; ext-02 B6; ext-04 E4; swell B6; implication 5 |
| A candidate may regenerate a generated reference and tighten an accepted value without separate authorization | § 5 | F5, F6; implication 4 |
| A stored series can supply the evidence for an adoption; the adopted value stays fixed | § 5 | F18; ext-02 E4; ext-07 E4 |
| Five more causes of insufficient evidence; a non-pass names its cause and where the next step lies | § 5 | F1, F2, F9, F17; synthesis § 3 |
| Gate modes: enforce and report; report mode shown with the date since which a requirement is unenforced | § 1, § 5 | F8; ext-07 D3; implication 8 |
| Exception record with reason, owner reference, and an expiry the CLI checks | § 1, § 5, § 6 | F12; F6; cortex C3; implication 9 |
| Trade-off: one reference change that names and proves the gain it buys | § 1, § 5 | gap 1; ux-ui E1; F6 (decision ids) |
| Records carry kind, scope, conditions, coverage, wait and run time, modes, and exceptions | § 6 | F2, F8, F9, F10, F12 |
| A series per measurement, imported from the forge or build pool | § 6 | F11; slot B2, B7; implication 11 |
| Numbers in documents generated from records; `ratchet render` | § 2, § 5, § 6 | F11, F14; surf D1; ext-02 B1; ext-05 B7; ext-07 B1; implication 12 |
| Preset table: “Consistency”, “Spend”, and “Review” rows; cost per operation; time per test and per test step; queue wait | § 4 | F4, F5, F8, F13, F16, F18 |
| § 7: `ux-ui` named as first consumer; each of the three integrations widened; a fourth, generated artifact, added; the milestone includes a host-caused limit | § 7 | F3, F5, F6, F7, F18; consumer input (offer); implication 17 |
| Illustrative YAML shows kind, scope, identity, conditions, coverage, reference kind, gate mode, qualifying environments, and an exception | § 3 | the rows above |

### Not supported by the evidence, or argued against

- **Time-window evidence and production telemetry.** 3 of 26 answers describe a deployed service (implication 17). The design for windows, SLOs, and deployed browser timing is unchanged and remains untested by this survey.
- **A coverage gate.** No answer gates on code coverage, and 23 report no coverage measurement (F11). “Coverage” stays in the code quality row as a candidate without support from the survey.
- **A baseline of accepted analyzer findings.** The synthesis reports no case of one in use (§ 7, integration 3). The idea stays because nothing contradicts it, and 20 of the 26 answers describe a Rust code base, 17 of them in one organization.
- **A reference that moves with every run.** Several proposed rules compare with the previous run on `main` or with the median of the last 10 runs (cortex E4, runbook E4, ext-02 E4). The design does not make that the enforced reference, because a tolerance applied to a moving value accumulates across merges. The series supplies evidence for an adoption instead (§ 5).
- **A wider tolerance to absorb noise.** The evidence argues against it (entity-runtime C2, C3). § 3 uses conditions, medians, exact measurements, and paired runs.
- **A standing requirement group or Pareto set** (gap 1, first option). One round from one consumer is the only evidence. The trade-off record covers that round without it.
- **Whether a text is clear or a judged result is right.** 16 answers name one of these as something a machine cannot check (F17, E2). The design adds no measurement for them; a review assessor is where such a judgement enters.
- **A measurement that moves with unrelated content.** One answer reports an accepted value that failed because a new content page shifted a list by one keyboard step (ext-02 C2). One case is not enough to design for.

### Limits

All 26 answers are from one day, and almost all from sessions on one shared host under load. F1 to F3 describe that host on that day (synthesis § 5). The changes that rest on them record conditions and split wait from run time. They do not assume a loaded host. 18 of the 25 projects share one organization’s rules, so a count of a shared convention is not 18 independent choices.
