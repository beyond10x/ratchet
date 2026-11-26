---
format: aep.planning-md/3
id: story:assessor-learns-observation
kind: story
status: draft
title: An assessor learns the workload, the runs and the least samples of its plan
summary: The workload is written twice with no check, and a percentile result carries no number of runs.
relations:
- decomposes: epic:preset-catalog
- depends_on: story:preset-catalog-runtime
scope:
- confidence: cited
  path: CHANGELOG.md
- confidence: cited
  path: docs/evidence-format.md
- confidence: inferred
  path: presets/event-time@2.preset.yaml
- confidence: cited
  path: presets/latency.md
- confidence: cited
  path: presets/operability.md
- confidence: cited
  path: presets/resources.md
- confidence: cited
  path: presets/start.md
- confidence: inferred
  path: presets/timing-report@2.assessor.yaml
- confidence: cited
  path: spec/README.md
- confidence: cited
  path: spec/domains/assessor.yaml
- confidence: cited
  path: spec/domains/evidence.yaml
- confidence: cited
  path: spec/presets.test.sh
- confidence: cited
  path: spec/record-fields.test.sh
- confidence: cited
  path: spec/record-types.test.sh
revision: 23
---
## Context

Point 6 of "Not expressible yet" on `presets/latency.md` (`:272-282`), repeated as point 5 on
`presets/resources.md` (`:140`) and `presets/start.md` (`:129`) and named on
`presets/operability.md` (`:187`) (`story:preset-catalog-runtime`), and finding 2 of
`review-result:adversary-preset-catalog-runtime-attack-1`. First consumer: the catalog, and
every project whose program reads a report of several runs.

What the formats say at the wave's base, `7b01ea1`:

- Ratchet passes an assessor the six reserved arguments and its declared inputs, "and nothing
  else" (`docs/evidence-format.md` § 10 "Invocation", `:683-697`). § 9 says that the contract
  does not say how an assessor learns the `scenarios`, the `workload`, the `command`, the
  `runs` and the `min_samples` of a plan (`:673`).
- A plan names the workload twice: `event-time@1` passes the input `workload` to
  `timing-report@1` and writes `observation.workload` from the same input
  (`presets/event-time@1.preset.yaml`; `presets/timing-report@1.assessor.yaml`).
  `ratchet.assessor.Assessor` has `target_input` for the target and no member that names the
  input of the workload (`spec/domains/assessor.yaml:159-164`), and nothing checks that the two
  are the same in a plan a project writes by hand.
- The program is passed neither `runs` nor `min_samples`. For a percentile over the requests
  of all runs the `samples` of a result counts requests (`spec/domains/evidence.yaml:395-401`;
  `docs/evidence-format.md:169`), so no record carries the number of runs: a report of one run
  with 200 requests satisfies a plan with `runs: 3`, against `docs/design.md` § 3 ("The
  evidence carries the count", `:86`).
- The first consumer of the formats met the same gap: an assessor is not passed the `command`
  of its plan (its report of 2026-11-25, from a read of `b8945e5`).

## Decision

Taken as the reversible answer (`AGENTS.md` § "Phase: implementation"), as members beside
`target_input` and not as reserved arguments, so the declaration format stays at version 1:

- A declaration may hold `observation_inputs`, a map from a key of the plan's observation
  (`scenarios`, `workload`, `command`, `runs`, `min_samples`) to the name of an input it
  declares. Ratchet passes the value of that key of the plan as that input (format § 10
  "Values"), so the plan writes it once, under `observation`, and passes no value to that input
  under `inputs`. The keys are a closed list, `ratchet.assessor.ObservationKey`.
- A number result may carry `runs`, the number of runs the value was aggregated over, beside
  `samples`. A result of a plan whose assessor maps `runs` carries it.

## Acceptance

Every outcome below is observable without a `ratchet` command.

1. `spec/domains/assessor.yaml`: the enum `ObservationKey` and the member
   `Assessor.observation_inputs`, whose summary states the decision; an input named there is
   no reserved argument. `spec/domains/evidence.yaml`: `MeasurementResult.runs`
   (`Optional<Integer>`), with an invariant that only a number has it. Checked by
   `ess specify validate --path spec --strict-requires` (exit 0).
2. `docs/evidence-format.md` § 10: the declaration table has a row `observation_inputs` (13
   rows), and the "Invocation" says that Ratchet passes the value of each key named there as
   its input; § 3, the table "A result of the value type `number`", has a row `runs` (6 rows),
   and the sentence "There are 80 fields" of 4 reads 81, with 26 `new`. Checked by
   `sh spec/record-fields.test.sh` and `sh spec/record-types.test.sh`: the lines of the two
   tables state 13 and 6 rows in both scripts, and their last lines count 103 field rows, 81
   of § 3 and 22 of § 10 (101 after 4). `spec/README.md` says "81 field rows in 13 tables of
   § 3 and 22 in 2 tables of § 10". § 9, "The rest of the invocation", no longer names
   `scenarios`, `workload`, `command`, `runs` and `min_samples`. The § 6 example 4 (the run of
   `ci-gate-timing`) may show `runs`; the number of examples stays 8.
3. `spec/presets.test.sh` refuses a plan that passes a value under `inputs` to an input its
   assessor names in `observation_inputs`, and a declaration whose `observation_inputs` names
   an input it does not declare, each with the message of its rule; a broken copy of the set
   for each is refused with that message, and the header lists the two rules. Before the story
   both copies are accepted.
4. `presets/timing-report@2.assessor.yaml` (new) maps `workload`, `runs` and `min_samples`;
   `presets/event-time@2.preset.yaml` (new) names it and writes the workload once, under
   `observation`. `event-time@1` and `timing-report@1` stay byte for byte.
   `presets/latency.md` has the rows of `event-time@2`, and its point 6 (`:272-282`) says
   that `observation_inputs` answers it from `event-time@2` on. Checked by
   `spec/presets.test.sh`, rules `place`, `type` and `row`: its last line counts two more
   files and one more measurement with a row.
5. `CHANGELOG.md` has its line under `## [Unreleased]`. Text only, no case.

## Notes

- An addition to two released formats, `ratchet-assessor/1` and `ratchet-evidence/1`: a
  declaration and a record written before the change stay valid. A declaration that uses the
  member is a new version of the declaration, and a preset that names it a new version of the
  preset.
- `event-time` and not `operation-time` takes the new version here: stories 16 and 21 of the
  wave make `operation-time@2`, and this story stays off that file.
- What the command does with the form is `story:assessor-learns-observation-in-ratchet`:
  `ratchet validate` refuses a plan that passes such an input, `ratchet assess` passes the
  values, and `ratchet evaluate` compares `runs` of a result with `runs` of the plan. It waits
  for the waves to 0.1.0 (`story:assessor-declaration`, `story:assess-command`,
  `story:evaluate-command`).
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of
  `.engineering/waves/0.1.0-ahead-2.md`, into one wave built in sequence on one branch: every
  planned wave starts behind `story:cli-skeleton-validate`, which waits for a release of ESS
  (beyond10x/ess#836), and this part needs no `ratchet` command. It is 5 of the 33 in the
  order of that page. It is the first of four stories that change § 10 of
  `docs/evidence-format.md` and the bullet "The rest of the invocation" of § 9; 6, 7 and 8
  follow, and 6 adds window keys to `ObservationKey`.
- It runs `task check:generated` when it edits `spec/domains/`.
- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s; the new
  broken copies are timed before they are added.
