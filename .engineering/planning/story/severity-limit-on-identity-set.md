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
  path: docs/design.md
- confidence: cited
  path: examples/README.md
- confidence: cited
  path: examples/production-gate.ratchet.yaml
- confidence: cited
  path: spec/presets.test.sh
revision: 9
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

1. `examples/production-gate.ratchet.yaml` states check 6 as a limit: the requirement
   `no-critical-advisory` on the plan `image-advisories` has
   `condition: {operator: eq, value: 0}` and no `reference`: `grep -c 'no-critical-advisory'
   examples/production-gate.ratchet.yaml` prints 2, the requirement and its gate entry (0
   before).
2. The requirement `no-new-critical-advisory` is gone from that file, and so is its entry in
   `gates.production.requires`: `grep -c 'no-new-critical-advisory'
   examples/production-gate.ratchet.yaml` prints 0 (2 before).
3. `examples/README.md`, the table of the production gate: the row of check 6 names
   `no-critical-advisory` and "`eq 0` on the filtered set": `grep -F 'no-critical-advisory'
   examples/README.md` finds the row, nothing before.
4. `examples/README.md`, the note under that table: the phrase "waits for a severity limit on
   an identity set" is gone (`grep -c` prints 0, 1 before), and the note holds the phrase "the
   limit is stated with the operators an identity set has" (`grep -F` finds it, nothing
   before).
5. `docs/design.md` § 3 "Comparisons", the bullet on `filter`, holds the phrase "`eq` with the
   value 0 on a set filtered by a field of its items" and says that `no_new_items` on the same
   set admits an item once it is accepted: `grep -F` finds the phrase, nothing before.
6. `spec/presets.test.sh`: the accepted copy `compare-eq-zero-on-filtered-set`, whose
   requirement on a set of the functional family has `condition: {operator: eq, value: 0}`, a
   `filter` on its measurement and no `reference`, is accepted (a form that stays valid gets an
   accepted copy, `AGENTS.md` row `presets/`): `grep -c '^copy
   compare-eq-zero-on-filtered-set$' spec/presets.test.sh` prints 1 (0 before).

## Notes

- No addition to a format: the form is valid at 0.0.4, and the story writes it down and uses it.
- A guard, not an outcome: `sh spec/example-declarations.test.sh` still exits 0, so the plan
  of check 6 still reads `advisory-report@1` as declared, and the comment above `assessments:`
  of the example file ("Check 6 is a plan of this file") stays true.
- The line of the wave's changelog: under `### Changed`, naming `no-critical-advisory`
  (written by the story that closes the wave, `AGENTS.md` § "Changelog lines").
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
