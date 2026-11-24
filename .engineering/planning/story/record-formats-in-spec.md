---
format: aep.planning-md/3
id: story:record-formats-in-spec
kind: story
status: draft
title: Declare ratchet-evidence/1 and ratchet-assessor/1 in the specification
summary: Bring spec/domains/evidence.yaml and assessor.yaml to docs/evidence-format.md; take E7 to E9 as A.
relations:
- decomposes: epic:runnable-cli
scope:
- confidence: cited
  path: docs/evidence-format.md
- confidence: cited
  path: spec/domains/assessor.yaml
- confidence: cited
  path: spec/domains/evidence.yaml
- confidence: cited
  path: spec/domains/reference.yaml
revision: 2
---
## Context

`docs/evidence-format.md` names the file form of an assessment run, `ratchet-evidence/1`, and the
assessor declaration `ratchet-assessor/1`. It counts 78 fields of the evidence document: 48 are in
the specification as written, 7 are there with another name, type or number, and 23 are not there
(§ 3). Its § 8 lists what the ESS specification needs, items 1 to 25. The specification
(`spec/domains/evidence.yaml`, `assessor.yaml`) is still at revision 3 and does not declare the
two formats, so code that reads an evidence file would use nouns no specification declares.

The questions E7 to E9 of that document are open and written under default A: every value is an
argument (E7), one YAML declaration per assessor and version (E8), a run that refused its inputs
is recorded as `refused_inputs` (E9).

## Decision taken with this story

E7, E8 and E9 are taken as A, the defaults the document is written under. Each is reversible
before the first release that reads an assessor's declaration. The story marks them in
`docs/evidence-format.md` as "taken as A for 0.1.0, 2026-11-24".

## Acceptance

`task check:spec` exits 0 on a specification in which `spec/domains/evidence.yaml` declares every
field of `ratchet-evidence/1` (the 78 of `docs/evidence-format.md` § 3, with `evidence` and `run`
as two structs) and `spec/domains/assessor.yaml` declares every field of `ratchet-assessor/1`
(§ 10), and `docs/evidence-format.md` § 8 lists each field whose spelling differs between the document and the
specification, or says there is none.

## Scope

- `spec/domains/evidence.yaml`
- `spec/domains/assessor.yaml`
- `spec/domains/reference.yaml`: only where `ratchet-reference/1` of design § 3 and § 5 names a
  field the specification lacks
- `docs/evidence-format.md`: § 8 items marked done with the spelling differences, E7 to E9 marked
  taken

## Notes

- Specification only: no Rust, no generated file. It lands beside `story:cli-skeleton-validate`;
  whichever of the two merges second regenerates `crates/ratchet-model/` in its own change, and
  the drift check names the files.
- The rules 1 to 7 and 9 of `docs/evidence-format.md` § 4 are written as ESS invariants where one
  entity or struct holds every field the rule reads; the others are listed in `docs/evidence-format.md`
  § 8. `spec/README.md` belongs to `story:cli-skeleton-validate` in this wave.
- `spec/domains/specification.yaml` belongs to `story:cli-skeleton-validate` in this wave. A
  change this story needs there (the target kind `document`, E1) is reported, not made.
