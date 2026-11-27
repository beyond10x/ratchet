# The functional family

Does a service do what its specification says, and does a candidate answer as a reference
implementation does? Three presets judge it from reports a project already produces:

| Preset | What it judges | Evidence |
| --- | --- | --- |
| [`conformance-cases@1`](conformance-cases@1.preset.yaml) | The result of each case of a conformance or contract suite | An imported conformance report, [`conformance-report@1`](conformance-report@1.assessor.yaml) |
| [`differential-equality@1`](differential-equality@1.preset.yaml), [`differential-equality@2`](differential-equality@2.preset.yaml) and [`differential-equality@3`](differential-equality@3.preset.yaml) | The answers of a candidate compared with those of a reference implementation, case by case | An imported comparison report, [`comparison-report@1`](comparison-report@1.assessor.yaml); `@2` names [`comparison-report@2`](comparison-report@2.assessor.yaml), which lists the values of `class`; `@3` also reads the conformance reports of the two implementations, [`conformance-report@1`](conformance-report@1.assessor.yaml) |
| [`known-failures@1`](known-failures@1.preset.yaml) and [`known-failures@2`](known-failures@2.preset.yaml) | The list of cases that are known to fail; `@2` also that every failed case of the suite is on it | An imported list of case ids, [`case-list@1`](case-list@1.assessor.yaml); `@2` also the conformance report, [`conformance-report@2`](conformance-report@2.assessor.yaml) |

Every measurement of the family is exact: a count or a set of case ids. Its tolerance is 0, and
no preset of the family has an input for it.

## How to read a row

A row is one measurement, named `<preset>/<assessment>/<measurement>`.

- **Direction** says which way is better. For a set it says what the set must not do.
- **Unit** is the unit the assessor declares for the output. A set has none.
- **Tolerance** is the band around the accepted value, and whether an input sets it.
- **Evidence** is the assessor and the output the value is read from.

A project that binds a preset under the name `functional` reads the requirement `no-case-lost` as
`functional.no-case-lost` and the assessment `conformance` as `functional.conformance`
([README.md](README.md)).

## `conformance-cases@1`

No case that passed in the accepted set fails or stops running, and the four counts do not get
worse.

| Input | Type | Required | What it is |
| --- | --- | --- | --- |
| `subject` | string | yes | The subject of the project that the suite judges, such as `orders-api` |
| `report` | path | yes | The report of the suite, relative to the root of the tree |
| `environments` | list of string | yes | The target classes the plan runs in, such as `[ci]` |

| Measurement | Direction | Unit | Tolerance | Evidence |
| --- | --- | --- | --- | --- |
| `conformance-cases@1/conformance/passing-cases` | Higher: the set loses no case | None: a set of case ids | 0, no input | `conformance-report@1`, output `passing_cases` |
| `conformance-cases@1/conformance/passed` | Higher | `cases` | 0, no input | `conformance-report@1`, output `passed` |
| `conformance-cases@1/conformance/failed` | Lower | `cases` | 0, no input | `conformance-report@1`, output `failed` |
| `conformance-cases@1/conformance/skipped` | Lower | `cases` | 0, no input | `conformance-report@1`, output `skipped` |
| `conformance-cases@1/conformance/refused` | Lower | `cases` | 0, no input | `conformance-report@1`, output `refused` |

| Requirement | Measurement | Comparison |
| --- | --- | --- |
| `no-case-lost` | `passing-cases` | `no_lost_items` against the accepted set |
| `passed-does-not-fall` | `passed` | Not below the accepted value |
| `failed-does-not-rise` | `failed` | Not above the accepted value |
| `skipped-does-not-rise` | `skipped` | Not above the accepted value |
| `refused-does-not-rise` | `refused` | Not above the accepted value |

The set is the requirement that sees a regression. A total hides one: a new pass beside a pass
that turned into a fail keeps `passed` where it was, and `no-case-lost` names the lost case. The
counts say how much of the suite gave a result. The preset declares no coverage bound: a skipped
or refused case is counted, and the count does not rise.

What the program of `conformance-report@1` returns for a run:

