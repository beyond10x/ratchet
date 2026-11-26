---
format: aep.planning-md/3
id: story:example-release-quality
kind: story
status: draft
title: An example plan for the quality of a release
summary: 'examples/release-quality.ratchet.yaml: exact counts with better: lower under a gate that starts report-only.'
relations:
- decomposes: epic:runnable-cli
scope:
- confidence: cited
  path: CHANGELOG.md
- confidence: cited
  path: examples/README.md
- confidence: inferred
  path: examples/quality/assessors/release-counts@1.assessor.yaml
- confidence: inferred
  path: examples/release-quality.ratchet.yaml
revision: 13
---
## Context

A consumer reviews each release of a product and wants its review written as a `ratchet/1`
file: measurements that are exact counts where a lower value is better, and a gate that starts
report-only (2026-11-25, routed by the operator session of the workstation). It asks for an
example to copy, `examples/release-quality.ratchet.yaml`. Nothing of the consumer is named
here.

What the format says today: the direction of a measurement is the key `better` with the value
`lower` (`docs/design.md` § 3 "Value lists", the row "Direction (`better`)", `:218`), and a gate
entry with `mode: report` and `since` (`docs/design.md` § 5 "Gate modes", `:627-631`;
`ratchet.specification.GateRequirement` and its invariant that a report-mode entry has `since`,
`spec/domains/specification.yaml:1078-1110`; the entry of `rust-test-step-budget` in
`examples/ci-turnaround.ratchet.yaml:130`). The six examples under `examples/` (the table of
`examples/README.md`, `:41-49`) hold no plan whose subject is a release, and none whose
measurements are all exact counts under a gate that only reports. `docs/design.md` lists no
example (`grep -n 'examples/' docs/design.md` names none of the files), so it gets no line.

What checks an example today: `sh spec/example-declarations.test.sh`, step 11 of
`task check:spec` (`spec/README.md`), reads each `examples/*.ratchet.yaml`: every assessor it
names has a declaration in `examples/quality/assessors/` or `presets/`, and each measurement
names an output, a unit and a scope that declaration declares. It reads no other key, so the
gate, the requirements and `better` are read by no script. AGENTS.md (row `examples/`): a change
that adds a file `*.ratchet.yaml` adds the declaration of each assessor it names that has none.
`ratchet validate` is built by `story:cli-skeleton-validate`.

`story:gate-judges-commit-of-a-tag` (30 in the order) adds `judges: {tag: <pattern>}` to a
gate: the example's gate uses it, so a reader sees that the gate judges a release.

## Acceptance

Every outcome below is observable without a `ratchet` command.

1. `examples/release-quality.ratchet.yaml` (new) declares a release as its subject, one plan
   over one assessor with at least three exact measurements with `better: lower` (open defects
   of the release, failed checks of its run, reverted changes since the release before), a
   requirement on each against an accepted reference (`reference: {kind: accepted_value}`), and
   one gate `release` with `judges: {tag: "*.*.*"}` whose every entry has `mode: report` and a
   `since`. Before the story the file does not exist.
2. `examples/quality/assessors/release-counts@1.assessor.yaml` (new), in the form of the files
   of `presets/`, declares the three outputs the measurements read, each `number`, `exact`, with
   its unit and the scope `run`. `sh spec/example-declarations.test.sh` exits 0, and its line
   `example-declarations: <e> example file(s), <d> declaration(s) read, <m> of <m> measurement(s) as declared`
   counts one more example file, one more declaration and three more measurements than at the
   commit before.
3. `examples/README.md`: the table of files (`:41-49`) has the row of the new file, a section
   "7. Quality of a release" gives the source of every value (the consumer's request of
   2026-11-25, not published), and the counts with no survey source are listed under "Numbers
   without a source". Text only, no case.
4. `CHANGELOG.md` has its line under `## [Unreleased]`. Text only, no case.

## Notes

- First consumer: the repository that reviews releases. The counts of the example are generic;
  no name of a product or a tracker.
- A thing the example needs and the format cannot say is named in the report and filed as a
  draft of `epic:format-gaps-first-format-consumer`; the example gets no key the specification
  does not declare. It reads `judges` of story 30 because that story lands first.
- How a record names the released version is decided by `story:record-series-git-ref`, which
  stays out of this wave; the example uses the target kind `revision` until then.
- `ratchet validate examples/release-quality.ratchet.yaml` exiting 0 is
  `story:example-release-quality-in-ratchet`, which waits for `story:cli-skeleton-validate`;
  the dependency on that story moves there.
- `examples/README.md` is changed before this story by `story:severity-limit-on-identity-set`
  (13), `story:records-tracked-baseline-directory` (28) and `story:production-gate-kind` (31);
  this story adds a row and a section of its own.
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of `.engineering/waves/0.1.0-ahead-2.md`,
  into one wave built in sequence on one branch: every planned wave starts behind
  `story:cli-skeleton-validate`, which waits for a release of ESS (beyond10x/ess#836), and this
  part needs no `ratchet` command. It is 33 of the 33 in the order of that page: the last,
  because it uses the form of story 30.
