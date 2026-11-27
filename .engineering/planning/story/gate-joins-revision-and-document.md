---
format: aep.planning-md/3
id: story:gate-joins-revision-and-document
kind: story
status: implemented
title: One candidate gate judges a revision and a document of it
relations:
- decomposes: epic:ess-ui-behavior
scope:
- confidence: cited
  path: crates/ratchet-cli-contract
- confidence: cited
  path: docs/design.md
- confidence: cited
  path: docs/evidence-format.md
- confidence: cited
  path: spec/domains/cli.yaml
- confidence: cited
  path: spec/domains/gate.yaml
revision: 14
transitions:
- {from: "draft", to: "proposed", at: "2026-11-26T21:04:25Z", actor: "human:operator", revision: 12, decided_on: {"recorded":{"review_outcome":4}}}
- {from: "proposed", to: "active", at: "2026-11-26T21:04:25Z", actor: "human:operator", revision: 13, decided_on: {"recorded":{"review_outcome":4}}}
- {from: "active", to: "implemented", at: "2026-11-26T23:39:04Z", actor: "human:operator", revision: 14, decided_on: {"recorded":{"test_result":1,"review_outcome":4}}}
---
## Context

Found by a consumer writing a `ratchet/1` file at 0.0.3: one gate cannot join candidates of two
kinds, a commit and a file digest. The design is silent.

The candidate of a run is the commit id for a target of the kind `revision` and the digest of
the document for `document` (`ratchet.evidence.CandidateIdentity`,
`spec/domains/evidence.yaml:52-60` at 7b01ea1; `docs/evidence-format.md` § 3, `evidence`, the
row `candidate`, `:70`). A record of a `document` target names `digest`, `digest_form`, and
`path` where the document is a file of the tree (`docs/evidence-format.md:87`,
`evidence.target`, the row `identifiers`). A gate decision has one candidate, a revision
(`ratchet.gate.GateDecision.candidate`, `spec/domains/gate.yaml:153-157`), and
`ratchet evaluate --candidate` takes a revision (`spec/domains/cli.yaml:267-272`). A gate whose
requirements name a `revision` plan and a `document` plan has no rule that says which document
run belongs to the candidate revision, so the document run never qualifies.
`ratchet.gate.RequirementVerdict` (`spec/domains/gate.yaml:195`) and the report row
`ratchet.cli.VerdictRow` (`spec/domains/cli.yaml:298`) list the runs read (`evidence`) and no
identity of a document. The cause `not_attributable_to_candidate` exists (`docs/design.md` § 5
"Verdicts", the table of causes, `:614`).

## Decision

The reversible answer, taken here (AGENTS.md § "Phase: implementation"): in a candidate gate,
the run of a `document` target belongs to the candidate revision when its
`target.identifiers.path` names a file of the tree and its `candidate` digest equals the
SHA-256 of that file at the candidate revision. A run whose digest is another is insufficient
evidence with the cause `not_attributable_to_candidate`, naming the path; a document that is no
file of the tree (no `path`) cannot be joined and gets the same cause. The verdict of such a
requirement records the document it joined: an optional member `document` of
`RequirementVerdict` and of `VerdictRow`, of a new struct `ratchet.gate.JoinedDocument` with
`path` and `digest` (`ratchet.evidence.Digest`). `GateDecision.candidate` stays the revision.

When `document` is present is a rule over the plan of the requirement, which a verdict does not
hold, so `spec/domains/gate.yaml` cannot state it as an invariant: the summary of the member
states it, and the command keeps it.

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

1. `spec/domains/gate.yaml` declares the struct `ratchet.gate.JoinedDocument` with the members
   `path` and `digest` (`ratchet.evidence.Digest`): `grep -c 'name: ratchet.gate.JoinedDocument'
   spec/domains/gate.yaml` prints 1 (0 before), and
   `ess specify validate --path spec --strict-requires` exits 0.
2. `ratchet.gate.RequirementVerdict` has the optional member `document` of that struct:
   `grep -c 'type: Optional<ratchet.gate.JoinedDocument>' spec/domains/gate.yaml` prints 1 (0
   before), and `task check:generated` exits 0.
3. The summary of `document` on `RequirementVerdict` states when it is present:
   `grep -F 'Present exactly when the plan of the requirement has a target of the kind
   `document`' spec/domains/gate.yaml` finds it (nothing before; the line break of a folded
   summary is placed so that the phrase stands on one line).
4. `ratchet.cli.VerdictRow` in `spec/domains/cli.yaml` has the optional member `document` of
   the same struct: `grep -c 'type: Optional<ratchet.gate.JoinedDocument>'
   spec/domains/cli.yaml` prints 1 (0 before).
5. The generated crate follows: after `task generate`, `task check:generated` exits 0 and
   `grep -rl JoinedDocument crates/ratchet-cli-contract/` prints at least one file (none
   before).
6. `docs/design.md` § 5 "Gate entries, deciding evidence, and gate kinds" has a paragraph after
   "Gate kinds" that says how a candidate gate joins a `document` run with the candidate
   revision: `grep -F '**A document run joins the candidate revision.**' docs/design.md` finds
   it (nothing before).
7. That paragraph names the cause when the digest is not the one at the candidate revision:
   `grep -F 'is not the SHA-256 of that file at the candidate revision' docs/design.md` finds
   it (nothing before).
8. `docs/design.md` § 6, the row "Gate decision" of the table of records, names the joined
   document: `grep -F 'the document it joined, by path and digest' docs/design.md` finds it
   (nothing before).
9. `docs/evidence-format.md` § 3, `evidence.target`, the row `identifiers` says that a document
   without `path` cannot be joined to a candidate revision in a gate:
   `grep -F 'cannot be joined to a candidate revision in a gate' docs/evidence-format.md` finds
   it (nothing before); the row count of the table stays.

## Notes

- An addition to a released format: a gate decision without `document` stays valid.
- `ratchet evaluate --gate <name>` in a fixture with one gate over a `revision` plan and a
  `document` plan, which passes when both runs qualify for the candidate, fills `document` in
  the decision and the report, and gives insufficient evidence naming the document when its
  digest is not the one at the candidate revision, is
  `story:gate-joins-revision-and-document-in-ratchet`, which waits for the waves to 0.1.0
  (`story:evaluate-command`).
- It changes `spec/domains/cli.yaml`, so it runs `task generate` and `task check:generated`.
- `RequirementVerdict` and `VerdictRow` get `items_not_judged` from
  `story:new-item-without-accepted-value` (26) before this story. `docs/design.md` § 5 "Gate
  kinds" is changed by stories 30 and 31 just before; this story adds a paragraph after it.
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of `.engineering/waves/0.1.0-ahead-2.md`,
  into one wave built in sequence on one branch: every planned wave starts behind
  `story:cli-skeleton-validate`, which waits for a release of ESS (beyond10x/ess#836), and this
  part needs no `ratchet` command. It is 32 of the 33 in the order of that page.
- Related: `story:build-target-invocation` (an artifact tied to a revision, 7 in the order),
  `story:gate-judges-commit-of-a-tag`.
