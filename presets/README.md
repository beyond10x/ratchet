# The preset catalog

A preset is a reusable part of a quality specification: the assessments and requirements of one
concern, written once and bound by many projects. This directory is the catalog of presets that
Ratchet ships ([`docs/design.md`](../docs/design.md) § 2, § 4).

## What the directory holds

| File | What it is |
| --- | --- |
| `<name>@<version>.preset.yaml` | A preset: a `ratchet/1` document with a `preset` block |
| `<name>@<version>.assessor.yaml` | The `ratchet-assessor/1` declaration of an assessor that a preset names |
| `README.md` | This file |
| every other `*.md` | The page of one family of presets |

Pages:

- [functional.md](functional.md): conformance cases, differential equality against a reference
  implementation, the known-failure list.
- [latency.md](latency.md): the time of each operation, the time from a request to the event
  it causes, the requests answered per second.
- [resources.md](resources.md): resident memory, CPU seconds per 1000 requests, open file
  descriptors and threads while a workload runs.
- [start.md](start.md): process start to ready, ready to first answer.
- [operability.md](operability.md): the documented metric names a scrape exposes, the
  health and readiness answers.
- [build.md](build.md): the time of a cold and of a warm build, of the test step and of its
  slowest test, the share of flaky tests.
- [artifact.md](artifact.md): the size and the layers of a container image, the size of a
  binary, the number of dependencies, the advisories that apply to them.
- [code.md](code.md): generated and hand-written lines of code, the obligations a generator
  leaves, the findings of a linter.

A file is named by the name and the version it states, and neither holds an `@`. Nothing else
lies in the directory: no subdirectory, no symbolic link, no empty file and no entry whose name
starts with `.`. A file is UTF-8 and holds no NUL byte and no control character; every line, the
last one too, ends with a line feed, and a page may hold tabs. No file of the directory, YAML
or Markdown, holds one of these characters either:

- a control character of the range U+0080 to U+009F; the next line, U+0085, is one;
- the line separator U+2028 and the paragraph separator U+2029;
- the byte order mark U+FEFF, also not as the first character of a file;
- U+FFFE and U+FFFF, which are no characters;
- a character that hides or reorders text: U+200B, U+200E, U+200F, U+202A to U+202E, U+2060
  and U+2066 to U+2069.

A YAML 1.1 reader takes U+0085, U+2028 and U+2029 as the end of a line and would read a key
where another reader sees text. U+200C and U+200D are allowed: some writing systems are spelled
with them.

## What a preset is

A preset file holds `format: ratchet/1`, a `preset` block, and the maps `statements`,
`assessments` and `requirements`, with entries as a project writes them
(`ratchet.specification.Preset` and `ratchet.specification.PresetMember` in
[`spec/domains/specification.yaml`](../spec/domains/specification.yaml)).

- The `preset` block has a `name`, a `version` and the declared `inputs`. An input has a type
  (`string`, `integer`, `decimal`, `boolean` or `path`), may be a list, is required or has a
  default, and is never local.
- An entry refers to an input as `${inputs.<name>}`. The reference is the whole of a value. Inside
  `{...}` or `[...]` it is quoted, `"${inputs.<name>}"`. The spelling is the only one: a value
  that holds `${` or `{inputs.` and is not `${inputs.<name>}` alone, such as
  `${ inputs.report }` and `${{inputs.report}}`, is an error and no text. `<name>` is the key of
  the input, and a key may hold a `.`: `${inputs.a.b}` refers to the input `a.b`. In an assessor
  declaration `${` is text.
- A requirement names its assessment, its measurement and the statements it serves by their
  names, written out. A reference there is an error: the row
  `<name>@<version>/<assessment>/<measurement>` of a measurement cannot be checked against a
  name that the binding gives.
- A preset holds at least one requirement. A file with assessments alone gives a project
  nothing to bind.
- An entry states no `project`. The binding gives it one.
- A preset declares no subject, no gate, no exception and no binding of its own. The subject of
  a plan is an input, and which requirement blocks at which stage is the project's decision.

## How a file is written

A preset and a declaration are written in the part of YAML that `spec/presets.test.sh` reads.
A file in another form is refused, also where a YAML reader would accept it:

