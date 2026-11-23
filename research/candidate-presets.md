# Candidate presets from survey 1

A list of first presets that the survey answers support. It is design input. It sets no priority by date, names no owner, and plans nothing.

- `surf E4` means `responses/surf.md`, question E4. `F8` is a finding in [synthesis.md](synthesis.md). `§ 3` is a section of [`docs/design.md`](../docs/design.md). `gap 2` is a gap in [consumer-input-ux-ui.md](consumer-input-ux-ui.md).
- Terms and field names are those of the design: measurement kind, scope, conditions, coverage, generated reference, accepted value, identity set, exception, trade-off.

## 1. Method

- Source: E4 of all 26 answers ("one enforced rule you would add tomorrow"), plus B1 to B6 and E1 where they show the same rule already in use.
- A candidate is one measurement with one kind of comparison. Rules that ask for the same measurement share a candidate. A rule with two measurements is split over two candidates.
- **Serves** is the number of E4 rules a candidate covers, in full or in part. Five rules count for two candidates each (codespec, cortex, ess, connectors, spindle), so the column sums to 29 for 24 rules.
- **In use** is the number of answers whose B1 to B6 describe a tool in the repository that checks the same measurement today, blocking or reporting. A check done by hand is named and not counted, unless the line says otherwise.
- Every YAML block is a proposal. It shows the assessment and the requirement a preset would expand to, in the fields of § 3. The design shows no syntax for binding a preset or declaring its inputs (section 6, item 1).
- Assessor ids `command-timing@1` and `ux-eval@1` come from § 3 and the consumer input. Every other assessor id is a placeholder. Scopes, operators and reference kinds that the design does not show are placeholders too, and section 6 lists them.
- The ids `ext-03` and `ext-06` describe one repository (synthesis § 1). Counts below are counts of answers.

## 2. Overview

| Candidate | Family (§ 4 row) | Kind | Scope | Comparison |
| --- | --- | --- | --- | --- |
| `test-step-time@1` | Development | sampled | test step | absolute limit, optional accepted value |
| `test-time@1` | Development | sampled | test | absolute limit, optional accepted value |
| `test-step-cost@1` | Development | exact and sampled outputs | test step | accepted value |
| `test-skips@1` | Development (not listed in the row) | exact | run | accepted value |
| `conformance-cases@1` | Backend | exact | case | identity set |
| `scenario-pass-rate@1` | Backend | sampled | run, aggregated per scenario | accepted value |
| `operation-cost@1` | Backend | exact | operation or scenario | accepted value |
| `operation-time@1` | Backend | sampled | operation | accepted value or paired run |
| `web-ux@1` | Web | exact | scenario, page | accepted value, absolute limit, identity set |
| `generated-file@1` | Consistency | exact | file | generated reference |
| `references-resolve@1` | Consistency (not listed in the row) | exact | document | absolute limit 0 |
| `review-findings@1` | Review | exact | revision | identity set |
| `public-surface@1` | no row | exact | release | identity set |
| `secret-scan@1` | no row; nearest is Code quality | exact | run or revision | identity set, absolute limit 0 |
| `tool-pin-freshness@1` | no row | exact | tool | absolute limit |

## 3. Candidates

### 3.1 `test-step-time@1`

- **Measures:** wall time of one test step. Sampled, unit s, `boundary: run-time` with queue wait recorded apart (ext-08 E4: "run, not queue"; § 3). Scope is the step. § 3's example writes `scope: run`.
- **Comparison:** an absolute limit, and optionally an accepted value with a tolerance. All 7 step rules name 120 s. 5 add a comparison: +10 % over the previous `main` run (cortex E4), `main`'s last green value (ess E4), the last green `main` run +10 % in a committed file (runbook E4), +20 % over the median of the last 10 runs (ext-02 E4), "a baseline file that only lowers" (ext-08 E4). codespec and inference use the fixed number only.
- **Inputs:** the step's command or report path; the limit, default 120 s (E4 of codespec, cortex, ess, inference, runbook, ext-02, ext-08; written in 21 answers, F8); the tolerance, no default (10 %, 10 % and 20 % in three rules); conditions; runs and aggregation.
- **Assessor:** `command-timing@1` runs the step, or an import of the nextest JUnit report (ess B2, cortex B7) or the Playwright reporter (runbook B2). Queue wait comes from the build pool where it is logged: `jobs.jsonl` (slot B2), a printed `waited ... ran ...` line (swell B2).
- **Evidence:** serves 7 (the E4 rules above). In use 12: canon, inbox, llm, loom, runbook, substrate, surf, swell, ext-05 (all B2), ext-02 B5, cortex B2 in `report` mode, slot B2 for its UI steps only.
- **Open questions:** Does the step include building the test binaries? loom B2 and runbook B2 leave the build out; the other answers do not say. Which host load qualifies? One answer waits for a load under 90 on its host (surf C3); I don't know a common bound. cortex, runbook and ext-02 ask for a reference that moves with each `main` run; § 5 and § 8 keep the reference fixed between adoptions. runbook E4 asks for the check "locally and in CI", and 9 answers get a different result for the same tree in the two places (F10).

