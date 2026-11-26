---
format: aep.planning-md/3
id: story:workflow-run-target-identifiers
kind: story
status: implemented
title: A workflow_run target names its run and its job
summary: The specification and the format document list run_id and job for a target of the kind workflow_run, with a § 6 example; identifiers stays an open map.
relations:
- decomposes: epic:format-gaps-first-format-consumer
revision: 8
transitions:
- {from: "draft", to: "proposed", at: "2026-11-26T05:20:02Z", actor: "human:operator", revision: 6}
- {from: "proposed", to: "active", at: "2026-11-26T05:20:02Z", actor: "human:operator", revision: 7}
- {from: "active", to: "implemented", at: "2026-11-26T07:54:30Z", actor: "human:operator", revision: 8, decided_on: {"recorded":{"test_result":1}}}
---
## Context

The repository `beyond10x/inference` wrote its quality definition against the formats at
commit `f139ecc` (2026-11-25): 3 `ratchet/1` files, 8 `ratchet-assessor/1` declarations and 15
`ratchet-evidence/1` records. It is the first consumer of the formats outside this repository
and of this story. Line numbers below are those of `f139ecc`.

Finding 7. A record of a CI run cannot say which run it is. `identifiers` of a target lists
names per target kind (`spec/domains/evidence.yaml:112-119`), and none is a run id or a job.
The consumer's example: `"identifiers": {"run_id": "<id>", "job": "<workflow> / <job>"}`.

At `7aa82f8`, as at `f139ecc`, `identifiers` is an open map, `Optional<Map<String, String>>`
(`spec/domains/evidence.yaml:113`), and E5 keeps it one: it is a place an assessor extends
without a version (`docs/evidence-format.md:334`). A record with `run_id` and `job` decodes
today. What is missing is the names: neither the specification nor the format document lists
them for `workflow_run`, so two assessors may write the same thing under two names.

## Acceptance

Line numbers here are those of `7aa82f8`. Before the story, neither the summary of
`identifiers` in `spec/domains/evidence.yaml` (`:112-119`) nor the row `identifiers` of the § 3 table `evidence.target` in
`docs/evidence-format.md` (`:79`) lists `run_id` and `job` for the kind `workflow_run`. After
it, both list them; a new example in § 6 of `docs/evidence-format.md` has a target of the kind
`workflow_run` with `selection: candidate` and carries both identifiers; `want_examples` in
`spec/record-examples.test.sh:46` and the number of § 6 examples in `spec/README.md` (`:122`)
and in the header of that script (`:27`) go from 3 to 4; and `sh spec/record-examples.test.sh`
passes. `ess specify validate` passes, and the story runs `task check:generated` because it
edits `spec/domains/`.

The script reads `identifiers` as an open map and does not see the two names, so they are
observed by a count over § 6: `sed -n '/^## 6\. /,/^## 7\. /p' docs/evidence-format.md | grep
-c '"run_id"'` prints 0 before the story and 1 after, and the same pipe with `'"job"'` prints 0
before and 1 after.

A `workflow_run` target may carry `selection: candidate`: neither the row `selection` (`:77`)
nor rule 1 (`:199`) restricts it by kind, and `examples/ci-turnaround.ratchet.yaml:26`
declares such a plan. Rule 1 then requires `candidate`, and the row `candidate` (`:62`) and the
summary of `ratchet.evidence.CandidateIdentity` (`spec/domains/evidence.yaml:56-59`) name its
identity for `revision`, `document` and `build` only. The example writes as `candidate` the
commit id the run ran at, equal to its `target.revision`, and the story adds that identity for
`workflow_run` to both places. Text only, no case: no row is added, and
`spec/record-fields.test.sh` and `spec/record-types.test.sh` keep their count of 78 rows in
§ 3.

## Notes

- Taken ahead of the waves to 0.1.0 into one wave built in sequence on one branch: every
  planned wave starts behind `story:cli-skeleton-validate`, which waits for an ESS release
  (beyond10x/ess#836). No `ratchet` command exists in this wave, so every acceptance item is
  observed through `task check` steps, the POSIX sh scripts under `spec/` and
  `.github/scripts/`, `ess specify validate`, or files. It is 1 of the nine in the order of
  `.engineering/waves/0.1.0-ahead-1.md`.
- `identifiers` stays an open map (E5): the story adds no refusal of a name, on
  `workflow_run` or on another kind.
- Two jobs of one run are two records, each with the same `run_id` and its own `job`.
- The form shown is the consumer's proposal. The story decides the names and the form of
  `job`, writes them into `spec/domains/evidence.yaml` first and into `docs/evidence-format.md`
  in the same change.
- A new name in an open map is an addition: a file written for the format before the change
  stays valid.
- `story:candidate-under-merge-result` adds its own § 6 example for the `merge_result` pair and
  changes the same count again; this story leaves that pair to it.
