---
format: aep.planning-md/3
id: story:gate-entry-unless-only-paths
kind: story
status: draft
title: A gate entry is skipped when every changed path is in a list
summary: 'The negative form of when: {changed} on a gate entry.'
relations:
- decomposes: epic:format-gaps-first-format-consumer
scope:
- confidence: cited
  path: docs/design.md
- confidence: cited
  path: spec/README.md
- confidence: cited
  path: spec/domains/specification.yaml
revision: 8
---
## Context

The repository `beyond10x/inference` wrote its quality definition against the formats at
commit `f139ecc` (2026-11-25). It is the first consumer of the formats outside this repository
and of this story.

Finding 3. The definition needs "this gate entry does not apply when every changed path is
planning or prose". `ratchet.specification.ChangedPaths` is positive only
(`spec/domains/specification.yaml:694-703` at 7b01ea1): `when: {changed: [paths]}` makes an
entry apply when the change touches a listed path, and `GateRequirement.when` holds one such
value (`:1106-1108`). `docs/design.md` § 5 "Gate entries, deciding evidence, and gate kinds"
states the positive form alone (`:637`, the paragraph "An entry can apply to some changes"). A
list of every path that is no planning file cannot be written as patterns without negation.
The consumer's example: `when: {not_only: [".engineering/**", "**/*.md"]}`.

## Decision

The consumer's form, taken here (AGENTS.md § "Phase: implementation"): `ChangedPaths` gets a
second optional member, `not_only`, and `changed` becomes optional; exactly one of the two is
present. `when: {not_only: [paths]}` makes the entry apply when the change touches at least one
path outside the list, and not apply when every changed path is in it. An empty change matches
neither form and the entry does not apply, as with `changed`. The patterns are those of
`changed`, policy read from the trusted revision.

## Acceptance

Every outcome below is observable without a `ratchet` command.

1. `spec/domains/specification.yaml`, `ratchet.specification.ChangedPaths` has the optional
   member `not_only`, and `changed` is optional: `grep -c 'name: not_only'
   spec/domains/specification.yaml` prints 1 (0 before), and
   `ess specify validate --path spec --strict-requires` and `task check:generated` exit 0.
2. `ChangedPaths` has invariants that exactly one of the two is present:
   `grep -F 'any: ["defined(changed)", "defined(not_only)"]' spec/domains/specification.yaml`
   and `grep -F 'any: ["not defined(changed)", "not defined(not_only)"]'
   spec/domains/specification.yaml` each find a line (nothing before).
3. The summary of `ChangedPaths` states the second form:
   `grep -F '`when: {not_only: [paths]}`' spec/domains/specification.yaml` finds it (nothing
   before).
4. `docs/design.md` § 5 "Gate entries, deciding evidence, and gate kinds", the paragraph "An
   entry can apply to some changes", states the form `not_only`, when it applies and when not:
   `grep -F 'applies when the change touches at least one path outside the list'
   docs/design.md` finds it (nothing before).
5. The same paragraph shows one entry with the form:
   `grep -F 'when: {not_only: [".engineering/**", "**/*.md"]}' docs/design.md` finds it
   (nothing before). The illustrative YAML of § 3 stays as it is.
6. The same paragraph says that the gate report names such an entry as not applicable with the
   reason: `grep -F 'every changed path is in `not_only`' docs/design.md` finds it (nothing
   before).
7. `spec/README.md`, § "How a `ratchet/1` file differs from the declared entities", the rule
   cell of the row "An entry written as a map may leave `mode` out" names `when` with either
   form: `grep -F 'Its `when` holds `changed` or `not_only`, one of the two.' spec/README.md`
   finds it (nothing before).

## Notes

- An addition to a released format: a file with `when: {changed: [...]}` stays valid.
- Matching a change against `not_only`, the entry not applicable with its reason in the gate
  report, and `ratchet validate` refusing a `when` with both members, are
  `story:gate-entry-unless-only-paths-in-ratchet`, which waits for the waves to 0.1.0
  (`story:evaluate-command`).
- `docs/design.md` § 5 "Gate entries, deciding evidence, and gate kinds" is changed by the next
  three stories too: `story:gate-judges-commit-of-a-tag` (30) and `story:production-gate-kind`
  (31) in the paragraph "Gate kinds", `story:gate-joins-revision-and-document` (32) after it.
  This story changes only the paragraph "An entry can apply to some changes". `spec/README.md`
  is rewritten by `story:readme-design-citations-by-place` (1) first; this story keeps its
  citation by place.
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of `.engineering/waves/0.1.0-ahead-2.md`,
  into one wave built in sequence on one branch: every planned wave starts behind
  `story:cli-skeleton-validate`, which waits for a release of ESS (beyond10x/ess#836), and this
  part needs no `ratchet` command. It is 29 of the 33 in the order of that page.
