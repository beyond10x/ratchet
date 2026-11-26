---
format: aep.planning-md/3
id: story:coverage-count-with-reference
kind: story
status: draft
title: A coverage count is a measurement a reference can protect
summary: executed, skipped, not_run and unsupported as measurements with a direction and an accepted value.
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
  path: spec/domains/specification.yaml
- confidence: cited
  path: spec/example-declarations.test.sh
- confidence: cited
  path: spec/presets.test.sh
revision: 8
---
## Context

The repository `beyond10x/inference` wrote its quality definition against the formats at
commit `f139ecc` (2026-11-25). It is the first consumer of the formats outside this
repository. Finding 2: the definition needs "the number of executed units does not fall". The
consumer's proposal: a requirement with `coverage: executed` and
`reference: {kind: accepted_value}`.

At `7b01ea1`:

- `ratchet.specification.CoverageBounds` holds fixed bounds only
  (`spec/domains/specification.yaml:326-343`): no `better`, no accepted value.
- The design says that a coverage count can be a measurement with an accepted value, "so that
  the number of ignored tests may not rise" (`docs/design.md:162`), and the row "Test
  evidence" of § 4 lists the counts "as measurements" (`:503`). No shape reads a count as a
  measurement: a measurement's `output` is an `OutputName` that "an assessor declares"
  (`spec/domains/specification.yaml:86-92`), and the counts are no outputs.
- An assessor lists the counts it reports under `coverage`
  (`ratchet.assessor.Assessor.coverage`, `spec/domains/assessor.yaml:194-199`; the list
  `ratchet.assessor.CoverageCount`, `:41-43`).
- `spec/presets.test.sh`, rule `assessor`, refuses a measurement that names no output of the
  declaration (`spec/presets.test.sh:62-63`), and `spec/example-declarations.test.sh`, case 2,
  does the same for an example (`spec/example-declarations.test.sh:13`).

Decision taken (reversible, `AGENTS.md` § "Phase: implementation"): no new key. The output name
`coverage.<count>` is Ratchet's, as `run`, `run_time` and `queue_wait` are (`docs/design.md`
§ 3 "Value lists"): a measurement with `output: coverage.executed` reads the count `executed`
of the run's `evidence.coverage`, for a count its assessor lists under `coverage`. Such a
measurement is `exact`, a number, at the scope `run`, with no `unit` (it counts units of the
assessor's `coverage_unit`, which the evidence names), and it takes `better` and a reference
as any number does. The consumer's spelling, a key `coverage` on the requirement, is not
taken: a requirement names a measurement, and the measurement keeps the direction.

## Acceptance

Every outcome below is observable without a `ratchet` command.

1. `spec/domains/specification.yaml`: the summary of `ratchet.specification.OutputName`
   (`:86-92`) and of `Measurement.output` name the reserved form `coverage.<count>`, the
   counts of `ratchet.assessor.CoverageCount`, and what such a measurement is. Checked by
   `ess specify validate --path spec --strict-requires`, which exits 0.
2. `docs/design.md` § 3 "Evidence coverage": the sentence of `:162` shows the form,
   `ignored: {kind: exact, output: coverage.skipped, scope: run, better: lower}` with a
   requirement against an accepted value; a count that the record states as a lower bound or
   as not known (story 2, `story:coverage-count-lower-bound`) gives such a measurement
   insufficient evidence; "Value lists" (`:226`, the row "Scope, unit, output, ...")
   names `coverage.<count>` beside `run`, `run_time` and `queue_wait` as Ratchet's.
   `docs/evidence-format.md` § 3 `evidence.coverage` says in one sentence that a measurement
   may read a count from there, and that it is no entry of `results`. Text only, no case.
3. `spec/presets.test.sh`, rule `assessor`: a measurement whose `output` is `coverage.<count>`
   is accepted when the declaration lists the count under `coverage`, is `exact`, at the scope
   `run` and without `unit`. Before the story such a measurement is refused with the message
   that the declaration declares no such output. After it, a copy with a requirement
   `executed-does-not-fall` on `coverage.executed` of `conformance-cases@1`, `better: higher`
   and an accepted value, is accepted; a copy with `coverage.skipped` on an assessor whose
   `coverage` lacks `skipped`, one with a `unit` on it, one with `kind: sampled`, and one with
   `coverage.passed_ids` (no count) are each refused with the message of the rule.
4. `spec/example-declarations.test.sh`, case 2: an example measurement on `coverage.<count>`
   of a count its assessor lists is accepted, and one on a count it does not list is refused
   with the message of case 2; a broken copy of its set holds the second, and its last line
   counts one more broken copy refused.
5. `CHANGELOG.md` has its line under `## [Unreleased]`, in the form
   `.github/scripts/release.test.sh` checks.

## Notes

- An addition to a released format: a file written before the change stays valid. The name
  `coverage.<count>` is reserved, and no output of the catalog or the examples has a name with
  a dot.
- The parts that need the command are `story:coverage-count-with-reference-in-ratchet`:
  `ratchet validate` holding the form to the declaration with a code, and
  `ratchet evaluate --gate` giving fail when `executed` is below the accepted value. It waits
  for the waves to 0.1.0.
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of `.engineering/waves/0.1.0-ahead-2.md`,
  into one wave built in sequence on one branch: every planned wave starts behind
  `story:cli-skeleton-validate`, which waits for a release of ESS (beyond10x/ess#836), and this
  part needs no `ratchet` command. It is 15 of the 33 in the order of that page.
- 2 (`story:coverage-count-lower-bound`) changes `ratchet.evidence.EvidenceCoverage` and
  `docs/evidence-format.md` § 3 `evidence.coverage` before it; 16
  (`story:coverage-bound-on-failed-units`) changes `docs/design.md:160`, the paragraph before
  `:162`, after it.
- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s; new broken
  copies are timed before they are added.
