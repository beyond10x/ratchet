# The artifact family

How large is what a project ships, how much does it depend on, and which published advisories
apply to what it depends on? Four presets judge it from what the project's own tools write
about a build:

| Preset | What it judges | Evidence |
| --- | --- | --- |
| [`image-size@1`](image-size@1.preset.yaml) | The size of a container image and the number of its layers | An imported inspection of the image, [`image-inspection@1`](image-inspection@1.assessor.yaml) |
| [`binary-size@1`](binary-size@1.preset.yaml) and [`binary-size@2`](binary-size@2.preset.yaml) | The size of one built file | The file itself, [`file-size@1`](file-size@1.assessor.yaml); `@2` names [`file-size@2`](file-size@2.assessor.yaml), which reads it as a target of the kind `build` |
| [`dependency-count@1`](dependency-count@1.preset.yaml) | The number of dependencies the project names, and the number its resolved graph holds | An imported dependency graph, [`dependency-graph@1`](dependency-graph@1.assessor.yaml) |
| [`dependency-advisories@1`](dependency-advisories@1.preset.yaml) | The published advisories that apply to a dependency | An imported report of an advisory scan, [`advisory-report@1`](advisory-report@1.assessor.yaml) |

Every measurement of the family is exact: a size in bytes, a count or a set. Its tolerance is
0. A count and a set have no input for it. Each of the two sizes has a tolerance input with
the default 0, for a project that accepts a small rise. The family has no sampled value, so
the sentence of the runtime families on a required tolerance does not apply here.

The first release that evaluates a gate, 0.1.0, judges exact numbers and identity sets, with an
absolute or percent tolerance ([ROADMAP.md](../ROADMAP.md), "Releases"): that is every
requirement of this family.

## How to read a row

A row is one measurement, named `<preset>/<assessment>/<measurement>`.

- **Direction** says which way is better. For a set it says what the set must not do.
- **Unit** is the unit the assessor declares for the output. A set has none.
- **Tolerance** is the band around the accepted value, and whether an input sets it.
- **Evidence** is the assessor and the output the value is read from.

A project that binds a preset under the name `image` reads the requirement
`size-does-not-rise` as `image.size-does-not-rise` ([README.md](README.md)).

## What the four presets share

Each preset holds one plan of the kind `snapshot`: its program reads one file that a tool of
the project wrote, and makes no run. The target of each plan has the kind `revision`. What is
judged is a thing built from the revision, and which build wrote it is the project's: the build
profile, the target platform, whether debug information stays in. A project keeps that the same
between an adoption and the runs that are compared with it; no preset of the family can
declare it ("Not expressible yet", points 3 and 4).

Each preset has these inputs:

| Input | Type | Required | What it is |
| --- | --- | --- | --- |
| `subject` | string | yes | The subject of the project that is judged, such as `service` |
| `environments` | list of string | yes | The target classes the plan runs in, such as `[ci]` |

## `image-size@1`

The size of the container image does not rise above the accepted size by more than the
tolerance, and the image gets no more layers.

Its inputs beside the shared ones:

| Input | Type | Required | What it is |
| --- | --- | --- | --- |
| `inspection` | path | yes | The inspection of the image as the tool of the project wrote it: the manifest of the image, or the index of an image for several platforms with the manifest of each. Relative to the root of the tree |
| `platform` | string | yes | The platform whose image is judged, as operating system and architecture, such as `linux/amd64`, with the variant as a third part where the index states one for that platform, such as `linux/arm/v7` |
| `size_tolerance_bytes` | integer | no, default `0` | The band of `size`, in bytes |

| Measurement | Direction | Unit | Tolerance | Evidence |
| --- | --- | --- | --- | --- |
| `image-size@1/image/size` | Lower | `bytes` | The input `size_tolerance_bytes`, absolute; default 0 | `image-inspection@1`, output `size` |
| `image-size@1/image/layers` | Lower | `layers` | 0, no input | `image-inspection@1`, output `layers` |

| Requirement | Measurement | Comparison | Judged by a release |
| --- | --- | --- | --- |
| `size-does-not-rise` | `size` | Not above the accepted value by more than the tolerance | 0.1.0: an exact number |
| `layers-do-not-rise` | `layers` | Not above the accepted value | 0.1.0: an exact number |

What the program of `image-inspection@1` returns for a run:

- It reads `inspection`. From an index it takes the manifest whose platform equals `platform`
  in every part: the operating system, the architecture, and the variant where the index
  states one. It refuses an index that holds no such manifest, and one that holds two.
