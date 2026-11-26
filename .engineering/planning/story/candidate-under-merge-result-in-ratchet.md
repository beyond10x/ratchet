---
format: aep.planning-md/3
id: story:candidate-under-merge-result-in-ratchet
kind: story
status: draft
title: The evidence reader refuses a merge_result record with candidate and target.revision swapped
summary: 'The command part of story:candidate-under-merge-result: a cause that names the field.'
relations:
- decomposes: epic:format-gaps-first-format-consumer
- depends_on: story:candidate-under-merge-result
- depends_on: story:cli-skeleton-validate
- depends_on: story:evidence-reader
revision: 1
---
## Context

Split on 2026-11-26 from `story:candidate-under-merge-result`, which states in `spec/domains/`,
`docs/design.md` and `docs/evidence-format.md` that under `selection: merge_result` the field
`candidate` is the revision under judgement and `target.revision` the merged tree that was
read, and shows the pair in an example of § 6. This story holds the part that needs the
`ratchet` command: the evidence reader.

## Acceptance

A record with the two swapped is refused by the reader with a cause that names the field;
before the story both spellings decode.

## Notes

- Moved verbatim from the acceptance of `story:candidate-under-merge-result`.
- The story decides what the reader compares to tell the two apart, such as the parents of
  the commit under `target.revision`.
- The story is a draft. It waits for the waves to 0.1.0: `story:cli-skeleton-validate` and
  `story:evidence-reader`.
