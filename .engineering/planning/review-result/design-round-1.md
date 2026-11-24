---
format: aep.planning-md/3
id: review-result:design-round-1
kind: review-result
status: active
title: design critic, round 1
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
story:cli-skeleton-validate — its acceptance (generated drift check, `ratchet validate` on fixtures) reads the specification that story:record-formats-in-spec rewrites in wave 1, and its "0 refused" synthesis measurement was taken at 7673482 before those edits, so a depends_on edge from it to story:record-formats-in-spec is needed; this makes the generators run once on the final spec and matches the stated intent "spec changes before generated files exist on main" — .engineering/planning/story/cli-skeleton-validate.md:53, .engineering/planning/story/record-formats-in-spec.md:60 and aep plan artifact graph (no edge between the two)
story:record-formats-in-spec — its note says whichever wave-1 story merges second regenerates `crates/ratchet-model/`, but its scope and acceptance say "no generated file", so the seam between the two wave-1 stories is open; with the edge above the note becomes "spec only, generated once by skeleton" — .engineering/planning/story/record-formats-in-spec.md:60 and :48-53
story:record-formats-in-spec — docs/evidence-format.md § 8 items 5 (split VerdictCause, spec/domains/gate.yaml), 13 (TargetKind `document`, specification.yaml) and 25 (`assess` in spec/cli.yaml) are specification changes that no story's scope makes (this story reports item 13 "not made", skeleton lists specification.yaml only for the shorthands), yet story:evidence-reader's acceptance reads the § 6 example whose `target.kind` is `document`, which `TargetKind` (variants revision, build, deployment, workflow_run, telemetry_population) rejects; this story must own items 5 and 13 (add gate.yaml and the TargetKind line to its scope, ordered before skeleton by the edge above, which also covers the shared specification.yaml) and say who makes item 25, otherwise a later wave rewrites the generated crates, against the one-spec-owner-per-wave design — .engineering/planning/story/record-formats-in-spec.md:65-66, docs/evidence-format.md:286-294, :535-580, spec/domains/specification.yaml:211-213, spec/domains/gate.yaml:32-54, .engineering/planning/story/evidence-reader.md:38
story:reference-adopt-command — its acceptance demands "a declared refusal" for a requirement that has no `reference` and (note) for a reference already present, but `reference-adopt` in spec/cli.yaml declares only unknown_requirement, no_qualifying_evidence, not_better, gain_not_shown, unnamed_regression, so the story needs a spec/cli.yaml change in wave 3 (which rewrites both generated crates beside story:assess-command and story:evaluate-command) unless the refusals are mapped to those names or the new names move into story:record-formats-in-spec or story:assessor-declaration; the body names neither — .engineering/planning/story/reference-adopt-command.md:36, spec/cli.yaml:80-87
story:ui-loop-acceptance — its fixture uses `quality/assessors/ui-loop@1.assessor.yaml` and a catalog source, which is the file form story:assessor-declaration decides, and its step 1 ("`ratchet validate` accepts the fixture project") reads validate behaviour that story:assessor-declaration extends to check the plan against the declaration, so in wave 2 the merge order decides whether step 1 passes; add a depends_on edge from it to story:assessor-declaration (it moves to wave 3, still before story:acceptance-in-gate) — .engineering/planning/story/ui-loop-acceptance.md:34 and :48, .engineering/planning/story/assessor-declaration.md (Decision taken with this story), aep plan artifact graph

What I read: 11 stories, 3 of 9 epics' edges via `aep plan artifact show` on each story, `aep plan artifact relations`, `graph` (49 edges walked, including the edges to epics and the initiative outside the set; no cycle found, depends_on edges are acyclic, 4 waves), `waves --kind story`, `validate` (reports valid); plus spec/domains/{specification,gate,config,assessor}.yaml, spec/cli.yaml, docs/evidence-format.md § 4, 6, 8, 10 and the Taskfile. Acceptance reads traced to a producer in the set: 14, of which 11 have a depends_on edge; the 3 without are the ones in findings 1, 3 and 5 (spec read by skeleton, `document` read by evidence-reader through record-formats, declaration form read by ui-loop-acceptance).

What I could not establish:
- Whether ESS 0.98 synthesises a Rust crate from the new evidence.yaml and assessor.yaml (items 15, 16, 24 of § 8 are "from ESS", for example rejecting an unknown member in `evidence` but ignoring one in `run`); only a generation run after record-formats-in-spec shows it, and the edge in finding 1 puts that check inside skeleton's acceptance.
- Out of my lane, for the acceptance critic: story:reference-adopt-command's acceptance says a second call with unchanged evidence writes the same bytes, while its note says a command with a reference present refuses (reference-adopt-command.md:35 vs :51). For the parallel-safety critic: the 34 collisions of `waves` are all the skeleton's directory-level `crates` scope against later per-file scopes, plus docs/design.md (skeleton, assessor-declaration, evaluate-command) and AGENTS.md, Taskfile.yml, ROADMAP.md, CHANGELOG.md, which edges already order.
- An unease, not a finding: story:reference-compare decides the two readings (reference_missing and coverage_below_plan per item) while story:evaluate-command writes them into docs/design.md § 5 (reference-compare.md Notes), so the design text lags the code by one wave; the plan chose this to keep docs/design.md out of wave 2.

```findings
- file: .engineering/planning/story/cli-skeleton-validate.md
  line: 53
  category: design
  severity: blocker
  verdict: needs-revision
  origin: introduced
  message: "its acceptance (generated drift check, validate on fixtures) reads the specification that story:record-formats-in-spec rewrites in wave 1 and its synthesis measurement predates those edits, so a depends_on edge from it to story:record-formats-in-spec is needed; the generators then run once on the final spec"
- file: .engineering/planning/story/record-formats-in-spec.md
  line: 60
  category: design
  severity: warning
  verdict: needs-revision
  origin: introduced
  message: "the note says whichever wave-1 story merges second regenerates crates/ratchet-model, but the scope and acceptance say no generated file; with the edge from skeleton the note becomes spec only, generated once by skeleton"
- file: .engineering/planning/story/record-formats-in-spec.md
  line: 65
  category: design
  severity: blocker
  verdict: needs-revision
  origin: introduced
  message: "docs/evidence-format.md section 8 items 5 (VerdictCause split in gate.yaml), 13 (TargetKind document in specification.yaml) and 25 (assess in spec/cli.yaml) are specification changes no story's scope makes, while story:evidence-reader's acceptance reads the section 6 example with target kind document; the story must own items 5 and 13 and name the owner of item 25"
- file: .engineering/planning/story/reference-adopt-command.md
  line: 36
  category: design
  severity: blocker
  verdict: needs-revision
  origin: introduced
  message: "its acceptance demands a declared refusal for a requirement with no reference and for a reference already present, but spec/cli.yaml declares neither for reference-adopt, so a wave-3 specification change rewrites both generated crates; map the refusals to declared names or move the new names to a spec-owning story of an earlier wave"
- file: .engineering/planning/story/ui-loop-acceptance.md
  line: 34
  category: design
  severity: blocker
  verdict: needs-revision
  origin: introduced
  message: "its fixture uses the assessor declaration file form story:assessor-declaration decides and its step 1 reads validate behaviour that story extends, so wave-2 merge order decides whether step 1 passes; add a depends_on edge from it to story:assessor-declaration"
```