```yaml
assessments:
  test-step-time:
    assessor: command-timing@1
    target: {kind: revision, environment: ci}
    observation: {kind: controlled-run, command: task test, runs: 3, conditions: {runner: ci-standard, host_load_per_cpu: {max: 1.0}}}
    measurement: {kind: sampled, output: duration, boundary: run-time, also_record: [queue-wait], scope: step, aggregation: median, unit: s}
requirements:
  test-step-budget:
    assessment: test-step-time
    condition: {operator: lte, value: 120, unit: s}
    reference: {kind: accepted-value, tolerance: {percent: 10}}
```

### 3.2 `test-time@1`

- **Measures:** wall time of each test. Sampled, scope test, unit s.
- **Comparison:** an absolute limit of 60 s (E4 of codespec, cortex, ess, substrate). substrate E4 adds "more than 2x its committed value" of the last release, "on the reference runner". ess E4 adds `main`'s last green value.
- **Inputs:** the report path; the limit, default 60 s (the 4 rules above; written in 19 answers, F8); the tolerance against the accepted value, no default (one rule: 2x); the runner that qualifies.
- **Assessor:** an import of the nextest JUnit report (ess B2, cortex B7) or of Playwright results (runbook B2, slot B5).
- **Evidence:** serves 4. In use 14: a runner kills a test at 60 s in canon, connectors, cortex, inbox, inference, llm, loom, runbook, substrate, surf, swell, ext-02, and slot for Playwright tests (all B2); ess B2 reports the test and does not kill it.
- **Open questions:** In the 13 answers with a kill, the timeout and the limit are one number, and the runner records a failed test with no conditions. § 3 would make a kill under host load insufficient evidence; "2 of 21 store tests killed at 60 s under host load 74" (connectors C2). A new test has no accepted value. § 5 rule 3 then returns insufficient evidence; I don't know how a change that adds a test would pass.

```yaml
assessments:
  test-time:
    assessor: junit-report@1
    observation: {kind: controlled-run, report: target/nextest/junit.xml, conditions: {runner: ci-standard}}
    measurement: {kind: sampled, output: duration, scope: test, unit: s}
requirements:
  test-budget:
    assessment: test-time
    condition: {operator: lte, value: 60, unit: s}
```

### 3.3 `test-step-cost@1`

- **Measures:** the work a test step does, in outputs that move less with host load than wall time. Instructions, as a median of three runs (surf E4). Summed case time and CPU time (inbox E4). Process starts (loom B2, inbox C1). Scope is the step.
- **Kind:** instructions and process starts are exact. Summed case time and CPU time are sampled: "CPU seconds moved 60 % with host load, instructions under 2 %" (surf C3).
- **Comparison:** the accepted value on `main`. A rise over 5 % fails (surf E4); over 10 % fails (inbox E4). A drop over 5 % must be recorded before the next release (surf E4).
- **Inputs:** the step's command; the outputs to collect; a tolerance per output, no default; conditions (toolchain, CPU; § 3).
- **Assessor:** a wrap of `perf stat` in user mode (surf B2, E4). inbox runs its cases under nextest and names no tool for the sum (inbox B2). loom checks its bounds with its own task (loom B2).
- **Evidence:** serves 2 (surf, inbox). In use 1: loom B2 blocks on 66 binary starts and 60 s of summed test time for one test group. By hand: a written limit of 122 G instructions (surf B5).
- **Open questions:** I don't know how far summed case time moves with load; inbox C1 gives one figure. surf accepts a late write-back until the next release; § 5 rule 4 fails the gate at once for an exact measurement.

```yaml
assessments:
  test-step-instructions:
    assessor: perf-stat@1
    observation: {kind: controlled-run, command: task test, runs: 3, conditions: {toolchain: pinned}}
    measurement: {kind: exact, output: instructions, scope: step, aggregation: median, unit: instructions}
requirements:
  test-step-instructions-hold:
    assessment: test-step-instructions
    reference: {kind: accepted-value, tolerance: {percent: 5}}
```

### 3.4 `test-skips@1`

