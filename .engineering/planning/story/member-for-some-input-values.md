---
format: aep.planning-md/3
id: story:member-for-some-input-values
kind: story
status: draft
title: A preset leaves a member out for some values of an input
summary: 'A reference to an input stands for a value and no key, so a preset declares an aggregation for runs: 1 too.'
relations:
- decomposes: epic:preset-catalog
- depends_on: story:preset-catalog-runtime
scope:
- confidence: cited
  path: CHANGELOG.md
- confidence: cited
  path: docs/design.md
- confidence: cited
  path: presets/build.md
- confidence: cited
  path: presets/latency.md
- confidence: cited
  path: presets/resources.md
- confidence: cited
  path: presets/start.md
- confidence: cited
  path: spec/domains/specification.yaml
- confidence: cited
  path: spec/presets.test.sh
revision: 15
---
## Context

Point 4 of "Not expressible yet" on `presets/latency.md` (`:262-266`), repeated on
`presets/resources.md` (`:137-139`), `presets/start.md` (`:126-128`) and `presets/build.md`
(`:417-419`) (`story:preset-catalog-runtime`, `story:preset-catalog-factory`). First consumer:
the catalog. Line numbers are those of `7b01ea1`.

`ratchet.specification.Measurement` says of `aggregation` that it is absent with `runs: 1` where
the command measures once (`spec/domains/specification.yaml:190-201`), and `docs/design.md` § 3,
"One run per candidate is valid" (`:114`), says the same: "A plan with `runs: 1` whose command
measures once declares no aggregation". `ratchet.specification.InputReference` stands for a
value and for no key (`:794`), so a preset cannot leave a member out when the binding passes
`runs: 1`. `workload-throughput@1`, `process-resources@1`, `start-time@1` and the four durations
of the build family therefore always declare the median of the runs, also for `runs: 1`.
`spec/presets.test.sh` accepts `runs: 1` with an aggregation (the copy
`valid-one-run-with-aggregation`, `:2746-2749`) and lists it under "Not checked" because it
cannot see whether a command repeats its measurement (`:162-168`).

The story first answers whether the format needs a member that is there for some values of an
input. The answer this story takes, the reversible one (`AGENTS.md` § "Phase: implementation"):
it does not. An aggregation of one value is that value: the median, a percentile and the best of
one value are the value, and the pass rate of one run is that run's result. So a measurement may
declare its aggregation for every value of `runs`, and at `runs: 1` with a command that measures
once the result is the observed value, carries `samples: 1`, and is judged as observed. A preset
whose `runs` is an input declares its aggregation once, for every value the binding passes. The
two other answers are not taken: a conditional member needs a form for a condition on an input
and a resolution of it (`story:preset-binding-resolution`), and a rule that a sampled
measurement of the catalog requires at least two runs would refuse the one run per candidate
that § 3 calls valid.

## Acceptance

Every outcome below is observable without a `ratchet` command.

1. `docs/design.md` § 3, "One run per candidate is valid" (`:114`): the paragraph says that an
   aggregation of one value is that value, that a measurement may therefore declare its
   aggregation for every value of `runs`, that a preset whose `runs` is an input does so, and
   that at `runs: 1` the result carries `samples: 1` and is judged as observed. The sentence "A
   plan with `runs: 1` whose command measures once declares no aggregation" reads as "needs no
   aggregation". Text only, no case.
2. `spec/domains/specification.yaml`: the summary of `Measurement.aggregation` (`:190-201`) and
   of `ratchet.specification.Aggregation` (`:140-149`) say the same; no member, type or
   invariant changes. Checked by `ess specify validate --path spec --strict-requires`, which
   exits 0, and by `task check:generated`, which finds no change of the generated crate.
3. `spec/presets.test.sh`: the line "`runs: 1` with an aggregation" under "Not checked"
   (`:162-168`) gives the design's sentence of item 1 as the reason, and the copy
   `valid-one-run-with-aggregation` (`:2746-2749`) stays accepted. The script's last line is
   the one it printed before the story.
4. Point 4 of "Not expressible yet" on `presets/latency.md`, `presets/resources.md`,
   `presets/start.md` and `presets/build.md` says that the point is answered without a new
   form (`docs/design.md` § 3, "One run per candidate is valid") and that the presets stay as
   they are, each in its place, so the numbering of the points stays. No preset changes. Text
   only, no case.
5. `CHANGELOG.md` has its line under `## [Unreleased]`. Text only, no case.

## Notes

- Decision taken: the format needs no member for some values of an input (§ Context). It is a
  reading of the design, so the owner can take it back by a story that adds the form.
- No new form, so no file written before the change becomes invalid, and no preset gets a new
  version.
- No command part: `ratchet validate` resolves a binding of `workload-throughput@1` with
  `runs: 1` to a measurement with the median of one run, which is the resolution of
  `story:preset-binding-resolution` and reports nothing; no `-in-ratchet` draft is filed.
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of `.engineering/waves/0.1.0-ahead-2.md`,
  into one wave built in sequence on one branch: every planned wave starts behind
  `story:cli-skeleton-validate`, which waits for a release of ESS (beyond10x/ess#836), and this
  part needs no `ratchet` command. It is 22 of the 33 in the order of that page. Before it,
  `story:plan-conditions-from-binding` (21) rewrites point 3 of the same pages and
  `story:min-samples-per-scope-item` (19) adds a member beside `Measurement.aggregation`. After
  it, `story:input-allowed-values` (23) changes `presets/code.md`, whose point 4 is another.
- POSIX sh and awk, no Python. The script changes only in its header. The test step ends within
  120 s, no test over 60 s.
