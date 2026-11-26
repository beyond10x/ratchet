---
format: aep.planning-md/3
id: story:build-target-invocation-in-ratchet
kind: story
status: draft
title: ratchet assess passes the artifact of a build and evaluate judges it for its revision only
summary: 'The command part of story:build-target-invocation: the artifact and the revision reach the assessor, and a record of another revision is not judged.'
relations:
- decomposes: epic:preset-catalog
- depends_on: story:build-target-invocation
- depends_on: story:cli-skeleton-validate
- depends_on: story:assess-command
- depends_on: story:evidence-reader
- depends_on: story:evaluate-command
scope:
- confidence: inferred
  path: crates/ratchet
- confidence: inferred
  path: crates/ratchet-core
revision: 3
---
## Context

Split on 2026-11-26 from `story:build-target-invocation`, which writes into
`docs/evidence-format.md` § 10 how an assessor of a target of the kind `build` is started
(`target_input` names the artifact, `--revision` the revision it was built from) and what its
record holds, and gives the form to `file-size@2` and `binary-size@2`. This story holds the
part that needs the `ratchet` command.

## Acceptance

`ratchet assess` on a plan of `binary-size@2` starts a stand-in assessor in a fixture with the
path of the artifact as its `target_input` and `--revision` the candidate revision, and
`ratchet evaluate --gate <name>` does not judge a record whose `target.revision` is another
revision than the candidate's: the requirement gets insufficient evidence with a cause that
names both revisions. Before the story no command starts an assessor or reads a record.

## Notes

- Moved from the acceptance of `story:build-target-invocation`.
- The story is a draft. It waits for the waves to 0.1.0: `story:cli-skeleton-validate`,
  `story:assess-command`, `story:evidence-reader` and `story:evaluate-command`.
