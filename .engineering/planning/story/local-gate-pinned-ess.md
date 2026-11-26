---
format: aep.planning-md/3
id: story:local-gate-pinned-ess
kind: story
status: draft
title: The local gate runs the ess release the specification requires
scope:
- confidence: cited
  path: Taskfile.yml
- confidence: cited
  path: spec/ess-inputs.yaml
revision: 2
---
## Context

`spec/ess-inputs.yaml` requires `ess 0.98`, and the gate runs `ess` by its bare name
(`Taskfile.yml`, task `check:spec`: `ess specify validate`, `ess specify cli`,
`ess generate synthesize`). The forge installs the release 0.98.0 first in `PATH`
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

On a host whose `ess` in `PATH` is a newer release than `spec/ess-inputs.yaml` requires and
that holds the required release beside it, `task check:spec` runs every `ess` call with the
required release and exits 0, and on the forge, where the required release is the one in
`PATH`, it exits 0 as before; before the story the first host refuses the step with the
`--strict-requires` line above.

## Notes

- One pin: the version comes from one place (the requirement of `spec/ess-inputs.yaml` or the
  `ESS_VERSION` of the workflows), and a script test fails when the two disagree.
- `ESS_TOOLCHAIN` is read by the `ess` dispatcher of a release that has one. Whether 0.98.0 in
  `PATH` on the forge accepts the variable, ignores it or refuses it is checked before the
  variable goes into the task; the forge run of the pull request is the evidence.
- No path of a workstation goes into the repository.
- POSIX sh, no Python. The test step ends within 120 s, no test over 60 s.
