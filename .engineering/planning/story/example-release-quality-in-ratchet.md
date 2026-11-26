---
format: aep.planning-md/3
id: story:example-release-quality-in-ratchet
kind: story
status: draft
title: ratchet validate accepts the example plan for the quality of a release
summary: 'The command part of story:example-release-quality: ratchet validate on examples/release-quality.ratchet.yaml exits 0.'
relations:
- decomposes: epic:runnable-cli
- depends_on: story:example-release-quality
- depends_on: story:cli-skeleton-validate
scope:
- confidence: inferred
  path: crates/ratchet/tests
revision: 3
---
## Context

Split on 2026-11-26 from `story:example-release-quality`, which adds
`examples/release-quality.ratchet.yaml` (a release as its subject, exact counts with
`better: lower` against accepted references, and a gate `release` with only report-mode
entries) and the declaration of its assessor, checked by
`sh spec/example-declarations.test.sh`. This story holds the part that needs the `ratchet`
command.

## Acceptance

`ratchet validate examples/release-quality.ratchet.yaml` exits 0, with a local config that
names the file and the catalog sources of `examples/ratchet.toml`; before the
story the command answers `cli_handler_unavailable`.

## Notes

- Moved from the acceptance of `story:example-release-quality`, with its dependency on
  `story:cli-skeleton-validate`.
- A key of the example that `ratchet validate` refuses is a defect of the example or of the
  command, fixed in this story.
- The story is a draft. It waits for the waves to 0.1.0: `story:cli-skeleton-validate`.
