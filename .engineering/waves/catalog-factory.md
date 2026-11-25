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

## Result, 2026-11-25

- The build node of the pre-flight ended at 14:00 CET, while the implementor wrote. Its first
  hand-back held the 24 new files and 3 edits and no run. Nothing was built or tested on the
  workstation until the owner opened its pool for builds (about 15:22 CET). The first run of
  the unit, unchanged: `slot sh spec/presets.test.sh`, exit 0, 47 of 47 files valid, 41 of
  41 measurements with a row. The script did not change in this unit, against the line of
  § Dispatch that allows it: no family was the first to reach a rule.
- The gate on the workstation runs with the release 0.98.0 of `ess` first in `PATH`,
  fetched with the checksum of `.github/workflows/pages.yml`: the workstation has another
  release, and `spec/ess-inputs.yaml` pins 0.98.
- Attack 1 (`review-result:adversary-preset-catalog-factory-attack-1`), in three parts. Part 1
  read the uncommitted unit while nothing could run: 18 findings, no blocker, 16 introduced
  by the unit and 2 on the unchanged script.
  The 16 were corrected and the unit committed as `09a48ee`. Part 2 read the commit: the
  16 are closed, and 7 more findings, no blocker: six sentences the corrections had added
  (findings 19 to 24, closed in `dd2cba5`) and the run time of the script in one job
  (finding 25).
- What the 22 findings on the unit were: a meaning and a page that said more than the value
  gives (`test-time@1`: the median over the runs of the slowest execution of a run, so "no
  test above the limit" holds with a report of one run); a condition the declaration lists
  and two plans did not declare (`cache_profile`); a rate that grows with the runs and a
  plan that named no fewest number of them (`min_samples`); and definitions with two
  readings (a warm test step, a failed execution, a package of the project, the platform of
  an image, the id of an advisory, the order of two findings on one line, a path of
  `generated_paths`), or with a statement the formats do not back (the cause
  `too_few_samples` outside a time window).
- The runs of part 2 on `dd2cba5`: the adversary's 77 cases in one job with 13 starts of
  the script, exit 0. The 61 defects in files of the unit are refused, each by a line that
  names its file and the words of its rule; the 16 forms expected to pass are accepted.
- Coordinator gate on `dd2cba5`: `slot task check` in the pool of the workstation, exit 0,
  16:52 CET, 45 s of wall time for the whole gate at a load of 2 to 5. Finding 25: the 79 s of the
  script in one earlier job fell into minutes in which the pool had no free slot; no change.
- Decisions taken: the plans of the build family write `cache_profile`, the name of the
  evidence member, and `story:cache-condition-one-name` holds the question of the two
  names; `test-step-time@1` and `test-time@1` take the default limits 120 s and 60 s that
  `research/candidate-presets.md` names; an item of the advisory set is the pair of an
  advisory and a package, and the text of the story says so now; `code-lines@1` takes the
  direction of its two counts from the binding (`docs/design.md` § 4 allows a reference
  there); `flake-rate@1` declares no aggregation; the target of an image or a binary is of
  the kind `revision`; no timing loop against the base commit, because the pool of the
  workstation takes no run that is repeated to time it; no further read after the six
  sentences, because each follows the change the adversary named and the gate and the 77
  cases ran on the commit that holds them.
- The 2 older findings are recorded as escalated on `story:preset-check-unlisted-forms`
  (findings 16 and 17), which gains five accepted forms and covers fourteen.
- Filed as drafts under `epic:preset-catalog`, what the three families need and the formats
  cannot say: `story:value-over-all-runs`, `story:build-target-invocation`,
  `story:input-allowed-values`, and the older `story:cache-condition-one-name`. Two
  drafts gained what the first consumer of the formats reported from its read:
  `story:assessor-learns-observation` and
  `story:specification-answers-first-format-consumer`.
- Known and not closed: no release judges a sampled value yet, so of the 12 presets 0.1.0
  judges the seven of the artifact and the code family. The catalog ships no program that
  reads a report: the definitions on the pages are followed by a project's own program and
  checked by no test. The workstation has no `dash` and no `mawk`; the run of the forge is
  the evidence for them. No rule of the script keeps a plan's condition in step with the
  list of its declaration, or a row on the page of its family
  (`story:preset-check-unlisted-forms`).
- Consumer gap moved: the items build, artifact and code of the catalog request. `presets/`
  holds the eight families of `epic:preset-catalog`.
- `story:preset-catalog-factory` is `implemented`.
