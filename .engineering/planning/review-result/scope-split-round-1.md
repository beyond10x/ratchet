---
format: aep.planning-md/3
id: review-result:scope-split-round-1
kind: review-result
status: active
title: scope critic on the split of story:cli-skeleton-validate, round 1
relations:
- reviews: story:workspace-cli-contract
- reviews: story:cli-skeleton-validate
revision: 1
---
needs-revision

The split holds: every outcome and scope line of the old story lands in exactly one of the two stories, nothing is reach beyond the parent, and no later story's expectation is left without an owner. Three stale or dropped lines still need fixing.

- `epic:runnable-cli` — "Done when" names only `story:record-formats-in-spec` and `story:cli-skeleton-validate`, and "the workspace is generated from it once (`story:cli-skeleton-validate`)" now points at the wrong story. The workspace and the generated CLI crate belong to `story:workspace-cli-contract`, which decomposes the epic but is named nowhere in its text. Name both stories in both sentences. — .engineering/planning/epic/runnable-cli.md:29 and :33
- `story:ui-loop-acceptance` — it says the root `Taskfile.yml` includes `acceptance/Taskfile.yml` "since `story:cli-skeleton-validate`". The optional include is now in `story:workspace-cli-contract`'s `Taskfile.yml` scope, so the owner named here is wrong. — .engineering/planning/story/ui-loop-acceptance.md:61
- `story:cli-skeleton-validate` — the old note "`check:generated` and its script test are gate steps outside the test step. The story times both and reports the two times" was kept only by the first story. The second story adds a second generator (`ess generate types` or `synthesize`) to `check:generated`, and `AGENTS.md` requires timing a generator before and after such a change. Its notes now carry only "No cargo test calls `ess`", so the timing of the model generation has no owner. Add the timing and report to its notes. — .engineering/planning/story/cli-skeleton-validate.md:117-118

**Coverage of the old story**
- **Acceptance.** The `validate` tests and the one-byte drift script are split cleanly. The script case for a generated file goes to `story:workspace-cli-contract` (`workspace-cli-contract.md:66-73`). The script case for `crates/ratchet-model/` goes to `story:cli-skeleton-validate` (`cli-skeleton-validate.md:69-74`).
- **Overlapping files.** `Cargo.toml`, `Cargo.lock`, `Taskfile.yml`, `AGENTS.md`, `check-generated.test.sh` and `crates/ratchet/` are in both scopes, but the lines each story owns are disjoint and the `depends_on` edge orders them.
- **Test modules.** The `ratchet-core` test modules, the empty modules and the whole-slice dependencies are in the second story only. The `crates/ratchet` test modules and `src/commands/mod.rs` wiring are in the first story only.
- **`validate` content.** The `validate` checks and the invariant-test note are in the second story only. The CI job, toolchain pin, nextest budget, ruleset note and the `ess`/`aep` pinning are in the first story only.
- **Later-story expectations.** Every file, module, test module and dependency that `evidence-reader`, `assessor-declaration`, `reference-compare`, `assess-command`, `reference-adopt-command` and `evaluate-command` expect to find has an owner. Their phrase "the skeleton declared…" is now ambiguous between the two stories, but each item is still covered.
- **`validate::unavailable`.** The first story creates it and the second story replaces it, so no file is edited by two stories at once.

**Parent**
- **Reach beyond the parent.** The note `validate::accepts_examples` (`cli-skeleton-validate.md:115-116`) is new relative to the old story and is in no acceptance line. It traces to the parent's "run `ratchet validate` on its `ratchet/1` documents", so I do not count it as reach.
- **Model generator question.** The open question about which generator produces the model is the owner's. The drafter named it as unresolved, so it is not a gap.

**What I read:** 12 artifacts and the old story's text from git. I ran `aep plan artifact show` for the epic, both stories and the eight dependants, plus `aep plan artifact graph`. I also read `spec/cli.yaml` and `spec/README.md:207`, the `record-formats-in-spec` body, and the line-numbered files under `.engineering/planning`.

**Parent promises:** I extracted 8 and traced all 8 to an item. They are: install the binary and run `ratchet validate`; the other commands answer "unavailable"; a Rust workspace; a pinned toolchain; the test step within budget; a drift check for every generated file; a CI job running the same gate; generated once from the specification.

**Not established**
- **Workspace version:** the old story did not say who sets the workspace version that `changelog-release-procedure` reads. Neither new story does either, so this is unchanged.
- **Out of my lane:** `story:cli-skeleton-validate` is `active` while it waits on an open question and on a `draft` dependency. That is for the design critic.
- **Out of my lane:** the second story's `ratchet-core` empty modules and whole-slice dependencies wait on the open question although they do not depend on the model crate. That is a question of how the work was divided.

```findings
[
  {"file": ".engineering/planning/epic/runnable-cli.md", "line": 29, "category": "scope", "severity": "warning", "message": "the epic names story:cli-skeleton-validate as the one that generates the workspace and lists only two stories in \"Done when\" (:33); the workspace, the generated CLI crate and the gate belong to story:workspace-cli-contract, which decomposes the epic and is named nowhere in its text"},
  {"file": ".engineering/planning/story/ui-loop-acceptance.md", "line": 61, "category": "scope", "severity": "warning", "message": "the body says the root Taskfile includes acceptance/Taskfile.yml \"since story:cli-skeleton-validate\"; that include is now in story:workspace-cli-contract's Taskfile.yml scope, so the named owner is wrong"},
  {"file": ".engineering/planning/story/cli-skeleton-validate.md", "line": 117, "category": "scope", "severity": "warning", "message": "the old note that check:generated and its script test are timed and the two times reported is kept only by story:workspace-cli-contract; this story adds a second generator to check:generated and its notes no longer say it is timed or reported"}
]
```
