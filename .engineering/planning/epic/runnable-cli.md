---
format: aep.planning-md/3
id: epic:runnable-cli
kind: epic
status: draft
title: A ratchet command a project can run
summary: Rust workspace, generated command surface and model, drift check, ratchet validate.
relations:
- decomposes: initiative:first-milestone
revision: 2
---
## Context

The repository holds a design, an ESS specification of 7 domains and an `ess-cli/2` binding of 16
commands, and no code. `AGENTS.md` § "Specification first (ESS)" says how code arrives: the
`ratchet` command from `ess generate cli`, other boilerplate from `ess generate synthesize`,
generated files checked for drift in the gate.

## Outcome

A project can install the `ratchet` binary and run `ratchet validate` on its `ratchet/1`
documents. Every other declared command exits non-zero with the generated adapter's
"unavailable" answer until its story builds it. The repository has a Rust workspace, a pinned
toolchain, a test step inside the budget of the workspace `AGENTS.md` (no test over 60 s, the
step within 120 s), a drift check for every generated file, and a CI job that runs the same gate.

The specification changes first and alone (`story:record-formats-in-spec`), because every
generated file carries a digest of the whole specification; the workspace is generated from it
once (`story:cli-skeleton-validate`).

## Done when

`story:record-formats-in-spec` and `story:cli-skeleton-validate` are implemented.

## Not in this epic

Reading evidence, references and gates (`epic:observe-adopt-reject`). The validation codes that
join a plan with an assessor's declaration (`story:assessor-declaration`).
