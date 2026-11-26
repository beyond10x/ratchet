---
format: aep.planning-md/3
id: story:records-tracked-baseline-directory
kind: story
status: draft
title: The local config names a tracked directory of baseline records
summary: A read-only source of records in the tree beside the directory a machine writes.
relations:
- decomposes: epic:format-gaps-first-format-consumer
scope:
- confidence: cited
  path: CHANGELOG.md
- confidence: cited
  path: docs/design.md
- confidence: cited
  path: examples/README.md
- confidence: cited
  path: examples/ratchet.toml
- confidence: cited
  path: spec/domains/config.yaml
revision: 7
---
## Context

The repository `beyond10x/inference` wrote its quality definition against the formats at
commit `f139ecc` (2026-11-25). It is the first consumer of the formats outside this repository
and of this story.

Finding 12. The consumer keeps its baseline evidence as tracked files of the tree, so a clone
holds them. `[records] store` is the git ref of the series or the path of the local record
directory, the one this machine writes (`ratchet.config.RecordStoreLocation`,
`spec/domains/config.yaml:17-24`; `ratchet.config.RecordsSection`, `:76-85`). No key names a
tracked directory that is read and never written by a run. `docs/design.md` § 5 "Local config"
shows `[records] store` alone (`:684-700`, the `ratchet.toml` block), and § 6 "The record store"
names the hand-over, the ref and the local record directory (`docs/design.md` § 6). The
consumer's `ratchet.toml` has no `[records]` section, and the place of its baseline is known to
a reader only by convention. `examples/ratchet.toml` has `[records] store` (`:10-11`).

## Decision

The reversible answer, taken here (AGENTS.md § "Phase: implementation"): an optional member
`tracked` of `RecordsSection`, a list of directories relative to the root that hold
`ratchet-evidence/1` files committed to the tree. A command reads records there beside the
local record directory and the ref, and writes none there. A record read from a tracked
directory is no reference: references stay `ratchet/references/<requirement>.json` (§ 5,
"Reference records"); a tracked record is evidence an adoption can read.

## Acceptance

Every outcome below is observable without a `ratchet` command.

1. `spec/domains/config.yaml`: `RecordsSection` (`:76`) has the optional `tracked`, a list of
   paths relative to the root, whose summary says that a command reads records there and writes
   none; the summary of `ratchet.config.RecordStore` (`:169`) names it as a third, read-only
   source. Checked by `ess specify validate --path spec --strict-requires`, which exits 0, and
   by `task check:generated`.
2. `docs/design.md` § 5 "Local config": the `ratchet.toml` block shows `tracked` under
   `[records]`, and the paragraph after it says what a tracked directory holds and that no run
   writes there; § 6 "The record store" names it beside the local record directory. Text only,
   no case.
3. `examples/ratchet.toml` has `tracked` under `[records]`, and `examples/README.md`
   § "`ratchet.toml`" gives its source. Text only, no case: no script of the gate reads the
   keys of `ratchet.toml`.
4. `CHANGELOG.md` has its line under `## [Unreleased]`. Text only, no case.

## Notes

- An addition to a released format: a config without `tracked` stays valid.
- `ratchet validate` and `ratchet evaluate` reading the records of a tracked directory, and
  `ratchet assess` writing none there, are `story:records-tracked-baseline-directory-in-ratchet`,
  which waits for the waves to 0.1.0 (`story:evidence-reader`, `story:assess-command`).
- `docs/design.md` § 5 "Local config" is changed by no other story of the wave;
  § 5 "Protected references" just above it is changed by stories 26 and 27.
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of `.engineering/waves/0.1.0-ahead-2.md`,
  into one wave built in sequence on one branch: every planned wave starts behind
  `story:cli-skeleton-validate`, which waits for a release of ESS (beyond10x/ess#836), and this
  part needs no `ratchet` command. It is 28 of the 33 in the order of that page.
- Related: `story:record-series-git-ref` (the series on the ref), which stays out of this wave.
