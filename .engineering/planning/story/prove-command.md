---
format: aep.planning-md/3
id: story:prove-command
kind: story
status: active
title: 'ratchet prove: run the planted defects of a requirement'
relations:
- decomposes: epic:improvement-and-policy
scope:
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
revision: 16
transitions:
- {from: "draft", to: "proposed", at: "2026-11-26T21:04:21Z", actor: "human:operator", revision: 15, decided_on: {"recorded":{"review_outcome":4}}}
- {from: "proposed", to: "active", at: "2026-11-26T21:04:21Z", actor: "human:operator", revision: 16, decided_on: {"recorded":{"review_outcome":4}}}
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
- `spec/record-examples.test.sh` reads the blocks fenced `json` of § 6 alone (its awk opens
  only on `## 6. `), and gives a root object that holds `format` the type
  `ratchet.evidence.AssessmentRun` whatever the value of `format`.

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

Every outcome below is observable without a `ratchet` command. No item cites a line number.

A phrase with a space in it may wrap in a Markdown paragraph or a folded YAML summary. So where
an item says that `grep -F` finds such a phrase in a `.md` or `.yaml` file, that it finds
nothing or the phrase is gone, or that `grep -c` of it prints a count, the check reads the
joined text of the file: `tr -s '\n ' '  ' < <file> | grep -o -F '<phrase>' | wc -l` prints 1
where the item says it is found, 0 where it says nothing or gone, and the count where it names
one. A name without a space, a row of a table, a pattern with `^`, `$` or `-E`, a check that
prints the line it matches and a check that reads the output of another command read the file
line by line, as written.

1. `spec/domains/evidence.yaml`, `ratchet.evidence.ProofRecord`: the field `format` with the
   invariant `format == "ratchet-proof/1"` (`grep -c 'ratchet-proof/1'
   spec/domains/evidence.yaml` prints at least 1; 0 before).
2. `spec/domains/evidence.yaml`, the invariants of `ProofRecord`: `refused` and `accepted`
   hold only ids of `planted`, and no id twice. The block of `ProofRecord` holds `in: refused`
   and `in: accepted` under `invariants:` (`grep -A60 'name: ratchet.evidence.ProofRecord$'
   spec/domains/evidence.yaml | grep -c 'in: refused'` prints at least 1, and so for
   `in: accepted`; 0 before, when `ProofRecord` has no invariant). `ess specify validate
   --path spec --strict-requires` exits 0.
3. `docs/evidence-format.md` has a section "## 12. The proof record `ratchet-proof/1`" with a
   field table of 7 rows, which `spec/record-fields.test.sh` and `spec/record-types.test.sh`
   read as `ratchet.evidence.ProofRecord`. They end with
   `record-fields: 112 of 112 field rows declared` and
   `record-types: 112 of 112 field rows as declared, 112 of 112 declared fields have a row`
   (105 after story 8). Before the story the scripts read no table of § 12, and a table
   there with a member the specification does not declare would pass unread.
4. `docs/evidence-format.md` § 9, the bullet "The other records", no longer counts the proof:
   `grep -F 'gate decision, reference change, trade-off, and proof' docs/evidence-format.md`
   prints nothing (one line before).
5. `spec/README.md`, the paragraph that begins "Each script states how much it reads": it
   says "7 in 1 table of § 12": `tr -s '\n ' '  ' < spec/README.md | grep -c -F '7 in 1 table
   of § 12'` prints 1 (0 before).
6. The open question of the round, answered: at the base `spec/record-examples.test.sh`
   cannot read a § 12 example. It reads § 6 alone, and it would decode a root that holds
   `format` as a `ratchet.evidence.AssessmentRun` and fail on every member of a proof
   record. The story changes the script: it also reads the blocks fenced `json` of § 12,
   against a number it states beside `want_examples`, and takes the root type of an object
   from the value of `format` (`ratchet-evidence/1`: `AssessmentRun`; `ratchet-proof/1`:
   `ratchet.evidence.ProofRecord`). Its header says "§ 12 holds 1 example" (`grep -F` finds
   it in `spec/record-examples.test.sh`; nothing before), and the script ends with
   `record-examples: <n> of <n> members of 10 example(s) decode under the specification`
   (9 examples after story 7). The evidence digest stays that of § 6 example 1.
7. `spec/README.md`, the same paragraph: it says "9 examples in § 6 and 1 in § 12
   (`record-examples`)": `tr -s '\n ' '  ' < spec/README.md | grep -c -F '9 examples in § 6
   and 1 in § 12'` prints 1 (0 before, when it says "9 examples in § 6 (`record-examples`)"
   after story 7).
8. `spec/gate-inputs.test.sh` has a case `proof-example-member`: a copy whose example of
   § 12 holds a member `ProofRecord` does not declare is refused, and the script ends with
   `gate-inputs: 12 of 12 broken inputs refused` (11 of 11 before).
9. `docs/design.md` § 6, the row "Proof", names the format `ratchet-proof/1` (`grep -c
   'ratchet-proof/1' docs/design.md` prints 1; 0 before).

## Notes

- A new record format; nothing written before the change changes.
- `story:prove-command-in-ratchet` holds the command: a fixture with one planted defect of
  each form (`inputs` and `patch`), the exit statuses, the working tree unchanged, and the mark
  "unproven" in the gate report. It waits for the waves to 0.1.0 (`story:assess-command`,
  `story:evaluate-command`).
- Filed under `epic:improvement-and-policy` as the closest epic: the next after 0.1.0 and the
  one that extends the gate report. No epic names `ratchet prove`.
- Its line of `CHANGELOG.md` is written by the closing commit of the wave (`AGENTS.md`
  § "Changelog lines"; the wave record names the heading and the phrase of the line).
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of
  `.engineering/waves/0.1.0-ahead-2.md`, into one wave built in sequence on one branch: every
  planned wave starts behind `story:cli-skeleton-validate`, which waits for a release of ESS
  (beyond10x/ess#836), and this part needs no `ratchet` command. It is 9 of the 33 in the
  order of that page. It comes after the seven stories that change the field tables and the
  examples of `docs/evidence-format.md` (2 to 8), so it adds § 12 and the counts once they
  stand.
- It runs `task check:generated` when it edits `spec/domains/`.
- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s; the new
  broken copy is timed before it is added.
