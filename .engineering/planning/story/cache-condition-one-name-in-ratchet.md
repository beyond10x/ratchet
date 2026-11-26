---
format: aep.planning-md/3
id: story:cache-condition-one-name-in-ratchet
kind: story
status: draft
title: ratchet validate refuses cache and the reader takes cache_profile
summary: 'The command part of story:cache-condition-one-name: the refusal of the other spelling in a plan and the reading of a declared cache_profile.'
relations:
- decomposes: epic:preset-catalog
- depends_on: story:cache-condition-one-name
- depends_on: story:cli-skeleton-validate
- depends_on: story:assessor-declaration
- depends_on: story:evidence-reader
revision: 1
---
## Context

Split on 2026-11-26 from `story:cache-condition-one-name`, which names the cache condition
`cache_profile` in `spec/domains/`, `docs/design.md`, `docs/evidence-format.md` and
`examples/quality/assessors/command-timing@1.assessor.yaml`, and makes `spec/presets.test.sh`
refuse `cache` with a message that names `cache_profile`. This story holds the part that needs
the `ratchet` command.

## Acceptance

`ratchet validate` refuses the other spelling, `cache`, in a plan with a message that names the
right one, `cache_profile`, and the evidence reader takes a declared `cache_profile` from
`evidence.conditions.cache_profile` and not from `other`; before the story no command reads
either.

## Notes

- The refusal is moved verbatim from the acceptance of `story:cache-condition-one-name`. The
  reading is its note that `story:evidence-reader` reads the conditions of a record and is the
  first code that needs the answer.
- The story is a draft. It waits for the waves to 0.1.0: `story:cli-skeleton-validate`,
  `story:assessor-declaration`, which reads the declaration a plan's conditions are held to,
  and `story:evidence-reader`.