- **Measures:** the count of tests skipped for a missing prerequisite in the test step. Exact, scope run. The value was 96 in one CI run (loom E4).
- **Comparison:** not above the accepted value on `main` (loom E4).
- **Inputs:** the report path; which skip reasons count.
- **Assessor:** an import of the test runner's report. loom names its own task (`loom-xtask test-step`, E4). No answer names a general tool for the skip reason.
- **Evidence:** serves 1 (loom E4, D3). In use 6, as a limit on a skipped, ignored or unsupported count: spindle B5 (`skipped = 0`), swell B5 (`ESS_UNSUPPORTED_MAX=44`), ext-02 B5, ext-05 B5, ext-07 B5, ext-04 C3 ("ignored tests may not rise").
- **Open questions:** § 3 offers two forms: a `coverage` bound in the plan, or a coverage count as a measurement with an accepted value. I don't know which one a preset should use. A count does not say which tests (swell D3); an identity set of skipped ids would.

```yaml
assessments:
  test-skips:
    assessor: junit-report@1
    observation: {kind: snapshot, report: target/nextest/junit.xml}
    measurement: {kind: exact, output: skipped, scope: run, unit: tests}
requirements:
  skips-do-not-rise:
    assessment: test-skips
    reference: {kind: accepted-value}
```

### 3.5 `conformance-cases@1`

- **Measures:** the result of each case of a conformance or contract suite. Exact, an identity set keyed by case id, scope case.
- **Comparison:** no case in the accepted set fails or stops running (§ 4). "No run that passed in the last accepted full run fails" (swell E4). The executed scenarios are never fewer than the committed list on `main` (spindle E4). A change to a pinned answer fails the merge (ext-01 E4).
- **Inputs:** the report path; the identity key; the coverage that qualifies (`skipped`, `unsupported`).
- **Assessor:** an import of an ESS conformance report (§ 4; spindle B4) or of a test262 run file (swell B6). ext-01 names a consumer-driven contract test and no tool (ext-01 E2).
- **Evidence:** serves 3 (swell, spindle, and ext-01 in part). In use 8. By identity, 2: an exact list of executed scenario ids (spindle B5), zero new failures outside an accepted list (ext-07 B5). By count, 7: cortex B6, substrate B5, surf B6, swell B4, ext-02 B5, ext-05 B6, ext-07 B5. By hand: run lines compared with a file kept in scratch (swell B6).
- **Open questions:** For ext-01, the answers the consumer branches on "live only in the consumer's code" (ext-01 D2), so the preset covers only the cases someone has pinned. swell's full run takes about 600 s (swell B6). When the specification changes the suite, the count "only exists after the suite is synthesized" (ext-02 C1); I don't know whether the reference is then a generated reference or an accepted value.

```yaml
assessments:
  conformance-cases:
    assessor: ess-conformance-report@1
    observation: {kind: snapshot, report: conformance/report.json, coverage: {skipped: 0, unsupported: 0}}
    measurement: {kind: exact, output: passing_cases, scope: case, identity: [case_id]}
requirements:
  no-case-lost:
    assessment: conformance-cases
    condition: {operator: no-lost-items}
    reference: {kind: accepted-value}
```

### 3.6 `scenario-pass-rate@1`

- **Measures:** per end-to-end scenario, the pass rate over the last 10 runs on the default branch (ext-07 E4). Sampled; § 3 names "the pass rate of a subject that answers differently per run". Scope run, aggregated per scenario.
- **Comparison:** not lower than the accepted value of that scenario. Checked on a daily scheduled run; a drop blocks the next release (ext-07 E4).
- **Inputs:** the scenario set; the window, 10 runs in the one rule; the accepted value per scenario; a tolerance, no default.
- **Assessor:** an import of the per-run result archives (ext-07 B7). The answer names no tool.
- **Evidence:** serves 1 (ext-07 E4, D3, E2). In use 0. The nearest practice is 3 runs per cell with a registered verdict rule, outside any gate (runbook B4).
- **Open questions:** What tolerance fits 10 runs? "One red run in ten says little, and one green run says little too" (ext-07 D3). The runs call a paid model under a daily spend limit (ext-07 B5), so the window has a cost. § 3 defines a window by interval and population, not by a count of runs.

```yaml
assessments:
  scenario-pass-rate:
    assessor: e2e-run-archive@1
    observation: {kind: time-window, runs: 10}
    measurement: {kind: sampled, output: passed, scope: scenario, aggregation: pass-rate, unit: ratio}
requirements:
  pass-rate-holds:
    assessment: scenario-pass-rate
    condition: {operator: gte-reference}
    reference: {kind: accepted-value}
```

### 3.7 `operation-cost@1`

