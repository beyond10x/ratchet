---
format: aep.planning-md/3
id: story:value-over-all-runs-in-ratchet
kind: story
status: draft
title: ratchet validate holds a sampled measurement over several runs to an aggregation or a value over all runs
summary: 'The command part of story:value-over-all-runs: acceptance and refusal with a code.'
relations:
- decomposes: epic:preset-catalog
- depends_on: story:value-over-all-runs
- depends_on: story:cli-skeleton-validate
- depends_on: story:evaluate-command
revision: 1
---
## Context

Split on 2026-11-26 from `story:value-over-all-runs`, which writes into `docs/design.md` § 3
and `spec/domains/specification.yaml` the form by which a sampled measurement states that its
value is computed over all runs of its plan, gives it to `flake-rate@2`, and makes
`spec/presets.test.sh` refuse a literal `runs` above 1 that states neither the form nor an
aggregation. This story holds the part that needs the `ratchet` command.

## Acceptance

`ratchet validate` accepts a sampled measurement that states its value is computed over all
runs of its plan with `runs` above 1, and refuses a measurement with `runs` above 1 that
states neither this nor an aggregation, with a code that names the rule; before the story no
command reads the form.

## Notes

- Moved from the acceptance of `story:value-over-all-runs`, verbatim but for the code.
- `spec/presets.test.sh` reads a literal `runs` only. The command also sees a `runs` that a
  binding passes; whether `validate` refuses a binding of `flake-rate@1` that passes `runs`
  above 1 is this story's to decide and write into `docs/design.md`.
- The story is a draft. It waits for the waves to 0.1.0 and for `ratchet evaluate`:
  `story:cli-skeleton-validate` and `story:evaluate-command`.
