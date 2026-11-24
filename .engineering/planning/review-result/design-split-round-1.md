---
format: aep.planning-md/3
id: review-result:design-split-round-1
kind: review-result
status: active
title: design critic on the split of story:cli-skeleton-validate, round 1
relations:
- reviews: story:workspace-cli-contract
- reviews: story:cli-skeleton-validate
revision: 1
---
needs-revision

The split holds. I found no cycle, no surface both stories own, and no missing edge. Five edits are still needed. Two are blockers, in the model-crate seam: the root workspace layout and the script that tests the drift check. The other three are warnings about stale or over-coupled downstream bodies.

Findings:

story:cli-skeleton-validate — its scope adds `crates/ratchet-model/` and edits `Cargo.toml`, but it does not say how the workspace holds a package with its own `[workspace]` table. I measured that `ess generate types` and `ess generate synthesize` both emit `[workspace]` in the crate's `Cargo.toml`, as `ess generate cli` does. A member glob over `crates/` would then fail with "multiple workspace roots". The first story only promises to report its mechanism (`workspace-cli-contract.md:60`, and the "reports how the workspace holds a generated package" note), so the second must state it follows that mechanism for `ratchet-model`. The seam is the root `Cargo.toml` members/exclude lines. — .engineering/planning/story/cli-skeleton-validate.md:90, .engineering/planning/story/workspace-cli-contract.md:60

story:workspace-cli-contract — it asks for `check:generated` to take a second crate as one more entry (line 88), but it gives the same property to no other edited file. The second story adds a case to `.github/scripts/check-generated.test.sh`, a script the first writes (line 90). The first story's acceptance names one generated file, one case. The body should say the script takes the generated crate (and its check command) as a table entry or argument, so the second story adds a row and does not rewrite the script. A body that writes the script for one crate leaves a hard rewrite at the seam. — .engineering/planning/story/workspace-cli-contract.md:88, .engineering/planning/story/cli-skeleton-validate.md:96

story:cli-skeleton-validate — if the answer is `ess generate types`, the crate's default feature `exact-numbers` turns on `serde_json/arbitrary_precision`. Cargo unifies features across the build, so that setting reaches `ratchet-cli-contract` and the `ratchet` binary the first story gates (`unavailable` answers, JSON output). The body should say the story re-runs the first story's tests with the crate in the build, or states the choice that avoids it. This is a warning, because only one of the three options does it. — .engineering/planning/story/cli-skeleton-validate.md:50 (the `types` option is described at lines 50-56)

story:evidence-reader — it presupposes "the generated decoders of `crates/ratchet-model`", but the open owner question exists because the `synthesize` option holds no typed decoder. It also credits "the skeleton" with the SHA-256 dependency, which the second story now owns. Answering the question changes the downstream bodies. The second story's body (line 59) promises to amend only itself. The downstream bodies need the same amendment, or the second story must list them. Same wording in `reference-compare.md:58`. — .engineering/planning/story/evidence-reader.md:62, .engineering/planning/story/cli-skeleton-validate.md:58

story:ui-loop-acceptance — it names `story:cli-skeleton-validate` as the story that added the `acceptance` include of the root `Taskfile.yml`. That include is now `story:workspace-cli-contract`'s (`workspace-cli-contract.md:84-85`). The edge is recorded only through the other story. "The skeleton declared the test module, wired the command" in `assess-command.md:56` (also `evaluate-command.md`, `reference-adopt-command.md`, `assessor-declaration.md:60`) now spans two stories: the first wired the commands and declared the test modules, the second declared the dependencies. Name the producer in each. — .engineering/planning/story/ui-loop-acceptance.md:61, .engineering/planning/story/assess-command.md:56

story:changelog-release-procedure — it declares `depends_on story:cli-skeleton-validate`, the story held behind the owner's question. What it reads is the first story's: the workspace version in `Cargo.toml`, `rust-toolchain.toml` (line 80), `task check:scripts` (line 64), and it says it "touches no crate" (line 81). After the split its edge should go to `story:workspace-cli-contract`, so it is no longer held by the owner's question. This is a warning, because the current edge is also true, only wider than needed. — .engineering/planning/story/changelog-release-procedure.md:10

