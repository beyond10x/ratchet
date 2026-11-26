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
revision: 20
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

Neither the phrase "input type `conditions`" nor `type: conditions` occurs in `presets/`,
`docs/` or `spec/` at `7b01ea1`.

1. `spec/domains/specification.yaml`: `ratchet.specification.InputType` reads `variants:
   [string, integer, decimal, boolean, path, conditions]`, and the comment above it names
   `conditions`. Check: `grep -c 'variants: \[string, integer, decimal, boolean, path,
   conditions\]' spec/domains/specification.yaml` prints 1 (0 before); `ess specify validate
   --path spec --strict-requires` exits 0 and `task check:generated` passes.
2. `ratchet.specification.InputDeclaration` has the invariants `type != conditions` or
   `not defined(default)`, and `type != conditions` or `not defined(list)` or `list == false`.
   Check: `grep -c '"type != conditions"' spec/domains/specification.yaml` prints 2 (0
   before).
3. The summary of `ratchet.specification.InputReference` holds the phrase "an input of the
   type `conditions` stands as the whole value of `observation.conditions`". Check: `grep -F`
   of that phrase in `spec/domains/specification.yaml` finds one line.
4. `presets/operation-time@2.preset.yaml`, made by `story:coverage-bound-on-failed-units` (16
   of the wave) and not released before 0.0.5, declares the input `conditions: {type:
   conditions, required: true}` and states `conditions: ${inputs.conditions}` under
   `observation`, in place of the input `runner`; this story edits that @2 and makes no @3.
   Check: `grep -c 'type: conditions' presets/operation-time@2.preset.yaml` prints 1, and
   `sh spec/presets.test.sh` exits 0 with the line `presets: <f> of <f> file(s) valid, ...`
   it printed after 16. The same file against the script of `7b01ea1` is refused with "an
   input stands for a scalar or a list of scalars".
5. `presets/operation-time@1.preset.yaml` stays byte for byte: `git diff --quiet 7b01ea1 --
   presets/operation-time@1.preset.yaml` exits 0.
6. `spec/presets.test.sh`, rule `inputs`: the case `conditions-input-at-a-scalar`, a copy that
   refers to the input `conditions` at `observation.conditions.all.runner`, is refused with
   the message "takes `String`, and the input `conditions` has the type `conditions`".
7. `spec/presets.test.sh`, rule `inputs`: the case `conditions-input-in-a-declaration`, a copy
   whose assessor declaration declares an input of the type `conditions`, is refused with a
   message that names the input and holds "only a preset declares an input of the type
   `conditions`". With item 6 the line `presets: <d> of <d> defect(s) refused with the
   message of their rule` counts 2 more than after unit 20.
8. The header of the rule `inputs` of `spec/presets.test.sh` says where a `conditions` input
   stands and that only a preset declares one. Check: `awk '/^#   inputs /,/^#   names /'
   spec/presets.test.sh | grep -c conditions` prints a number above 0 (0 before).
9. Point 3 of "Not expressible yet" on `presets/latency.md`, and the point 3 that repeats it on
   `presets/resources.md`, `presets/start.md`, `presets/code.md`, `presets/build.md` and
   `presets/artifact.md`, each in its place so the numbering of the points stays: the input
   type `conditions` answers it from `operation-time@2` on, and the other presets of the family
   still fix their conditions until a version of their own takes the input. Check: for each of
   the six pages `grep -c 'input type \`conditions\`'` prints a number above 0.
10. `docs/design.md` § 4, the bullet "Inputs" ("a type (string, integer, decimal, boolean,
    path, or a list of one of these)"), names the type `conditions` of a preset input. Check:
    `grep '^- \*\*Inputs\.\*\*' docs/design.md | grep -c conditions` prints 1 (0 before).
11. `docs/design.md` § 4, the paragraph that opens "`${inputs.<name>}` is the whole of a
    value", says that a reference to a `conditions` input stands as the whole value of
    `observation.conditions` and nowhere else. Check: `grep '^`\${inputs.<name>}` is the whole
    of a value' docs/design.md | grep -c 'observation.conditions'` prints 1 (0 before).

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
