---
format: aep.planning-md/3
id: story:prove-command-in-ratchet
kind: story
status: draft
title: ratchet prove runs the planted defects of a requirement and writes ratchet-proof/1
summary: 'The command part of story:prove-command: the run of each defect outside the working tree, the record, and unproven in the gate report.'
relations:
- decomposes: epic:improvement-and-policy
- depends_on: story:prove-command
- depends_on: story:cli-skeleton-validate
- depends_on: story:assess-command
- depends_on: story:evaluate-command
scope:
- confidence: inferred
  path: crates/ratchet-core
- confidence: inferred
  path: crates/ratchet/src/commands/prove.rs
- confidence: inferred
  path: crates/ratchet/tests/prove.rs
revision: 4
---
## Context

Split on 2026-11-26 from `story:prove-command`, which writes the file form of the proof record,
`ratchet-proof/1`, into `docs/evidence-format.md` § 12 and `spec/domains/evidence.yaml`. This
story holds the command: `ratchet prove`, declared in `spec/cli.yaml:111-117`, and the mark in
the gate report (`docs/design.md` § 4, `:516`).

## Acceptance

- In a fixture project with a requirement that declares one planted defect of each form
  (`inputs` and `patch`), `ratchet prove` exits 0 and writes a `ratchet-proof/1` record with
  both ids under `refused`, and exits 1 naming the id when the assessor accepts a defect; the
  working tree is unchanged after the run. Before the story the command answers
  `cli_handler_unavailable`.
- A gate report marks an enforced requirement with no proof record and no recorded fail as
  unproven.

## Notes

- Moved from the acceptance of `story:prove-command`.
- The story is a draft. It waits for the waves to 0.1.0: `story:cli-skeleton-validate`,
  `story:assess-command` and `story:evaluate-command`.
