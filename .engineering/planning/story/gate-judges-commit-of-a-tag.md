---
format: aep.planning-md/3
id: story:gate-judges-commit-of-a-tag
kind: story
status: active
title: A gate states that it judges the commit of a tag
summary: A candidate gate names the revision it judges when that is not the candidate of a change, first the commit a tag points at.
relations:
- decomposes: epic:format-gaps-first-format-consumer
scope:
- confidence: cited
  path: crates/ratchet-cli-contract
- confidence: cited
  path: docs/design.md
- confidence: cited
  path: spec/cli.yaml
- confidence: cited
  path: spec/domains/specification.yaml
revision: 17
transitions:
- {from: "draft", to: "proposed", at: "2026-11-26T21:04:24Z", actor: "human:operator", revision: 16, decided_on: {"recorded":{"review_outcome":4}}}
- {from: "proposed", to: "active", at: "2026-11-26T21:04:24Z", actor: "human:operator", revision: 17, decided_on: {"recorded":{"review_outcome":4}}}
---
## Context

The repository `beyond10x/inference` wrote the second unit of its quality definition against
the formats at commit `f139ecc` (2026-11-25). It is the first consumer of the formats outside
this repository and of this story.

Finding 20. A gate cannot say that it judges the commit a tag points at. The stage of a gate
is a free label (`ratchet.specification.Stage`, `spec/domains/specification.yaml:662-668` at
7b01ea1), so a gate `release` can be written and can require what the gates of a merge
require. A gate has no field for what it judges (`ratchet.specification.Gate`, `:1027-1076`:
`project`, `kind`, `stage`, `qualifying_environments`, `evidence`): the candidate is given when
the gate is evaluated (`ratchet evaluate --candidate`, `spec/domains/cli.yaml:267-272`), and
the selection of a target is the candidate or its merge result
(`ratchet.specification.Selection`, `:250`). `docs/design.md` § 5 "Gate entries, deciding
evidence, and gate kinds", the paragraph "Gate kinds" (`:648`), names `candidate` and
`operational` and nothing a candidate gate binds to. Nothing in the file binds a gate to a tag,
so the file holds a release to nothing a reader can see. The consumer left the gate out.

The binding `spec/cli.yaml` declares the refusals of `ratchet evaluate` under `errors:`, among
them `operational_gate_takes_no_candidate`. The name is the binding's own: its comment above
`errors:` calls it "a name this specification proposes", and `docs/design.md` does not name
it. The paragraph "Gate kinds" gives only the rule behind it, that the evidence of an
operational gate "is not attributable to one candidate".

## Decision

The reversible answer, taken here (AGENTS.md § "Phase: implementation"): an optional member
`judges` of `Gate`, a struct `ratchet.specification.JudgedCandidate` with one member `tag`, a
pattern of tag names such as `"*.*.*"`. A candidate gate with `judges: {tag: ...}` judges only
a candidate that is the commit of a tag the pattern matches; without `judges` it judges the
candidate of a change, as today. An operational gate takes no `judges`: it has no candidate.
`JudgedCandidate` is a struct so that `story:production-gate-kind` (31) can add a second form
beside `tag`.

A candidate that is no commit of a tag the pattern matches is refused, in one place: before
any entry is judged, `ratchet evaluate` writes no decision and returns the refusal
`candidate_not_tagged`, which names the gate and the pattern. It is no verdict: a gate that
judges releases has nothing to say about another commit. The refusal is declared in the binding
`spec/cli.yaml` beside `operational_gate_takes_no_candidate`; returning it is the command's.

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

1. `spec/domains/specification.yaml` declares the struct
   `ratchet.specification.JudgedCandidate` with the required member `tag`:
   `grep -c 'name: ratchet.specification.JudgedCandidate' spec/domains/specification.yaml`
   prints 1 (0 before), and `ess specify validate --path spec --strict-requires` exits 0.
2. `ratchet.specification.Gate` has the optional member `judges` of that struct:
   `grep -c 'type: Optional<ratchet.specification.JudgedCandidate>'
   spec/domains/specification.yaml` prints 1 (0 before), and `task check:generated` exits 0.
3. An invariant of `Gate` refuses `judges` with `kind: operational`:
   `grep -F 'any: ["kind != operational", "not defined(judges)"]'
   spec/domains/specification.yaml` finds it (nothing before).
4. `docs/design.md` § 5, the paragraph "Gate kinds", says that a candidate gate states with
   `judges: {tag: <pattern>}` that it judges the commit of a tag, and shows the form:
   `grep -F 'judges: {tag: "*.*.*"}' docs/design.md` finds it (nothing before).
5. The same paragraph says what a candidate that is no such commit gets:
   `grep -F 'returns the refusal `candidate_not_tagged`' docs/design.md` finds it (nothing
   before).
6. The same paragraph says that an operational gate has no `judges`:
   `grep -F 'An operational gate takes no `judges`' docs/design.md` finds it (nothing before).
7. The binding `spec/cli.yaml` declares the refusal on `evaluate`:
   `grep -c 'candidate_not_tagged: ratchet.cli.Refusal' spec/cli.yaml` prints 1 (0 before),
   and `ess specify cli --path spec --binding spec/cli.yaml --strict-requires` exits 0.
8. The generated crate follows: after `task generate`, `task check:generated` exits 0 and
   `grep -c candidate_not_tagged crates/ratchet-cli-contract/README.md` prints 1 (0 before).

## Notes

- An addition to a released format: a gate without `judges` stays valid and judges the
  candidate of a change.
- `ratchet evaluate --gate <name>` returning `candidate_not_tagged` for a candidate that is not
  the commit of a matching tag is `story:gate-judges-commit-of-a-tag-in-ratchet`, which waits
  for the waves to 0.1.0 (`story:evaluate-command`).
- It changes `spec/cli.yaml`, so it runs `task generate` and `task check:generated`.
  `spec/cli-errors.test.sh` counts the errors the command table of § 5 "Proposed CLI" names;
  the paragraph "Gate kinds" is not that table, so its count stays 3.
- The paragraph "Gate kinds" of `docs/design.md` § 5 is changed after this story by
  `story:production-gate-kind` (31), which adds a second form of `judges`;
  `story:gate-entry-unless-only-paths` (29) changes the paragraph "An entry can apply to some
  changes" before it.
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of `.engineering/waves/0.1.0-ahead-2.md`,
  into one wave built in sequence on one branch: every planned wave starts behind
  `story:cli-skeleton-validate`, which waits for a release of ESS (beyond10x/ess#836), and this
  part needs no `ratchet` command. It is 30 of the 33 in the order of that page.
