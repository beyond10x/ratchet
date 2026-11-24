---
format: aep.planning-md/3
id: review-result:design-split-round-2
kind: review-result
status: active
title: design critic on the split of story:cli-skeleton-validate, round 2
relations:
- reviews: story:workspace-cli-contract
- reviews: story:cli-skeleton-validate
revision: 1
---
needs-revision

Both round-1 blockers of my lane are closed. One warning remains in the second story, and it is small.

story:cli-skeleton-validate — the Context says the body is amended with the owner's answer "and with it the notes of `story:evidence-reader`, `story:reference-compare` and `story:assessor-declaration` that name the decoders", but only evidence-reader's body names the decoders (and it now says it is amended with the answer). A grep for `decod` and `ratchet-model` in reference-compare and assessor-declaration finds nothing, so two of the three amendments point at no text; name evidence-reader alone, or name the place in the other two that reads the model — .engineering/planning/story/cli-skeleton-validate.md:61

Round-1 findings of my lane:
- Workspace holding a second package with its own `[workspace]` table (blocker): resolved.
  - The second story states that it follows the mechanism `AGENTS.md` records for `crates/ratchet-cli-contract` (`cli-skeleton-validate.md:90`).
  - The first story is given the AGENTS.md duty of recording that mechanism "so the next generated crate is held the same way" (`workspace-cli-contract.md:108`).
  - The seam is now one record the first story writes and the second reads. Nothing in either body contradicts the other.
- Drift-check script written for one crate (blocker): resolved.
  - `check-generated.sh` holds one line per crate, and `check-generated.test.sh` reads the same lines and runs its case once per line (`workspace-cli-contract.md:88-93`).
  - The second story adds a line and says the script test is "not edited" (`cli-skeleton-validate.md:117`, `:156`). It does not rewrite what the first wrote.
- Feature unification through `serde_json/arbitrary_precision` (warning): resolved. The note at `cli-skeleton-validate.md:~141` runs the first story's tests with the model crate in the build and fixes a test whose answer changes.
- Evidence-reader presupposing decoders and crediting "the skeleton" with the SHA-256 dependency (warning): resolved for evidence-reader (`evidence-reader.md:62-66`). The part that is still open is the finding above, about the amendment list.
- Downstream bodies naming the wrong producer (warning): resolved.
  - ui-loop-acceptance (`:61`), assess-command (`:56`), evaluate-command, reference-adopt-command, assessor-declaration, reference-compare and evidence-reader now name the producing story.
  - The one place left that is not marked is assessor-declaration (`:35`), which says "After `story:cli-skeleton-validate`" about the command's behaviour. That is correct as written.
- changelog-release-procedure edge to the held story (warning): resolved. It now has `depends_on story:workspace-cli-contract`. The state it reads is all the first story's: the workspace version, `rust-toolchain.toml` and `task check:scripts`. A stub binary stands in for the `ratchet` binary, and the body says it touches no crate.

New from the corrections:
- Cycles: none. I walked every `depends_on` edge (the stories' own edges, plus the epic edges outside the set). The chain is record-formats-in-spec, workspace-cli-contract, cli-skeleton-validate, the library stories, the command stories, acceptance-in-gate and release-0-1-0. changelog-release-procedure hangs off workspace-cli-contract and feeds acceptance-in-gate and release-0-1-0.
- Two stories owning one surface: none. The shared files are `Cargo.toml`, `Cargo.lock`, `AGENTS.md` and `check-generated.sh`. Each has a different owner for each part, and the `depends_on` edge orders the pair. This is the ordering trade-off, not a split abstraction. The seam in `crates/ratchet` is the intended replace-in-place: the first story writes `validate.rs` and the `validate::unavailable` test, and the second replaces both. The first story's acceptance is judged at its own merge commit (`workspace-cli-contract.md:112`).
- `story:cli-skeleton-validate` is the only story whose dependents wait on the owner's question. Nothing in the first story or in changelog-release-procedure waits on it.

What I read: 15 artifacts. `story:workspace-cli-contract` and `story:cli-skeleton-validate` in full, `review-result:design-split-round-1`, the diff of the 10 modified store files, and the dependent stories' dependency and decoder lines. Commands: `aep plan artifact relations`, `graph`, `waves --kind story`, `validate` (valid), `git status` and `git diff`, `grep`. The graph and waves came from the full store, so I walked outside the set. I traced 9 acceptance reads to producers in the set, and a `depends_on` edge records all 9:
- Second story: `check-generated.test.sh` and `task check:generated` (the first story), the `validate::unavailable` test (the first story), and `examples/*.ratchet.yaml` and `spec/domains` (record-formats-in-spec).
- First story: `spec/cli.yaml` (record-formats-in-spec).
- changelog-release-procedure: the workspace version, `rust-toolchain.toml` and `check:scripts` (the first story).
- The optional `acceptance` include reads nothing a sibling must produce.

What I could not establish:
- Whether Cargo accepts the mechanism the first story will record (a path dependency carrying its own `[workspace]` table). I ran no build, so I could not test it. The seam is sound whichever mechanism is chosen, because the second story only follows the record.
- Whether `check:rust` (`fmt` and `clippy -D warnings`) passes on a generated crate that is never edited. If it fails for the model crate, the second story has no place to fix it, because it does not list `Taskfile.yml`. This was open in round 1 and the answer depends on the first story's mechanism.
- Out of my lane, for the acceptance and parallel-safety critics:
  - The Red-first note at `cli-skeleton-validate.md:135-136` says the case of `check-generated.test.sh` for the new line fails before the code exists. That case is derived from the line, so before the line exists there is no case to fail.
  - changelog-release-procedure and cli-skeleton-validate both edit `AGENTS.md`, with no edge between them. The waves put them in waves 3 and 4, but `aep plan artifact waves` lists the collision.
- These do not set my verdict; only the one finding above does.

```findings
[
  {"file": ".engineering/planning/story/cli-skeleton-validate.md", "line": 61, "category": "design", "severity": "warning", "message": "the body says it amends, with the owner's answer, the notes of evidence-reader, reference-compare and assessor-declaration that name the decoders, but only evidence-reader's body names them; the other two hold no such note, so list evidence-reader alone or name where the other two read the model"}
]
```
