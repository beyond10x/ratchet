---
format: aep.planning-md/3
id: review-result:acceptance-split-round-1
kind: review-result
status: active
title: acceptance critic on the split of story:cli-skeleton-validate, round 1
relations:
- reviews: story:workspace-cli-contract
- reviews: story:cli-skeleton-validate
revision: 1
---
needs-revision

All findings are warnings. Neither story has a blocker.

**Your two direct questions**

- **`story:workspace-cli-contract` without the model crate:** yes, its acceptance can go green with no model crate and no answer to the open question. Nothing in its acceptance, scope or notes names `crates/ratchet-model` or `ratchet-core`, and line 112 excludes both. I ran `ess generate cli --path spec --binding spec/cli.yaml --out <scratch>` with the installed `ess`. It wrote 10 artifacts as a package `ratchet-cli-contract`. That package depends on `clap`, `serde`, `serde_json` and a few others, with no model crate. It ships `UnavailableHandler` (`src/runtime.rs:77`) and carries its own `[workspace]`. The 12 is also right: 16 commands in `spec/cli.yaml`, minus `validate`, `assess`, `reference adopt` and `evaluate`.
- **`story:cli-skeleton-validate` under either answer:**
  - It is checkable under both generator answers.
  - The tests (`validate::accepts_valid_project`, `validate::reports_duplicate_id`) observe only exit status, `valid: true` and code `spec_invalid`. `ratchet.cli.ValidationReport` has `valid` (`spec/domains/cli.yaml:183`).
  - The byte-flip case names `crates/ratchet-model/`, and line 78 says that directory holds either generator's output.
  - If the answer is to wait for ESS to emit decoders, the story does not start, so there is nothing to judge.
  - The one input the tests need is unnamed (finding 4).

**Findings**

- `story:workspace-cli-contract` — "its output lists as passed … the script `.github/scripts/check-generated.test.sh`": a shell script has no passed-test line. The existing `*.test.sh` scripts in `Taskfile.yml` print nothing of the sort. The acceptance should name the task step that runs it and its exit status — `.engineering/planning/story/workspace-cli-contract.md:66-73`
- `story:workspace-cli-contract` — the acceptance never names the text or exit status of the unavailable answer. The check compares the binary with "the generated adapter's unavailable answer", and the notes only say the story reports the text (line 103). That is circular. Name the expected exit status, or the literal the test compares against — `.engineering/planning/story/workspace-cli-contract.md:66-70`
- `story:workspace-cli-contract` — the summary and scope promise the CI job and `rust-toolchain.toml`, and the notes promise the nextest 60 s limit. The acceptance observes none of them, so the story can be closed with a CI job that does not run. It needs a statement, or a split, that a person can see pass: a workflow run on a `code` change, or a `task check:ci-paths` case for the new job — `.engineering/planning/story/workspace-cli-contract.md:7`, `:91-92`, `:98-102`
- `story:cli-skeleton-validate` — `validate::accepts_valid_project` names no project. "Exit 0, `valid: true`" passes on any fixture, including a trivial one. Name the fixture, or move `validate::accepts_examples` (line 115, currently only in Notes) into the acceptance — `.engineering/planning/story/cli-skeleton-validate.md:69-71`, `:115-116`
- `story:cli-skeleton-validate` — its dependency `story:workspace-cli-contract` names `validate::unavailable` in its acceptance (`workspace-cli-contract.md:69`). This story's tests replace that test (`cli-skeleton-validate.md:87-89`), so the contract story's acceptance is checkable only at its own merge point. One sentence in either story saying the contract story's acceptance is judged at its merge commit would make the dependency checkable — `.engineering/planning/story/cli-skeleton-validate.md:87-89`

**Read:** both ids, the whole body of each, with the `origin/main` version of `cli-skeleton-validate`. I also read `AGENTS.md`, `Taskfile.yml`, `spec/cli.yaml`, `spec/domains/cli.yaml` and `ROADMAP.md`. I generated the CLI package once in a scratch directory and deleted it afterwards.

**Could not establish:**
- Whether the generated package's own `[workspace]` table lets it sit under a root workspace. That is the story's own report item (line 104) and sits outside acceptance.
- The literal unavailable text and exit status, because I did not build the binary.
- Whether the `ess generate synthesize` and `ess generate types` commands have a `--check` mode. The help output matched `--check` once and I did not attribute it. Scope allows a byte comparison either way.

**Out of my lane:** the cross-story edit of `.github/scripts/check-generated.test.sh` (the contract story creates it, the skeleton story adds a case) is for parallel-safety. Whether the 12/4 command split matches wave scope is for scope.

```findings
[
{"file":".engineering/planning/story/workspace-cli-contract.md","line":66,"category":"acceptance","severity":"warning","message":"Acceptance says the output 'lists as passed' the script check-generated.test.sh; a shell script has no passed-test line, so name the task step that runs it and its exit status."},
{"file":".engineering/planning/story/workspace-cli-contract.md","line":68,"category":"acceptance","severity":"warning","message":"The unavailable answer is the oracle ('the generated adapter's unavailable answer and exits with its status') but its text and exit status are not named, only reported at line 103; the check is circular."},
{"file":".engineering/planning/story/workspace-cli-contract.md","line":91,"category":"acceptance","severity":"warning","message":"Scope and summary promise the CI job, rust-toolchain.toml and the nextest 60 s bound (lines 7, 91-92, 98-102); the acceptance observes none of them, so the story can close with a CI job that does not run."},
{"file":".engineering/planning/story/cli-skeleton-validate.md","line":70,"category":"acceptance","severity":"warning","message":"validate::accepts_valid_project names no project; exit 0 with valid: true passes on any trivial fixture. Name the fixture or put validate::accepts_examples (line 115, Notes only) into the acceptance."},
{"file":".engineering/planning/story/cli-skeleton-validate.md","line":87,"category":"acceptance","severity":"warning","message":"This story replaces validate::unavailable, which the dependency's acceptance names (workspace-cli-contract.md:69); the contract story's acceptance holds only at its own merge commit, and neither story says so."}
]
```
