# Catalog story 2: latency, resources, start and operability

Plan: [ROADMAP.md](../../ROADMAP.md) § "Beside the waves". Run by the skill `aep:implementing`,
version 0.26.0, wave mode. Approval: `approval-record:preset-catalog-stories`.

## Unit

- `story:preset-catalog-runtime`: the preset files, the assessor declarations and the pages of
  the four families that are observed while a fixed workload runs against a started service.
  Objective: `epic:preset-catalog`. Consumer gap moved: four items of the catalog request,
  latency and throughput, resources, start and readiness, and operability.

`aep plan artifact waves --kind story --status active`, the lines that name the unit:

```
wave 1
  story:cli-skeleton-validate
  story:preset-catalog-runtime
```

The epic's rule is that a catalog story starts between two waves, from the `main` of that
moment: wave 3 and the first catalog story are merged (`90924c9`), and wave 4
(`story:cli-skeleton-validate`) is not dispatched: it waits for the ESS release that carries
the reading rules of the generated crate. The unit writes under `presets/` alone, where the
other story of its wave writes nothing. N is 1.

## Dispatch

- `aep:implementor` for the unit, then `aep:adversary` on its result, at most two attacks.
- The implementor makes no commit and writes nothing under `.engineering/`.
- The branch `catalog/runtime` starts at `main` (`90924c9`).
- `spec/presets.test.sh` and `presets/README.md` are not edited by the unit (story § Scope).
  The script checks 90 broken copies of the whole of `presets/`, so each added file costs time
  in every copy: the implementor reports the run time of the script before, after each family
  and at the end, and a jump is fixed as a task of its own in this unit.
- Every test, the script included, runs through `slot` on the build node.
- Wave 4 keeps priority when it collides with this unit.

## Commits this unit makes

This page, one commit for the unit, corrections after an attack, the closing store commit, and a
pull request to `main` merged through the bot. No tag and no release.

## Pre-flight, 2026-11-25 12:39 CET

- Primary checkout clean, on `main` at `90924c9`.
- Free disk on `/` of the workstation: 40 G.
- `slot status`: 31 of 40 slots free, 0 queued; run-time limit 10 m per job.
- `aep` 0.80.0, `rustc` 1.99.1. `ess` runs on the build node, at the release
  `spec/ess-inputs.yaml` pins (0.98).
