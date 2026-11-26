---
format: aep.planning-md/3
id: story:gate-joins-revision-and-document
kind: story
status: draft
title: One candidate gate judges a revision and a document of it
relations:
- decomposes: epic:ess-ui-behavior
scope:
- confidence: cited
  path: CHANGELOG.md
- confidence: cited
  path: docs/design.md
- confidence: cited
  path: docs/evidence-format.md
- confidence: cited
  path: spec/domains/gate.yaml
revision: 6
---
## Context

Found by a consumer writing a `ratchet/1` file at 0.0.3: one gate cannot join candidates of two
kinds, a commit and a file digest. The design is silent.

The candidate of a run is the commit id for a target of the kind `revision` and the digest of
the document for `document` (`ratchet.evidence.CandidateIdentity`,
`spec/domains/evidence.yaml:52-60`; `docs/evidence-format.md` § 3, `evidence`, the row
`candidate`, `:70`). A record of a `document` target names `digest`, `digest_form`, and `path`
where the document is a file of the tree (`docs/evidence-format.md:87`, `evidence.target`, the
row `identifiers`). A gate decision has one candidate, a revision
(`ratchet.gate.GateDecision.candidate`, `spec/domains/gate.yaml:153-157`), and
`ratchet evaluate --candidate` takes a revision (`spec/domains/cli.yaml:267-272`). A gate whose
requirements name a `revision` plan and a `document` plan has no rule that says which document
run belongs to the candidate revision, so the document run never qualifies.
`ratchet.gate.RequirementVerdict` (`spec/domains/gate.yaml:195`) lists the runs it read
(`evidence`) and no identity of a document. The cause `not_attributable_to_candidate` exists
(`docs/design.md` § 5 "Verdicts", the table of causes, `:614`).

## Decision

The reversible answer, taken here (AGENTS.md § "Phase: implementation"): in a candidate gate,
the run of a `document` target belongs to the candidate revision when its
`target.identifiers.path` names a file of the tree and its `candidate` digest equals the
SHA-256 of that file at the candidate revision. A run whose digest is another is insufficient
evidence with the cause `not_attributable_to_candidate`, naming the path; a document that is no
file of the tree (no `path`) cannot be joined and gets the same cause. The verdict of such a
requirement records the document it joined: an optional member `document` of
`RequirementVerdict`, a struct of `path` and `digest`. `GateDecision.candidate` stays the
revision.

## Acceptance

Every outcome below is observable without a `ratchet` command.

1. `spec/domains/gate.yaml`: `RequirementVerdict` (`:195`) has the optional `document`, a new
   struct of `path` and `digest` (`ratchet.evidence.Digest`), present exactly when the plan of
   the requirement has a target of the kind `document`. Checked by
   `ess specify validate --path spec --strict-requires`, which exits 0, and by
   `task check:generated`.
2. `docs/design.md` § 5 "Gate entries, deciding evidence, and gate kinds", after the paragraph
   "Gate kinds": how a candidate gate joins a `document` run with the candidate revision, the
   cause when the digest is not the one at the candidate revision, and that the decision records
   both identities. § 6, the row "Gate decision" of the table of records, names the joined
   document. Text only, no case.
3. `docs/evidence-format.md` § 3, `evidence.target`, the row `identifiers` (`:87`): a document
   without `path` cannot be joined to a candidate revision in a gate. Text only, no case; the
   row count of the table stays, so `sh spec/record-fields.test.sh` and
   `sh spec/record-types.test.sh` print their last lines unchanged.
4. `CHANGELOG.md` has its line under `## [Unreleased]`. Text only, no case.

## Notes

- An addition to a released format: a gate decision without `document` stays valid.
- `ratchet evaluate --gate <name>` in a fixture with one gate over a `revision` plan and a
  `document` plan, which passes when both runs qualify for the candidate and gives insufficient
  evidence naming the document when its digest is not the one at the candidate revision, and
  the gate report row (`ratchet.cli.VerdictRow`) that shows the document, are
  `story:gate-joins-revision-and-document-in-ratchet`, which waits for the waves to 0.1.0
  (`story:evaluate-command`).
- `spec/domains/gate.yaml` `RequirementVerdict` gets its list of items not judged from
  `story:new-item-without-accepted-value` (26) before this story. `docs/design.md` § 5 "Gate
  kinds" is changed by stories 30 and 31 just before; this story adds a paragraph after it.
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of `.engineering/waves/0.1.0-ahead-2.md`,
  into one wave built in sequence on one branch: every planned wave starts behind
  `story:cli-skeleton-validate`, which waits for a release of ESS (beyond10x/ess#836), and this
  part needs no `ratchet` command. It is 32 of the 33 in the order of that page.
- Related: `story:build-target-invocation` (an artifact tied to a revision, 7 in the order),
  `story:gate-judges-commit-of-a-tag`.
