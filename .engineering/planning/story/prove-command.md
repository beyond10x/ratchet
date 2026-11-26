---
format: aep.planning-md/3
id: story:prove-command
kind: story
status: draft
title: 'ratchet prove: run the planted defects of a requirement'
relations:
- decomposes: epic:improvement-and-policy
scope:
- confidence: cited
  path: CHANGELOG.md
- confidence: cited
  path: docs/design.md
- confidence: cited
  path: docs/evidence-format.md
- confidence: cited
  path: spec/README.md
- confidence: cited
  path: spec/domains/evidence.yaml
- confidence: cited
  path: spec/gate-inputs.test.sh
- confidence: cited
  path: spec/record-examples.test.sh
- confidence: cited
  path: spec/record-fields.test.sh
- confidence: cited
  path: spec/record-types.test.sh
revision: 11
---
## Context

Found by a consumer writing a `ratchet/1` file at 0.0.3: `ratchet prove` is not built.

What the formats say at the wave's base, `7b01ea1`:

- A requirement can declare planted defects (`ratchet.specification.QualityRequirement`,
  `spec/domains/specification.yaml:975-1025`). `ratchet prove` runs the assessment once per
  defect, never in the working tree, and expects the verdict fail; the proof record holds the
  ids refused and accepted, and a gate report marks an enforced requirement with no proof
  record and no recorded fail as unproven (`docs/design.md` § 4, `:516`; § 5 "Proposed CLI",
  `:741`; § 6, the row "Proof", `:772`).
- `spec/cli.yaml:111-117` declares the command with `ratchet.cli.ProveInput`
  (`spec/domains/cli.yaml`). The binary answers `cli_handler_unavailable`
  (`crates/ratchet/src/commands/mod.rs`), and `epic:observe-adopt-reject` leaves it to a later
  epic that no story names.
- `ratchet.evidence.ProofRecord` declares the requirement, the revision, the planted defects
  run, the ids refused and accepted and the time (`spec/domains/evidence.yaml:620-658`). The
  record has no file form: `docs/evidence-format.md` § 9 lists "The other records" of design
  § 6, proof among them, as having no field list (`:672`).

## The part of this story in the wave

The format of the record the command writes. The command itself, its run of each defect and
the mark in the gate report wait for the waves to 0.1.0 in
`story:prove-command-in-ratchet`.

Decision, taken as the reversible answer (`AGENTS.md` § "Phase: implementation"): the proof
record is one JSON document of the format `ratchet-proof/1`, written by the CLI, with the
members `format`, `requirement`, `revision`, `planted`, `refused`, `accepted` and
`recorded_at`. Its id is `proof:<digest>` of its bytes, as a run's (design § 6), and is not a
member. A defect in neither list returned insufficient evidence.

## Acceptance

Every outcome below is observable without a `ratchet` command.

1. `spec/domains/evidence.yaml`: `ProofRecord` has `format` with the invariant
   `format == "ratchet-proof/1"`, and invariants that `refused` and `accepted` hold only ids of
   `planted` and no id twice; a rule ESS cannot state as an invariant is a row of the table
   of rules that are not invariants (`docs/evidence-format.md` § 8). Checked by `ess specify validate --path spec --strict-requires`
   (exit 0).
2. `docs/evidence-format.md` gets a section "12. The proof record `ratchet-proof/1`" with a
   field table of 7 rows and one JSON example; § 9 no longer counts the proof among "The other
   records". `spec/record-fields.test.sh` and `spec/record-types.test.sh` read the table as
   `ratchet.evidence.ProofRecord` with 7 rows, and their last lines count 112 field rows (105
   after 8): 82 of § 3, 23 of § 10 and 7 of § 12. `spec/README.md` names the table and says
   "7 in 1 table of § 12". Before the story the scripts read no table of § 12, and a table
   there with a member the specification does not declare would pass unread.
3. `spec/record-examples.test.sh` reads the JSON example of § 12 against
   `ratchet.evidence.ProofRecord` beside the 9 examples of § 6, and its last line counts the
   members of 10 examples, every one decoding; a copy whose example of § 12 holds an
   undeclared member is refused (a case in `spec/gate-inputs.test.sh`).
4. `docs/design.md` § 6, the row "Proof", names the format `ratchet-proof/1`. Text only, no
   case.
5. `CHANGELOG.md` has its line under `## [Unreleased]`. Text only, no case.

## Notes

- A new record format; nothing written before the change changes.
- `story:prove-command-in-ratchet` holds the command: a fixture with one planted defect of
  each form (`inputs` and `patch`), the exit statuses, the working tree unchanged, and the mark
  "unproven" in the gate report. It waits for the waves to 0.1.0 (`story:assess-command`,
  `story:evaluate-command`).
- Filed under `epic:improvement-and-policy` as the closest epic: the next after 0.1.0 and the
  one that extends the gate report. No epic names `ratchet prove`.
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of
  `.engineering/waves/0.1.0-ahead-2.md`, into one wave built in sequence on one branch: every
  planned wave starts behind `story:cli-skeleton-validate`, which waits for a release of ESS
  (beyond10x/ess#836), and this part needs no `ratchet` command. It is 9 of the 33 in the
  order of that page. It comes after the eight stories that change the field tables and the
  examples of `docs/evidence-format.md` (2 to 8), so it adds § 12 and the counts once they
  stand.
- It runs `task check:generated` when it edits `spec/domains/`.
- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s; the new
  broken copy is timed before it is added.
