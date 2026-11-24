---
format: aep.planning-md/3
id: review-result:parallel-safety-split-round-2
kind: review-result
status: active
title: parallel-safety critic on the split of story:cli-skeleton-validate, round 2
relations:
- reviews: story:workspace-cli-contract
- reviews: story:cli-skeleton-validate
revision: 1
---
needs-revision

One new finding, a warning, introduced by the correction. All six round-1 findings are fixed.

story:changelog-release-procedure — both this story and story:cli-skeleton-validate land on `AGENTS.md` (cited, both bodies and both typed scopes), and no `depends_on` edge and no sentence in either body orders them; round 1 had an edge from changelog-release-procedure to cli-skeleton-validate, and the correction replaced it with one to story:workspace-cli-contract, so the store now puts them in waves 3 and 4 only by its own collision rule (`collision: story:changelog-release-procedure story:cli-skeleton-validate AGENTS.md`). Remedies, without choosing: an edge between the two recording `AGENTS.md` as the reason, or splitting the file so they share none (the sections differ: § "Release" and the changelog rule here, the ownership-table rows and the regeneration text there) — .engineering/planning/story/changelog-release-procedure.md:56, .engineering/planning/story/cli-skeleton-validate.md:119

Round-1 findings, one by one:
- story:ui-loop-acceptance (the include of `acceptance/Taskfile.yml` is attributed to the wrong story): it now says `story:workspace-cli-contract` (ui-loop-acceptance.md:60). Order holds through its direct edge to cli-skeleton-validate, which depends on workspace-cli-contract. No longer holds.
- story:assess-command, story:evaluate-command, story:reference-adopt-command (the test module and wiring are attributed to "the skeleton"): each now names `story:workspace-cli-contract` for the test module and wiring, and cli-skeleton-validate for the dependencies (assess-command.md:55-57, evaluate-command.md:58-59, reference-adopt-command.md:58-59). Order holds transitively, and round 1 allowed "name the story or add the edge". No longer holds.
- story:workspace-cli-contract (`.github/workflows/` and `gate.yml`): the prose now says the job goes in `pages.yml`, because the classifier step and the path list are there (workspace-cli-contract.md:104-106). The typed scope lists `pages.yml` and no `gate.yml`. `pages.yml` exists and its classifier has the `code` class. No longer holds.
- story:cli-skeleton-validate (the invariants check lands in no named file): `crates/ratchet-core/tests/invariants.rs` and `tests/invariants/` are now in the Scope prose (cli-skeleton-validate.md:101-107). The typed scope `crates/ratchet-core` covers them. The wave 5 list files `assessor.txt` and `evidence.txt` match `spec/domains/assessor.yaml` and `spec/domains/evidence.yaml`. No longer holds.

Your questions:
1. Typed scope against `## Scope` prose:
   - cli-skeleton-validate matches: every prose path is under a typed path. `spec/`, `examples/`, `ratchet.toml` and `spec/README.md` are read only, and the only story that lands on the first three is the implemented `story:record-formats-in-spec`, which it depends on.
   - workspace-cli-contract matches: `.cargo`, `.config`, both `.github/scripts/check-generated*.sh` files, `pages.yml`, `.gitignore`, `AGENTS.md`, `Cargo.*`, `Taskfile.yml`, `crates/ratchet`, `crates/ratchet-cli-contract` and `rust-toolchain.toml`. Its read-only mentions are `acceptance/Taskfile.yml` (an optional include, created by ui-loop-acceptance), `spec/cli.yaml` and `spec/ess-inputs.yaml`.
2. Files the two stories share:
   - They share `Cargo.toml`, `Cargo.lock`, `Taskfile.yml`'s neighbours, `AGENTS.md`, `.github/scripts/check-generated.sh`, `crates/ratchet/Cargo.toml`, `src/commands/validate.rs`, `tests/validate.rs` and `tests/fixtures/validate`.
   - The `depends_on` edge from cli-skeleton-validate (line 11) orders them, and both bodies admit the sharing.
   - Wave 3 holds only changelog-release-procedure. Its edge to workspace-cli-contract is recorded, and so is `AGENTS.md` with workspace-cli-contract, but not `AGENTS.md` with cli-skeleton-validate (the finding above).
