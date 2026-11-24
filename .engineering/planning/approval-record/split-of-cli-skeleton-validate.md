---
format: aep.planning-md/3
id: approval-record:split-of-cli-skeleton-validate
kind: approval-record
status: approved
title: story:cli-skeleton-validate is split; story:workspace-cli-contract is accepted as wave 2
relations:
- decides: story:workspace-cli-contract
- decides: story:cli-skeleton-validate
- decides: story:changelog-release-procedure
revision: 2
transitions:
- {from: "draft", to: "approved", at: "2026-11-24T18:13:29Z", actor: "agent:ratchet", revision: 2}
---
## Decision

`story:cli-skeleton-validate` is split in two. `story:workspace-cli-contract` holds what one open
question to the owner does not change: the workspace, the pinned compiler, the generated command
surface with its drift check, the binary whose 16 commands answer "unavailable", the gate tasks
and the CI job. It is accepted for implementation as wave 2. `story:cli-skeleton-validate` keeps
the model crate, `ratchet-core` and `ratchet validate`, and starts when the owner has answered
which generated crate holds the model.

`story:changelog-release-procedure` now depends on `story:workspace-cli-contract` and no longer on
`story:cli-skeleton-validate`: it reads the workspace version, `rust-toolchain.toml` and
`task check:scripts`, and touches no crate. It is wave 3, and it does not wait on the question.

`aep plan artifact waves --kind story` derives eight waves from the store after the split (53
collisions, 0 unassessed), and `ROADMAP.md` lists them.

## On whose word

- The operator session of the workstation, 2026-11-24 19:03 CET, about the open question: "Wave 2
  parts that do not depend on the decoder may start; say which ones do, in one line."
- `approval-record:stories-to-0-1-0` accepted the unsplit story. This record changes how its work
  is cut, and adds no outcome the epic does not name.
- The workspace rule "Goal first": a story starts implementation as soon as its critics approve
  it.

## What the critics said

- Round 1: four verdicts `needs-revision`, 20 findings, 2 of them blockers (how the root
  workspace holds a second generated package that carries its own `[workspace]` table; a drift
  check written for one crate). All 20 are recorded as fixed (`review-result:*-split-round-1`).
- Round 2, the last: four verdicts `needs-revision`, 8 findings, all warnings
  (`review-result:*-split-round-2`). The design critic found both blockers closed. The 8 are
  recorded as fixed: the acceptance of `story:workspace-cli-contract` names the four gate steps,
  a script that checks the test budget, and the compiler channel in the CI log; the acceptance of
  `story:cli-skeleton-validate` gains a refusal case for `schema_violation` and for
  `unresolved_reference` and the invariants test; an edge orders the two stories that edit
  `AGENTS.md`.
- No critic read the fixes made after round 2: the panel has two rounds.
- One remark outside a critic's lane was taken as well: `check:rust` formats and lints the
  hand-written crates only, because a generated crate is never edited.

## Commits this record authorises

For `story:workspace-cli-contract`: the story's commits, the closing store commit, and a pull
request to `main` merged through the bot. No tag and no release.
