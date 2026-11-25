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

## Result, 2026-11-25

- The unit was committed as `66b80de`; `main` with release 0.0.1 was merged in (`53abbff`)
  and the changelog lines written after it (`954445d`).
- Attack 1 on `954445d`: 11 findings, 6 warnings and 5 notes, 10 introduced by the unit
  (`review-result:adversary-preset-catalog-functional-attack-1`). 65 of 104 changed copies of
  the script stayed green, and 37 of 75 broken catalog copies were accepted. Closed in
  `886e4db`; the one older finding, a rename listed by its new path alone in `pages.yml`, was
  closed with it because a changelog line of the unit depends on it.
- Attack 2 on `886e4db`: 16 findings, 2 blockers, 6 warnings and 8 notes, all introduced by
  the unit (`review-result:adversary-preset-catalog-functional-attack-2`). The blockers: the
  built-in `record-series@1` was refused for a missing declaration file, and C1 control
  characters and the line breaks U+0085, U+2028 and U+2029 passed. The attack was stopped
  before its end, because tests run on the build node alone and the node did not answer; its 25
  prepared cases ran later with the corrections.
- The corrections were written without a run (`395254e`), and the forge ran them first: 218 of
  219 copies refused. The one accepted copy was a join at the wrong path depth, fixed in
  `996cba2` with the other results of the run on the node.
- State of the script in `996cba2`: 220 defects in 90 broken copies, each refused with the
  message of its rule; defects that stand apart share a copy. The script alone on the build
  node: 3429, 3351 and 3774 ms in three runs; with a load of 26 to 83 on 32 CPUs, 3217 to
  12735 ms in six runs, against 6163 to 24811 ms with one copy per defect (219 copies).
- Each of the 112 `fail(` and `norule(` calls of the script, taken out alone, fails the run.
  Of 17 `given` guards taken out alone, 3 leave the run green (lines 1088, 1092 and 1098, the
  names a requirement writes): a name that is a reference is refused before them.
- The runner of the corrections, 118 cases with the reproducers of attack 2: 0 differ from
  the expected result.
- Coordinator gate on the content of `996cba2`: `slot task check` on the build node, exit 0;
  11 tests passed, 48 classifier cases.
- Decisions taken: `record-series@1` is a reserved name and has no declaration file; the name
  by which a requirement names an assessment, a measurement or a statement of its preset is
  written out and is no reference (`docs/design.md` § 4 and § 12); `run_time` and
  `queue_wait` are boundaries of Ratchet itself; a list is a flow list; no third attack.
- Filed as drafts under `epic:preset-catalog`, what the family needs and the formats cannot
  say: `story:reference-from-another-plan`, `story:requirement-over-two-measurements`,
  `story:item-field-values`.
- Known and not closed: the script alone passes 5 s on the build node under load. The build
  node has no `dash` and no `mawk`; the run of the forge is the evidence for them, and the
  portability cases of attack 2 were not run. What the script does not check is listed in
  its header (`spec/presets.test.sh:100`).
- Consumer gap moved: the first item of the catalog request, functional criteria.
- `story:preset-catalog-functional` is `implemented`.
