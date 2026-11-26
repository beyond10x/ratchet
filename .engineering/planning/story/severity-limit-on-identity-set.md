---
format: aep.planning-md/3
id: story:severity-limit-on-identity-set
kind: story
status: draft
title: A requirement limits the items of an identity set by severity
relations:
- decomposes: epic:preset-catalog
revision: 1
---
## Context

Named by `story:production-gate-spec-executed-service`. Check 6 of a consumer's production
gate is "the image has no critical advisory". The items of `advisory-report@1` carry
`severity` (`presets/advisory-report@1.assessor.yaml:17`), and a measurement's `filter` keeps
the items of a severity (`docs/design.md:184`). The example `examples/production-gate.ratchet.yaml`
states check 6 as `no_new_items` against the accepted set over the critical items, which lets a
critical advisory stand once it is accepted.

## The question

Whether `eq 0` on a filtered identity set already states the limit: an identity set takes the
five operators on the number of its items (`docs/design.md:175`), so `eq` with the value 0 on
the set filtered to `severity: [critical]` may say "no critical item" with no new key. Only
where it does not does the story add a requirement by severity in `spec/domains/` first.

## Acceptance

A requirement of a `ratchet/1` file limits the items of an identity set by their severity, in
the form `docs/design.md` names after the question is answered, and the example of check 6 in
`examples/production-gate.ratchet.yaml` uses it; before the story the example states check 6
with `no_new_items` only.

## Notes

- The story is a draft. It waits for the waves to 0.1.0.
