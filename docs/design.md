# Ratchet

**Proposed repository:** `beyond10x/ratchet`  
**Status:** Design proposal

Ratchet specifies how to specify software quality. It defines a versioned YAML format for declaring what quality means for a project, how to assess it, and what evidence a candidate must produce before it can advance. The repository ships the specification, a CLI, a catalog of reusable YAML presets, and assessors that run or wrap existing tools. An agent or developer can use the same format to add a measurement specific to their repository.

The primary outcome is **regression prevention**. A brownfield team can start by measuring current quality, turn selected findings into enforceable requirements, and use the same evidence to evaluate improvements and track them over time.

## 1. Domain language

Quality has a **subject** and an **audience**. The subject is the thing assessed, such as a search interaction, an API operation, a codebase, or a release workflow. The audience experiences the quality. It can include users, developers, coding agents, maintainers, or operators. The same subject can matter to several audiences for different reasons.

| Term | Meaning |
| --- | --- |
| Quality specification | A project’s versioned declaration of subjects, audiences, requirements, assessment plans, and gates. |
| Quality requirement | A condition the project expects to hold, such as p95 latency below 100 ms, zero new analyzer findings of a specified severity, or a scenario passing. |
| Measurement | The value or assertion being evaluated, with a defined unit, scope, and aggregation where applicable. |
| Assessment plan | The instructions for collecting evidence. It binds a measurement to an assessor, a target, and observation conditions. |
| Assessor | A tool or adapter that runs a check or reads an existing result and returns structured evidence. |
| Target | The concrete repository revision, build, deployed service, workflow run, or telemetry population from which evidence is collected. |
| Protected reference | An accepted measurement used for regression comparisons. It has a revision, compatible assessment conditions, and evidence supporting its adoption. |
| Gate | A decision at a workflow stage, such as merge or promotion, that requires specified verdicts before a candidate can advance. |
| Ratchet policy | The rule for when an evidenced improvement can tighten a requirement or replace its protected reference. |

KPI, SLI, SLO, and SLA can keep their usual meanings. A KPI is a selected measure of an important outcome. A service SLI can be represented as a measurement and an SLO as an objective over a defined window. An SLA adds a customer commitment. These are useful domain concepts within the model. General quality requirements also cover static checks, behavioral assertions, and development workflows.

## 2. What the repository ships

| Surface | Responsibility |
| --- | --- |
| Specification | Defines YAML document shapes, reference resolution, typed comparisons, evidence requirements, and gate semantics. Publishes a machine-readable schema for authoring and validation. |
| CLI | Resolves presets, validates configuration, runs or imports assessments, evaluates gates, and writes human-readable and machine-readable results. |
| Preset catalog | Supplies versioned YAML instances of the specification for common concerns. Each preset declares its inputs, expected evidence, and defaults where they are meaningful. |
| Assessors | Built-in or separately packaged adapters for scenario runners, analyzers, benchmarks, CI systems, telemetry, and repo-specific tools. |
| Agent integration | A skill or plugin guides agents through choosing presets, authoring custom checks, running them, and interpreting results. It uses the same specification and CLI as CI. |

Project specifications live alongside the project code. A project pins the presets and assessor versions it uses, binds them to its subjects and targets, and supplies thresholds that fit its workload. Presets use the same schema as locally authored checks, so teams can inspect them, configure their declared inputs, or use them as examples for a custom check. Validation resolves references and catches mismatched measurement types, units, and target bindings before a run.

## 3. Requirements, evidence, and targets

A requirement describes **what must hold**. An assessment plan describes **how we can know**. For example, “search request p95 is below 100 ms” belongs in a requirement. The endpoint or scenario, timing boundaries, workload, dataset, minimum sample count, and environment belong in the assessment plan. A gate identifies which requirements are mandatory at a given stage and which evidence qualifies for that decision.

