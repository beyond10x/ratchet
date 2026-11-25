---
format: aep.planning-md/3
id: story:preset-check-one-start
kind: story
status: draft
title: The preset check judges its broken copies in one start
summary: Each of the 90 copies costs a start of the script; the story removes that and halves the run time.
relations:
- decomposes: epic:preset-catalog
scope:
- confidence: inferred
  path: spec/README.md
- confidence: inferred
  path: spec/presets.test.sh
revision: 3
---
## Context

`sh spec/presets.test.sh` is a step of `task check:spec`. On the build node (32 CPUs) it ran
6.1 s, 7.2 s and 13.7 s under a load of 25 to 32, and 3.2 s to 4.2 s under a load of 23 to 27
(the adversary of `story:preset-catalog-runtime`, attack 1, finding 9, and the implementor's
measurement of the same unit). The check of the whole of `presets/` takes about 0.1 s of it.
The rest is the cases of the script's own harness and its 90 broken copies: each copy is
checked by a new start of the script (`sh "$self"`), which parses the specification again.
The time was the same before that unit (`90924c9`).

The budget of the repository is 120 s for the test step and 60 s for one test, and the script
is inside both. A step that takes seconds for 90 small directories still grows with every
rule that gets a copy.

## Acceptance

The script checks its broken copies without starting itself once per copy (one start reads
the specification and judges every copy, or an equal change), its two last lines and its exit
status are what they were, every defect is still refused with the message of its rule, and
its run time on the build node, measured against the script before the change in one job with
alternating rounds, is at most half; before the story each copy costs a start of the script.

## Notes

- No guard is lost: the defects, the harness cases and the stops of the script stay, and the
  mutants of the changed lines are killed.
- The story is a draft. It was there before the planned waves to 0.1.0 and waits for them.
- POSIX sh and awk, no Python.
