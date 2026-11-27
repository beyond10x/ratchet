# The code family

How much of the code of a project is written by a generator and how much by hand, what does a
generator leave to the project, and what does a linter find? Three presets judge it from
reports the project's own tools write about a tree:

| Preset | What it judges | Evidence |
| --- | --- | --- |
| [`code-lines@1`](code-lines@1.preset.yaml) and [`code-lines@2`](code-lines@2.preset.yaml) | The generated and the hand-written lines of code; `@2` declares the values of the two inputs of the direction | An imported report of a line counter, [`line-count@1`](line-count@1.assessor.yaml) |
| [`generator-obligations@1`](generator-obligations@1.preset.yaml) | The pieces of work a code generator leaves to the project | An imported report of the generator, [`obligation-report@1`](obligation-report@1.assessor.yaml) |
| [`lint-findings@1`](lint-findings@1.preset.yaml) | The findings of a linter | An imported report of the linter, [`lint-report@1`](lint-report@1.assessor.yaml) |

Every measurement of the family is exact: a count of lines or a set. Its tolerance is 0, and
no preset of the family has an input for it. The family has no sampled value, so the sentence
of the runtime families on a required tolerance does not apply here.

The first release that evaluates a gate, 0.1.0, judges exact numbers and identity sets
([ROADMAP.md](../ROADMAP.md), "Releases"): that is every requirement of this family.

## How to read a row

A row is one measurement, named `<preset>/<assessment>/<measurement>`.

- **Direction** says which way is better. For a set it says what the set must not do.
- **Unit** is the unit the assessor declares for the output. A set has none.
- **Tolerance** is the band around the accepted value, and whether an input sets it.
- **Evidence** is the assessor and the output the value is read from.

A project that binds a preset under the name `lint` reads the requirement `no-new-finding` as
`lint.no-new-finding` ([README.md](README.md)).

## What the three presets share

Each preset holds one plan of the kind `snapshot`: its program reads one report that a tool of
the project wrote about the tree, and makes no run. Ratchet ships no line counter, no generator
and no linter. Each preset has these inputs:

| Input | Type | Required | What it is |
| --- | --- | --- | --- |
| `subject` | string | yes | The subject of the project that is judged, such as `service` |
| `report` | path | yes | The report of the tool, relative to the root of the tree |
| `environments` | list of string | yes | The target classes the plan runs in, such as `[ci]` |

## `code-lines@1`

The generated and the hand-written lines of code are counted apart, and neither number gets
worse than its accepted value. Which way is worse is the project's: one project wants its
hand-written code not to grow, another one wants more of its code to come from a generator,
and a third wants a generator that writes less. So the direction of each number is a required
input and has no default.

Its inputs beside the shared ones:

| Input | Type | Required | What it is |
| --- | --- | --- | --- |
| `generated_paths` | list of path | yes | The files and directories whose code is generated, relative to the root of the tree, such as `[src/generated]`. `[]` is valid |
| `generated_better` | string | yes | Which way is better for the generated lines: `lower` or `higher` |
| `handwritten_better` | string | yes | Which way is better for the hand-written lines: `lower` or `higher` |

| Measurement | Direction | Unit | Tolerance | Evidence |
| --- | --- | --- | --- | --- |
| `code-lines@1/lines/generated` | The input `generated_better`: lower or higher | `lines` | 0, no input | `line-count@1`, output `generated` |
| `code-lines@1/lines/handwritten` | The input `handwritten_better`: lower or higher | `lines` | 0, no input | `line-count@1`, output `handwritten` |

| Requirement | Measurement | Comparison | Judged by a release |
| --- | --- | --- | --- |
| `generated-lines-do-not-get-worse` | `generated` | With `lower`, not above the accepted value; with `higher`, not below it | 0.1.0: an exact number |
| `handwritten-lines-do-not-get-worse` | `handwritten` | With `lower`, not above the accepted value; with `higher`, not below it | 0.1.0: an exact number |

A `string` input stands here for a value of a closed list, the two of
`ratchet.specification.Direction` ([`docs/design.md`](../docs/design.md) § 4, "Presets").
The word a binding passes is read when the binding is resolved, and the script of the catalog
reads no binding ("Not expressible yet", point 4).

What the program of `line-count@1` returns for a run:

- It reads `report`: the files the line counter took as code, each with its path and its
  number of lines. Which files the counter takes, and which it leaves out as no code or as
  code of others, is its configuration, and a project keeps it the same.
- A line is a physical line: the number of line feeds of the file, and one more where the last
  byte of the file is no line feed. A blank line and a comment line count. A count of
  statements or of lines without comments depends on the counter and the language, and the
  preset would then judge the counter.
- A file is generated when `generated_paths` holds it, or holds a directory it lies under.
  A path there is a path and no pattern, and it is compared by whole parts between `/`:
  `src/gen` holds `src/gen/a.rs` and does not hold `src/generated/a.rs`. A `/` at the end of
  a path changes nothing: `src/gen/` is `src/gen`. A `./` at the start of a path is dropped,
  and the program refuses a list with a path that still holds a part `.` or `..`. Every other
  counted file is hand-written. A file is the one or the other as a whole: a file that a
  generator wrote in part is hand-written unless the list names it.