| Observation | What it answers | Example |
| --- | --- | --- |
| Snapshot | What holds for this revision, build, or run? | Resolved dependency count at a commit, current code analysis findings, or the duration of a particular CI workflow run. |
| Controlled run | How does this candidate behave under a repeatable workload? | Browser search p95 on an ephemeral deployment with fixed data, traffic, and sample requirements. A run can collect many samples and still produce one result for the candidate. |
| Time window | What happened across a defined population and interval? | Successful requests over a rolling 30-day production window, or median CI turnaround across seven days of eligible workflow runs. |

**History** is a separate concern. Storing snapshots and controlled runs over time creates a trend. A windowed measurement specifies the time interval and population as part of the evidence itself.

Record both the **expected target** in the plan and the **resolved target** in the evidence. For source checks, this may be a commit and lockfile. For a deployed benchmark, it may be an ephemeral environment ID, the candidate’s artifact digest, and the workload version. For production telemetry, it may be a service, region, traffic filter, deployment or cohort identifier where available, and exact window bounds. Local, ephemeral, staging, and production are explicit target classes. A pre-release gate can use an ephemeral environment with declared production-like conditions. A production window with mixed revisions describes that population and can support an operational gate, such as pausing a rollout. Candidate-specific verdicts require evidence attributable to that candidate.

### Illustrative project YAML

The field names and commands in this document are proposals. This example shows a project-specific requirement wired to a reusable assessor.

```yaml
format: ratchet/1
project: partner-portal

subjects:
  partner-search:
    kind: user-interaction
    audiences: [portal-user]

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
    measurement:
      output: search_request_duration
      boundary: request-start-to-response-complete
      aggregation: p95
      unit: ms

requirements:
  search-latency-budget:
    assessment: search-request-latency
    condition: {operator: lt, value: 100, unit: ms}

gates:
  promote:
    stage: pre-promotion
    requires: [search-latency-budget]
```

The sample count illustrates a project choice. A real plan also defines how the assessor selects the request, handles errors and timeouts, and versions the workload. For user-perceived latency, the measurement would instead span the input action to the expected result becoming visible. Both measurements can use the same interaction.

## 4. Presets and custom assessors

The catalog should grow across product quality and the quality of the software factory itself.

| Domain | Candidate preset families | Evidence source |
| --- | --- | --- |
| Web | UI behavior, keyboard interaction, accessibility, page or interaction latency, bundle size | ESS UI reports, browser runners, scanners, build outputs |
| Backend | Contract conformance, latency, error rate, throughput | ESS conformance reports, load runners, service telemetry |
| Code quality | Static analysis findings, lint, complexity, coverage, dependency count | Existing analyzers, coverage reports, lockfiles or build graphs |
| Development | Clean and incremental build time, test turnaround | Build and test commands under a declared toolchain and cache profile |
| CI and release | Time to first actionable verdict, total workflow duration, release lead time | Workflow stage events, CI runs, release records |

For code quality, an assessor can wrap the project’s existing tool or import a report already generated by CI. Preserve findings with rule IDs, severity, and locations so the agent can act on them. A brownfield project can gate on **new findings** by comparing stable finding identities against an accepted set. A total count alone can let a new violation hide behind the removal of an unrelated one.

A custom assessor can run as a project command or import a structured report. It declares supported targets, configuration inputs, output types, and a version. It returns evidence in the same format as bundled assessors. The CLI validates those outputs and applies the project’s comparison rules. This keeps custom measurements usable in the same gates and history from their first run.

## 5. Agent workflow and enforcement

1. **Baseline.** Add presets or custom checks in observe mode. Collect comparable evidence and use audience impact to prioritize the requirements worth protecting.
2. **Protect.** Apply absolute limits, regression comparisons, or both. For every candidate, run fast checks locally or in early CI, then gather deployment or windowed evidence at the stage that can produce it.
3. **Improve.** Use candidate and reference evidence to confirm the gain. Adopt a better reference when it meets the ratchet policy’s evidence criteria.
4. **Track.** Retain runs, gate decisions, and reference changes so developers and agents can identify where quality is improving or degrading.

