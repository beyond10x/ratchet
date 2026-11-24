---
format: aep.planning-md/3
id: review-result:acceptance-round-1
kind: review-result
status: active
title: acceptance critic, round 1
relations:
- reviews: story:cli-skeleton-validate
- reviews: story:record-formats-in-spec
- reviews: story:evidence-reader
- reviews: story:assessor-declaration
- reviews: story:reference-compare
- reviews: story:assess-command
- reviews: story:reference-adopt-command
- reviews: story:evaluate-command
- reviews: story:ui-loop-acceptance
- reviews: story:acceptance-in-gate
- reviews: story:changelog-release-procedure
revision: 1
---
needs-revision
story:cli-skeleton-validate — the acceptance joins four independent outcomes (gate green, drift detected after a hand edit, validate valid on one fixture, validate duplicate_id on another) and says drift "failed in a test" while the Notes say "No test calls `ess`: the drift check is a gate step of its own", so the drift outcome has no stated observable — .engineering/planning/story/cli-skeleton-validate.md:71 and :115
story:record-formats-in-spec — the acceptance names `task check:spec exits 0`, which already exits 0 on the current specification, and nothing observable shows that all 78 fields of § 3 and the § 10 fields are declared, so it reads the same before the work as after; the clause "or says there is none" also lets the § 8 list be absent — .engineering/planning/story/record-formats-in-spec.md:42 (Taskfile.yml:12-16 runs only `ess specify validate` and `ess specify cli`)
story:evidence-reader — the story's title and scope include the local record directory (write under record id, list the runs of an assessment, read one, `[records] store` path) but the acceptance names no outcome for it, so `tests/store.rs` can be empty and the story still closes — .engineering/planning/story/evidence-reader.md:38
story:reference-compare — the acceptance joins the verdict table and a reference-record byte-identical round trip as two outcomes, and "the cause of an incomplete result" names no cause, so a row can be chosen to pass — .engineering/planning/story/reference-compare.md:34
story:assess-command — the Notes build `--report <file>` (records an existing document after the same checks, without starting the assessor) but the acceptance names no case for it, so the flag can be absent or wrong and the story still closes — .engineering/planning/story/assess-command.md:50
story:reference-adopt-command — the acceptance says a second call with unchanged evidence "writes the same bytes", but the Notes say "With a reference present the command refuses", and after the first call a reference record is present, so the second-call outcome is both a write and a refusal — .engineering/planning/story/reference-adopt-command.md:32 and :51
story:acceptance-in-gate — the acceptance joins two independent outcomes with "and": the gate runs the acceptance task at 7 of 7, and a Getting started page whose command output blocks are compared by a gate check, which names no check, so one can pass while the other fails — .engineering/planning/story/acceptance-in-gate.md:40
story:changelog-release-procedure — the acceptance joins three outcomes (CHANGELOG.md form, AGENTS.md § Release text, a test of two checks) and names no observable for the archive build, `SHA256SUMS`, the archive contents or the notes cut from the changelog, which the title and scope claim for `release.yml` — .engineering/planning/story/changelog-release-procedure.md:35

What I read: 11 of 11 stories with `aep plan artifact show story:<id>` for each, plus Taskfile.yml, spec/domains/cli.yaml (ValidationCode), docs/evidence-format.md § 8 and § 10, AGENTS.md, and the store files for line numbers.

Judged sound, no finding: story:assessor-declaration, story:evaluate-command, story:ui-loop-acceptance.

Could not establish: whether the check named in story:acceptance-in-gate for output blocks will exist (the story does not name it).

Out of my lane, not set into the verdict: step 2 of story:ui-loop-acceptance says "no gate names the plan's requirements yet" while its fixture's `ratchet.yaml` carries one gate (design/scope question). story:acceptance-in-gate depends on story:changelog-release-procedure (coupling, for the design critic). I did not judge the five undecomposed epics.

```findings
- file: .engineering/planning/story/cli-skeleton-validate.md
  line: 71
  category: acceptance
  severity: blocker
  verdict: needs-revision
  origin: introduced
  message: "the acceptance joins four independent outcomes (gate green, drift detected after a hand edit, validate valid on one fixture, validate duplicate_id on another) and says drift 'failed in a test' while the Notes say 'No test calls ess: the drift check is a gate step of its own', so the drift outcome has no stated observable"
- file: .engineering/planning/story/record-formats-in-spec.md
  line: 42
  category: acceptance
  severity: blocker
  verdict: needs-revision
  origin: introduced
  message: "the acceptance names `task check:spec exits 0`, which already exits 0 on the current specification, and nothing observable shows that all 78 fields of § 3 and the § 10 fields are declared, so it reads the same before the work as after; the clause 'or says there is none' also lets the § 8 list be absent"
- file: .engineering/planning/story/evidence-reader.md
  line: 38
  category: acceptance
  severity: blocker
  verdict: needs-revision
  origin: introduced
  message: "the story's title and scope include the local record directory (write under record id, list the runs of an assessment, read one, `[records] store` path) but the acceptance names no outcome for it, so tests/store.rs can be empty and the story still closes"
- file: .engineering/planning/story/reference-compare.md
  line: 34
  category: acceptance
  severity: warning
  verdict: needs-revision
  origin: introduced
  message: "the acceptance joins the verdict table and a reference-record byte-identical round trip as two outcomes, and 'the cause of an incomplete result' names no cause, so a row can be chosen to pass"
- file: .engineering/planning/story/assess-command.md
  line: 50
  category: acceptance
  severity: warning
  verdict: needs-revision
  origin: introduced
  message: "the Notes build `--report <file>` (records an existing document after the same checks, without starting the assessor) but the acceptance names no case for it, so the flag can be absent or wrong and the story still closes"
- file: .engineering/planning/story/reference-adopt-command.md
  line: 32
  category: acceptance
  severity: blocker
  verdict: needs-revision
  origin: introduced
  message: "the acceptance says a second call with unchanged evidence 'writes the same bytes', but the Notes (line 51) say 'With a reference present the command refuses', and after the first call a reference record is present, so the second-call outcome is both a write and a refusal"
- file: .engineering/planning/story/acceptance-in-gate.md
  line: 40
  category: acceptance
  severity: warning
  verdict: needs-revision
  origin: introduced
  message: "the acceptance joins two independent outcomes with 'and': the gate runs the acceptance task at 7 of 7, and a Getting started page whose command output blocks are compared by a gate check that is not named, so one can pass while the other fails"
- file: .engineering/planning/story/changelog-release-procedure.md
  line: 35
  category: acceptance
  severity: warning
  verdict: needs-revision
  origin: introduced
  message: "the acceptance joins three outcomes (CHANGELOG.md form, AGENTS.md § Release text, a test of two checks) and names no observable for the archive build, SHA256SUMS, archive contents or the notes cut from the changelog, which the title and scope claim for release.yml"
```