- A case has one of four results: passed, failed, skipped or refused. A refused case is one the
  suite did not judge because the service under test, or the suite, refused to run it.
- `passing_cases` holds one item per passed case, with the id the suite gives the case under
  `case_id`, such as `case-0042`. The four numbers count the cases of each result.
- Coverage, in the unit `case`: passed and failed cases are `executed`, skipped cases are
  `skipped`, refused cases are `unsupported`, and a case the report lists without a result is
  `not_run`.

[`conformance-report@2`](conformance-report@2.assessor.yaml) is `conformance-report@1` with
`revision_inputs: [report]`: its program reads the revision the report states it was produced
from, writes it as `inputs.report.revision`, and refuses a report that states none, and
`ratchet assess` refuses a report of another revision than the candidate's
([`docs/evidence-format.md`](../docs/evidence-format.md) § 10, "The revision"; no release
builds that command yet). A report left
from a run of another revision then does not count as the candidate's. It also declares the set
`failing_cases`, one item per failed case, which `known-failures@2` compares with the list of
known failures. A later version of `conformance-cases` names it too. The file `@1` stays as it
was released.

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

## `differential-equality@1`

A comparison runs the same cases against a reference implementation and against the candidate,
and gives each case one class:

- `equal`: the two answers are the same.
- `allowed`: the answers differ in a way the project has accepted, such as a generated id or a
  timestamp.
- `different`: the answers differ in any other way.

No case leaves the accepted set of equal cases, the sets of allowed and of different cases gain
no case, and the number of different cases is within a limit.

| Input | Type | Required | What it is |
| --- | --- | --- | --- |
| `subject` | string | yes | The subject of the project that is the candidate, such as `orders-api` |
| `report` | path | yes | The comparison report, relative to the root of the tree |
| `environments` | list of string | yes | The target classes the plan runs in, such as `[ci]` |
| `different_limit` | integer | yes | The most cases that may be different. It has no default: `0` asks for no difference at all |

| Measurement | Direction | Unit | Tolerance | Evidence |
| --- | --- | --- | --- | --- |
| `differential-equality@1/comparison/equal-cases` | Higher: the set loses no case | None: a set of case ids | 0, no input | `comparison-report@1`, output `cases`, the items of the class `equal` |
| `differential-equality@1/comparison/allowed-cases` | Lower: the set gains no case | None: a set of case ids | 0, no input | `comparison-report@1`, output `cases`, the items of the class `allowed` |
| `differential-equality@1/comparison/different-cases` | Lower: the set gains no case | None: a set of case ids | 0, no input; the limit is the input `different_limit` | `comparison-report@1`, output `cases`, the items of the class `different` |

| Requirement | Measurement | Comparison |
| --- | --- | --- |
| `no-equal-case-lost` | `equal-cases` | `no_lost_items` against the accepted set |
| `no-new-allowed-case` | `allowed-cases` | `no_new_items` against the accepted set |
| `no-new-different-case` | `different-cases` | `no_new_items` against the accepted set |
| `different-cases-within-limit` | `different-cases` | `lte` the input `different_limit`, on the number of items |

The two requirements on `different-cases` say different things. The limit bounds how many cases
differ and does not see which. The set sees which: a case that starts to differ fails
`no-new-different-case` while the number is still under the limit. A case that the project
accepts as allowed joins the accepted set of `no-new-allowed-case`, which is a change of that
reference and can carry a reason and an owner per item
([`docs/design.md`](../docs/design.md) § 5, "Protected references").

What the program of `comparison-report@1` returns for a run:

- `cases` holds one item per compared case, with the id of the case under `case_id` and its class
  under the field `class`. A case id is in the set once, so a case has one class.
- Coverage, in the unit `case`: a compared case is `executed`, a case the comparison left out is
  `skipped`, a case one of the two implementations refused is `unsupported`, and a case the
  report lists without a class is `not_run`.

The three measurements read the one output through a `filter` on `class`.

```yaml
presets:
  differential:
    use: differential-equality@1
    digest: sha256:<digest of the preset file>
    with:
      subject: orders-api
      report: target/comparison/report.json
      environments: [ci]
      different_limit: 0
```