A lower-is-better CI check might start with a protected reference of **6 minutes** and a **30-second regression tolerance** under a declared runner and cache profile. A candidate taking **7 minutes** fails. A candidate taking **5 minutes** can pass, and repeated comparable results can support tightening the reference to 5 minutes. The accepted reference stays fixed between adoption decisions, so the same tolerance cannot accumulate across successive merges.

A required check returns **pass**, **fail**, or **insufficient evidence**. Only a pass clears the gate. Insufficient evidence covers cases such as too few samples, a timed-out assessor, stale telemetry, or an incompatible target. Results include the requirement ID, target revision, observed and allowed values, and pointers to the relevant logs, traces, or findings. The agent can then determine whether to fix the candidate or recover the assessment.

A candidate’s gate uses policy from a trusted revision. Proposed changes to thresholds, assessor versions, measurement conditions, or protected references are evaluated as policy changes. An explicitly authorized update records the previous value, supporting evidence, and new value. Protocol changes that affect comparability establish a new evidence series or use documented overlap to relate it to the old one.

### Proposed CLI

| Command | Purpose |
| --- | --- |
| `ratchet init` | Create a project spec and bind selected catalog presets. |
| `ratchet validate` | Check the spec, resolve references, and validate assessor configuration. |
| `ratchet assess` | Run selected assessors or ingest their results and produce structured evidence. |
| `ratchet evaluate --gate promote` | Evaluate a named gate using qualifying evidence and emit a report with an exit status CI can enforce. |
| `ratchet reference propose` | Produce an evidence-backed proposal to adopt a stronger protected reference. |

## 6. Results and visualization

Store observations, decisions, and reference changes as separate records. This makes it possible to re-evaluate old evidence against a new requirement and still see which policy governed the original decision.

| Record | Required context |
| --- | --- |
| Assessment run | Candidate identity, resolved target, assessor and protocol versions, timestamps or window bounds, values and units, sample or coverage details, and artifact references. |
| Gate decision | Candidate, gate and policy version, evidence IDs, protected reference or absolute limit, verdict, and reason. |
| Reference change | Requirement, previous and adopted references, supporting evidence, and the revision or decision that authorized adoption. |

Start with versioned JSON records and CI artifacts. A database can index those records for cross-project queries and dashboards. Useful views include observed values alongside the enforced boundary, a history of gate decisions, and a breakdown of time to first verdict by CI stage. Label protocol changes and environment changes on charts so a change to the runner or workload remains visible.

## 7. ESS integration and first implementation

ESS provides authored conformance scenarios and reports. ESS UI provides named interactions and expectations over canonical node paths, fixture-backed reads, virtual time, and a Playwright projection. Ratchet can import the verdict from a fixture-backed test for fast behavioral feedback. A separate deployed assessor can reference the same interaction and reuse supported steps and node addresses while collecting wall-clock evidence against the real deployment. [ESS conformance](https://beyond10x.github.io/docs/ess/guides/verify-conformance/) · [ESS UI test reference](https://beyond10x.github.io/ess/docs/reference/ess-ui-test)

The first implementation should prove the shared contract with three integrations.

1. **ESS UI behavior.** Import a structured result and enforce an assertion.
2. **CI turnaround.** Read workflow timings, establish a protected reference, and catch a regression under comparable conditions.
3. **Code quality.** Import findings from an existing analyzer and enforce a no-new-findings requirement.

Then add deployed browser timing to exercise candidate attribution and controlled sampling, and production telemetry to exercise windowed assessment. The same specification should carry through all five cases. The first end-to-end milestone is a project that can start in observe mode, adopt a gate, reject a regression with actionable evidence, and record an improvement as a new protected reference.
