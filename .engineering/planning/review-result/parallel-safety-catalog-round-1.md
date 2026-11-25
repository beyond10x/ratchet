---
format: aep.planning-md/3
id: review-result:parallel-safety-catalog-round-1
kind: review-result
status: active
title: parallel-safety critic on the preset catalog drafts, round 1
relations:
- reviews: epic:preset-catalog
revision: 1
---
Recorded by the coordinator from the critic's report on `epic:preset-catalog` and its four draft stories, verbatim except that absolute paths of the workstation are replaced by `<tree>` and `<scratch>`.

needs-revision

Findings:
1. story:preset-catalog-functional — its `CHANGELOG.md` line (`.engineering/planning/story/preset-catalog-functional.md:71`) targets a file that does not exist; `story:changelog-release-procedure` (active) creates it (`changelog-release-procedure.md:45`), and `story:release-0-1-0` cuts `## [0.1.0]` from the same section (`release-0-1-0.md:45`). No `depends_on` runs to either. Close it with an edge to `story:changelog-release-procedure` that names the file as the reason, or leave the changelog out of this story. Cited; the file is not there yet.
2. story:preset-catalog-functional — it edits `Taskfile.yml` (`:63`) and the `AGENTS.md` § "Ownership" table (`:70`). `story:acceptance-in-gate` edits `Taskfile.yml` (`acceptance-in-gate.md:53`) and the same ownership table (`:57`). `story:cli-skeleton-validate` also adds rows to that table. The epic says the set "changes none of" the 0.1.0 waves (`.engineering/planning/epic/preset-catalog.md:95`), and the draft names no one of these files as shared. Close it with ordering edges recording the shared files, or by placing the `presets/` row and the `check:spec` command so the two stories do not share lines. Cited, both bodies.
3. story:preset-catalog-functional — it edits `spec/domains/specification.yaml` and `spec/domains/config.yaml` (`:64`), and neither the recorded scope nor the prose says what that does to the generated model. `story:cli-skeleton-validate` makes `crates/ratchet-model` from those domains, guards it with `.github/scripts/check-generated.sh`, and adds `crates/ratchet-core/tests/invariants/specification.txt` for invariants. A new file-name rule in those domains can fail the drift check or the invariants test, so it can land on files the story does not list. Close it by recording that the rule adds no type or invariant, or by naming those files in the scope. Inferred, so a weaker claim.
4. story:preset-catalog-runtime — its `CHANGELOG.md` line (`.engineering/planning/story/preset-catalog-runtime.md:41`) has the same unrecorded relation to `story:changelog-release-procedure` and `story:release-0-1-0` as finding 1. It also collides on `CHANGELOG.md` with `story:preset-catalog-factory` (`.engineering/planning/story/preset-catalog-factory.md:36`), and neither body mentions the other. `aep plan artifact waves --kind story --status draft` orders them (factory in wave 3, runtime in wave 4) only because of the shared files, and no edge records the order. Close it with an edge between them naming `CHANGELOG.md`, or by dropping the changelog line from one. Cited. The `presets/` directory claim is not a collision, because the pages are distinct files.
5. story:preset-catalog-factory — its `CHANGELOG.md` line (`:36`) has the same unrecorded relation to `story:changelog-release-procedure` and `story:release-0-1-0` as finding 1. Close it with the same edge, or by dropping the line.
6. story:preset-binding-resolution — its recorded scope is `crates/ratchet/src/commands/validate.rs` and `crates/ratchet/tests/validate.rs` (`.engineering/planning/story/preset-binding-resolution.md:49`). `story:cli-skeleton-validate` puts the spec reader and the `validate` report in `crates/ratchet-core`, and `story:assessor-declaration` puts catalog-source resolution in `crates/ratchet-core/src/assessor.rs` and `validate.rs`. Resolving a preset digest and inputs, and reading the `presets` key, most likely edits `crates/ratchet-core/src/` too. The body only says it "uses what that story built" (`:63`). The scope looks narrower than the work. Close it by naming the `crates/ratchet-core` files it changes, or by saying the resolution lives wholly in the command file. Inferred.
7. story:preset-binding-resolution — it shares `CHANGELOG.md` (`:56`) and `presets/README.md` (`:54`) with `story:preset-catalog-factory` and `story:preset-catalog-runtime`. The recorded scope of those two is the whole `presets` directory, and the prose of neither lists the README. Only the edge to `story:preset-catalog-functional` exists. Close it with edges from the binding story to both, or by moving the "what validate prints" text out of `presets/README.md`. Cited.

