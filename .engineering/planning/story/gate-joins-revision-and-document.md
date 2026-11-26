---
format: aep.planning-md/3
id: story:gate-joins-revision-and-document
kind: story
status: draft
title: One candidate gate judges a revision and a document of it
relations:
- decomposes: epic:ess-ui-behavior
revision: 1
---
## Context

Found by a consumer writing a `ratchet/1` file at 0.0.3: one gate cannot join candidates of two
kinds, a commit and a file digest. The design is silent.

The candidate of a run is the commit id for a target of the kind `revision` and the digest of
the document for `document` (`ratchet.evidence.CandidateIdentity`,
`spec/domains/evidence.yaml:52-60`). A gate decision has one candidate, a revision
(`spec/domains/gate.yaml:153-157`), and `ratchet evaluate --candidate` takes a revision
(`spec/domains/cli.yaml:267-272`). A gate whose requirements name a `revision` plan and a
`document` plan has no rule that says which document run belongs to the candidate revision, so
the document run never qualifies.

## Acceptance

- The design states how a candidate gate joins a run of a `document` target with the candidate
  revision, for example the digest of the file at that revision, and how the gate decision
  records both identities; before the story the design names neither.
- `ratchet evaluate --gate <name>` in a fixture with one gate over a `revision` plan and a
  `document` plan passes when both runs qualify for the candidate, and gives
  insufficient evidence with a cause that names the document when its digest is not the one at
  the candidate revision. This part waits for the waves to 0.1.0.

## Notes

- The story decides the form, declares it in `spec/` first (`ess specify validate` passes), and
  writes it into `docs/design.md` § 5 and `docs/evidence-format.md` in the same change.
- Filed under `epic:ess-ui-behavior` as the closest epic: it brings the target kind `document`
  into a gate. No epic holds this consumer's gaps.
- Related: `story:build-target-invocation` (an artifact tied to a revision),
  `story:gate-judges-commit-of-a-tag`, `story:evaluate-command`.
