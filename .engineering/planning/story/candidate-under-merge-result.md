---
format: aep.planning-md/3
id: story:candidate-under-merge-result
kind: story
status: implemented
title: Under merge_result a record names the candidate and the merged tree apart
summary: candidate is the revision under judgement, target.revision the merge commit that was read.
relations:
- decomposes: epic:format-gaps-first-format-consumer
revision: 7
transitions:
- {from: "draft", to: "proposed", at: "2026-11-26T05:20:02Z", actor: "human:operator", revision: 5}
- {from: "proposed", to: "active", at: "2026-11-26T05:20:02Z", actor: "human:operator", revision: 6}
- {from: "active", to: "implemented", at: "2026-11-26T07:54:30Z", actor: "human:operator", revision: 7, decided_on: {"recorded":{"test_result":1}}}
---
## Context

The repository `beyond10x/inference` wrote its quality definition against the formats at
commit `f139ecc` (2026-11-25). It is the first consumer of the formats outside this repository
and of this story. The finding comes from the correction round of that definition.

Finding 17. A record of a pull-request run: the run checked out the merge of the head into the
default branch. `selection: merge_result` is "the candidate merged into the trusted revision"
(`docs/design.md:76`; `spec/domains/specification.yaml:225-229`), and `evidence.candidate` is
"the candidate identity the evidence is attributable to" (`spec/domains/evidence.yaml:481-486`).
No sentence says which of the two commits is `candidate` and which is `target.revision` under
`merge_result`. The consumer wrote `candidate` as the head of the pull request and
`target.revision` as the merge commit in three records. That is this repository's reading too;
it is not written down, and a reader that keys a series by `candidate` and one that keys it by
`target.revision` build two different series from the same records.

The three examples of `docs/evidence-format.md` § 6 have the selection `candidate` (`:400`);
none shows `merge_result`.

## Acceptance

Every outcome below is observable without a `ratchet` command.

1. `spec/domains/specification.yaml`, `ratchet.specification.Selection` (`:225-229`), and
   `spec/domains/evidence.yaml`, `Evidence.candidate` (`:481-486`) and
   `ResolvedTarget.selection` (`:103`), state for `selection: merge_result` that `candidate`
   is the revision under judgement and `target.revision` the merged tree that was read.
   Checked by `ess specify validate --path spec --strict-requires`, which exits 0, and by
   `task check:generated`; the sentences are text, no case.
2. `docs/evidence-format.md` § 3, the rows `candidate` (`:62`) and `selection` (`:77`), and
   `docs/design.md` § 3 (`:76`) say the same. Text only, no case: no row is added, and
   `spec/record-fields.test.sh` and `spec/record-types.test.sh` keep their count of 78 rows in
   § 3.
3. `docs/evidence-format.md` § 6: a new JSON example, a record of a run under
   `selection: merge_result` whose `candidate` and `target.revision` are two different commit
   ids, after the example that `story:workflow-run-target-identifiers` adds. Checked by
   `spec/record-examples.test.sh`: before the story it expects 4 examples (`want_examples`,
   `:46`, 3 today and 4 after `story:workflow-run-target-identifiers`) and none has
   `merge_result`; after the story it expects 5, the new example decodes, and the last line
   counts 5 examples. `spec/README.md:122` and the header of the script
   (`spec/record-examples.test.sh:27`, "§ 6 holds 3 examples", 4 after
   `story:workflow-run-target-identifiers`) say 5 examples in § 6.
   The script does not see the selection or the two ids, so they are observed with `jq` over
   the files the script writes, after `sh spec/record-examples.test.sh`:
   `jq -s '[.[] | objects | select(.evidence.target.selection == "merge_result" and .evidence.candidate != .evidence.target.revision)] | length' target/record-examples/example-*.json`
   prints 0 before the story and 1 after.
4. `CHANGELOG.md` has its line under `## [Unreleased]`. Text only, no case.

## Notes

- The form shown is the consumer's proposal or what it wrote in place of the missing form.
  The story decides the form, declares it in `spec/` first (`ess specify validate` passes), and
  writes it into `docs/design.md` and `docs/evidence-format.md` in the same change. It runs
  `task check:generated` when it edits `spec/domains/`.
- A new value or field of a released format is an addition: a file written for the format
  before the change stays valid.
- The invocation of § 10 passes one `--revision`, which the assessor writes as both
  `evidence.candidate` and `evidence.target.revision` (`docs/evidence-format.md:620`), and § 9
  says that the contract does not cover a `merge_result` selection (`:602`). The story does
  not change the invocation.
- The refusal of a record with the two swapped is `story:candidate-under-merge-result-in-ratchet`,
  which waits for the waves to 0.1.0.
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them, with eight other drafts, into one wave built in sequence on one
  branch: every planned wave starts behind `story:cli-skeleton-validate`, which waits for a
  release of ESS (beyond10x/ess#836), and this part needs no `ratchet` command. It is 2 of the
  nine in the order of `.engineering/waves/0.1.0-ahead-1.md`, after
  `story:workflow-run-target-identifiers`, whose
  § 6 example it follows.
