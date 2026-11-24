---
format: aep.planning-md/3
id: review-result:scope-round-2
kind: review-result
status: active
title: scope critic, round 2
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
- reviews: story:release-0-1-0
- reviews: epic:release-line
- reviews: epic:first-consumer-ui-loop
- reviews: epic:observe-adopt-reject
- reviews: epic:runnable-cli
revision: 1
---
approve

What I read: 18 artifacts with `aep plan artifact show` — `initiative:first-milestone`, the 4 decomposed epics, the 12 stories, `review-result:scope-round-1`, and `epic:improvement-and-policy` for its exclusions. I also read `vision.md` § "First milestone" and, in `spec/cli.yaml` and `docs/evidence-format.md` § 10, the lines that bear on `assess --report`, the exit-status table and the declaration. I read the parents' bodies first and listed their promises before reading any story. I extracted 34 promises from the four epics and the initiative's 0.1.0 list and traced all 34 to a story. No story reaches into a "Not in this slice" or "Not in this epic" item, and no two stories claim the same outcome.

Round 1: resolved. `story:release-0-1-0` now claims "0.1.0 is released when the slice … is green on `main` with the acceptance run at 7 of 7" and the "Done when" clause (release authored by the bot, archives and checksums attached). Its acceptance is `release-verify.sh 0.1.0` against the published release, and it depends on `story:acceptance-in-gate` and `story:changelog-release-procedure`. The revision is consistent across the set:
- 0.1.0 now includes the tightening form of `reference adopt` and a percent tolerance, claimed by `story:reference-adopt-command` and `story:reference-compare`.
- The stale-reference fail and the rounding rule are excluded in the epic, the stories and `epic:improvement-and-policy` alike.
- Unbuilt commands return the generated adapter's "unavailable" answer, claimed by `story:cli-skeleton-validate` (3 stubs plus 1 shared function for the other 12).
- `story:record-formats-in-spec` owns every specification change.

What I could not establish:
- The refusal `requirement_without_reference` for `reference-propose` (decision 4 of `story:record-formats-in-spec`) touches a command that "Not in this slice" excludes. It is only a specification declaration, and the generated adapter answers "unavailable" for that command. I read it as keeping the two adopt/propose refusals aligned and did not count it as a finding.
- `story:acceptance-in-gate` writes the `CHANGELOG.md` lines and the `README.md` § "Status" for stories of three epics. `epic:first-consumer-ui-loop` does not name either. The content is traceable to `epic:release-line` ("What 0.1.0 holds"). I treated this as how the promises were divided, which is outside my lane, so it is not a finding.
- `story:reference-compare` makes an incomplete result with `at_least` above an upper limit a fail. `epic:observe-adopt-reject` says a run that did not complete is insufficient evidence. The fail rule is in `docs/evidence-format.md` §5 (U6/E6), so I did not count it. The epic sentence could mention the exception.
- Out of my lane, not counted: several stories edit `ROADMAP.md` and `CHANGELOG.md` (parallel-safety critic).

```findings
[]
```
