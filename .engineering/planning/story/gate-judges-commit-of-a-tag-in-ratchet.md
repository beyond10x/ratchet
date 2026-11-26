---
format: aep.planning-md/3
id: story:gate-judges-commit-of-a-tag-in-ratchet
kind: story
status: draft
title: ratchet evaluate refuses a candidate that is not the commit of the tag a gate judges
summary: 'The command part of story:gate-judges-commit-of-a-tag: the check of the candidate against judges.tag.'
relations:
- decomposes: epic:format-gaps-first-format-consumer
- depends_on: story:gate-judges-commit-of-a-tag
- depends_on: story:cli-skeleton-validate
- depends_on: story:evaluate-command
scope:
- confidence: inferred
  path: crates/ratchet-core
- confidence: inferred
  path: spec/domains/cli.yaml
revision: 3
---
## Context

Split on 2026-11-26 from `story:gate-judges-commit-of-a-tag`, which declares
`judges: {tag: <pattern>}` on a gate in `spec/domains/specification.yaml` and writes it into
`docs/design.md` § 5 "Gate kinds". This story holds the part that needs the `ratchet` command.

## Acceptance

In a fixture repository with a tag `1.0.0` on one commit and a gate `release` with
`judges: {tag: "*.*.*"}`, `ratchet evaluate --gate release --candidate <that commit>` judges
the gate, and with a commit that no matching tag points at it refuses the candidate with a cause
that names the gate and the pattern; before the story the key is not read and a gate named
`release` judges any revision.

## Notes

- Moved from the acceptance of `story:gate-judges-commit-of-a-tag`.
- The tag is read with git from the repository; Ratchet reads no forge API.
- The story is a draft. It waits for the waves to 0.1.0: `story:cli-skeleton-validate`,
  `story:evaluate-command`.
