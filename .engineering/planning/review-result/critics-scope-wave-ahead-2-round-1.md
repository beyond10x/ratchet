---
format: aep.planning-md/3
id: review-result:critics-scope-wave-ahead-2-round-1
kind: review-result
status: active
title: scope critic on the 33 stories of wave ahead 2, round 1
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
Scope critic, round 1, on the 33 stories of `.engineering/waves/0.1.0-ahead-2.md` at e6dd5e9.
Verdict: needs-revision.

Nothing of the original bodies (7b01ea1) is dropped and no now-part holds command behaviour,
except the refusal of a range whose lower bound is above its upper bound. The order of the wave
record holds for every claim checked (`conformance-report@2` 8/12, `operation-time@2` 16/21,
`ObservationKey` 5/6, `Measurement` 17-19, `JudgedCandidate` 30/31, `RequirementVerdict` 26/32,
check 6 of the production-gate example 13/31). Field-row counts 98, 99, 101, 103, 105, 112 hold.

Findings: five `-in-ratchet` drafts declare members of `spec/domains/cli.yaml`, which the wave
otherwise puts in the now-part; two drafts carry design text; three now-parts reach past what
their story, epic or decision asked; two scope lists do not match their bodies; one count of
`spec/README.md` goes stale.

Notes without a finding entry: the wave record's list of shared files omits
`spec/domains/gate.yaml`, `spec/domains/cli.yaml`, `examples/README.md`,
`examples/production-gate.ratchet.yaml` and `docs/evidence-format.md` outside group B;
`story:requirement-over-two-measurements` does not rewrite point 2 of `presets/latency.md` and
`presets/operability.md`; `story:records-tracked-baseline-directory-in-ratchet` adds a refusal of
a path outside the root; `story:coverage-count-lower-bound` cites `want_examples` at `:46`, the
assignment is at `:57`.

```findings
[{"file":".engineering/planning/story/requirement-states-a-range.md","line":76,"category":"scope","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"the original promised the refusal of a range whose lower bound is above its upper bound; no refused copy of item 4 has min above max and the in-ratchet draft does not claim it"},
 {"file":".engineering/planning/story/requirement-states-a-range-in-ratchet.md","line":36,"category":"scope","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"the draft declares the two-bound LimitRow in spec/domains/cli.yaml, a format change that belongs in the now-part"},
 {"file":".engineering/planning/story/number-states-its-source-in-ratchet.md","line":36,"category":"scope","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"the draft declares the LimitRow member for the source in spec/domains/cli.yaml, which belongs in the now-part"},
 {"file":".engineering/planning/story/list-item-statement-in-ratchet.md","line":35,"category":"scope","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"the draft declares the report member for a statement in spec/domains/cli.yaml, which belongs in the now-part"},
 {"file":".engineering/planning/story/new-item-without-accepted-value-in-ratchet.md","line":18,"category":"scope","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"the draft adds the items not judged to VerdictRow in spec/domains/cli.yaml, which belongs in the now-part"},
 {"file":".engineering/planning/story/gate-joins-revision-and-document-in-ratchet.md","line":18,"category":"scope","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"the draft adds the document to VerdictRow in spec/domains/cli.yaml, which belongs in the now-part"},
 {"file":".engineering/planning/story/gate-judges-commit-of-a-tag-in-ratchet.md","line":17,"category":"scope","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"scope lists spec/domains/cli.yaml but no sentence of the body changes it"},
 {"file":".engineering/planning/story/requirement-over-two-measurements-in-ratchet.md","line":43,"category":"scope","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"the draft decides the cause and writes it into docs/design.md section 5, design text without docs/design.md in its scope"},
 {"file":".engineering/planning/story/production-gate-kind-in-ratchet.md","line":41,"category":"scope","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"the draft leaves the design decision of which revision is deployed in the class to itself and scopes spec/domains/gate.yaml with no stated change"},
 {"file":".engineering/planning/story/production-gate-kind.md","line":65,"category":"scope","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"the rule that every requirement of a production gate names a plan that runs in that class is asked by neither the story, the epic nor D88 A"},
 {"file":".engineering/planning/story/plan-never-assessed.md","line":75,"category":"scope","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"an enforced gate entry over a plan stating no_run_expected as a validation error is not in the original promise"},
 {"file":".engineering/planning/story/example-release-quality.md","line":58,"category":"scope","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"the example's gate carries judges tag, which neither the original acceptance nor epic:runnable-cli asks for"},
 {"file":".engineering/planning/story/assessor-learns-observation.md","line":110,"category":"scope","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"scope names presets/resources.md, start.md and operability.md but the acceptance rewrites point 6 of presets/latency.md only"},
 {"file":".engineering/planning/story/coverage-count-lower-bound.md","line":98,"category":"scope","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"spec/README.md:131 states 5 examples in section 6; units 2, 3, 4, 7 and 9 change want_examples and no body updates that count"}]
```
