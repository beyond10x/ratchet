---
format: aep.planning-md/3
id: story:assessor-learns-observation-in-ratchet
kind: story
status: draft
title: ratchet passes an assessor the observation of its plan and compares the runs
summary: 'The command part of story:assessor-learns-observation: validate refuses a mapped input passed twice, assess passes it, evaluate compares runs.'
relations:
- decomposes: epic:preset-catalog
- depends_on: story:assessor-learns-observation
- depends_on: story:cli-skeleton-validate
- depends_on: story:assessor-declaration
- depends_on: story:assess-command
- depends_on: story:evaluate-command
scope:
- confidence: inferred
  path: crates/ratchet
- confidence: inferred
  path: crates/ratchet-core
revision: 3
---
## Context

Split on 2026-11-26 from `story:assessor-learns-observation`, which declares
`observation_inputs` on a `ratchet-assessor/1` declaration and `runs` on a number result,
writes the rule into `docs/evidence-format.md` § 10, gives it to `timing-report@2` and
`event-time@2`, and makes `spec/presets.test.sh` refuse a plan that passes such an input
itself. This story holds the part that needs the `ratchet` command.

## Acceptance

`ratchet validate` refuses a plan that passes a value under `inputs` to an input its
assessor names in `observation_inputs`, with a code that names the input; `ratchet assess`
passes the value of each mapped key of the plan's observation as that input, so a stand-in
assessor in a fixture receives `--runs 3` for a plan with `runs: 3`; and `ratchet evaluate`
gives insufficient evidence, with a cause that names both numbers, for a result whose `runs`
is below the `runs` of its plan. Before the story no command reads a plan or a record.

## Notes

- Moved from the acceptance of `story:assessor-learns-observation`, but for the codes.
- The story is a draft. It waits for the waves to 0.1.0: `story:cli-skeleton-validate`,
  `story:assessor-declaration`, `story:assess-command` and `story:evaluate-command`.
