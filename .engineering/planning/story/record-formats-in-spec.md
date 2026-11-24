---
format: aep.planning-md/3
id: story:record-formats-in-spec
kind: story
status: implemented
title: 'The specification for 0.1.0: record formats, long-form bounds, refusals'
summary: 'Every specification change 0.1.0 needs, in one change before code is generated: ratchet-evidence/1, ratchet-assessor/1, E7 to E9 as A, no shorthands, the catalog directory.'
relations:
- decomposes: epic:runnable-cli
scope:
- confidence: cited
  path: Taskfile.yml
- confidence: cited
  path: docs/design.md
- confidence: cited
  path: docs/evidence-format.md
- confidence: cited
  path: examples
- confidence: cited
  path: research/candidate-presets.md
- confidence: cited
  path: spec/README.md
- confidence: cited
  path: spec/cli-coverage-row.test.sh
- confidence: cited
  path: spec/cli-errors.test.sh
- confidence: cited
  path: spec/cli.yaml
- confidence: cited
  path: spec/contract-examples.test.sh
- confidence: cited
  path: spec/domains/assessor.yaml
- confidence: cited
  path: spec/domains/cli.yaml
- confidence: cited
  path: spec/domains/config.yaml
- confidence: cited
  path: spec/domains/evidence.yaml
- confidence: cited
  path: spec/domains/gate.yaml
- confidence: cited
  path: spec/domains/reference.yaml
- confidence: cited
  path: spec/domains/specification.yaml
- confidence: cited
  path: spec/gate-inputs.test.sh
- confidence: cited
  path: spec/record-examples.test.sh
- confidence: cited
  path: spec/record-fields.test.sh
- confidence: cited
  path: spec/record-types.test.sh
revision: 15
transitions:
- {from: "draft", to: "proposed", at: "2026-11-24T13:10:21Z", actor: "agent:ratchet", revision: 6, decided_on: {"recorded":{"review_outcome":4}}}
- {from: "proposed", to: "active", at: "2026-11-24T13:10:21Z", actor: "agent:ratchet", revision: 7, decided_on: {"recorded":{"review_outcome":4}}}
- {from: "active", to: "implemented", at: "2026-11-24T17:42:01Z", actor: "agent:ratchet", revision: 15, decided_on: {"recorded":{"test_result":1,"review_outcome":24,"verification":1}}}
---
## Context

`docs/evidence-format.md` names the file form of an assessment run, `ratchet-evidence/1`, and the
assessor declaration `ratchet-assessor/1`. It counts 78 fields of the evidence document: 48 are in
the specification as written, 7 are there with another name, type or number, and 23 are not there
(§ 3). Its § 8 lists what the ESS specification needs, items 1 to 25. The specification is still
at revision 3 and does not declare the two formats, so code that reads an evidence file would use
nouns no specification declares.

Every generated file carries a digest of the whole specification, so each specification change
rewrites both generated crates. This story is therefore the one owner of every specification
change 0.1.0 needs. It lands alone, before any generated file exists on `main`;
`story:cli-skeleton-validate` then generates once.

Measured on 2026-11-24 with `ess` 0.98.0 at `7673482`: `ess generate synthesize --path spec
--target rust --layout crate` refuses the specification, because three structs declare a
`shorthand:` (`MinimumBound`: `min`, `MaximumBound`: `max`, `RatchetPolicy`: `from`) and the Rust
target decodes a struct from its object only. With the three lines removed it writes one crate
(13 artifacts, 203 capabilities, 0 obligations, 0 refused).

## Decisions taken with this story

Each is reversible before the first release, and each is written into `docs/design.md` and the
specification in this change.

1. The three shorthands leave the specification until the ESS Rust target decodes them. A
   coverage bound is written `{min: 18}` or `{max: 0}` and an adoption `{from: same_change}`. The
   bare spellings of design § 3 and § 5 can return later without breaking a document written in
   the long form. The story reports the ESS refusal text so the gap can be filed with ESS.
