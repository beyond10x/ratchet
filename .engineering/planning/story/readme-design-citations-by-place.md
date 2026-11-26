---
format: aep.planning-md/3
id: story:readme-design-citations-by-place
kind: story
status: draft
title: The README of the specification cites the design by place, not by line number
relations:
- decomposes: epic:format-gaps-first-format-consumer
revision: 1
---
## Context

The table of `spec/README.md` that maps each rule of the specification to its place in the design
cites `docs/design.md` and the specification sources by line number (for example 690, 603, YAML
218). Those numbers were already out of step at 9dcbc6e, before the wave of
`.engineering/waves/0.1.0-ahead-1.md`, and the wave's insertions into `docs/design.md` § 3 moved
them further. No script checks them. Found by the implementor of stories 4 to 6 of that wave;
pre-existing, so it waits until every planned wave is delivered.

## Acceptance

1. Each place the table of `spec/README.md` cites is named by a section heading or a quoted
   phrase instead of a line number, or a script under `spec/` reads each cited line number and
   fails when the line does not hold the text the row names.
2. Before: at least one cited line does not hold what its row names; after: none, and a case
   that moves one cited line fails.

## Notes

- Waits for the waves to 0.1.0.
