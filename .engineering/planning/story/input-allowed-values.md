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
  path: docs/design.md
- confidence: inferred
  path: presets/code-lines@2.preset.yaml
- confidence: cited
  path: presets/code.md
- confidence: cited
  path: spec/domains/specification.yaml
- confidence: cited
  path: spec/presets.test.sh
revision: 15
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

1. `spec/domains/specification.yaml`: `ratchet.specification.InputDeclaration` has the member
   `values` (`Optional<List<String>>`). Check: `awk '/- name: ratchet.specification.InputDeclaration$/,/^  - name: ratchet.specification.InputReference$/'
   spec/domains/specification.yaml | grep -c 'name: values$'` prints 1 (0 before); `ess
   specify validate --path spec --strict-requires` exits 0 and `task check:generated` passes.
2. `InputDeclaration` has the invariant `not defined(values)` or `type == string`. Check: `grep
   -c '"not defined(values)", "type == string"' spec/domains/specification.yaml` prints 1.
3. The summary of `InputDeclaration.values` holds the phrase "a default is one of the
   values". Check: `grep -F` of that phrase in `spec/domains/specification.yaml` finds one
   line.
4. `spec/presets.test.sh`, rule `inputs`: the case `input-default-outside-values`, a preset
   input with `values: [lower, higher]` and `default: sideways`, is refused with a message that
   names the input and the values.
5. `spec/presets.test.sh`, rule `inputs`: the case `input-values-outside-enum`, an input with
   `values: [lower, sideways]` referred to at `better`, is refused with a message that names
   the input, the value `sideways` and the enum `ratchet.specification.Direction`.
6. `spec/presets.test.sh`, rule `assessor`: the case `plan-literal-outside-values`, a plan that
   passes a literal outside the `values` of an input of its assessor's declaration, is refused
   with a message that names the input and the values. With items 4 and 5 the line `presets:
   <d> of <d> defect(s) refused with the message of their rule` counts 3 more than after unit
   22.
7. The header of the rule `inputs` of `spec/presets.test.sh` says that a default and a value
   at the place of an enum are read against `values`, and that an input of the type `string`
   without `values` stays accepted at the place of an enum, as `code-lines@1` writes it.
   Check: `awk '/^#   inputs /,/^#   names /' spec/presets.test.sh | grep -c values` prints a
   number above 0 (0 before).
8. `presets/code-lines@2.preset.yaml` (new) declares `values: [lower, higher]` for
   `generated_better` and `handwritten_better` and refers to them at `better`. Check: `grep -c
   'values: \[lower, higher\]' presets/code-lines@2.preset.yaml` prints 2, and the line
   `presets: <f> of <f> file(s) valid, <r> of <r> measurement(s) with a row` of `sh
   spec/presets.test.sh` counts one more file and two more measurements with a row than after
   unit 22.
9. `presets/code-lines@1.preset.yaml` stays byte for byte: `git diff --quiet 7b01ea1 --
   presets/code-lines@1.preset.yaml` exits 0.
10. `presets/code.md` has an index row, a section `## \`code-lines@2\`` and the measurement rows
    `code-lines@2/lines/generated` and `code-lines@2/lines/handwritten` beside those of @1.
    Check: `grep -c '^## `code-lines@2`$' presets/code.md` prints 1 and `grep -c '^|
    `code-lines@2/lines/' presets/code.md` prints 2; rule `row` of `spec/presets.test.sh` holds
    the rows to the file (item 8).
11. Point 4 of "Not expressible yet" on `presets/code.md`, in its place, says that `values`
    answers it from `code-lines@2` on. Check: `awk '/^## Not expressible yet$/,0'
    presets/code.md | grep -c 'code-lines@2'` prints a number above 0 (0 before).
12. `docs/design.md` § 4, the bullet "Inputs", names `values`. Check: `grep '^- \*\*Inputs\.\*\*'
    docs/design.md | grep -c '`values`'` prints 1 (0 before).
13. `docs/design.md` § 4, the paragraph that opens "`${inputs.<name>}` is the whole of a
    value", says that an input with `values` stands for a value of a closed list only where
    each of its values is a value of that list. Check: `grep '^`\${inputs.<name>}` is the whole
    of a value' docs/design.md | grep -c '`values`'` prints 1 (0 before).

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
