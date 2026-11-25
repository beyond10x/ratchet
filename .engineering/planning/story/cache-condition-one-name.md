---
format: aep.planning-md/3
id: story:cache-condition-one-name
kind: story
status: draft
title: The cache condition has one name in a plan and in a record
summary: A plan writes cache and a record holds cache_profile; no rule joins the two.
relations:
- decomposes: epic:preset-catalog
- depends_on: story:preset-catalog-factory
scope:
- confidence: inferred
  path: CHANGELOG.md
- confidence: inferred
  path: docs/design.md
- confidence: inferred
  path: docs/evidence-format.md
- confidence: inferred
  path: presets
- confidence: inferred
  path: spec/domains/assessor.yaml
- confidence: inferred
  path: spec/domains/evidence.yaml
- confidence: inferred
  path: spec/domains/specification.yaml
revision: 8
---
## Context

Found by the implementor of `story:preset-catalog-factory` on 2026-11-25; it was there before
that unit.

The condition that says whether a build ran with a warm cache has two names. A plan and a
declaration write `cache`: the example of `docs/design.md` § 3 (`cache: warm` under
`conditions.all`), the summary of `ratchet.specification.ObservationConditions`
(`spec/domains/specification.yaml`) and the summary of `conditions` of
`ratchet.assessor.Assessor` (`spec/domains/assessor.yaml`). An evidence record holds
`cache_profile`: `ratchet.evidence.ObservedConditions.cache_profile`
(`spec/domains/evidence.yaml`) and the field table of `docs/evidence-format.md` § 3. The same
record has `other` for "every further condition that the plan or the assessor declares", so a
program that follows the plan writes `other.cache`, and no sentence says that a declared
`cache` is read from `cache_profile`.

The presets of the build family (`cold-build-time@1`, `warm-build-time@1`,
`test-step-time@1`) and their declarations write `cache_profile`, the name of the evidence
member, so that the declared condition and the observed one have one name.

## Acceptance

The design, the two domains and the evidence format name the condition once, with the same
key in a plan, a declaration and a record, `ratchet validate` refuses the other spelling in a
plan with a message that names the right one, and the example of `docs/design.md` § 3 and
the presets of the build family use that key; before the story the two spellings stand side
by side and no rule joins them.

## Notes

- The story decides which name stays. If it is `cache`, the three presets and two
  declarations of the build family change in a new version or before their first release.
- The story is a draft. It was there before the planned waves to 0.1.0 and waits for them;
  `story:evidence-reader` reads the conditions of a record and is the first code that needs
  the answer.
