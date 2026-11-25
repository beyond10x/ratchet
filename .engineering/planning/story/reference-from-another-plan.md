---
format: aep.planning-md/3
id: story:reference-from-another-plan
kind: story
status: draft
title: A reference is adopted from the evidence of another plan
summary: 'The run of a reference implementation as the accepted set of the candidate: a requirement names another assessment as the source of its reference.'
relations:
- decomposes: epic:preset-catalog
- depends_on: story:preset-catalog-functional
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

`story:preset-catalog-functional` wrote the functional family of the catalog and listed on
`presets/functional.md`, under "Not expressible yet", what the family needs and the format
cannot say. This is the first of three. The first consumer is the catalog itself, and behind
it every project that binds `differential-equality@1`.

A candidate is compared with a reference implementation: the cases the reference
implementation passes are the accepted set, and the candidate loses none of them. The accepted
set is then the evidence of another plan, the run of the reference implementation.
`ratchet.specification.AdoptionSource` has `same_change` and `trusted_revision`, and
`ratchet.specification.RatchetPolicy` holds `from`, `runs` and `aggregation` and names no
assessment (`spec/domains/specification.yaml`). A reference is adopted from the runs of its
own plan alone.

## Acceptance

A requirement of a `ratchet/1` file names another assessment of the same specification as the
source of its reference, `ratchet validate` accepts the file and refuses a source that names no
assessment or one whose measurement has another value type, and
`differential-equality@1` gains the requirement "the candidate loses no case the reference
implementation passes" with its row on `presets/functional.md`; before the story the key is
refused and the page lists the requirement under "Not expressible yet".

## Notes

- The story decides the form, declares it in `spec/` first (`ess specify validate` passes),
  and writes it into `docs/design.md` § 5 "Protected references" in the same change.
- A new value or field of a released format is an addition: a file written before the change
  stays valid. A preset that uses it is a new version of the preset.
- The story is a draft. It waits for the waves to 0.1.0 and for `ratchet validate`.
