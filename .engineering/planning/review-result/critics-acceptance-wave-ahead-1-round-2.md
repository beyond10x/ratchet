---
format: aep.planning-md/3
id: review-result:critics-acceptance-wave-ahead-1-round-2
kind: review-result
status: active
title: acceptance critic on the nine stories of the ahead wave, round 2
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
Acceptance critic, round 2, on the nine stories of `.engineering/waves/0.1.0-ahead-1.md` at
b28b930. Verdict: needs-revision (one blocker, seventeen warnings); plan-with-exact-and-sampled-measurements
approved. All 11 findings of round 1 are answered.

## Per story

- workflow-run-target-identifiers: the example is read only as a count; name a grep on `run_id` and `job`.
- candidate-under-merge-result: no rule sees `merge_result` or two different ids; the header of spec/record-examples.test.sh:27 states the count too.
- cache-condition-one-name: the refusal of `cache` has no sentence of the format behind it; the name `cache_profile` is left open by a Note.
- specification-answers-first-format-consumer: place 10 leaves the refusal of `scopes: []` open, and a refusal would change released declarations; no case drops `scopes`; place 16 names no sentence form for the digest § 6 states.
- preset-check-unlisted-forms: an exception leaves the refused set open; form 14 names a story built before it; the harness case of line 1600 has no mechanism; the adoption entry is at :123-126.
- value-over-all-runs: "whether `ratchet validate` reports the form today" cannot be observed.
- item-field-values: the counts of 19 rows stand also in spec/README.md and two script headers; `:129` moves after earlier stories.
- production-gate-spec-executed-service: absolute counts ignore stories 7 and 8 (blocker); the bound presets, the kind, the filter and the digests are read by no script; Scope items the acceptance does not name.

No item needs a `ratchet` command. No later acceptance undoes an earlier one except the counts of story 9.

```findings
[
{"file": ".engineering/planning/story/workflow-run-target-identifiers.md", "line": 34, "category": "acceptance", "severity": "warning", "verdict": "needs-revision", "origin": "introduced", "message": "the example that carries run_id and job is read by record-examples.test.sh only as a count, since identifiers is an open map; name a grep on run_id and job (0 before, 1 after) or a rule of the script"},
{"file": ".engineering/planning/story/candidate-under-merge-result.md", "line": 45, "category": "acceptance", "severity": "warning", "verdict": "needs-revision", "origin": "introduced", "message": "no rule of record-examples.test.sh sees merge_result or that candidate and target.revision differ, only the count 5; add a jq observation or a rule with a case"},
{"file": ".engineering/planning/story/candidate-under-merge-result.md", "line": 51, "category": "acceptance", "severity": "warning", "verdict": "needs-revision", "origin": "introduced", "message": "item 3 names spec/README.md:122 and not the header of spec/record-examples.test.sh:27 that states the number of examples"},
{"file": ".engineering/planning/story/cache-condition-one-name.md", "line": 80, "category": "acceptance", "severity": "warning", "verdict": "needs-revision", "origin": "introduced", "message": "item 5 refuses cache and no sentence of the format forbids it (specification.yaml:349-350 calls the struct open); say in items 1 to 3 that a plan and a declaration write cache_profile and no other name"},
{"file": ".engineering/planning/story/cache-condition-one-name.md", "line": 91, "category": "acceptance", "severity": "warning", "verdict": "needs-revision", "origin": "introduced", "message": "the Note lets the story record the other name and then every item changes; fix cache_profile in the acceptance and move the alternative to another story"},
{"file": ".engineering/planning/story/specification-answers-first-format-consumer.md", "line": 62, "category": "acceptance", "severity": "warning", "verdict": "needs-revision", "origin": "introduced", "message": "place 10 leaves open whether the empty scopes list is refused, and a refusal would change released @1 declarations; name the answer valid and delete the branch"},
{"file": ".engineering/planning/story/specification-answers-first-format-consumer.md", "line": 61, "category": "acceptance", "severity": "warning", "verdict": "needs-revision", "origin": "introduced", "message": "an output without scopes is refused by rules type and required, but no case of presets.test.sh drops scopes; add the case or drop the clause"},
{"file": ".engineering/planning/story/specification-answers-first-format-consumer.md", "line": 78, "category": "acceptance", "severity": "warning", "verdict": "needs-revision", "origin": "introduced", "message": "the rule must find the digest that section 6 states and no sentence form is named; name it, say the digest is over the printed example, and add sha256sum to the script's needs"},
{"file": ".engineering/planning/story/preset-check-unlisted-forms.md", "line": 43, "category": "acceptance", "severity": "warning", "verdict": "needs-revision", "origin": "introduced", "message": "the exception for a form the story finds a forbidding sentence for leaves the set of refused forms open while Notes 69-70 say none is forbidden; delete the exception"},
{"file": ".engineering/planning/story/preset-check-unlisted-forms.md", "line": 45, "category": "acceptance", "severity": "warning", "verdict": "needs-revision", "origin": "introduced", "message": "form 14 names as its deciding story one that is built before this story; name the sentence of docs/design.md it writes as the reason"},
{"file": ".engineering/planning/story/preset-check-unlisted-forms.md", "line": 53, "category": "acceptance", "severity": "warning", "verdict": "needs-revision", "origin": "introduced", "message": "the harness case for line 1600 has no mechanism, a case cannot delete its own line; run a copy of the script with the compared line made to differ, expect exit 1 there, and time it"},
{"file": ".engineering/planning/story/preset-check-unlisted-forms.md", "line": 94, "category": "acceptance", "severity": "warning", "verdict": "needs-revision", "origin": "introduced", "message": "the adoption entry of the header is at presets.test.sh:123-126, not 121-124"},
{"file": ".engineering/planning/story/value-over-all-runs.md", "line": 49, "category": "acceptance", "severity": "warning", "verdict": "needs-revision", "origin": "introduced", "message": "the design first answers whether ratchet validate reports the form today, and no such command exists so today cannot be observed; reword as the section of docs/design.md that lists the form"},
{"file": ".engineering/planning/story/item-field-values.md", "line": 54, "category": "acceptance", "severity": "warning", "verdict": "needs-revision", "origin": "introduced", "message": "item 2 omits spec/README.md:119-122 and the headers of record-fields.test.sh and record-types.test.sh that state 19 rows of section 10"},
{"file": ".engineering/planning/story/item-field-values.md", "line": 65, "category": "acceptance", "severity": "warning", "verdict": "needs-revision", "origin": "introduced", "message": "the header line at presets.test.sh:129 moves after stories 3, 5 and 6 edit the header; cite it by its text"},
{"file": ".engineering/planning/story/production-gate-spec-executed-service.md", "line": 80, "category": "acceptance", "severity": "blocker", "verdict": "needs-revision", "origin": "introduced", "message": "the absolute counts ignore stories 7 and 8, which add 3 files and 4 measurements and land first, and the broken copies of stories 3, 5, 7 and 8; state 5 more files, 4 more measurements and c unchanged from after story 8"},
{"file": ".engineering/planning/story/production-gate-spec-executed-service.md", "line": 72, "category": "acceptance", "severity": "warning", "verdict": "needs-revision", "origin": "introduced", "message": "the bound presets, kind candidate, the check 6 filter and requirement and the digests are read by no script; name greps or extend the use rule to compare each digest with sha256sum of the file"},
{"file": ".engineering/planning/story/production-gate-spec-executed-service.md", "line": 99, "category": "acceptance", "severity": "warning", "verdict": "needs-revision", "origin": "introduced", "message": "Scope lists the two design rows, examples/README.md and CHANGELOG.md and the acceptance names none of them"}
]
```
