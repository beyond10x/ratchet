---
format: aep.planning-md/3
id: story:acceptance-in-gate
kind: story
status: draft
title: The acceptance run joins the gate; getting-started page
summary: task check runs the seven steps at 7 of 7, and the documentation shows them.
relations:
- decomposes: epic:first-consumer-ui-loop
- depends_on: story:ui-loop-acceptance
- depends_on: story:assess-command
- depends_on: story:reference-adopt-command
- depends_on: story:evaluate-command
- depends_on: story:changelog-release-procedure
scope:
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
revision: 2
---
## Context

After `story:assess-command`, `story:reference-adopt-command` and `story:evaluate-command` the
acceptance run of `story:ui-loop-acceptance` should pass 7 of 7. From then on a change that
breaks the consumer's loop must fail the gate, and a project needs a page that shows the loop.

## Acceptance

`slot task check` runs `task acceptance:ui-loop` and exits 0 with the line `acceptance ui-loop: 7 of 7
steps pass`, and the documentation site has a page "Getting started" whose commands are the seven
steps and whose command output blocks are compared with the acceptance run's output by a check in
the gate.

## Scope

- `Taskfile.yml`: `check` calls `acceptance:ui-loop`
- `docs/getting-started.md`, `website/docusaurus.config.ts`, `website/sidebars.ts`: the page and
  its route (`AGENTS.md`, ownership table, row `website/`)
- `README.md`: § "Status" says what 0.1.0 does and what it does not do yet
- `ROADMAP.md`: wave closed, next waves
- `CHANGELOG.md`: the entries of the slice under `## [Unreleased]`, if a story left one out

## Notes

- A step that still fails here is a defect in the story that owns the command; it is fixed there
  first, with a test that failed before.
- The page states only what the acceptance run shows. It names what is not built (design § 5
  "Proposed CLI", the commands that answer with a refusal).
- Budget: the gate's test step, with the acceptance run in it, ends within 120 s.
- After this story merges green on `main`, 0.1.0 is cut by the release procedure of
  `story:changelog-release-procedure`.
