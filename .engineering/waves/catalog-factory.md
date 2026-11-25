# Catalog story 3: build, artifact and code

Plan: [ROADMAP.md](../../ROADMAP.md) § "Beside the waves". Run by the skill `aep:implementing`,
version 0.26.0, wave mode. Approval: `approval-record:preset-catalog-stories`.

## Unit

- `story:preset-catalog-factory`: the preset files, the assessor declarations and the pages of
  the three families that are read from a build and from the tree, without a running service.
  Objective: `epic:preset-catalog`. Consumer gap moved: three items of the catalog request,
  build, artifact and code.

`aep plan artifact waves --kind story --status active`, the lines that name the unit:

```
wave 1
  story:cli-skeleton-validate
  story:preset-catalog-factory
```

The epic's rule is that a catalog story starts between two waves, from the `main` of that
moment. Wave 4 (`story:cli-skeleton-validate`) is not dispatched: it waits for the ESS
release that carries the reading rules of the generated crate. The second catalog story is
closed and its pull request (#35, head `e5a9cf3`) waits for the checks of the forge. The
branch of this unit starts at that head and not at `main`: the unit needs the files of the
second story (the fixed set of copies, the three rules for sampled measurements, the list of
pages), and `main` holds them after the merge. If #35 changes before it is merged, this
branch takes `main` in before its own pull request. N is 1.

## Dispatch

- `aep:implementor` for the unit, then `aep:adversary` on its result, at most two attacks.
- The implementor makes no commit and writes nothing under `.engineering/`.
- The branch `catalog/factory` starts at `e5a9cf3`.
- The scope of the story holds what the second story had to add after its first hand-back: the
  list of pages in `presets/README.md`, the sentence of the site that names the families, and
  the script where a family is the first to reach a rule.
- What two attacks and three hand-backs of the first two stories found goes into the brief: a
  page is the definition a project's program follows, so each term has one reading; an input
  a declaration does not pass reaches no program; a program is passed neither `runs` nor
  `min_samples`; a sampled measurement declares a condition, and against an accepted value a
  tolerance and an adoption.
- Every test, the script included, runs through `slot` on the build node.
- Wave 4 keeps priority when it collides with this unit.

## Commits this unit makes

This page, one commit for the unit, corrections after an attack, the closing store commit, and a
pull request to `main` merged through the bot. No tag and no release.

## Pre-flight, 2026-11-25 14:03 CET

- Primary checkout clean, on `main` at `90924c9`.
- Free disk on `/` of the workstation: 123 G.
- `slot status`: 32 of 40 slots, 32 free, 0 running, 0 queued; run-time limit 10 m per job.
- `aep` 0.80.0. `ess` runs on the build node, at the release `spec/ess-inputs.yaml` pins
  (0.98).
- `sh spec/presets.test.sh` at `791fdc4`, in the gate on the build node: 227 of 227
  defects refused, 23 of 23 files valid, 26 of 26 measurements with a row, 92 of 92 broken
  copies refused.
