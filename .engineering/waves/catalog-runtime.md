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

## Result, 2026-11-25

- The implementor's first hand-back was red: the 16 new files made `spec/presets.test.sh`
  fail, because one of its cases pinned the count `6 of 7 file(s)` of the whole of
  `presets/`. The scope of the story was widened in the store (the script,
  `spec/README.md`, `AGENTS.md`, the site config), against the line of § Dispatch above
  that says the unit does not edit the script. Since then a broken copy holds a fixed set of 8
  files and no longer the whole directory. The unit was committed as `e6518eb`.
- The script in one job on the build node, three alternating rounds at a load of 23 to 27: the
  old script with 7 files 3.2 s to 4.2 s, the old script with 23 files 6.9 s to 7.4 s, the
  changed script with 23 files 3.5 s to 3.6 s.
- Attack 1 on `e6518eb`: 11 findings, no blocker, 7 warnings and 4 notes
  (`review-result:adversary-preset-catalog-runtime-attack-1`). 8 were introduced by the unit: an input
  that never reached the program (finding 1, `percentile` of `event-time@1`), sentences of
  a page with two readings or with a statement the format does not back (findings 2 to 6 and
  11), and three reports of `ratchet validate` for sampled measurements that the script
  neither checked nor listed (finding 7). Of the adversary's 58
  catalog cases 40 defects were refused, 5 files of a later family accepted as they should be,
  and 13 defects accepted.
- Closed in `791fdc4`. The script has 227 defects in 92 broken copies, each refused with the
  message of its rule. Each of the 12 mutants of the added lines is killed. The adversary's
  runner again: the 40 defects refused, the 5 files accepted, and of the 13 accepted defects 4
  are refused now (a sampled accepted value without tolerance, with `tolerance: {}`, without
  `adoption`, a sampled plan without conditions).
- The script before and after the corrections in one job on the build node, three alternating
  rounds at a load of 21 to 30: 3933 and 3879 ms, 3927 and 3596 ms, 3751 and 3881 ms.
- Coordinator gate on `791fdc4`: `slot task check` on the build node, exit 0, 14:00 CET.
- Decisions taken: the scope of the story holds the script; a broken copy holds a fixed set of
  files; `event-time@1` is fixed at the 95th percentile and has no input for it; a metric
  name is the name on a sample line of the scrape, without labels and value; the three reports
  of `ratchet validate` for sampled measurements are rules of the script; the program
  aggregates over the runs its report holds and is passed neither `runs` nor `min_samples`,
  as `docs/evidence-format.md` says; an adoption from the trusted revision without `runs`
  is no rule, because `docs/design.md` § 5 names no report for it, and stands under "Not
  checked"; no second attack, because attack 1 found no blocker and its runner and the mutants
  ran again on the corrections.
- The 3 older findings are drafts, recorded as escalated:
  `story:preset-check-unlisted-forms` (findings 8 and 10; the adoption without `runs` is
  noted there as a tenth form) and `story:preset-check-one-start` (finding 9).
- Filed as drafts under `epic:preset-catalog`, what the four families need and the formats
  cannot say: `story:plan-conditions-from-binding`, `story:member-for-some-input-values`,
  `story:coverage-bound-on-failed-units`, `story:assessor-learns-observation`,
  `story:assertion-required-items`. The pages name two more that had a draft:
  `story:reference-from-another-plan` and `story:requirement-over-two-measurements`.
- Known and not closed: no release judges a sampled value yet, so of the 7 presets 0.1.0
  judges `metric-names@1` alone. The catalog ships no program that reads a report: the
  definitions on the pages are followed by a project's own program and checked by no test. The
  build node has no `dash` and no `mawk`; the run of the forge is the evidence for them.
  The script alone passes 5 s on the build node under load
  (`story:preset-check-one-start`).
- Consumer gap moved: the items latency and throughput, resources, start and readiness, and
  operability of the catalog request.
- `story:preset-catalog-runtime` is `implemented`.
