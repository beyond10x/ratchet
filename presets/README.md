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

A file is named by the name and the version it states. Nothing else lies in the directory, and it
has no subdirectory.

## What a preset is

A preset file holds `format: ratchet/1`, a `preset` block, and the maps `statements`,
`assessments` and `requirements`, with entries as a project writes them
(`ratchet.specification.Preset` and `ratchet.specification.PresetMember` in
[`spec/domains/specification.yaml`](../spec/domains/specification.yaml)).

- The `preset` block has a `name`, a `version` and the declared `inputs`. An input has a type
  (`string`, `integer`, `decimal`, `boolean` or `path`), may be a list, is required or has a
  default, and is never local.
- An entry refers to an input as `${inputs.<name>}`. The reference is the whole of a value. Inside
  `{...}` or `[...]` it is quoted, `"${inputs.<name>}"`.
- An entry states no `project`. The binding gives it one.
- A preset declares no subject, no gate, no exception and no binding of its own. The subject of
  a plan is an input, and which requirement blocks at which stage is the project's decision.

## Rules of the catalog

- **Tolerance.** An exact value (a count, a size in bytes, a set) has the tolerance 0. A count
  and a set have no input for it. A size may have a tolerance input with the default 0, for a
  project that accepts a small rise. A sampled value (a duration, memory, a rate) has no default
  tolerance, because the format ships none: its preset declares the tolerance as a required
  input, and the page says so.
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
  empty. The rows of one preset stand on one page.
- **No comment in a preset or a declaration.** A binding carries the digest of the preset file,
  so a reworded comment would be a new digest. What a file means is on the page.
- **Generic examples.** No file names a consumer, a product or a customer. Examples are
  `service`, `orders-api` and `case-0042`.

`sh spec/presets.test.sh`, a step of `task check:spec`, checks every file of this directory
against the specification and against the pages. Its header says what it checks and what it
does not.

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
