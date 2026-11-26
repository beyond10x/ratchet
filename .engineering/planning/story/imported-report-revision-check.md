---
format: aep.planning-md/3
id: story:imported-report-revision-check
kind: story
status: draft
title: An imported report of another revision is refused
summary: A report states the revision or source digest it was produced from, and assess refuses one that is not the candidate's.
relations:
- decomposes: epic:format-gaps-second-format-consumer
scope:
- confidence: cited
  path: CHANGELOG.md
- confidence: cited
  path: docs/evidence-format.md
- confidence: inferred
  path: presets/conformance-report@2.assessor.yaml
- confidence: cited
  path: presets/functional.md
- confidence: cited
  path: spec/README.md
- confidence: cited
  path: spec/domains/assessor.yaml
- confidence: cited
  path: spec/domains/evidence.yaml
- confidence: cited
  path: spec/record-fields.test.sh
- confidence: cited
  path: spec/record-types.test.sh
revision: 18
---
## Context

The repository `beyond10x/swell`, a script engine, drafted its quality definition against the
formats at commit `90924c9` (2026-11-25). It is the first consumer of this story. Its
conformance run writes a result file that Git ignores; a file left from a run of another
revision is read as it is, and the evidence names the candidate's revision, so a stale report
counts as the candidate's. The consumer guards its own expected file with a digest of its
sources; the formats have nothing for it.

What the formats say at the wave's base, `7b01ea1`:

- An assessor writes the revision it is given and looks none up (`docs/evidence-format.md`
  § 3, the row `revision` of `evidence.target`, `:85`; § 10 "The revision", Q9, `:699`).
- A resolved input holds `value`, `digest` and `digest_form` (`docs/evidence-format.md` § 3
  `evidence.inputs.<name>`, `:100-106`; `ratchet.evidence.ResolvedInput`,
  `spec/domains/evidence.yaml:137-162`): the digest of the report's bytes, and nothing of the
  revision it was produced from.
- `conformance-report@1`, `comparison-report@1` and `case-list@1` of the catalog import a report
  in this way (`presets/conformance-report@1.assessor.yaml`: the input `report`, a path).
  `ratchet.assessor.Assessor` says nothing of what a report states
  (`spec/domains/assessor.yaml:134-218`).

## Decision

Taken as the reversible answer (`AGENTS.md` § "Phase: implementation"):

- A declaration may list `revision_inputs`: the inputs whose file states the revision it was
  produced from. The assessor reads that revision from the file and writes it as
  `evidence.inputs.<input>.revision`.
- A report named there that states no revision is refused: the assessor exits 1, which the CLI
  records as `refused_inputs` (format § 10 "Exit status", E9).
- A report whose revision is not the candidate's is refused by `ratchet assess`, with a cause
  that names both (the command part).
- The digest of the sources is left out: it needs the list of the sources, which no
  declaration names. § 9 says so.

## Acceptance

Every outcome below is observable without a `ratchet` command.

1. `spec/domains/assessor.yaml`: `Assessor.revision_inputs` (`Optional<List<String>>`), whose
   summary states the decision; `spec/domains/evidence.yaml`: `ResolvedInput.revision`
   (`Optional<ratchet.specification.Revision>`). Checked by
   `ess specify validate --path spec --strict-requires` (exit 0).
2. `docs/evidence-format.md` § 10: the declaration table has a row `revision_inputs` (14
   rows), and "The revision" and "Exit status" say how such a report is read and when it is
   refused; § 3 `evidence.inputs.<name>` has a row `revision` (4 rows), and the sentence
   "There are 81 fields" of 5 reads 82, with 27 `new`. Checked by
   `sh spec/record-fields.test.sh` and `sh spec/record-types.test.sh`: the lines of the two
   tables state 14 and 4 rows in both scripts, and their last lines count 105 field rows, 82
   of § 3 and 23 of § 10 (103 after 5). `spec/README.md` says "82 field rows in 13 tables of
   § 3 and 23 in 2 tables of § 10". § 9 names the digest of the sources as not in version 1.
3. `presets/conformance-report@2.assessor.yaml` (new) lists `revision_inputs: [report]`;
   `conformance-report@1` stays byte for byte. `presets/functional.md` names the new version
   beside the old one. Checked by `spec/presets.test.sh`, rules `place` and `type`: its last
   line counts one more file valid.
4. `CHANGELOG.md` has its line under `## [Unreleased]`. Text only, no case.

## Notes

- An addition to released formats: a declaration and a record written before the change stay
  valid. A declaration that uses it is a new version of the declaration. A preset that names
  `conformance-report@2` is a later version of `conformance-cases`; this story makes none, and
  `comparison-report` and `case-list` keep their versions.
- `presets/functional.md` is in the set of the broken copies of `spec/presets.test.sh`
  (`set_files`): the line it adds is placed where no case edits.
- `ratchet assess` refusing a report of another revision is
  `story:imported-report-revision-check-in-ratchet`, which waits for the waves to 0.1.0
  (`story:assess-command`).
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of
  `.engineering/waves/0.1.0-ahead-2.md`, into one wave built in sequence on one branch: every
  planned wave starts behind `story:cli-skeleton-validate`, which waits for a release of ESS
  (beyond10x/ess#836), and this part needs no `ratchet` command. It is 8 of the 33 in the
  order of that page. It adds the last field rows of the wave to § 3 and § 10, after 2, 4 and
  5, and changes § 10 after 5, 6 and 7.
- It runs `task check:generated` when it edits `spec/domains/`.
- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s.
