---
format: aep.planning-md/3
id: story:prove-command
kind: story
status: draft
title: 'ratchet prove: run the planted defects of a requirement'
relations:
- decomposes: epic:improvement-and-policy
revision: 1
---
## Context

Found by a consumer writing a `ratchet/1` file at 0.0.3: `ratchet prove` is not built.

A requirement can declare planted defects (`spec/domains/specification.yaml:1008`), and
`ratchet prove` runs the assessment once per defect, never in the working tree, and expects the
verdict fail; the proof record holds the ids refused and accepted, and a gate report marks an
enforced requirement with no proof record and no recorded fail as unproven
(`docs/design.md:516`, `:741`). `spec/cli.yaml:111-117` declares the command with
`ratchet.cli.ProveInput` (`spec/domains/cli.yaml:502`). The binary answers
`cli_handler_unavailable` (`crates/ratchet/src/commands/mod.rs:41-47`), and
`epic:observe-adopt-reject` leaves it to a later epic that no story names.

## Acceptance

- In a fixture project with a requirement that declares one planted defect of each form
  (`inputs` and `patch`), `ratchet prove` exits 0 and records both ids as refused, and exits 1
  naming the id when the assessor accepts a defect; the working tree is unchanged after the
  run. Before the story the command answers `cli_handler_unavailable`.
- A gate report marks an enforced requirement with no proof record and no recorded fail as
  unproven.
- The command waits for the waves to 0.1.0 (`ratchet assess`, `ratchet evaluate`).

## Notes

- The proof record has no field list yet (`docs/evidence-format.md` § 9, "The other records");
  the story declares it in `spec/` first.
- Filed under `epic:improvement-and-policy` as the closest epic: the next after 0.1.0 and the
  one that extends the gate report. No epic names `ratchet prove`.
- Related: `story:assess-command`, `story:evaluate-command`.
