---
format: aep.planning-md/3
id: story:window-over-outside-population
kind: story
status: draft
title: An assessor of a window over a population outside the record store learns its window
relations:
- decomposes: epic:ci-turnaround
revision: 1
---
## Context

Found by a consumer writing a `ratchet/1` file at 0.0.3: a time window is defined only over the
runs of another plan, read by `record-series@1`.

The design gives a window a second population, `{filter: {...}}`, read by the assessor outside
the record store (`docs/design.md:172`), with the fields the assessor declares
(`ratchet.assessor.Assessor.population_fields`, `spec/domains/assessor.yaml:205`). No contract
says how such an assessor learns its window. The invocation passes `--project`, `--assessment`,
`--root`, `--class`, `--out`, `--revision` and the declared inputs, and nothing else
(`docs/evidence-format.md:685-697`). The contract does not cover a plan without a selection or a
target of another kind than `revision` or `document` (`docs/evidence-format.md:674`). So the
`window` and the `filter` of a plan reach no program, and the bounds in
`evidence.target.window` are the assessor's guess.

## Acceptance

- The invocation contract passes an assessor the window of its plan (`length`, `last`) and the
  fields of its `population: {filter}`, and covers a time-window plan without a `selection`;
  before the story `docs/evidence-format.md` § 9 lists both as not covered.
- `ratchet assess` refuses a record of such a plan whose `target.window` lies outside the
  window it passed, with a cause that names the plan. This part waits for the waves to 0.1.0.
- An example plan with a `{filter}` population and a declaration of its assessor decode under
  the specification; before the story no example uses the shape (`docs/design.md:72`).

## Notes

- The story decides the form (reserved arguments or declared inputs), declares it in `spec/`
  first and writes it into `docs/evidence-format.md` § 10. A new reserved argument is a new
  version of the declaration format (`docs/evidence-format.md:697`).
- Partly answered by the design: the shape of a `{filter}` window exists; this story covers how
  it reaches the assessor.
- Filed under `epic:ci-turnaround` as the closest epic: it uses a time window first
  (`docs/design.md:820`). No epic holds windows over a population outside the record store.
- Related: `story:assessor-learns-observation` (`runs`, `min_samples`, `workload`, `command`,
  `scenarios`; not the window or the population), `story:build-target-invocation`.
