# The functional family

Does a service do what its specification says, and does a candidate answer as a reference
implementation does? Three presets judge it from reports a project already produces:

| Preset | What it judges | Evidence |
| --- | --- | --- |
| [`conformance-cases@1`](conformance-cases@1.preset.yaml) | The result of each case of a conformance or contract suite | An imported conformance report, [`conformance-report@1`](conformance-report@1.assessor.yaml) |
| [`differential-equality@1`](differential-equality@1.preset.yaml) | The answers of a candidate compared with those of a reference implementation, case by case | An imported comparison report, [`comparison-report@1`](comparison-report@1.assessor.yaml) |
| [`known-failures@1`](known-failures@1.preset.yaml) | The list of cases that are known to fail | An imported list of case ids, [`case-list@1`](case-list@1.assessor.yaml) |

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

## Candidate against a reference implementation

A requirement of `ratchet/1` compares a measurement with a fixed limit or with a protected
reference. It does not compare two measurements. The family expresses "the candidate against the
reference implementation" in two ways:

1. **In the evidence.** `differential-equality@1` reads a report in which a comparison has
   already set the two implementations side by side. The reference implementation is no subject
   and no target of the plan: it is inside the report, and the plan judges the classes at the
   candidate's revision.
2. **As the protected reference.** A value that means something only against the reference
   implementation, such as the set of cases it passes, is the accepted value of the candidate's
   requirement: `no-case-lost` then says that the candidate passes every case the reference
   implementation passes. `ratchet/1` can hold that accepted set and cannot say where it comes
   from (the first point below). Until it can, a project binds `conformance-cases@1` once per
   implementation, each with its own subject and report, and each is judged against its own
   accepted values.

## Not expressible yet

What the family needs and `ratchet/1` cannot say. The catalog adds no key to the format; each
point names the place in the specification
([`spec/domains/`](../spec/domains/)) that lacks it.

1. **A reference adopted from the evidence of another plan.** The accepted set of the
   candidate's `no-case-lost` should be the set the reference implementation passes, adopted
   from the run of the binding for the reference implementation.
   `ratchet.specification.AdoptionSource` has the values `same_change` and `trusted_revision`,
   and `ratchet.specification.RatchetPolicy` holds `from`, `runs` and `aggregation`: an adoption
   names no assessment, so it reads the evidence of the requirement's own plan.
2. **A requirement over two measurements.** "Every failed case is on the known-failure list" and
   "the candidate passes no fewer cases than the reference implementation" each compare two
   measurements. `ratchet.specification.QualityRequirement` names one `assessment` and one
   `measurement`, `ratchet.specification.Condition.value` is a decimal, and
   `ratchet.specification.ComparisonOperator` has no operator between two sets. So
   `known-failures@1` judges the list alone and does not see whether it matches the failures of
   the suite.
3. **The values of an item field.** The classes `equal`, `allowed` and `different` are a closed
   list, and no declaration can say so: `ratchet.assessor.AssessorOutput.item_fields` is a list
   of field names without their values. A `filter` on a class that no program returns selects no
   item, the set is empty, and nothing refuses it.
