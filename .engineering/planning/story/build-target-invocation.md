---
format: aep.planning-md/3
id: story:build-target-invocation
kind: story
status: draft
title: The invocation contract covers a target that is a build
summary: No reserved argument passes the artifact of a build, so the built file is an input and nothing ties it to the revision.
relations:
- decomposes: epic:preset-catalog
- depends_on: story:preset-catalog-factory
scope:
- confidence: cited
  path: CHANGELOG.md
- confidence: cited
  path: docs/evidence-format.md
- confidence: cited
  path: presets/artifact.md
- confidence: inferred
  path: presets/binary-size@2.preset.yaml
- confidence: inferred
  path: presets/file-size@2.assessor.yaml
- confidence: cited
  path: spec/domains/assessor.yaml
- confidence: cited
  path: spec/domains/evidence.yaml
- confidence: cited
  path: spec/record-examples.test.sh
revision: 16
---
## Context

The entry "A target that is a build" under "Not expressible yet" on `presets/artifact.md`
(point 4, `:314-321`, `story:preset-catalog-factory`). First consumer: the catalog, and every
project that binds `image-size@1` or `binary-size@1`.

What the formats say at the wave's base, `7b01ea1`:

- `ratchet.specification.TargetKind` has `build`, and a candidate of a `build` target is the
  artifact digest (`ratchet.evidence.CandidateIdentity`, `spec/domains/evidence.yaml:52-60`).
- The invocation contract covers a target of the kind `revision` or `document`
  (`docs/evidence-format.md` § 9, `:673`; § 10, `--revision` "for a target of the kind
  `revision`", `:692`). `ratchet.assessor.ReservedArgument` has `revision` and no argument
  that passes the artifact (`spec/domains/assessor.yaml:55-57`). `target_input` is present
  exactly when `targets` holds `document` (`spec/domains/assessor.yaml:159-164`, invariants
  `:212-218`).
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

Every outcome below is observable without a `ratchet` command.

1. `spec/domains/assessor.yaml` and `spec/domains/evidence.yaml` hold the two invariants and the
   summaries of the decision (`Assessor.target_input`, `ReservedArgument`,
   `ResolvedTarget.revision` and `identifiers`). Checked by
   `ess specify validate --path spec --strict-requires` (exit 0).
2. `docs/evidence-format.md` § 10: the row `--revision` of the invocation table names a target
   of the kind `build`, a bullet "The target of the kind `build`" beside the one for `document`
   states the decision, and the row `target_input` of the declaration table names `build`;
   § 3, the rows `revision` and `identifiers` of `evidence.target`, say what a `build` target
   holds; § 9 no longer counts `build` among the targets the contract does not cover. The rows
   of both tables stay as many, so the counts of `spec/record-fields.test.sh` and
   `spec/record-types.test.sh` do not change. Text only, no case.
3. `docs/evidence-format.md` § 6 has a ninth example: a run of `binary-size@2` with
   `target.kind: build`, `target.revision`, `candidate` and `identifiers.artifact_digest` the
   digest of the artifact. `want_examples` of `spec/record-examples.test.sh` goes from 8 to 9,
   and its last line counts the members of 9 examples, every one decoding.
4. `presets/file-size@2.assessor.yaml` (new) declares `targets: [build]` and
   `target_input: binary`; `presets/binary-size@2.preset.yaml` (new) names it with a target of
   the kind `build`; `binary-size@1` and `file-size@1` stay byte for byte.
   `presets/artifact.md` has the section and the row of `binary-size@2`, and its point 4
   (`:314-321`) says that the kind `build` answers it from `binary-size@2` on. Checked by
   `spec/presets.test.sh`, rules `place`, `type` and `row` and the rule that a plan names a target
   kind its assessor declares: its last line counts two
   more files and one more measurement with a row.
5. `CHANGELOG.md` has its line under `## [Unreleased]`. Text only, no case.

## Notes

- An addition to released formats: a declaration and a record written before the change stay
  valid. A declaration that uses it is a new version of the declaration, and a preset that
  names it a new version of the preset.
- That `ratchet assess` passes the artifact and the revision and that `ratchet evaluate` does
  not judge a record whose `target.revision` is not the candidate's revision is
  `story:build-target-invocation-in-ratchet`, which waits for the waves to 0.1.0.
- Related and not the same: `story:imported-report-revision-check` (8 of the wave).
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of
  `.engineering/waves/0.1.0-ahead-2.md`, into one wave built in sequence on one branch: every
  planned wave starts behind `story:cli-skeleton-validate`, which waits for a release of ESS
  (beyond10x/ess#836), and this part needs no `ratchet` command. It is 7 of the 33 in the
  order of that page. It adds the last § 6 example of the wave (8 to 9), after those of 2, 3
  and 4, and changes § 10 "Invocation" after 5 and 6.
- It runs `task check:generated` when it edits `spec/domains/`.
- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s.
