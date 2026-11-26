---
format: aep.planning-md/3
id: story:gate-judges-commit-of-a-tag
kind: story
status: draft
title: A gate states that it judges the commit of a tag
summary: A candidate gate names the revision it judges when that is not the candidate of a change, first the commit a tag points at.
relations:
- decomposes: epic:format-gaps-first-format-consumer
scope:
- confidence: cited
  path: CHANGELOG.md
- confidence: cited
  path: docs/design.md
- confidence: cited
  path: spec/domains/specification.yaml
revision: 10
---
## Context

The repository `beyond10x/inference` wrote the second unit of its quality definition against
the formats at commit `f139ecc` (2026-11-25). It is the first consumer of the formats outside
this repository and of this story.

Finding 20. A gate cannot say that it judges the commit a tag points at. The stage of a gate
is a free label (`ratchet.specification.Stage`, `spec/domains/specification.yaml:662-668`), so
a gate `release` can be written and can require what the gates of a merge require. A gate has
no field for what it judges (`ratchet.specification.Gate`, `:1027-1076`: `project`, `kind`,
`stage`, `qualifying_environments`, `evidence`): the candidate is given when the gate is
evaluated (`ratchet evaluate --candidate`, `spec/domains/cli.yaml:267-272`), and the selection
of a target is the candidate or its merge result (`ratchet.specification.Selection`, `:250`).
`docs/design.md` § 5 "Gate entries, deciding evidence, and gate kinds", the paragraph "Gate
kinds" (`:648`), names `candidate` and `operational` and nothing a candidate gate binds to.
Nothing in the file binds a gate to a tag, so the file holds a release to nothing a reader can
see. The consumer left the gate out.

## Decision

The reversible answer, taken here (AGENTS.md § "Phase: implementation"): an optional member
`judges` of `Gate`, a struct `ratchet.specification.JudgedCandidate` with one member `tag`, a
pattern of tag names such as `"*.*.*"`. A candidate gate with `judges: {tag: ...}` judges only
a candidate that is the commit of a tag the pattern matches; without `judges` it judges the
candidate of a change, as today. An operational gate takes no `judges`: it has no candidate.
`JudgedCandidate` is a struct so that `story:production-gate-kind` (31) can add a second form
beside `tag`.

## Acceptance

Every outcome below is observable without a `ratchet` command.

1. `spec/domains/specification.yaml`: `Gate` (`:1027`) has the optional `judges` of the new
   struct `JudgedCandidate` with the required `tag`; an invariant of `Gate` refuses `judges` with
   `kind: operational`. Checked by `ess specify validate --path spec --strict-requires`, which
   exits 0, and by `task check:generated`.
2. `docs/design.md` § 5, the paragraph "Gate kinds" (`:648`): a candidate gate may state with
   `judges: {tag: <pattern>}` that it judges the commit of a tag, what a candidate that is no
   such commit gets, and that an operational gate has no `judges`; § 3 "Value lists" or the
   illustrative YAML shows the form once. Text only, no case.
3. `CHANGELOG.md` has its line under `## [Unreleased]`. Text only, no case.

## Notes

- An addition to a released format: a gate without `judges` stays valid and judges the
  candidate of a change.
- `ratchet evaluate --gate <name>` refusing a candidate that is not the commit of a matching
  tag, with a cause that names the gate, is `story:gate-judges-commit-of-a-tag-in-ratchet`,
  which waits for the waves to 0.1.0 (`story:evaluate-command`).
- The paragraph "Gate kinds" of `docs/design.md` § 5 is changed after this story by
  `story:production-gate-kind` (31), which adds a second form of `judges`, and
  `ratchet.specification.Gate` by no other story; `story:gate-entry-unless-only-paths` (29)
  changes the paragraph before it.
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of `.engineering/waves/0.1.0-ahead-2.md`,
  into one wave built in sequence on one branch: every planned wave starts behind
  `story:cli-skeleton-validate`, which waits for a release of ESS (beyond10x/ess#836), and this
  part needs no `ratchet` command. It is 30 of the 33 in the order of that page.