- **Measures:** the work of one product operation on a fixed input. Exact. Units: bytes, counts (decodes, serialisations, opens, allocations), instructions, syscalls. Scope is the operation (entity-runtime E4) or a frozen scenario (ext-04 E4).
- **Comparison:** an accepted value. The rules name three references: the merge base (entity-runtime E4), the value committed for `main` (connectors E4), the last release plus a band (ext-04 E4).
- **Inputs:** the scenario or fixture list; the counters; a tolerance per key; the toolchain and loader as conditions (ext-04 E4). Tolerances in use: 0 on bytes (connectors E4); 0, or 0.005 plus a slack of 256, per counter (entity-runtime B5); a band from 0.1 % to 10 % with up to 3 re-measurements (ext-04 B5). No common default.
- **Assessor:** callgrind, strace and valgrind memcheck (ext-04 B4); the project's own counter tool (entity-runtime B4). connectors measures with scratch scripts (connectors B4).
- **Evidence:** serves 3 (entity-runtime, ext-04, and the bytes of connectors). In use 4: 55 counters, job not required (entity-runtime B4, B5); blocks the merge (ext-04 B5); one behaviour bound in a test (connectors B5); step totals in tests (swell B6).
- **Open questions:** "A distro update can refuse a merge that changed no code" (ext-04 D2); § 3 makes that a new evidence series, and the rule asks for a pin. A counter catches only what it counts: the path of one regression had no counter (entity-runtime C1). The merge base is not the trusted copy of § 5 rule 1; I don't know whether the two differ in practice.

```yaml
assessments:
  read-path-cost:
    assessor: callgrind@1
    observation: {kind: controlled-run, scenario: scenarios/read.yaml, conditions: {toolchain: pinned, loader: pinned}}
    measurement: {kind: exact, output: instructions, scope: scenario, unit: instructions}
requirements:
  read-path-cost-holds:
    assessment: read-path-cost
    reference: {kind: accepted-value, tolerance: {percent: 0.1}}
```

### 3.8 `operation-time@1`

- **Measures:** wall time of one product operation on a fixed fixture, as a median (connectors E4: "median wall ms per read invoke"). Sampled, unit ms, scope operation.
- **Comparison:** not worse than the value committed for `main`, tolerance 10 % (connectors E4). The two answers that run such a check use a paired run and no stored value (§ 3).
- **Inputs:** the fixture; runs and aggregation; the tolerance; the runner that qualifies.
- **Assessor:** a paired-run wrap of the project's benchmark command. In use: base and head built and run interleaved on one runner, 3 rounds, best round per side (entity-runtime B6); rows against the last release tag on a dedicated host, interleaved (ext-04 B6).
- **Evidence:** serves 1 (the ms part of connectors E4). In use 3: entity-runtime B5 with `continue-on-error`, ext-04 B6 per release, a latency limit in ms per run (ext-02 B5).
- **Open questions:** I don't know whether 10 % holds on a shared runner. One answer's limit is 2.0x because an unchanged build moved up to 1.94x, and that limit "misses a 1.68x regression" (entity-runtime C2, C3). A stored value needs the conditions of § 5 rule 5; a paired run does not.

```yaml
assessments:
  read-invoke-time:
    assessor: paired-run@1
    observation: {kind: controlled-run, command: task bench:read, runs: 3, conditions: {runner: dedicated}}
    measurement: {kind: sampled, output: duration, scope: operation, aggregation: median, unit: ms}
requirements:
  read-invoke-time-holds:
    assessment: read-invoke-time
    reference: {kind: paired-run, tolerance: {percent: 10}}
```

### 3.9 `web-ux@1`

- **Status:** the first consumer offers this id as a preset family, with a draft planned in its own repository (consumer input, Offer). I don't know which presets the family will hold.
- **Measures:** exact values per scenario and key from a UI loop: actions per task, sideways scroll, serious and critical accessibility violations, layout shift, keyboard steps, reading load (slot B5, spindle B4, ux-ui B5). Page-level results keep the page as scope (gap 2).
- **Comparison:** an accepted value per scenario and key, lower is better (F6). Absolute limits on some keys: 0 serious or critical axe violations (inference B5, llm B5, slot B5, ux-ui B5), at most 2 actions per task (slot B5; ux-ui B5 has "every fix <= 2 actions"). Findings as an identity set of rule id, node path and environment (gap 4). A trade-off for a change that makes some keys worse on purpose (gap 1; § 5).
- **Inputs:** scenarios; viewports and themes; a tolerance per key. Defaults with support: 0 for counts (agentplugins, runbook, slot, spindle, ux-ui, ext-04, all B5; ext-02 B6) and 0.01 for layout shift (agentplugins, runbook, slot, spindle, ux-ui, all B5).
- **Assessor:** `ux-eval@1` evaluates an `ess-ui/1` document with no I/O (consumer input). The loops in use run Playwright (codespec B4, runbook B4, slot B5, spindle B4, ux-ui B4, ext-04 B4) and axe-core (agentplugins B4, llm B4, runbook B4, slot B4, spindle B4, ux-ui B4, ext-08 B4). I don't know whether `ux-eval@1` can import their results.
- **Evidence:** serves 1 (the "each UX ratchet metric" part of spindle E4). In use 12 (F6): agentplugins, codespec, inference, llm, runbook, slot, spindle, substrate, ux-ui, ext-02, ext-04, ext-08 (B4 or B6). 3 of the 12 run it only by hand or only locally (spindle B4, runbook B4, ext-08 B4).
- **Open questions:** Some keys vary by host: `reading_load.*` has a 10 % band "because fonts differ between hosts" (slot B5), and `keyboard.tabs` has a 30 % band (spindle B5). I don't know whether they are exact with a font condition or sampled. A value moved when a new content page shifted a list (ext-02 C2); § 8 does not design for it.

