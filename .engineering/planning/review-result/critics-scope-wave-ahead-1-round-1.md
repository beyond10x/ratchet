---
format: aep.planning-md/3
id: review-result:critics-scope-wave-ahead-1-round-1
kind: review-result
status: active
title: scope critic on five stories of the ahead wave, round 1
relations:
- reviews: story:preset-check-one-start
- reviews: story:preset-check-unlisted-forms
- reviews: story:production-gate-spec-executed-service
- reviews: story:specification-answers-first-format-consumer
- reviews: story:workflow-run-target-identifiers
revision: 1
---
Scope critic, round 1, on the five stories of the wave taken ahead of the waves to 0.1.0, against
`epic:preset-catalog` (PC) and `epic:format-gaps-first-format-consumer` (FG). Verdict:
needs-revision for all five.

## Per story

- preset-check-one-start: the premise is false at the base: each copy is checked in process by
  `check_catalog` (spec/presets.test.sh:1386, inside `judge_cases` :1429); `sh "$self"` stands only
  at :1600 and :1609 (harness runs); the tables are parsed once (:1382-1385). The body must name
  the true per-copy cost (one `check_catalog` run, several awk passes over the copy); title and
  summary ("in one start") follow.
- preset-check-unlisted-forms: `runs: 1` with an aggregation is the rule finding 11 of
  specification-answers decides (design.md:114); a literal `runs` above 1 without aggregation is the
  acceptance of `story:value-over-all-runs` (:38-39); both go under "Not checked" with the deciding
  story named. The acceptance names nine forms, the notes fourteen. Asking the design and writing
  answers into design.md makes format rules, against PC:78-79; a form the design does not forbid
  goes under "Not checked" with its reason.
- production-gate-spec-executed-service: adds a ninth family and an example where PC:31, :56 name
  eight families and no example; the body must say it extends the epic. The severity key in
  `spec/domains/` and the gate kind in design § 5 add format (PC:78-79), the gate kind overlaps
  `story:gate-judges-commit-of-a-tag`, and a severity requirement would touch `Condition`
  (specification.yaml:496); both become separate drafts. Check 6 binds a preset although the
  catalog has no severity limit: name it bound with `no_new_items` only. The reader of the example
  is `spec/example-declarations.test.sh`; binding digests are checked by no command until
  `story:preset-binding-resolution`.
- specification-answers-first-format-consumer: finding 8 is also decided by
  `story:assessor-learns-observation` (:58-65); one drops it and FG:38 points at the other.
  Finding 11 shares the `runs: 1` rule with member-for-some-input-values (:27-32),
  preset-check-unlisted-forms (:62) and value-over-all-runs; say it decides only the validity of
  existing aggregation kinds at `runs: 1`. Finding 14 may reach `Condition.unit` (FG:55-57); say
  the answer is text only. No script reads `observation.command` (8) or a comment (15): name the
  reading script per place or say text only.
- workflow-run-target-identifiers: "refuses the names" is false before and only code can deliver
  it; `identifiers` is an open map (evidence.yaml:112-113) kept open by E5
  (evidence-format.md:334). The acceptance lists `run_id` and `job` in the specification and a § 6
  example. It shares the § 6 count (spec/record-examples.test.sh:46, spec/README.md) with
  `story:candidate-under-merge-result`; say it adds its own example and leaves the `merge_result`
  pair to that story.

## Build order on one branch

1. preset-check-one-start; 2. workflow-run-target-identifiers; 3. specification-answers;
4. preset-check-unlisted-forms; 5. production-gate-spec-executed-service.

`task generate`: the only generated crate is `crates/ratchet-cli-contract` (`ratchet.cli` types
only), so the specification, evidence and assessor domains do not change it; stories that edit
`spec/domains/` still run `task check:generated`.

Out of lane: FG says 16 findings (FG:7, :20), 22 places (FG:26) and seventeen stories (FG:61).

