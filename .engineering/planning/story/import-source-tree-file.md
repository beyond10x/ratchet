---
format: aep.planning-md/3
id: story:import-source-tree-file
kind: story
status: draft
title: An imported run names a file of the tree as its source
summary: A source kind for a committed results file and for a run made by hand.
relations:
- decomposes: epic:format-gaps-first-format-consumer
scope:
- confidence: cited
  path: CHANGELOG.md
- confidence: cited
  path: crates/ratchet-cli-contract
- confidence: cited
  path: docs/design.md
- confidence: cited
  path: docs/evidence-format.md
- confidence: cited
  path: spec/domains/evidence.yaml
- confidence: cited
  path: spec/record-examples.test.sh
revision: 8
---
## Context

The repository `beyond10x/inference` wrote its quality definition against the formats at
commit `f139ecc` (2026-11-25): 3 `ratchet/1` files, 8 `ratchet-assessor/1` declarations and 15
`ratchet-evidence/1` records. It is the first consumer of the formats outside this repository.
Finding 4: the definition imports results that are a committed file of the tree and results
of a run made by hand. The consumer's proposal: `"source": {"kind": "tree_file", "location":
"<path of a results file in the tree>"}`.

What the formats say at the wave's base, `7b01ea1`:

- `ratchet.evidence.ImportSourceKind` is the closed list `forge_runs`, `build_pool_log`,
  `junit` (`spec/domains/evidence.yaml:450-453`), and `ImportSource.location` is "the forge
  run, the job log or the JUnit file read" (`:455-464`).
- `ratchet.cli.ImportInput.source` and `ImportResult.source` are of that type
  (`spec/domains/cli.yaml:806`, `:820`), so the list is part of the generated
  `crates/ratchet-cli-contract/` (`binding.json`).
- `docs/evidence-format.md` § 3 `evidence.source` (`:187-192`) names the three kinds;
  `docs/design.md` § 5 "Proposed CLI", the row `ratchet import` (`:749`), names forge runs,
  build pool logs and JUnit files.
- A record's `target.revision` is the revision the target was read at (`:85`), and nothing
  ties an imported file to a revision.

## Decision

Taken as the reversible answer (`AGENTS.md` § "Phase: implementation"): a fourth kind
`tree_file`. `location` is the path of the file relative to the root (`docs/evidence-format.md`
§ 1, no absolute path), and the record holds the revision the file was read at as
`target.revision`, which an invariant on `ratchet.evidence.Evidence` requires for
`source.kind: tree_file`. Results of a run made by hand are kept as such a file; there is no
kind of their own.

## Acceptance

Every outcome below is observable without a `ratchet` command.

1. `spec/domains/evidence.yaml`: `ImportSourceKind` has `tree_file`, the summary of
   `ImportSource.location` names a path relative to the root for it, and an invariant on
   `Evidence` refuses a record with `source.kind: tree_file` and no `target.revision`.
   Checked by `ess specify validate --path spec --strict-requires` (exit 0) and, because
   `spec/domains/cli.yaml` uses the type, by `task check:generated` after `task generate`
   rewrote `crates/ratchet-cli-contract/`.
2. `docs/evidence-format.md` § 6 has a seventh example: a record whose `source` is
   `{"kind": "tree_file", "location": "<a path of the tree>"}` and whose `target.revision` is
   the commit the file was read at. `want_examples` of `spec/record-examples.test.sh` goes
   from 6 to 7, and its last line counts the members of 7 examples, every one decoding. Before
   the story the value `tree_file` is refused there as no variant of
   `ratchet.evidence.ImportSourceKind`.
3. `docs/evidence-format.md` § 3 `evidence.source`: the row `kind` names `tree_file` and the
   row `location` the path relative to the root; the number of rows stays 2. Checked by
   `sh spec/record-fields.test.sh` and `sh spec/record-types.test.sh`, whose counts do not
   change.
4. `docs/design.md` § 5 "Proposed CLI", the row `ratchet import`, and § 6, the paragraph on an
   imported run, name a file of the tree and the revision it is read at. Text only, no case.
5. `CHANGELOG.md` has its line under `## [Unreleased]`. Text only, no case.

## Notes

- An addition to a released format: a record written before the change stays valid.
- No `-in-ratchet` part: the acceptance names no command behaviour beyond reading the
  declared form, which `story:cli-skeleton-validate` and `story:evidence-reader` build. How
  `ratchet import` reads a file of the tree belongs to the story that builds that command;
  none does yet.
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of
  `.engineering/waves/0.1.0-ahead-2.md`, into one wave built in sequence on one branch: every
  planned wave starts behind `story:cli-skeleton-validate`, which waits for a release of ESS
  (beyond10x/ess#836), and this part needs no `ratchet` command. It is 3 of the 33 in the
  order of that page. It adds the § 6 example after that of 2 (6 to 7), and 4 adds the next.
- It changes `spec/domains/evidence.yaml` under a type `spec/domains/cli.yaml` uses, so it
  runs `task generate` and `task check:generated`.
- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s.