## `differential-equality@2`

`differential-equality@1` that names `comparison-report@2`. That declaration lists the values
of the item field `class`, `item_values: {class: [equal, allowed, different]}`, so a `filter`
on a class that is none of the three is refused (`spec/presets.test.sh`, rule `assessor`) and
does not select an empty set. The inputs, the plan, the requirements and what the program
returns are those of `differential-equality@1`, and a project binds it with
`use: differential-equality@2`. The files `@1` stay as they were released.

| Measurement | Direction | Unit | Tolerance | Evidence |
| --- | --- | --- | --- | --- |
| `differential-equality@2/comparison/equal-cases` | Higher: the set loses no case | None: a set of case ids | 0, no input | `comparison-report@2`, output `cases`, the items of the class `equal` |
| `differential-equality@2/comparison/allowed-cases` | Lower: the set gains no case | None: a set of case ids | 0, no input | `comparison-report@2`, output `cases`, the items of the class `allowed` |
| `differential-equality@2/comparison/different-cases` | Lower: the set gains no case | None: a set of case ids | 0, no input; the limit is the input `different_limit` | `comparison-report@2`, output `cases`, the items of the class `different` |

## `differential-equality@3`

`differential-equality@2` and the requirement that the candidate loses no case the reference
implementation passes. The plan `comparison` and its four requirements are those of `@2`. Two
plans over [`conformance-report@1`](conformance-report@1.assessor.yaml) read the conformance
report of each implementation: `reference-run` that of the reference implementation,
`candidate-run` that of the candidate. The accepted set of the candidate's `passing-cases` is
adopted from the reference implementation's, with
`adoption: {from: assessment, assessment: reference-run, measurement: passing-cases}`: the
value of that measurement in the last qualifying run of `reference-run` on the trusted revision
([`docs/design.md`](../docs/design.md) § 5, "The ratchet policy"). It stays fixed until the
next adoption, as every accepted value does. The files `@1` and `@2` stay as they were
released.

| Input | Type | Required | What it is |
| --- | --- | --- | --- |
| `subject` | string | yes | The subject of the project that is the candidate, such as `orders-api` |
| `report` | path | yes | The comparison report, relative to the root of the tree |
| `environments` | list of string | yes | The target classes the plans run in, such as `[ci]` |
| `different_limit` | integer | yes | The most cases that may be different. It has no default: `0` asks for no difference at all |
| `reference_report` | path | yes | The conformance report of the reference implementation, relative to the root of the tree |
| `candidate_report` | path | yes | The conformance report of the candidate, relative to the root of the tree |

| Measurement | Direction | Unit | Tolerance | Evidence |
| --- | --- | --- | --- | --- |
| `differential-equality@3/comparison/equal-cases` | Higher: the set loses no case | None: a set of case ids | 0, no input | `comparison-report@2`, output `cases`, the items of the class `equal` |
| `differential-equality@3/comparison/allowed-cases` | Lower: the set gains no case | None: a set of case ids | 0, no input | `comparison-report@2`, output `cases`, the items of the class `allowed` |
| `differential-equality@3/comparison/different-cases` | Lower: the set gains no case | None: a set of case ids | 0, no input; the limit is the input `different_limit` | `comparison-report@2`, output `cases`, the items of the class `different` |
| `differential-equality@3/reference-run/passing-cases` | None: the source of an adoption | None: a set of case ids | None: no requirement compares it | `conformance-report@1`, output `passing_cases` |
| `differential-equality@3/candidate-run/passing-cases` | Higher: the set loses no case | None: a set of case ids | 0, no input | `conformance-report@1`, output `passing_cases` |

| Requirement | Measurement | Comparison |
| --- | --- | --- |
| `no-equal-case-lost`, `no-new-allowed-case`, `no-new-different-case`, `different-cases-within-limit` | those of `@2` | as in `@2` |
| `no-reference-case-lost` | `passing-cases` of `candidate-run` | `no_lost_items` against the accepted set, adopted from `passing-cases` of `reference-run` |