- An inspection that is a single manifest names no platform. The program takes that manifest
  and cannot check it against `platform`, which is then the word of the binding.
- `size` is the sum of the sizes of the layers as that manifest states them: the size of each
  layer as it is stored and transferred, which for a compressed layer is its compressed size.
  The configuration of the image and the manifest are not counted. The size of the image
  unpacked on a disk is another number, and no output holds it.
- `layers` is the number of layer entries of that manifest. Every entry counts, also an empty
  layer and a layer that the image shares with its base image: the manifest does not say which
  layers a base image brought.
- A layer that the manifest lists twice counts twice in both numbers.
- Coverage, in the unit `image`: the image of the platform that was read is `executed`.
- It writes the digest of that manifest under `target.identifiers.artifact_digest`
  ([`docs/evidence-format.md`](../docs/evidence-format.md) § 3).

A project that ships an image for several platforms binds the preset once per platform, each
under a name of its own.

```yaml
presets:
  image:
    use: image-size@1
    digest: sha256:<digest of the preset file>
    with:
      subject: service
      inspection: target/image/inspection.json
      platform: linux/amd64
      environments: [ci]
      size_tolerance_bytes: 1048576
```

The numbers of this binding are illustrations and no recommendation.

## `binary-size@1`

The size of one built file, such as the executable of a service or a library a project ships,
does not rise above the accepted size by more than the tolerance.

Its inputs beside the shared ones:

| Input | Type | Required | What it is |
| --- | --- | --- | --- |
| `binary` | path | yes | The built file, relative to the root of the tree |
| `tolerance_bytes` | integer | no, default `0` | The band, in bytes |

| Measurement | Direction | Unit | Tolerance | Evidence |
| --- | --- | --- | --- | --- |
| `binary-size@1/binary/size` | Lower | `bytes` | The input `tolerance_bytes`, absolute; default 0 | `file-size@1`, output `size` |

| Requirement | Measurement | Comparison | Judged by a release |
| --- | --- | --- | --- |
| `size-does-not-rise` | `size` | Not above the accepted value by more than the tolerance | 0.1.0: an exact number |

What the program of `file-size@1` returns for a run:

- It reads `binary`, one regular file, and refuses a directory. A symbolic link is followed.
- `size` is the length of the file in bytes: the number of bytes a reader gets, and not the
  space the file takes on a disk.
- Coverage, in the unit `file`: the file that was read is `executed`.
- It writes the SHA-256 of the file under `target.identifiers.artifact_digest`.

The preset judges one file. A project that ships several binds it once per file, each under a
name of its own. The same build of one revision may give two sizes where the build tool is not
reproducible to the byte; a project with such a tool sets `tolerance_bytes` above the
difference it sees between two builds of one revision.

```yaml
presets:
  binary:
    use: binary-size@1
    digest: sha256:<digest of the preset file>
    with:
      subject: service
      binary: target/release/service
      environments: [ci]
      tolerance_bytes: 4096
```

## `binary-size@2`

`binary-size@1` whose plan names a target of the kind `build`, and the assessor
`file-size@2`. That declaration takes `targets: [build]` and names its input `binary` as
`target_input`, the path of the artifact
([`docs/evidence-format.md`](../docs/evidence-format.md) § 10, "Invocation"). Ratchet passes
`--revision`, the revision the artifact was built from, and the program writes it as
`target.revision`, the SHA-256 of the file as `candidate` and under
`target.identifiers.artifact_digest`, and does not repeat the file under `inputs`
([`docs/evidence-format.md`](../docs/evidence-format.md) § 6, example 9). The inputs, the
requirement, what the program measures and the binding are those of `binary-size@1`, with
`use: binary-size@2`. The files `@1` stay as they were released.

That the file was built from that revision is the project's statement: the binding names a
path that its build at that revision writes. Nothing reads a record of the build or a pinned
digest of the file.

| Measurement | Direction | Unit | Tolerance | Evidence |
| --- | --- | --- | --- | --- |
| `binary-size@2/binary/size` | Lower | `bytes` | The input `tolerance_bytes`, absolute; default 0 | `file-size@2`, output `size`, of the target of the kind `build` |

## `dependency-count@1`

The project names no more dependencies than before, and its resolved dependency graph holds no
more.

Its input beside the shared ones:

