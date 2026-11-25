---
format: aep.planning-md/3
id: story:candidate-under-merge-result
kind: story
status: draft
title: Under merge_result a record names the candidate and the merged tree apart
summary: candidate is the revision under judgement, target.revision the merge commit that was read.
relations:
- decomposes: epic:format-gaps-first-format-consumer
revision: 1
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

## Acceptance

The specification and `docs/evidence-format.md` state for `selection: merge_result` that
`candidate` is the revision under judgement and `target.revision` the merged tree that was
read, a record with the two swapped is refused by the reader with a cause that names the
field, and an example of § 6 shows the pair; before the story both spellings decode.

## Notes

- The form shown is the consumer's proposal or what it wrote in place of the missing form.
  The story decides the form, declares it in `spec/` first (`ess specify validate` passes), and
  writes it into `docs/design.md` or `docs/evidence-format.md` in the same change.
- A new value or field of a released format is an addition: a file written for the format
  before the change stays valid.
- The story is a draft. It was there before the planned waves to 0.1.0 and waits for them.
