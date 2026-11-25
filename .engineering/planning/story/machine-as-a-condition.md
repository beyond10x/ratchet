---
format: aep.planning-md/3
id: story:machine-as-a-condition
kind: story
status: draft
title: A plan declares the machine and the build profile as conditions
summary: Declared condition keys for machine memory, an unused accelerator and the build profile of the measured binary.
relations:
- decomposes: epic:format-gaps-first-format-consumer
revision: 1
---
## Context

The repository `beyond10x/inference` wrote its quality definition against the formats at
commit `f139ecc` (2026-11-25). It is the first consumer of the formats outside this repository
and of this story. The finding comes from the correction round of that definition.

Finding 19. A resource profile is measured on one reference machine. What makes two runs
comparable there: the CPU model, the memory of the machine, an accelerator that is present and
unused, and the build profile of the measured binary. A reference "records the tools, image,
runner, and host class that produced it" (`docs/design.md` § 5, rule 5), and `runner` is one
text. No declared key holds the memory of the machine, an unused accelerator or the build
profile. The consumer wrote `conditions.local` with a runner name, `execution: cpu`, `threads`
and one tool version, declared `conditions: [execution, threads]` on the assessor, and left
the other three out of the record.

## Acceptance

A plan declares the machine facts and the build profile a sampled measurement depends on as
conditions with declared keys, a record carries their values, and evidence from a machine
with another value is not compared with the reference and gets insufficient evidence with a
cause that names the key; before the story `ratchet validate` refuses the keys or the record
cannot hold them.

## Notes

- The form shown is the consumer's proposal or what it wrote in place of the missing form.
  The story decides the form, declares it in `spec/` first (`ess specify validate` passes), and
  writes it into `docs/design.md` or `docs/evidence-format.md` in the same change.
- A new value or field of a released format is an addition: a file written for the format
  before the change stays valid.
- The story is a draft. It was there before the planned waves to 0.1.0 and waits for them.
