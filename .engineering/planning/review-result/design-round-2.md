---
format: aep.planning-md/3
id: review-result:design-round-2
kind: review-result
status: active
title: design critic, round 2
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
revision: 1
---
needs-revision
story:acceptance-in-gate — its acceptance compares `docs/getting-started.md` with "the transcript the acceptance run writes", but no story of the set makes the run write one: story:ui-loop-acceptance prints only an `ok` or `FAIL` line per step and a count line, and its scope (`acceptance/ui-loop/`, `acceptance/Taskfile.yml`, `ROADMAP.md`) is not edited by acceptance-in-gate. Close it with the transcript (command and output per step, to a named file) in story:ui-loop-acceptance's acceptance and scope, or add `acceptance/` to story:acceptance-in-gate's scope. Either way the reader keeps its existing edge to the producer, `depends_on story:ui-loop-acceptance` — .engineering/planning/story/acceptance-in-gate.md:45, .engineering/planning/story/ui-loop-acceptance.md:30

Round-1 findings (all five resolved; none repeated as findings):
1. `story:cli-skeleton-validate` -> `story:record-formats-in-spec` edge: resolved. `depends_on` is in the graph and the skeleton's Context says both generators run once on the final specification.
2. record-formats note vs "no generated file": resolved. The note now says "no Rust and no generated file in the tree" and the skeleton generates once.
3. Ownership of § 8 items 5, 13 and 25: resolved. gate.yaml (item 5), specification.yaml (item 13), spec/cli.yaml and spec/domains/cli.yaml (item 25) are all in record-formats' scope. Later stories carry "No specification file changes here", and `spec/domains/gate.yaml` already holds `reference_missing` and `coverage_below_plan`.
4. reference-adopt refusals: resolved. `requirement_without_reference` is a record-formats decision (4) and the adopt story cites it. The other refusals it tests exist in `spec/cli.yaml`, and `ValidationCode` already holds the assessor codes.
5. ui-loop-acceptance -> assessor-declaration: resolved. `depends_on` edges to assessor-declaration and record-formats are recorded; it sits in wave 4 and acceptance-in-gate in wave 5.

What I read: all 12 stories whole, the `design-round-1` verdict, `relations`, `graph` and `waves --kind story`. I read `validate` too; it reports valid, so nothing from it is mine. I walked every declared edge in the store, including those to the four epics, the other five epics of the initiative and the review-result nodes. The `depends_on` edges are acyclic and the 6 waves are 1, 1, 4, 4, 1, 1. The record-formats, skeleton, fan-out, acceptance-in-gate, release chain is justified in the bodies: the digest of the whole specification is in every generated file, and the Taskfile, `CHANGELOG.md` and `ROADMAP.md` collisions in `waves` are ordered by edges. Wave 3 is four parallel stories, so the set is not a queue. I traced roughly 30 acceptance reads to a producer in the set (documents, fixtures, the `release-verify.sh` that release-0-1-0 runs, the `reference` and `store` modules, the `assessor` declarations, the command binary). Every one has a `depends_on` edge except the transcript above. ui-loop-acceptance steps 2 to 7 read commands built in the same wave with no edge. That is by design: it states "prints the count the merged commands reach" and acceptance-in-gate waits for all three commands, so I do not count it. I checked the spec sources (`spec/cli.yaml`, `spec/domains/gate.yaml`, `spec/domains/cli.yaml`, `docs/evidence-format.md` § 5, 8) for a command acceptance that needs a name no story adds. I found none.

What I could not establish:
- Whether ESS 0.98 synthesises the new record formats (§ 8 items 15, 16, 24 are "from ESS"). Only the synthesis run after record-formats shows it, and that check sits in record-formats' own acceptance.
- Out of my lane, for the acceptance critic: record-formats' acceptance line asks for the "0 refused" synthesis, which depends on the three `shorthand:` removals.
- For the parallel-safety critic: the directory-level `crates` scope of the skeleton collides with every later per-file scope in `waves`. The edge to the skeleton orders them.
- An unease, not a finding: decision 7 of record-formats ("if the list has none, declare `evidence_missing`") is conditional. The cause may already exist in `spec/domains/gate.yaml`, so the story may be a no-op there.

```findings
- file: .engineering/planning/story/acceptance-in-gate.md
  line: 45
  category: design
  severity: blocker
  verdict: needs-revision
  origin: introduced
  message: "its acceptance reads the transcript the acceptance run writes (getting-started.test.sh compares the page's command and output blocks with it), but story:ui-loop-acceptance, the producer, prints only ok or FAIL per step and a count line (ui-loop-acceptance.md:30) and no story's scope makes run.sh write a transcript; add the transcript file to ui-loop-acceptance's acceptance and scope, or add acceptance/ to acceptance-in-gate's scope; the edge to story:ui-loop-acceptance already exists"
```
