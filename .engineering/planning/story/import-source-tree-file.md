---
format: aep.planning-md/3
id: story:import-source-tree-file
kind: story
status: draft
title: An imported run names a file of the tree as its source
summary: A source kind for a committed results file and for a run made by hand.
relations:
- decomposes: epic:format-gaps-first-format-consumer
revision: 1
---
## Context

The repository `beyond10x/inference` wrote its quality definition against the formats at
commit `f139ecc` (2026-11-25): 3 `ratchet/1` files, 8 `ratchet-assessor/1` declarations and 15
`ratchet-evidence/1` records. It is the first consumer of the formats outside this repository
and of this story. Line numbers below are those of `f139ecc`.

Finding 4. The definition imports results that are a committed file of the tree and results of
a run made by hand. `ratchet.evidence.ImportSourceKind` is the closed list `forge_runs`,
`build_pool_log`, `junit` (`spec/domains/evidence.yaml:441-454`). The consumer's example:
`"source": {"kind": "tree_file", "location": "<path of a results file in the tree>"}`.

## Acceptance

A `ratchet-evidence/1` record whose `source.kind` names a file of the tree decodes under the
specification and `ratchet validate` accepts a plan that reads it, with the revision the file
was read at in the record; before the story the record is refused because the kind is not in
the list.

## Notes

- The form shown is the consumer's proposal. The story decides the form, declares it in
  `spec/` first (`ess specify validate` passes), and writes it into `docs/design.md` or
  `docs/evidence-format.md` in the same change.
- A new value or field of a released format is an addition: a file written for the format
  before the change stays valid.
- The story is a draft. It was there before the planned waves to 0.1.0 and waits for them.