```findings
[{"file": ".engineering/planning/story/preset-check-one-start.md", "line": 23, "category": "scope", "severity": "blocker", "verdict": "needs-revision", "origin": "introduced", "message": "each copy is checked in process by check_catalog (spec/presets.test.sh:1386), not by a new start of the script; the body names no true per-copy cost"},
 {"file": ".engineering/planning/story/preset-check-unlisted-forms.md", "line": 62, "category": "scope", "severity": "blocker", "verdict": "needs-revision", "origin": "introduced", "message": "runs 1 with an aggregation is the rule finding 11 of story:specification-answers-first-format-consumer decides; it goes under Not checked until that answer exists"},
 {"file": ".engineering/planning/story/preset-check-unlisted-forms.md", "line": 60, "category": "scope", "severity": "blocker", "verdict": "needs-revision", "origin": "introduced", "message": "a literal runs above 1 with no aggregation is the acceptance of story:value-over-all-runs; it goes under Not checked with that story named"},
 {"file": ".engineering/planning/story/preset-check-unlisted-forms.md", "line": 39, "category": "scope", "severity": "warning", "verdict": "needs-revision", "origin": "introduced", "message": "the acceptance covers nine forms while the notes say fourteen"},
 {"file": ".engineering/planning/story/preset-check-unlisted-forms.md", "line": 65, "category": "scope", "severity": "warning", "verdict": "needs-revision", "origin": "introduced", "message": "writing design answers into docs/design.md makes format rules against epic:preset-catalog:78-79; forms the design does not forbid go under Not checked"},
 {"file": ".engineering/planning/story/production-gate-spec-executed-service.md", "line": 72, "category": "scope", "severity": "blocker", "verdict": "needs-revision", "origin": "introduced", "message": "a ninth family and an example where epic:preset-catalog:31 and :56 name eight families and no example; the body must say it extends the epic"},
 {"file": ".engineering/planning/story/production-gate-spec-executed-service.md", "line": 79, "category": "scope", "severity": "blocker", "verdict": "needs-revision", "origin": "introduced", "message": "the severity key and the gate kind add format against epic:preset-catalog:78-79, and the gate kind overlaps story:gate-judges-commit-of-a-tag; both become separate drafts"},
 {"file": ".engineering/planning/story/production-gate-spec-executed-service.md", "line": 66, "category": "scope", "severity": "blocker", "verdict": "needs-revision", "origin": "introduced", "message": "check 6 binds a preset although the catalog has no severity limit; name it bound with no_new_items only"},
 {"file": ".engineering/planning/story/production-gate-spec-executed-service.md", "line": 66, "category": "scope", "severity": "warning", "verdict": "needs-revision", "origin": "introduced", "message": "the reader of the example is spec/example-declarations.test.sh, and binding digests are checked by no command in this wave"},
 {"file": ".engineering/planning/story/specification-answers-first-format-consumer.md", "line": 22, "category": "scope", "severity": "blocker", "verdict": "needs-revision", "origin": "introduced", "message": "finding 8 is also decided by story:assessor-learns-observation; one story drops it"},
 {"file": ".engineering/planning/story/specification-answers-first-format-consumer.md", "line": 29, "category": "scope", "severity": "blocker", "verdict": "needs-revision", "origin": "introduced", "message": "finding 11 shares the runs 1 rule with three drafts; say it decides only the validity of existing aggregation kinds at runs 1"},
 {"file": ".engineering/planning/story/specification-answers-first-format-consumer.md", "line": 38, "category": "scope", "severity": "warning", "verdict": "needs-revision", "origin": "introduced", "message": "finding 14 may reach Condition.unit, a type the 0.1.0 slice reads; say the answer is text only"},
 {"file": ".engineering/planning/story/specification-answers-first-format-consumer.md", "line": 46, "category": "scope", "severity": "warning", "verdict": "needs-revision", "origin": "introduced", "message": "no script reads observation.command (8) or a comment (15); name the reading script per place or say text only"},
 {"file": ".engineering/planning/story/workflow-run-target-identifiers.md", "line": 23, "category": "scope", "severity": "blocker", "verdict": "needs-revision", "origin": "introduced", "message": "refusing the names is false before and only code can deliver it; identifiers stays an open map (E5), so the acceptance lists run_id and job in the specification and a section 6 example"},
 {"file": ".engineering/planning/story/workflow-run-target-identifiers.md", "line": 23, "category": "scope", "severity": "warning", "verdict": "needs-revision", "origin": "introduced", "message": "this story and story:candidate-under-merge-result both change the section 6 example count; say it adds its own example and leaves the merge_result pair to the other"}]
```
