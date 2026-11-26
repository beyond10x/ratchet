---
format: aep.planning-md/3
id: story:machine-as-a-condition
kind: story
status: implemented
title: A plan declares the machine and the build profile as conditions
summary: Declared condition keys for machine memory, an unused accelerator and the build profile of the measured binary.
relations:
- decomposes: epic:format-gaps-first-format-consumer
scope:
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
revision: 15
transitions:
- {from: "draft", to: "proposed", at: "2026-11-26T21:04:23Z", actor: "human:operator", revision: 13, decided_on: {"recorded":{"review_outcome":4}}}
- {from: "proposed", to: "active", at: "2026-11-26T21:04:23Z", actor: "human:operator", revision: 14, decided_on: {"recorded":{"review_outcome":4}}}
- {from: "active", to: "implemented", at: "2026-11-26T23:39:03Z", actor: "human:operator", revision: 15, decided_on: {"recorded":{"test_result":1,"review_outcome":4}}}
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

A phrase with a space in it may wrap in a Markdown paragraph or a folded YAML summary. So where
an item says that `grep -F` finds such a phrase in a `.md` or `.yaml` file, that it finds
nothing or the phrase is gone, or that `grep -c` of it prints a count, the check reads the
joined text of the file: `tr -s '\n ' '  ' < <file> | grep -o -F '<phrase>' | wc -l` prints 1
where the item says it is found, 0 where it says nothing or gone, and the count where it names
one. A name without a space, a row of a table, a pattern with `^`, `$` or `-E`, a check that
prints the line it matches and a check that reads the output of another command read the file
line by line, as written.

None of the four names occurs in `docs/`, `spec/`, `presets/` or `examples/` at `7b01ea1`, so
each grep below prints 0 before the story.

1. `spec/domains/specification.yaml`: `ratchet.specification.ObservationConditions` has the
   members `cpu_model`, `memory`, `accelerator` and `build_profile`, each `Optional<String>`
   with the meaning of the table above. Check: `grep -cE 'name: (cpu_model|memory|accelerator|build_profile)$'
   spec/domains/specification.yaml` prints 4; `ess specify validate --path spec
   --strict-requires` exits 0 and `task check:generated` passes.
2. The summary of `ObservationConditions` says "Seven have a defined meaning" in place of
   "Three have a defined meaning". Check: `grep -c 'Seven have a defined meaning'
   spec/domains/specification.yaml` prints 1 and `grep -c 'Three have a defined meaning'` prints
   0.
3. The summary of `ratchet.assessor.Assessor.conditions`, which says "beyond
   `host_load_per_cpu`, `tools` and `runner`", names the seven. Check: `grep -c
   build_profile spec/domains/assessor.yaml` prints 1.
4. `spec/presets.test.sh`, rule `assessor`: the copy `valid-inputs` states `build_profile:
   release` and `cpu_model` under `observation.conditions` of a plan whose assessor's
   declaration lists neither, and `sh spec/presets.test.sh` accepts it with no new copy,
   because the rule reads the members of `ObservationConditions` from the specification. The
   same copy against the specification of `7b01ea1` is refused with "is the condition
   `build_profile`, which is none of Ratchet itself". Check that the copy states them: the
   lines of the copy, `awk '$0 == "copy valid-inputs" {on = 1; next} on && /^accepts / {on =
   0} on' spec/presets.test.sh`, piped to `grep -c 'build_profile: release'` and
   to `grep -c 'cpu_model'` each print a number above 0 (0 each before).
5. The header of `spec/presets.test.sh` ("A condition of the observation is
   `host_load_per_cpu`, `tools`, `runner` or one the declaration lists") and the comment of the
   rule above the condition check ("one of the three that have a field in
   ratchet.specification.ObservationConditions") name the seven. Check: `grep -c accelerator
   spec/presets.test.sh` prints 2 (the case of item 4 names no `accelerator`).
6. `docs/design.md` § 3 "Measurement kind and observation conditions": the sentence "Three
   conditions have a defined meaning" reads "Seven conditions have a defined meaning". Check:
   `grep -c 'Seven conditions have a defined meaning' docs/design.md` prints 1.
7. The condition table of that section has the four rows. Check: `awk '/^### Measurement kind
   and observation conditions$/,/^### Scope and aggregation$/' docs/design.md | grep -cE
   '^\| `(cpu_model|memory|accelerator|build_profile)` \|'` prints 4.
8. `docs/design.md` § 5 "Protected references", rule 5 ("records the tools, image, runner,
   and host class that produced it"): a reference records the conditions its plan declares,
   the four included, and evidence with another value of one of them is not compared with it.
   Check: `awk '/^### Protected references$/,/^### Verdicts$/' docs/design.md | grep -c
   build_profile` prints a number above 0.
9. `docs/evidence-format.md` § 3 "`evidence.conditions`": a sentence under the table says
   that the four are held under `other` by their names, and the field tables do not change.
   Check: `grep -c accelerator docs/evidence-format.md` prints a number above 0, and the last
   line of `sh spec/record-fields.test.sh` is the one it printed before the story.
10. `ratchet.evidence.ObservedConditions.other`, whose summary says "Every further condition
    by name, such as the C library or the CPU model", names the four keys. Check: `grep -c
    accelerator spec/domains/evidence.yaml` prints 1.

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
