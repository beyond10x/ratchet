# The operability family

Can the people who run a service see what it does and tell whether it is up? Two presets judge
it from what a project already collects:

| Preset | What it judges | Evidence |
| --- | --- | --- |
| [`metric-names@1`](metric-names@1.preset.yaml) | The metric names a scrape of the service exposes, against the list the project documents | An imported scrape, [`metrics-scrape@1`](metrics-scrape@1.assessor.yaml) |
| [`health-readiness@1`](health-readiness@1.preset.yaml) | The health and the readiness answers of the service, against what the project documents | An imported report of the checks, [`probe-report@1`](probe-report@1.assessor.yaml) |

Every measurement of the family is exact: a set of metric names or an assertion. Its tolerance
is 0, and no preset of the family has an input for it. The family has no sampled value, so the
sentence of the other runtime families on a required tolerance does not apply here.

What a release judges, per requirement, is in the tables below. The first release that
evaluates a gate, 0.1.0, judges exact numbers and identity sets
([ROADMAP.md](../ROADMAP.md), "Releases"): that is `metric-names@1`. An assertion is exact and
is not among them, so `health-readiness@1` is declared here and no release judges it yet.

## How to read a row

A row is one measurement, named `<preset>/<assessment>/<measurement>`.

- **Direction** says what the set must not do, or that the assertion holds.
- **Unit** is the unit the assessor declares for the output. A set and an assertion have none.
- **Tolerance** is the band around the accepted value, and whether an input sets it.
- **Evidence** is the assessor and the output the value is read from.

## `metric-names@1`

No documented metric name that the accepted set holds stops being exposed, and the service
exposes no name outside its documented list.

| Input | Type | Required | What it is |
| --- | --- | --- | --- |
| `subject` | string | yes | The subject of the project that is scraped, such as `orders-api` |
| `scrape` | path | yes | The scrape of the metrics endpoint of the service, as the service wrote it, relative to the root of the tree |
| `documented` | path | yes | The list of the metric names the project documents, a name a line, relative to the root of the tree |
| `workload` | string | yes | The workload of the project that ran before the scrape, by its path or its name, such as `workloads/conformance.yaml`. Ratchet ships no workload |
| `environments` | list of string | yes | The target classes the plan runs in, such as `[ci]` |

| Measurement | Direction | Unit | Tolerance | Evidence |
| --- | --- | --- | --- | --- |
| `metric-names@1/scrape/documented-names` | Higher: the set loses no name | None: a set of metric names | 0, no input | `metrics-scrape@1`, output `documented_names` |
| `metric-names@1/scrape/undocumented-names` | Lower: the set is empty | None: a set of metric names | 0, no input; the limit is 0 | `metrics-scrape@1`, output `undocumented_names` |

| Requirement | Measurement | Comparison | Judged by a release |
| --- | --- | --- | --- |
| `no-documented-name-lost` | `documented-names` | `no_lost_items` against the accepted set | 0.1.0: an exact set |
| `no-undocumented-name` | `undocumented-names` | `lte` 0, on the number of items | 0.1.0: the number of items of an exact set |

The two requirements see different changes. A metric that a change removes or renames is lost
from the accepted set and fails `no-documented-name-lost`, and the result names it. A metric
that a change adds without documenting it fails `no-undocumented-name`. A name that the list
documents and no scrape ever exposed is in neither set, and the preset does not see it.

The workload is an input because a service may expose a metric only after the first event it
counts. The scrape is taken when the workload has ended, and the same workload gives the same
names.

What the program of `metrics-scrape@1` returns for a run:

- It reads `scrape` and `documented`. A name is the name as it stands on a sample line of the
  scrape, without its labels and without its value, and a name with several label values is
  one name: a histogram gives its `_bucket`, `_sum` and `_count` names. A project that
  documents metric families lists the sample names of each.
- `documented_names` holds one item per name that the scrape exposes and the list holds, with
  the name under `name`, such as `orders_created_total`.
- `undocumented_names` holds one item per name that the scrape exposes and the list does not
  hold.
- Coverage, in the unit `metric`: every name of the scrape that was read is `executed`.
- It writes the version of the workload under `target.identifiers.workload_version` where the
  project states one ([`docs/evidence-format.md`](../docs/evidence-format.md) § 3).

The labels of a metric, its type and its values are not judged.

```yaml
presets:
  metrics:
    use: metric-names@1
    digest: sha256:<digest of the preset file>
    with:
      subject: orders-api
      scrape: target/workload/metrics.txt
      documented: docs/metrics.txt
      workload: workloads/conformance.yaml
      environments: [ci]
```

## `health-readiness@1`

A project documents what the health and the readiness endpoint of its service answer in which
state, as a list of expectations with an id each, such as `ready-after-start`,
`not-ready-before-start-completes` and `healthy-while-the-workload-runs`. Its own tool brings
the service into each state, asks the endpoint and writes a report. Every expectation holds.

