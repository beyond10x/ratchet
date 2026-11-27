---
format: aep.planning-md/3
id: story:imported-report-revision-check
kind: story
status: implemented
title: An imported report of another revision is refused
summary: A report states the revision or source digest it was produced from, and assess refuses one that is not the candidate's.
relations:
- decomposes: epic:format-gaps-second-format-consumer
scope:
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
revision: 24
transitions:
- {from: "draft", to: "proposed", at: "2026-11-26T21:04:21Z", actor: "human:operator", revision: 22, decided_on: {"recorded":{"review_outcome":4}}}
- {from: "proposed", to: "active", at: "2026-11-26T21:04:21Z", actor: "human:operator", revision: 23, decided_on: {"recorded":{"review_outcome":4}}}
- {from: "active", to: "implemented", at: "2026-11-26T23:39:01Z", actor: "human:operator", revision: 24, decided_on: {"recorded":{"test_result":1,"review_outcome":4}}}
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
  § 3, the row `revision` of `evidence.target`, `:86`; § 10 "The revision", Q9, `:699`).
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

Every outcome below is observable without a `ratchet` command. No item cites a line number.

A phrase with a space in it may wrap in a Markdown paragraph or a folded YAML summary. So where
an item says that `grep -F` finds such a phrase in a `.md` or `.yaml` file, that it finds
nothing or the phrase is gone, or that `grep -c` of it prints a count, the check reads the
joined text of the file: `tr -s '\n ' '  ' < <file> | grep -o -F '<phrase>' | wc -l` prints 1
where the item says it is found, 0 where it says nothing or gone, and the count where it names
one. A name without a space, a row of a table, a pattern with `^`, `$` or `-E`, a check that
prints the line it matches and a check that reads the output of another command read the file
line by line, as written.

1. `spec/domains/assessor.yaml`, `ratchet.assessor.Assessor`: the member `revision_inputs`,
   `Optional<List<String>>`, whose summary states the decision (`grep -c 'name:
   revision_inputs' spec/domains/assessor.yaml` prints 1; 0 before).
2. `spec/domains/evidence.yaml`, `ratchet.evidence.ResolvedInput`: the member `revision`,
   `Optional<ratchet.specification.Revision>` (the block of `ResolvedInput` holds `- name:
   revision`; it holds `value`, `digest` and `digest_form` alone before). `ess specify
   validate --path spec --strict-requires` exits 0.
3. `docs/evidence-format.md` § 10, the declaration table, has a row `revision_inputs` (14
   rows), and § 3 `evidence.inputs.<name>` a row `revision` (4 rows); the sentence of § 3
   reads "There are 82 fields: 48 `spec`, 7 `changed`, 27 `new`". The scripts end with
   `record-fields: 105 of 105 field rows declared` and
   `record-types: 105 of 105 field rows as declared, 105 of 105 declared fields have a row`
   (103 after story 5).
4. `spec/README.md`, the paragraph that begins "Each script states how much it reads": it
   says "82 field rows in 13 tables of § 3 and 23 in 2 tables of § 10". The sentence wraps,
   so the check joins the lines: `tr -s '\n ' '  ' < spec/README.md | grep -c -F '82 field
   rows in 13 tables of § 3 and 23 in 2 tables of § 10'` prints 1 (0 before), and the same
   check of '81 field rows in 13 tables of § 3 and 22 in 2 tables of § 10' prints 0 (1
   before, after story 5).
5. `docs/evidence-format.md` § 10, the bullet "The revision", says how a report named in
   `revision_inputs` is read: "reads the revision from the report and writes it as
   `inputs.<input>.revision`" (`grep -F` finds it; nothing before).
6. `docs/evidence-format.md` § 10 "Exit status" says when such a report is refused: "a report
   named in `revision_inputs` that states no revision" (`grep -F` finds it; nothing before).
7. `docs/evidence-format.md` § 9 has a bullet "**The digest of the sources of a report**",
   left out of version 1 (`grep -c 'digest of the sources' docs/evidence-format.md` prints
   at least 1; 0 before).
8. `presets/conformance-report@2.assessor.yaml` (new) lists `revision_inputs: [report]`, and
   `conformance-report@1` stays byte for byte (`git diff --quiet 7b01ea1 --
   presets/conformance-report@1.assessor.yaml` exits 0). `spec/presets.test.sh` (rules
   `place` and `type`) ends with
   `presets: 60 of 60 file(s) valid, 51 of 51 measurement(s) with a row, 101 of 101 broken copies refused`
   (59 files after story 7).
9. `presets/functional.md` names the new version beside the old one (`grep -c
   'conformance-report@2' presets/functional.md` prints at least 1; 0 before), on a line no
   case of `spec/presets.test.sh` edits: the line of item 8 still counts 101 of 101 copies
   refused.

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
- Its line of `CHANGELOG.md` is written by the closing commit of the wave (`AGENTS.md`
  § "Changelog lines"; the wave record names the heading and the phrase of the line).
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of
  `.engineering/waves/0.1.0-ahead-2.md`, into one wave built in sequence on one branch: every
  planned wave starts behind `story:cli-skeleton-validate`, which waits for a release of ESS
  (beyond10x/ess#836), and this part needs no `ratchet` command. It is 8 of the 33 in the
  order of that page. It adds the last field rows of the wave to § 3 and § 10, after 2, 4 and
  5, and changes § 10 after 5, 6 and 7.
- It runs `task check:generated` when it edits `spec/domains/`.
- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s.
