---
format: aep.planning-md/3
id: review-result:critics-acceptance-wave-ahead-1-round-1
kind: review-result
status: active
title: acceptance critic on five stories of the ahead wave, round 1
relations:
- reviews: story:preset-check-one-start
- reviews: story:preset-check-unlisted-forms
- reviews: story:production-gate-spec-executed-service
- reviews: story:specification-answers-first-format-consumer
- reviews: story:workflow-run-target-identifiers
revision: 1
---
Acceptance critic, round 1, on the five stories of the wave taken ahead of the waves to 0.1.0:
`story:preset-check-one-start`, `story:preset-check-unlisted-forms`,
`story:production-gate-spec-executed-service`, `story:specification-answers-first-format-consumer`,
`story:workflow-run-target-identifiers`. Verdict: needs-revision for all five.

## Type rule (epic:format-gaps-first-format-consumer lines 55-57)

- Stories 1, 2, 4 and 5 change none of `EvidenceCoverage`, `ImportSourceKind`, `Condition` by their bodies.
- Story 4, finding 14 (units), could reach the `unit` of `Condition` (spec/domains/specification.yaml:511) if the answer allows another unit; the body does not say it will not.
- Story 3: a requirement "no item of severity critical" (production-gate-spec-executed-service.md:81) would be a new operator or limit on `Condition`; the severity part cannot be in this wave.

## task generate rule (epic:preset-catalog lines 118-120)

- Stories 3, 4 and 5 change or may change `spec/domains/`; each needs the line "run `task generate` if `story:cli-skeleton-validate` has landed".

## Per story

- preset-check-one-start: the time clause names no statistic and no round count; under load one script took 3.2 s to 13.7 s. Name a load-independent count of starts (1, before 91) first, the median of alternating pairs second, and the time in its own sentence.
- preset-check-unlisted-forms: the acceptance says nine forms, the notes fourteen, and the tolerance places are unnamed; no default without an owner answer; the form `runs: 1` with an aggregation is the place story 4 decides (finding 11); two outcomes in one sentence (the forms, the harness case of the comparison).
- production-gate-spec-executed-service: binding the catalog presets has no check in this wave (no example holds a `presets:` block, no script reads a binding); check 6 and the gate kind are decided inside the story (docs/design.md:184 already has a severity filter); a third declaration in the Scope is not in the acceptance; "counts their measurements" names no number.
- specification-answers-first-format-consumer: "an example document that the answer makes valid or invalid" is not decidable for the six places with the scripts that exist; finding 16 is a recipe; a new § 6 example changes `want_examples` in spec/record-examples.test.sh:46.
- workflow-run-target-identifiers: the before-state is false (identifiers is an open `Map<String, String>`, spec/domains/evidence.yaml:113, so `run_id` and `job` decode today) and "the reader of the story" names no reader; "told apart" needs a reader that does not exist.

```findings
[{"file": ".engineering/planning/story/preset-check-one-start.md", "line": 36, "category": "acceptance", "severity": "blocker", "verdict": "needs-revision", "origin": "introduced", "message": "the time clause names no statistic and no round count, and one script took 3.2 s to 13.7 s under load; add a load-independent count of starts (1, before 91) and the median of at least 5 alternating pairs in one slot job"},
 {"file": ".engineering/planning/story/preset-check-unlisted-forms.md", "line": 39, "category": "acceptance", "severity": "blocker", "verdict": "needs-revision", "origin": "introduced", "message": "the acceptance says the nine forms while the notes say fourteen and leave the other places a tolerance stands unnamed"},
 {"file": ".engineering/planning/story/preset-check-unlisted-forms.md", "line": 65, "category": "acceptance", "severity": "warning", "verdict": "needs-revision", "origin": "introduced", "message": "the design is asked first but no default is named, so the forms have no outcome without an owner answer"},
 {"file": ".engineering/planning/story/preset-check-unlisted-forms.md", "line": 61, "category": "acceptance", "severity": "blocker", "verdict": "needs-revision", "origin": "introduced", "message": "runs 1 with an aggregation is the place story:specification-answers-first-format-consumer decides (finding 11); remove the form or order that story first"},
 {"file": ".engineering/planning/story/preset-check-unlisted-forms.md", "line": 39, "category": "acceptance", "severity": "warning", "verdict": "needs-revision", "origin": "introduced", "message": "one sentence joins the forms and the harness case of the comparison; split them and state the case as one that goes red when the comparison line is deleted"},
 {"file": ".engineering/planning/story/production-gate-spec-executed-service.md", "line": 66, "category": "acceptance", "severity": "blocker", "verdict": "needs-revision", "origin": "introduced", "message": "binding the catalog presets has no check in this wave; add a rule that each use in an example names a presets file, with a case on each side"},
 {"file": ".engineering/planning/story/production-gate-spec-executed-service.md", "line": 81, "category": "acceptance", "severity": "blocker", "verdict": "needs-revision", "origin": "introduced", "message": "check 6 and the gate kind are decided inside the story; docs/design.md:184 already has a severity filter, so bind dependency-advisories@1 with the filter and no new spec type, and state the kind in the example"},
 {"file": ".engineering/planning/story/production-gate-spec-executed-service.md", "line": 66, "category": "acceptance", "severity": "warning", "verdict": "needs-revision", "origin": "introduced", "message": "the Scope lists a third declaration the acceptance does not name, and counts their measurements names no number"},
 {"file": ".engineering/planning/story/specification-answers-first-format-consumer.md", "line": 48, "category": "acceptance", "severity": "blocker", "verdict": "needs-revision", "origin": "introduced", "message": "an example document valid or invalid is not decidable for the six places with the scripts that exist, and finding 16 is a recipe; name per place the script, the rule and the accepted or refused input"},
 {"file": ".engineering/planning/story/workflow-run-target-identifiers.md", "line": 27, "category": "acceptance", "severity": "blocker", "verdict": "needs-revision", "origin": "introduced", "message": "the before-state is false: identifiers is an open map so run_id and job decode today, and the reader of the story names no reader; add a shell rule that refuses them on another target kind, with a passing section 6 example"},
 {"file": ".engineering/planning/story/workflow-run-target-identifiers.md", "line": 25, "category": "acceptance", "severity": "warning", "verdict": "needs-revision", "origin": "introduced", "message": "told apart needs a reader that does not exist; drop it or reword it as two section 6 examples with one run_id and two jobs"}]
```
