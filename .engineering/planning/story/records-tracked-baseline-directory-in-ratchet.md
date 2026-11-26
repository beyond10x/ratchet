---
format: aep.planning-md/3
id: story:records-tracked-baseline-directory-in-ratchet
kind: story
status: draft
title: The commands read a tracked directory of records and write none there
summary: 'The command part of story:records-tracked-baseline-directory: validate and evaluate read it, assess never writes it.'
relations:
- decomposes: epic:format-gaps-first-format-consumer
- depends_on: story:records-tracked-baseline-directory
- depends_on: story:cli-skeleton-validate
- depends_on: story:evidence-reader
- depends_on: story:assess-command
scope:
- confidence: inferred
  path: crates/ratchet-core
revision: 2
---
## Context

Split on 2026-11-26 from `story:records-tracked-baseline-directory`, which declares
`[records] tracked` in `spec/domains/config.yaml` and writes into `docs/design.md` § 5 and § 6
that a tracked directory of the tree holds records a command reads and no run writes. This
story holds the part that needs the `ratchet` command.

## Acceptance

In a fixture whose `ratchet.toml` names a tracked directory holding one record,
`ratchet validate` and `ratchet evaluate` read that record beside the local record directory,
and `ratchet assess` writes its record to the local record directory and none to the tracked
one; a `tracked` path outside the root is refused with a code that names the key. Before the
story the key is not read.

## Notes

- Moved from the acceptance of `story:records-tracked-baseline-directory`.
- The story is a draft. It waits for the waves to 0.1.0: `story:cli-skeleton-validate`,
  `story:evidence-reader`, `story:assess-command`.
