---
format: aep.planning-md/3
id: story:build-target-invocation
kind: story
status: active
title: The invocation contract covers a target that is a build
summary: No reserved argument passes the artifact of a build, so the built file is an input and nothing ties it to the revision.
relations:
- decomposes: epic:preset-catalog
- depends_on: story:preset-catalog-factory
scope:
- confidence: cited
  path: docs/evidence-format.md
- confidence: cited
  path: presets/artifact.md
- confidence: inferred
  path: presets/binary-size@2.preset.yaml
- confidence: inferred
  path: presets/file-size@2.assessor.yaml
- confidence: cited
  path: spec/README.md
- confidence: cited
  path: spec/domains/assessor.yaml
- confidence: cited
  path: spec/domains/evidence.yaml
- confidence: cited
  path: spec/record-examples.test.sh
revision: 22
transitions:
- {from: "draft", to: "proposed", at: "2026-11-26T21:04:21Z", actor: "human:operator", revision: 21, decided_on: {"recorded":{"review_outcome":4}}}
- {from: "proposed", to: "active", at: "2026-11-26T21:04:21Z", actor: "human:operator", revision: 22, decided_on: {"recorded":{"review_outcome":4}}}
---
## Context

The entry "A target that is a build" under "Not expressible yet" on `presets/artifact.md`
(point 4, `:314-321`, `story:preset-catalog-factory`). First consumer: the catalog, and every
project that binds `image-size@1` or `binary-size@1`.

What the formats say at the wave's base, `7b01ea1`:

- `ratchet.specification.TargetKind` has `build`, and a candidate of a `build` target is the
  artifact digest (`ratchet.evidence.CandidateIdentity`, `spec/domains/evidence.yaml:52-60`).
- The invocation contract covers a target of the kind `revision` or `document`
  (`docs/evidence-format.md` § 9, the bullet "The rest of the invocation", `:674`; § 10,
  `--revision` "for a target of the kind `revision`", `:692`). `ratchet.assessor.ReservedArgument`
  has `revision` and no argument that passes the artifact (`spec/domains/assessor.yaml:55-57`).
  `target_input` (`spec/domains/assessor.yaml:168`) is present exactly when `targets` holds
  `document` (the invariants of `Assessor`, `:211-219`).
- So `binary-size@1` names the kind `revision` (`presets/binary-size@1.preset.yaml`), the built
  file is the input `binary` of `file-size@1` (`presets/file-size@1.assessor.yaml`), and
  nothing ties the file to the revision. `artifact-verification-report@1` already declares
  `targets: [build]` with no `target_input`.

## Decision

Taken as the reversible answer (`AGENTS.md` § "Phase: implementation"), on the form of the
`document` target and without a new reserved argument:

- A declaration whose `targets` holds `build` may name the input that holds the path of the
  artifact as `target_input`; for `document` it stays required. The invariant on
  `ratchet.assessor.Assessor` becomes: `target_input` only where `targets` holds `document` or
  `build`, and always where it holds `document`, so `artifact-verification-report@1` stays
  valid.
- For a `build` target Ratchet passes `--revision`, the revision the artifact was built from.
  The assessor writes it as `target.revision`, the digest of the artifact's bytes as
  `candidate` and under `target.identifiers.artifact_digest`, and does not repeat the artifact
  under `inputs`. Invariants on `ratchet.evidence.ResolvedTarget`: a `build` target has
  `revision` and `identifiers`. No record of the kind `build` exists in this repository; every
  plan of the artifact family names `revision`.
- That the artifact was built from that revision is the project's statement: the plan names a
  path its build at that revision writes. A record the build writes, or a digest the plan
  pins, is left out; § 9 says so.

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

1. `spec/domains/assessor.yaml`, the invariants of `ratchet.assessor.Assessor`: `target_input`
   is admitted where `targets` holds `build` (`grep -c 't == build'
   spec/domains/assessor.yaml` prints at least 1; 0 before), and the summary of
   `target_input` names `build`.
2. `spec/domains/evidence.yaml`, the invariants of `ratchet.evidence.ResolvedTarget`: a
   `build` target has `revision` and `identifiers` (`grep -c '"kind != build"'
   spec/domains/evidence.yaml` prints 2; 0 before). `ess specify validate --path spec
   --strict-requires` exits 0.
