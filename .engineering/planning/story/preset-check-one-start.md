---
format: aep.planning-md/3
id: story:preset-check-one-start
kind: story
status: draft
title: The preset check judges its broken copies in one run of the check
summary: Each of the 92 broken copies costs one run of check_catalog (cat, tr, wc and the awk check); the story judges them in one run. The script is inside the test budget already.
relations:
- decomposes: epic:preset-catalog
scope:
- confidence: inferred
  path: spec/README.md
- confidence: inferred
  path: spec/presets.test.sh
revision: 6
---
## Context

`sh spec/presets.test.sh` is a step of `task check:spec`. On the build node (32 CPUs) it ran
6.1 s, 7.2 s and 13.7 s under a load of 25 to 32, and 3.2 s to 4.2 s under a load of 23 to 27
(the adversary of `story:preset-catalog-runtime`, attack 1, finding 9, and the implementor's
measurement of the same unit). At `791fdc4`, three alternating rounds at a load of 21 to 30 ran
3596 ms to 3933 ms. The check of the whole of `presets/` takes about 0.1 s of it.

The rest is the harness of the script and its 92 broken copies. Each copy is checked in the
running script, not by a new start of it: `check_copy` calls `check_catalog`
(`spec/presets.test.sh:1381-1387`) from `judge_cases` (`:1429`), and the specification is read
into its tables once (`:1257`) and again only for the 4 copies with a specification of their
own (`own_spec`, `:1325-1328`). The script starts itself 4 times, all in its harness
(`:1600`, `:1609`, `:1625`, `:1642`). It was the same at `90924c9`.

The cost of one copy, at most 42 ms (3933 ms / 92): one `cp -R` of the 8 files of the set
(`:1311-1317`), and one run of `check_catalog`: `cat`, `tr` and `wc` over the copy (`:256`)
and one run of the check's awk program (`:297-1239`), which parses its program and reads the
tables and the 8 files. Each case adds an `awk` and an `mv` for its edit and a `grep` in
`judge` (`:1391`). The check of the copy is the guard and stays; what one copy costs beside it
is the start of those processes.

At `7aa82f8` the script is inside the step budget of 120 s and the bound of 60 s for one test,
also at the highest time measured (13.7 s). The story cuts no cost the budget asks to cut now.
It cuts the per-copy starts, which grow with every rule that gets a copy; a family the catalog
gets adds no copy (`:1293-1296`).

## Acceptance

The script judges all its broken copies from one run of `check_catalog` (or an equal change
that removes the per-copy runs of the check): the lines `+ check_catalog` in the trace of
`sh -x spec/presets.test.sh` fall by at least 91, from one per broken copy (92 at `7aa82f8`,
the count of the script's last line) to one for all of them; its two last lines and its exit
status are what they were, and every defect is still refused with the message of its rule.

The median run time of the new script over at least 5 alternating rounds, old and new, in one
job on the build node is lower than the median of the old script, the one at the wave's base
commit `7aa82f8`; the report names both medians and the load. The rounds run in one measuring
script started without the `slot` prefix: a script that only measures stays off the build pool.

## Notes

- It left the wave of `.engineering/waves/0.1.0-ahead-1.md` on 2026-11-26. Each copy is
  already checked in the running script (§ Context), and the highest time measured, 13.7 s, is
  inside the step budget of 120 s: the wave has no cost of this script to cut. The story stays
  a draft.
- Revision 3 said that each copy costs a start of the script that parses the specification
  again, and asked for half the run time. Neither held at `90924c9` or at `7aa82f8`; the
  acceptance no longer names a factor.
- No guard is lost: the defects, the harness cases and the stops of the script stay, and the
  mutants of the changed lines are killed.
- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s.