| Input | Type | Required | What it is |
| --- | --- | --- | --- |
| `subject` | string | yes | The subject of the project whose endpoints are asked, such as `orders-api` |
| `report` | path | yes | The report of the checks, relative to the root of the tree |
| `environments` | list of string | yes | The target classes the plan runs in, such as `[ci]` |
| `min_expectations` | integer | yes | The fewest expectations that a run must have checked. It has no default |

| Measurement | Direction | Unit | Tolerance | Evidence |
| --- | --- | --- | --- | --- |
| `health-readiness@1/probes/health` | Holds for every expectation | None: an assertion | 0, no input | `probe-report@1`, output `health` |
| `health-readiness@1/probes/readiness` | Holds for every expectation | None: an assertion | 0, no input | `probe-report@1`, output `readiness` |

| Requirement | Measurement | Comparison | Judged by a release |
| --- | --- | --- | --- |
| `health-answers-hold` | `health` | `holds` for every expectation | Not yet: 0.1.0 judges numbers and sets, and this is an assertion |
| `readiness-answers-hold` | `readiness` | `holds` for every expectation | Not yet: 0.1.0 judges numbers and sets, and this is an assertion |

An assertion has no accepted value, so nothing compares the expectations of a run with those
of the run before. `holds` is true for the items a run has, also when it has fewer. The plan
therefore declares its coverage: at least `min_expectations` expectations were checked, and
none was skipped or not run. A run below that is insufficient evidence, with the cause
`coverage_below_plan`.

What the program of `probe-report@1` returns for a run:

- It reads `report`: one result per expectation, with the id of the expectation, the endpoint
  it is about, and whether the answer was the documented one.
- `health` and `readiness` hold one assertion per expectation about that endpoint, at the
  scope `expectation`. The item is the id of the expectation, in the same spelling in every
  run.
- Coverage, in the unit `expectation`: an expectation that was checked is `executed`, and
  `passed` or `failed` as its assertion; one that the tool left out on purpose is `skipped`;
  one that it could not bring the service into the state for is `not_run`.

A service without one of the two endpoints has no expectation about it. The requirement on
that endpoint then reads no item, and no item fails it: `holds` asks of the items a run has.
The coverage bound `executed` counts the expectations of both endpoints together, so it fails
such a run only where the report as a whole holds fewer than `min_expectations`.

```yaml
presets:
  probes:
    use: health-readiness@1
    digest: sha256:<digest of the preset file>
    with:
      subject: orders-api
      report: target/workload/probes.json
      environments: [ci]
      min_expectations: 5
```

## Candidate against a reference implementation

The documented list is one for both implementations, so `no-undocumented-name` judges the
candidate and the reference implementation against the same list. "The candidate exposes every
documented name that the reference implementation exposes" is the accepted set of the
candidate's `no-documented-name-lost`, taken from the scrape of the reference implementation.
`ratchet/1` can hold that set and cannot say where it comes from (the first point below).
Until it can, a project binds `metric-names@1` once per implementation, each with its own
subject and scrape, and each is judged against its own accepted set
([`docs/design.md`](../docs/design.md) § 4, "A candidate against a reference implementation").

The expectations of `health-readiness@1` are the same list for both implementations too, and a
binding per implementation judges each against it.

## Not expressible yet

What the family needs and `ratchet/1` or `ratchet-assessor/1` cannot say. The catalog adds no
key to a format; each point names the place in the specification
([`spec/domains/`](../spec/domains/)) that lacks it.

1. **A reference adopted from the evidence of another plan.** The accepted set of the
   candidate should be the set of the binding for the reference implementation.
   `ratchet.specification.RatchetPolicy` names no assessment
   ([functional.md](functional.md), "Not expressible yet", point 1).
2. **A requirement over two sets.** "Every exposed name is documented" compares the set of the
   scrape with the set of the list. The program of `metrics-scrape@1` makes the comparison and
   returns its two sides as two outputs, and the list is an input of the assessor and no
   measurement. `subset_of` with `against` states it once the list is a measurement of a plan:
   `ratchet.specification.Condition.against` names that plan, and every exposed name is in the
   listed set ([functional.md](functional.md), point 2). `metrics-scrape@1` stays as released;
   a version of the preset with a plan over the list is not written.
3. **The items an assertion must have.** An assertion takes no reference
   ([`docs/design.md`](../docs/design.md) § 3, "Comparisons"):
   `ratchet.specification.ReferenceKind` has `generated` and `accepted_value`, and neither
   is for an assertion. So no accepted set names the expectations that must be there, as
   one does for a set with `no_lost_items`. The plan bounds their number through
   `ratchet.specification.CoverageBounds`, which does not see one expectation replaced by
   another. `executed_ids` there names an exact set, which a run with one more expectation
   no longer is.
4. **The input that holds the workload.** As for the latency family
   ([latency.md](latency.md), "Not expressible yet", point 6): `ratchet.assessor.Assessor` has
   `observation_inputs`, which maps the key `workload` of the plan's `observation` to an input
   of the declaration, and no preset of the family uses it yet: `metrics-scrape@1` takes the
   workload as an input that the plan passes under `inputs`.
