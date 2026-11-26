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
revision: 25
---
## Context

Point 6 of "Not expressible yet" on `presets/latency.md` (`:272-282`), repeated as point 5 on
`presets/resources.md` (`:140`) and `presets/start.md` (`:129`) and named in point 4 on
`presets/operability.md` (`:186`) (`story:preset-catalog-runtime`), and finding 2 of
`review-result:adversary-preset-catalog-runtime-attack-1`. First consumer: the catalog, and
every project whose program reads a report of several runs.

What the formats say at the wave's base, `7b01ea1`:

- Ratchet passes an assessor the six reserved arguments and its declared inputs, "and nothing
  else" (`docs/evidence-format.md` § 10 "Invocation", `:683-697`). § 9, the bullet "The rest
  of the invocation" (`:674`), says that the contract does not say how an assessor learns the
  `scenarios`, the `workload`, the `command`, the `runs` and the `min_samples` of a plan.
- A plan names the workload twice: `event-time@1` passes the input `workload` to
  `timing-report@1` and writes `observation.workload` from the same input
  (`presets/event-time@1.preset.yaml`; `presets/timing-report@1.assessor.yaml`).
  `ratchet.assessor.Assessor` has `target_input` for the target and no member that names the
  input of the workload (`spec/domains/assessor.yaml:168`), and nothing checks that the two
  are the same in a plan a project writes by hand.
- The program is passed neither `runs` nor `min_samples`. For a percentile over the requests
  of all runs the `samples` of a result counts requests (`spec/domains/evidence.yaml:376`;
  `docs/evidence-format.md` § 3, the row `samples`, `:168`), so no record carries the number
  of runs: a report of one run with 200 requests satisfies a plan with `runs: 3`, against
  `docs/design.md` § 3 ("The evidence carries the count", `:87`).
- The first consumer of the formats met the same gap: an assessor is not passed the `command`
  of its plan (its report of 2026-11-25, from a read of `b8945e5`).
- The rule `assessor` of `spec/presets.test.sh` says "Every required input that is not local
  is passed" (its header), under `inputs`, and knows no other way an input gets its value.

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

Every outcome below is observable without a `ratchet` command. No item cites a line number.

1. `spec/domains/assessor.yaml`: the enum `ratchet.assessor.ObservationKey` with the values
   `scenarios`, `workload`, `command`, `runs` and `min_samples` (`grep -c 'name:
   ratchet.assessor.ObservationKey' spec/domains/assessor.yaml` prints 1; 0 before).
2. `spec/domains/assessor.yaml`, `ratchet.assessor.Assessor`: the member
   `observation_inputs`, whose summary says "an input named here is no reserved argument"
   (`grep -c 'name: observation_inputs' spec/domains/assessor.yaml` prints 1 and `grep -F`
   finds the phrase; neither before).
3. `spec/domains/evidence.yaml`, `ratchet.evidence.MeasurementResult`: the member `runs`,
   `Optional<Integer>` (`grep -c 'name: runs$' spec/domains/evidence.yaml` prints 1; 0
   before), with an invariant that only a result of the value type `number` has it: an
   invariant of `MeasurementResult` names `runs` (`grep -A140 'name:
   ratchet.evidence.MeasurementResult' spec/domains/evidence.yaml | grep -c
   'defined(runs)'` prints at least 1; 0 before). `ess specify validate --path spec
   --strict-requires` exits 0.
4. `docs/evidence-format.md` § 10: the declaration table has a row `observation_inputs` (13
   rows), and § 3, the table "A result of the value type `number`", a row `runs` (6 rows);
   the sentence of § 3 reads "There are 81 fields: 48 `spec`, 7 `changed`, 26 `new`". The
   scripts end with `record-fields: 103 of 103 field rows declared` and
   `record-types: 103 of 103 field rows as declared, 103 of 103 declared fields have a row`
   (101 after story 4).
5. `spec/README.md`, the paragraph that begins "Each script states how much it reads": it
   says "81 field rows in 13 tables of § 3 and 22 in 2 tables of § 10" (`grep -F` finds the
   phrase; "80 ... and 21" before).
