---
format: aep.planning-md/3
id: story:plan-conditions-from-binding
kind: story
status: draft
title: A binding passes the conditions of a plan
summary: The conditions of a plan are a map per class and no input type holds a map, so each preset fixes them.
relations:
- decomposes: epic:preset-catalog
- depends_on: story:preset-catalog-runtime
scope:
- confidence: cited
  path: CHANGELOG.md
- confidence: cited
  path: docs/design.md
- confidence: cited
  path: presets/artifact.md
- confidence: cited
  path: presets/build.md
- confidence: cited
  path: presets/code.md
- confidence: cited
  path: presets/latency.md
- confidence: inferred
  path: presets/operation-time@2.preset.yaml
- confidence: cited
  path: presets/resources.md
- confidence: cited
  path: presets/start.md
- confidence: cited
  path: spec/domains/specification.yaml
- confidence: cited
  path: spec/presets.test.sh
revision: 18
---
## Context

Point 3 of "Not expressible yet" on `presets/latency.md` (`:257-261`), repeated on
`presets/resources.md` (`:135-136`), `presets/start.md` (`:124-125`), `presets/code.md`
(`:258`), `presets/build.md` (`:410-416`) and `presets/artifact.md` (`:307`)
(`story:preset-catalog-runtime`, `story:preset-catalog-factory`). First consumer: the catalog,
and every project that binds a preset with a sampled measurement. Line numbers are those of
`7b01ea1`.

Sampled evidence qualifies under the conditions its plan declares (`docs/design.md` § 3,
"Measurement kind and observation conditions", `:94`). A project may want a bound on the host
load for the class `local` and a runner for the class `ci`.
`ratchet.specification.ObservationPlan` holds `conditions` as a map from a class to its
conditions (`spec/domains/specification.yaml:519-525`), and
`ratchet.specification.InputType` has `string`, `integer`, `decimal`, `boolean` and `path`
(`:727-730`): an input stands for a scalar or a list of scalars
(`ratchet.specification.InputReference`, `:794`; `docs/design.md:543`). `spec/presets.test.sh`
refuses a reference at a place of a map or a struct with "an input stands for a scalar or a
list of scalars" (`:645`). So each preset of the families fixes the form, a `runner` in every
class, and a project that needs another condition copies the preset.

The decision this story takes, the reversible one (`AGENTS.md` § "Phase: implementation"): an
input type for the map, not a member of the binding beside `with`. A sixth variant of
`InputType`, `conditions`: an input of that type stands for a map from a target class to its
conditions, and a reference to it stands as the whole value of `observation.conditions` and
nowhere else. It is never a list, has no default, and only a preset declares one: an assessor
reads no plan's conditions as an input. A member of the binding was not taken: it would let a
binding change a plan of a preset the preset does not name as changeable.

## Acceptance

Every outcome below is observable without a `ratchet` command.

1. `spec/domains/specification.yaml`: `ratchet.specification.InputType` (`:728`) has the
   variant `conditions`, the comment above it (`:727`) names it, and
   `ratchet.specification.InputDeclaration` (`:732`) has the invariants
   `type != conditions` or `not defined(default)`, and `type != conditions` or
   `not defined(list)` or `list == false`. `ratchet.specification.InputReference` (`:794`) says
   where a `conditions` input stands. Checked by
   `ess specify validate --path spec --strict-requires`, which exits 0, and by
   `task check:generated`.
2. `spec/presets.test.sh`, rule `inputs`: a copy whose preset declares
   `conditions: {type: conditions, required: true}` and states
   `conditions: ${inputs.conditions}` under `observation` is accepted; before the story it is
   refused at `:645` ("an input stands for a scalar or a list of scalars"). A copy that refers
   to that input at `observation.conditions.all.runner` is refused with the message of `:651`
   (it takes `String`, and the input has the type `conditions`), and a copy whose declaration
   declares an input of the type `conditions` is refused with a message that names the input
   and says that only a preset declares one. The header of the rule `inputs` (`:41-53`) says both. The
   script's last line counts the new copies.
3. `presets/operation-time@2.preset.yaml`, made by `story:coverage-bound-on-failed-units` (16
   of the wave) and not released before 0.0.5, takes its conditions from the input
   `conditions` of the type `conditions` in place of the input `runner`; this story edits that
   @2 and makes no @3. `operation-time@1` stays byte for byte. Checked by
   `spec/presets.test.sh`, rules `place`, `type`, `inputs` and `row`: the last line counts the
   files and the measurements with a row it counted after 16.
4. Point 3 of "Not expressible yet" on `presets/latency.md` says that the input type
   `conditions` answers it from `operation-time@2` on and that the other presets of the family
   still fix their conditions until a version of their own takes the input; the points 3 of
   `presets/resources.md`, `presets/start.md`, `presets/code.md`, `presets/build.md` and
   `presets/artifact.md` say the same for their presets, each in its place, so the numbering
   of the points stays. Text only, no case.
5. `docs/design.md` § 4: the bullet "Inputs" (`:520`) names the type `conditions` of a preset
   input, and the paragraph of `${inputs.<name>}` (`:543`, "The type of the input fits the
   place") says where it stands. Text only, no case.
6. `CHANGELOG.md` has its line under `## [Unreleased]`. Text only, no case.

## Notes

- Decision taken: an input type, not a member of the binding (§ Context).
- An addition to a released format; a preset that uses it is a new version of the preset.
  `operation-time@2` is new in this wave, so this story extends it rather than adding @3.
- The command part, `ratchet validate` resolving a binding that passes the conditions and
  refusing a value that is no map from a class to conditions, is
  `story:plan-conditions-from-binding-in-ratchet`, which waits for the waves to 0.1.0
  (`story:cli-skeleton-validate`, `story:preset-binding-resolution`).
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of `.engineering/waves/0.1.0-ahead-2.md`,
  into one wave built in sequence on one branch: every planned wave starts behind
  `story:cli-skeleton-validate`, which waits for a release of ESS (beyond10x/ess#836), and this
  part needs no `ratchet` command. It is 21 of the 33 in the order of that page. Before it,
  `story:machine-as-a-condition` (20) adds four conditions to
  `ratchet.specification.ObservationConditions`, which a `conditions` input may then carry;
  `story:coverage-bound-on-failed-units` (16) makes `operation-time@2` and rewrites point 5 of
  `presets/latency.md`. After it, `story:member-for-some-input-values` (22) rewrites point 4 of
  the same pages and `story:input-allowed-values` (23) adds to `InputDeclaration` and to the
  bullet "Inputs" of § 4.
- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s; the new
  copies are timed before they are added, and a case shares a copy (`again`) where its defect
  stands apart.
