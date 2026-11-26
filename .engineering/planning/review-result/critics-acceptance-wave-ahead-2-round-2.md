---
format: aep.planning-md/3
id: review-result:critics-acceptance-wave-ahead-2-round-2
kind: review-result
status: active
title: acceptance critic on the 33 stories of wave ahead 2, round 2
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
Acceptance critic, round 2, on the 33 stories of `.engineering/waves/0.1.0-ahead-2.md` at c5ff8d2.
Verdict: needs-revision.

All 23 findings of round 1 are answered. The cites moved to names, the greps for `YAML 1.1
reader` and `design, line 658`, `want_examples`, the field-row chain 98, 99, 101, 103, 105, 112,
the preset counts and the last line of `spec/cli-coverage-row.test.sh` match the tree. One new
blocker: four greps for the field-row sentence of `spec/README.md` cannot match a wrapped line.

```findings
[{"file":".engineering/planning/story/coverage-count-lower-bound.md","line":110,"category":"acceptance","severity":"blocker","verdict":"needs-revision","origin":"introduced","message":"grep -F for the field-row sentence cannot match: spec/README.md:131-132 wraps after field, so the before form also finds 0; same in result-with-two-dimensions, assessor-learns-observation, imported-report-revision-check"},
 {"file":".engineering/waves/0.1.0-ahead-2.md","line":296,"category":"acceptance","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"unit 34 greps count the phrases anywhere in docs/design.md and do not show the paragraph stands in section 2; the move to rejected has no check"},
 {"file":".engineering/waves/0.1.0-ahead-2.md","line":253,"category":"acceptance","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"a grep -c of each changelog token does not tie it to its unit's line; cell, digest, conditions, needs, tracked, within can be met by another line"},
 {"file":".engineering/planning/story/severity-limit-on-identity-set.md","line":54,"category":"acceptance","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"grep -c no-critical-advisory prints 2 whatever the condition is; eq 0 and the absent reference are not observed"},
 {"file":".engineering/planning/story/coverage-count-lower-bound.md","line":100,"category":"acceptance","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"item 6 packs four independent outcomes"},
 {"file":".engineering/planning/story/machine-as-a-condition.md","line":85,"category":"acceptance","severity":"note","verdict":"needs-revision","origin":"introduced","message":"no grep shows the copy valid-inputs states build_profile: release"},
 {"file":".engineering/planning/story/requirement-over-two-measurements.md","line":89,"category":"acceptance","severity":"note","verdict":"needs-revision","origin":"introduced","message":"the count 4 for not defined(against) assumes four separate invariants, which the item does not state"},
 {"file":".engineering/planning/story/readme-design-citations-by-place.md","line":68,"category":"acceptance","severity":"note","verdict":"needs-revision","origin":"introduced","message":"item 3 greps only the heading, not the quoted phrase in the three README rows"},
 {"file":".engineering/planning/story/coverage-count-lower-bound.md","line":126,"category":"acceptance","severity":"note","verdict":"needs-revision","origin":"introduced","message":"phrase greps in folded YAML summaries do not say the phrase stands on one line"}]
```
