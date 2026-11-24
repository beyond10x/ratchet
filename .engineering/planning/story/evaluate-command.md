---
format: aep.planning-md/3
id: story:evaluate-command
kind: story
status: draft
title: 'ratchet evaluate --gate: verdict from the trusted revision''s policy'
summary: Pass, fail or insufficient evidence with requirement, scope item, observed, allowed, cause and evidence id.
relations:
- decomposes: epic:observe-adopt-reject
- depends_on: story:evidence-reader
- depends_on: story:reference-compare
- depends_on: story:assessor-declaration
scope:
- confidence: cited
  path: crates/ratchet-core/src/gate.rs
- confidence: cited
  path: crates/ratchet/src/commands/evaluate.rs
- confidence: cited
  path: crates/ratchet/tests/evaluate.rs
- confidence: cited
  path: crates/ratchet/tests/fixtures/evaluate
- confidence: cited
  path: docs/design.md
revision: 2
---
## Context

`ratchet evaluate --gate <name>` is the command CI enforces. It judges the candidate's evidence by
policy from the trusted revision: the specification and the accepted references are read there
and not from the candidate's tree (design § 5 "Protected references" rules 1 and 2; vision
outcome 5). It exits 0 only on a pass; a failed gate and a gate with insufficient evidence exit 1
and the code in the report tells them apart (design § 5 "Proposed CLI").

## Acceptance

In a fixture git repository whose trusted revision holds a specification, a gate and a reference,
`ratchet evaluate --gate merge --trusted <revision>` exits 0 with the verdict pass for a
candidate whose recorded evidence is within the tolerance; exits 1 with the code `gate_failed`
for a candidate with one worse value, and the report row names the requirement, the scope item,
the observed value, the allowed value, the cause `regression`, the next step `candidate` and the
id of the evidence record; exits 1 with the code `insufficient_evidence` and the cause
`reference_missing` when the trusted revision holds no reference record; and still exits 1 with
`gate_failed` when the candidate's own tree holds a looser reference or a looser tolerance.

## Scope

- `crates/ratchet-core/src/gate.rs`: read the policy at the trusted revision, select the
  qualifying run per requirement, compare (`story:reference-compare`), compute the verdict of the
  gate (fail before insufficient evidence), build the typed report
- `crates/ratchet/src/commands/evaluate.rs`
- `crates/ratchet/tests/`: module `evaluate`; the fixture repository is built once per test run
  under `target/`, keyed by a digest of its sources
- `docs/design.md` § 5: the default of `--trusted`, and the two readings `story:reference-compare`
  reports

## Notes

- Evidence qualifies when its `candidate` is the candidate revision, its class is one of the
  gate's `qualifying_environments`, its run is complete and its coverage meets the plan's bounds;
  otherwise the cause is the one design § 5 "Verdicts" gives (`coverage_below_plan`, the
  completion's cause, or no run: `reference_missing` is not used for a missing run; the story
  names the cause it uses and writes it into the design if the list lacks one).
- `evidence: any` over the gate's classes (D3 decided A).
- Report-mode entries are evaluated and listed with their verdict and `since`, and do not block.
- Decision this story takes and reports: the default of `--trusted` when it is absent. Proposed:
  the merge base of HEAD and `origin/main`, written into `docs/design.md` § 5.
- Not here: `when`, exceptions, operational gates, `local_skips_refused`, the stale-reference
  fail.
- Red first, with the fourth case (a candidate that loosens its own policy) written before the
  reader of the trusted revision exists. Budget: no test over 60 s, the step within 120 s.
