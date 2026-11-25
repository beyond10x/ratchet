---
format: aep.planning-md/3
id: story:records-tracked-baseline-directory
kind: story
status: draft
title: The local config names a tracked directory of baseline records
summary: A read-only source of records in the tree beside the directory a machine writes.
relations:
- decomposes: epic:format-gaps-first-format-consumer
revision: 1
---
## Context

The repository `beyond10x/inference` wrote its quality definition against the formats at
commit `f139ecc` (2026-11-25): 3 `ratchet/1` files, 8 `ratchet-assessor/1` declarations and 15
`ratchet-evidence/1` records. It is the first consumer of the formats outside this repository
and of this story. Line numbers below are those of `f139ecc`.

Finding 12. The consumer keeps its baseline evidence as tracked files of the tree, so a clone
holds them. `[records] store` is a git ref or the directory this machine writes
(`spec/domains/config.yaml:17-24`, `:64-74`; `docs/evidence-format.md:13`), and no key names a
tracked directory that is read and never written by a run. The consumer's `ratchet.toml` has
no `[records]` section, and the place of its baseline is known to a reader only by convention.

## Acceptance

The local config names a tracked directory of records beside the local record directory,
`ratchet validate` reads the records there, and `ratchet assess` writes none there; before the
story the key is refused.

## Notes

- The form shown is the consumer's proposal. The story decides the form, declares it in
  `spec/` first (`ess specify validate` passes), and writes it into `docs/design.md` or
  `docs/evidence-format.md` in the same change.
- A new value or field of a released format is an addition: a file written for the format
  before the change stays valid.
- The story is a draft. It was there before the planned waves to 0.1.0 and waits for them.
