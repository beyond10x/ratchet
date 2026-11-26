---
format: aep.planning-md/3
id: story:input-allowed-values
kind: story
status: draft
title: An input of a preset declares the values it may have
summary: An input has a type and no list of values, so a wrong direction word is found where it is used.
relations:
- decomposes: epic:preset-catalog
- depends_on: story:preset-catalog-factory
scope:
- confidence: cited
  path: CHANGELOG.md
- confidence: cited
  path: docs/design.md
- confidence: inferred
  path: presets/code-lines@2.preset.yaml
- confidence: cited
  path: presets/code.md
- confidence: cited
  path: spec/domains/specification.yaml
- confidence: cited
  path: spec/presets.test.sh
revision: 13
---
## Context

The entry "The values an input may have" under "Not expressible yet" on `presets/code.md`
(point 4, `:262-265`, `story:preset-catalog-factory`). First consumer: the catalog, and every
project that binds `code-lines@1`. Line numbers are those of `7b01ea1`.

Neither more nor fewer generated lines is better for every project, so `code-lines@1` takes
the direction of its two counts from the binding: the inputs `generated_better` and
`handwritten_better` (`presets/code-lines@1.preset.yaml:11-12`) hold `lower` or `higher`, and
`better` of each measurement is a reference to one (`:33`, `:39`).
`ratchet.specification.InputDeclaration` has a type, `list`, `required`, `default` and `local`
and no list of the values an input may have (`spec/domains/specification.yaml:732-767`). An
input of the type `string` stands for text and for a value of a closed list
(`ratchet.specification.InputReference`, `:794`; `docs/design.md:543`), and
`spec/presets.test.sh` accepts it at the place of an enum without reading a value (`:650`).
So the preset file does not say which words a binding may pass, and a wrong word is found where
the value is used and not at the input.

The decision this story takes, the reversible one (`AGENTS.md` § "Phase: implementation"): a
member `values` of `InputDeclaration`, a list of text, valid on an input of the type `string`
(each item of a list input is one of them). Not an input type per closed list of the format: a
type per list would tie the input types to the enums of `ratchet/1`, and an assessor's input
with values of its own (a mode of its tool) could not use it.

## Acceptance

Every outcome below is observable without a `ratchet` command.

1. `spec/domains/specification.yaml`: `ratchet.specification.InputDeclaration` (`:732`) has
   the member `values` (`Optional<List<String>>`) with the invariant `not defined(values)` or
   `type == string`; its summary says that a binding or a plan passes one of the values, and a
   default is one of them. Checked by `ess specify validate --path spec --strict-requires`,
   which exits 0, and by `task check:generated`.
2. `spec/presets.test.sh`, rule `inputs`: a default that is none of the `values` of its input is
   refused with a message that names the input and the values (beside the default check of
   `:1028-1034`); a reference to an input with `values` at the place of an enum is refused when
   a value is no variant of that enum, naming the input, the value and the enum; a literal that
   a plan passes to an input of a declaration with `values` (rule `assessor`) is refused when it
   is none of them. Each is a broken copy refused with the message of its rule. A copy whose
   input `generated_better` declares `values: [lower, higher]` and is referred to at `better` is
   accepted. An input of the type `string` without `values` stays accepted at the place of an
   enum, as `code-lines@1` writes it. The header of the rule (`:41-53`) says what is read.
3. `presets/code-lines@2.preset.yaml` (new) declares `values: [lower, higher]` for
   `generated_better` and `handwritten_better`; `code-lines@1` stays byte for byte.
   `presets/code.md` has the index row (`:9`), a section and the rows of
   `code-lines@2/lines/generated` and `code-lines@2/lines/handwritten` beside those of @1
   (`:62-63`), and its point 4 (`:262-265`) says that `values` answers it from `code-lines@2`
   on. Checked by `spec/presets.test.sh`, rules `place`, `type`, `inputs` and `row`: its last
   line counts one more preset and two more measurements with a row.
4. `docs/design.md` § 4: the bullet "Inputs" (`:520`) names `values`, and the paragraph of
   `${inputs.<name>}` (`:543`) says that an input with `values` stands for a value of a closed
   list only where each of its values is a value of that list. Text only, no case.
5. `CHANGELOG.md` has its line under `## [Unreleased]`. Text only, no case.

## Notes

- Decision taken: a member `values` of the declaration (§ Context).
- An addition to a released format; a preset that uses it is a new version of the preset. A
  declaration of an assessor may use it too; none of the catalog does in this story.
- The command part, `ratchet validate` refusing a binding or a plan that passes another value
  and naming the input and the allowed values, is `story:input-allowed-values-in-ratchet`,
  which waits for the waves to 0.1.0 (`story:cli-skeleton-validate`,
  `story:preset-binding-resolution`).
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of `.engineering/waves/0.1.0-ahead-2.md`,
  into one wave built in sequence on one branch: every planned wave starts behind
  `story:cli-skeleton-validate`, which waits for a release of ESS (beyond10x/ess#836), and this
  part needs no `ratchet` command. It is 23 of the 33 in the order of that page. Before it,
  `story:plan-conditions-from-binding` (21) adds the input type `conditions`, two invariants of
  `InputDeclaration`, a rule of `spec/presets.test.sh` and the same two places of § 4, and
  rewrites point 3 of `presets/code.md`; `values` is valid on `string` alone, so it does not
  reach a `conditions` input.
- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s; the new
  broken copies are timed before they are added, and a case shares a copy (`again`) where its
  defect stands apart.