6. `docs/evidence-format.md` § 10 "Invocation" says "Ratchet passes the value of each key
   named in `observation_inputs` as that input" (`grep -F` finds it; nothing before).
7. `docs/evidence-format.md` § 9, the bullet "The rest of the invocation", no longer names
   the keys of the observation: `grep -F '(`scenarios`, `workload`, `command`, `runs`,
   `min_samples`)' docs/evidence-format.md` prints nothing (one line before).
8. The open question of the round, answered: at the base the rule `assessor` of
   `spec/presets.test.sh` does not exempt an input named in `observation_inputs`. It requires
   every required input that is not local under `inputs`, so `event-time@2`, which writes the
   workload once under `observation`, would be refused as missing its input. The story
   changes the rule: an input that the declaration names in `observation_inputs` is passed
   by that key of the plan's `observation`, and the header of the rule says "is passed by
   the key of the plan's `observation`" (`grep -F` finds it in `spec/presets.test.sh`;
   nothing before). `event-time@2` is valid (item 12).
9. `spec/presets.test.sh` refuses a plan that passes a value under `inputs` to an input its
   assessor names in `observation_inputs`, with the message of its rule: the new case
   `observation-input-passed-twice` is refused. Before the story the same copy is accepted.
10. `spec/presets.test.sh` refuses a declaration whose `observation_inputs` names an input it
    does not declare, with the message of its rule: the new case
    `observation-input-undeclared` is refused. Before the story the same copy is accepted.
11. `presets/timing-report@2.assessor.yaml` (new) maps `workload`, `runs` and `min_samples`
    under `observation_inputs`, and `presets/event-time@2.preset.yaml` (new) names it and
    writes the workload once, under `observation`; `event-time@1` and `timing-report@1` stay
    byte for byte (`git diff --quiet 7b01ea1 -- presets/event-time@1.preset.yaml
    presets/timing-report@1.assessor.yaml` exits 0).
12. `presets/latency.md` has the section and the row of `event-time@2`, and with item 11 and
    the two cases `spec/presets.test.sh` ends with
    `presets: 57 of 57 file(s) valid, 50 of 50 measurement(s) with a row, 101 of 101 broken copies refused`
    (55 files, 49 measurements and 99 copies before).
13. `presets/latency.md`, point 6 of "Not expressible yet", is rewritten in place: it says
    that `observation_inputs` answers it from `event-time@2` on, and keeps its number
    (`grep -c 'observation_inputs' presets/latency.md` prints at least 1; 0 before).
14. `presets/resources.md` and `presets/start.md`, point 5 of "Not expressible yet", are
    rewritten in place: each says that `ratchet.assessor.Assessor` has `observation_inputs`
    and that no preset of the family uses it yet, and keeps its number (`grep -c
    'observation_inputs'` prints at least 1 in each page; 0 before).
15. `presets/operability.md`, point 4 of "Not expressible yet", is rewritten in place in the
    same words (`grep -c 'observation_inputs' presets/operability.md` prints at least 1; 0
    before).

## Notes

- An addition to two released formats, `ratchet-assessor/1` and `ratchet-evidence/1`: a
  declaration and a record written before the change stay valid. A declaration that uses the
  member is a new version of the declaration, and a preset that names it a new version of the
  preset.
- `event-time` and not `operation-time` takes the new version here: stories 16 and 21 of the
  wave make `operation-time@2`, and this story stays off that file. The pages of the
  resources, start and operability families keep their presets; their points say that the
  member exists and is not used there yet.
- What the command does with the form is `story:assessor-learns-observation-in-ratchet`:
  `ratchet validate` refuses a plan that passes such an input, `ratchet assess` passes the
  values, and `ratchet evaluate` compares `runs` of a result with `runs` of the plan. It waits
  for the waves to 0.1.0 (`story:assessor-declaration`, `story:assess-command`,
  `story:evaluate-command`).
- Its line of `CHANGELOG.md` is written by the closing commit of the wave (`AGENTS.md`
  § "Changelog lines"; the wave record names the heading and the token).
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