| Input | Type | Required | What it is |
| --- | --- | --- | --- |
| `graph` | path | yes | The resolved dependency graph of the project as its package tool writes it: every package with its name, its version and the packages it depends on, and the list of its roots, the packages the graph was resolved for. Relative to the root of the tree |

| Measurement | Direction | Unit | Tolerance | Evidence |
| --- | --- | --- | --- | --- |
| `dependency-count@1/dependencies/direct` | Lower | `dependencies` | 0, no input | `dependency-graph@1`, output `direct` |
| `dependency-count@1/dependencies/transitive` | Lower | `dependencies` | 0, no input | `dependency-graph@1`, output `transitive` |

| Requirement | Measurement | Comparison | Judged by a release |
| --- | --- | --- | --- |
| `direct-does-not-rise` | `direct` | Not above the accepted value | 0.1.0: an exact number |
| `transitive-does-not-rise` | `transitive` | Not above the accepted value | 0.1.0: an exact number |

What the program of `dependency-graph@1` returns for a run:

- It reads `graph`. A package of the project itself is a root of the graph: a package the
  graph was resolved for, such as each member of a workspace. A root is no dependency, and
  every other package of the graph is one. Where a package lies decides nothing: a package
  that is copied into the tree and that a root names by its path is a dependency, unless the
  project makes it a root. The program refuses a graph that names no root.
- A dependency is a name and a version. One name in two versions is two dependencies. One name
  and version that the graph holds from two sources is one.
- Every edge of the graph counts, whatever it is for: a dependency of the running program, of
  the build, of the tests, and an optional one that the resolution selected. So do the
  dependencies of every platform the graph holds. A graph that the package tool wrote for one
  platform or without the dependencies of the tests gives smaller numbers, and a project keeps
  the way the graph is written the same.
- `direct` is the number of dependencies that a package of the project names.
- `transitive` is the number of all dependencies of the graph, the direct ones among them. A
  direct dependency is in both numbers, so `transitive` is never below `direct`.
- Coverage, in the unit `package`, a name and a version: every package of the graph that was
  read is `executed`, the roots among them.
- It writes the digest of the lock file under `target.identifiers.lockfile` where the graph
  comes from one.

The two requirements see different changes. A change that adds one direct dependency with
forty of its own moves `direct` by one and `transitive` by forty-one. A change that raises the
version of a dependency may move `transitive` alone. A dependency that replaces another keeps
both numbers, and neither requirement sees it: the preset counts, and holds no set of names.

```yaml
presets:
  dependencies:
    use: dependency-count@1
    digest: sha256:<digest of the preset file>
    with:
      subject: service
      graph: target/dependencies/graph.json
      environments: [ci]
```

## `dependency-advisories@1`

No published advisory applies to a dependency of the project that the accepted set does not
hold. Ratchet ships no scanner and no advisory database: the scan is a tool of the project.

Its inputs beside the shared ones:

| Input | Type | Required | What it is |
| --- | --- | --- | --- |
| `report` | path | yes | The report of the advisory scan of the resolved dependencies, relative to the root of the tree |
| `unchecked_packages_max` | integer | no, default `0` | The most packages the scan may have been unable to check, such as a package from a source its database does not cover |

| Measurement | Direction | Unit | Tolerance | Evidence |
| --- | --- | --- | --- | --- |
| `dependency-advisories@1/scan/advisories` | Lower: the set gains no item | None: a set of pairs of an advisory and a package | 0, no input | `advisory-report@1`, output `advisories` |

| Requirement | Measurement | Comparison | Judged by a release |
| --- | --- | --- | --- |
| `no-new-advisory` | `advisories` | `no_new_items` against the accepted set | 0.1.0: an exact set |

What the program of `advisory-report@1` returns for a run:

- It reads `report`: the packages the scan checked, those it could not check, and the
  advisories it found.
- `advisories` holds one item per pair of an advisory and a package it applies to. The
  identity of an item is the id of the advisory under `advisory` and the name of the package
  under `package`.
  - The id is one of the ids the scanner reports for the advisory, its own and every alias:
    the one that comes first when they are sorted by their bytes, such as `ADV-2026-0042`. The
    order in which a scanner lists them decides nothing. An alias is another id of the same
    flaw. Another id of the same advisory is no item, and two entries of a report that share
    an id of one flaw are one advisory with the ids of both. An id that covers several flaws,
    such as the id of a bulletin, is no alias: it merges nothing and is no id of an item.
    When a database later gives an advisory an id that sorts before the others, the item has
    a new identity and is a new item once.
  - The version of the package is no part of the identity. A package that the graph holds in
    two versions an advisory applies to is one item, and a raised version that the advisory
    still applies to keeps the item.
  - An advisory that applies to two packages is two items.
