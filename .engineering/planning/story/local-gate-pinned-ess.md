---
format: aep.planning-md/3
id: story:local-gate-pinned-ess
kind: story
status: implemented
title: The local gate runs the ess release the specification requires
relations:
- informed_by: story:workspace-cli-contract
scope:
- confidence: inferred
  path: .github/scripts/ess-pin.test.sh
- confidence: inferred
  path: AGENTS.md
- confidence: inferred
  path: CHANGELOG.md
- confidence: cited
  path: Taskfile.yml
revision: 12
transitions:
- {from: "draft", to: "proposed", at: "2026-11-26T03:55:04Z", actor: "human:operator", revision: 10}
- {from: "proposed", to: "active", at: "2026-11-26T03:55:04Z", actor: "human:operator", revision: 11}
- {from: "active", to: "implemented", at: "2026-11-26T04:19:56Z", actor: "human:operator", revision: 12, decided_on: {"recorded":{"test_result":1}}}
---
## Context

`spec/ess-inputs.yaml` requires `ess 0.98`, and the gate runs `ess` by its bare name: three
calls in `Taskfile.yml` (task `check:spec`: `ess specify validate`, `ess specify cli`,
`ess generate synthesize`) and one in `.github/scripts/check-generated.sh` (`ess generate
cli`), which `check:generated`, `generate` and, through `check-generated.test.sh`,
`check:scripts` start. The forge installs the release 0.98.0 first in `PATH`
(`.github/workflows/pages.yml`, `.github/workflows/release.yml`, `ESS_VERSION: "0.98.0"`).
A host with a newer release in `PATH` refuses the step: on 2026-11-26 the workstation and the
build node both have 0.99.2 in `PATH`, and `task check:spec` ends with
`error: spec/ess-inputs.yaml requires ess 0.98 and this is ess 0.99.2, which is newer, and
--strict-requires refuses a newer release`. Both hosts hold 0.98.0 beside it; the variable
`ESS_TOOLCHAIN=0.98.0` makes the bare `ess` delegate to it, as the build pool's operator
measured that day.

Until then each session found its own way: a copy of the release in a scratch directory
first in `PATH` (which the build pool refuses), or `slot --here` with a copy under `target/`.
That is a difference between the local gate and the forge that the repository does not
write down (`~/beyond10x/AGENTS.md` § "The local gate equals the forge" asks it to).

## Acceptance

On a host where `ess --version` prints a release newer than `ess <major>.<minor>` of
`spec/ess-inputs.yaml` and `ESS_TOOLCHAIN=0.98.0 ess --version` prints `ess 0.98.0` (behind
the note `delegating to ess 0.98.0`), `task check:spec` and `task check:generated` each exit
0; the output of `task check:spec` and the file
`target/check-generated/ratchet-cli-contract.txt` hold the note `delegating to ess 0.98.0`
and neither holds a `--strict-requires` refusal; at `main`
`a23cbf9` the same `task check:spec` ends with that refusal. `task check:scripts` runs the
script test `.github/scripts/ess-pin.test.sh`, which passes on the tree and fails, with a
message that names the file, for each of three broken copies: `ESS_TOOLCHAIN` of
`Taskfile.yml` differs from `ESS_VERSION` of `.github/workflows/pages.yml`; `ESS_VERSION` of
`pages.yml` differs and `Taskfile.yml` follows it; the requirement of `spec/ess-inputs.yaml`
is not the major and minor of `ESS_TOOLCHAIN`. On the forge, where 0.98.0 is the `ess` in
`PATH`, the required check `Repository gate` of the pull request ends green and the lines of
its `task check:spec` hold no `delegating` note; the run on `main` before the merge is green
too.

## Notes

- The pin of the local gate is `ESS_TOOLCHAIN` in the `env:` of `Taskfile.yml`. The
  `ESS_VERSION` of the two workflows is the forge's copy, and `spec/ess-inputs.yaml` holds the
  requirement. The new test fails when the Taskfile value is not the value of `pages.yml` or
  not within the requirement. `.github/scripts/release.test.sh` already compares the
  `ESS_VERSION` of `pages.yml` with that of `release.yml` (`pins`, `workflow_pins`); the new
  test does not repeat it.
- The gate is run through `task`. `ESS_TOOLCHAIN` comes from the `env:` of `Taskfile.yml`, so
  `sh .github/scripts/check-generated.sh` or its test started directly gets no pin on such a
  host; `AGENTS.md` says that the scripts that run `ess` are run through `task`
  (`task check:generated`, `task check:scripts`, `task generate`).
- `ESS_TOOLCHAIN` is read by the `ess` dispatcher, and 0.98.0 is one: measured on
  2026-11-26, the release 0.98.0 with `ESS_TOOLCHAIN=0.98.0` runs itself
  (`ess specify validate --path spec --strict-requires`: "valid", exit 0), and with
  `ESS_TOOLCHAIN=0.99.2` it delegates to 0.99.2 (`note: ess 0.98.0 is the dispatcher;
  delegating to ess 0.99.2`), which the requirement refuses. So the variable set to the
  pinned release changes nothing where that release is the one in `PATH` (the forge) and
  selects it where a newer one is (the hosts).
- Not established: whether the root `env:` of `Taskfile.yml` reaches the tasks of the
  optional included `acceptance/Taskfile.yml`. No `ess` call is known there; when
  `story:acceptance-in-gate` lands, it checks this.
- No path of a workstation goes into the repository.
- POSIX sh, no Python. The test step ends within 120 s, no test over 60 s.

## Scope

Derived 2026-11-26 by the coordinator at `main` `a23cbf9`; read by the scope critic.

- **Files:** `Taskfile.yml`: one root `env:` entry `ESS_TOOLCHAIN`, so that the three calls
  of `check:spec` and the call of `.github/scripts/check-generated.sh` read it (cited).
- **Files:** `.github/scripts/ess-pin.test.sh` (new, POSIX sh): the pin test, run by
  `task check:scripts` with the other `.github/scripts/*.test.sh` (inferred).
- **Read only:** `spec/ess-inputs.yaml`, `.github/workflows/pages.yml`,
  `.github/workflows/release.yml`, `.github/scripts/check-generated.sh` (cited; the pin does
  not move).
- **Documents:** `AGENTS.md` (how the gate and the scripts that run `ess` are run, the table
  of files), `CHANGELOG.md` (one line under `### Changed`) (inferred).
- **Shares files, no collision:** `story:acceptance-in-gate` (active) edits the `cmds` of
  `check` in `Taskfile.yml` and `CHANGELOG.md`; `story:cli-skeleton-validate` (active) names
  `AGENTS.md` and `check-generated.sh`.
