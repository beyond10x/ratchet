---
format: aep.planning-md/3
id: story:gate-entry-unless-only-paths-in-ratchet
kind: story
status: draft
title: ratchet evaluate skips a gate entry when every changed path is in its not_only list
summary: 'The command part of story:gate-entry-unless-only-paths: the match, the not-applicable reason, and the refusal of both forms.'
relations:
- decomposes: epic:format-gaps-first-format-consumer
- depends_on: story:gate-entry-unless-only-paths
- depends_on: story:cli-skeleton-validate
- depends_on: story:evaluate-command
scope:
- confidence: inferred
  path: crates/ratchet-core
revision: 2
---
## Context

Split on 2026-11-26 from `story:gate-entry-unless-only-paths`, which declares
`when: {not_only: [paths]}` on a gate entry in `spec/domains/specification.yaml` and writes it
into `docs/design.md` § 5. This story holds the part that needs the `ratchet` command.

## Acceptance

In a fixture with a gate entry `when: {not_only: [".engineering/**", "**/*.md"]}`,
`ratchet evaluate --gate <name>` evaluates the entry for a change that touches one path outside
the list, and lists it as not applicable with the reason for a change whose paths are all in
the list; `ratchet validate` refuses a `when` that holds both `changed` and `not_only` with a
code that names the entry. Before the story no command reads the form.

## Notes

- Moved from the acceptance of `story:gate-entry-unless-only-paths`.
- The story is a draft. It waits for the waves to 0.1.0: `story:cli-skeleton-validate`,
  `story:evaluate-command`.
