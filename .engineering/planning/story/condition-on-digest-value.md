---
format: aep.planning-md/3
id: story:condition-on-digest-value
kind: story
status: draft
title: A requirement compares a digest with a value the specification states
summary: A condition with eq on a digest measurement and a pinned sha256 value.
relations:
- decomposes: epic:format-gaps-first-format-consumer
scope:
- confidence: cited
  path: CHANGELOG.md
- confidence: cited
  path: docs/design.md
- confidence: cited
  path: spec/domains/specification.yaml
- confidence: cited
  path: spec/presets.test.sh
revision: 6
---
## Context

The repository `beyond10x/inference` wrote its quality definition against the formats at
commit `f139ecc` (2026-11-25): 3 `ratchet/1` files, 8 `ratchet-assessor/1` declarations and 15
`ratchet-evidence/1` records. It is the first consumer of the formats outside this repository.
Finding 1: the definition needs "the SHA-256 of a downloaded archive equals a pinned value",
and the consumer wrote an assertion in its place, which loses the two digests in the verdict.
Its proposal: `condition: {operator: eq, value: "sha256:..."}`.

At `7b01ea1`:

- `ratchet.specification.Condition` holds `operator`, `value` as `Optional<Decimal>` and
  `unit` (`spec/domains/specification.yaml:536-555`). A digest is no decimal, so the proposal
  is refused.
- The table "Comparisons" of `docs/design.md` § 3 gives a digest no `condition`
  (`docs/design.md:194`, row "Digest": "None"); its one comparison is a `generated` reference.
- `spec/presets.test.sh`, rule `compare`, says the same: "A digest has no condition"
  (`spec/presets.test.sh:85-95`).
- A gate decision records the limit an observed value was compared with as a `Condition`
  (`ratchet.gate.RequirementVerdict.allowed`, `spec/domains/gate.yaml:241-243`), so a digest
  limit declared on `Condition` reaches the verdict without a new member there.
- A digest is written `sha256:` and 64 lowercase hex digits (`ratchet.evidence.Digest`,
  `spec/domains/evidence.yaml:44-50`).

Decision taken (reversible, `AGENTS.md` § "Phase: implementation"): a `Condition` gets a member
`digest`, of a new newtype `ratchet.specification.DigestValue` (the form of
`ratchet.evidence.Digest`), beside `value`. A digest is compared with `eq` and a `digest`, and
with nothing else. `value` keeps its type, so no file written before the change reads
otherwise. The consumer's spelling `value: "sha256:..."` is not taken: it would make `value` a
decimal or a text by the value type of the output, which the decoder cannot see.

## Acceptance

Every outcome below is observable without a `ratchet` command.

1. `spec/domains/specification.yaml`: `ratchet.specification.DigestValue` (newtype of
   `String`, summary naming the form `sha256:<64 lowercase hex digits>`) and the member
   `digest: Optional<ratchet.specification.DigestValue>` of `ratchet.specification.Condition`
   (`:536-555`), with the invariants that a condition with `digest` has the operator `eq` and
   no `value`. Checked by `ess specify validate --path spec --strict-requires`, which exits 0,
   and by `task check:generated`.
2. `docs/design.md` § 3 "Comparisons": the row "Digest" of the table (`:194`) reads `eq` with a
   `digest` in the column `condition`, and the bullet "A requirement with a `reference` and no
   `condition`" (`:197`) or a bullet beside it says that a digest is compared with a value the
   specification states as `{operator: eq, digest: "sha256:..."}`, that the verdict names the
   stated and the observed digest, and that a `digest` on another value type is an error.
   Text only, no case.
3. `spec/presets.test.sh`, rule `compare`: a digest takes `eq` with a `digest` and no `value`,
   and `digest` stands on no other value type. Before the story a preset whose requirement on
   a digest output has `condition: {operator: eq, digest: "sha256:<64 hex>"}` is refused (the
   key `digest` is no declared field, rule `place`, and a digest has no condition). After it, a
   copy with that requirement is accepted; a copy with `digest` on a number output, a copy
   with `operator: lt` and a `digest`, and a copy with `value` on a digest output are each
   refused with the message of the rule. The header of the script states the rule under
   `compare`. The line `presets: <d> of <d> defect(s) refused with the message of their rule`
   counts the three new defects.
4. `CHANGELOG.md` has its line under `## [Unreleased]`, in the form
   `.github/scripts/release.test.sh` checks.

## Notes

- An addition to a released format: a file written for `ratchet/1` before the change stays
  valid, and `value` keeps its type.
- The parts that need the command are `story:condition-on-digest-value-in-ratchet`: the
  refusal by `ratchet validate` of a `digest` on an output whose declared value type is not
  `digest` (the decoder cannot see the declaration), and a verdict of `ratchet evaluate --gate`
  that names both digests. It waits for the waves to 0.1.0 (`story:cli-skeleton-validate`,
  `story:evaluate-command`).
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of `.engineering/waves/0.1.0-ahead-2.md`,
  into one wave built in sequence on one branch: every planned wave starts behind
  `story:cli-skeleton-validate`, which waits for a release of ESS (beyond10x/ess#836), and this
  part needs no `ratchet` command. It is 10 of the 33 in the order of that page.
- It is the first of four stories of the wave that change `ratchet.specification.Condition`
  and the rule `compare` of `spec/presets.test.sh`: 11 (`story:requirement-states-a-range`)
  adds an operator with two bounds, 12 (`story:requirement-over-two-measurements`) a second
  measurement, 14 (`story:number-states-its-source`) a source. Each builds on the text this
  story leaves in `:536-555`, in the table of `docs/design.md:190-195` and in the rule.
- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s; new broken
  copies are timed before they are added.