- A mapping is written by indentation, as `key:` and `key: value`, or on one line as
  `{key: value, ...}`.
- A list is a flow list on one line, `[a, b]`, also where [`docs/design.md`](../docs/design.md)
  shows a block list (`- a`).
- A key holds letters, digits, `_`, `.`, `@` and `-` and is not quoted. A key that YAML reads
  as a number, a boolean or null, such as `15` and `true`, is refused.
- A text is plain or stands between quotes of one kind. A text that holds a quote stands
  between quotes of the other kind. A text that holds both kinds of quote cannot be written in
  a catalog file, and neither can a backslash escape (`"\n"`), a folded or a literal scalar
  (`>`, `|`) and a text over two lines.
- A file holds no tab, no comment, no tag (`!!str`), no anchor and no document marker (`---`).

## Rules of the catalog

- **Tolerance.** An exact value (a count, a size in bytes, a set) has the tolerance 0. An exact
  count and a set have no input for it. A size may have a tolerance input with the default 0,
  for a project that accepts a small rise. A sampled value (a duration, memory, a rate, a count
  read while a service runs, such as its open file descriptors) has no default tolerance,
  because the format ships none: its preset declares the tolerance as a required input, and the
  page says so.
- **A value against a reference implementation.** A requirement compares a measurement with a
  fixed limit or with a protected reference, and not with another measurement. The catalog
  expresses a candidate against a reference implementation with what `ratchet/1` has. What that
  cannot say is named on the page of the family under "Not expressible yet". The catalog adds no
  key to the format.
- **Names.** A preset that covers a candidate of
  [`research/candidate-presets.md`](../research/candidate-presets.md) takes that candidate's
  name, as `conformance-cases@1` does.
- **Evidence.** A preset names an assessor that runs a command of the project or imports a
  report. Ratchet reimplements no tool: the catalog holds no load runner, no scanner and no
  profiler.
- **A row per measurement.** Every measurement of a preset has one row on the page of its
  family, under the header `| Measurement | Direction | Unit | Tolerance | Evidence |`, named
  `<name>@<version>/<assessment>/<measurement>`, and none of the four cells after the name is
  empty. The rows of one preset stand on one page. A table has one form. Its header line is
  written as above, with one space on each side of a word and no space before the first `|`; a
  header line that is padded or indented is not found. A row starts and ends with `|`; a table
  without the outer bars is not found. The first cell is the name between backticks and nothing
  else; a name that is a link is refused. A `|` inside a cell is written `\|`. A row inside a
  code fence or an HTML comment is no row, and a cell that holds only spaces, tabs, no-break
  spaces or an HTML comment is empty. A fence closes as CommonMark says: at a run of the
  character that opened it, at least as long, indented by at most three spaces, with nothing
  but spaces and tabs after it. `<!--` inside a code span that closes on its line opens no
  comment.
- **A measurement as its assessor declares it.** A measurement has the kind of the output it
  names, the unit of that output or none where the output has none, and a boundary and an
  identity key that the output declares. `run_time` and `queue_wait` are boundaries of Ratchet
  itself and stand also on an output that declares no boundaries. `pass_rate` aggregates an
  assertion and nothing else; the measurement of such a rate may be `sampled` and is compared
  as a number. An assessment passes every input its assessor requires, with the declared type,
  also for each item of a list, and names a target kind the assessor takes. A condition of an
  observation is `host_load_per_cpu`, `tools`, `runner` or one the assessor declares, and a
  field of a population filter is one of its `population_fields`. A value that an input gives
  is not checked against the declaration, because the binding passes it; only the kind of a
  target is checked against the default of its input.
