---
format: aep.planning-md/3
id: review-result:critics-scope-wave-ahead-2-round-2
kind: review-result
status: active
title: scope critic on the 33 stories of wave ahead 2, round 2
relations:
- reviews: story:readme-design-citations-by-place
- reviews: story:coverage-count-lower-bound
- reviews: story:import-source-tree-file
- reviews: story:result-with-two-dimensions
- reviews: story:assessor-learns-observation
- reviews: story:window-over-outside-population
- reviews: story:build-target-invocation
- reviews: story:imported-report-revision-check
- reviews: story:prove-command
- reviews: story:condition-on-digest-value
- reviews: story:requirement-states-a-range
- reviews: story:requirement-over-two-measurements
- reviews: story:severity-limit-on-identity-set
- reviews: story:number-states-its-source
- reviews: story:coverage-count-with-reference
- reviews: story:coverage-bound-on-failed-units
- reviews: story:assertion-required-items
- reviews: story:list-item-statement
- reviews: story:min-samples-per-scope-item
- reviews: story:machine-as-a-condition
- reviews: story:plan-conditions-from-binding
- reviews: story:member-for-some-input-values
- reviews: story:input-allowed-values
- reviews: story:plan-declares-what-its-command-needs
- reviews: story:plan-never-assessed
- reviews: story:new-item-without-accepted-value
- reviews: story:reference-from-another-plan
- reviews: story:records-tracked-baseline-directory
- reviews: story:gate-entry-unless-only-paths
- reviews: story:gate-judges-commit-of-a-tag
- reviews: story:production-gate-kind
- reviews: story:gate-joins-revision-and-document
- reviews: story:example-release-quality
revision: 1
---
Scope critic, round 2, on the 33 stories of `.engineering/waves/0.1.0-ahead-2.md` at c5ff8d2.
Verdict: needs-revision.

All 14 findings of round 1 are answered: the refusal of a range with min above max, the members
of `spec/domains/cli.yaml` in the now-parts of units 11, 14, 18, 26 and 32, the scope lists, the
four rules that reached past their story, the design text of unit 12, and the example counts of
`spec/README.md`. The shared-file list, the order, the field-row and preset counts agree with the
bodies. `candidate_not_tagged` of unit 30 follows the original's refusal that names the gate.
Two new findings come from the revision.

Notes: `story:gate-judges-commit-of-a-tag` says the paragraph "Gate kinds" gives
`operational_gate_takes_no_candidate`, which `docs/design.md` does not name there;
`story:production-gate-kind-in-ratchet` item 1 cites a design sentence the now-part leaves open.

```findings
[{"file":".engineering/planning/story/coverage-count-with-reference.md","line":70,"category":"scope","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"item 3 decides insufficient evidence with coverage_below_plan for an unknown or lower-bound count, which the original did not ask, and coverage-count-lower-bound already writes that rule into the same section"},
 {"file":".engineering/waves/0.1.0-ahead-2.md","line":15,"category":"scope","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"the opening list of the files the 33 stories change omits spec/cli.yaml, which unit 30 changes for candidate_not_tagged"}]
```
