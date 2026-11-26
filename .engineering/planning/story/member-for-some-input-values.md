---
format: aep.planning-md/3
id: story:member-for-some-input-values
kind: story
status: active
title: A preset leaves a member out for some values of an input
summary: 'A reference to an input stands for a value and no key, so a preset declares an aggregation for runs: 1 too.'
relations:
- decomposes: epic:preset-catalog
- depends_on: story:preset-catalog-runtime
scope:
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
revision: 20
transitions:
- {from: "draft", to: "proposed", at: "2026-11-26T21:04:23Z", actor: "human:operator", revision: 19, decided_on: {"recorded":{"review_outcome":4}}}
- {from: "proposed", to: "active", at: "2026-11-26T21:04:23Z", actor: "human:operator", revision: 20, decided_on: {"recorded":{"review_outcome":4}}}
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

A phrase with a space in it may wrap in a Markdown paragraph or a folded YAML summary. So where
an item says that `grep -F` finds such a phrase in a `.md` or `.yaml` file, that it finds
nothing or the phrase is gone, or that `grep -c` of it prints a count, the check reads the
joined text of the file: `tr -s '\n ' '  ' < <file> | grep -o -F '<phrase>' | wc -l` prints 1
where the item says it is found, 0 where it says nothing or gone, and the count where it names
one. A name without a space, a row of a table, a pattern with `^`, `$` or `-E`, a check that
prints the line it matches and a check that reads the output of another command read the file
line by line, as written.

None of the phrases the checks below look for occurs in `docs/`, `spec/` or `presets/` at
`7b01ea1`, but "measures once declares no aggregation", which item 2 removes (1 there). The
name of the paragraph, "One run per candidate is valid", is a place, not a check.

1. `docs/design.md` § 3, the paragraph "One run per candidate is valid", holds the sentence
   "An aggregation of one value is that value", and says that a measurement may therefore
   declare its aggregation for every value of `runs`, that a preset whose `runs` is an input
   does so, and that at `runs: 1` the result carries `samples: 1` and is judged as observed.
   Check: `grep -c 'An aggregation of one value is that value' docs/design.md` prints 1.
2. In that paragraph the sentence "A plan with `runs: 1` whose command measures once declares
   no aggregation" reads "... needs no aggregation". Check: `grep -c 'measures once declares no
   aggregation' docs/design.md` prints 0 (1 before) and `grep -c 'measures once needs no
   aggregation' docs/design.md` prints 1.
3. `spec/domains/specification.yaml`: the summaries of `Measurement.aggregation` and of
   `ratchet.specification.Aggregation` say that an aggregation of one value is that value; no
   member, type or invariant changes. Check: `grep -c 'of one value is that value'
   spec/domains/specification.yaml` prints 2, and `task check:generated` finds no change of the
   generated crate.
4. `spec/presets.test.sh`: the entry "`runs: 1` with an aggregation" under "Not checked" gives
   the design's sentence of item 1 as the reason, and the copy `valid-one-run-with-aggregation`
   stays accepted. Check: `grep -c 'An aggregation of one value is that value'
   spec/presets.test.sh` prints 1, and the two last lines of `sh spec/presets.test.sh` are the
   ones it printed after unit 21.
5. Point 4 of "Not expressible yet" on `presets/latency.md`, `presets/resources.md`,
   `presets/start.md` and `presets/build.md`, each in its place so the numbering of the points
   stays, says that the point is "answered without a new form" (`docs/design.md` § 3, "One run
   per candidate is valid") and that the presets stay as they are. Check: for each of the four
   pages `grep -c 'answered without a new form'` prints 1, and the unit's own diff lists no
   file `presets/*.preset.yaml` (`git diff --name-only -- 'presets/*.preset.yaml'` over the
   tree of unit 21 prints nothing).

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
