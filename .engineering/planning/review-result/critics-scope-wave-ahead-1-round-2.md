---
format: aep.planning-md/3
id: review-result:critics-scope-wave-ahead-1-round-2
kind: review-result
status: active
title: scope critic on the nine stories of the ahead wave, round 2
relations:
- reviews: story:workflow-run-target-identifiers
- reviews: story:candidate-under-merge-result
- reviews: story:cache-condition-one-name
- reviews: story:specification-answers-first-format-consumer
- reviews: story:plan-with-exact-and-sampled-measurements
- reviews: story:preset-check-unlisted-forms
- reviews: story:value-over-all-runs
- reviews: story:item-field-values
- reviews: story:production-gate-spec-executed-service
revision: 1
---
Scope critic, round 2, on the nine stories of `.engineering/waves/0.1.0-ahead-1.md` at b28b930.
Verdict: needs-revision. Round-1 findings are answered except the two drafts promised by the
production gate story.

## Per story, in wave order

1. workflow-run-target-identifiers: approve.
2. candidate-under-merge-result: approve; the original and its -in-ratchet draft cover the story, nothing claimed twice.
3. cache-condition-one-name: approve; `ObservationConditions` (specification.yaml:343-350) is not `Condition` (specification.yaml:496).
4. specification-answers-first-format-consumer: needs-revision; cites the type rule as epic lines 55-57, now lines 68-70.
5. plan-with-exact-and-sampled-measurements: approve; order after 3 and 4 is right.
6. preset-check-unlisted-forms: needs-revision; frontmatter scope lists docs/design.md while the body writes no rule there.
7. value-over-all-runs: needs-revision; an `AggregationKind` variant would be an aggregation at `runs: 1` (specification.yaml:182-188), reaching finding 11 and story:member-for-some-input-values.
8. item-field-values: approve.
9. production-gate-spec-executed-service: needs-revision; counts are those of 7aa82f8 though stories 7 and 8 add files first; design.md § 4 has no table of presets; examples/README.md:523 lists a `presets` binding among shapes no example uses, a sentence story:preset-binding-resolution:71 also claims; the `use:` rule overlaps `unresolved_reference`; the severity and gate-kind drafts do not exist.

## Epics

- epic:preset-catalog: does not say that value-over-all-runs, item-field-values and cache-condition-one-name add to the format by their own decision; Done when names four stories only.
- epic:format-gaps-first-format-consumer: promises a test that failed before for each place while several places are answered in text only.

Type rule: none of the nine changes `EvidenceCoverage`, `ImportSourceKind` or `Condition`. Order: consistent with the files each story edits, except the counts of story 9.

```findings
[{"file":".engineering/planning/story/specification-answers-first-format-consumer.md","line":50,"category":"scope","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"cites the type rule as epic lines 55-57; in revision 7 of the epic it is lines 68-70"},
 {"file":".engineering/planning/story/preset-check-unlisted-forms.md","line":12,"category":"scope","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"frontmatter scope lists docs/design.md while the body says the story writes no rule into it (:91-93); drop the scope line"},
 {"file":".engineering/planning/story/value-over-all-runs.md","line":51,"category":"scope","severity":"blocker","verdict":"needs-revision","origin":"introduced","message":"the form may be an AggregationKind variant, which would be an aggregation at runs 1 and reaches finding 11 and story:member-for-some-input-values; state the form is valid for every runs and is no aggregation at runs 1"},
 {"file":".engineering/planning/story/production-gate-spec-executed-service.md","line":80,"category":"scope","severity":"blocker","verdict":"needs-revision","origin":"introduced","message":"counts are those of 7aa82f8 but stories 7 and 8 add files and measurements first, and the broken-copy count names only story 6; state increments and the count stories 3 to 8 leave"},
 {"file":".engineering/planning/story/production-gate-spec-executed-service.md","line":101,"category":"scope","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"design.md section 4 holds no table of presets, only the family table; name the two rows and the table or drop the line"},
 {"file":".engineering/planning/story/production-gate-spec-executed-service.md","line":99,"category":"scope","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"examples/README.md:523 lists a presets binding among the shapes no example uses; the story must remove it, and story:preset-binding-resolution:71 claims the same sentence"},
 {"file":".engineering/planning/story/production-gate-spec-executed-service.md","line":88,"category":"scope","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"the use: rule checks file existence and overlaps unresolved_reference of story:preset-binding-resolution; say digest, inputs and unresolved_reference stay there"},
 {"file":".engineering/planning/story/production-gate-spec-executed-service.md","line":113,"category":"scope","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"the severity story and the gate-kind story are said to become drafts but none exists in the store; file them or say when"},
 {"file":".engineering/planning/epic/preset-catalog.md","line":110,"category":"scope","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"epic says the catalog adds no key to the format (:80-85) and does not say that value-over-all-runs, item-field-values and cache-condition-one-name add to the format by their own decision"},
 {"file":".engineering/planning/epic/preset-catalog.md","line":149,"category":"scope","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"Done when names the four stories and none of the eight stories taken ahead or split"},
 {"file":".engineering/planning/epic/format-gaps-first-format-consumer.md","line":29,"category":"scope","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"promises a test that failed before for each place while stories answer several places in text only; the epic does not say where text only is allowed"}]
```
