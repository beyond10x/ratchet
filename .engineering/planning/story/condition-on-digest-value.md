---
format: aep.planning-md/3
id: story:condition-on-digest-value
kind: story
status: implemented
title: A requirement compares a digest with a value the specification states
summary: A condition with eq on a digest measurement and a pinned sha256 value.
relations:
- decomposes: epic:format-gaps-first-format-consumer
scope:
- confidence: cited
  path: docs/design.md
- confidence: cited
  path: spec/domains/specification.yaml
- confidence: cited
  path: spec/presets.test.sh
revision: 12
transitions:
- {from: "draft", to: "proposed", at: "2026-11-26T21:04:21Z", actor: "human:operator", revision: 10, decided_on: {"recorded":{"review_outcome":4}}}
- {from: "proposed", to: "active", at: "2026-11-26T21:04:21Z", actor: "human:operator", revision: 11, decided_on: {"recorded":{"review_outcome":4}}}
- {from: "active", to: "implemented", at: "2026-11-26T23:39:02Z", actor: "human:operator", revision: 12, decided_on: {"recorded":{"test_result":1,"review_outcome":4}}}
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

A phrase with a space in it may wrap in a Markdown paragraph or a folded YAML summary. So where
an item says that `grep -F` finds such a phrase in a `.md` or `.yaml` file, that it finds
nothing or the phrase is gone, or that `grep -c` of it prints a count, the check reads the
joined text of the file: `tr -s '\n ' '  ' < <file> | grep -o -F '<phrase>' | wc -l` prints 1
where the item says it is found, 0 where it says nothing or gone, and the count where it names
one. A name without a space, a row of a table, a pattern with `^`, `$` or `-E`, a check that
prints the line it matches and a check that reads the output of another command read the file
line by line, as written.

1. `spec/domains/specification.yaml` declares the newtype `ratchet.specification.DigestValue`
   of `String`, whose summary names the form `sha256:<64 lowercase hex digits>`:
   `grep -c 'name: ratchet.specification.DigestValue' spec/domains/specification.yaml` prints
   1 (0 before).
2. `ratchet.specification.Condition` holds the member
   `digest: Optional<ratchet.specification.DigestValue>`: the line
   `type: Optional<ratchet.specification.DigestValue>` stands among the fields of `Condition`
   (`grep -F` finds it, nothing before), and `ess specify validate --path spec
   --strict-requires` exits 0.
3. `Condition` states two invariants, written
   `- any: ["not defined(digest)", "operator == eq"]` and
   `- any: ["not defined(digest)", "not defined(value)"]`: `grep -cF '"not defined(digest)"'
   spec/domains/specification.yaml` prints 2 (0 before).
4. `docs/design.md` § 3 "Comparisons", the table: the cell `condition` of the row "Digest"
   reads "`eq` with a `digest`" in place of "None" (`grep -F '| Digest | None |'
   docs/design.md` prints nothing; it prints the row before).
5. `docs/design.md` § 3 "Comparisons", a bullet below the table states the form
   `{operator: eq, digest: "sha256:..."}` and that the verdict names the stated and the
   observed digest: `grep -F '{operator: eq, digest:' docs/design.md` finds it, nothing before.
6. The same bullet holds the phrase "a `digest` on another value type is a validation error":
   `grep -F` finds it, nothing before.
7. `spec/presets.test.sh`, the header of the rule `compare`, holds the phrase "takes `eq` with
   a `digest` and no `value`" on one line: `grep -cF` prints 1, 0 before.
8. `spec/presets.test.sh`: the accepted copy `compare-digest-eq`, whose requirement on a digest
   output has `condition: {operator: eq, digest: "sha256:<64 hex>"}`, is accepted. Before the
   story the same requirement is refused (rule `place`: `digest` is no declared field).
9. `spec/presets.test.sh`: three cases are each refused with the message of the rule
   `compare`, named "a digest condition on a number output", "a digest condition with the
   operator lt" and "a value on a digest output". Before the story none of the three names is
   in the script (`grep -c` prints 0 for each).

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
  story leaves in `Condition`, in the table of `docs/design.md` § 3 "Comparisons" and in the
  rule.
- The line of the wave's changelog: under `### Added`, naming `digest` (written by the story
  that closes the wave, `AGENTS.md` § "Changelog lines").
- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s; new broken
  copies are timed before they are added.