3. `docs/evidence-format.md` § 10, the row `--revision` of the invocation table, names a
   target of the kind `build` (`grep -F '| `--revision` |' docs/evidence-format.md | grep -c
   'build'` prints 1; 0 before).
4. `docs/evidence-format.md` § 10 "Invocation" has a bullet "**The target of the kind
   `build`**" beside the one for `document`, stating the decision (`grep -F` finds it;
   nothing before).
5. `docs/evidence-format.md` § 10, the row `target_input` of the declaration table, names
   `build` (`grep -F '| `target_input` |' docs/evidence-format.md | grep -c 'build'` prints 1;
   0 before).
6. `docs/evidence-format.md` § 3, the rows `revision` and `identifiers` of `evidence.target`,
   each say what a `build` target holds, starting "For `build`:" (`grep -c 'For `build`'
   docs/evidence-format.md` prints 2; 0 before). The tables keep their rows:
   `sh spec/record-fields.test.sh` still ends with `record-fields: 103 of 103 field rows
   declared`.
7. `docs/evidence-format.md` § 9, the bullet "The rest of the invocation", counts `build`
   among the kinds the contract covers: "the kind `revision`, `document` or `build`" (`grep
   -F` finds it; nothing before).
8. `docs/evidence-format.md` § 6 has a ninth example: a run of `binary-size@2` with
   `target.kind: build`, `target.revision`, `candidate` and `identifiers.artifact_digest` the
   digest of the artifact. The assignment `want_examples` of `spec/record-examples.test.sh`
   goes from 8 to 9, and the script ends with
   `record-examples: <n> of <n> members of 9 example(s) decode under the specification`.
9. `spec/README.md`, the paragraph that begins "Each script states how much it reads": it
   says "9 examples in § 6 (`record-examples`)": `tr -s '\n ' '  ' < spec/README.md | grep
   -c -F '9 examples in § 6'` prints 1 (0 before), and the same check of '8 examples in § 6'
   prints 0 (1 before, after story 4).
10. `presets/file-size@2.assessor.yaml` (new) declares `targets: [build]` and
    `target_input: binary`, and `presets/binary-size@2.preset.yaml` (new) names it with a
    target of the kind `build`; `binary-size@1` and `file-size@1` stay byte for byte (`git
    diff --quiet 7b01ea1 -- presets/binary-size@1.preset.yaml
    presets/file-size@1.assessor.yaml` exits 0).
11. `presets/artifact.md` has the section `` ## `binary-size@2` `` and its row, and with item
    10 `spec/presets.test.sh` (rules `place`, `type`, `row` and the rule that a plan names a
    target kind its assessor declares) ends with
    `presets: 59 of 59 file(s) valid, 51 of 51 measurement(s) with a row, 101 of 101 broken copies refused`
    (57 files and 50 measurements after story 5).
12. `presets/artifact.md`, point 4 of "Not expressible yet", is rewritten in place and keeps
    its number: it says "the kind `build` answers it from `binary-size@2` on" (`grep -F`
    finds it; nothing before).

## Notes

- An addition to released formats: a declaration and a record written before the change stay
  valid. A declaration that uses it is a new version of the declaration, and a preset that
  names it a new version of the preset.
- That `ratchet assess` passes the artifact and the revision and that `ratchet evaluate` does
  not judge a record whose `target.revision` is not the candidate's revision is
  `story:build-target-invocation-in-ratchet`, which waits for the waves to 0.1.0.
- Related and not the same: `story:imported-report-revision-check` (8 of the wave).
- Its line of `CHANGELOG.md` is written by the closing commit of the wave (`AGENTS.md`
  § "Changelog lines"; the wave record names the heading and the phrase of the line).
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of
  `.engineering/waves/0.1.0-ahead-2.md`, into one wave built in sequence on one branch: every
  planned wave starts behind `story:cli-skeleton-validate`, which waits for a release of ESS
  (beyond10x/ess#836), and this part needs no `ratchet` command. It is 7 of the 33 in the
  order of that page. It adds the last § 6 example of the wave (8 to 9), after those of 2, 3
  and 4, and changes § 10 "Invocation" after 5 and 6.
- It runs `task check:generated` when it edits `spec/domains/`.
- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s.
