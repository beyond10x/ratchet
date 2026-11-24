---
format: aep.planning-md/3
id: story:ui-loop-acceptance
kind: story
status: active
title: Acceptance run in the shape of the first consumer's UI loop
summary: 'Seven counted steps against the ratchet binary: validate, assess, adopt, pass, reject, tolerance, trusted policy.'
relations:
- decomposes: epic:first-consumer-ui-loop
- depends_on: story:cli-skeleton-validate
- depends_on: story:assessor-declaration
- depends_on: story:record-formats-in-spec
scope:
- confidence: cited
  path: ROADMAP.md
- confidence: cited
  path: acceptance
revision: 6
transitions:
- {from: "draft", to: "proposed", at: "2026-11-24T13:10:22Z", actor: "agent:ratchet", revision: 4, decided_on: {"recorded":{"review_outcome":2}}}
- {from: "proposed", to: "active", at: "2026-11-24T13:10:22Z", actor: "agent:ratchet", revision: 5, decided_on: {"recorded":{"review_outcome":2}}}
---
## Context

The consumer's loop measures 12 keys per scenario (counts, a reading load, a layout shift) and
compares each with `baseline.json`. In `ratchet/1` a key is a measurement with a requirement of
its own and a scenario is a scope item (design § 5 "Trade-offs"). The acceptance run states the
consumer's first gap as steps a program can count.

## Acceptance

`task acceptance:ui-loop` runs seven numbered steps against the built `ratchet` binary in a scratch git
repository made from `acceptance/ui-loop/`, prints one line `ok` or `FAIL` per step and a last
line `acceptance ui-loop: <n> of 7 steps pass`, writes the command and the output of every step
to `target/acceptance/ui-loop/transcript.txt`, exits 0 only at 7 of 7, and on the day this story
merges prints the count the merged commands reach, which is at least 1 (step 1).

## The seven steps

The fixture has two states. The observe state holds 4 measurements and one assessment plan, no
requirement and no gate. The gated state adds one requirement with a `reference` per measurement
and the gate `merge`.

1. In the observe state `ratchet validate` accepts the project.
2. `ratchet assess` records one run with the values of 3 scenarios and 4 keys.
3. In the gated state `ratchet validate` accepts the project and `ratchet reference adopt` writes
   a first reference for each requirement.
4. With the gated state and the references committed on the trusted revision, `ratchet evaluate
   --gate merge` passes for a candidate with the same values.
5. For a candidate with one worse value it exits 1 with `gate_failed`, and the output names the
   requirement, the scenario, the observed value, the allowed value and the evidence record.
6. For a candidate whose value is worse within the key's tolerance it passes.
7. For a candidate that also loosens the reference in its own tree it still exits 1.

## Scope

- `acceptance/ui-loop/`: `ratchet.toml` with a catalog directory, the two states of
  `ratchet.yaml`, `quality/assessors/ui-loop@1.assessor.yaml`, a POSIX sh assessor that writes a
  prepared `ratchet-evidence/1` document chosen by an input, the prepared documents, `run.sh`
- `acceptance/Taskfile.yml`: the task `ui-loop` (the root `Taskfile.yml` includes this file as
  `acceptance` since `story:workspace-cli-contract`); `check` does not call it in this story
- `ROADMAP.md`: the line with the count

## Notes

- The fixture is written in the forms `story:record-formats-in-spec` declares (the evidence
  fields, the catalog directory, the long-form bounds), and step 1 passes with the declaration
  checks of `story:assessor-declaration` in `ratchet validate`.
- The transcript holds, per step, the command line as a project would type it and the output it
  printed, with the scratch path and the record ids replaced by fixed words, so two runs write
  the same bytes. `story:acceptance-in-gate` compares the getting-started page with it.
- `run.sh` is POSIX sh. It builds nothing: it takes the path of the binary as an argument, and
  the task builds the binary first. It is not started with the `slot` prefix beyond that build.
- The fixture's numbers are the consumer's shape and not its data: scenarios and keys have
  neutral names.
- The whole run ends within 60 s; it is one step of the 120 s budget once it joins the gate.
- No Python.
- A step that fails because its command is not built yet is the expected state, and the run still
  exits non-zero; only `check` must stay green.
