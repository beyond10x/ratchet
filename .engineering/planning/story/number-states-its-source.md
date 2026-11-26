---
format: aep.planning-md/3
id: story:number-states-its-source
kind: story
status: draft
title: A limit or a tolerance of a ratchet/1 file states its source
relations:
- decomposes: epic:format-gaps-first-format-consumer
revision: 1
---
## Context

Found by a consumer writing a `ratchet/1` file at 0.0.3: the file has no field for the source of
a number, read here as where a limit or a tolerance of the file comes from (a decision, a
commitment to someone, an earlier measurement).

A `Condition` holds `operator`, `value` and `unit` (`spec/domains/specification.yaml:536-555`),
and a `Tolerance` holds `percent` and `absolute`
(`spec/domains/specification.yaml:562-574`). The only text on a requirement is `meaning`,
free prose that `ratchet explain` prints (`spec/domains/specification.yaml:989-991`). Nothing a
reader or a gate report can show says where the number came from or since when it holds. The
records hold a source only for an imported run (`docs/evidence-format.md:77`).

## Acceptance

- A limit and a tolerance of a `ratchet/1` file can state their source (a reference to a
  document or a decision, and a date), the gate report and `ratchet explain` print it beside the
  allowed value, and a file without it stays valid; before the story the key is refused.
- `ratchet validate` accepts the form. The output of `ratchet explain` and of the gate report
  waits for the waves to 0.1.0.

## Notes

- The story decides the form, declares it in `spec/` first (`ess specify validate` passes), and
  writes it into `docs/design.md` § 3 in the same change. An addition to a released format.
- Filed under `epic:format-gaps-first-format-consumer` as the closest epic: an addition to
  `ratchet/1` for a consumer's definition. No epic holds this consumer's gaps.
- Related: `story:list-item-statement` (a statement on an item of a list).
