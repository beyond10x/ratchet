---
format: aep.planning-md/3
id: story:mimalloc-measure
kind: story
status: draft
title: The musl binary keeps mimalloc only if it is not slower
relations:
- decomposes: epic:release-line
- depends_on: story:musl-static-release
- depends_on: story:cli-skeleton-validate
revision: 1
---
## Context

The owner approved on 2026-11-25 that the Beyond10x Rust tools use mimalloc where they are
allocation-heavy, kept only if it is not slower. The static musl archive of
`story:musl-static-release` uses the allocator of musl. ratchet builds no command yet, so there
is nothing to measure.

## Acceptance

1. When the first command of 0.1.0 that reads files builds (`story:cli-skeleton-validate`), the
   wall time and peak resident memory of `ratchet validate` on `examples/` are measured on the
   musl binary with the musl allocator and with mimalloc, alternating, at least 5 rounds each,
   on the build node; the medians are reported.
2. mimalloc is kept for the musl target only when its median wall time is not above the musl
   allocator's; otherwise the story records the medians and is closed without the change.
3. Whatever is decided, `AGENTS.md` § Release names the allocator of the musl binary.

## Notes

- Waits for the waves to 0.1.0 (`story:cli-skeleton-validate`).