```yaml
presets:
  differential:
    use: differential-equality@3
    digest: sha256:<digest of the preset file>
    with:
      subject: orders-api
      report: target/comparison/report.json
      environments: [ci]
      different_limit: 0
      reference_report: target/conformance/reference.json
      candidate_report: target/conformance/candidate.json
```

## `known-failures@1`

A project that keeps a list of cases known to fail, in a file of its tree, binds this preset
beside `conformance-cases@1`. The list gains no case, and its size does not rise.

| Input | Type | Required | What it is |
| --- | --- | --- | --- |
| `subject` | string | yes | The subject of the project that the list belongs to, such as `orders-api` |
| `list` | path | yes | The list, relative to the root of the tree |
| `environments` | list of string | yes | The target classes the plan runs in, such as `[ci]` |

| Measurement | Direction | Unit | Tolerance | Evidence |
| --- | --- | --- | --- | --- |
| `known-failures@1/known-failures/listed-cases` | Lower: the set gains no case | None: a set of case ids | 0, no input | `case-list@1`, output `cases` |
| `known-failures@1/known-failures/size` | Lower | `cases` | 0, no input | `case-list@1`, output `count` |

| Requirement | Measurement | Comparison |
| --- | --- | --- |
| `no-new-known-failure` | `listed-cases` | `no_new_items` against the accepted set |
| `size-does-not-rise` | `size` | Not above the accepted value |

Each of the two requirements has a reference record of its own, and each is adopted on its own.
While the accepted size is the size of the accepted set, a list that passes
`no-new-known-failure` is no longer than the accepted list, and `size-does-not-rise` refuses
nothing the first passes. After an adoption of one of the two alone that does not hold: with a
lower accepted size and the older accepted set, a list that takes back a case of that set
passes `no-new-known-failure` and fails `size-does-not-rise`. `size` is there as a number: a view
and a history show how the list shrinks.

What the program of `case-list@1` returns for a run: `cases` holds one item per entry of the
list, with the id of the case under `case_id`, and `count` is the number of entries. Coverage, in
the unit `entry`: every entry that was read is `executed`.

```yaml
presets:
  known:
    use: known-failures@1
    digest: sha256:<digest of the preset file>
    with:
      subject: orders-api
      list: conformance/known-failures.txt
      environments: [ci]
```

## `known-failures@2`

`known-failures@1` judges the list alone and does not see whether it matches the failures of
the suite. `known-failures@2` also reads the report of the suite, through
[`conformance-report@2`](conformance-report@2.assessor.yaml), and every case that fails there is
on the list. The plan of the list is `list`, with the measurements and the two requirements of
`known-failures@1`; the plan of the suite is `known-failures`, whose set `failing-cases` is
compared with the listed cases through `against` and `subset_of`
([`docs/design.md`](../docs/design.md) § 3, "Comparisons"). The files `@1` stay as they were
released.

| Input | Type | Required | What it is |
| --- | --- | --- | --- |
| `subject` | string | yes | The subject of the project that the list belongs to, such as `orders-api` |
| `list` | path | yes | The list, relative to the root of the tree |
| `report` | path | yes | The report of the suite, relative to the root of the tree |
| `environments` | list of string | yes | The target classes the plans run in, such as `[ci]` |

| Measurement | Direction | Unit | Tolerance | Evidence |
| --- | --- | --- | --- | --- |
| `known-failures@2/list/listed-cases` | Lower: the set gains no case | None: a set of case ids | 0, no input | `case-list@1`, output `cases` |
| `known-failures@2/list/size` | Lower | `cases` | 0, no input | `case-list@1`, output `count` |
| `known-failures@2/known-failures/failing-cases` | Lower: every case of the set is on the list | None: a set of case ids | 0, no input | `conformance-report@2`, output `failing_cases` |

| Requirement | Measurement | Comparison |
| --- | --- | --- |
| `no-new-known-failure` | `listed-cases` | `no_new_items` against the accepted set |
| `size-does-not-rise` | `size` | Not above the accepted value |
| `every-failed-case-listed` | `failing-cases` | `subset_of` the set `listed-cases` of the plan `list`, through `against` |

