---
format: aep.planning-md/3
id: story:preset-check-unlisted-forms
kind: story
status: implemented
title: The preset check refuses or lists the 14 forms it accepts in silence
summary: 14 forms of a preset or declaration are accepted and not named under Not checked (2 of them forbidden by the design), and one comparison of the harness has no case.
relations:
- decomposes: epic:preset-catalog
scope:
- confidence: inferred
  path: presets/README.md
- confidence: inferred
  path: spec/presets.test.sh
revision: 14
transitions:
- {from: "draft", to: "proposed", at: "2026-11-26T05:20:03Z", actor: "human:operator", revision: 12}
- {from: "proposed", to: "active", at: "2026-11-26T05:20:03Z", actor: "human:operator", revision: 13}
- {from: "active", to: "implemented", at: "2026-11-26T07:54:32Z", actor: "human:operator", revision: 14, decided_on: {"recorded":{"test_result":1,"review_outcome":3}}}
---
## Context

The adversary of `story:preset-catalog-runtime` (attack 1, commit `e6518eb`,
`review-result:adversary-preset-catalog-runtime-attack-1`, findings 8 and 10) and attack 1 on
`story:preset-catalog-factory` (`review-result:adversary-preset-catalog-factory-attack-1`,
findings 16 and 17; its cases b01, b02, b03, b07 and b08, run on `dd2cba5`) found two things in
`spec/presets.test.sh` that were there before those units, at `90924c9`:

- The script accepts forms of a preset or a declaration, listed in the Notes (1 to 14), and
  its header does not list them under "Not checked" (`spec/presets.test.sh:107` at `7aa82f8`),
  while `presets/README.md` says the header lists what the script does not check. Two of them
  the design forbids: an exact identity set with `aggregation: {kind: median}`
  (`docs/design.md:88`, exact: "None, or a sum"), and a declaration input with a reserved
  argument name such as `out` (`docs/evidence-format.md:624`, "Reserved names"). For the
  others no sentence of the design forbids them outright.
- No case of the script's own harness proves the comparison of the line it prints with
  `--catalog` and `--spec` with the line of the check in process (`spec/presets.test.sh:1600`):
  with the comparison removed the script ends green.

## Acceptance

The story keeps 12 forms, 1 to 12 of the Notes. Forms 1 and 2, which `docs/design.md:88` and
`docs/evidence-format.md:624` forbid, are refused by `sh spec/presets.test.sh` with the message
of a rule, each with a broken copy; the refused set is these two forms and no other. Forms 3
to 12 stand in the header under "Not checked", each with its reason. Form 13 stands under "Not
checked" with `story:value-over-all-runs` named as the story that decides it. Form 14 stands
under "Not checked" with its reason the sentence that
`story:specification-answers-first-format-consumer` (finding 11) writes into `docs/design.md`
§ 3, the paragraph "One run per candidate is valid" (`:114` at `7aa82f8`), on an aggregation
with `runs: 1`: the header quotes that sentence, and adds that the script cannot see whether a
command repeats its measurement itself. For form 7 the header or a rule covers each place a tolerance stands: `reference.tolerance` of a requirement, the one field of the
type `ratchet.specification.Tolerance` (`spec/domains/specification.yaml:574-575`), on an exact
measurement with a reference `accepted_value` (as `presets/image-size@1.preset.yaml:47`) and
with a reference `generated`, beside the sampled measurement and the window over runs, refused
since `791fdc4` (`spec/presets.test.sh:1141`, case at `:2523`). Before the story the 14 forms
are accepted without a word.

The script's harness holds a case that fails the run when the comparison at
`spec/presets.test.sh:1600` (the line printed with `--catalog` and `--spec` against the line of
the check in process) is deleted. A case cannot delete its own line, so the case writes a copy
of the script under `target/presets`, edits the copy so that the line it prints with
`--catalog` and `--spec` differs from the line of its check in process, runs the copy, and
expects exit 1 with the message of the comparison. With the comparison deleted from the
script, the copy carries no comparison, exits 0, and the case fails the run. Before the story
the script stays green with the comparison deleted. The time of the new case is measured and
stated in the implementor's report; it stays inside the 60 s bound of one test and the 120 s of
the step.

## Notes

- Taken ahead of the waves to 0.1.0 into one wave built in sequence on one branch: every
  planned wave starts behind `story:cli-skeleton-validate`, which waits for an ESS release
  (beyond10x/ess#836). No `ratchet` command exists in this wave, so every acceptance item is
  observed through `task check` steps, the POSIX sh scripts under `spec/` and
  `.github/scripts/`, `ess specify validate`, or files. It is 6 of the nine in the order of
  `.engineering/waves/0.1.0-ahead-1.md`. Stories 3 to 5 of that order can change the same
  script before this one, so its line numbers move.
- The forms. The design forbids:
  1. an exact identity set with `aggregation: {kind: median}`;
  2. a declaration input with a reserved argument name such as `out`.
  No sentence of the design forbids outright:
  3. a percentile without `parameter`;
  4. a percentile with the parameter 250;
  5. a duration without `boundary`;
  6. a set without an identity key;
  7. `tolerance: {}` in the places named in the Acceptance;
  8. an input that is required and has a default;
  9. an input that is neither required nor has a default;
  10. the one row of a preset with one measurement on the page of another family, while
      `presets/README.md:113` says that a measurement has its row on the page of its family
      (the script checks that the rows of one preset stand on one page, and no file names the
      family page of a preset);
  11. a plan without a condition that the declaration of its assessor lists;
  12. `min_samples` above `runs`, both literals.
  Two forms on `runs`, decided by other stories:
  13. a sampled measurement with a literal `runs` above 1 and no aggregation:
      `story:value-over-all-runs`;
  14. `runs: 1` with an aggregation (`docs/design.md:114`): the sentence that
      `story:specification-answers-first-format-consumer` (finding 11, built before this
      story) writes there for the existing aggregation kinds when the command repeats its
      measurement itself is the reason in the header; `story:member-for-some-input-values`
      keeps a preset that declares the aggregation for every value of `runs`.
- The story writes no new rule into `docs/design.md`: the catalog adds no rule to the format on
  its own (`epic:preset-catalog`, "Rules of the catalog"). A form the design does not already
  forbid stands under "Not checked" with its reason.
- An adoption from the trusted revision without `runs` already stands under "Not checked"
  with its reason (`spec/presets.test.sh:123-126` at `7aa82f8`); it is no form of this story.- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s.
