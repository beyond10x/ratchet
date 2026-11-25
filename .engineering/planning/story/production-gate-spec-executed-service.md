---
format: aep.planning-md/3
id: story:production-gate-spec-executed-service
kind: story
status: draft
title: A ratchet file as the production gate of a spec-executed service
summary: 'Seven checks of a consumer''s survey: three covered by catalog presets, probe assertions and artifact verification need a preset and a declaration each.'
relations:
- decomposes: epic:preset-catalog
- depends_on: story:preset-catalog-functional
- depends_on: story:preset-catalog-factory
scope:
- confidence: inferred
  path: CHANGELOG.md
- confidence: inferred
  path: docs/design.md
- confidence: inferred
  path: examples/README.md
- confidence: inferred
  path: examples/production-gate.ratchet.yaml
- confidence: inferred
  path: presets
- confidence: inferred
  path: spec/domains
revision: 7
---
## Context

A consumer runs a prototype service that executes a specification, and surveyed what the
service needs before production (2026-11-25, routed by the operator session of the
workstation). It wants one `ratchet/1` file as the production gate of that service. Nothing of
the consumer is named here: no organization, no service, no host.

The checks the survey names:

1. Every declared operation is served, and the set of served operations loses no item.
2. Every scenario replay that passed in the accepted run passes; a known-failure list holds
   the others and gains no item.
3. Negative-authentication probes fail closed: a request without a credential, with an
   expired one and with one of another tenant is refused.
4. Console routes cannot be reached through the public proxy.
5. TLS is on for every public listener.
6. The image has no critical advisory.
7. The signatures of the image and of its provenance verify.

What covers them, read against `epic:preset-catalog` and the design:

| check | covered by | what is missing |
| --- | --- | --- |
| 1, 2 | `conformance-cases@1` of `story:preset-catalog-functional`: an identity set by case id with `no_lost_items`, and the known-failure list | an assessor declaration that imports a replay report and a served-operations report; the catalog names an imported conformance report only |
| 6 | the artifact family of `story:preset-catalog-factory`: the set of dependencies with a known advisory, `no_new_items` | a severity on an item and a requirement on it ("no item of severity critical"); the catalog compares with an accepted set and has no limit by severity |
| 3, 4, 5 | nothing | assertions per probe (`holds` at a scope `probe`) from a report of HTTP probes; no assessor and no preset declares that output |
| 7 | nothing | an assertion per artifact from a verification tool's report; no assessor and no preset declares it |

Ratchet reimplements no tool (`AGENTS.md` § "Boundary"): it sends no HTTP request, replays no
scenario and verifies no signature. Each new assessor here runs a project command or imports a
report that the project's own probe runner, replay runner, scanner or verifier wrote.

A production gate is evaluated on a deployed environment, not on a revision: the target is a
deployment (`target: {kind: deployment, ...}`, `docs/design.md` § 3), and whether the verdict
is tied to a candidate or is an operational gate (`docs/design.md` § 5 "Gate kinds") is part
of this story.

## Acceptance

`examples/production-gate.ratchet.yaml`, a gate over the seven checks with generic names,
binds the catalog presets for checks 1, 2 and 6 and two new presets for checks 3 to 5 and 7,
each with its `ratchet-assessor/1` declaration, and `sh spec/presets.test.sh` passes on the
new preset files and counts their measurements; before the story the two presets and their
declarations are absent and the example does not exist.

## Scope

- `presets/`: a preset and a declaration for probe assertions (checks 3, 4, 5), a preset and a
  declaration for artifact verification (check 7), a declaration that imports a replay report
  and a served-operations report for `conformance-cases@1` where its declared report form
  does not hold them, and the page of the new family.
- `examples/production-gate.ratchet.yaml`, `examples/README.md`.
- `docs/design.md` § 4: the two rows of the preset table; § 5: the gate kind of a production
  gate.
- `spec/domains/`: a severity on an item of an identity set and a requirement by it, when the
  story decides check 6 needs it; declared before a file uses it.
- `CHANGELOG.md`.

## Notes

- First consumer: the surveyed service's repository. The story is a draft behind wave 3, the
  release 0.0.1 and the catalog stories it builds on (`story:preset-catalog-functional`,
  `story:preset-catalog-factory`).
- The survey's reading "ratchet lacks assessors for HTTP probes and for scenario replay" is
  half right: a scenario replay is an identity set the functional family already compares;
  what lacks is the declaration that imports its report. HTTP probes lack both the preset and
  the declaration, and so does signature verification, which the survey lists as a check and
  not as a gap.
- Every check here is exact: an assertion or a set. 0.1.0 judges identity sets; an assertion
  with `holds` is judged by the release that builds it (`ROADMAP.md` § "Releases").
- Every example is generic: `orders-api`, `probe-0007`. No Python. The test step ends within
  120 s, no test over 60 s.