```yaml
assessments:
  docs-ux:
    assessor: ux-eval@1
    target: {kind: revision, environment: [local, ci]}
    observation: {kind: snapshot, scenario: ess-ui:docs/find-command, coverage: {skipped: 0, unsupported: 0}}
    measurement: {kind: exact, output: actions_per_task, scope: journey, unit: actions}
requirements:
  actions-do-not-rise:
    assessment: docs-ux
    reference: {kind: accepted-value}
```

### 3.10 `generated-file@1`

- **Measures:** whether committed files equal a fresh run of their generator. Exact, bytes or a digest, scope file.
- **Comparison:** a generated reference, tolerance 0; the candidate may rewrite it in the same change (§ 5). canon E4 asks for this on every fixture's output of six commands: "any difference fails unless the same commit updates the baseline".
- **Inputs:** the generator command; the paths; the pinned generator version as a condition.
- **Assessor:** runs the project's generator in its check mode, as the answers do (`--check` in slot B6 and spindle B1; `task drift` in cortex B1).
- **Evidence:** serves 1 (canon E4). In use 21 (F5): canon, codespec, connectors, cortex, entity-runtime, ess, inbox, llm, loom, runbook, slot, spindle, substrate, surf, swell, ext-02, ext-04, ext-05, ext-07, ext-08 (all B1), inference B6. For the fixture outputs of canon E4 the comparison is done by agents today, "not by a committed check" (canon B4).
- **Open questions:** A tool newer than the pinned one changes the output: 47 tests fail (canon C2), and a local run reports "schema drift" (llm C2). § 3 makes that insufficient evidence. Several answers compare a digest of the sources as a fast check and regenerate fully in a slow lane (runbook B6, connectors B6, swell B6); I don't know whether one preset covers both. A merge can leave a file stale without a conflict (runbook C1).

```yaml
assessments:
  generated-docs:
    assessor: generator-check@1
    observation: {kind: snapshot, command: task generate, conditions: {toolchain: pinned}}
    measurement: {kind: exact, output: digest, scope: file}
requirements:
  generated-docs-current:
    assessment: generated-docs
    condition: {operator: equals-reference}
    reference: {kind: generated-reference}
```

### 3.11 `references-resolve@1`

- **Measures:** the count of references in documents that do not resolve. Exact. ext-05 E4: every backend line citation resolves at its named commit, and "the cited lines hold the named item".
- **Comparison:** an absolute limit of 0, on every merge request (ext-05 E4).
- **Inputs:** the documents; the reference pattern; where the cited repository can be read.
- **Assessor:** a resolver that reads each citation at its commit. The answer names "one-off resolver runs in review" and no tool (ext-05 D2).
- **Evidence:** serves 1 (ext-05 E4; over 150 citations were wrong for weeks, ext-05 C1). In use 4, in a weaker form that checks only that the named thing exists: a citation names a commit (ext-05 B1); a status item or requirement names an existing test (entity-runtime B1, spindle B1, swell B4).
- **Open questions:** The check needs the cited repository at each cited commit; I don't know how a gate gets it. Whether "the cited lines hold the named item" is exact is not shown by any answer. § 4's Consistency row names generated files and numbers in documents, and no references.

```yaml
assessments:
  spec-citations:
    assessor: citation-resolver@1
    observation: {kind: snapshot, paths: [spec/]}
    measurement: {kind: exact, output: unresolved, scope: document, unit: citations}
requirements:
  citations-resolve:
    assessment: spec-citations
    condition: {operator: lte, value: 0, unit: citations}
```

### 3.12 `review-findings@1`

