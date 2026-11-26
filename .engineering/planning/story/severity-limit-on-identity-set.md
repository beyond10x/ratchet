---
format: aep.planning-md/3
id: story:severity-limit-on-identity-set
kind: story
status: draft
title: A requirement limits the items of an identity set by severity
relations:
- decomposes: epic:preset-catalog
scope:
- confidence: cited
  path: CHANGELOG.md
- confidence: cited
  path: docs/design.md
- confidence: cited
  path: examples/README.md
- confidence: cited
  path: examples/production-gate.ratchet.yaml
- confidence: cited
  path: spec/presets.test.sh
revision: 7
---
## Context

Named by `story:production-gate-spec-executed-service`. Check 6 of a consumer's production
gate is "the image has no critical advisory".

At `7b01ea1`:

- The items of `advisory-report@1` carry `severity`
  (`presets/advisory-report@1.assessor.yaml:17`, `item_fields: [severity, versions]`), and a
  measurement's `filter` keeps the items whose field has one of the listed values, before the
  comparison (`docs/design.md:202`).
- `examples/production-gate.ratchet.yaml:62-73` states check 6 as the measurement
  `critical-advisories` with `filter: {severity: [critical]}` and the requirement
  `no-new-critical-advisory`, `no_new_items` against the accepted set. That lets a critical
  advisory stand once it is accepted. `examples/README.md:467` and `:470-472` say so: "a limit
  of no critical advisory at all waits for a severity limit on an identity set".

## The question, answered

Whether `eq 0` on a filtered identity set already states the limit. It does. The table
"Comparisons" of `docs/design.md` § 3 gives an identity set "the same five operators, on the
number of items" (`:193`), `lt`, `lte`, `gt`, `gte` and `eq` with a `value`, and the `filter`
applies before the comparison (`:202`). So `condition: {operator: eq, value: 0}` on the set
filtered to `severity: [critical]` says "no critical item", with no reference and no new key.
`spec/presets.test.sh`, rule `compare`, already allows it: "`lt`, `lte`, `gt`, `gte` and `eq`
take a number or a set and have a `value`" (`spec/presets.test.sh:86-87`). The story adds
nothing to `spec/domains/`.

## Acceptance

Every outcome below is observable without a `ratchet` command.

1. `examples/production-gate.ratchet.yaml`: check 6 is stated as a limit, the requirement
   `no-critical-advisory` with `condition: {operator: eq, value: 0}` on the measurement
   `critical-advisories` (`filter: {severity: [critical]}`), and no `reference`; the gate
   `production` requires it in place of `no-new-critical-advisory` (`:87`), and the comment of
   `:51` still holds. Before the story the file states check 6 with `no_new_items` only.
   `sh spec/example-declarations.test.sh` exits 0 with the same line of its check: the plan of
   check 6 still reads `advisory-report@1` as declared.
2. `examples/README.md`: the row of check 6 (`:467`) names `no-critical-advisory`, `eq 0` on the
   filtered set, and the note under the table (`:470-472`) says that the limit is stated with
   the operators an identity set has, and no longer that it waits. Text only, no case.
3. `docs/design.md` § 3 "Comparisons": the bullet on `filter` (`:202`) says that `eq` with the
   value 0 on a set filtered by a field of its items, such as `severity: [critical]`, is the
   limit "no item of that kind", whatever an accepted set holds, and that `no_new_items` on the
   same set admits an item once it is accepted. Text only, no case.
4. `spec/presets.test.sh`: a copy whose requirement on a set of the functional family has
   `condition: {operator: eq, value: 0}`, a `filter` on its measurement and no `reference` is
   accepted (a form that stays valid gets an accepted copy, `AGENTS.md` row `presets/`).
5. `CHANGELOG.md` has its line under `## [Unreleased]`, in the form
   `.github/scripts/release.test.sh` checks.

## Notes

- No addition to a format: the form is valid at 0.0.4, and the story writes it down and uses it.
- No part needs a command beyond `story:evaluate-command`, which judges a condition on the
  number of items of a set; the story has no `-in-ratchet` draft.
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of `.engineering/waves/0.1.0-ahead-2.md`,
  into one wave built in sequence on one branch: every planned wave starts behind
  `story:cli-skeleton-validate`, which waits for a release of ESS (beyond10x/ess#836), and this
  part needs no `ratchet` command. It is 13 of the 33 in the order of that page.
- 31 (`story:production-gate-kind`) changes the gate of the same example file and the note
  under its table after this story.
- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s; the new
  accepted copy is timed before it is added.
