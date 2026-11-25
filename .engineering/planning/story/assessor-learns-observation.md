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
- confidence: inferred
  path: CHANGELOG.md
- confidence: inferred
  path: docs/evidence-format.md
- confidence: inferred
  path: presets
- confidence: inferred
  path: spec/domains/assessor.yaml
- confidence: inferred
  path: spec/domains/evidence.yaml
revision: 7
---
## Context

Point 6 of "Not expressible yet" on `presets/latency.md`, repeated on `presets/resources.md`,
`presets/start.md` and `presets/operability.md` (`story:preset-catalog-runtime`), and finding
2 of `review-result:adversary-preset-catalog-runtime-attack-1`. First consumer: the catalog,
and every project whose program reads a report of several runs.

Ratchet passes an assessor its declared inputs and nothing of the `observation` of the plan
(`docs/evidence-format.md` § 10, "Invocation"); § 9 says that the contract does not say how an
assessor learns the `scenarios`, the `workload`, the `command`, the `runs` and the
`min_samples` of a plan. What follows in the four families:

- A plan names the workload twice, as `observation.workload` and as the input `workload`.
  `ratchet.assessor.Assessor` has `target_input` for the target and no member that names the
  input of the workload (`spec/domains/assessor.yaml`), and nothing checks that the two are
  the same in a plan a project writes by hand.
- The program is passed neither `runs` nor `min_samples`. The tool of the project makes the
  runs and the program aggregates over the runs its report holds. For a percentile over the
  requests of all runs (`operation-time@1`, `event-time@1`) the `samples` of a result counts
  requests, so no record carries the number of runs: a report of one run with 200 requests
  satisfies a plan with `runs: 3`, against `docs/design.md` § 3 ("The evidence carries the
  count").

## Acceptance

An assessor declaration names the inputs that hold the workload, the number of runs and the
least number of samples of its plan, `ratchet validate` refuses a plan whose observation
differs from the value of such an input, and an evidence record of a sampled result carries
the number of runs it was aggregated over, which `ratchet evaluate` compares with `runs` of
the plan; before the story the values are written twice with no check and a percentile result
carries no number of runs.

## Notes

- Also met by the first consumer of the formats, `beyond10x/inference` (its report of
  2026-11-25, from a read of `b8945e5`): an assessor is not passed the `command` of its plan,
  so the consumer's first assessor program takes two arguments of its own, the file a run
  left behind and the source of the run. The form this story decides covers `command` and
  `scenarios` with the three members its acceptance names.
- The story decides the form (members beside `target_input`, or Ratchet passes the observation
  of the plan as reserved arguments), declares it in `spec/` first and writes it into
  `docs/evidence-format.md` § 9 and § 10 in the same change.
- An addition to two released formats, `ratchet-assessor/1` and `ratchet-evidence/1`; a
  declaration that uses it is a new version of the declaration.
- The story is a draft. It waits for the waves to 0.1.0 and for `ratchet evaluate`.