- **Measures:** the findings of a review as an identity set tied to the revision judged (§ 4). ux-ui E4 adds: every closed S1/S2 finding "names a regression test that failed before its fix and passes after".
- **Comparison:** no open finding above a declared severity (§ 4); no closed finding without a named test. Checked in the local gate on every change (ux-ui E4).
- **Inputs:** the review records; the severity that blocks; where the tests live.
- **Assessor:** the review assessor of § 4, importing review records. No answer names a tool.
- **Evidence:** serves 1 (ux-ui E4). In use 2: regression assertions for 37 closed UI findings (slot B4); a fixed UI finding re-checked as a test (ext-08 B4). 11 answers report a regression found by a review after the gates had passed (F13).
- **Open questions:** "Failed before its fix" needs the test run at the revision before the fix; I don't know whether `ratchet prove` (§ 4) is meant to do that. Review results today are text records and are "not machine-checked against the head that merged" (runbook D3, inferred there).

```yaml
assessments:
  review-findings:
    assessor: review-record@1
    observation: {kind: snapshot, records: reviews/}
    measurement: {kind: exact, output: closed_findings_without_test, scope: revision, identity: [finding_id]}
requirements:
  closed-findings-have-tests:
    assessment: review-findings
    condition: {operator: lte, value: 0}
```

### 3.13 `public-surface@1`

- **Measures:** the set of public API items of each crate. Exact, an identity set (llm E4).
- **Comparison:** against the last release tag. A removed or changed item fails the pull request unless the unreleased changelog section has a Breaking line (llm E4).
- **Inputs:** the packages; the tag pattern; the changelog path.
- **Assessor:** llm names no tool. In use are project-own checks: a specification diff against the newest release tag with `--fail-on breaking-or-unknown` (cortex B1), a `release-check` against the previous tag (loom B3), a committed scan of every public item (swell B4).
- **Evidence:** serves 1 (llm E4). In use 4: cortex B1, loom B3, swell B4, ext-05 B6 (a specification diff against `main`). 11 answers say a release must not break a consumer without saying so (F17).
- **Open questions:** The acceptance ends at an event, not a date: acknowledgements are "reset after a release" (cortex B6), and 37 had accumulated (cortex C3). § 5 gives an exception an expiry date (section 6, item 5). § 4 has no row for this family.

```yaml
assessments:
  public-surface:
    assessor: api-surface@1
    observation: {kind: snapshot, packages: all}
    measurement: {kind: exact, output: public_items, scope: release, identity: [crate, item_path, signature]}
requirements:
  no-unannounced-break:
    assessment: public-surface
    condition: {operator: no-lost-items}
    reference: {kind: accepted-value, revision: last-release-tag}
```

### 3.14 `secret-scan@1`

- **Measures:** findings of a scan for credential shapes. Exact, an identity set. ext-03 E4 scans every run's records; the scans in use read a repository's commits.
- **Comparison:** an absolute limit of 0 findings, with reviewed entries as exceptions. Checked at run end and in CI on fixtures (ext-03 E4).
- **Inputs:** the paths or run directory; the rule set; the exceptions.
- **Assessor:** ext-03 names no scanner. 4 answers name a secret or credential scan of the repository (cortex B1, inbox B1, substrate B1, ext-08 B1). 7 more name a required job "Security and privacy" (agentplugins, canon, codespec, entity-runtime, llm, slot, spindle, all B1); two of them could not read what it checks (slot B1, spindle B1).
- **Evidence:** serves 1 (ext-03 E4, in part: no answer scans run records today; ext-03 E2 lists it as "with work"). In use 4 on repositories. Scan allowlists exist in 2: one entry scoped by rule and path (substrate C3), and 27 lines, each with a written reason (ext-08 C3).
- **Open questions:** "At run end" is not a gate stage of § 1 (section 6, item 7). The scan input grows: one scan failed at 512.3 MiB against a 512 MiB limit (cortex C1). An allowlist of 27 lines was "never observed tightened" (ext-08 C3); § 5 would give each entry an expiry.

```yaml
assessments:
  run-record-scan:
    assessor: credential-scan@1
    target: {kind: workflow-run}
    observation: {kind: snapshot, paths: [runs/current/]}
    measurement: {kind: exact, output: findings, scope: run, identity: [rule, path]}
requirements:
  no-credential-in-records:
    assessment: run-record-scan
    condition: {operator: lte, value: 0}
```

### 3.15 `tool-pin-freshness@1`

- **Measures:** for each tool, the version recorded as verified against its newest release (agentplugins E4). Exact, scope tool.
- **Comparison:** equal, or the newer release is at most 1 day old. A required check on every pull request and before the tag (agentplugins E4).
- **Inputs:** the file of verified versions; the tools; the allowed age.
- **Assessor:** a read of each tool's release list on the forge. In use: a CI job compares `verified.json` with the newest releases (agentplugins B4, B6).
- **Evidence:** serves 1 (agentplugins E4). In use 1, not required and red on `main` on the answer day (agentplugins B4, C1).
- **Open questions:** The result changes when another project releases, with no change in the candidate. § 3 asks that a candidate-specific verdict rest on evidence attributable to the candidate (section 6, item 6). § 4 has no row for it.