3. Waves 5 and 6:
   - No two stories in either wave land on a common file. Wave 5 is assessor-declaration, evidence-reader and reference-compare, each on its own modules, tests, fixtures and list file under `crates/ratchet-core`. Wave 6 is assess-command, evaluate-command, reference-adopt-command and ui-loop-acceptance; the first three each take one core module and one `commands/<name>.rs`, `tests/<name>.rs` and fixture directory, and ui-loop-acceptance takes `acceptance` and `ROADMAP.md`.
   - Every wave 5 story depends on cli-skeleton-validate, which owns the empty modules, `tests/main.rs` and the dependencies. Every wave 6 story keeps its edge to the wave 5 stories it reads.
   - The unlisted shared edits (`Cargo.*`, `tests/main.rs`, `commands/mod.rs`) are stated as "not edited". The convention for a dependency a later story needs is stated at cli-skeleton-validate.md:150-151.
4. Prose surfaces absent from the typed scope: none that a story lands on. The one candidate is `AGENTS.md` in story:acceptance-in-gate, which this critique does not count as a finding. See below.

What I read:
- 12 stories: workspace-cli-contract, cli-skeleton-validate, changelog-release-procedure, assessor-declaration, evidence-reader, reference-compare, assess-command, evaluate-command, reference-adopt-command, ui-loop-acceptance, acceptance-in-gate and release-0-1-0. Frontmatter for all, full body for the first 10, and the `git diff` of the 10 changed stories and the epic.
- The commands: `aep plan artifact show` on the round-1 record, `aep plan artifact waves --kind story`, `git diff`, `ls` of `.github/workflows`, `spec` and `spec/domains`, and grep of `pages.yml` and `Taskfile.yml`.
- Surfaces placed: 12 cited, 0 inferred, 0 unplaceable. `story:record-formats-in-spec` I did not read (implemented, outside the lane).
- Acceptance reads traced to a producer in the set: 17. Direct edges record 13. The other 4 are ordered only transitively: the `acceptance/Taskfile.yml` include read by ui-loop-acceptance, and the test module and wiring read by the three wave 6 commands, all from workspace-cli-contract. Order holds, because each reader depends on cli-skeleton-validate, which depends on workspace-cli-contract.

What I could not establish:
- `crates/ratchet-core/src/lib.rs` and the `commands` glue: whether wave 6 needs items made `pub` beyond the empty modules, since no body says.
- The file in `crates/ratchet` that implements the generated `Handler`: workspace-cli-contract names no file, and it is inside the claimed directory.
- Whether story:acceptance-in-gate edits `AGENTS.md`: its text names it only as a pointer (acceptance-in-gate.md:57). If it does, it is absent from its typed scope, and the edge from acceptance-in-gate to changelog-release-procedure orders it after both.
- Out of lane:
  - The workspace-cli-contract acceptance lists `validate::unavailable` as passing while cli-skeleton-validate replaces it. That is acceptance-critic ground.
  - cli-skeleton-validate is `active` on an approval recorded before the rewrite, while it now waits on an open owner question and depends on a `draft` story.

```findings
[
  {"file": ".engineering/planning/story/changelog-release-procedure.md", "line": 56, "category": "parallel-safety", "severity": "warning", "message": "both this story and story:cli-skeleton-validate (cli-skeleton-validate.md:119) land on AGENTS.md (cited); no depends_on edge or body sentence orders them since this story's edge moved from cli-skeleton-validate to story:workspace-cli-contract, so the waves keep them apart only by the store's collision rule; record AGENTS.md as the reason for an ordering edge or split the file between them"}
]
```