- **A window over the runs of another plan.** `record-series@1` is the assessor of Ratchet
  itself that reads the runs of another plan ([`docs/design.md`](../docs/design.md) § 3, "A
  series of runs as a population"). The name is reserved: a plan names it without a
  declaration, and a file `record-series@1.assessor.yaml` in the directory is refused. A plan
  that names it has `observation.population.runs_of`, no `target.selection`, no
  `observation.conditions` and no `inputs`, and a plan with `runs_of` names it. Its
  measurements read the measurements of the source plan, which may be in another file, so the
  script joins them with no declaration; each still has its row on the page.
- **A comparison its value type allows.** A requirement compares its measurement as the table
  "Comparisons" of [`docs/design.md`](../docs/design.md) § 3 allows for the value type of the
  output: the operator, the `value`, the kind of the reference, `better` and the unit.
- **A sampled measurement.** What [`docs/design.md`](../docs/design.md) § 3 and § 5 say
  `ratchet validate` reports, the script refuses. The plan of a sampled measurement declares at
  least one condition under `observation.conditions`, unless it is a window over `runs_of`,
  which declares none. A requirement that compares a sampled measurement with an accepted value
  has a tolerance, with `percent` or `absolute`, and an `adoption`.
- **No text that is empty.** A member without a value is left out, not written as `""`.
- **No comment in a preset or a declaration.** A binding carries the digest of the preset file,
  so a reworded comment would be a new digest. What a file means is on the page. The script
  refuses a comment line and a comment after a value.
- **Generic examples.** No file names a consumer, a product or a customer. Examples are
  `service`, `orders-api` and `case-0042`.

`sh spec/presets.test.sh`, a step of `task check:spec`, checks every file of this directory
against the specification, against the declaration of its assessor and against the pages. Its
header says what it checks, and under "Not checked" it lists, each with its reason, every form
it accepts without a word: among them the invariants of the types beside the four of a plan
over `runs_of`, a value that an input gives where a rule reads the value, a measurement of a
plan of `record-series@1` against the source plan, the number of runs of an adoption from the
trusted revision, the prose of a row, and the forms that no sentence of the design forbids
outright, such as a percentile without its rank or `tolerance: {}` on an exact measurement. A
form the design forbids is refused, such as an exact measurement that aggregates with `median`
or an input of a declaration named `out`. No script
checks the rules "Tolerance", "A value against a reference implementation", "Names",
"Evidence" and "Generic examples".

## What the catalog does not ship

The catalog ships declarations and no program. A declaration such as
`conformance-report@1.assessor.yaml` says what an assessor takes and returns; the page of the
family says what each output holds. A project supplies the program that reads the report of its
own tool and writes the evidence, and says under `[tools]` of its `ratchet.toml` how the
`command` of the declaration is started on a machine
([`docs/evidence-format.md`](../docs/evidence-format.md) § 10).

## How a project binds a preset

In its specification, under a name of its own:

```yaml
presets:
  functional:
    use: conformance-cases@1
    digest: sha256:<digest of the preset file>
    with:
      subject: orders-api
      report: target/conformance/report.json
      environments: [ci]
```

- `use` is the name and the version of the preset.
- `digest` is the SHA-256 of the bytes of the preset file, as `sha256sum` prints it. A preset
  that is found with another digest is a validation error.
- `with` holds a value for every required input, and may hold one for an input with a default.

The entries of the preset join the project under the name of the binding: the requirement
`no-case-lost` is `functional.no-case-lost`, and a gate lists it like any other requirement.

```yaml
gates:
  merge:
    stage: pre-merge
    qualifying_environments: [ci]
    requires: [functional.no-case-lost, functional.failed-does-not-rise]
```

The local config says where the catalog is. A project reads it from a checkout of this
repository, as a directory relative to its root:

```toml
[catalog]
sources = [{ path = "vendor/ratchet/presets" }]
```

## Before `ratchet validate` resolves a binding

No command resolves a binding yet. A binding is valid `ratchet/1`, and nothing of the preset is
judged through it. Until a release says that `ratchet validate` resolves a binding from a
directory, a project that wants the requirements of a preset judged writes the entries into its
own specification, in place of the binding:

1. Copy the `assessments` and `requirements` of the preset file into the project's file.
2. Replace each `${inputs.<name>}` with the value the binding would pass.
3. Name each copied entry as the binding will name it, `<binding>.<entry>`, in the key and
   where a requirement names its `assessment`. A gate, and the reference record of a requirement
   under `ratchet/references/`, then keep their names when the binding replaces the copy.
4. Keep the declarations of the assessors the preset names where the local config finds them.
5. Note the commit of this repository the copy was taken from. The copy carries no digest, so
   nothing reports that the preset has changed since.

When a release resolves bindings, the project deletes the copied entries and writes the binding.
A copy and a binding with the same names in one specification are a duplicate id, which is a
validation error.
