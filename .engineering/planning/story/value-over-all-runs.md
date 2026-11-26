---
format: aep.planning-md/3
id: story:value-over-all-runs
kind: story
status: active
title: A sampled measurement states a value computed over all runs
summary: No aggregation kind gives one value over all runs, so flake-rate@1 declares none with runs above 1.
relations:
- decomposes: epic:preset-catalog
- depends_on: story:preset-catalog-factory
scope:
- confidence: inferred
  path: CHANGELOG.md
- confidence: inferred
  path: docs/design.md
- confidence: inferred
  path: presets
- confidence: inferred
  path: spec/domains/specification.yaml
revision: 10
transitions:
- {from: "draft", to: "proposed", at: "2026-11-26T05:20:03Z", actor: "human:operator", revision: 9}
- {from: "proposed", to: "active", at: "2026-11-26T05:20:04Z", actor: "human:operator", revision: 10}
---
## Context

The entry "A value over the runs that no aggregation of the format gives" under "Not
expressible yet" on `presets/build.md` (point 6, `:408-414`, `story:preset-catalog-factory`).
First consumer: the catalog, and every project that binds `flake-rate@1`.

`ratchet.specification.AggregationKind` has `sum`, `median`, `percentile`, `best_of_n` and
`pass_rate` (`spec/domains/specification.yaml:136-138`). The flake rate is one value over all
runs of a report: the share of tests that passed in one run and failed in another. It is no
median of a value per run, and `pass_rate` aggregates an assertion. So `flake-rate@1` declares
no `aggregation` (`presets/flake-rate@1.preset.yaml:38-42`), also where `runs` is above 1,
though `ratchet.specification.Aggregation` says that one is declared where a sampled plan has
more than one run or sample (`:143-145`), and `docs/design.md` § 3 says the same (`:88`).

`flake-rate@1` takes `runs` from an input (`presets/flake-rate@1.preset.yaml:30`), as every
preset of the catalog does. `spec/presets.test.sh` reads no value that an input gives (its
header, "Not checked"), and it accepts a sampled measurement with a literal `runs` above 1 and
no aggregation without a word (attack 1 on `story:preset-catalog-factory`, listed by
`story:preset-check-unlisted-forms`).

## Acceptance

Every outcome below is observable without a `ratchet` command.

1. `docs/design.md` § 3, the row "Aggregation" of the table (`:88`) and the paragraph "One run
   per candidate is valid" (`:114`): the rule that a sampled measurement of a plan with `runs`
   above 1 states an aggregation, or states that the assessor computes its value over all runs
   of the plan, and that one stating neither is an error. The form is valid for every value of
   `runs`, and at `runs: 1` it is no aggregation: the measurement declares none, as the
   paragraph "One run per candidate is valid" requires. § 3 "Measurement kind and observation
   conditions" lists, beside "`ratchet validate` reports a sampled measurement that declares
   no conditions" (`:92`), a sampled measurement of a plan with `runs` above 1 that states
   neither among what `ratchet validate` reports. Text only, no case.
2. `spec/domains/specification.yaml`: the form is a member of
   `ratchet.specification.Measurement` (`:158`), not a variant of
   `ratchet.specification.AggregationKind` (`:136-138`): a variant would be an `aggregation`
   at `runs: 1`, where the summary of `Measurement.aggregation` (`:182-188`) says it is
   absent. The summary of `Aggregation` (`:143-145`) states the rule. `spec/domains/evidence.yaml`
   says what a result of that value carries as `samples` (`:368-375`). Checked by
   `ess specify validate --path spec --strict-requires`, which exits 0, and by
   `task check:generated`.
3. `spec/presets.test.sh`, rule `sampled`: a sampled measurement of a plan whose `runs` is a
   literal above 1 and which states neither an aggregation nor the new form is refused with
   the message of the rule. Before the story a copy with `runs: 3`, a sampled measurement and
   no aggregation is accepted. After the story that copy is refused, a copy that states the
   new form is accepted, and the header lists the form under `sampled` and not under "Not
   checked". A `runs` that an input gives stays unread, so the rule does not reach
   `flake-rate@1`, which stays accepted as released in 0.0.2.
4. `presets/flake-rate@2.preset.yaml` (new) states the form; `flake-rate@1` stays byte for
   byte. `presets/build.md` has the row of `flake-rate@2/test-runs/flake-rate`, and its point 6
   (`:408-414`) says that the form answers it from `flake-rate@2` on. Checked by
   `spec/presets.test.sh`, rules `place`, `type` and `row`: its last line counts one more
   preset and one more measurement with a row.
5. `CHANGELOG.md` has its line under `## [Unreleased]`. Text only, no case.

## Notes

- Whether the existing aggregation kinds are valid with `runs: 1` when the command repeats
  itself is `story:specification-answers-first-format-consumer` (finding 11). This story adds
  the form for a value over all runs, and of `runs: 1` says only that the form is valid there
  and is no aggregation. How many runs a preset
  declares for each value of an input stays with `story:member-for-some-input-values`.
- An addition to a released format; a preset that uses it is a new version of the preset.
- It runs `task check:generated` when it edits `spec/domains/`.
- The acceptance and refusal by `ratchet validate`, with a code, are
  `story:value-over-all-runs-in-ratchet`, which waits for the waves to 0.1.0 and for
  `ratchet evaluate`.
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them, with eight other drafts, into one wave built in sequence on one
  branch: every planned wave starts behind `story:cli-skeleton-validate`, which waits for a
  release of ESS (beyond10x/ess#836), and this part needs no `ratchet` command. It is 7 of the
  nine in the order of `.engineering/waves/0.1.0-ahead-1.md`. Where `story:preset-check-unlisted-forms` lists the
  form under "Not checked" when this story lands, this story removes that line.
- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s; the new
  broken copies are timed before they are added.