```yaml
assessments:
  tool-pins:
    assessor: release-list@1
    observation: {kind: snapshot, file: verified.json}
    measurement: {kind: exact, output: unverified_release_age, scope: tool, aggregation: max, unit: d}
requirements:
  pins-are-current:
    assessment: tool-pins
    condition: {operator: lte, value: 1, unit: d}
```

## 4. Coverage of the 26 rules

| Id (E4) | What the rule measures | Candidate | Note |
| --- | --- | --- | --- |
| agentplugins | Verified CLI versions against the newest releases | `tool-pin-freshness@1` | Section 6, item 6 |
| canon | Every fixture output against a committed file, by bytes | `generated-file@1` | |
| codespec | Wall time per CI part and per test, 120 s and 60 s | `test-step-time@1`, `test-time@1` | Fixed numbers only |
| connectors | Bytes appended and median ms per read invoke | `operation-cost@1`, `operation-time@1` | |
| cortex | Wall time of the step and of each test, and +10 % over the previous `main` run | `test-step-time@1`, `test-time@1` | Reference fixed between adoptions (§ 5) |
| entity-runtime | Work counters per operation against the merge base | `operation-cost@1` | "Named exception" is the exception of § 5 |
| ess | Wall time of the step and of each test, and `main`'s last green value | `test-step-time@1`, `test-time@1` | |
| ext-01 | Answers the main consumer branches on, pinned by contract tests | `conformance-cases@1` | In part: nothing lists the answers (ext-01 D2) |
| ext-02 | Step wall time per CI job, median of the last 10 runs +20 %, 120 s | `test-step-time@1` | The series supplies the adoption (§ 5) |
| ext-03 | Credential shapes in every run's records | `secret-scan@1` | In part: "at run end" is not a gate stage |
| ext-04 | Instructions and syscalls per frozen scenario against the last release | `operation-cost@1` | |
| ext-05 | Every line citation resolves at its commit | `references-resolve@1` | |
| ext-06 | A run with a step ended by its time limit closes as "error" | not covered | A rule about the outcome of the respondent's own runs. § 3 and § 5 apply the same rule to Ratchet's verdicts. Its first half, queue wait and run time recorded per step, is what § 3 records. |
| ext-07 | Pass rate per scenario over the last 10 runs | `scenario-pass-rate@1` | |
| ext-08 | Run time of the full test step, 120 s, a baseline that only lowers | `test-step-time@1` | |
| inbox | Summed case time and CPU time of the test step, +10 % | `test-step-cost@1` | Both outputs are sampled |
| inference | Seconds of the CI test step, 120 | `test-step-time@1` | Fixed number only |
| llm | Public API of every crate against the last release tag | `public-surface@1` | Section 6, item 5 |
| loom | Count of tests skipped for a missing prerequisite | `test-skips@1` | |
| runbook | Step wall time, last green `main` run +10 %, 120 s | `test-step-time@1` | "A numbered decision" is an exception or a policy change (§ 5) |
| slot | Queue-wait p90 and CPUs per slot, 60 min after an install against 60 min before | not covered | Section 6, item 4 |
| spindle | Executed conformance scenarios and each UX metric | `conformance-cases@1`, `web-ux@1` | |
| substrate | Wall time per test, 60 s or 2x the committed value | `test-time@1` | |
| surf | Instructions of each test step, median of three, 5 % | `test-step-cost@1` | |
| swell | No run line that passed in the last accepted run fails | `conformance-cases@1` | |
| ux-ui | Every closed finding names a regression test | `review-findings@1` | |

24 of 26 rules have a candidate. 2 of the 24 are covered in part (ext-01, ext-03). 2 have none (ext-06, slot).

## 5. Ranking by evidence

This orders the candidates by evidence in the survey. It is not a plan. Order: rules served, then answers with a version in use. Counting is as in section 1.

