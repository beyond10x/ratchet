---
format: aep.planning-md/3
id: epic:format-gaps-second-format-consumer
kind: epic
status: draft
title: The formats say what the second format consumer's quality definition needs
summary: 3 findings from the draft quality definition of beyond10x/swell against the formats, each with no story before.
relations:
- decomposes: initiative:first-milestone
revision: 1
---
## Context

The repository `beyond10x/swell`, a script engine, drafted its quality definition against the
formats at commit `90924c9` (2026-11-25), before any `ratchet` command is built: one `ratchet/1`
file that binds `conformance-cases@1` and `known-failures@1` and adds plans of its own. It also
compares itself with other engines on a public page. It is the second repository that writes a
definition against the formats.

The draft found three things with no story: a value of another implementation shown beside the
candidate's, an imported report of another revision, and numbers in documents written from
records. What the draft found that a story already holds is not repeated here
(`story:requirement-over-two-measurements`, `story:reference-from-another-plan`,
`story:item-field-values`, `story:import-source-tree-file`, `story:coverage-count-with-reference`,
`story:coverage-count-lower-bound`, `story:plan-with-exact-and-sampled-measurements`,
`story:list-item-statement`, `story:machine-as-a-condition`, `story:example-assessor-declarations`).

## Outcome

Each of the three places has an answer in `spec/` and in the design documents, with a test that
failed before, and the quality definition of `beyond10x/swell` can say in the formats what it
now leaves out or keeps in a table typed by hand.

## Stories

- `story:peer-values-beside-candidate`
- `story:imported-report-revision-check`
- `story:render-numbers-into-documents`

## Acceptance

The three stories are implemented or rejected with a written reason, and the consumer has been
told which.

## Notes

- The stories are drafts. They were there before the planned waves to 0.1.0 and wait for them.
- Whether Ratchet records values of other implementations at all is a question of its
  boundary (`AGENTS.md` § "Boundary"); `story:peer-values-beside-candidate` puts it and does
  not answer it.
