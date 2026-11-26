---
format: aep.planning-md/3
id: story:production-gate-spec-executed-service
kind: story
status: draft
title: A ratchet file as the production gate of a spec-executed service
summary: 'Seven checks of a consumer''s survey in one example gate: checks 1, 2 and 6 from the catalog, a ninth family of two presets and two declarations for probe assertions and artifact verification.'
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
  path: spec/example-declarations.test.sh
- confidence: inferred
  path: spec/presets.test.sh
revision: 13
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

What covers them, read against `epic:preset-catalog` and the design (line numbers of
`7aa82f8`):

| check | covered by | what is missing |
| --- | --- | --- |
| 1, 2 | `conformance-cases@1` (an identity set by case id with `no_lost_items`) and `known-failures@1` of the functional family, each bound over the report the project's runner writes in the form of `presets/functional.md` | nothing, where a served-operations report and a replay report fit that form |
| 6 | `advisory-report@1`, the declaration of `dependency-advisories@1`: its items carry `severity` (`presets/advisory-report@1.assessor.yaml:17`), and a measurement's `filter` keeps the items of a severity (`docs/design.md:184`) | `dependency-advisories@1` takes no filter input (`presets/dependency-advisories@1.preset.yaml:6-10`), so the example writes the plan of check 6 itself |
| 3, 4, 5 | nothing | assertions per probe (`holds` at a scope `probe`) from a report of HTTP probes; no preset declares that output |
| 7 | nothing | an assertion per artifact from a verification tool's report; no assessor and no preset declares it |

Ratchet reimplements no tool (`AGENTS.md` § "Boundary"): it sends no HTTP request, replays no
scenario and verifies no signature. Each new assessor here runs a project command or imports a
report that the project's own probe runner, replay runner, scanner or verifier wrote.

A production gate is evaluated on a deployed environment, not on a revision. The gate kinds
that exist are `candidate` and `operational` (`spec/domains/specification.yaml:637-639`); an
operational gate takes only time-window plans without a `selection` (`docs/design.md:629`),
and the bound presets' plans carry `selection: candidate`. The example states `kind: candidate`.

The story extends `epic:preset-catalog`, whose lines 31 and 56 name eight families and no
example, with a ninth family and an example.

## Acceptance

`examples/production-gate.ratchet.yaml` is a gate over the seven checks with generic names and
`kind: candidate`. It binds by `use:` `conformance-cases@1` for check 1, `conformance-cases@1`
and `known-failures@1` for check 2, and the two new presets for checks 3 to 5 and check 7.
Check 6 is a plan of the example over `advisory-report@1` with `filter: {severity: [critical]}`
and a requirement `no_new_items` against the accepted set; "no critical advisory" as a limit
waits for the severity story of the Notes.

`presets/` gains 2 presets, 2 declarations and 1 page, the ninth family, as the Scope names.
The last line of `sh spec/presets.test.sh` goes from
`presets: 47 of 47 file(s) valid, 41 of 41 measurement(s) with a row, <c> of <c> broken copies refused`
to `presets: 52 of 52 file(s) valid, 45 of 45 measurement(s) with a row, <c> of <c> broken copies refused`,
with `<c>` the count that `story:preset-check-unlisted-forms` leaves (92 at `7aa82f8`): the
probe preset has 3 measurements, one per check 3, 4 and 5, and the verification preset 1.

`sh spec/example-declarations.test.sh` reads the example: its check line counts 6 example
files (5 at `7aa82f8`) with every measurement as declared. A new rule of that script: each
`use:` under `presets:` of an example names a file `presets/<name>@<version>.preset.yaml`. The
example is accepted, and a broken copy whose `use:` names a preset that `presets/` does not
hold is refused with the message of the rule; the last line counts one broken copy more (31 at
`7aa82f8`). Before the story the two presets and their declarations are absent, the example
does not exist, and no script reads a `use:`.

## Scope

- `presets/`: a preset and a declaration for probe assertions (checks 3, 4, 5; 3
  measurements), a preset and a declaration for artifact verification (check 7; 1
  measurement), and the page of the new family.
- `examples/production-gate.ratchet.yaml`, `examples/README.md`.
- `spec/example-declarations.test.sh`: the rule on `use:` and its broken copy.
- `docs/design.md` § 4: the two rows of the preset table.
- `CHANGELOG.md`.

## Notes

- Taken ahead of the waves to 0.1.0 into one wave built in sequence on one branch: every
  planned wave starts behind `story:cli-skeleton-validate`, which waits for an ESS release
  (beyond10x/ess#836). No `ratchet` command exists in this wave, so every acceptance item is
  observed through `task check` steps, the POSIX sh scripts under `spec/` and
  `.github/scripts/`, `ess specify validate`, or files. It is 9 of the nine in the order of
  `.engineering/waves/0.1.0-ahead-1.md`. It builds on
  `story:preset-catalog-functional` and `story:preset-catalog-factory`.
- A severity on an item of an identity set and a requirement by it in `spec/domains/` becomes
  its own draft story. It first reads `docs/design.md:175`: an identity set takes `eq` on the
  number of its items, so `eq` with the value 0 on the filtered set may already state the limit.
- The gate kind of a production gate in `docs/design.md` § 5 becomes its own draft story, beside
  `story:gate-judges-commit-of-a-tag`.
- A declaration that imports a served-operations report or a replay report becomes its own
  draft story where that report does not fit the form of `conformance-report@1`.
- The example writes the `digest` of each binding; no command checks a binding digest until
  `story:preset-binding-resolution`.
- `probe-report@1` (`presets/probe-report@1.assessor.yaml`) already declares the assertions
  `health` and `readiness` at the scope `expectation`; the declaration of checks 3 to 5 takes
  another name.
- The story runs `task check:generated` when it edits `spec/domains/`.
- The survey's reading "ratchet lacks assessors for HTTP probes and for scenario replay" is
  half right: a scenario replay is an identity set the functional family already compares.
  HTTP probes lack both the preset and the declaration, and so does signature verification,
  which the survey lists as a check and not as a gap.
- Every check here is exact: an assertion or a set. 0.1.0 judges identity sets; an assertion
  with `holds` is judged by the release that builds it (`ROADMAP.md` § "Releases").
- Every example is generic: `orders-api`, `probe-0007`. No Python. The test step ends within
  120 s, no test over 60 s.