| Candidate | Serves | Ids (E4) | In use | Of which not blocking or partial |
| --- | --- | --- | --- | --- |
| `test-step-time@1` | 7 | codespec, cortex, ess, inference, runbook, ext-02, ext-08 | 12 | cortex (report mode), slot (UI steps only) |
| `test-time@1` | 4 | codespec, cortex, ess, substrate | 14 | ess (reported, not killed) |
| `conformance-cases@1` | 3 | swell, spindle, ext-01 | 8 | 7 compare a count, 2 an identity set; ext-07 does both |
| `operation-cost@1` | 3 | entity-runtime, ext-04, connectors | 4 | entity-runtime (job not required) |
| `test-step-cost@1` | 2 | surf, inbox | 1 | surf checks by hand and is not counted |
| `generated-file@1` | 1 | canon | 21 | |
| `web-ux@1` | 1 | spindle | 12 | spindle, runbook, ext-08 (by hand or local only) |
| `test-skips@1` | 1 | loom | 6 | |
| `public-surface@1` | 1 | llm | 4 | |
| `references-resolve@1` | 1 | ext-05 | 4 | all 4 check existence only |
| `secret-scan@1` | 1 | ext-03 | 4 | all 4 scan a repository, none run records |
| `operation-time@1` | 1 | connectors | 3 | entity-runtime (`continue-on-error`) |
| `review-findings@1` | 1 | ux-ui | 2 | |
| `tool-pin-freshness@1` | 1 | agentplugins | 1 | not required |
| `scenario-pass-rate@1` | 1 | ext-07 | 0 | |

- The four Development candidates serve 11 distinct rules: the 7 and 4 above share codespec, cortex and ess, plus surf, inbox and loom.
- The two orders disagree. `generated-file@1` and `web-ux@1` are the practices most in use (21 and 12 answers) and each is asked for by one rule. E4 asks for a rule to add, so a check already in place is seldom the answer.
- 18 of 25 projects share one organization's rules (synthesis § 5). The 120 s and 60 s limits, the UI loop and the "Security and privacy" job are shared conventions, so their counts are not independent choices.

## 6. What the design cannot express yet

1. **Preset binding and inputs.** § 2 and § 4 say a preset declares inputs and defaults and that a project binds it. The YAML of § 3 shows neither a preset reference nor an input. Every snippet above is therefore an expansion, not a preset.
2. **Scopes.** § 1 and § 3 list state, journey, page, test, variant and run. The rules also need a test step or CI part (codespec, runbook, ext-02 E4), an operation (entity-runtime E4), a scenario (ext-04, ext-07 E4) and a case (swell E4). § 3 says "per scenario" in prose for ext-07. I don't know whether the list is closed.
3. **Operators, and a limit with an accepted value.** § 3 shows `lt`, `lte` and `no-new-items`. The candidates also need byte equality with a generated reference, "no accepted item fails or stops running" (§ 4, in prose), and "not lower than the reference". The snippets write these as `equals-reference`, `no-lost-items` and `gte-reference`. § 3's `test-step-budget` holds an absolute limit and an accepted value in one requirement and does not say how the second comparison is written or which direction is worse. 5 of the 7 step rules need both.
4. **A comparison of two windows.** slot E4 compares 60 minutes after an install with 60 minutes before. § 3 has a time window. § 5 has stored references, and the paired run of § 3 is interleaved. A before and after pair is neither. § 8 says the window design is untested by this survey.
5. **An acceptance that ends at an event.** A breaking change named in the changelog is accepted until the next release (llm E4, cortex B6). An exception in § 5 ends at a date, and a trade-off needs a named gain. Neither fits.
6. **A check about the world outside the candidate.** agentplugins E4 fails a pull request when another project has released. § 3 ties a candidate-specific verdict to evidence attributable to the candidate. § 3 allows an operational gate on evidence that is not attributable to one candidate. The rule asks for a merge gate.
7. **A gate at the end of a product run.** ext-03 and ext-06 check "at run end" and "when the run closes". § 1 defines a gate at a workflow stage "such as merge or promotion".
8. **Preset table rows.** § 4 has no row for the compatibility of a published surface between releases (llm E4; F17: 11 answers), for secret scans (ext-03 E4), for references that resolve (ext-05 E4), or for coverage counts as measurements (loom E4; § 3 describes them).
9. **A reference kind for a paired run.** § 3 describes the paired run as a comparison. The `reference` field of § 3 shows only `accepted-value`; `paired-run` and `generated-reference` in the snippets are placeholders.

## 7. Limits

- The counts are this document's reading of free text. "In use" rests on what an answer says about its repository; nothing was checked against a repository.
- inference states only what differs from llm (synthesis § 5), so it is counted only where its own file names the check.
- Six answers are read-only passes that ran no gate (synthesis § 1). Their B sections describe files, not runs.
- The defaults named here (120 s, 60 s, tolerance 0 for counts, 0.01 for layout shift) come mostly from one organization's shared rules.
- Not known from the answers: a host load bound that qualifies a timing run; a tolerance for a pass rate over 10 runs; a tool for a Rust public API diff; a scanner for run records; whether `ux-eval@1` can import the Playwright loops in use.
