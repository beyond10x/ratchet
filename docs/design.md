# Ratchet

**Proposed repository:** `beyond10x/ratchet`  
**Status:** Design proposal, revision 4 (2026-11-24)  
**Evidence:** revision 2 was revised from survey 1 of 2026-11-23 ([synthesis](../research/synthesis.md), [consumer input from `ux-ui`](../research/consumer-input-ux-ui.md)); § 8 lists those changes. Revision 3 was revised from two drafts written against revision 2: five worked examples ([`examples/`](https://github.com/beyond10x/ratchet/blob/main/examples/README.md)) and the ESS specification of Ratchet’s own domain ([`spec/`](https://github.com/beyond10x/ratchet/blob/main/spec/README.md)). § 10 lists each change and its cause. Revision 4 was revised from those examples as rewritten to revision 3 (`examples/README.md` at commit `a94ab83`, [section “New gaps”](https://github.com/beyond10x/ratchet/blob/a94ab83f8afb6dcbb8d987a907b41d93039b535d/examples/README.md#new-gaps)): four more gaps, G26 to G29, and the places where revision 3 contradicted itself. § 11 lists each change and its cause. § 9 lists the questions left to the owner: D1 to D4 are decided, and D5 and D6 are open with a default each.

Ratchet specifies how to specify software quality. It defines a versioned YAML format for declaring what quality means for a project, how to assess it, and what evidence a candidate must produce before it can advance. The repository ships the specification, a CLI, a catalog of reusable YAML presets, and assessors that run or wrap existing tools. An agent or developer can use the same format to add a measurement specific to their repository.

The primary outcome is **regression prevention**. A brownfield team can start by measuring current quality, turn selected findings into enforceable requirements, and use the same evidence to evaluate improvements and track them over time.

Survey 1 asked 26 agent sessions how their projects track quality. Three practices are common: a committed generated file compared by bytes (21 answers), a committed file of accepted values compared by the project’s own tool (18), and a written time budget for the test step (21). The survey also shows where they fail. A check failed with nothing wrong in 23 answers. A passing result covered less than it appeared to in 10. In 18, a loosening was not tightened again or nobody knows whether it was. Revision 2 made the format carry what those cases lacked: the kind of a measurement, the conditions it was observed under, how much of the plan ran, and who may change a reference.

Writing the examples and the specification showed where revision 2 named a thing and gave it no field, no value list, or no rule: 25 gaps in the examples and 12 open markers in the specification. Revision 3 closes them. The six product questions are decided ([open questions](open-questions.md)), and revision 3 applies them: the specification is YAML and the local config is TOML (Q1); a gate never reads a local skip (Q2); records are handed over as a CI artifact and kept as a series on a git ref (Q3); the views are a static export and a served app (Q4); the preset catalog is a directory in this repository (Q5); a view across repositories is a consumer of Ratchet’s records (Q6).

Rewriting the examples to revision 3 found four more gaps and showed where revision 3 disagreed with itself. Revision 4 closes them. An operational gate reads a time window that its plan declares, and `window` and `population` have a shape (G26). An input that differs per machine is declared local by its assessor and supplied by the local config (G27). An item of an accepted set is `{identity, reason, owner}` (G28). A plan’s coverage counts the assessor’s coverage unit, once per run (G29). G26 and G27 are written under a default that the owner has not confirmed (§ 9, D5 and D6).

## 1. Domain language

Quality has a **subject** and an **audience**. The subject is the thing assessed, such as a search interaction, an API operation, a codebase, or a release workflow. The audience experiences the quality. It can include users, developers, coding agents, maintainers, or operators. The same subject can matter to several audiences for different reasons.

A coding agent that builds the project is an audience with subjects of its own: the gate, the text of an error or refusal, and the instruction file. In 20 of 26 answers, quality is worse for that audience when the gate gets slower or fails for a reason outside the change. In 7, it is worse when an error names no cause and no next step (synthesis § 3).

| Term | Meaning |
| --- | --- |
| Quality specification | A project’s versioned declaration of statements, subjects, audiences, requirements, assessment plans, gates, and exceptions. A project has one. A gate reads it at a revision. |
| Quality statement | A sentence in plain words about what quality means for an audience. A requirement names the statements it serves. A statement that no requirement serves is reported as not machine-checked. |
| Quality requirement | A condition the project expects to hold, such as p95 latency below 100 ms, zero new analyzer findings of a specified severity, or a scenario passing. |
| Measurement | The value or assertion being evaluated, with a defined kind, unit, scope, and aggregation where applicable, and the direction that is better. |
| Measurement kind | **Exact** or **sampled**. An exact measurement gives the same value for the same input under the same conditions: a count, bytes, instructions, a digest, a modelled metric. A sampled measurement varies between runs: wall time, or the pass rate of a subject that answers differently per run. |
| Scope | The unit one result belongs to: a state, a journey, a page, a test, a file, a variant, or a run. An assessor declares the scopes of its outputs. |
| Identity set | A set of items with stable identities, such as findings or passing cases, compared item by item. |
| Assessment plan | The instructions for collecting evidence. It binds one or more measurements to an assessor, a target, and observation conditions. |
| Assessor | A tool or adapter that runs a check or reads an existing result and returns structured evidence. |
| Target | The concrete repository revision, build, deployed service, workflow run, or telemetry population from which evidence is collected. |
| Evidence coverage | How much of the plan a run executed: counts of executed, skipped, not run, and unsupported items. The items are of the assessor’s **coverage unit**, the piece of work a run executes or skips, such as a walk, a test, or a file. |
| Protected reference | An accepted state used for regression comparisons. It is either a **generated reference**, a committed artifact that a generator reproduces and that is compared by bytes or digest, or an **accepted value**, a measured value or identity set. It has a revision, the conditions that produced it, and evidence supporting its adoption. |
| Gate | A decision at a workflow stage, such as merge or promotion, that requires specified verdicts before a candidate can advance. A gate lists each requirement as enforced or report-only. A **candidate gate** judges one candidate. An **operational gate** judges a host or a population over a time window and decides nothing about a candidate. |
| Ratchet policy | The rule for when an evidenced improvement can tighten a requirement or replace its protected reference. It is declared per requirement, as the `adoption` of its reference. |
| Exception | An accepted departure from a requirement: a waived finding, a known-failing case, a raised limit. It carries a reason, an owner reference, and an expiry date. It is authored in the specification. |
| Trade-off | A record that accepts worse values for some requirements and names the better values it buys. Each reference change it loosens names it. |
| Preset | A reusable part of a specification in the catalog, with declared inputs. A project binds it by name and version. |
| Local config | A file per machine or checkout (`ratchet.toml`) that says where specifications, presets, records, tools, and local inputs are, and what to run on this machine. It carries no policy. |
| Local input | An input of an assessor whose value differs per machine, such as the path of a build pool’s job log. The assessor declares it as local, and the local config supplies it. |

KPI, SLI, SLO, and SLA can keep their usual meanings. A KPI is a selected measure of an important outcome. A service SLI can be represented as a measurement and an SLO as an objective over a defined window. An SLA adds a customer commitment. These are useful domain concepts within the model. General quality requirements also cover static checks, behavioral assertions, and development workflows.

## 2. What the repository ships

| Surface | Responsibility |
| --- | --- |
| Specification | Defines YAML document shapes, reference resolution, measurement kinds and scopes, typed comparisons, value lists, evidence and coverage requirements, exceptions, and gate semantics. Publishes a machine-readable schema for authoring and validation. |
| CLI | Resolves presets, validates configuration, runs or imports assessments, evaluates gates, checks exception expiry, and writes human-readable and machine-readable results. It can also generate a block of numbers in a document from records. |
| Preset catalog | A directory `presets/` in this repository, released with the format and the CLI (open questions Q5). It supplies versioned YAML instances of the specification for common concerns. Each preset declares its inputs, expected evidence, and defaults where they are meaningful. |
| Assessors | Built-in or separately packaged adapters for scenario runners, analyzers, benchmarks, CI systems, telemetry, reviews, and repo-specific tools. |
| Local config | `ratchet.toml`, in TOML (open questions Q1). It locates specifications, preset sources, the record store, tools, and local inputs, and selects what runs on one machine (§ 5). |
| Record store | Versioned JSON records. A run hands its records over as a CI artifact, and one job on the trusted branch appends them to the git ref `refs/ratchet/records`, which gates and views read (open questions Q3; § 6). |
| Views | One page and one data document from the records, as a static export and as a served app (open questions Q4; § 6). A view across repositories is a consumer of the records and not a part of Ratchet (open questions Q6). |
| Agent integration | A skill or plugin guides agents through choosing presets, authoring custom checks, running them, and interpreting results. It uses the same specification and CLI as CI. |

Project specifications live alongside the project code, in `ratchet.yaml` or in several files that the local config lists. A project pins the presets and assessor versions it uses, binds them to its subjects and targets, and supplies thresholds that fit its workload. Presets use the same schema as locally authored checks, so teams can inspect them, configure their declared inputs, or use them as examples for a custom check. Validation resolves references and catches mismatched measurement kinds, units, scopes, and target bindings before a run.

## 3. Requirements, evidence, and targets

A requirement describes **what must hold**. An assessment plan describes **how we can know**. For example, “search request p95 is below 100 ms” belongs in a requirement. The endpoint or scenario, timing boundaries, workload, dataset, minimum sample count, and environment belong in the assessment plan. A gate identifies which requirements are mandatory at a given stage and which evidence qualifies for that decision.

| Observation | What it answers | Example |
| --- | --- | --- |
| Snapshot | What holds for this revision, build, or run? | Resolved dependency count at a commit, current code analysis findings, or the duration of a particular CI workflow run. |
| Controlled run | How does this candidate behave under a repeatable workload? | Browser search p95 on an ephemeral deployment with fixed data, traffic, and sample requirements. A run can collect many samples and still produce one result for the candidate. |
| Time window | What happened across a defined population and interval? | Successful requests over a rolling 30-day production window, or median CI turnaround across seven days of eligible workflow runs. |

**History** is a separate concern. Storing snapshots and controlled runs over time creates a trend. A windowed measurement specifies the time interval and population as part of the evidence itself. Its plan declares a `window` and a `population`, and the evidence records the exact bounds (below, time windows). No example uses the shape yet, and the survey does not test it (§ 8, time-window evidence).

Record both the **expected target** in the plan and the **resolved target** in the evidence. For source checks, this may be a commit and lockfile. For a deployed benchmark, it may be an ephemeral environment ID, the candidate’s artifact digest, and the workload version. For production telemetry, it may be a service, region, traffic filter, deployment or cohort identifier where available, and exact window bounds. Local, CI, ephemeral, staging, and production are explicit target classes. A pre-release gate can use an ephemeral environment with declared production-like conditions. A production window with mixed revisions describes that population and can support an operational gate, such as pausing a rollout. Candidate-specific verdicts require evidence attributable to that candidate.

A target’s `selection` says which tree or build is assessed: `candidate`, or `merge_result`, the candidate merged into the trusted revision. A comparison that a merge can break without a conflict uses `merge_result` (§ 5, generated references). A time-window plan declares a `selection` only when its population is the candidate’s alone, such as a cohort that only the candidate serves. Without one, its evidence is attributable to no candidate, and the plan serves an operational gate (§ 5).

The local gate and CI are different targets, even for the same tree. 14 answers report a different check set or a different result between the two (F10). A plan lists the classes it runs in as `environments`, always a list. Evidence records where it was produced: the target class, the runner, and the tools. A gate names the classes whose evidence qualifies. A requirement that a location cannot assess is reported there as not run: its verdict is insufficient evidence with the cause `not_assessable_here`. It is not left out of the list, and the run does not exit 0 as if it had passed (ext-07 D3).

### Measurement kind and observation conditions

A measurement declares its **kind**. The kind decides how many runs are needed, which conditions the evidence records, and what tolerance makes sense. The survey shows what happens when the two kinds share one rule: 16 answers report a time limit hit because of host load or queue wait (F2), and 8 answers already use counts of work because those do not move with load (F4).

| | Exact | Sampled |
| --- | --- | --- |
| Examples | Finding count, bytes, instructions, syscalls, allocations, process starts, a digest, a modelled UI metric | Wall time, a latency percentile, throughput, the pass rate of a subject that answers differently per run |
| Runs | One, unless the plan says more | N runs or N samples, declared. 1 is valid. The evidence carries the count. |
| Aggregation | None, or a sum within the declared scope | Declared where N is above 1: median, percentile, best of N, or pass rate |
| Tolerance | 0 by default. A small declared band where the tool varies. | A declared band |
| Conditions that decide comparability | Tools and their versions, loader and libraries, CPU | Host load, runner, cache profile, tools |

Sampled evidence states the conditions it was observed under. The plan declares the conditions that qualify. Evidence observed outside them does not qualify, and the verdict is insufficient evidence. This covers a limit that was crossed: when host load is above the declared bound, the result says nothing about the candidate. In one answer a release gate failed on 194.7 s against a 120 s budget at load 65, and the same steps took 94.3 s at load 34 (swell C2). `ratchet validate` reports a sampled measurement that declares no conditions. A snapshot can declare conditions too.

**Conditions are declared per target class.** `conditions` is keyed by class, with `all` for what holds in every class. One plan can then carry a load bound for a workstation and a runner for CI. Three conditions have a defined meaning. An assessor can declare others.

| Condition | Meaning | In the evidence |
| --- | --- | --- |
| `host_load_per_cpu` | The mean of the 1-minute load average over the run, divided by the number of CPUs. The bound applies to the mean. One reading before the run is not this condition: it can decide whether a local run starts, and it is not evidence (§ 5, local config, rule 4). | Mean, minimum, and maximum. One answer saw load move from 82 to 112 during one run (inbox C2). |
| `tools` | A map from a tool to its version, or to the file that pins it: `{rustc: {pin: rust-toolchain.toml}, ess: "0.97.4"}`. It replaces `toolchain: pinned`, which named no tool and no version. | The resolved version of each named tool |
| `runner` | The label of the runner or runner class | The runner that ran |

Ratchet ships no default for a load bound. No answer states a load that qualifies a timing run ([candidate presets](../research/candidate-presets.md) § 7). A project takes its bound from its own observe-mode series.

When the measurement is a duration, the assessor’s timeout and the requirement’s limit can be the same number. The rule does not change. Under qualifying conditions, a run that reaches the limit is a fail with the observed value “at least the limit”. Outside them it is insufficient evidence. A killed run is never recorded as a result about the subject, such as “not reproduced” (ext-06 C2).

A duration has parts. Evidence records **queue wait** and **run time** as separate values where the runner or build pool reports them, and the measurement’s `boundary` says which part the requirement is about: `run_time`, `queue_wait`, or a boundary the assessor declares. Each part can have its own measurement and its own requirement (ext-03 C3, ext-08 C3). Without the split, one round reported 1912 s for a browser run of 108.6 s (ux-ui C2).

A wider tolerance does not solve noise. A timing limit set to 2.0x, after an unchanged build moved up to 1.94x, would miss a 1.68x regression (entity-runtime C2, C3). The format offers three other answers:

- **An exact measurement of the same subject**, where one exists. CPU seconds moved 60 % with host load and instructions under 2 % (surf C3).
- **A median of N runs**, with N in the evidence. Repeats are in use in 4 answers (F9; consumer gap 3).
- **A paired run.** The assessor builds the revision that holds the accepted reference and measures it and the candidate interleaved on the same runner. The plan declares `paired: {pairs: N}`. The comparison is between the two values of that run, so no stored value has to match the present host (entity-runtime B6, ext-04 B6). A paired run is a way to compare with an accepted value and not a third kind of reference: the reference revision stays fixed between adoptions, as a stored value does (§ 5).

**One run per candidate is valid.** A gate that judges a whole test step or a workflow run has one sample per candidate. Three runs of a 120 s step take longer than the budget they measure. A plan with `runs: 1` declares no aggregation, and the value is judged as observed, under the declared conditions and with the declared tolerance. Repeats are needed where the plan aggregates and where a sampled reference is adopted (§ 5). No answer states a run count for a timing check of a whole step. The repeats in use are 3 and 5 (surf B5, runbook B4, entity-runtime B6, ext-04 B6).

Exact measurements have conditions too. Instruction and syscall counts depend on the C library, the compiler version, and the CPU, so a system update can refuse a merge that changed no code (ext-04 D2). The plan names those conditions and the evidence records them. A mismatch with the reference’s conditions is insufficient evidence, and it starts a new evidence series as § 5 describes for protocol changes. A tool version other than the one `tools` names is handled the same way: 47 tests failed in one answer when a tool at 0.98.0 was first on the path and the pin was 0.97.4 (canon C2).

Cost has units of its own: money per run or per day, and model calls per run. 6 answers bound or record money for runs that call a paid model, and in 3 a crossed cap refuses or stops the run (F16).

### Scope and aggregation

A result belongs to one **scope**: a UI state, a journey, a page, a test, a file, a design variant, or a whole run. The assessor reports each result at the scope where it was observed. Aggregation is declared per measurement and does not repeat a result outside its scope. A page-level accessibility finding is one finding for the page, however many journeys visit that page. In the first consumer’s round, one page-level defect was summed per journey and counted 12 times (ux-ui D3; consumer gap 2).

The same holds for time. A limit per test and a limit for the test step are two requirements at two scopes; 19 answers write both (F8). A pass rate over the last 10 runs of one scenario aggregates the run scope per scenario (ext-07 E4).

The scopes are not a closed list. An assessor declares the scope of each output, and `ratchet validate` checks a measurement’s scope against that declaration. `run` is the whole run, and every assessor has it. The proposed rules of the survey also need a test step, an operation, a scenario, and a case (candidate presets § 6, item 2).

**Several measurements from one run.** A plan holds a map of `measurements`. The assessor runs once per plan, and every measurement reads that run: the 14 metrics of one walk (ux-ui B4), the step time and the time per test of one `task test`, the run time and the queue wait of one workflow run. A requirement names the plan and the measurement. It can leave the measurement out when the plan has one.

**Several scenarios in one plan.** `scenarios` is a list, and an entry can end in `*`. The scope keeps one result per scenario. A pattern can match fewer scenarios than it did before, so a plan with a pattern declares its coverage.

A scenario is not a walk. One round ran 30 walks with 14 metrics each (ux-ui B4) and compared 168 values (consumer gap 1), which at 14 metrics are 12 scenarios. The answers do not say how a walk maps to a scenario. In this format a scenario is a scope item and holds the values, and a walk is what the assessor counts as executed (below, evidence coverage).

### Evidence coverage

Every assessment run reports how much of the plan it executed: counts of **executed**, **skipped**, **not run**, and **unsupported** items, next to passed and failed. The plan declares the coverage that qualifies, as bounds on those counts or as an exact set of executed item ids (spindle B5). A run below it is insufficient evidence. That includes a run that executed a subset of what its name claims.

**Coverage belongs to the plan and not to a measurement.** A plan runs once and every measurement reads that run, so a run has one set of counts. They count items of the assessor’s **coverage unit**: the piece of work that a run executes or skips, such as a walk, a test, a file, or a crate. An assessor declares one unit (§ 4). The unit need not be the scope of a measurement. A plan with measurements at the scopes journey and page counts walks, and a plan with measurements at the scopes run and test counts tests. The evidence names the unit beside the counts, and `executed_ids` are ids of that unit.

A measurement needs no count of its own. Where a requirement has an accepted value per scope item, the reference record lists the items. An item of the reference with no value in the run makes that requirement insufficient evidence, with the cause `coverage_below_plan`.

The plan’s `coverage` has four count keys, `executed`, `skipped`, `not_run`, and `unsupported`, and one set key, `executed_ids`. A bare number is a bound in the direction that matters: a minimum for `executed`, a maximum for the other three. `{min, max}` states both. `executed_ids` is the exact set, as a list or as `{file: <path>}`. The file is read from the trusted revision.

10 answers report a passing result that covered less than it appeared to: 96 tests skipped for a missing prerequisite, 87 of 119 scenarios unsupported and still passing, “tests pass” evidence that covered 3 of 20 crates (F9). 9 answers already put a number on coverage. An assessor that prints “not run” and exits 0 has returned no evidence. A coverage count can also be a measurement with an accepted value, so that the number of ignored tests may not rise (ext-04 C3).

### Time windows

A time-window plan (`observation.kind: time_window`) declares three keys.

| Key | Shape | Meaning |
| --- | --- | --- |
| `window` | `{length: 7d}`, `{last: 20}`, or both | `length` is a duration back from the end of the window: a whole number and `m`, `h`, or `d`. `last` is a number of population items, newest first. With both, the window holds the newest `last` items inside `length`. |
| `population` | `{runs_of: <assessment>, from: any_revision}` | The assessment runs of another plan, read from the record store (§ 6). `from` is `trusted_revision`, the runs on the trusted branch alone, or `any_revision`, the runs of every candidate too. |
| | `{filter: {service: portal, region: eu}}` | A population that the assessor reads outside the record store: production telemetry, a job log. The fields are those the assessor declares for its population. |
| `min_samples` | A whole number | The fewest population items that qualify. Below it the verdict is insufficient evidence, with the cause `too_few_samples`. |

The window ends when the plan is assessed. The evidence records the exact bounds, the number of items, and the time of the newest item. `ratchet validate` reports a time-window plan that lacks one of the three keys, and a `window` or a `population` on a plan of another kind.

**A series of runs as a population.** `runs_of` names another plan of the same specification, the source plan. The built-in assessor `record-series@1` reads the source plan’s runs from the record store. Its outputs are the measurements of the source plan, by name.

- A measurement of the window plan keeps the scope, the unit, and the direction of the source measurement and declares an `aggregation` across the runs in the window. That gives one value for a measurement at the scope `run` and one value per item at any other scope, as for a pass rate per scenario over the last 10 runs (ext-07 E4). A window aggregates numbers, and assertions with `pass_rate`.
- The target has the kind of the source plan’s target, lists the classes whose runs count, and has no `selection`. A plan that lists two classes gives one window per class.
- Only runs that qualified under the source plan enter the population. A run outside the source plan’s conditions or below its coverage is left out, and the evidence counts the runs left out. The window plan therefore declares no conditions of its own, and the rule that a sampled measurement declares conditions does not apply to it.
- A window measurement can have an accepted value. Its `adoption` counts windows: `runs: 4` is the last four windows that an evaluation recorded. Windows that overlap share items.

This is how a per-candidate plan feeds a requirement about a host or a pool. One per-candidate plan gives the run time and the queue wait of a run. The run time is judged per candidate. The queue wait has no requirement on that plan: its runs are the population of a window plan, and the requirement names the window plan. The YAML below shows the pair as `test-step` and `pool-queue-wait`.

### Comparisons

A measurement returns one of four value types: a **number**, an **identity set**, a **digest**, or an **assertion**. A requirement compares it in up to two ways, and both must hold. `condition` compares with a fixed limit. `reference` compares with the protected reference (§ 5).

| Value type | `condition` | `reference` |
| --- | --- | --- |
| Number | `lt`, `lte`, `gt`, `gte`, or `eq` with a `value` | `accepted_value`: not worse than the accepted value by more than the tolerance. `better: lower` or `better: higher` on the measurement says which way is worse. |
| Identity set | The same five operators, on the number of items. `no_new_items` or `no_lost_items`, against the accepted set. | `accepted_value`. The two set operators need it. |
| Digest | None | `generated`: equal to a fresh generation, tolerance 0 |
| Assertion | `holds` | None |

- A requirement with a `reference` and no `condition` is valid for a number and for a digest. `ratchet validate` reports a number that has a reference and no `better`.
- `no_new_items` holds when every item of the candidate’s set is in the accepted set. `no_lost_items` holds when every item of the accepted set is in the candidate’s set. A set of passing cases takes `no_lost_items`, so a case that fails or stops running is lost (§ 4). A set of failing cases with `no_new_items` does not see a deleted case.
- An assertion holds or does not hold for each item of its scope: a scenario passing, an expectation of an imported ESS UI result. `holds` requires it for every item, and the result names the items where it does not hold.
- A tolerance is `{percent: 10}`, `{absolute: 30}` in the unit of the measurement, or both. With both, the wider band applies. Absolute bands are in use: 0.01 for layout shift in 3 answers (ux-ui B5, spindle B5, slot B5), and the 30 seconds of § 5. `ratchet validate` reports a sampled measurement with an accepted value and no tolerance. Ratchet ships no default band.
- A number has a `unit` exactly when the assessor declares one for the output. The measurement states that unit, and so does its `condition`. `ratchet/1` converts no units, and a different unit is a validation error. An output without a unit, such as a layout shift, a ratio, or the number of items of a set, takes no `unit` on the measurement, on the `condition`, or in a record, and an absolute tolerance on it is a bare number. A `unit` written for such an output is a validation error, so no stand-in such as `score` is needed.
- `filter` on a measurement of an identity set keeps the items whose field has one of the listed values, such as `filter: {severity: [serious, critical]}`. It applies before the comparison. The fields are those the assessor declares for the items of the set. A changed filter starts a new evidence series (§ 5).

### Value lists

Ratchet defines some values. An assessor or the author defines the others. Values that Ratchet defines are spelled in snake_case, as keys are.

| List | Values | Who defines it |
| --- | --- | --- |
| Measurement kind | `exact`, `sampled` | Ratchet, closed |
| Value type | `number`, `identity_set`, `digest`, `assertion` | Ratchet, closed |
| Observation kind | `snapshot`, `controlled_run`, `time_window` | Ratchet, closed |
| Target class (`environments`) | `local`, `ci`, `ephemeral`, `staging`, `production` | Ratchet, closed |
| Target kind | `revision`, `build`, `deployment`, `workflow_run`, `telemetry_population` | Ratchet, closed |
| Selection | `candidate`, `merge_result` | Ratchet, closed |
| Operator | `lt`, `lte`, `gt`, `gte`, `eq`, `no_new_items`, `no_lost_items`, `holds` | Ratchet, closed |
| Aggregation kind | `sum`, `median`, `percentile`, `best_of_n`, `pass_rate` | Ratchet, closed |
| Direction (`better`) | `lower`, `higher` | Ratchet, closed |
| Reference kind | `generated`, `accepted_value` | Ratchet, closed |
| Gate mode | `enforce`, `report` | Ratchet, closed |
| Gate kind | `candidate`, `operational` | Ratchet, closed |
| Deciding evidence (`evidence`) | `any`, `all` | Ratchet, closed |
| Verdict | `pass`, `fail`, `insufficient_evidence` | Ratchet, closed |
| Next step | `candidate`, `assessment`, `system` | Ratchet, closed |
| Run source (`from`) | `trusted_revision` for an adoption. `trusted_revision`, `any_revision` for a population. | Ratchet, closed |
| Scope, unit, output, boundary, coverage unit, input names, population filter fields, further conditions | For example `journey`, `file`, `min`, `steps`, `percent`, `walk` | The assessor declares them, and `ratchet validate` checks the plan against the declaration. `run`, `run_time`, and `queue_wait` are Ratchet’s. |
| Subject kind, audience, stage, owner reference | For example `codebase`, `api-consumer`, `pre-merge`, `story:filter-bar` | The author. Free labels. |

An aggregation is a map, `{kind: percentile, parameter: 95}` or `{kind: median}`. `environments` is always a list.

### Illustrative project YAML

The field names and commands in this document are proposals, and the numbers in this YAML are illustrations. The example shows a sampled measurement against an absolute limit, two measurements from one UI evaluation, three measurements from one test run under conditions per target class, a time window over the runs of that plan for an operational gate, and a generated reference.

```yaml
format: ratchet/1
project: partner-portal

statements:
  search-is-fast:
    text: A search shows its results before the user looks away.
    audiences: [portal-user]

subjects:
  partner-search:
    kind: user-interaction
    audiences: [portal-user]
  test-step:
    kind: development-workflow
    audiences: [coding-agent, developer]
  build-pool:
    kind: development-workflow
    audiences: [coding-agent, developer]
  reference-docs:
    kind: codebase
    audiences: [developer, coding-agent]

assessments:
  search-request-latency:
    subject: partner-search
    assessor: browser-request-timing@1
    target: {kind: deployment, environments: [ephemeral], selection: candidate}
    observation:
      kind: controlled_run
      scenarios: [ess-ui:partner-portal/partner-search]
      workload: workloads/partner-search.yaml
      min_samples: 200
      conditions:
        all: {runner: dedicated}
    measurements:
      p95:
        kind: sampled
        output: search_request_duration
        boundary: request_start_to_response_complete
        scope: journey
        aggregation: {kind: percentile, parameter: 95}
        unit: ms
        better: lower

  search-ui:
    subject: partner-search
    assessor: ux-eval@1
    inputs: {report: target/ux-eval/report.json}
    target: {kind: revision, environments: [local, ci]}
    observation:
      kind: snapshot
      scenarios: ["ess-ui:partner-portal/search-*"]
      coverage: {executed: {min: 3}, skipped: 0, not_run: 0, unsupported: 0}
    measurements:
      findings:
        kind: exact
        output: findings
        scope: page
        identity: [rule, node_path, environment]
        filter: {severity: [serious, critical]}
      steps:
        kind: exact
        output: steps
        scope: journey
        unit: steps
        better: lower

  test-step:
    subject: test-step
    assessor: command-timing@1
    target: {kind: revision, environments: [local, ci]}
    observation:
      kind: controlled_run
      command: task test
      runs: 1
      conditions:
        all:
          tools: {rustc: {pin: rust-toolchain.toml}}
          cache: warm
        local: {host_load_per_cpu: {max: 1.0}}
        ci: {runner: ci-standard}
      coverage: {skipped: 0}
    measurements:
      step-time:
        {kind: sampled, output: duration, boundary: run_time, scope: run, unit: s, better: lower}
      queue-wait:
        {kind: sampled, output: duration, boundary: queue_wait, scope: run, unit: s, better: lower}
      test-time:
        {kind: sampled, output: duration, boundary: run_time, scope: test, unit: s, better: lower}

  pool-queue-wait:
    subject: build-pool
    assessor: record-series@1
    target: {kind: revision, environments: [ci]}
    observation:
      kind: time_window
      window: {length: 7d}
      population: {runs_of: test-step, from: any_revision}
      min_samples: 20
    measurements:
      p90:
        kind: sampled
        output: queue-wait
        scope: run
        aggregation: {kind: percentile, parameter: 90}
        unit: s
        better: lower

  generated-docs:
    subject: reference-docs
    assessor: generator-check@1
    target: {kind: revision, environments: [local, ci], selection: merge_result}
    observation:
      kind: snapshot
      command: task docs-check
      conditions:
        all:
          tools: {rustc: {pin: rust-toolchain.toml}}
    measurements:
      digest: {kind: exact, output: digest, scope: file}

requirements:
  search-latency-budget:
    meaning: 95 of 100 searches answer within 100 ms.
    serves: [search-is-fast]
    assessment: search-request-latency
    condition: {operator: lt, value: 100, unit: ms}
  no-new-search-findings:
    assessment: search-ui
    measurement: findings
    condition: {operator: no_new_items}
    reference: {kind: accepted_value}
    planted_defects:
      - {id: unlabelled-button, patch: quality/defects/unlabelled-button.patch}
  search-steps-do-not-rise:
    assessment: search-ui
    measurement: steps
    reference: {kind: accepted_value, tolerance: {percent: 5}}
  test-step-budget:
    assessment: test-step
    measurement: step-time
    condition: {operator: lte, value: 120, unit: s}
    reference:
      kind: accepted_value
      tolerance: {percent: 10, absolute: 5}
      adoption: {from: trusted_revision, runs: 10, aggregation: {kind: median}}
  test-budget:
    assessment: test-step
    measurement: test-time
    condition: {operator: lte, value: 60, unit: s}
  queue-wait-budget:
    meaning: 9 of 10 runs of the test step start within 300 s of being queued.
    assessment: pool-queue-wait
    condition: {operator: lte, value: 300, unit: s}
  generated-docs-current:
    assessment: generated-docs
    reference: {kind: generated, paths: ["docs/reference/**"]}

gates:
  merge:
    stage: pre-merge
    qualifying_environments: [ci]
    requires:
      - no-new-search-findings
      - search-steps-do-not-rise
      - test-budget
      - {requirement: test-step-budget, mode: report, since: 2026-11-23}
      - {requirement: generated-docs-current, when: {changed: ["docs/**", "spec/**"]}}
  promote:
    stage: pre-promotion
    qualifying_environments: [ephemeral, ci]
    evidence: any
    requires: [search-latency-budget, generated-docs-current]
  build-pool:
    kind: operational
    stage: daily
    qualifying_environments: [ci]
    requires: [queue-wait-budget]

exceptions:
  filter-reset-target-size:
    requirement: no-new-search-findings
    item:
      rule: target-size
      node_path: /search/filters/reset
      environment: {viewport: narrow, theme: light, input_mode: pointer}
    reason: The filter bar is replaced in the next release.
    owner: story:filter-bar
    expires: 2026-12-15
```

The sample count illustrates a project choice. A real plan also defines how the assessor selects the request, handles errors and timeouts, and versions the workload. For user-perceived latency, the measurement would instead span the input action to the expected result becoming visible. Both measurements can use the same interaction.

Two things are not written in the YAML because the assessor declares them (§ 4). One is the coverage unit: `executed: {min: 3}` of `search-ui` counts the unit of `ux-eval@1`, and `skipped: 0` of `test-step` counts tests. The other is a local input: `test-step` passes no input for the place of the build pool’s job log, because `command-timing@1` declares `job_log` as local and the local config supplies it (§ 5).

The accepted values are not in this file. They live in reference records that the `ratchet reference` commands write (§ 5, § 6). The specification names the kind of reference, the tolerance, and the adoption rule. One reference record, for `search-steps-do-not-rise`:

```json
{
  "format": "ratchet-reference/1",
  "requirement": "search-steps-do-not-rise",
  "kind": "accepted_value",
  "revision": "<commit the value was adopted at>",
  "values": [
    {"scope": "journey", "item": "ess-ui:partner-portal/search-by-name", "value": "7", "unit": "steps"}
  ],
  "conditions": {"tools": {"ux-eval": "1"}},
  "evidence": ["run:<id>"],
  "last_change": {"kind": "first_adoption", "authorized_by": "decision:<id>"}
}
```

Decimals are text in records and reports, so no value changes in a conversion. A value without a unit has no `unit` key.

The record of an identity set has `items` in place of `values`. For `no-new-search-findings`:

```json
{
  "format": "ratchet-reference/1",
  "requirement": "no-new-search-findings",
  "kind": "accepted_value",
  "revision": "<commit the set was adopted at>",
  "items": [
    {
      "identity": {
        "rule": "color-contrast",
        "node_path": "/search/results/row/meta",
        "environment": {"viewport": "narrow", "theme": "dark", "input_mode": "pointer"}
      }
    },
    {
      "identity": {
        "rule": "region",
        "node_path": "/search/banner",
        "environment": {"viewport": "wide", "theme": "light", "input_mode": "pointer"}
      },
      "reason": "<why this finding is accepted>",
      "owner": "decision:<id>"
    }
  ],
  "conditions": {"tools": {"ux-eval": "1"}},
  "evidence": ["run:<id>"],
  "last_change": {"kind": "first_adoption", "authorized_by": "decision:<id>"}
}
```

- An item is an object. `identity` holds exactly the fields of the measurement’s identity key, and a field can be a map, as `environment` is.
- `reason` and `owner` sit beside `identity` and not inside it, so a key with a field of that name stays unambiguous. Both are optional.
- An item holds nothing else. Severity, message, and location are in the evidence.
- The set is one per requirement, whatever the scope of the measurement. The identity key tells two items apart.
- The `item` of an exception on a set has the shape of `identity`, as in the YAML above.
- An `identity` with other fields than the key makes the reference not comparable, with the cause `reference_not_comparable`.

## 4. Presets and custom assessors

The catalog should grow across product quality and the quality of the software factory itself.

| Domain | Candidate preset families | Evidence source |
| --- | --- | --- |
| Web | UI behavior, keyboard interaction, accessibility, actions per task, page or interaction latency, bundle size | ESS UI reports, `ux-ui` evaluations, browser runners, scanners, build outputs |
| Backend | Contract conformance by case, latency, error rate, throughput, cost per operation (instructions, syscalls, allocations, bytes) | ESS conformance reports, load runners, counters and profilers, service telemetry |
| Code quality | Static analysis findings, lint, complexity, coverage, dependency count | Existing analyzers, coverage reports, lockfiles or build graphs |
| Consistency | Generated files match their generator; numbers in documents match records; citations and references resolve | Generators, Ratchet records, link and citation checkers |
| Compatibility | A published surface (API, CLI, schema) compared with the last release | Surface diff tools, the changelog |
| Security | Secret scans of the tree and of run records | Existing scanners |
| Test evidence | Counts of executed, skipped, and ignored tests or scenarios, as measurements | Test and conformance reports |
| Development | Clean and incremental build time, test turnaround, time per test and per test step, gate run time and queue wait | Build and test commands under declared tools and a cache profile, build pool logs |
| CI and release | Time to first actionable verdict, total workflow duration, queue wait, release lead time | Workflow stage events, CI runs, release records |
| Spend | Money and model calls per run or per day | Run logs, provider usage reports |
| Review | Open findings of an adversarial or independent review at a revision | Review records |

For code quality, an assessor can wrap the project’s existing tool or import a report already generated by CI. Preserve findings with rule IDs, severity, and locations so the agent can act on them. A brownfield project can gate on **new findings** by comparing stable finding identities against an accepted set. A total count alone can let a new violation hide behind the removal of an unrelated one.

The same comparison applies beyond analyzer findings (F7, F9, F18). A total of passing cases has the weakness of a total of findings: “a new pass beside a pass turned fail would keep the total” (swell D3). A conformance or test report can be compared as an identity set with `no_lost_items`: no case in the accepted set fails or stops running. The answers name three such identities: the run lines of a conformance suite (swell E4), the ids of executed scenarios (spindle B5), and scenario ids compared between two jobs (ext-05 B7). For UI findings the identity is the rule id, the `ess-ui` node path, and the environment: viewport, theme, and input mode (consumer gap 4). An assessor declares the identity key of each set it returns.

**Reviews as assessors.** 11 answers report a regression found by a review after the gates had passed, and 23 name something a machine cannot check (F13, F17). A review assessor imports a review’s findings as an identity set tied to the revision the review judged. A requirement can then ask for no open finding above a severity at the candidate revision. A review of another revision does not qualify. Review results are otherwise “not re-run later” (inbox D2). A closed finding names the test that failed before its fix (ux-ui E4), and from then on an automated assessor carries it.

**Proof that a check can fail.** A check that has never returned fail has the standing of a first reference compared with itself. 8 answers plant a defect or test the check itself: 65 planted defects a gate must refuse, 8 broken copies of a manifest (F15). A requirement can declare planted defects, which are inputs the assessor must refuse. A planted defect has an `id` and one of two forms. `inputs` replaces inputs of the plan for that run: a broken copy of a manifest, a report with a known finding. `patch` is a patch file applied to a scratch copy of the tree. `ratchet prove` runs the assessment once per defect, never in the working tree, and expects the verdict fail. Insufficient evidence is not a refusal. The proof record holds the ids refused and the ids accepted. A gate report marks an enforced requirement with no proof record and no recorded fail as unproven.

**Custom assessors.** A custom assessor can run as a project command or import a structured report. It declares supported targets, configuration inputs, output types, a coverage unit, and a version.

- **Inputs.** Each input has a name, a type (string, integer, decimal, boolean, path, or a list of one of these), whether it is required, a default, and whether it is local. A plan passes the inputs that are not local as `inputs`, and `ratchet validate` checks names and types against the declaration: the workflow to read, the path of a report, an exclusion the tool applies.
- **Local inputs.** A local input is one whose value differs per machine, such as the place of a build pool’s job log, which is in a state directory of each machine (slot B2, B7). It has the type `path`. The specification cannot set it, and the local config supplies it under `[inputs]` (§ 5; § 9, D6, default A).
- **Outputs.** For each output the assessor declares the value type, the kind, the scopes, the unit or that the output has none, the boundaries of a duration, and the identity key of a set and the fields of its items.
- **Coverage.** The assessor declares one coverage unit and the coverage counts it reports, for the assessor as a whole and not per output. A run has one set of counts, whichever outputs a plan reads (§ 3).

It returns evidence in the same format as bundled assessors. The CLI validates those outputs and applies the project’s comparison rules. This keeps custom measurements usable in the same gates and history from their first run.

**Presets.** A preset is a `ratchet/1` document with a `preset` block in place of `project`: a name, a version, and declared `inputs` with the shape of an assessor’s inputs, none of them local. Its statements, assessments, and requirements refer to an input as `${inputs.<name>}`. A project binds a preset under a name:

```yaml
presets:
  ux:
    use: web-ux@1
    digest: sha256:<digest of the preset file>
    with:
      scenarios: ["ess-ui:partner-portal/*"]
      steps_tolerance_percent: 5
```

The bound entries join the project under the binding’s name, such as `ux.steps-do-not-rise`, and a gate lists them like any other requirement. A preset declares no gate and no exception: which requirement blocks at which stage is the project’s decision. A project changes a preset’s behaviour only through its declared inputs. The binding carries the digest of the preset file, and a resolved preset with another digest is a validation error. The local config says where to look for presets and cannot change what is found. A consumer’s own family, such as the `web-ux@1` that `ux-ui` plans, binds the same way from its own directory. This shape is new in revision 3, and no example has tested it.

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
| What it is | A committed file that a generator reproduces from sources in the tree: a schema, generated documentation, a CLI snapshot | A measured value, a count, or an identity set recorded from evidence |
| In the specification | `reference: {kind: generated, paths: [...]}`. The paths name the committed files. | `reference: {kind: accepted_value, tolerance, adoption}` |
| Comparison | Bytes or digest against a fresh generation, tolerance 0 | Typed comparison with a tolerance per key: 0 for exact values, a band for sampled ones |
| Who may change it | The candidate, in the same change, by running the generator | The candidate may tighten it with its own evidence. Loosening is a policy change. |
| In use | 21 answers | 18 answers |

A generated reference proves that the file matches its generator. It does not prove that the generator is right (canon D3). A merge can leave the file stale without a conflict, so the gate compares on the merged tree, with `selection: merge_result` (runbook C1).

A committed file of measured results is an accepted value, whatever writes it. A file of conformance counts that a full run writes, guarded by a digest of its sources, looks like a generated reference (swell B4, B6; ext-02 C1). As one, the candidate could rewrite it, and a regression would go in with the rewrite. The line is this: a generated reference is a function of sources in the tree. A file made by running the candidate is an accepted value and follows the six rules below.

“Policy from a trusted revision” fits the accepted value. Applied to a generated reference it would refuse the practice of 21 answers, so the format keeps the two kinds apart. An accepted value follows six rules. Each answers a failure in the survey (F7).

1. **Judged by the trusted copy.** The gate reads the reference from the trusted revision, such as the copy on `main`, and not from the candidate’s tree. 4 answers compare this way (F6).
2. **No loosening by the candidate.** A worse value recorded by the candidate does not change what the candidate is judged by. In one answer the commit that caused a regression re-recorded the counter it had moved, and the tool allowed it (entity-runtime C1). A worse value is accepted only through an exception or a trade-off, described below.
3. **First adoption from prior evidence.** A reference is adopted from evidence produced before the candidate, such as observe-mode runs on the trusted revision. Until one exists, the regression comparison returns insufficient evidence. A first run compared with itself passes and proves nothing (ux-ui B6, D1).
4. **Stale after an improvement.** When candidate evidence is better than the reference by more than the tolerance, the gate reports the reference as stale. For a set, better means fewer items under `no_new_items` and more items under `no_lost_items`. For an exact measurement the candidate adopts the better value in the same change, and the gate fails when it does not; 5 answers fail the check or block a release on this (F6). For a sampled measurement, `ratchet reference propose` first collects repeated comparable results. In one answer 27 counters stayed “improved: re-record” from 02:45 to 15:34, so a regression up to each improvement would have passed (entity-runtime C3).
5. **Comparable conditions.** A reference records the tools, image, runner, and host class that produced it. Evidence from other conditions is not compared with it (F7, 4 answers). A project can produce the reference where the gate runs (ext-02 B6), pin the conditions (ext-04 E4), or use a paired run (§ 3).
6. **Stored where the gate can read it.** A reference lives in the repository or with the Ratchet records. A run file in a scratch directory or in a git-ignored directory is not a reference (swell B6, canon B6, ext-03 B6).

A stored series can supply the evidence for an adoption, for example the median of the last 10 runs on the default branch (ext-02 E4, ext-07 E4). Once adopted, the value stays fixed until the next adoption decision.

**The ratchet policy** of a requirement is the `adoption` of its reference.

| `adoption` | Meaning | Default for |
| --- | --- | --- |
| `same_change` | The candidate writes the better value with `ratchet reference adopt`, and the gate verifies it against the candidate’s own qualifying evidence. | Exact measurements |
| `{from: trusted_revision, runs: N, aggregation: {...}}` | The value is the aggregation of the last N qualifying runs on the trusted revision. `ratchet reference propose` reports when they are better than the reference by more than the tolerance. | Sampled measurements. N has no default. |

`ratchet validate` reports a sampled measurement with an accepted value and no `adoption`. A first adoption reads the same source (rule 3). The series of runs is read from the record store (§ 6).

**Reference records.** A reference record holds the requirement, the kind, the revision it was adopted at, the values per scope item or the items of a set, the conditions, the evidence ids, and the context of its last change (§ 3 shows one of each kind). An item of an accepted set is `{identity, reason, owner}`, and the last two are optional. An allowlist entry for a permanent false positive is such an item: one answer scopes an entry by rule and path, another keeps 27 lines with a written reason each (substrate C3, ext-08 C3). Adding an item is a loosening. The place is one JSON file per requirement in the tree, `ratchet/references/<requirement>.json` (§ 9, D1, decided A).

A reference is current or superseded by computation and not by a stored state. It is superseded when a later reference change names it as the previous one. No command moves it.

`ratchet reference propose` writes nothing. It prints the previous value, the proposed value, the evidence ids, the kind of change, and whether the change needs authorization. `ratchet reference adopt` writes the reference record and the context of the change into the working tree. A proposal is not a stored record. The change becomes a reference change record (§ 6) when it reaches the trusted revision.

### Verdicts

A required check returns **pass**, **fail**, or **insufficient evidence**. Only a pass clears the gate. Insufficient evidence covers cases such as too few samples, a timed-out assessor, stale telemetry, or an incompatible target. The survey adds five causes: observation conditions outside the declared ones, including a limit crossed because of the host; coverage below the plan (skipped, not run, unsupported, or a subset); an assessor stopped by its infrastructure, such as a failed tool download or a missing runner; a tool other than the declared one; and a reference that is missing or not comparable (F1, F2, F9).

Insufficient evidence does not clear the gate. What it changes is the next step: run the assessment again under qualifying conditions, and leave the candidate as it is. 12 answers describe good quality as a system that says so when it cannot tell (F17).

Results include the requirement ID, target revision, observed and allowed values, coverage counts, observed conditions, and pointers to the relevant logs, traces, or findings. Each result that is not a pass names its cause and says whether the next step is on the candidate or on the assessment. The agent can then determine whether to fix the candidate or recover the assessment. The causes are a closed list:

| Verdict | Next step | Causes |
| --- | --- | --- |
| Fail | On the candidate | `limit_crossed`, `regression`, `new_items`, `lost_items`, `assertion_not_held`, `generated_reference_differs`, `stale_reference_not_adopted` |
| Insufficient evidence | On the assessment | `too_few_samples`, `assessor_timed_out`, `assessor_infrastructure_failure`, `stale_telemetry`, `incompatible_target`, `conditions_outside_declared`, `coverage_below_plan`, `tool_mismatch`, `reference_missing`, `reference_not_comparable`, `not_attributable_to_candidate`, `not_assessable_here`, `skipped_locally` |

An operational gate has no candidate (below). The next step of a fail there is on the host or the population that the gate judges, and the report says `system` in place of `candidate`.

**The verdict of a gate.** A gate passes when every enforced requirement that applies has passed. It fails when at least one of them fails. In every other case its verdict is insufficient evidence. Fail comes first because a fail is a result about the candidate: recovering the assessment of another requirement would not clear the gate. The report lists the verdict of every requirement in each case, so the agent sees both kinds of work.

**Two states are not verdicts.** A gate entry is **not applicable** when its `when` does not match the change (below). It is not evaluated and does not block, and the gate result lists it with the reason. An assessment is **skipped locally** when the local config left it out of a run on this machine (below). `ratchet status` shows that state beside the last verdict, never as a pass.

### Gate modes

A gate lists each requirement as **enforce** or **report**. An assessment with no requirement in any gate is in observe mode. A report-mode requirement is evaluated and shown with its verdict, and it does not block. 7 answers have such a check today, through a `continue-on-error` flag, a job that is not required, or a `report` setting (F8).

Requirements tend to stay in that state. In 6 answers a written time budget was not enforced while the measured value was over it. Report mode is therefore visible. Each gate result lists its report-mode requirements with the verdict, the observed and allowed values, and the date since which the requirement has not been enforced. A report-mode entry declares that date as `since`, and `ratchet validate` reports one without it. A gate result with failing report-mode requirements says so in its summary line. Without that, a gate that fails “by decision” stops carrying information: “only the counts do” (ext-07 D3).

### Gate entries, deciding evidence, and gate kinds

An entry of `requires` is a requirement name, which means enforce, or a map with `requirement`, `mode`, `since`, and `when`. A gate lists a requirement once, so `<gate>/<requirement>` identifies an entry.

**An entry can apply to some changes.** `when: {changed: [paths]}` makes the entry apply when the change touches a listed path. The change is the difference between the trusted revision and the candidate. One answer runs a full regeneration only when its sources changed (runbook B1). The path list is policy and is read from the trusted revision. An entry that does not apply is not applicable. A path list that misses a source lets a stale file through, so the same requirement belongs without `when` in a later gate, as `promote` shows in § 3.

**Which evidence decides.** A gate can list several classes in `qualifying_environments`. 9 answers get two results for one tree (F10), and one answer states its rule as “the forge’s run judges the budget” (swell C3). `evidence` says which results decide. The classes of a requirement are those that the gate lists and its plan runs in, and `ratchet validate` reports a requirement that has none. A fail from one of them is a fail in both settings.

| `evidence` | A requirement passes when |
| --- | --- |
| `any` | One of its classes returns a pass. Insufficient evidence from another class does not block. |
| `all` | Each of its classes returns a pass. |

A gate that should be decided by one class lists that class alone. `all` needs the records of one class to be readable where the gate is evaluated in another. Records of a local run stay on the machine that produced them (§ 6), so `all` over `local` and `ci` cannot pass in CI. The default is `any` (§ 9, D3, decided A).

**Gate kinds.** A gate is `candidate` by default. An `operational` gate judges a host, a build pool, or a population: queue wait, a production window with mixed revisions. Its evidence is not attributable to one candidate, so it never decides whether a candidate advances. Its verdict is for whoever operates the system. A requirement on queue wait belongs in an operational gate (ext-03 C3, ext-08 C3).

**The evidence of an operational gate is a window** (§ 9, D5, default A). Every requirement of an operational gate names a time-window plan that has no `selection` (§ 3).

- `ratchet evaluate --gate <operational>` takes no candidate. It reads the specification and the references at the trusted revision, as every gate does.
- It assesses each of those plans at the evaluation, so each window ends there. It writes the windows as assessment runs and judges them.
- It does not read the last run alone, and it does not read the runs since the previous evaluation. The window is declared in the plan, so two evaluations at the same moment read the same runs, and a missed day changes nothing. A gate that should judge the last run declares `window: {last: 1}`.
- A per-candidate plan does not feed an operational gate directly. Its runs feed one as the population of a window plan (§ 3, time windows).
- `ratchet validate` reports an operational gate whose requirement names a plan of another kind, a candidate gate whose requirement names a time-window plan without a `selection`, and a `when` in an operational gate, which has no change to match.
- The gate decision records the bounds of each window in place of a candidate (§ 6).

### Policy changes, exceptions, and trade-offs

A candidate’s gate uses policy from a trusted revision. Proposed changes to thresholds, assessor versions, measurement conditions, or protected references are evaluated as policy changes. An explicitly authorized update records the previous value, supporting evidence, and new value. Protocol changes that affect comparability establish a new evidence series or use documented overlap to relate it to the old one. A loosening is a change of its own, merged before the candidate it would affect (§ 9, D2, decided A).

The specification has one identity per project. A gate decision records the revision whose policy and references judged the candidate, so “versioned” means the format version (`ratchet/1`) and the revision the document was read at.

Two updates need no separate authorization, because the gate can verify them: a candidate that regenerates a generated reference, and a candidate that tightens an accepted value its own qualifying evidence meets. Both are still recorded as reference changes.

**Exceptions.** 23 of 26 answers report at least one loosening. 18 of those say it was not tightened again, or that they do not know (F12). The forms are a skipped or ignored test, a raised limit, a known-failing list, an allowlist entry, and a worse accepted value. In the format each is an **exception**: an entry of the specification that names the requirement, the item or value excepted, a reason, an owner reference such as a story or decision id, and an expiry date. `exceptions` is a map, and the key is the exception’s id. For a raised limit, `value` is the condition that holds in place of the requirement’s while the exception applies. 9 answers already require a decision id for a worse value. 3 record a review-by date, and none checks it (F6, F12). `ratchet evaluate` checks the date. Active or expired is computed from the date at evaluation and is not stored. An expired exception no longer applies, so the requirement is evaluated without it. Adding or extending an exception is a policy change. Every gate result lists the active exceptions with their age and expiry. The age is counted from the entry’s `created` date, or from the revision that added the entry when it has none. The list matters because exceptions accumulate: one answer counts 37 acknowledged incompatible changes since the last reset (cortex C3). An exception ends at a date only (§ 9, D4, decided A).

**Trade-offs.** One change can make some values better and others worse on purpose. In the first consumer’s round, a change to in-page navigation moved one value from 23 to 0 and made 20 of 168 values worse (consumer gap 1). With one reference per requirement, that change needs 20 exceptions, and none of them says what was gained. A **trade-off** is a record that lists the values it loosens and the gains it buys:

```json
{
  "format": "ratchet-trade-off/1",
  "id": "in-page-navigation",
  "reason": "<why the gain is worth the loss>",
  "owner": "decision:<id>",
  "gains": [{"requirement": "<requirement>", "item": "<scope item>", "from": "23", "to": "0"}],
  "loosens": [{"requirement": "<requirement>", "item": "<scope item>", "from": "<old>", "to": "<new>"}]
}
```

An entry names a requirement and, where the requirement has a value per scope item, the item. The 168 values of that round are pairs of a scenario and a key: at 14 keys, 12 scenarios (§ 3). In this format a key is a measurement with a requirement of its own and a scenario is a scope item, so one entry addresses each value. One reference change is recorded per requirement the trade-off loosens, and each names the trade-off. `ratchet reference propose` with gains named drafts the record from the candidate’s evidence, and `ratchet reference adopt` writes it. The CLI checks both lists against that evidence: the named gains are present, and nothing outside `loosens` got worse. The loosened values become the references, so a trade-off has no expiry. A worse value that buys no named gain remains an exception and expires.

### Local config

The local config is `ratchet.toml`, per machine or per checkout. The specification is policy and is judged from the trusted revision. The local config carries none (open questions Q1, Q2).

```toml
[spec]
paths = ["ratchet.yaml", "quality/*.ratchet.yaml"]

[catalog]
sources = [{ git = "https://github.com/beyond10x/ratchet", rev = "<commit>", path = "presets" }]

[records]
store = "git:refs/ratchet/records"

[environment]
class = "local"

[local]
skip_sampled_outside_conditions = true
skip = ["search-request-latency"]
observe_only = ["test-budget"]

[tools]
nextest = "cargo nextest"

[inputs.test-step]
job_log = "/var/lib/build-pool/jobs.jsonl"
```

`<commit>` is a placeholder, and `presets/` does not exist in the repository yet. `[records] store` names the ref that holds the series (§ 6). `[inputs.test-step]` supplies the local input `job_log` of the plan `test-step` of § 3, and the path is an illustration.

1. **A gate reads no `[local]` key.** `[local]` selects what `ratchet assess` and `ratchet status` do on this machine: `skip` names assessments that do not run here, and `observe_only` names requirements that `ratchet status` shows with their value and leaves out of its summary. A requirement leaves a gate only through the specification: an exception, or report mode.
2. **A local skip is recorded and shown.** `ratchet assess` records a skipped assessment as a run that executed nothing, with the cause `skipped_locally`, and reports it as “skipped locally by ratchet.toml”. A gate that finds only that record returns insufficient evidence with that cause.
3. **Outside the class `local`, `ratchet evaluate` refuses a config that carries `[local]` skips.** `skip`, `observe_only`, and `skip_sampled_outside_conditions` are skips. It names the key and returns the refusal `local_skips_refused`. It does not ignore the section. The class is `ci` when a CI environment is detected, whatever the file says.
4. **The skip rule holds no number, and its check is not evidence.** `skip_sampled_outside_conditions` reads the bound from the plan. Before a sampled assessment runs, the CLI compares the declared conditions with what it can read at that moment: the tools, the runner, and for `host_load_per_cpu` the 1-minute load average at that moment, divided by the number of CPUs. The check decides one thing, whether the run starts. A run that does not start is skipped locally (rule 2). A run that starts is judged as § 3 defines, by the mean over the run. It can still end outside the declared conditions, and the cause is then `conditions_outside_declared`.
5. **Several paths form one specification.** Ids are unique across the files of `[spec] paths`, a duplicate is a validation error, and the files declare one `format` and one `project`.
6. **`[inputs]` supplies local inputs and nothing else** (§ 9, D6, default A). `[inputs.<assessment>]` gives a value to an input that the plan’s assessor declares as local (§ 4).
   - A key for an input that is not local is refused with `input_not_local`. A threshold, a filter, or an exclusion therefore cannot move into this file.
   - A local input set in the specification is a validation error, so the trusted revision holds no path of one machine.
   - The value says where evidence is read and decides nothing about a verdict. `ratchet assess` reads `[inputs]`, and a gate does not. The machine is trusted with it as it is with `[tools]`.
   - The assessment run records the resolved value.
   - A required local input with no value on this machine makes the requirement not assessable there: insufficient evidence with the cause `not_assessable_here` (§ 3).
   - `[inputs]` is not a skip. Rule 3 does not refuse it, and a CI runner has its own.

### Proposed CLI

| Command | Purpose |
| --- | --- |
| `ratchet init` | Create a project spec and bind selected catalog presets. |
| `ratchet validate` | Check the spec, resolve references, and validate assessor configuration. Report sampled measurements without declared conditions; accepted values without a direction, a tolerance, or an adoption rule where § 3 and § 5 require one; exceptions without a reason, an owner, or an expiry; a time-window plan without a `window`, a `population`, or `min_samples`; and a requirement whose plan does not fit the kind of its gate. |
| `ratchet assess` | Run selected assessors or ingest their results and produce structured evidence. |
| `ratchet evaluate --gate promote` | Evaluate a named gate using qualifying evidence and emit a report with an exit status CI can enforce. The report lists report-mode requirements, entries that are not applicable, active and expired exceptions, and coverage. For an operational gate it takes no candidate and assesses the gate’s windows first. |
| `ratchet reference propose` | Print an evidence-backed proposal to adopt a stronger protected reference, or a trade-off that names its gains. Write nothing. |
| `ratchet reference adopt` | Write the proposed reference record, and the trade-off record where there is one, into the working tree. |
| `ratchet prove` | Run a requirement’s planted defects and record that the check refuses each. |
| `ratchet render` | Write a block of numbers in a document from records, and the static export of § 6. With `--check true`, compare what is committed with a fresh one. |
| `ratchet status` | Show every requirement: verdict, value against its limit or reference, when it was last checked and where, and whether it is skipped locally. |
| `ratchet explain <requirement>` | Print the requirement’s `meaning`, the statements it serves, its audience, how it is measured, and where its evidence is. |
| `ratchet diff <requirement>` | Compare the candidate with the reference item by item: new items, lost items, worse and better values. |
| `ratchet exceptions` | List active and expired exceptions, and those that expire within a number of days. |
| `ratchet doctor` | Check that the local config, the specifications, the tools, the local inputs, and the record store are reachable. |
| `ratchet history <requirement>` | Show the series with the reference line, reference changes, and exceptions marked. It reads the record store. |
| `ratchet import` | Write history that exists elsewhere as assessment runs: forge runs, build pool logs, JUnit files. The records reach the store as those of any run do (§ 6). |
| `ratchet serve` | Serve the page of § 6 over the record store. |

The last eight commands come from the [product brainstorm](product-brainstorm.md) § 3.

The command surface is declared as an `ess-cli/2` binding, and the parser is generated from it. Three things follow.

- **Spelling.** A flag takes a value and a list is JSON: `--check true`, `--presets '["web-ux@1"]'`.
- **Exit status.** `ratchet evaluate` exits 0 only on a pass. A failed gate and a gate with insufficient evidence exit with the same non-zero status, and the code in the report tells them apart: `gate_failed`, `insufficient_evidence`.
- **Typed reports.** The gate report has the same typed rows for a pass and for a non-pass. Observed and allowed values are rows with a value type, a unit, and decimals as text.

## 6. Results and visualization

Store observations, decisions, and reference changes as separate records. This makes it possible to re-evaluate old evidence against a new requirement and still see which policy governed the original decision.

| Record | Required context |
| --- | --- |
| Assessment run | Candidate identity, resolved target and its class, assessor and protocol versions, timestamps or window bounds, values per measurement with value type, kind, unit, and scope, sample or run count, coverage counts with their unit, observed conditions (runner, host load, tools, cache profile), queue wait and run time, the resolved value of each local input, artifact references, and for an imported run where it came from. For a window: the number of population items, the time of the newest, and the number of runs left out. |
| Gate decision | Candidate, or for an operational gate the window bounds of each requirement. Gate, the revision of the policy, evidence IDs, and the verdict of the gate. Per requirement: the protected reference or absolute limit, the mode, the verdict with its cause and next step, exceptions applied, and whether it is proven. Entries that were not applicable. |
| Reference change | One requirement, the kind of change (first adoption, regeneration, tightening, loosening, trade-off), previous and adopted references, the conditions of the adopted one, supporting evidence, the trade-off it belongs to, and the revision or decision that authorized adoption. |
| Trade-off | Reason, owner reference, the gains and the loosened values with their requirements and scope items, and the decision that authorized it. |
| Proof | Requirement, revision, the planted defects run, and the ids refused and accepted. |

An exception is an entry of the specification and not a record of its own. A gate decision copies the exceptions it applied, with their reason, owner reference, and expiry.

An authored entry has the id its author gave it: the key of its map. A record gets its id from the CLI when it is written, as its type and a digest of its content, such as `run:<digest>`. Two writers then need no coordination.

The file form of an assessment run is drafted as `ratchet-evidence/1` in [`docs/evidence-format.md`](https://github.com/beyond10x/ratchet/blob/main/docs/evidence-format.md), which lists its fields, decides the first assessor’s gaps U1 to U9, and leaves six questions to the owner.

**The record store** has two parts with one role each (open questions Q3). Records are versioned JSON.

- **Hand-over.** A run writes its records as a CI artifact. A pull-request job needs no push rights.
- **Series.** One job on the trusted branch appends the handed-over records to the git ref `refs/ratchet/records`. It is the only writer. Gates and views read the ref, and `git fetch` gives a local gate the records that CI reads.

The hand-over can be built first. The ref follows with the first requirement that needs a series, such as a sampled adoption (§ 5) or a window over the runs of a plan (§ 3). The same job writes a reference change to the ref when its change reaches the trusted revision. Records of a local run stay on the machine that produced them. The push right of the writer and the author of its commits are the owner’s to set. The decision sets no retention for the ref. Reference records live in the tree (§ 9, D1).

**Views** (open questions Q4). One page and one JSON data document serve two forms, built together. The static export is written by `ratchet render`: a CI artifact, a committed file, or a page of the docs site. The served app is `ratchet serve`, which answers over the record store. Both show the same page over the same data. `ratchet status` is the terminal form. A committed export is a generated reference, and `ratchet render --check true` fails when it is stale.

**Across repositories** (open questions Q6). A view across repositories is a consumer of Ratchet’s records and not a part of Ratchet. Ratchet publishes the record format, versioned, and an export per repository. Another project aggregates, and which one is not decided here. Ratchet keeps no shared index and no list of repositories. The record format is a public contract from its first release. Proposed: the export is the data document of the static export, so one document serves the page and the consumer.

Useful views include observed values alongside the enforced boundary, a history of gate decisions, and a breakdown of time to first verdict by CI stage. Label protocol changes and environment changes on charts so a change to the runner or workload remains visible. The survey asks for four more views: queue wait apart from run time, report-mode requirements with the time each has gone unenforced, active exceptions by expiry, and coverage counts per run.

**A series per measurement.** No answer reports a stored series of CI duration, queue wait, or lead time. The figures given were read from the forge or from a job log on the day (F11). 4 answers saw a value grow toward a fixed limit and noticed when it reached the limit: a scan input at 512.3 MiB against 512 MiB, a test step at 120 s. One record per run shows the distance to the limit before that. Much of the data exists outside the repository. The forge keeps run history, and a build pool can log queue wait, run time, and CPU seconds for every job (slot B2, B7). An assessor imports it from there.

An imported run is an assessment run record that names its source. Context the source does not hold, such as host load, is recorded as unknown. Evidence with an unknown value for a declared condition does not qualify for a gate. It still extends a series.

**Numbers in documents come from records.** 16 answers keep measured numbers as hand-written prose in an instruction file, a changelog, a story, or a README, and nothing checks that they are still true (F11, F14). One answer rewrites the gate’s counts in 7 files at every release (surf D1). Each record has a stable id that prose can cite. `ratchet render` writes a marked block in a document from records, and `ratchet render --check true` fails when the block differs from a fresh one. The block is then a generated reference (§ 5). 3 answers already generate a statistics block or badges from a source and do not write them by hand (ext-02 B1, ext-05 B7, ext-07 B1).

## 7. ESS integration and first implementation

ESS provides authored conformance scenarios and reports. ESS UI provides named interactions and expectations over canonical node paths, fixture-backed reads, virtual time, and a Playwright projection. Ratchet can import the verdict from a fixture-backed test for fast behavioral feedback. A separate deployed assessor can reference the same interaction and reuse supported steps and node addresses while collecting wall-clock evidence against the real deployment. [ESS conformance](https://beyond10x.github.io/docs/ess/guides/verify-conformance/) · [ESS UI test reference](https://beyond10x.github.io/ess/docs/reference/ess-ui-test)

The `ux-ui` repository has offered to be the first consumer of the ESS UI integration. It plans a preset family `web-ux@1` and an assessor `ux-eval@1` that evaluates design variants of an `ess-ui/1` document with no I/O and emits Ratchet evidence ([consumer input](../research/consumer-input-ux-ui.md)). Its measurements are exact, which suits fixture-backed feedback. §§ 3 to 5 answer the four gaps it reported.

The first proposal named three integrations to prove the shared contract. The survey shows which practices are most common: a generated file compared by bytes (21 answers), a file of accepted values per key (18, of which 12 are one kind of UI loop), and a time budget for the test step (21 write the rule; 13 of 26 proposed one-line rules are about time or cost). The three integrations still fit, each with a wider contract, and the survey adds a fourth.

1. **ESS UI behavior.** Import a structured result and enforce an assertion with `holds`. With `ux-ui` as the first consumer, the import also carries exact values per scenario and key under accepted values, page-scoped findings compared by identity, and a trade-off. 12 answers run a UI loop of this shape with their own comparison tool, and one answer counted that loop 7 times in 3 languages in one organization (F6).
2. **CI turnaround.** Read workflow timings, establish a protected reference, and catch a regression under comparable conditions. The survey supports this one most: time to a verdict is the top cost in 24 of 26 answers (F3). It reads queue wait and run time apart, covers the local gate and the test step as well as CI workflows, and returns insufficient evidence for a limit crossed under host load. 10 of the 13 time or cost rules measure the project’s own test step (F18).
3. **Code quality.** Import findings from an existing analyzer and enforce a no-new-findings requirement. The survey says little about accepted sets of analyzer findings. Where the answers describe lint, it blocks on any finding, which is a fixed zero (spindle B5, substrate B1). The nearest cases are scan allowlists: one scoped by rule and path (substrate C3), one with a written reason per entry (ext-08 C3). The identity comparison this integration proves is asked for more often for cases, so the same comparison also takes the passing-case set of an ESS conformance report (F7, F9).
4. **Generated artifact.** Run a generator and compare the committed file by digest, tolerance 0. This is the most common baseline in the survey (F5) and the one kind of reference the candidate may rewrite. The first implementation needs it to prove both update rules of § 5.

**Evidence that exists after the stage.** A gate evaluated inside a workflow cannot read that workflow’s total run time. Integration 2 has three placements, and a project chooses per requirement:

- The steps that ended before `ratchet evaluate` are measured in the same run, each by its own measurement, in the pre-merge gate.
- The whole run is judged by a job that starts when the workflow has finished. That job evaluates a gate with a stage of its own and reports to the forge as a separate check.
- The series of finished runs is judged in an operational gate, through a time-window plan whose population is the runs of the per-candidate plan (§ 3, time windows).

A stage is a free label. A gate is evaluated wherever `ratchet evaluate --gate` runs, so a gate at the end of a product run needs no stage that Ratchet defines (ext-03 E4; candidate presets § 6, item 7).

Then add deployed browser timing to exercise candidate attribution and controlled sampling, and production telemetry to exercise windowed assessment. The survey gives little evidence for these two: 3 of 26 answers describe a deployed service and 1 cites a production incident (synthesis § 4, implication 17). Their design is unchanged, except that a time window has a shape now (§ 3), which integration 2 uses first, for its operational gate. The same specification should carry through all six cases. The first end-to-end milestone is a project that can start in observe mode, adopt a gate, reject a regression with actionable evidence, and record an improvement as a new protected reference. It also returns insufficient evidence, and not a fail, when the host and not the candidate caused a limit to be crossed.

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

## 9. Design questions D1 to D6

Revision 3 left four questions to the owner, each a decision about authority or a default that every project inherits. The owner decided all four on 2026-11-24, each as recommended (A). Revision 4 adds D5 and D6. Both are open, and each names a default. §§ 3 to 6 are written under the four answers and the two defaults. The options are kept as the record of the choice. These are separate from the product questions Q1 to Q6 of [open-questions.md](open-questions.md), which are decided.

| Question | Decided | Option |
| --- | --- | --- |
| D1 place of reference records | A | Files in the tree |
| D2 authorization of a loosening | A | A change of its own, before the candidate |
| D3 default of `evidence` | A | `any` |
| D4 exception that ends at an event | A | A date only |
| D5 evidence of an operational gate | Open, default A | A time-window plan |
| D6 an input that differs per machine | Open, default A | Declared local by the assessor, supplied by `ratchet.toml` |

### D1. Where do reference records and trade-off records live?

Open questions Q3 assumes that reference records are files in the tree and does not decide it: its options, and the owner’s answer C, are about runs and decisions. § 5 rule 6 allows the repository or the Ratchet records.

| | Does | Costs |
| --- | --- | --- |
| A | Files in the tree, one per requirement: `ratchet/references/<requirement>.json`, `ratchet/trade-offs/<id>.json`. The gate reads the copy at the trusted revision. | A sampled value adopted from a series on the trusted revision needs a change that someone opens. A reference file is in every diff that tightens a value. |
| B | In the record store, on `refs/ratchet/records`, with runs and decisions. | The ref has one writer, a job on the trusted branch (§ 6). A candidate cannot write there, so “in the same change” (§ 5 rule 4) is no longer one commit, and a tightening waits for that job. |
| C | Exact values and sets in the tree. Sampled values on the ref, written by the job that holds the series. | Two places to read. A sampled reference changes with no change in the tree for a reviewer to see. |

**Decided: A** (the owner, 2026-11-24). § 5 rule 1 reads the trusted copy, and rule 4 has the candidate adopt in the same change. 8 answers commit the new value with the change, and 4 compare with the copy on `main` (F6). A keeps the ref to one kind of content: what was observed and decided.

### D2. How is a loosening authorized?

§ 5 says “an explicitly authorized update” and names no mechanism. The question covers an added or extended exception, a raised limit, a first adoption, and a worse accepted value with no named gain. It does not cover a regeneration or a tightening, which the gate verifies, or a trade-off, whose gain the gate checks.

| | Does | Costs |
| --- | --- | --- |
| A | A loosening never applies to the candidate that carries it. It lands in a change of its own. The forge’s review of that change is the authorization, and the record names an owner reference. The candidate follows. | Two merges for one intended regression. Time to a verdict is the top cost in 24 of 26 answers (F3). |
| B | The candidate may carry the loosening when the record names an owner reference. The gate applies it, and its summary line says that the candidate passed under its own policy change. | The candidate changes what it is judged by. Vision outcome 5 then holds only through the reviewer who reads the mark. 9 answers work this way, with a decision id for a worse value (F6). |
| C | The candidate may carry the loosening when the forge shows an approval of the policy files by a named role, and Ratchet reads that approval. | A ruleset or required reviewer is the owner’s to set. Ratchet depends on one forge’s API. |

**Decided: A** (the owner, 2026-11-24). “A candidate cannot loosen the thresholds it is judged by” (vision, outcome 5). In one answer the commit that caused a regression re-recorded the counter it had moved (entity-runtime C1). A measured cost of the second merge would change the answer to B.

### D3. Which evidence decides by default when a gate lists several classes?

§ 5 defines `evidence: any` and `evidence: all`. The gap that asked for the field proposes `all` as the default (G15).

| | Does | Costs |
| --- | --- | --- |
| A | Default `any`. One qualifying pass clears the requirement, and a fail from a qualifying class blocks. | A local pass clears a gate that lists `local`. A merge gate has to list `ci` alone to be judged by the forge. |
| B | Default `all`. Every listed class that the plan runs in must pass. | A gate evaluated in one class needs the records of the others. Records of a local run do not reach the ref (§ 6), so a gate over `local` and `ci` cannot pass in CI. A loaded workstation blocks a change the forge passed (swell C2, C3). |
| C | No default. `ratchet validate` reports a gate with several classes and no `evidence`. | One more key in every such gate. |

**Decided: A** (the owner, 2026-11-24). Each evaluation judges by the records it can read, which fits the store as decided (Q3). C costs one key and hides nothing, and is the second choice.

### D4. Can an exception end at an event?

An exception expires on a date (§ 5). Three answers accept something until an event: a breaking change until the next release, a failure until a finding is fixed (llm E4, cortex B6, spindle C3; candidate presets § 6, item 5).

| | Does | Costs |
| --- | --- | --- |
| A | A date only. An acceptance that waits for an event gets a date, and extending it is a policy change. | The date is a guess. Each extension is a change. |
| B | `expires` also takes an event, `{when: closed, ref: <owner reference>}`. A resolver that the project configures answers whether it happened: a tag exists, a story is closed. | Ratchet reads plan or release state, which other tools own. An event that never happens never expires: 18 answers report a loosening that was not tightened again or do not know (F12). |
| C | An event and a latest date. The exception ends at whichever comes first. | Needs the resolver of B. |

**Decided: A** (the owner, 2026-11-24). It is what `ratchet/1` can check without a resolver. C follows when a first consumer brings one.

### D5. Which runs does an operational gate read?

An operational gate has no candidate (§ 5). Revision 3 did not say which evidence `ratchet evaluate --gate <operational>` reads, and its YAML fed such a gate from a per-candidate plan (G26).

| | Does | Costs |
| --- | --- | --- |
| A | A requirement of an operational gate names a time-window plan. The plan declares the `window`, the `population`, and `min_samples`. A per-candidate plan feeds it as `population: {runs_of: ...}`. The evaluation assesses the window that ends there. | A second plan for a series that a per-candidate plan already produces. `ratchet evaluate` runs an assessor for these gates. |
| B | A key on the gate, `over: {last: N}` or `over: {length: 7d}`. The gate reads that many runs of the per-candidate plan that its requirement names. | N runs give N verdicts, or they need an aggregation, which is a key of a measurement (§ 3) and would be written twice. A production window still needs a time-window plan, so one kind of evidence has two mechanisms. One plan is per candidate in one gate and a population in another. |
| C | Every run since the last decision of the gate. No key. | The evidence depends on when someone last evaluated. A repeated evaluation gives another verdict, a missed day doubles the population, and the first evaluation has no start. |

**Default: A.** The window, the aggregation, and the sample count are then declared in one place, the plan, and recorded in the evidence. “The last run” is A with `window: {last: 1}`. What would change the answer: many window plans that only repeat a per-candidate plan with an aggregation added. Then B, as a short form that expands to A.

### D6. Where does an input live whose value differs per machine?

A plan’s `inputs` are part of the specification, which is read from the trusted revision. The job log of a build pool is in a state directory of each machine (slot B2, B7; G27). The local config carries no policy (Q2, decided A), and it had no place for an input.

| | Does | Costs |
| --- | --- | --- |
| A | An assessor declares an input as local, with the type `path`. `ratchet.toml` supplies it under `[inputs.<assessment>]`. The specification cannot set a local input, and the local config cannot set any other. The assessment run records the resolved value. | The machine says where its evidence is read, as it says which command is a tool. A wrong path gives evidence from the wrong file, and only the record shows it. A place that is not a path, such as the address of a local service, needs a second type. |
| B | The specification holds the input with a variable that the machine resolves: `job_log: "${env.POOL_STATE}/jobs.jsonl"`. | The value comes from the environment of the process. `ratchet doctor` cannot list it, and a CI job of the candidate can set it. Every input becomes a template. |
| C | No local input. The assessor finds the file by a convention of its own, or `ratchet import` copies it to a path in the tree before the run. | Each assessor invents a rule for finding its file. Neither the specification nor the local config says where the evidence came from. |

**Default: A.** A gate still reads nothing from the local config (Q2): `ratchet assess` reads `[inputs]`, and a gate reads evidence. The two refusals of § 5 rule 6 keep a threshold, a filter, or an exclusion out of TOML. What would change the answer: a first local input that is not a path. Then the types of a local input grow, and A stays.

## 10. Changes from revision 2

`G<n>` is one of the gaps G1 to G25 that the examples found in revision 2. The full text of each (what was needed, what the design lacked, the proposed fix) is in `examples/README.md` at commit `b7cd992`, [section “Design gaps found”](https://github.com/beyond10x/ratchet/blob/b7cd992deb4192ef8c4d0f89b0f6c12604b68999/examples/README.md#design-gaps-found). `values`, `shapes`, and `numbers` are sections of that file at the same commit: “Values not shown in the design” (with the three shapes below its table) and “Numbers without a source”. The file was rewritten to revision 3 afterwards. It now keeps one line per gap under “Gaps of revision 2 and how revision 3 closed them”, and its two other sections describe the rewritten examples. `marker <file>: <entity>` is an `UNMAPPED:` comment in `spec/domains/<file>.yaml` or `spec/cli.yaml`. `spec README` is a point of [`spec/README.md`](https://github.com/beyond10x/ratchet/blob/main/spec/README.md), section “Where this specification sharpens or departs from docs/design.md”. `presets <n>` is an item of [candidate presets](../research/candidate-presets.md) § 6. `Q<n>` is a question of [open-questions.md](open-questions.md) that the owner decided on 2026-11-24: A for Q1, Q2, and Q5, C for Q3 and Q4, B for Q6. The examples and the specification were written against revision 2, so neither showed the shapes of revision 3 when it was written. The examples were rewritten to revision 3 afterwards (§ 11).

| Change | Where | Cause |
| --- | --- | --- |
| The specification is YAML and the local config is TOML; “local config” is a term and a shipped surface | § 1, § 2, § 5 | Q1; spec README (not declared: `ratchet.toml`) |
| A gate reads no `[local]` key; outside the class `local`, `ratchet evaluate` refuses a config with `[local]` skips (`local_skips_refused`); a detected CI environment sets the class | § 5 | Q2; marker cli: `evaluate` |
| “Skipped locally” is a state and not a verdict; the skip is recorded as a run that executed nothing; a gate returns insufficient evidence with the cause `skipped_locally` | § 5 | G22; spec README (skipped locally) |
| The local skip rule holds no number and reads the plan’s bound; several `[spec] paths` form one specification with unique ids | § 5 | G22 |
| The preset catalog is the directory `presets/` here; a preset has a `preset` block with inputs; a project binds it with `use`, `digest`, and `with` | § 1, § 2, § 4 | Q5; presets 1; spec README (not declared: preset) |
| Quality statement as a term; `statements`, and `meaning` and `serves` on a requirement | § 1, § 3, § 5 | marker specification: `QualityRequirement.meaning`; spec README (not declared: quality statement) |
| The ratchet policy is `reference.adoption`, per requirement: `same_change` for exact measurements, `{from, runs, aggregation}` for sampled ones | § 1, § 5 | G1; marker specification: `RatchetPolicy` |
| Reference record: fields, one illustrative record, a proposed place in the tree | § 3, § 5 | G2 (place: D1) |
| A reference is current or superseded by computation; no stored state | § 5 | marker reference: `ProtectedReference` |
| `ratchet reference propose` writes nothing and `ratchet reference adopt` writes; a proposal is not a stored record | § 5 | marker reference: `ReferenceChange` (authorization: D2) |
| A trade-off is a record of its own with `gains` and `loosens`, each entry `{requirement, item, from, to}`; one reference change per loosened requirement names it | § 1, § 5, § 6 | G3; spec README (trade-off) |
| A plan holds a map of `measurements` and runs once; a requirement names the plan and the measurement; `also_record` is removed | § 1, § 3 | G4; values (`boundary`) |
| `scenarios` is a list and takes a pattern | § 3 | G5 |
| Operators `gt`, `gte`, and `eq`; `better: lower` or `higher` on a measurement; a requirement may hold a limit, a reference, or both | § 3 | G6; presets 3; shapes; spec README (YAML shapes) |
| The five number operators compare the item count of a set; `no_lost_items` | § 3, § 4 | G7; presets 3 |
| Tolerance takes `absolute` beside `percent`; the wider band applies | § 3 | G8 |
| Assertion as a value type, with the operator `holds` | § 3, § 7 | G9 |
| Coverage keys `executed`, `skipped`, `not_run`, `unsupported`, and `executed_ids`; the direction of a bare number; `{min, max}` | § 3 | G10; spec README (coverage bounds) |
| `filter` on a measurement of an identity set | § 3 | G11 |
| An item of an accepted set can carry `reason` and `owner`; adding an item is a loosening | § 5 | G12 (an end at an event: D4; presets 5) |
| Assessor inputs have a name, a type, a required flag, and a default; a plan passes `inputs` | § 4 | G13; marker assessor: `Assessor.configuration_inputs`; presets 1 |
| `conditions` keyed by target class with `all`; host load defined as a mean per CPU, with minimum and maximum recorded; no default bound | § 3 | G14; numbers (host load bound) |
| `evidence: any` or `all` on a gate; a fail from a qualifying class is a fail | § 5 | G15 (default: D3) |
| `when: {changed: [paths]}` on a gate entry; the state “not applicable” | § 5 | G16 |
| `reference: {kind: generated, paths: [...]}` | § 5 | G17; presets 3, 9 |
| A committed file of measured results is an accepted value; a generated reference is a function of sources in the tree | § 5 | G18 |
| The condition `tools` names each tool with a version or a pin file; `toolchain: pinned` is removed | § 3 | G19 |
| `selection: merge_result` | § 3, § 5 | G20 |
| `runs: 1` without an aggregation is valid; repeats are needed for an aggregation and for a sampled adoption | § 3 | G21; shapes; numbers (`runs: 1`) |
| Gate kind `candidate` or `operational`; a requirement on queue wait belongs in an operational gate | § 1, § 5 | G23 |
| Three placements for evidence that exists after the stage; a stage is a free label | § 7 | G24; presets 7 |
| Value lists: which are closed, which the assessor declares, which are free labels; scope is no longer a closed list; Ratchet’s values are spelled in snake_case | § 1, § 3 | G25; presets 2; values; spec README (YAML shapes) |
| `environments` is always a list; an aggregation is a map `{kind, parameter}` | § 3 | spec README (YAML shapes) |
| A `condition` carries the unit of its measurement; no unit conversion | § 3 | values (`unit`) |
| A snapshot can declare conditions | § 3 | shapes |
| The verdict of a gate: fail before insufficient evidence | § 5 | marker gate: `GateDecision.verdict` |
| A closed list of causes per verdict, with `not_assessable_here` for “reported there as not run”, and `assertion_not_held` and `skipped_locally` added | § 3, § 5 | spec README (not run); G9; G22 |
| `ratchet evaluate` exits 0 only on a pass; fail and insufficient evidence share one non-zero status and differ by the report’s code | § 5 | spec README (exit status) |
| The gate report has typed rows, decimals as text, for a pass and a non-pass alike | § 3, § 5 | spec README (no Json in error data) |
| CLI spelling follows the `ess-cli/2` binding: `--check true`, lists as JSON | § 5, § 6 | spec README (CLI spelling) |
| A gate entry is identified by `<gate>/<requirement>`; a bare name means enforce; a gate lists a requirement once | § 5 | spec README (gate entries) |
| `since` is required with report mode | § 5 | numbers (`since`) |
| `exceptions` is a map keyed by an authored id; an exception is an entry of the specification and not a record; active or expired is computed; `value` is the condition that holds in its place | § 1, § 5, § 6 | marker specification: `Exception`; spec README (exception expiry, exceptions) |
| An authored entry has the id of its map key; a record gets its id from the CLI, as its type and a digest of its content | § 6 | marker specification: `Exception` |
| The specification has one identity per project; a gate decision records the revision it was read at | § 5 | marker specification: `QualitySpecification` |
| A planted defect has an `id` and either `inputs` or `patch`; the proof record holds the ids refused and accepted | § 4 | marker specification: `QualityRequirement.planted_defects` |
| A paired run is declared as `paired: {pairs: N}`, measures the revision of the accepted reference, and is not a reference kind | § 3 | marker specification: `ObservationPlan`; presets 9 |
| A time window is declared as `window` and `population` | § 3 | marker specification: `ObservationPlan` |
| An imported run is an assessment run record that names its source; unknown conditions do not qualify for a gate | § 6 | marker evidence: `AssessmentRun.imported_from` |
| `ratchet validate` reports an accepted value without `better`, and a sampled one without a tolerance or an `adoption` | § 3, § 5 | G6; G1; numbers (tolerance 20 %) |
| CLI table: `reference adopt`, `status`, `explain`, `diff`, `exceptions`, `doctor`, `history`, `import`, `serve` | § 5 | markers reference: `ReferenceChange`, specification: `QualityRequirement.meaning`, evidence: `AssessmentRun.imported_from`; G22; Q4 |
| Records table: trade-off and proof rows added, exception row removed, gate decision lists a cause and next step per requirement | § 6 | spec README (trade-off, exceptions) |
| Record store: a CI artifact as the hand-over and the git ref `refs/ratchet/records` as the series, with one writer on the trusted branch; `[records] store` in the local config; records of a local run stay on the machine | § 2, § 5, § 6 | Q3; spec README (not declared: record store) |
| Views: one page and one data document, as a static export that `ratchet render` writes and as a served app, `ratchet serve` | § 2, § 5, § 6 | Q4 |
| A view across repositories is a consumer of the records; Ratchet publishes a versioned record format and an export per repository | § 2, § 6 | Q6 |
| Preset table rows “Compatibility”, “Security”, and “Test evidence”; references that resolve under “Consistency” | § 4 | presets 8 |
| The illustrative YAML is rewritten to the shapes above; an illustrative reference record, trade-off record, preset binding, and local config are added | § 3, § 4, § 5 | the rows above |

### Counts

- Of the 25 gaps, 22 are closed here. G2, G12, and G15 were closed in part and left the place of a reference record (D1), an exception that ends at an event (D4) and the default of `evidence` (D3) to the owner, who decided them on 2026-11-24 (§ 9).
- All 12 markers are closed here. The authorization that the `ReferenceChange` marker also touches is D2.
- All 12 points of the specification’s list are taken. Two are sharpened: a bare coverage number is a minimum for `executed` and a maximum for the other counts, and the four things “not declared yet” (preset, quality statement, `ratchet.toml`, record store) now have a shape.

### Not changed

- **A comparison of two windows** (presets 4). One proposed rule compares 60 minutes after an install with 60 minutes before (slot E4). The time-window design is untested by the survey (§ 8).
- **A check about the world outside the candidate, in a candidate gate** (presets 6). One proposed rule fails a pull request when another project has released (agentplugins E4). A candidate gate takes evidence attributable to the candidate; such a check fits an operational gate, which does not block a merge.
- **A default for a load bound, a sampled tolerance, or a run count of an adoption.** No answer supplies one (numbers; candidate presets § 7). The format requires each to be declared.
- **An empty help line for the `reference` command group** (spec README, CLI spelling). It is a property of the binding and changes nothing here.

## 11. Changes from revision 3

`G26` to `G29` are the gaps in `examples/README.md` at commit `a94ab83`, [section “New gaps”](https://github.com/beyond10x/ratchet/blob/a94ab83f8afb6dcbb8d987a907b41d93039b535d/examples/README.md#new-gaps), found while the examples were rewritten to revision 3. `contradiction` is a place where revision 3 disagreed with itself, and the row names the two places. `README` is another section of that file as rewritten. `D5` and `D6` are in § 9: a row that names one is written under its default.

| Change | Where | Cause |
| --- | --- | --- |
| The evidence of an operational gate is a window: each of its requirements names a time-window plan; `ratchet evaluate --gate <operational>` takes no candidate, assesses those plans, and reads neither the last run alone nor the runs since the previous evaluation | § 1, § 5 | G26 (D5) |
| `window` is `{length}`, `{last}`, or both; `population` is `{runs_of, from}` or `{filter}`; `min_samples` is required; the window ends when the plan is assessed, where revision 3 said at the evaluation | § 3 | G26 |
| A per-candidate plan feeds an operational gate only as the population of a window plan, read by the built-in assessor `record-series@1`; only runs that qualified under the source plan count; the window plan declares no conditions; an `adoption` counts windows | § 3, § 5 | G26 |
| A time-window plan declares a `selection` only when its population is the candidate’s alone; without one it serves an operational gate | § 3 | G26 (the plan that fed the gate had `selection: candidate`) |
| `ratchet validate` reports a requirement whose plan does not fit the kind of its gate, a `when` in an operational gate, and a time-window plan without `window`, `population`, or `min_samples` | § 3, § 5 | G26 |
| Illustrative YAML: subject `build-pool` and plan `pool-queue-wait`; `queue-wait-budget` names that plan and no longer the per-candidate plan `test-step` | § 3 | G26 |
| The next step of a fail in an operational gate is `system`; its gate decision records window bounds in place of a candidate | § 3, § 5, § 6 | contradiction: § 5 verdicts put every fail “on the candidate”, § 5 gate kinds give an operational gate none |
| Third placement of integration 2: the series is judged through a time-window plan; a time window has a shape that integration 2 uses first | § 7 | G26 (§ 7 said “on the trusted branch” and named no plan) |
| Local input: an assessor declares it, with the type `path`; `[inputs.<assessment>]` in `ratchet.toml` supplies it; the specification cannot set it; the local config cannot set another input (`input_not_local`); the run records the resolved value; a missing one is `not_assessable_here` | § 1, § 2, § 4, § 5, § 6 | G27 (D6) |
| A preset input is never local | § 4 | G27 |
| An item of a set’s reference record is `{identity, reason, owner}`; one illustrative record; the set is one per requirement; an `identity` with other fields than the key is `reference_not_comparable` | § 3, § 5 | G28 |
| The exception of the illustrative YAML names the whole `environment`, as an `identity` does | § 3 | G28 |
| Coverage belongs to the plan; its counts count the assessor’s coverage unit, declared once per assessor and not per output; the evidence names the unit | § 1, § 3, § 4, § 6 | G29; contradiction: § 3 had one `coverage` block per plan, § 4 had coverage counts per output |
| An item of a reference with no value in the run is `coverage_below_plan` for that requirement | § 3 | G29 |
| A scenario is a scope item and a walk is a coverage unit; the 30 walks are no longer cited as 30 scenarios; the 168 values are read as 12 scenarios with 14 keys | § 3, § 5 | contradiction: § 3 “the 30 walks” as one result per scenario, § 5 “168 values” as pairs of a scenario and a key; README numbers (`executed: 30`) |
| The check before a local run reads the load at that moment and decides only whether the run starts; the run is judged by the mean over the run | § 3, § 5 | contradiction: § 5 local config rule 4 compared conditions before the run, § 3 defines `host_load_per_cpu` as a mean over the run |
| A number has a `unit` exactly when the assessor declares one for the output; an output without a unit takes none on the measurement, the `condition`, the tolerance, or a record | § 3, § 4 | contradiction: § 3 “a `condition` carries the unit of its measurement”, § 3 operators on a number of items with no unit; README values (`unit: score`) |
| The gaps G1 to G25 are cited at commit `b7cd992` | § 10 | contradiction: § 10 named sections of `examples/README.md` that the rewrite renamed or replaced |
| Value lists: next step, run source (`from`), coverage unit, population filter fields | § 3 | G26, G27, G29 |
| CLI table: `validate`, `evaluate`, and `doctor` rows; records table: assessment run and gate decision rows; a window over the runs of a plan is a reason to build the ref | § 5, § 6 | G26, G27, G29 |
| Questions D5 and D6, each with three options and a default | § 9 | G26, G27 |

### Counts

- All four gaps are closed here. G26 and G27 are closed under a default that the owner has not confirmed: D5 and D6 (§ 9).
- Five contradictions are resolved: four that the rewritten examples exposed (the citations of § 10, walks and scenarios, the check before a local run, a number without a unit), and the next step of a fail in an operational gate, found while closing G26.
- The examples and the specification do not show the shapes of this revision yet.

### Not changed

- **Shapes that no example uses** (README, below “Values not shown in the design”): `statements` with `meaning` and `serves`, a `presets` binding, `planted_defects`, `paired`, `aggregation` on a measurement, `executed_ids`, `value` on an exception, and `skip` in `ratchet.toml`. They are unchanged and untested. `window` and `population` have a shape now and no example yet.
- **A comparison of two windows** (§ 10, not changed). A window plan gives one value per window.
- **A default for a window length or for `min_samples`.** No answer supplies one. The format requires both to be declared, as it does for a load bound.
- **A scope item that is new in a run.** § 5 rule 3 covers a requirement that has no reference. It does not say what a gate returns for one new scenario under a requirement that has accepted values for the others, and no evidence from before the candidate can exist for a scenario that the candidate adds. No example adds a scenario, so this is left for the next round of examples.
