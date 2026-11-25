---
format: aep.planning-md/3
id: story:render-numbers-into-documents
kind: story
status: draft
title: ratchet render writes numbers into documents from records
summary: 'The command of design § 5 and § 6: a block of numbers in a document, its check, and the static export with subjects side by side.'
relations:
- decomposes: epic:format-gaps-second-format-consumer
scope:
- confidence: inferred
  path: CHANGELOG.md
- confidence: inferred
  path: crates/ratchet
- confidence: inferred
  path: crates/ratchet-core
- confidence: inferred
  path: docs/design.md
- confidence: inferred
  path: spec/cli.yaml
revision: 6
---
## Context

The repository `beyond10x/swell`, a script engine, drafted its quality definition against the
formats at commit `90924c9` (2026-11-25). It is the first consumer of this story. Line numbers
below are those of `90924c9`.

`docs/design.md` § 5 lists the command `ratchet render`: it writes a block of numbers in a
document from records, and the static export of § 6; with `--check true` it compares what is
committed (`docs/design.md:721`, `:766`, `:776`). `spec/cli.yaml` declares the command. No
story builds it, and 0.1.0 does not hold it. The consumer keeps measured numbers in an
instruction file, a changelog and a data file of its site, typed by hand, and wants its
subjects side by side on one page.

## Acceptance

`ratchet render` writes the declared block of a document from the records of a revision and
exits 0, `ratchet render --check true` exits non-zero and names the block when the committed
numbers differ from the records, and the static export shows two subjects of one project side
by side; before the story the command answers that it is unavailable.

## Notes

- The command and its inputs are declared in `spec/cli.yaml`; the story reads the declaration
  and changes it first where it does not fit.
- The story is a draft. It was there before the planned waves to 0.1.0 and waits for them.