- The item fields `severity` and `versions` hold what the scanner reports as the severity and
  the versions of the package that the advisory applies to. No requirement of the preset reads
  them.
- A scan that finds nothing gives the empty set, which is a complete result
  ([`docs/evidence-format.md`](../docs/evidence-format.md) § 4, rule 8).
- Coverage, in the unit `package`, a name and a version as `dependency-graph@1` counts it: a
  package the scan checked is `executed`, and one it could not check is `unsupported`. One
  name in two versions is two units, also where the identity of an item holds the name
  alone. The plan bounds `unsupported` by `unchecked_packages_max`; a scan above it is
  insufficient evidence, with the cause `coverage_below_plan`.

The set is read against the advisory database as it is at the scan. An advisory that is
published for a dependency that did not change is a new item, and the requirement fails for a
change that touched no dependency. That is what the criterion says: the tree has an advisory
that was not accepted. The date of the database is not in the evidence as a condition
("Not expressible yet", point 3).

An advisory that the project accepts is an item of the accepted set, with its reason and its
owner ([`docs/design.md`](../docs/design.md) § 5, "Protected references"). An advisory that the
scanner is told to leave out is not in the report, and the preset does not see it.

```yaml
presets:
  advisories:
    use: dependency-advisories@1
    digest: sha256:<digest of the preset file>
    with:
      subject: service
      report: target/dependencies/advisories.json
      environments: [ci]
```

## Candidate against a reference implementation

The rule is that of [`docs/design.md`](../docs/design.md) § 4, "A candidate against a
reference implementation". A project binds a preset once per implementation, each with its own
subject and files, and each implementation is judged against its own accepted values. "The
image of the candidate is no larger than the image of the reference implementation" is not
said by that: the first two points below.

## Not expressible yet

What the family needs and `ratchet/1` or `ratchet-assessor/1` cannot say. The catalog adds no
key to a format; each point names the place in the specification
([`spec/domains/`](../spec/domains/)) that lacks it.

1. **A reference adopted from the evidence of another plan.** The accepted size of the
   candidate should be the size of the reference implementation. Answered in the format:
   `ratchet.specification.AdoptionSource` has the value `assessment`, and
   `ratchet.specification.RatchetPolicy` names the plan and the measurement of the same
   specification that the value is adopted from
   ([functional.md](functional.md), "Not expressible yet", point 1). No preset of the family
   holds a plan of the reference implementation, so none adopts from one yet.
2. **A requirement over two measurements.** "The image is at most twice the size of the
   binary it holds" compares two measurements. `ratchet.specification.Condition.against`
   names the second and compares the two as they are, with no factor
   ([functional.md](functional.md), point 2): it states "the image is not larger than the
   binary" and not "at most twice".
3. **The conditions of a plan as an input.** As for the latency family
   ([latency.md](latency.md), "Not expressible yet", point 3): up to `operation-time@1` an input
   stood for a scalar or a list of scalars and for no map, so a binding cannot pass the tools
   that decide a size, such as the version of the compiler, as the condition `tools`.
   The input type `conditions` answers it from `operation-time@2` on, as the whole value of
   `observation.conditions`, and the presets of this family still fix their conditions, none,
   until a version of their own takes the input. The date of an advisory database is no
   condition of Ratchet itself, and a declaration could name one; a snapshot of an exact set
   would then stop qualifying with every new day, so `advisory-report@1` declares none.
4. **A target that is a build.** What the family judges is a built thing, and
   `ratchet.specification.TargetKind` has `build` for it. Up to `binary-size@1` each plan of
   the family names the kind `revision`, the built file is an input, and the program writes
   its digest under `target.identifiers.artifact_digest`, and the kind `build` answers it
   from `binary-size@2` on: `ratchet.assessor.Assessor.target_input` names the input of the
   artifact for a `build` target, Ratchet passes `--revision`, the revision it was built
   from, and the record holds the digest of the artifact as `candidate`
   ([`docs/evidence-format.md`](../docs/evidence-format.md) § 10, "Invocation").
   `image-size@1`, `dependency-count@1` and `dependency-advisories@1` keep the kind
   `revision`. Nothing checks that the file was built from the revision: that is the
   project's statement ([`docs/evidence-format.md`](../docs/evidence-format.md) § 9).
