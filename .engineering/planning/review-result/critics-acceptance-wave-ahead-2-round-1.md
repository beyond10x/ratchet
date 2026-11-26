---
format: aep.planning-md/3
id: review-result:critics-acceptance-wave-ahead-2-round-1
kind: review-result
status: active
title: acceptance critic on the 33 stories of wave ahead 2, round 1
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
Acceptance critic, round 1, on the 33 stories of `.engineering/waves/0.1.0-ahead-2.md` at e6dd5e9.
Verdict: needs-revision.

Counts, row numbers and cites not named below match the tree (13 to 14 to 105 field rows, the
79 to 82 fields sentence, 98 to 112, `want_examples` 2 to 4 and 5 to 9, the last lines of
`spec/presets.test.sh`, `cli-coverage-row` 9 to 10).

Notes without a finding entry: unit 34 names no heading or phrase for its paragraph;
`AGENTS.md` says the closing story writes the lines of its wave under `## [Unreleased]` while
each story assigns one line per unit; whether the rule `assessor` of `spec/presets.test.sh`
exempts inputs named in `observation_inputs` (story 5) is open; whether
`spec/record-examples.test.sh` reads a § 12 example whose root holds `format` (story 9) is open.

```findings
[{"file":".engineering/planning/story/readme-design-citations-by-place.md","line":62,"category":"acceptance","severity":"blocker","verdict":"needs-revision","origin":"introduced","message":"the grep for a line number also matches spec/README.md:75 (YAML 1.1 reader), a line the story does not touch, so the check cannot pass"},
 {"file":".engineering/planning/story/readme-design-citations-by-place.md","line":57,"category":"acceptance","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"item 1 holds three outcomes and only the line-number one has a mechanical check"},
 {"file":".engineering/planning/story/readme-design-citations-by-place.md","line":65,"category":"acceptance","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"the item 2 grep misses the cite design, line 658 in spec/README.md:299"},
 {"file":".engineering/planning/story/coverage-count-lower-bound.md","line":98,"category":"acceptance","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"want_examples is cited at :46, a comment; the variable is at :57"},
 {"file":".engineering/planning/story/coverage-count-lower-bound.md","line":93,"category":"acceptance","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"record-fields and record-types print one combined total, not a split by section; the same sentence is in four more stories of group B"},
 {"file":".engineering/planning/story/assessor-learns-observation.md","line":101,"category":"acceptance","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"example 4 may show runs is not an outcome"},
 {"file":".engineering/planning/story/assessor-learns-observation.md","line":60,"category":"acceptance","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"three cites are off: target_input, samples and the section 9 bullet"},
 {"file":".engineering/planning/story/window-over-outside-population.md","line":40,"category":"acceptance","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"the section 9 bullet is at evidence-format.md:674, not :673"},
 {"file":".engineering/planning/story/build-target-invocation.md","line":41,"category":"acceptance","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"cites of the section 9 bullet and of target_input are off"},
 {"file":".engineering/planning/story/build-target-invocation.md","line":60,"category":"acceptance","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"item 2 is one text-only item over five places"},
 {"file":".engineering/planning/story/import-source-tree-file.md","line":45,"category":"acceptance","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"the evidence.target row revision is at evidence-format.md:86, not :85; imported-report-revision-check repeats it"},
 {"file":".engineering/planning/story/import-source-tree-file.md","line":56,"category":"acceptance","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"the invariant tree_file requires target.revision is checked only by a validate exit that is the same before and after"},
 {"file":".engineering/planning/story/requirement-states-a-range.md","line":58,"category":"acceptance","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"acceptance cites base lines of Condition that earlier units move; cite by name (also requirement-over-two-measurements, number-states-its-source)"},
 {"file":".engineering/planning/story/production-gate-kind.md","line":67,"category":"acceptance","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"acceptance cites base lines that earlier units change; same in list-item-statement, assertion-required-items, min-samples-per-scope-item, plan-never-assessed, gate-judges-commit-of-a-tag, gate-joins-revision-and-document"},
 {"file":".engineering/planning/story/min-samples-per-scope-item.md","line":71,"category":"acceptance","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"a comment in gate.yaml is checked only by validate, which cannot see it; no phrase is named"},
 {"file":".engineering/planning/story/new-item-without-accepted-value.md","line":62,"category":"acceptance","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"the list of items not judged on RequirementVerdict has no member name"},
 {"file":".engineering/planning/story/gate-judges-commit-of-a-tag.md","line":56,"category":"acceptance","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"what a candidate that is no such commit gets is not fixed, and two places are offered as alternatives"},
 {"file":".engineering/planning/story/gate-entry-unless-only-paths.md","line":56,"category":"acceptance","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"item 2 offers two places and item 3 names no string for the README cell"},
 {"file":".engineering/planning/story/gate-joins-revision-and-document.md","line":56,"category":"acceptance","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"document present exactly when the plan target is a document cannot be stated in gate.yaml, and validate exit 0 is the same before and after"},
 {"file":".engineering/planning/story/example-release-quality.md","line":54,"category":"acceptance","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"item 1 packs about eight attributes and no script reads them"},
 {"file":".engineering/planning/story/example-release-quality.md","line":37,"category":"acceptance","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"docs/design.md:201 names examples/ci-turnaround.ratchet.yaml, against the claim that design names no example file"},
 {"file":".engineering/planning/story/severity-limit-on-identity-set.md","line":57,"category":"acceptance","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"item 1 bundles four outcomes, one vague and one identical before and after"},
 {"file":".engineering/planning/story/assertion-required-items.md","line":80,"category":"acceptance","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"the CHANGELOG item names no heading or phrase; the same item is in all 33 stories"}]
```
