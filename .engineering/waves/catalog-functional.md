# Catalog story 1: the functional family

Plan: [ROADMAP.md](../../ROADMAP.md) § "Beside the waves". Run by the skill `aep:implementing`,
version 0.26.0, wave mode. Approval: `approval-record:preset-catalog-stories`.

## Unit

- `story:preset-catalog-functional`: `presets/` with file names declared in the specification,
  `spec/presets.test.sh` in `task check:spec`, and the presets of the functional family.
  Objective: `epic:preset-catalog`. Consumer gap moved: the first item of the catalog request,
  functional criteria.

`aep plan artifact waves --kind story --status active`, the lines that name the unit:

```
wave 2
  story:assessor-declaration
  story:evidence-reader
  story:preset-catalog-functional (inferred)
  story:reference-compare
```

The derivation places the unit behind `story:cli-skeleton-validate` because both name
`Taskfile.yml` and the generated crate. The epic's rule is that a catalog story starts between
two waves, from the `main` of that moment: wave 3 is merged (`7ac2b7a`), wave 4 has not started
and waits for a decision of the owner on `crates/ratchet-model/`. The unit writes no file under
`crates/ratchet-model/`, which does not exist. N is 1.

## Dispatch

- `aep:implementor` for the unit, then `aep:adversary` on its result, at most two attacks.
- The implementor makes no commit and writes nothing under `.engineering/`.
- The branch `catalog/functional` starts at `main` (`beb21b3`). The pull request of release
  0.0.1 is open at that moment and moves the lines of `CHANGELOG.md` under a dated heading.
  The implementor therefore reports its changelog lines, and the coordinator writes them under
  `## [Unreleased]` after `main` with the release commit is merged into the branch.
- Wave 4 and the release keep priority when they collide with this unit.

## Commits this unit makes

This page, one commit for the unit, corrections after an attack, the closing store commit, and a
pull request to `main` merged through the bot. No tag and no release.

## Pre-flight, 2026-11-25 03:10 CET

- Primary checkout clean, on `main` at `beb21b3`.
- Free disk on `/`: 61 G.
- `slot status`: 31 of 40 slots free, 0 queued; run-time limit 10 m per job.
- `ess` 0.98.0, `aep` 0.80.0, `rustc` 1.99.1.