- `generated` is the sum of the lines of the generated files, and `handwritten` that of the
  others.
- Coverage, in the unit `file`: every file of the report is `executed`.

A requirement on one number does not see the other. A change that moves code from a generator
to hand-written files makes `handwritten` rise and `generated` fall, and with `lower` for both
it fails the first and tightens the second. The share of the generated lines in all lines is
no measurement of the preset ("Not expressible yet", point 2).

```yaml
presets:
  lines:
    use: code-lines@1
    digest: sha256:<digest of the preset file>
    with:
      subject: service
      report: target/lines/report.json
      generated_paths: [src/generated]
      environments: [ci]
      generated_better: lower
      handwritten_better: lower
```

## `code-lines@2`

`code-lines@1` whose two inputs of the direction declare the values they may have:
`generated_better` and `handwritten_better` each state `values: [lower, higher]`, the two of
`ratchet.specification.Direction` ([`docs/design.md`](../docs/design.md) § 4, "Custom
assessors"). The preset file then says which words a binding may pass, and a binding that
passes another word is refused at the input, when a command resolves the binding, and not
where the value is used. The script of the catalog reads each of the values against the
values of `better`. The other inputs, the requirements, the program of
`line-count@1` and the binding are those of `code-lines@1`, with `use: code-lines@2`. The
file `@1` stays as it was released.

| Input | Type | Required | What it is |
| --- | --- | --- | --- |
| `generated_better` | string, `values: [lower, higher]` | yes | Which way is better for the generated lines |
| `handwritten_better` | string, `values: [lower, higher]` | yes | Which way is better for the hand-written lines |

| Measurement | Direction | Unit | Tolerance | Evidence |
| --- | --- | --- | --- | --- |
| `code-lines@2/lines/generated` | The input `generated_better`: one of its values, lower or higher | `lines` | 0, no input | `line-count@1`, output `generated` |
| `code-lines@2/lines/handwritten` | The input `handwritten_better`: one of its values, lower or higher | `lines` | 0, no input | `line-count@1`, output `handwritten` |

## `generator-obligations@1`

A code generator that cannot write the whole of a program says what it leaves to the project:
a handler to write by hand, a type it could not map, a part of the specification it does not
support. Each such piece of work is an obligation. The generator leaves no obligation that the
accepted set does not hold.

The preset has the shared inputs and no other.

| Measurement | Direction | Unit | Tolerance | Evidence |
| --- | --- | --- | --- | --- |
| `generator-obligations@1/obligations/obligations` | Lower: the set gains no item | None: a set of obligation ids | 0, no input | `obligation-report@1`, output `obligations` |

| Requirement | Measurement | Comparison | Judged by a release |
| --- | --- | --- | --- |
| `no-new-obligation` | `obligations` | `no_new_items` against the accepted set | 0.1.0: an exact set |

What the program of `obligation-report@1` returns for a run:

- It reads `report`: the obligations the generator reported for the tree, each with an id.
- `obligations` holds one item per obligation, with the id under `obligation_id`. The id is
  the one the generator gives, in the same spelling in every run. It names what is left and
  where in the specification of the project, such as `handler:orders.create`, and no line of
  a generated file: a line moves when the generator changes, and the obligation would be a new
  item.
- A report without an obligation gives the empty set, which is a complete result
  ([`docs/evidence-format.md`](../docs/evidence-format.md) § 4, rule 8).
- Coverage, in the unit `obligation`: every obligation of the report is `executed`.

The preset judges what the generator reports. A generator that leaves work and does not say
so gives no item, and the preset does not see it. An obligation that the project has done by
hand and that the generator still reports stays an item: the set is the generator's.

```yaml
presets:
  generator:
    use: generator-obligations@1
    digest: sha256:<digest of the preset file>
    with:
      subject: service
      report: target/generator/obligations.json
      environments: [ci]
```

## `lint-findings@1`

The linter reports no finding that the accepted set does not hold. A project with old findings
adopts them once and is then held to no new one
([`docs/design.md`](../docs/design.md) § 4: a total count alone can let a new finding hide
behind the removal of another).

The preset has the shared inputs and no other.

| Measurement | Direction | Unit | Tolerance | Evidence |
| --- | --- | --- | --- | --- |
| `lint-findings@1/lint/findings` | Lower: the set gains no item | None: a set of findings | 0, no input | `lint-report@1`, output `findings` |

| Requirement | Measurement | Comparison | Judged by a release |
| --- | --- | --- | --- |
| `no-new-finding` | `findings` | `no_new_items` against the accepted set | 0.1.0: an exact set |

The identity of a finding decides what "new" means. A finding named by its line number would
be a new item whenever a line is added above it, and every such change would fail. The
identity of this preset therefore holds no line number. It has four fields:

- `rule` is the id of the rule as the linter names it.
- `path` is the path of the file, relative to the root of the tree, with `/` between its
  parts. A finding about no file has the path `.`.
- `line_text` is the text of the first line the finding points at, without the blanks at its
  start and its end. A line ends before its line feed, and a carriage return before the line
  feed is no part of the text, so a file with CRLF line ends gives the same text.
- `occurrence` says which of several findings it is that agree in the three fields above:
  `1` for the first, `2` for the next. The order is from the top of the file, and on one line
  by the column. Where the report has no column, or two findings have the same one, the order
  is that of their messages, sorted by their bytes. Two findings that agree in the message
  too are alike, and which of them is the first changes no set. The order in which a report
  lists its findings decides nothing.

Three cases of the place:

- A finding with several locations stands at its primary one, as the linter marks it. Where
  the linter marks none, it stands in the path that comes first when the paths of its
  locations are sorted by their bytes, and there at the lowest line.
- A finding about a file and no line has the empty `line_text` and no `line` among its item
  fields. Among the findings of its file with the same rule and the empty text it comes
  before every finding on a blank line.
- A finding about no file has the path `.` and the empty `line_text`.

So a finding stays the same item when lines above it are added or removed. It becomes a new
item when its own line is edited, when its file is renamed, and when a finding with the same
rule and the same text appears above it in the file. The first two are changes to the place
of the finding, and a project accepts the item again or removes the finding.

What the program of `lint-report@1` returns for a run:

- It reads `report`: the files the linter checked, those it could not read, and its findings.
- `findings` holds one item per finding, with the identity above. The item fields `severity`,
  `line` and `message` hold what the linter reports, so that a result names the place as the
  tree has it. No requirement of the preset reads them: every severity is judged.
- A report without a finding gives the empty set, which is a complete result.
- Coverage, in the unit `file`: a file the linter checked is `executed`, and one it could not
  read or parse is `unsupported`. The plan declares `unsupported: {max: 0}`, so a report with
  such a file is insufficient evidence, with the cause `coverage_below_plan`.

A finding that is silenced in the code or in the configuration of the linter is not in the
report, and the preset does not see it. The accepted set is the place for a finding that a
project keeps, with its reason and its owner
([`docs/design.md`](../docs/design.md) § 5, "Protected references"). The rules that are
switched on and the version of the linter decide the set too, and a project that changes them
adopts the set again ("Not expressible yet", point 3).

```yaml
presets:
  lint:
    use: lint-findings@1
    digest: sha256:<digest of the preset file>
    with:
      subject: service
      report: target/lint/report.json
      environments: [ci]
```

## Candidate against a reference implementation

The rule is that of [`docs/design.md`](../docs/design.md) § 4, "A candidate against a
reference implementation". The three presets judge the tree of one implementation, so a
project binds a preset once per implementation, each with its own subject and report, and each
is judged against its own accepted values. "The candidate needs no more hand-written lines
than the reference implementation" is not said by that: the first two points below.

## Not expressible yet

What the family needs and `ratchet/1` or `ratchet-assessor/1` cannot say. The catalog adds no
key to a format; each point names the place in the specification
([`spec/domains/`](../spec/domains/)) that lacks it.

1. **A reference adopted from the evidence of another plan.** The accepted number of
   hand-written lines of the candidate should be that of the reference implementation.
   Answered in the format: `ratchet.specification.AdoptionSource` has the value `assessment`,
   and `ratchet.specification.RatchetPolicy` names the plan and the measurement of the same
   specification that the value is adopted from
   ([functional.md](functional.md), "Not expressible yet", point 1). No preset of the family
   holds a plan of the reference implementation, so none adopts from one yet.
2. **A requirement over two measurements.** "At least half of the lines are generated"
   compares two measurements. Answered in the format:
   `ratchet.specification.Condition.against` names the second
   ([functional.md](functional.md), point 2), so `generated` with `gte` against `handwritten`
   in the unit `lines` states it, from the two numbers `line-count@1` returns. Neither
   `code-lines@1` nor `code-lines@2` holds that requirement, and a version that does is not
   written.
3. **The conditions of a plan as an input.** As for the latency family
   ([latency.md](latency.md), "Not expressible yet", point 3): up to `operation-time@1` an input
   stood for a scalar or a list of scalars and for no map, so a binding could not pass the
   version of the linter or of the generator as the condition `tools`.
   The input type `conditions` answers it from `operation-time@2` on, as the whole value of
   `observation.conditions`. The presets of this family still fix their conditions, none,
   until a version of their own takes the input.
4. **The values an input may have.** `generated_better` and `handwritten_better` take `lower`
   or `higher`. Up to `code-lines@1`, `ratchet.specification.InputDeclaration` had a type and
   no list of the values an input may have, so the preset file does not say which words a
   binding may pass, and a wrong word is found where the value is used and not at the input.
   Answered from `code-lines@2` on: `InputDeclaration.values` lists them, `[lower, higher]`,
   and a binding that passes another word is refused at the input. `code-lines@1` stays as it
   was released.
