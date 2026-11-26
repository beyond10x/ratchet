---
format: aep.planning-md/3
id: review-result:critics-local-gate-pinned-ess
kind: review-result
status: active
title: acceptance and scope critics on story:local-gate-pinned-ess, two rounds
relations:
- reviews: story:local-gate-pinned-ess
revision: 1
---
Recorded by the coordinator from the reports of two plan critics on
`story:local-gate-pinned-ess`, before its implementation: the acceptance critic and the scope
critic, two rounds each. The findings are in the critics' words, shortened.

## Round 1, story revision 4

Acceptance critic: needs-revision, seven findings.

1. The starting state ("a newer `ess` in `PATH` that holds the required release beside it")
   named no command a reviewer can use to see it.
2. The acceptance named only `task check:spec`; the call of `check-generated.sh` was not
   covered.
3. "Runs every `ess` call with the required release" had no observable; the dispatcher's note
   `delegating to ess 0.98.0` is one.
4. The script test of the pin, named in the Notes and the Scope, had no sentence in the
   acceptance.
5. "On the forge it exits 0 as before" named no check and no reference run.
6. The Notes said the version comes from one place; the Scope has four places held equal by
   a test.
7. The pin comes from the `env:` of `Taskfile.yml`, so the gate must be run through `task`.

Scope critic: needs-revision, four findings.

1. The pin test's comparison of `pages.yml` with `release.yml` repeats `workflow_pins` of
   `.github/scripts/release.test.sh`; name the new test file.
2. "One pin from one place" contradicted the design; say which value is the pin and which
   are copies.
3. The story was the only one of 54 with no relation; `informed_by:
   story:workspace-cli-contract`.
4. The `env:` reaches `check-generated.sh` only under `task`, while `AGENTS.md` names direct
   runs of the script and its test.

All eleven were taken into the story (revisions 5 to 8): the acceptance critic's proposed
text, with the test named `.github/scripts/ess-pin.test.sh` and three broken copies.

## Round 2, story revision 8

Scope critic: approve, no finding.

Acceptance critic: needs-revision, two findings. `check-generated.sh` writes the generator's
output to `target/check-generated/ratchet-cli-contract.txt` and prints it only on failure, so
the note is in that file and not in the output of `task check:generated`; the placeholder
`<required release>` was undefined, and on the forge only the lines of `task check:spec` can
show that no note is there. The critic gave the wording; the story carries it from revision
9. No third read was asked for: the wording is the critic's own.

```findings
- file: .engineering/planning/story/local-gate-pinned-ess.md
  category: acceptance
  severity: warning
  origin: introduced
  message: "the starting state named no command a reviewer can use"
- file: .engineering/planning/story/local-gate-pinned-ess.md
  category: acceptance
  severity: warning
  origin: introduced
  message: "the call of check-generated.sh was not covered"
- file: .engineering/planning/story/local-gate-pinned-ess.md
  category: acceptance
  severity: warning
  origin: introduced
  message: "running the required release had no observable"
- file: .engineering/planning/story/local-gate-pinned-ess.md
  category: acceptance
  severity: warning
  origin: introduced
  message: "the pin test had no sentence in the acceptance"
- file: .engineering/planning/story/local-gate-pinned-ess.md
  category: acceptance
  severity: warning
  origin: introduced
  message: "the forge side named no check and no reference run"
- file: .engineering/planning/story/local-gate-pinned-ess.md
  category: acceptance
  severity: note
  origin: introduced
  message: "one place against four places held equal"
- file: Taskfile.yml
  line: 88
  category: acceptance
  severity: note
  origin: introduced
  message: "the gate must be run through task to read the pin"
- file: .github/scripts/release.test.sh
  line: 1343
  category: scope
  severity: warning
  origin: introduced
  message: "the pin test repeated the comparison of the two workflows"
- file: .engineering/planning/story/local-gate-pinned-ess.md
  category: scope
  severity: warning
  origin: introduced
  message: "which value is the pin was not said"
- file: .engineering/planning/story/local-gate-pinned-ess.md
  line: 1
  category: scope
  severity: warning
  origin: introduced
  message: "no relation to the plan"
- file: AGENTS.md
  line: 189
  category: scope
  severity: warning
  origin: introduced
  message: "direct runs of check-generated.sh get no pin"
- file: .github/scripts/check-generated.sh
  line: 67
  category: acceptance
  severity: warning
  origin: introduced
  message: "round 2: the note of check:generated is in a file, not in the task output"
- file: .engineering/planning/story/local-gate-pinned-ess.md
  category: acceptance
  severity: note
  origin: introduced
  message: "round 2: an undefined placeholder and a forge sentence wider than its log"
```
