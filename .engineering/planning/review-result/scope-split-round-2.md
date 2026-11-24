---
format: aep.planning-md/3
id: review-result:scope-split-round-2
kind: review-result
status: active
title: scope critic on the split of story:cli-skeleton-validate, round 2
relations:
- reviews: story:workspace-cli-contract
- reviews: story:cli-skeleton-validate
revision: 1
---
needs-revision

story:record-formats-in-spec — "`story:cli-skeleton-validate` then generates once" names one story as the generator, but the generation is now split: story:workspace-cli-contract generates `crates/ratchet-cli-contract` first and story:cli-skeleton-validate generates only the model crate; the pointer should name both stories (same kind of stale owner as round-1 finding 2) — .engineering/planning/story/record-formats-in-spec.md:71

Round-1 findings of this lane:
- Epic "Done when" and "generated once" named only story:cli-skeleton-validate. Resolved. Both sentences now name story:record-formats-in-spec, story:workspace-cli-contract and story:cli-skeleton-validate, with the split of workspace and command surface versus model crate (epic runnable-cli.md:29-30, :34-35).
- ui-loop-acceptance named the wrong owner of the optional Taskfile include. Resolved. It now says "since `story:workspace-cli-contract`" (ui-loop-acceptance.md:61).
- Timing of the model generation had no owner. Resolved. story:cli-skeleton-validate notes carry "times `task check:generated` and `check-generated.test.sh` before and after the line of `crates/ratchet-model/` and reports the four times; a jump is fixed here" (cli-skeleton-validate.md:139-140). The workspace story keeps its own two-time note (workspace-cli-contract.md:119-122).
- Round-1 "not established": the workspace version. Still not set by either story, and still not a gap, because story:changelog-release-procedure sets the workspace version itself in its release commit (changelog-release-procedure.md:68-69).

New from the corrections: nothing is reach beyond the parent or the pre-split story.
- `validate::accepts_examples` is now an acceptance bullet; it traces to the epic's "run `ratchet validate` on its `ratchet/1` documents", and the five `examples/*.ratchet.yaml` exist.
- The `invariants` test machinery (list files per domain) elaborates the pre-split note about comparing declared invariants with the tests that break them. It is not an epic promise, but the pre-split story carried it. evidence-reader and assessor-declaration now each add one list file and no longer "report how they compare the lists". That moves the claim to the second story without duplicating it.
- The cargo feature-unification note follows from the split and adds no new outcome.
- No two items claim one outcome. The four `<command>::unavailable` tests and `commands::unbuilt_commands_answer_unavailable` are in the workspace story, and the second story replaces only `validate::unavailable`. The 12 unbuilt commands plus validate, assess, reference-adopt and evaluate make the 16 of `spec/cli.yaml`.
- `.github/workflows/gate.yml` in the old scope became `pages.yml`. That file exists and holds the classifier and path list; `gate.yml` does not exist.

Promise check: I extracted 9 promises from the epic and traced all 9 to an item.
1. Run `ratchet validate` on `ratchet/1` documents: second story.
2. Every other command answers "unavailable": workspace story.
3. A Rust workspace: workspace story.
4. A pinned toolchain: workspace story.
5. A test step within budget: both stories' notes.
6. A drift check for every generated file: workspace story builds it, and the second story adds the model line.
7. A CI job that runs the same gate: workspace story.
8. The specification changes first and alone, then is generated once: record-formats-in-spec, then the two stories.
9. "Done when" lists three stories: now correct.

"Install the binary" is claimed here only as far as building the `ratchet` binary. Packaging and install instructions sit in story:changelog-release-procedure and story:release-0-1-0, outside this set, so it is covered elsewhere.

Every promise of the pre-split story (acceptance, scope, notes) lands in exactly one of the two. Overlapping paths (`Cargo.toml`, `Cargo.lock`, `AGENTS.md`, `check-generated.sh`, `crates/ratchet`) are split by line and ordered by the new `depends_on` edge.

What I read: the epic; both stories whole; the pre-split story from git; round 1 of this lane; the diffs of the nine other changed planning files; `spec/cli.yaml` and the `ValidateInput` type; `Taskfile.yml` and `.github/workflows`; and the planning-wide references to both story ids. I ran `aep plan artifact graph`. I ran no generator, build or test.

I could not establish whether `ess generate cli` produces exactly the answer the workspace acceptance pins (exit 1, `cli_handler_unavailable` on stderr). I ran no generator; the story cites the generated source and has a stop-and-report note.

Out of my lane, not counted in the verdict:
- The second story's `invariants` test sits in the notes and not in the acceptance (acceptance critic).
- The `ratchet-core` empty modules and whole-slice dependencies wait on the open model question although they do not depend on the model crate (design and division).
- Overlap of the `crates/ratchet` scope between the stories (parallel-safety).

```findings
[
  {"file": ".engineering/planning/story/record-formats-in-spec.md", "line": 71, "category": "scope", "severity": "warning", "message": "\"`story:cli-skeleton-validate` then generates once\" names a single generating story; after the split story:workspace-cli-contract generates crates/ratchet-cli-contract and story:cli-skeleton-validate generates only crates/ratchet-model, so the owner named here is incomplete"}
]
```
