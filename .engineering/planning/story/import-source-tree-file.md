---
format: aep.planning-md/3
id: story:import-source-tree-file
kind: story
status: active
title: An imported run names a file of the tree as its source
summary: A source kind for a committed results file and for a run made by hand.
relations:
- decomposes: epic:format-gaps-first-format-consumer
scope:
- confidence: cited
  path: crates/ratchet-cli-contract
- confidence: cited
  path: docs/design.md
- confidence: cited
  path: docs/evidence-format.md
- confidence: cited
  path: spec/README.md
- confidence: cited
  path: spec/domains/evidence.yaml
- confidence: cited
  path: spec/record-examples.test.sh
revision: 14
transitions:
- {from: "draft", to: "proposed", at: "2026-11-26T21:04:20Z", actor: "human:operator", revision: 13, decided_on: {"recorded":{"review_outcome":4}}}
- {from: "proposed", to: "active", at: "2026-11-26T21:04:21Z", actor: "human:operator", revision: 14, decided_on: {"recorded":{"review_outcome":4}}}
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
- A record's `target.revision` is the revision the target was read at
  (`docs/evidence-format.md` § 3 `evidence.target`, the row `revision`, `:86`), and nothing
  ties an imported file to a revision.

## Decision

Taken as the reversible answer (`AGENTS.md` § "Phase: implementation"): a fourth kind
`tree_file`. `location` is the path of the file relative to the root (`docs/evidence-format.md`
§ 1, no absolute path), and the record holds the revision the file was read at as
`target.revision`, which an invariant on `ratchet.evidence.Evidence` requires for
`source.kind: tree_file`. Results of a run made by hand are kept as such a file; there is no
kind of their own.

## Acceptance

Every outcome below is observable without a `ratchet` command. No item cites a line number.

A phrase with a space in it may wrap in a Markdown paragraph or a folded YAML summary. So where
an item says that `grep -F` finds such a phrase in a `.md` or `.yaml` file, that it finds
nothing or the phrase is gone, or that `grep -c` of it prints a count, the check reads the
joined text of the file: `tr -s '\n ' '  ' < <file> | grep -o -F '<phrase>' | wc -l` prints 1
where the item says it is found, 0 where it says nothing or gone, and the count where it names
one. A name without a space, a row of a table, a pattern with `^`, `$` or `-E`, a check that
prints the line it matches and a check that reads the output of another command read the file
line by line, as written.

1. `spec/domains/evidence.yaml`, `ratchet.evidence.ImportSourceKind`: the variant
   `tree_file`. The `§ 6` example of item 4 decodes only with it, and `grep -c 'tree_file'
   spec/domains/evidence.yaml` prints at least 1 (0 before).
2. `spec/domains/evidence.yaml`, the invariants of `ratchet.evidence.Evidence`: one refuses a
   record with `source.kind` `tree_file` and no `target.revision`. The block of
   `ratchet.evidence.Evidence` under `invariants:` holds a line with both `tree_file` and
   `target.revision` (`grep -A120 'name: ratchet.evidence.Evidence$'
   spec/domains/evidence.yaml | grep 'tree_file' | grep -c 'target.revision'` prints 1; 0
   before), and `ess specify validate --path spec --strict-requires` exits 0.
3. `spec/domains/evidence.yaml`, the summary of `ImportSource.location`, says "a path relative
   to the root" for `tree_file` (`grep -F` finds the phrase in the file; nothing before).
4. `docs/evidence-format.md` § 6 has a seventh example: a record whose `source` is
   `{"kind": "tree_file", "location": "<a path of the tree>"}` and whose `target.revision` is
   the commit the file was read at. The assignment `want_examples` of
   `spec/record-examples.test.sh` goes from 6 to 7, and the script ends with
   `record-examples: <n> of <n> members of 7 example(s) decode under the specification`.
   Before the story the value `tree_file` is refused there as no value of
   `ratchet.evidence.ImportSourceKind`.
5. `spec/README.md`, the paragraph that begins "Each script states how much it reads": it
   says "7 examples in § 6 (`record-examples`)": `tr -s '\n ' '  ' < spec/README.md | grep
   -c -F '7 examples in § 6'` prints 1 (0 before), and the same check of '6 examples in § 6'
   prints 0 (1 before, after story 2).
6. `task generate` rewrote `crates/ratchet-cli-contract/` (`spec/domains/cli.yaml` uses
   `ImportSourceKind` in `ImportInput` and `ImportResult`), and `task check:generated` exits
   0; before the rewrite it fails on the new variant.
7. `docs/evidence-format.md` § 3 `evidence.source`: the row `kind` names `tree_file`
   (`grep -F '`tree_file`' docs/evidence-format.md` finds the row; nothing before), and the
   table keeps its 2 rows: `sh spec/record-fields.test.sh` still ends with
   `record-fields: 99 of 99 field rows declared`.
8. `docs/design.md` § 5 "Proposed CLI", the row `ratchet import`, names "a file of the tree"
   (`grep -F '| `ratchet import` |' docs/design.md | grep -c 'a file of the tree'` prints
   1; the row names forge runs, build pool logs and JUnit files alone before).
9. `docs/design.md` § 6, the paragraph that begins "An imported run is an assessment run
   record", says "A file of the tree is imported with the revision it was read at"
   (`grep -F` finds the phrase; nothing before).

## Notes

- An addition to a released format: a record written before the change stays valid.
- No `-in-ratchet` part: the acceptance names no command behaviour beyond reading the
  declared form, which `story:cli-skeleton-validate` and `story:evidence-reader` build. How
  `ratchet import` reads a file of the tree belongs to the story that builds that command;
  none does yet.
- Its line of `CHANGELOG.md` is written by the closing commit of the wave (`AGENTS.md`
  § "Changelog lines"; the wave record names the heading and the phrase of the line).
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of
  `.engineering/waves/0.1.0-ahead-2.md`, into one wave built in sequence on one branch: every
  planned wave starts behind `story:cli-skeleton-validate`, which waits for a release of ESS
  (beyond10x/ess#836), and this part needs no `ratchet` command. It is 3 of the 33 in the
  order of that page. It adds the § 6 example after that of 2 (6 to 7), and 4 adds the next.
- It changes `spec/domains/evidence.yaml` under a type `spec/domains/cli.yaml` uses, so it
  runs `task generate` and `task check:generated`.
- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s.
