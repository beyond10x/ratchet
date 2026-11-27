---
format: aep.planning-md/3
id: review-result:adversary-wave-ahead-2-attack-1
kind: review-result
status: active
title: adversary on wave ahead 2, attack 1 on 47e82d9
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
Adversary, attack 1, on wave ahead 2 (`.engineering/waves/0.1.0-ahead-2.md`), commits 20565dc..47e82d9
over 5cbb795. Verdict: needs-change; 31 findings, all introduced by the wave, no blocker.

Attacked: 52 mutants of `spec/presets.test.sh` (36 killed by the cases as built), 5 of
`spec/example-declarations.test.sh`, 7 of `spec/record-examples.test.sh`. Compatibility held: the
55 presets of 0.0.4, the five § 6 examples of 0.0.4 and the examples of 0.0.4 pass the changed
checks. Counts of `spec/README.md` and the citation table resolve. No private name, path or
decision number in the added lines.

New cases written: 15 mutant killers in `spec/presets.test.sh` and 2 in
`spec/gate-inputs.test.sh`; two red cases (`population-field-as-input`,
`observation-input-window-keys`); a new `spec/design-drift.test.sh` with 13 sentences, 10 of them
red.

```findings
[{"file":"spec/presets.test.sh","line":1202,"category":"contract-drift","severity":"warning","verdict":"CONFIRMED","origin":"introduced","message":"story:window-over-outside-population: the rule reads observation.window_last and observation.window_ends_at, while section 10 puts them at window.last and the instant of assessment (case observation-input-window-keys)"},
 {"file":"docs/evidence-format.md","line":801,"category":"contract-drift","severity":"warning","verdict":"CONFIRMED","origin":"introduced","message":"story:window-over-outside-population: an input named as a population field is forbidden, yet the preset check neither refuses it nor lists it under Not checked (case population-field-as-input)"},
 {"file":"docs/design.md","line":583,"category":"contract-drift","severity":"warning","verdict":"NEEDS-CHANGE","origin":"introduced","message":"story:reference-from-another-plan: says ratchet/1 has no adoption that names the plan, while AdoptionSource has assessment"},
 {"file":"docs/design.md","line":580,"category":"contract-drift","severity":"warning","verdict":"NEEDS-CHANGE","origin":"introduced","message":"story:reference-from-another-plan: says a comparison in a preset waits for a reference from another plan, which batch 7 delivered"},
 {"file":"docs/design.md","line":585,"category":"contract-drift","severity":"warning","verdict":"NEEDS-CHANGE","origin":"introduced","message":"story:requirement-over-two-measurements: says functional.md names these points as not expressible, while that page marks them answered"},
 {"file":"presets/artifact.md","line":323,"category":"contract-drift","severity":"warning","verdict":"NEEDS-CHANGE","origin":"introduced","message":"story:reference-from-another-plan: point 1 says RatchetPolicy names no assessment; the same on build.md, code.md, latency.md, operability.md, resources.md and start.md"},
 {"file":"spec/presets.test.sh","line":1418,"category":"mutant","severity":"warning","verdict":"CONFIRMED","origin":"introduced","message":"story:reference-from-another-plan: the measurement-on-trusted_revision refusal survived its removal; killed by adoption-measurement-on-trusted-revision"},
 {"file":"spec/presets.test.sh","line":1456,"category":"mutant","severity":"warning","verdict":"CONFIRMED","origin":"introduced","message":"story:requirement-states-a-range: within on an assertion was unguarded; killed by compare-within-on-an-assertion"},
 {"file":"spec/presets.test.sh","line":1458,"category":"mutant","severity":"warning","verdict":"CONFIRMED","origin":"introduced","message":"story:requirement-over-two-measurements: no copy held lte with against; killed by compare-against-lte"},
 {"file":"spec/presets.test.sh","line":1463,"category":"mutant","severity":"warning","verdict":"CONFIRMED","origin":"introduced","message":"story:requirement-states-a-range: within without min survived; killed by compare-range-without-min, compare-max-on-gte, compare-within-equal-and-numeric-bounds"},
 {"file":"spec/presets.test.sh","line":816,"category":"mutant","severity":"warning","verdict":"CONFIRMED","origin":"introduced","message":"story:input-allowed-values: the list branch of outside() was untested; killed by three new cases"},
 {"file":"spec/presets.test.sh","line":1508,"category":"mutant","severity":"warning","verdict":"CONFIRMED","origin":"introduced","message":"story:reference-from-another-plan: pass_rate and unit rules of an adoption survived; killed by pass-rate-against-and-adopted, coverage-count-adopted-from-cases"},
 {"file":"spec/presets.test.sh","line":1423,"category":"mutant","severity":"warning","verdict":"CONFIRMED","origin":"introduced","message":"story:coverage-count-with-reference: comparisons of a coverage count were untested; killed by three new cases"},
 {"file":"spec/record-examples.test.sh","line":163,"category":"mutant","severity":"warning","verdict":"CONFIRMED","origin":"introduced","message":"story:prove-command: an unknown format read as AssessmentRun and a dropped section 12 count survived; killed by gate-inputs example-format-unknown and proof-example-added"},
 {"file":"spec/domains/gate.yaml","line":277,"category":"contract-drift","severity":"note","verdict":"INFEASIBLE","origin":"introduced","message":"story:new-item-without-accepted-value, story:plan-never-assessed, story:prove-command: items_not_judged, plan_state and ProofRecord.format became required on records no release has written"},
 {"file":"docs/design.md","line":813,"category":"contract-drift","severity":"note","verdict":"CONFIRMED","origin":"introduced","message":"story:new-item-without-accepted-value: the gate decision row of section 6 does not list the items not judged"},
 {"file":"spec/presets.test.sh","line":821,"category":"mutant","severity":"note","verdict":"CONFIRMED","origin":"introduced","message":"story:input-allowed-values and story:coverage-count-with-reference: dead clauses (presets.test.sh:821, example-declarations.test.sh:441)"}]
```
