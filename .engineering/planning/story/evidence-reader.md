---
format: aep.planning-md/3
id: story:evidence-reader
kind: story
status: active
title: Read and check ratchet-evidence/1, record id, local record directory
summary: The reader with rules 1 to 7 and 9, both digests, and the hand-over directory.
relations:
- decomposes: epic:observe-adopt-reject
- depends_on: story:cli-skeleton-validate
- depends_on: story:record-formats-in-spec
scope:
- confidence: cited
  path: crates/ratchet-core/src/evidence
- confidence: cited
  path: crates/ratchet-core/src/evidence.rs
- confidence: cited
  path: crates/ratchet-core/src/store.rs
- confidence: cited
  path: crates/ratchet-core/tests/evidence.rs
- confidence: cited
  path: crates/ratchet-core/tests/fixtures/evidence
- confidence: cited
  path: crates/ratchet-core/tests/invariants/evidence.txt
- confidence: cited
  path: crates/ratchet-core/tests/store.rs
revision: 9
transitions:
- {from: "draft", to: "proposed", at: "2026-11-24T13:10:21Z", actor: "agent:ratchet", revision: 4, decided_on: {"recorded":{"review_outcome":3}}}
- {from: "proposed", to: "active", at: "2026-11-24T13:10:21Z", actor: "agent:ratchet", revision: 5, decided_on: {"recorded":{"review_outcome":3}}}
---
## Context

`uxui`'s assessor `ux-static@1` writes `ratchet-evidence/1` documents today, and nothing reads
them (`research/consumer-input-ux-ui.md`, gap U1). `docs/evidence-format.md` § 4 gives nine rules
a reader checks; rules 1 to 7 and 9 can be checked on one document. § 2 defines the record id
(`run:<hex>`, SHA-256 over the bytes of the file) and the evidence digest (SHA-256 over the bytes
of the value of `evidence`). Design § 6 names the hand-over: a run writes its records where a
later step reads them.

## Acceptance

The test run of `ratchet-core` lists as passed `evidence::reads_example` (the example document of
`docs/evidence-format.md` § 6 yields its typed results, its record id and its evidence digest),
one test `evidence::rule_<n>_rejected` for each of the rules 1 to 7 and 9 (a fixture that breaks
that one rule is rejected with the number of the rule and the JSON path of the member), and
`store::write_list_read` (a document written to the local record directory is listed among the
runs of its assessment under its record id and read back byte-identical, in the directory
`[records] store` names and in `.ratchet/records` without it).

## Scope

- `crates/ratchet-core/src/evidence.rs` (and `evidence/` beside it)
- `crates/ratchet-core/src/store.rs`: the local record directory. Write a document under its
  record id, list the runs of an assessment, read one. The directory is `[records] store` of
  `ratchet.toml` when it names a path, else `.ratchet/records` under the root
- `crates/ratchet-core/tests/evidence.rs`, `crates/ratchet-core/tests/store.rs`, fixtures under
  `crates/ratchet-core/tests/fixtures/evidence/`, `crates/ratchet-core/tests/invariants/evidence.txt`

## Notes

- `crates/ratchet-core/tests/main.rs`, `Cargo.toml` and `Cargo.lock` are not edited:
  `story:cli-skeleton-validate` declared the test modules and the SHA-256 dependency.
- The decoders of `crates/ratchet-model` are generated: the owner answered on 2026-11-25 that
  the crate is the output of `ess generate synthesize` alone (`story:cli-skeleton-validate`).
  This story writes no decoder and starts after the ESS release that emits them. Decoding
  goes through them
  (`story:record-formats-in-spec` declares the fields, the target kind `document` among them). A
  member of `evidence` the reader does not know is rejected, a member of `run` it does not know
  is ignored (§ 1 "Version").
- Decimals stay text; no value passes through a float.
- Each invariant of a `ratchet.evidence` type in the specification has a fixture that breaks only it
  and is rejected (`samples` of a sampled number and the rule-6 pair among them), and the test
  step fails when the specification holds an invariant of those types that no fixture names. No
  gate step read an invariant before this story (`review-result:adversary-record-formats-pass-2`,
  finding 4). The comparison is the test `invariants` of `story:cli-skeleton-validate`; this story
  adds the list `crates/ratchet-core/tests/invariants/evidence.txt` and edits no file of that test.
- Red first: the tests fail before the reader exists.
- Budget: no test over 60 s, the step within 120 s; these tests read files only.
- The check of a document against an assessor's declaration is in `story:assess-command`.
- Decision this story takes and reports: the layout of the local record directory (design § 6
  names the hand-over and not its layout).
- No `CHANGELOG.md` line here: `story:acceptance-in-gate` writes the lines of the slice.
