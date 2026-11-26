---
format: aep.planning-md/3
id: story:plan-with-exact-and-sampled-measurements
kind: story
status: implemented
title: One plan holds exact and sampled measurements of one run
summary: Whether a controlled run may carry exact values beside durations, and what its conditions qualify.
relations:
- decomposes: epic:format-gaps-first-format-consumer
revision: 6
transitions:
- {from: "draft", to: "proposed", at: "2026-11-26T05:20:03Z", actor: "human:operator", revision: 4}
- {from: "proposed", to: "active", at: "2026-11-26T05:20:03Z", actor: "human:operator", revision: 5}
- {from: "active", to: "implemented", at: "2026-11-26T07:54:31Z", actor: "human:operator", revision: 6, decided_on: {"recorded":{"test_result":1}}}
---
## Context

The repository `beyond10x/inference` wrote its quality definition against the formats at
commit `f139ecc` (2026-11-25). It is the first consumer of the formats outside this repository
and of this story. The finding comes from the correction round of that definition.

Finding 18. One command in one run reports twelve exact values (counts per scenario and
viewport, compared with a committed baseline) and two durations (seconds per test, seconds
per run). A plan has one observation kind
(`spec/domains/specification.yaml:435-444`, `ObservationPlan`). `controlled_run` with
`runs: 1` is true for the two durations and says nothing about the twelve counts; `snapshot`
is true for the counts and has no place for conditions of a timing. The consumer wrote one
plan, `controlled_run`, `runs: 1`, with measurements of the kinds `exact` and `sampled` side by
side. The smallest example: one browser run that yields `horizontal-scroll = 0 pages` (exact)
and `run-time = 48.0 s` (sampled). The design does not say whether that plan is valid, nor
which conditions apply to its exact measurements. `docs/design.md` § 3 says that every
measurement of a plan reads its one run (`:128`) and that exact measurements have conditions
too (`:116`).

No preset and no example of the tree holds a plan with both kinds. `spec/presets.test.sh`
builds one in a copy: `add_rate` (`:1536-1542`) puts a sampled `pass-rate` into the `snapshot`
plan of `conformance-cases@1` beside its exact measurements, and the script accepts it
(`:1772`). No rule of the script reads the mix of kinds in one plan.

## Acceptance

Every outcome below is observable without a `ratchet` command.

1. `docs/design.md` § 3, beside "Several measurements from one run" (`:128`): whether one plan
   may hold exact and sampled measurements of one run, and for the answer yes which
   observation kind it declares and which of its conditions qualify its exact measurements,
   read against "Exact measurements have conditions too" (`:116`). The smallest example above
   is written with the answer. Text only, no case.
2. `spec/domains/specification.yaml`: the summaries of `ratchet.specification.ObservationPlan`
   (`:435-444`) and `ratchet.specification.ObservationConditions` (`:343-350`) state the rule,
   with an invariant where the answer refuses a form the types can express. Checked by
   `ess specify validate --path spec --strict-requires`, which exits 0, and by
   `task check:generated`.
3. `spec/presets.test.sh`: where the rule refuses a form, the script refuses it with the
   message of the rule in one broken copy, and the copy of `add_rate` follows the rule; before
   the story that form is accepted. Where the rule accepts every mix, the header names the
   rule and the case at `:1772` stays. Either way the header no longer leaves the mix unread
   in silence.
4. `CHANGELOG.md` has its line under `## [Unreleased]`. Text only, no case.

## Notes

- The form shown is the consumer's proposal or what it wrote in place of the missing form.
  The story decides the form, declares it in `spec/` first (`ess specify validate` passes), and
  writes it into `docs/design.md` or `docs/evidence-format.md` in the same change. It runs
  `task check:generated` when it edits `spec/domains/`.
- Whether `runs: 1` is valid with an aggregation kind when the command repeats itself is
  `story:specification-answers-first-format-consumer` (finding 11), which shares
  `docs/design.md` § 3 with this story and lands before it. This story states the rule of one
  plan holding both kinds and cites that answer for `runs: 1`.
- A new value or field of a released format is an addition: a file written for the format
  before the change stays valid.
- The verdict of `ratchet validate` on the smallest example, with its code, is
  `story:plan-with-exact-and-sampled-measurements-in-ratchet`, which waits for the waves to
  0.1.0.
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them, with eight other drafts, into one wave built in sequence on one
  branch: every planned wave starts behind `story:cli-skeleton-validate`, which waits for a
  release of ESS (beyond10x/ess#836), and this part needs no `ratchet` command. It is 5 of the
  nine in the order of `.engineering/waves/0.1.0-ahead-1.md`.
- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s; a new
  broken copy is timed before it is added.
