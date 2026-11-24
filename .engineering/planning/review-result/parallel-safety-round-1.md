---
format: aep.planning-md/3
id: review-result:parallel-safety-round-1
kind: review-result
status: active
title: parallel-safety critic, round 1
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
story:evidence-reader — it, story:assessor-declaration and story:reference-compare each add a `mod` line to `crates/ratchet-core/tests/main.rs` (modules `evidence`/`store`, `assessor`, `compare`/`reference`) and none lists or mentions that file; the skeleton pre-creates only the `src` modules, so three wave-2 stories write one file (cited by workspace rule, file not yet existing); remedy either an ordering edge recording `tests/main.rs` as the reason, or the skeleton pre-creates the test modules so each story edits only its own file — .engineering/planning/story/evidence-reader.md:49, .engineering/planning/story/cli-skeleton-validate.md:85
story:assess-command — it, story:evaluate-command and story:reference-adopt-command each add a `mod` line to `crates/ratchet/tests/main.rs` (modules `assess`, `evaluate`, `reference_adopt`) and no body names that file, so three wave-3 stories write one file (cited by workspace rule, file not yet existing); remedy either an ordering edge with the file as reason, or the skeleton pre-creates the test modules — .engineering/planning/story/assess-command.md:45, .engineering/planning/story/evaluate-command.md:51, .engineering/planning/story/reference-adopt-command.md:43
story:evidence-reader — it and story:reference-compare both add a dependency (SHA-256 for the record id and evidence digest; a decimal type for exact tolerance arithmetic) so both edit `crates/ratchet-core/Cargo.toml` and the workspace `Cargo.lock`, which neither scope lists, and the generated model crate has no dependencies to supply them (inferred from the nouns SHA-256 and "decimal type"); remedy either an ordering edge with `Cargo.toml`/`Cargo.lock` as the reason, or the skeleton declares the shared dependencies up front — .engineering/planning/story/evidence-reader.md:32, .engineering/planning/story/reference-compare.md:51
story:assess-command — it and story:evaluate-command likely add dependencies in wave 3 (assess starts a child with a time limit; evaluate reads a git revision and builds a fixture git repository), so both edit `Cargo.toml`/`Cargo.lock`, which neither scope lists (inferred from the nouns "time limit" and "trusted revision"); remedy either an ordering edge with the manifest files as the reason, or the skeleton declares them up front — .engineering/planning/story/assess-command.md:41, .engineering/planning/story/evaluate-command.md:51
story:changelog-release-procedure — its AGENTS.md rule that every change adds a line under `## [Unreleased]` makes each later story (story:assess-command, story:evaluate-command, story:reference-adopt-command in wave 3) edit the same `CHANGELOG.md` section, and none of their scopes lists `CHANGELOG.md`; remedy either an ordering edge with the changelog as the reason, or the rule says the lines are batched in one story (story:acceptance-in-gate already holds `CHANGELOG.md`) — .engineering/planning/story/changelog-release-procedure.md:43, .engineering/planning/story/assess-command.md:39
story:assessor-declaration — its spec change to `spec/domains/config.yaml` rewrites the digest in every generated file, so `crates/ratchet-cli-contract` is regenerated too, yet the scope and Notes name only `crates/ratchet-model`, and the `validate.rs` edit ("adds one call there") is absent from the typed scope; remedy either list both generated crates and `validate.rs` in scope, or split the regeneration into the skeleton's drift step — .engineering/planning/story/assessor-declaration.md:66, .engineering/planning/story/assessor-declaration.md:70
story:record-formats-in-spec — it is "specification only, no generated file" with no `crates/` in its typed scope, yet any `spec/` change rewrites both generated crates in story:cli-skeleton-validate's surface (wave 1, same wave), and its note names only `crates/ratchet-model/`, not `crates/ratchet-cli-contract/`; remedy either an ordering edge recording the generated crates as the reason, or name both crates and the regeneration in scope — .engineering/planning/story/record-formats-in-spec.md:59
story:ui-loop-acceptance — its fixture writes `ratchet.toml` with a catalog source, `quality/assessors/ui-loop@1.assessor.yaml` and prepared `ratchet-evidence/1` documents, and step 1 (`ratchet validate`) reads them, while the lookup form (`<name>@<version>.assessor.yaml` under `[catalog] sources`) is decided by story:assessor-declaration and the document fields by story:record-formats-in-spec, both in the same wave or earlier, with only a `depends_on` edge to story:cli-skeleton-validate; the missing edges are from story:ui-loop-acceptance to story:assessor-declaration and to story:record-formats-in-spec (reader beside producer) — .engineering/planning/story/ui-loop-acceptance.md:48, .engineering/planning/story/assessor-declaration.md:43

