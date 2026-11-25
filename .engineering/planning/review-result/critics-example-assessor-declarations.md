---
format: aep.planning-md/3
id: review-result:critics-example-assessor-declarations
kind: review-result
status: active
title: acceptance and scope critics on story:example-assessor-declarations, two rounds
relations:
- reviews: story:example-assessor-declarations
revision: 1
---
Recorded by the coordinator from the reports of two plan critics on
`story:example-assessor-declarations`, before its implementation: the acceptance critic and the
scope critic, two rounds each. The findings are in the critics' words, shortened; paths of the
workstation are left out.

## Round 1, story revision 4

Acceptance critic: needs-revision, six findings.

1. One sentence joined the declaration files and the test and never stated the passing state
   (exit 0, a count line), so a script that always fails would have met it.
2. "The message of its rule" was named for none of the rules; the unit codes and the wording
   for a scope are in `spec/presets.test.sh:1074-1080` and were not carried over.
3. The check of a measurement over `runs_of` stood only in a Note; read literally, the output
   rule failed the measurement `p90` of the `record-series@1` plan
   (`examples/ci-turnaround.ratchet.yaml:86-100`), and the exemption left its unit and scope
   unchecked, with no broken copy.
4. The state before the story, "the test fails for each of the five files", named no tree and
   did not ask the output to name each file; the case of no example file had no broken copy.
5. "A script test of the gate" could not be observed until `check:spec` runs the script
   (`Taskfile.yml:90-97`).
6. "A case that fails when the comparison is taken out" had no observable form;
   `spec/presets.test.sh` has message-judged cases, harness cases and a count line.

Scope critic: needs-revision, five findings.

1. The story said a later example adds its declarations under `examples/` and named
   `story:production-gate-spec-executed-service`, whose scope puts them in `presets/`; the
   acceptance looked an assessor up in `examples/quality/assessors/` only, while
   `examples/ratchet.toml` lists `presets` as a catalog source too.
2. The conditions of `command-timing@1` were tied to `story:cache-condition-one-name`; no plan
   of the examples uses a cache condition.
3. The epic's outcome asks for an answer in the design documents; the edit of
   `docs/evidence-format.md` was "also likely" and not a stated part of the story.
4. `ROADMAP.md` and the epic's § Order said the stories of the epic wait for the waves to
   0.1.0, while this story is taken ahead of them.
5. `story:example-release-quality` said it "shares the declarations" with this story while its
   scope claims the declaration of each assessor its example names (there before this story).

All eleven were taken into the story (revisions 5 and 6), into `story:example-release-quality`
(revision 7), into the epic (revision 5) and into `ROADMAP.md`.

## Round 2, story revision 6

Scope critic: approve, no finding.

Acceptance critic: needs-revision, one finding. With the lookup in `presets/` as a second
source, the script could exit 0 while `examples/quality/assessors/` is still absent: the
acceptance named the directory only in the state before the story. The critic gave the
sentence that closes it ("after the story `examples/quality/assessors/` holds the nine files
... and `presets/` holds none of them"); the story carries it from revision 7. No third read
was asked for: the sentence is the critic's own.

## Not established by the critics

- The message strings of the script, which does not exist yet.
- Whether `epic:format-gaps-second-format-consumer` is right that this story holds something
  of the second consumer's draft.
- Whether the files of `examples/quality/assessors/` should be checked against
  `ratchet.assessor.Assessor` key by key. The story lists it under what the script does not
  check.

```findings
- file: .engineering/planning/story/example-assessor-declarations.md
  category: acceptance
  severity: warning
  origin: introduced
  message: "the acceptance stated no passing state of the script"
- file: .engineering/planning/story/example-assessor-declarations.md
  category: acceptance
  severity: warning
  origin: introduced
  message: "the message of a rule was named for no rule"
- file: examples/ci-turnaround.ratchet.yaml
  line: 86
  category: acceptance
  severity: warning
  origin: introduced
  message: "the measurement over runs_of was checked by a Note only and had no broken copy"
- file: .engineering/planning/story/example-assessor-declarations.md
  category: acceptance
  severity: warning
  origin: introduced
  message: "the state before the story named no tree and no line per file; no case for a directory without an example"
- file: Taskfile.yml
  line: 90
  category: acceptance
  severity: warning
  origin: introduced
  message: "the acceptance did not say that check:spec runs the script"
- file: .engineering/planning/story/example-assessor-declarations.md
  category: acceptance
  severity: warning
  origin: introduced
  message: "the proof that the comparison is live had no observable form"
- file: .engineering/planning/story/example-assessor-declarations.md
  category: scope
  severity: blocker
  origin: introduced
  message: "an assessor was looked up in examples/quality/assessors/ only, while a later story puts its declarations in presets/"
- file: .engineering/planning/story/example-assessor-declarations.md
  category: scope
  severity: warning
  origin: introduced
  message: "the conditions of command-timing@1 were tied to a story on a cache condition no example uses"
- file: docs/evidence-format.md
  line: 688
  category: scope
  severity: warning
  origin: introduced
  message: "the design-document answer of the epic's outcome was not a stated part of the story"
- file: ROADMAP.md
  line: 103
  category: scope
  severity: warning
  origin: introduced
  message: "ROADMAP.md and the epic's Order said the story waits for the waves to 0.1.0"
- file: .engineering/planning/story/example-release-quality.md
  line: 61
  category: scope
  severity: warning
  origin: pre-existing
  message: "the story said it shares the declarations with story:example-assessor-declarations while its scope claims them"
- file: .engineering/planning/story/example-assessor-declarations.md
  category: acceptance
  severity: warning
  origin: introduced
  message: "round 2: with presets/ as a second source the acceptance did not state that examples/quality/assessors/ holds the nine files after the story"
```
