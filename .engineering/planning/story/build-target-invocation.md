---
format: aep.planning-md/3
id: story:build-target-invocation
kind: story
status: draft
title: The invocation contract covers a target that is a build
summary: No reserved argument passes the artifact of a build, so the built file is an input and nothing ties it to the revision.
relations:
- decomposes: epic:preset-catalog
- depends_on: story:preset-catalog-factory
scope:
- confidence: inferred
  path: CHANGELOG.md
- confidence: inferred
  path: docs/evidence-format.md
- confidence: inferred
  path: presets
- confidence: inferred
  path: spec/domains/assessor.yaml
- confidence: inferred
  path: spec/domains/evidence.yaml
revision: 6
---
## Context

The entry "A target that is a build" under "Not expressible yet" on `presets/artifact.md`
(`story:preset-catalog-factory`). First consumer: the catalog, and every project that binds
`image-size@1` or `binary-size@1`.

What the artifact family judges is a built thing, and `ratchet.specification.TargetKind` has
`build` for it. The invocation contract covers a target of the kind `revision` or `document`
(`docs/evidence-format.md` § 9, "The rest of the invocation"), and
`ratchet.assessor.ReservedArgument` has `revision` and no argument that passes the artifact
of a build (`spec/domains/assessor.yaml`). So each plan of the family names the kind
`revision`, the built file is an input, and the program writes its digest under
`target.identifiers`. Nothing checks that the file was built from the revision.

## Acceptance

The invocation contract covers a target of the kind `build`: Ratchet passes the assessor the
artifact the plan names, the evidence record carries its digest and the revision it was built
from, and `ratchet evaluate` does not judge a record whose artifact is of another revision
than the candidate; `binary-size@1` in a new version names a target of the kind `build`;
before the story the built file is an input and no record ties it to a revision.

## Notes

- The story decides how a project states that an artifact was built from a revision (a
  record the build writes, or a digest the plan pins), declares the form in `spec/` first and
  writes it into `docs/evidence-format.md` § 10 in the same change.
- Related and not the same: `story:imported-report-revision-check` (the revision of an
  imported report).
- An addition to released formats; a declaration that uses it is a new version of the
  declaration.
- The story is a draft. It waits for the waves to 0.1.0 and for `ratchet assess`.