2. E7, E8 and E9 of `docs/evidence-format.md` are taken as A, the defaults the document is
   written under: every value is an argument, one YAML declaration per assessor and version, a
   run that refused its inputs is recorded as `refused_inputs`. Marked there as "taken as A for
   0.1.0, 2026-11-24".
3. A catalog source without `git` is a directory relative to the root (`[catalog] sources =
   [{ path = "quality/assessors" }]`), and a declaration is the file
   `<name>@<version>.assessor.yaml` in a source. It replaces the `UNMAPPED:` marker in
   `spec/domains/config.yaml` and goes into design § 5 "Local config".
4. `reference-adopt` and `reference-propose` get the refusal `requirement_without_reference` in
   `spec/cli.yaml`, for a requirement that holds a `condition` and no `reference`.
5. In a comparison, a scope item the evidence holds and the reference does not is
   `reference_missing` for that item; a scope item the reference holds and the evidence does not
   is `coverage_below_plan`. Both are insufficient evidence (design § 5 "Verdicts").
6. `ratchet evaluate` without `--trusted` reads the policy at the merge base of `HEAD` and
   `origin/main` (design § 5 "Proposed CLI").
7. A requirement with no qualifying run gets the cause design § 5 "Verdicts" names for it. If the
   list of `ratchet.gate.VerdictCause` has none, the story declares `evidence_missing` and
   reports it.
8. Without a `[records]` section in `ratchet.toml`, or with one whose `store` names no path, the
   local record directory is `.ratchet/records` under the root (`spec/domains/config.yaml`,
   design § 6).

## Acceptance

`slot task check:spec` exits 0 and prints the line `record-fields: <n> of <n> field rows
declared` from `spec/record-fields.test.sh` and the line of `ess generate synthesize --target
rust` that reports 0 refused, where on the specification of commit `7673482` the same script
exits 1 and names the missing fields and the generator refuses the three `shorthand:` structs.

## Scope

- `spec/domains/evidence.yaml`, `spec/domains/assessor.yaml`: every field of
  `docs/evidence-format.md` § 3 and § 10, with `evidence` and `run` as two structs
- `spec/domains/reference.yaml`: only where `ratchet-reference/1` of design § 3 and § 5 names a
  field the specification lacks
- `spec/domains/gate.yaml`: § 8 item 5 (the `VerdictCause` split) and decision 7
- `spec/domains/specification.yaml`: decision 1 and § 8 item 13 (the target kind `document`)
- `spec/domains/config.yaml`: decisions 3 and 8
- `spec/cli.yaml` and `spec/domains/cli.yaml`: § 8 item 25 (`assess`) and decision 4
- `spec/README.md`: § "Where this specification still departs"
- `spec/record-fields.test.sh`: POSIX sh. It reads the field rows of `docs/evidence-format.md`
  § 3 and § 10 and checks each against the two domain files, under the name the row gives or the
  name § 8 maps it to
- `docs/evidence-format.md`: each item of § 8 marked done with its spelling in the
  specification, or marked left out of 0.1.0 with the reason; E7 to E9 marked taken
- `docs/design.md`, `examples/`: the decisions above
- `Taskfile.yml`: `check:spec` also runs `spec/record-fields.test.sh` and a synthesis into a
  scratch directory that fails on a refusal

## Notes

- Specification, documents and one script: no Rust and no generated file in the tree.
- Red first: `spec/record-fields.test.sh` is written first and exits 1 on the specification as
  it is.
- The rules 1 to 7 and 9 of `docs/evidence-format.md` § 4 are written as ESS invariants where one
  entity or struct holds every field the rule reads; the others stay listed in § 8.
- The three other `UNMAPPED:` markers (`assessor.yaml`, the `record-series@1` coverage unit;
  `specification.yaml`, the absent `selection` default and the list type spelling) stay unless a
  field of this story reads them; the story reports which stayed.
- The story times `task check:spec` before and after and reports the two times; the step stays
  within the 120 s budget. `ess specify validate --path spec --strict-requires` stays green.
- No Python.
