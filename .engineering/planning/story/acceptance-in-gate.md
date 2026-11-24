---
format: aep.planning-md/3
id: story:acceptance-in-gate
kind: story
status: active
title: The acceptance run joins the gate; getting-started page
summary: task check runs the seven steps at 7 of 7, a getting-started page checked against the run, the changelog lines of the slice.
relations:
- decomposes: epic:first-consumer-ui-loop
- depends_on: story:ui-loop-acceptance
- depends_on: story:assess-command
- depends_on: story:reference-adopt-command
- depends_on: story:evaluate-command
- depends_on: story:changelog-release-procedure
scope:
- confidence: cited
  path: .github/scripts/getting-started.test.sh
- confidence: cited
  path: CHANGELOG.md
- confidence: cited
  path: README.md
- confidence: cited
  path: ROADMAP.md
- confidence: cited
  path: Taskfile.yml
- confidence: cited
  path: docs/getting-started.md
- confidence: cited
  path: website/docusaurus.config.ts
- confidence: cited
  path: website/sidebars.ts
revision: 7
transitions:
- {from: "draft", to: "proposed", at: "2026-11-24T13:10:22Z", actor: "agent:ratchet", revision: 6, decided_on: {"recorded":{"review_outcome":3}}}
- {from: "proposed", to: "active", at: "2026-11-24T13:10:22Z", actor: "agent:ratchet", revision: 7, decided_on: {"recorded":{"review_outcome":3}}}
---
## Context

After `story:assess-command`, `story:reference-adopt-command` and `story:evaluate-command` the
acceptance run of `story:ui-loop-acceptance` should pass 7 of 7. From then on a change that
breaks the consumer's loop must fail the gate, and a project needs a page that shows the loop.

## Acceptance

`slot task check` exits 0 and its output holds the line `acceptance ui-loop: 7 of 7 steps pass`
and the line `getting-started: <n> of <n> command blocks match` printed by
`.github/scripts/getting-started.test.sh`, which compares every command and output block of
`docs/getting-started.md` with `target/acceptance/ui-loop/transcript.txt`, the transcript `task
acceptance:ui-loop` writes since `story:ui-loop-acceptance`.

## Scope

- `Taskfile.yml`: `check` calls `acceptance:ui-loop`
- `.github/scripts/getting-started.test.sh`: POSIX sh, run by `check:scripts` after the
  acceptance run
- `docs/getting-started.md`, `website/docusaurus.config.ts`, `website/sidebars.ts`: the page and
  its route (`AGENTS.md`, ownership table, row `website/`)
- `README.md`: § "Status" says what 0.1.0 does and what it does not do yet
- `ROADMAP.md`: wave closed, next waves
- `CHANGELOG.md`: every line of the slice under `## [Unreleased]`, one per story of
  `epic:runnable-cli`, `epic:observe-adopt-reject` and `epic:first-consumer-ui-loop`

## Notes

- A step that still fails here is a defect in the story that owns the command; it is fixed there
  first, with a test that failed before.
- The page states only what the acceptance run shows. It names what is not built (design § 5
  "Proposed CLI", the commands that return the unavailable answer).
- Budget: the gate's test step, with the acceptance run in it, ends within 120 s.
- No Python.
- `story:release-0-1-0` follows this story.