What I read: 11 stories (`aep plan artifact show` for each, `aep plan artifact waves --kind story`), the specification tree (`spec/domains/*.yaml` for the shorthand location), `Taskfile.yml` and `.github/` for existing files, and the story files under `.engineering/planning/story/` for line numbers.
Surfaces: 11 of 11 items placed from cited bodies, 0 placed only by inference, 0 unplaceable. Two of the findings (the `Cargo.toml`/`Cargo.lock` pairs) rest on inferred surfaces, as marked. Acceptance reads traced to a producer in the set: 24, of which 19 have a `depends_on` edge. The other 5 are the 2 gaps in the last finding and 3 commands that story:ui-loop-acceptance reads before they exist, which that body states as the expected failing state, so I do not count them as defects.
Not established or not flagged: (a) the wave-1 pair story:cli-skeleton-validate and story:record-formats-in-spec has no shared hand-written file (the shorthands are all in `spec/domains/specification.yaml`, owned by the skeleton), so only the generated-crate finding applies to it; (b) story:evaluate-command's fixtures (recorded evidence, a reference) are hand-written while story:assess-command and story:reference-adopt-command produce the same state in the same wave with no edge, which I left unflagged because the formats are owned by upstream stories with edges; (c) out of my lane: the skeleton's typed scope is the whole `crates` directory and its acceptance sentence says "No test calls `ess`" beside a drift test, left to the design and acceptance critics; (d) I could not tell whether the skeleton's per-command files pre-wire the `Handler` dispatch, so I report no collision on `crates/ratchet/src/commands/`.

```findings
- file: .engineering/planning/story/evidence-reader.md
  line: 49
  category: parallel-safety
  severity: blocker
  verdict: needs-revision
  origin: introduced
  message: "story:evidence-reader, story:assessor-declaration and story:reference-compare each add a mod line to crates/ratchet-core/tests/main.rs and none names that file; the skeleton pre-creates only the src modules, so three wave-2 stories write one file (file not yet existing); remedy: ordering edge recording the file as reason, or the skeleton pre-creates the test modules"
- file: .engineering/planning/story/assess-command.md
  line: 45
  category: parallel-safety
  severity: blocker
  verdict: needs-revision
  origin: introduced
  message: "story:assess-command, story:evaluate-command and story:reference-adopt-command each add a mod line to crates/ratchet/tests/main.rs and no body names it, so three wave-3 stories write one file (file not yet existing); remedy: ordering edge recording the file as reason, or the skeleton pre-creates the test modules"
- file: .engineering/planning/story/evidence-reader.md
  line: 32
  category: parallel-safety
  severity: warning
  verdict: needs-revision
  origin: introduced
  message: "inferred surface: story:evidence-reader (SHA-256) and story:reference-compare (decimal type) each add a dependency, so both edit crates/ratchet-core/Cargo.toml and Cargo.lock, which neither scope lists; remedy: ordering edge with the manifest files as reason, or the skeleton declares the shared dependencies up front"
- file: .engineering/planning/story/assess-command.md
  line: 41
  category: parallel-safety
  severity: warning
  verdict: needs-revision
  origin: introduced
  message: "inferred surface: story:assess-command (child process with a time limit) and story:evaluate-command (git read of the trusted revision) likely add dependencies in wave 3, so both edit Cargo.toml and Cargo.lock, which neither scope lists; remedy: ordering edge with the manifest files as reason, or the skeleton declares them up front"
- file: .engineering/planning/story/changelog-release-procedure.md
  line: 43
  category: parallel-safety
  severity: blocker
  verdict: needs-revision
  origin: introduced
  message: "the AGENTS.md rule that every change adds a line under ## [Unreleased] makes story:assess-command, story:evaluate-command and story:reference-adopt-command each edit CHANGELOG.md in wave 3, and none lists it in scope; remedy: ordering edge with the changelog as reason, or batch the lines in story:acceptance-in-gate, which already holds CHANGELOG.md"
- file: .engineering/planning/story/assessor-declaration.md
  line: 66
  category: parallel-safety
  severity: warning
  verdict: needs-revision
  origin: introduced
  message: "a spec/ change rewrites the contract digest in every generated file, so crates/ratchet-cli-contract is regenerated as well, yet scope and Notes name only crates/ratchet-model; the crates/ratchet-core/src/validate.rs edit (line 70) is also missing from the typed scope; remedy: list both generated crates and validate.rs, or split the regeneration out"
- file: .engineering/planning/story/record-formats-in-spec.md
  line: 59
  category: parallel-safety
  severity: warning
  verdict: needs-revision
  origin: introduced
  message: "the story is declared specification-only with no crates/ in scope, yet any spec/ change rewrites both generated crates in story:cli-skeleton-validate's surface in the same wave, and the note names only crates/ratchet-model, not crates/ratchet-cli-contract; remedy: ordering edge recording the generated crates as reason, or name both crates and the regeneration in scope"
- file: .engineering/planning/story/ui-loop-acceptance.md
  line: 48
  category: parallel-safety
  severity: blocker
  verdict: needs-revision
  origin: introduced
  message: "its fixture and step 1 read a catalog source, an assessor declaration file and evidence documents whose lookup form is decided by story:assessor-declaration (same wave) and whose fields by story:record-formats-in-spec, with a depends_on edge only to story:cli-skeleton-validate; the edges to story:assessor-declaration and story:record-formats-in-spec are missing (reader beside producer)"
```
