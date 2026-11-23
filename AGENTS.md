# AGENTS.md — ratchet

Ratchet specifies how to specify software quality: a versioned YAML format (`ratchet/1`), a CLI, a
preset catalog and assessors, aimed at regression prevention. Vision: `vision.md`. Design:
`docs/design.md`.

Organization-wide rules live in the workspace `AGENTS.md` (`~/beyond10x/AGENTS.md`); this file adds
what is specific to ratchet.

## Phase: design

The repository is in the design phase.

- No planning ahead: no epics, stories or tasks in the store until Timo opens implementation
  planning. Timo, 2026-11-23: "do not do any planning ahead … we're just in the design phase".
- No implementation code yet. Changes go to `docs/design.md`, `vision.md`, `research/` and this
  file.
- Survey answers arrive through the operator session of `~/.claude/CLAUDE.md` § Host operator.
  An answer about work outside beyond10x names nothing of that work (`research/README.md`
  § Confidentiality); check every answer against that list before committing it.
- Field names, document shapes and CLI commands in `docs/design.md` are proposals. Do not cite
  them as settled.

## Ownership

| path | what |
|---|---|
| `vision.md` | why Ratchet exists, its outcomes and what it does not do |
| `docs/design.md` | the design proposal: domain language, YAML shapes, CLI, records, ESS integration |
| `research/` | surveys and their answers; confidentiality rules in `research/README.md` |
| `.engineering/` | AEP planning store (`aep.project/5`, profile `development.standard`), no artifacts yet |
| `Taskfile.yml` | `task check`: the repository gate |

## Domain language

Use the terms of `docs/design.md` § 1 with those meanings: subject, audience, quality
specification, quality requirement, measurement, assessment plan, assessor, target, protected
reference, gate, ratchet policy. A gate verdict is one of pass, fail, insufficient evidence.

## Boundary

- Ratchet runs or imports existing tools (analyzers, browsers, load runners, CI, telemetry); it
  does not reimplement them.
- ESS owns conformance scenarios and ESS UI interactions; Ratchet imports their reports
  (`docs/design.md` § 7).
- AEP owns the planning store; Ratchet records quality evidence, not plan state.

## Gate

`task check` runs `aep plan artifact validate`. Edit the store only through `aep plan artifact`.

## Commits

Every commit and push is `b10x-bot[bot]`'s through `b10x-gates bot -- <git command>`; every other
GitHub write goes through `b10x-gates api`, with `--policy ../gates-policy/policy.json` from the
primary checkout. Every commit has a body.

## Never

- Write Python for anything committed (workspace `AGENTS.md` § No Python for permanent tools).
- Hand-edit a `status`, `revision` or `transitions` field under `.engineering/planning/`.
