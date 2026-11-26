---
format: aep.planning-md/3
id: story:records-tracked-baseline-directory
kind: story
status: active
title: The local config names a tracked directory of baseline records
summary: A read-only source of records in the tree beside the directory a machine writes.
relations:
- decomposes: epic:format-gaps-first-format-consumer
scope:
- confidence: cited
  path: docs/design.md
- confidence: cited
  path: examples/README.md
- confidence: cited
  path: examples/ratchet.toml
- confidence: cited
  path: spec/domains/config.yaml
revision: 12
transitions:
- {from: "draft", to: "proposed", at: "2026-11-26T21:04:24Z", actor: "human:operator", revision: 11, decided_on: {"recorded":{"review_outcome":4}}}
- {from: "proposed", to: "active", at: "2026-11-26T21:04:24Z", actor: "human:operator", revision: 12, decided_on: {"recorded":{"review_outcome":4}}}
---
## Context

The repository `beyond10x/inference` wrote its quality definition against the formats at
commit `f139ecc` (2026-11-25). It is the first consumer of the formats outside this repository
and of this story.

Finding 12. The consumer keeps its baseline evidence as tracked files of the tree, so a clone
holds them. `[records] store` is the git ref of the series or the path of the local record
directory, the one this machine writes (`ratchet.config.RecordStoreLocation`,
`spec/domains/config.yaml:17-24` at 7b01ea1; `ratchet.config.RecordsSection`, `:76-85`). No key
names a tracked directory that is read and never written by a run. `docs/design.md` § 5 "Local
config" shows `[records] store` alone (`:684-700`, the `ratchet.toml` block), and § 6, the
paragraph "The record store" (`:780`), names the hand-over, the ref and the local record
directory. The consumer's `ratchet.toml` has no `[records]` section, and the place of its
baseline is known to a reader only by convention. `examples/ratchet.toml` has `[records] store`
(`:10-11`).

## Decision

The reversible answer, taken here (AGENTS.md § "Phase: implementation"): an optional member
`tracked` of `RecordsSection`, a list of directories relative to the root that hold
`ratchet-evidence/1` files committed to the tree. A command reads records there beside the
local record directory and the ref, and writes none there. A record read from a tracked
directory is no reference: references stay `ratchet/references/<requirement>.json` (§ 5,
"Reference records"); a tracked record is evidence an adoption can read.

## Acceptance

Every outcome below is observable without a `ratchet` command.

A phrase with a space in it may wrap in a Markdown paragraph or a folded YAML summary. So where
an item says that `grep -F` finds such a phrase in a `.md` or `.yaml` file, that it finds
nothing or the phrase is gone, or that `grep -c` of it prints a count, the check reads the
joined text of the file: `tr -s '\n ' '  ' < <file> | grep -o -F '<phrase>' | wc -l` prints 1
where the item says it is found, 0 where it says nothing or gone, and the count where it names
one. A name without a space, a row of a table, a pattern with `^`, `$` or `-E`, a check that
prints the line it matches and a check that reads the output of another command read the file
line by line, as written.

1. `spec/domains/config.yaml`, `ratchet.config.RecordsSection` has the optional member
   `tracked`, a list of paths relative to the root: `grep -c 'name: tracked'
   spec/domains/config.yaml` prints 1 (0 before), and
   `ess specify validate --path spec --strict-requires` and `task check:generated` exit 0.
2. The summary of `tracked` says that a command reads records there and writes none:
   `grep -F 'reads records there and writes none' spec/domains/config.yaml` finds it (nothing
   before).
3. The summary of `ratchet.config.RecordStore` names a tracked directory as a third, read-only
   source: `grep -F 'a tracked directory, read and never written' spec/domains/config.yaml`
   finds it (nothing before).
4. `docs/design.md` § 5 "Local config", the `ratchet.toml` block shows `tracked` under
   `[records]`: `grep -F 'tracked = ["quality/baseline"]' docs/design.md` finds it (nothing
   before).
5. `docs/design.md` § 5 "Local config", the paragraph after the block says what a tracked
   directory holds and that no run writes there: `grep -F 'A tracked directory holds
   `ratchet-evidence/1` files committed to the tree' docs/design.md` finds it (nothing before).
6. `docs/design.md` § 6, the paragraph "The record store", names the tracked directory beside
   the local record directory: `grep -F 'and the tracked directories of `[records] tracked`'
   docs/design.md` finds it (nothing before).
7. `examples/ratchet.toml` has `tracked` under `[records]`:
   `grep -c '^tracked = ' examples/ratchet.toml` prints 1 (0 before). No script of the gate
   reads the keys of `ratchet.toml`.
8. `examples/README.md` § "`ratchet.toml`" gives the source of `tracked`:
   `grep -F '`tracked` names the directory of the baseline records' examples/README.md` finds
   it (nothing before).

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