Edges and reads checked:
- Of the 8 stories that build on the pair, every one reaches `story:workspace-cli-contract` through `story:cli-skeleton-validate`. The first story's outputs are the binary's command files and test modules, the Taskfile include, the toolchain pin and the `check:generated` and `check:scripts` tasks. Each downstream read is covered by a path, so no edge is missing.
- The graph has no cycle. `cli-skeleton-validate` depends on `workspace-cli-contract` and `record-formats-in-spec`; `workspace-cli-contract` depends on `record-formats-in-spec` only. The chain is the intended one, with the owner's question gating the second story and nothing else.
- Waves show `workspace-cli-contract` in wave 2 and `cli-skeleton-validate` in wave 3. The five collisions between the pair are ordered by the edge (`Cargo.toml`, `Cargo.lock`, `Taskfile.yml`, `AGENTS.md`, `check-generated.test.sh`). The shared files are an ordering trade-off, not a split abstraction. The binary files (`crates/ratchet/src/commands/validate.rs`, `tests/validate.rs`, `Cargo.toml`) are named in the second story's scope, and the test `validate::unavailable` is replaced there, so that seam holds.

What I read: 13 stories, plus the 8 dependents' bodies and the original `cli-skeleton-validate` from `origin/main`. Commands: `aep plan artifact list --kind story`, `graph`, `waves --kind story`, `relations`, `show` on both stories, `validate`, `ess generate cli/types/synthesize` into a scratch directory (since removed), `git show origin/main:...`, `grep`.

What I could not establish:
- Whether `check:rust` (`fmt` and `clippy -D warnings`) passes on the generated crates. It is outside the two bodies, so I cannot say whether the model crate trips it.
- Whether the invariant-coverage check (`cli-skeleton-validate.md:119-121`) has a file location in the scope. That is acceptance or parallel-safety lane, not mine.
- I did not trace acceptance reads of the other 8 stories beyond the lines cited above; 6 reads were traced, all recorded by path.

```findings
[
  {"file": ".engineering/planning/story/cli-skeleton-validate.md", "line": 90, "category": "design", "severity": "blocker", "verdict": "needs-revision", "origin": "introduced", "message": "the body adds crates/ratchet-model to the workspace but does not say how the root Cargo.toml holds a package that carries its own [workspace] table (both ess generate types and synthesize emit one); it should follow the mechanism workspace-cli-contract reports"},
  {"file": ".engineering/planning/story/workspace-cli-contract.md", "line": 88, "category": "design", "severity": "blocker", "verdict": "needs-revision", "origin": "introduced", "message": "check:generated is written so a second crate is one more entry, but check-generated.test.sh (line 90) is not given the same property, so the second story's added case may rewrite a script the first wrote for one crate"},
  {"file": ".engineering/planning/story/cli-skeleton-validate.md", "line": 50, "category": "design", "severity": "warning", "verdict": "needs-revision", "origin": "introduced", "message": "the ess generate types option has the default feature exact-numbers (serde_json/arbitrary_precision), which unifies into ratchet-cli-contract and the ratchet binary the first story gates; the body does not say the first story's tests are re-run with the crate in the build"},
  {"file": ".engineering/planning/story/evidence-reader.md", "line": 62, "category": "design", "severity": "warning", "verdict": "needs-revision", "origin": "introduced", "message": "the body presupposes generated decoders in crates/ratchet-model, which is the open owner question, and credits 'the skeleton' with the SHA-256 dependency; cli-skeleton-validate.md:58 amends only its own body when answered; reference-compare.md:58 has the same wording"},
  {"file": ".engineering/planning/story/ui-loop-acceptance.md", "line": 61, "category": "design", "severity": "warning", "verdict": "needs-revision", "origin": "introduced", "message": "the body names story:cli-skeleton-validate as the source of the acceptance include of Taskfile.yml, which workspace-cli-contract now owns; assess-command.md:56, evaluate-command.md, reference-adopt-command.md and assessor-declaration.md:60 write 'the skeleton' for what the two stories now split"},
  {"file": ".engineering/planning/story/changelog-release-procedure.md", "line": 10, "category": "design", "severity": "warning", "verdict": "needs-revision", "origin": "introduced", "message": "depends_on story:cli-skeleton-validate, held by the owner's open question, while the story reads only workspace-cli-contract outputs (workspace version, rust-toolchain.toml, check:scripts) and touches no crate; the edge should run to story:workspace-cli-contract"}
]
```