Recorded scope against `## Scope` prose:
- The recorded scopes and the prose lists match for all four stories (functional 10 of 10, runtime 3 of 3, factory 2 of 2, binding 6 of 6). The disagreements are in what both leave out (findings 3 and 6) and in the epic sentence at `epic/preset-catalog.md:95` (finding 2).

What I read: 5 draft artifacts, 11 active stories and the epic, with `aep plan artifact show` for each, `aep plan artifact waves --kind story --status draft`, `--status active`, `list --kind story`, and the body text of `changelog-release-procedure`, `release-0-1-0`, `acceptance-in-gate` and `cli-skeleton-validate`.

Surfaces: 4 stories placed cited, 0 only inferred, 0 unplaceable. Two inferred surfaces are added in findings 3 and 6. No story is unassessed. Acceptance reads traced to a producer in the set: 4 (runtime and factory read `spec/presets.test.sh` and `presets/`, binding reads `presets/`, binding reads `ratchet validate`). All 4 are recorded by an edge; the `ratchet validate` read is only transitive, through `story:release-0-1-0` to `story:acceptance-in-gate`, `story:ui-loop-acceptance` and `story:cli-skeleton-validate`.

What I could not establish:
- Whether the file-name rule changes the generated model (finding 3). Only the owner of the generator can say.
- Draft-only waves put `story:preset-binding-resolution` in wave 2, ahead of factory and runtime. They ignore its `depends_on story:release-0-1-0`, which is active. The edge is correct, but a runner reading only that listing is misled.
- Out of my lane: the runtime story's conditional test case "when `story:preset-catalog-functional` did not add it" makes the check order-dependent. That is for the acceptance critic.

```findings
- file: .engineering/planning/story/preset-catalog-functional.md
  line: 71
  category: parallel-safety
  severity: blocker
  verdict: needs-revision
  origin: introduced
  message: "CHANGELOG.md does not exist yet; story:changelog-release-procedure creates it and story:release-0-1-0 cuts its Unreleased section; no depends_on edge records either relation"
- file: .engineering/planning/story/preset-catalog-functional.md
  line: 63
  category: parallel-safety
  severity: warning
  verdict: needs-revision
  origin: introduced
  message: "Taskfile.yml (:63) and the AGENTS.md ownership table (:70) are also edited by story:acceptance-in-gate and story:cli-skeleton-validate; neither body nor the epic's 'changes none of them' says so, and no ordering edge records it"
- file: .engineering/planning/story/preset-catalog-functional.md
  line: 64
  category: parallel-safety
  severity: warning
  verdict: needs-revision
  origin: introduced
  message: "edits spec/domains/*.yaml that story:cli-skeleton-validate generates crates/ratchet-model from (drift check, invariants list files); the scope names none of those files. Inferred surface."
- file: .engineering/planning/story/preset-catalog-runtime.md
  line: 41
  category: parallel-safety
  severity: blocker
  verdict: needs-revision
  origin: introduced
  message: "CHANGELOG.md is shared with story:preset-catalog-factory (no edge, bodies silent) and with story:changelog-release-procedure and story:release-0-1-0 (no edge)"
- file: .engineering/planning/story/preset-catalog-factory.md
  line: 36
  category: parallel-safety
  severity: warning
  verdict: needs-revision
  origin: introduced
  message: "CHANGELOG.md does not exist yet and is created by story:changelog-release-procedure and cut by story:release-0-1-0; no depends_on edge records either relation"
- file: .engineering/planning/story/preset-binding-resolution.md
  line: 49
  category: parallel-safety
  severity: warning
  verdict: needs-revision
  origin: introduced
  message: "recorded scope omits crates/ratchet-core, where story:cli-skeleton-validate and story:assessor-declaration put the spec reader, validate report and catalog resolution that a binding needs; the scope looks narrower than the work. Inferred surface."
- file: .engineering/planning/story/preset-binding-resolution.md
  line: 54
  category: parallel-safety
  severity: warning
  verdict: needs-revision
  origin: introduced
  message: "presets/README.md and CHANGELOG.md are shared with story:preset-catalog-factory and story:preset-catalog-runtime, and no edge orders them; only the edge to story:preset-catalog-functional exists"
```
