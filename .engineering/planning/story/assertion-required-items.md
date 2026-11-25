---
format: aep.planning-md/3
id: story:assertion-required-items
kind: story
status: draft
title: A plan names the items an assertion must have
summary: An assertion takes no reference, so no set names the expectations that must be there; one bound covers both endpoints of health-readiness@1.
relations:
- decomposes: epic:preset-catalog
- depends_on: story:preset-catalog-runtime
scope:
- confidence: inferred
  path: CHANGELOG.md
- confidence: inferred
  path: docs/design.md
- confidence: inferred
  path: presets
- confidence: inferred
  path: spec/domains/specification.yaml
revision: 5
---
## Context

Point 3 of "Not expressible yet" on `presets/operability.md`
(`story:preset-catalog-runtime`), and finding 3 of
`review-result:adversary-preset-catalog-runtime-attack-1`. First consumer: the catalog, and
every project that binds `health-readiness@1`.

An assertion takes no reference (`docs/design.md` § 3, "Comparisons"):
`ratchet.specification.ReferenceKind` has `generated` and `accepted_value`, and neither is for
an assertion (`spec/domains/specification.yaml`). So no accepted set names the expectations
that must be there, as one does for a set with `no_lost_items`. A plan bounds their number
through `ratchet.specification.CoverageBounds`, which does not see one expectation replaced by
another, and `executed_ids` there names an exact set, which a run with one more expectation no
longer is. In `health-readiness@1` the one `executed` bound (`min_expectations`) is over both
endpoints: a report whose expectations are all on the health endpoint is inside it when their
number reaches the bound, and the requirement on the readiness endpoint reads no item.

## Acceptance

A plan names the items an assertion must have, as a least set that a run may exceed, or a
bound per group of items, `ratchet evaluate` fails a requirement whose assertion lacks one of
them and names the missing item, and `health-readiness@1` in a new version requires at least
one expectation per endpoint; before the story a run with no expectation on one endpoint is
inside the bound of the plan.

## Notes

- The story decides the form and what a requirement over no item returns; it declares the form
  in `spec/` first and writes it into `docs/design.md` § 3 in the same change.
- Related and not the same: `story:item-field-values` (the values a field of an item may
  hold).
- An addition to a released format; a preset that uses it is a new version of the preset.
- The story is a draft. It waits for the waves to 0.1.0 and for `ratchet evaluate`.
