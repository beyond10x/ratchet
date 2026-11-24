---
format: aep.planning-md/3
id: review-result:scope-round-1
kind: review-result
status: active
title: scope critic, round 1
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
- reviews: epic:release-line
- reviews: epic:first-consumer-ui-loop
- reviews: epic:observe-adopt-reject
- reviews: epic:runnable-cli
revision: 1
---
needs-revision
epic:release-line — the promise "0.1.0 is released when the slice of `epic:observe-adopt-reject` is green on `main` with the acceptance run at 7 of 7" (also "Done when ... the release 0.1.0 exists, authored by the bot, with its archives and checksums attached") is claimed by no story: `story:changelog-release-procedure` delivers CHANGELOG.md, § "Release", the workflow and a test of two checks, and its acceptance and scope never include performing the release; `story:acceptance-in-gate` only notes "0.1.0 is cut by the release procedure" afterwards; `epic:first-consumer-ui-loop` repeats the same promise ("and 0.1.0 is released with every step of the acceptance run passing"). Add a release story (or widen `story:changelog-release-procedure`) that depends on `story:acceptance-in-gate` and whose acceptance is the published release, or have the epics state that the release is an operator act outside any story. — .engineering/planning/epic/release-line.md:21-23 and :33-35; .engineering/planning/epic/first-consumer-ui-loop.md:33; .engineering/planning/story/acceptance-in-gate.md:61

What I read: 16 artifacts (initiative, 9 epics, 11 stories, minus overlap: initiative:first-milestone, the 4 decomposed epics, the 5 undecomposed epics and the 11 stories) via `aep plan artifact show <id>` for each and `aep plan artifact graph`. Sources read: vision.md, ROADMAP.md, AGENTS.md (§ "Phase: implementation", § "Specification first (ESS)"), docs/design.md headings and § 7 and § 5 "Gate modes" lines. Promise count: I extracted 31 promises from the four decomposed epics, the initiative's milestone sentence and its 0.1.0 list, and traced 30 to a story. The untraced one is the release itself (the finding above). Joint epic coverage of `vision.md` § "First milestone" holds: observe mode and adopt a gate and reject (`epic:observe-adopt-reject`), record an improvement (`epic:improvement-and-policy`), the four integrations (`epic:ess-ui-behavior`, `epic:ci-turnaround`, `epic:analyzer-findings`, `epic:generated-artifact`), and the host-caused insufficient-evidence sentence (`epic:ci-turnaround`, line "the last sentence of vision.md § First milestone"). No story reaches into a "Not in this slice" or "Not in this epic" item: the exclusions of `story:assess-command`, `story:reference-adopt-command` and `story:evaluate-command` repeat the epic's exclusions.

What I could not establish:
- The initiative's "Done when" clause "the first consumer's loop runs on `ratchet` with no comparator of its own" is covered only by `epic:improvement-and-policy` (undecomposed) plus the consumer's own migration story, which `epic:first-consumer-ui-loop` names as outside this repository. I read that as named by the drafter, so it is not a finding.
- The initiative lists consumer gap 5 (a relative tolerance per key) under `epic:improvement-and-policy`, while `epic:observe-adopt-reject` ("an accepted value with an absolute or percent tolerance") and acceptance step 6 already deliver a percent tolerance. Not a defect of any story, but the initiative's mapping of gap 5 to a later release reads against it. The owner may want the initiative text aligned.
- Out of my lane, not counted: `story:ui-loop-acceptance` says the run "ends within 60 s" and is "one step of the 120 s budget", while `story:acceptance-in-gate` makes the whole test step include it (acceptance and parallel-safety critics). `story:acceptance-in-gate` and `story:changelog-release-procedure` both edit `CHANGELOG.md`; `story:cli-skeleton-validate` and `story:record-formats-in-spec` both touch `docs/design.md`-adjacent spec files, and the decomposition says who owns which (parallel-safety critic).

```findings
- file: .engineering/planning/epic/release-line.md
  line: 21
  category: scope
  severity: blocker
  verdict: needs-revision
  origin: introduced
  message: "the promise \"0.1.0 is released when the slice of `epic:observe-adopt-reject` is green on `main` with the acceptance run at 7 of 7\" (and Done when: the release 0.1.0 exists, authored by the bot, with archives and checksums) is claimed by no story: story:changelog-release-procedure delivers the changelog, the procedure and the workflow checks but not the release, and story:acceptance-in-gate only notes that 0.1.0 is cut afterwards; epic:first-consumer-ui-loop repeats the promise at line 33"
```
