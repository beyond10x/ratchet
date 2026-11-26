---
format: aep.planning-md/3
id: story:window-over-outside-population
kind: story
status: draft
title: An assessor of a window over a population outside the record store learns its window
relations:
- decomposes: epic:ci-turnaround
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
  path: spec/contract-examples.test.sh
- confidence: cited
  path: spec/domains/assessor.yaml
revision: 8
---
## Context

Found by a consumer writing a `ratchet/1` file at 0.0.3: a time window is defined only over the
runs of another plan, read by `record-series@1`.

What the formats say at the wave's base, `7b01ea1`:

- The design gives a window a second population, `{filter: {...}}`, read by the assessor
  outside the record store (`docs/design.md` § 3 "Time windows", `:172`), with the fields the
  assessor declares (`ratchet.assessor.Assessor.population_fields`,
  `spec/domains/assessor.yaml:205-210`; `ratchet.specification.PopulationSpec`,
  `spec/domains/specification.yaml:439-466`).
- No contract says how such an assessor learns its window. The invocation passes `--project`,
  `--assessment`, `--root`, `--class`, `--out`, `--revision` and the declared inputs, and
  nothing else (`docs/evidence-format.md` § 10, `:687-697`). § 9 says that the contract does
  not cover a plan without a selection or a target of another kind than `revision` or
  `document` (`:673`). So the `window` and the `filter` of a plan reach no program, and the
  bounds in `evidence.target.window` (`docs/evidence-format.md:90-98`) are the assessor's
  guess.
- No example uses the shape (`docs/design.md:72`).
- `story:assessor-learns-observation` (5 of this wave) adds `observation_inputs`, a map from a
  key of the plan's observation to an input the declaration declares, with the closed list
  `ratchet.assessor.ObservationKey`.

## Decision

Taken as the reversible answer (`AGENTS.md` § "Phase: implementation"), on the form of 5 and
without a new reserved argument, so the declaration format stays at version 1:

- `ObservationKey` gets `window_length`, `window_last` and `window_ends_at`. Ratchet passes the
  `length` and the `last` of the plan's `window`, and the instant the plan is assessed, at
  which the window ends (design § 3), as the inputs a declaration maps them to. A record's
  `target.window` lies inside the window passed.
- Each field of `population: {filter}` is passed as `--<field> <value>`, with the names of the
  declaration's `population_fields`; an assessor declares no input with such a name.
- A time-window plan without a `selection` is passed no `--revision` and writes no
  `candidate` and no `target.selection` (format § 4 rule 1).

## Acceptance

Every outcome below is observable without a `ratchet` command.

1. `spec/domains/assessor.yaml`: `ObservationKey` has the three window keys, and the summaries
   of `Assessor.population_fields` and `ReservedArgument` say how the fields of a `{filter}`
   are passed. Checked by `ess specify validate --path spec --strict-requires` (exit 0).
2. `docs/evidence-format.md` § 10 "Invocation" states the decision for the window, the
   population fields and a plan without a selection; § 9, "The rest of the invocation", no
   longer names a plan without a selection. Text only, no case.
3. `docs/evidence-format.md` § 10 has two more YAML examples: the declaration of an assessor
   of a population outside the record store, with `targets: [telemetry_population]`,
   `population_fields` and `observation_inputs` for the window keys, and a time-window plan
   with `population: {filter: {...}}`, a `window` and `min_samples` and no `selection`.
   `want_examples` of `spec/contract-examples.test.sh` (`:43`) goes from 2 to 4, and its last
   line counts the keys of 4 examples, every one a declared field. Before the story no example
   uses the shape. `docs/design.md:72` no longer says that no example uses it, and points to
   that example. `spec/README.md` says "4 examples in § 10 (`contract-examples`)".
4. `CHANGELOG.md` has its line under `## [Unreleased]`. Text only, no case.

## Notes

- An addition to a released format: a declaration written before the change stays valid, and
  an assessor that maps no window key and declares no population field is passed nothing new.
- That `ratchet assess` passes the window and refuses a record outside it is
  `story:window-over-outside-population-in-ratchet`, which waits for the waves to 0.1.0
  (`story:assess-command`, `story:evidence-reader`).
- Filed under `epic:ci-turnaround` as the closest epic: it uses a time window first
  (`docs/design.md:820`).
- Related: `story:assessor-learns-observation` (the form this story extends),
  `story:build-target-invocation`.
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of
  `.engineering/waves/0.1.0-ahead-2.md`, into one wave built in sequence on one branch: every
  planned wave starts behind `story:cli-skeleton-validate`, which waits for a release of ESS
  (beyond10x/ess#836), and this part needs no `ratchet` command. It is 6 of the 33 in the
  order of that page. It comes after 5, whose `ObservationKey` it extends, and before 7 and 8,
  which change the same § 9 bullet and § 10 "Invocation".
- It runs `task check:generated` when it edits `spec/domains/`.
- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s.