`every-failed-case-listed` has no reference: the list of the same revision is the other side.
A case that fails and is not on the list fails the requirement with the cause `new_items`, and
the result names it. A case on the list that passes is not refused here; `no-new-known-failure`
and `size-does-not-rise` hold the list from growing.

What the program of `conformance-report@2` returns beside the outputs of `conformance-report@1`:
`failing_cases` holds one item per failed case, with the id under `case_id`.

```yaml
presets:
  known:
    use: known-failures@2
    digest: sha256:<digest of the preset file>
    with:
      subject: orders-api
      list: conformance/known-failures.txt
      report: target/conformance/report.json
      environments: [ci]
```

## Candidate against a reference implementation

A requirement of `ratchet/1` compares a measurement with a fixed limit, with a protected
reference, or through `against` with another measurement of the same preset, as
`known-failures@2` does. A preset names no measurement of another binding; a project names
one in its own file. The family expresses "the candidate against the reference implementation" in two ways:

1. **In the evidence.** `differential-equality@1` reads a report in which a comparison has
   already set the two implementations side by side. The reference implementation is no subject
   and no target of the plan: it is inside the report, and the plan judges the classes at the
   candidate's revision.
2. **As the protected reference.** A value that means something only against the reference
   implementation, such as the set of cases it passes, is the accepted value of the candidate's
   requirement: `no-case-lost` then says that the candidate passes every case the reference
   implementation passes. `ratchet/1` holds that accepted set, and from
   `differential-equality@3` on it also says where the set comes from: an adoption from the
   plan of the reference implementation's run (the first point below). With `@1` and `@2`, a
   project binds `conformance-cases@1` once per implementation, each with its own subject and
   report, and each is judged against its own accepted values.

## Not expressible yet

What the family needs and `ratchet/1` cannot say. The catalog adds no key to the format; each
point names the place in the specification
([`spec/domains/`](../spec/domains/)) that lacks it.

1. **A reference adopted from the evidence of another plan.** The accepted set of the
   candidate's `no-case-lost` should be the set the reference implementation passes, adopted
   from the run of the binding for the reference implementation. In the format of release
   0.0.4, `ratchet.specification.AdoptionSource` has the values `same_change` and
   `trusted_revision`, and `ratchet.specification.RatchetPolicy` holds `from`, `runs` and
   `aggregation`: an adoption names no assessment, so it reads the evidence of the
   requirement's own plan. It is answered from `differential-equality@3` on:
   `ratchet.specification.AdoptionSource` has the value `assessment`, and
   `ratchet.specification.RatchetPolicy` names the plan and the measurement the value is
   adopted from. The candidate's `no-reference-case-lost` adopts its accepted set from the set
   the plan `reference-run` passes. `differential-equality@1` and `@2` stay as they were
   released.
2. **A requirement over two measurements.** "Every failed case is on the known-failure list" and
   "the candidate passes no fewer cases than the reference implementation" each compare two
   measurements. `ratchet.specification.QualityRequirement` names one `assessment` and one
   `measurement`, and `known-failures@1` judges the list alone and does not see whether it
   matches the failures of the suite. Answered for the known-failure list from `known-failures@2`
   on: `ratchet.specification.Condition.against` names a second measurement of the preset, and
   the operator `subset_of` holds when every failed case is on the list. "No fewer passed cases
   than the reference implementation" is answered with point 1, as an accepted value: the plan
   of the reference implementation's run is a plan of `differential-equality@3`, and the
   candidate's set is adopted from it. A comparison of the two runs of one evaluation, through
   `against`, stays outside the family: the passed cases of the reference implementation in
   another binding are a measurement that `against` names only in a project's own file.
3. **The values of an item field.** The classes `equal`, `allowed` and `different` are a closed
   list, and no declaration can say so: `ratchet.assessor.AssessorOutput.item_fields` is a list
   of field names without their values. A `filter` on a class that no program returns selects no
   item, the set is empty, and nothing refuses it. Answered from `comparison-report@2` on:
   `ratchet.assessor.AssessorOutput.item_values` lists the values of an item field, that
   declaration lists the three classes, and `differential-equality@2` names it, so a `filter` on
   another class is refused. `differential-equality@1` and `comparison-report@1` stay as they
   were released.
