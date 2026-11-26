---
format: aep.planning-md/3
id: story:machine-as-a-condition
kind: story
status: draft
title: A plan declares the machine and the build profile as conditions
summary: Declared condition keys for machine memory, an unused accelerator and the build profile of the measured binary.
relations:
- decomposes: epic:format-gaps-first-format-consumer
scope:
- confidence: cited
  path: CHANGELOG.md
- confidence: cited
  path: docs/design.md
- confidence: cited
  path: docs/evidence-format.md
- confidence: cited
  path: spec/domains/assessor.yaml
- confidence: cited
  path: spec/domains/evidence.yaml
- confidence: cited
  path: spec/domains/specification.yaml
- confidence: cited
  path: spec/presets.test.sh
revision: 9
---
## Context

The repository `beyond10x/inference` wrote its quality definition against the formats at
commit `f139ecc` (2026-11-25). It is the first consumer of the formats outside this repository
and of this story. The finding comes from the correction round of that definition. Line numbers
below are those of `7b01ea1`.

Finding 19. A resource profile is measured on one reference machine. What makes two runs
comparable there: the CPU model, the memory of the machine, an accelerator that is present and
unused, and the build profile of the measured binary. A reference "records the tools, image,
runner, and host class that produced it" (`docs/design.md:583`, § 5 "Protected references",
rule 5), and `runner` is one text. The consumer wrote `conditions.local` with a runner name,
`execution: cpu`, `threads` and one tool version, declared `conditions: [execution, threads]`
on the assessor, and left the other three out of the record.

What the format holds today: three conditions have a defined meaning, `host_load_per_cpu`,
`tools` and `runner` (`docs/design.md:94-100`; `ratchet.specification.ObservationConditions`,
`spec/domains/specification.yaml:372-394`, "Three have a defined meaning" at `:381`). An
assessor declares others (`ratchet.assessor.Assessor.conditions`,
`spec/domains/assessor.yaml:182-188`), and a record holds them under `other`
(`ratchet.evidence.ObservedConditions.other`, `spec/domains/evidence.yaml:204-206`;
`docs/evidence-format.md:119`, "Every further condition that the plan or the assessor
declares"). So each assessor names the machine in words of its own, and a plan over two
assessors cannot state one machine. `spec/presets.test.sh` refuses a condition that is none of
the three and not in the declaration (`:1205-1206`, the case "a plan states a condition that
its assessor does not declare", `:2571`).

The decision this story takes, the reversible one (`AGENTS.md` § "Phase: implementation"):
four more conditions with a defined meaning, each text compared byte for byte as `runner` is,
and each held in a record under `other` by the same name.

| Condition | Meaning |
| --- | --- |
| `cpu_model` | The model of the CPU as the machine reports it |
| `memory` | The memory of the machine, in the words of the assessor, such as `64 GiB` |
| `accelerator` | The accelerator the machine holds, `none` where it holds none. Whether a run uses it is a condition the assessor declares, such as `execution: cpu` |
| `build_profile` | The build profile of the measured binary, such as `release` |

No member is added to `ratchet.evidence.ObservedConditions`: a record keeps them under `other`,
so the record format and the field tables of `docs/evidence-format.md` § 3 do not change.

## Acceptance

Every outcome below is observable without a `ratchet` command.

1. `spec/domains/specification.yaml`: `ratchet.specification.ObservationConditions` (`:372`)
   has the members `cpu_model`, `memory`, `accelerator` and `build_profile`, each
   `Optional<String>` with the meaning of the table above, and its summary says "Seven have a
   defined meaning". The summary of `ratchet.assessor.Assessor.conditions`
   (`spec/domains/assessor.yaml:182-188`, "beyond `host_load_per_cpu`, `tools` and `runner`")
   names the seven. Checked by `ess specify validate --path spec --strict-requires`, which
   exits 0, and by `task check:generated`.
2. `spec/presets.test.sh`, rule `assessor`: a plan of a copy that states
   `build_profile: release` and `cpu_model` under `observation.conditions` while the declaration
   of its assessor lists neither is accepted, because the rule reads the members of
   `ObservationConditions` from the specification (`:1205`). Before the story such a copy is
   refused with the message of `:1206` ("is the condition `build_profile`, which is none of
   Ratchet itself"); after it the copy `valid-inputs` (`:1887`, accepted at `:1906`) holds the two
   conditions and is accepted, with no new copy. The header of the rule (`:72-73`) and the
   comment of `:1198` name seven conditions of Ratchet itself.
3. `docs/design.md` § 3 "Measurement kind and observation conditions": the sentence "Three
   conditions have a defined meaning" (`:94`) says seven, and the table under it (`:96-100`) has
   the four rows. Text only, no case.
4. `docs/design.md` § 5 "Protected references", rule 5 (`:583`): a reference records the
   conditions its plan declares, the four included, and evidence with another value of one of
   them is not compared with it. Text only, no case.
5. `docs/evidence-format.md` § 3 "`evidence.conditions`": a sentence under the table
   (`:108-121`) says that the four are held under `other` by their names, and
   `ratchet.evidence.ObservedConditions.other` (`spec/domains/evidence.yaml:204-206`) says the
   same. `sh spec/record-fields.test.sh` and `sh spec/record-types.test.sh` print the counts
   they printed before. Checked by those two scripts and by `ess specify validate`.
6. `CHANGELOG.md` has its line under `## [Unreleased]`. Text only, no case.

## Notes

- Decision taken: four named conditions of the plan, held under `other` in a record (§ Context).
  A record member per condition was not taken: it would change a released record format for a
  value `other` already holds.
- An addition to a released format: a file written before the change stays valid, and a
  declaration that lists one of the four as its own condition stays valid.
- The command part, evidence with another value of a declared machine condition getting
  insufficient evidence with a cause that names the key, and a reference adopted under other
  values not being compared, is `story:machine-as-a-condition-in-ratchet`, which waits for the
  waves to 0.1.0 (`story:cli-skeleton-validate`, `story:evaluate-command`,
  `story:reference-compare`).
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of `.engineering/waves/0.1.0-ahead-2.md`,
  into one wave built in sequence on one branch: every planned wave starts behind
  `story:cli-skeleton-validate`, which waits for a release of ESS (beyond10x/ess#836), and this
  part needs no `ratchet` command. It is 20 of the 33 in the order of that page. Before it,
  `story:min-samples-per-scope-item` (19) adds a member to `ratchet.specification.Measurement`
  and writes into § 3 "Scope and aggregation"; after it, `story:plan-conditions-from-binding`
  (21) lets a binding pass the whole of `observation.conditions`, these four included.
  `docs/evidence-format.md` § 3 is changed before by stories 2 to 8 of the wave.
- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s; the copy
  `valid-inputs` is timed before and after its edit.
