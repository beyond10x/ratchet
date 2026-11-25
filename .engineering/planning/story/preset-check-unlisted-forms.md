---
format: aep.planning-md/3
id: story:preset-check-unlisted-forms
kind: story
status: draft
title: The preset check refuses or lists nine forms it accepts in silence
summary: Nine forms of a preset or declaration are accepted and not named under Not checked, and one comparison of the harness has no case.
relations:
- decomposes: epic:preset-catalog
scope:
- confidence: inferred
  path: docs/design.md
- confidence: inferred
  path: presets/README.md
- confidence: inferred
  path: spec/presets.test.sh
revision: 5
---
## Context

The adversary of `story:preset-catalog-runtime` (attack 1, commit `e6518eb`,
`review-result:adversary-preset-catalog-runtime-attack-1`, findings 8 and 10) found two things
in `spec/presets.test.sh` that were there before that unit, at `90924c9`:

- The script accepts defects of a preset or a declaration that the design names, and its
  header does not list them under "Not checked" (`spec/presets.test.sh:100`), while
  `presets/README.md` says the header lists what the script does not check. Accepted: an exact
  identity set with `aggregation: {kind: median}` (`docs/design.md:88`, exact: "None, or a
  sum"), and a declaration input with a reserved argument name such as `out`
  (`docs/evidence-format.md` § 10, "Reserved names"). Accepted as well, with no sentence of
  the design that forbids them outright: a percentile without `parameter`, a percentile with
  the parameter 250, a duration without `boundary`, a set without an identity key,
  `tolerance: {}`, an input that is required and has a default, an input that is neither.
- No case of the script's own harness proves the comparison of the line it prints with
  `--catalog` and `--spec`: with the comparison removed the script ends green.

## Acceptance

Each of the nine forms above is refused by `sh spec/presets.test.sh` with the message of a
rule, or stands in the header under "Not checked" with its reason, and the script fails when
the comparison of the line printed with `--catalog` and `--spec` is taken out; before the
story the nine forms are accepted without a word and the script stays green without the
comparison.

## Notes

- State after the corrections of attack 1 (`791fdc4`): `tolerance: {}` is refused on a
  requirement that compares a sampled measurement with an accepted value
  (`spec/presets.test.sh:1141`); the story checks the other places a tolerance stands. A
  tenth form, an adoption from the trusted revision without `runs`, is accepted and stands
  under "Not checked" with its reason (`spec/presets.test.sh:123`): `docs/design.md` § 5 says
  that the number has no default and names no report of `ratchet validate` for it. The story
  asks the design whether `validate` reports it.
- Where the design does not say whether a form is an error (the seven of the second list), the
  story asks the design first and writes the answer into `docs/design.md`.
- The story is a draft. It was there before the planned waves to 0.1.0 and waits for them.
- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s.
