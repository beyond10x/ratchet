# The latency and throughput family

How long does a service take to answer, and how much does it answer per second, while a fixed
functional workload runs against it? The workload is the project's own, such as its conformance
suite, and it is no load test. Three presets judge the timing from the report of such a run:

| Preset | What it judges | Evidence |
| --- | --- | --- |
| [`operation-time@1`](operation-time@1.preset.yaml) and [`operation-time@2`](operation-time@2.preset.yaml) | The time of each operation from the request to the answer: p50, p95 and p99; `@2` of a run with at most a bound of failed requests | An imported timing report, [`timing-report@1`](timing-report@1.assessor.yaml) |
| [`event-time@1`](event-time@1.preset.yaml) and [`event-time@2`](event-time@2.preset.yaml) | The time from a request to the event it causes, per operation: p95 | The same report; `@2` names [`timing-report@2`](timing-report@2.assessor.yaml), which is passed the workload, the runs and the fewest samples of the plan |
| [`workload-throughput@1`](workload-throughput@1.preset.yaml) | The requests answered per second | The same report |

Every measurement of the family is sampled and has no default tolerance: the tolerance, the
number of runs and the workload are required inputs of each preset.

A sampled criterion is declared here, and no release judges it yet. The first release that
evaluates a gate, 0.1.0, judges exact numbers and identity sets
([ROADMAP.md](../ROADMAP.md), "Releases"), and the family has neither.

## How to read a row

A row is one measurement, named `<preset>/<assessment>/<measurement>`.

- **Direction** says which way is better.
- **Unit** is the unit the assessor declares for the output. `ratchet/1` converts no units, and a
  declaration states one: every duration of this family is in `ms`.
- **Tolerance** is the band around the accepted value, and the input that sets it.
- **Evidence** is the assessor, the output and the part of the output the value is read from.

A project that binds a preset under the name `latency` reads the requirement
`p95-does-not-rise` as `latency.p95-does-not-rise` ([README.md](README.md)).

## What the three presets share

Each preset holds one plan of the kind `controlled_run` with these inputs:

| Input | Type | Required | What it is |
| --- | --- | --- | --- |
| `subject` | string | yes | The subject of the project that the workload runs against, such as `orders-api` |
| `report` | path | yes | The timing report of the workload runs, relative to the root of the tree |
| `workload` | string | yes | The workload of the project, by its path or its name, such as `workloads/conformance.yaml`. Ratchet ships no workload and no load runner |
| `environments` | list of string | yes | The target classes the plan runs in, such as `[ci]` |
| `runner` | string | yes | The label of the runner whose runs qualify, such as `ci-standard`. It is the condition of the plan in every class |
| `runs` | integer | yes | The number of runs of the workload behind a value. It has no default; `1` is valid |
| `adoption_runs` | integer | yes | The number of qualifying runs on the trusted revision whose median becomes the accepted value. It has no default |

A requirement compares its measurement with the accepted value alone: no preset of the family
holds a fixed limit such as "p95 below 100 ms". A limit is a number of the project and has no
default, so a project writes it as a requirement of its own.

The accepted value of each requirement is adopted from the trusted revision
(`adoption: {from: trusted_revision}`), as the median of the last `adoption_runs` qualifying
runs. A run under another runner than `runner` does not qualify and is no fail
([`docs/design.md`](../docs/design.md) § 3, "Measurement kind and observation conditions").

What the program of `timing-report@1` returns for a run:

- It reads `report`: the requests of the runs of the workload, each with its operation, the
  moment the request was sent, the moment its answer was complete, and where the request causes
  an event the moment the event was observed. It refuses a report that names another workload
  than `workload`.
- `duration` holds one result per operation, boundary and aggregation, at the scope
  `operation`: the 50th, the 95th and the 99th percentile for
  `request_start_to_response_complete`, the 95th percentile for
  `request_start_to_event_observed`, and no other. The item is the operation as the workload
  names it, such as `GET /orders`, in the same spelling in every run.
  - The boundary `request_start_to_response_complete` is the time from the moment the client of
    the workload writes the first byte of the request to the moment it has read the whole
    answer. Setting up the connection is outside it.
  - The boundary `request_start_to_event_observed` starts at the same moment and ends when the
    observer of the workload sees the event that the request causes: of several events, the
    first event of the kind the workload names for the request.
- A percentile is over the requests of one operation in all runs of the report, by the nearest
  rank: the smallest value with at least p percent of the samples at or below it. A median is
  the 50th percentile by the same rule, so of an even number of values the lower of the two in
  the middle. Only a request that was answered as the workload expects is a sample: an error
  is often faster than an answer. `samples` holds the number of samples behind a value, here
  requests, so for a percentile no record carries the number of runs.
- `throughput` is, for one run, the number of requests answered as the workload expects,
  divided by the seconds from the first request sent to the last answer read.
- Coverage, in the unit `request`: a request that was sent and answered is `executed`, and
  `passed` or `failed` as the workload judges its answer. A request of the workload that was
  not sent or got no answer is `not_run`. Each plan of the family declares
  `not_run: {max: 0}`, so a run that was cut short is insufficient evidence.
- The conditions hold the runner the report names, and `target.identifiers.workload_version`
  holds the version of the workload where the report states one
  ([`docs/evidence-format.md`](../docs/evidence-format.md) § 3).

## `operation-time@1`

No percentile of the time of an operation rises above its accepted value by more than its
tolerance. The preset covers the candidate `operation-time@1` of
[`research/candidate-presets.md`](../research/candidate-presets.md) § 3.8 and takes its name.
It compares with a stored accepted value under the runner of the binding and declares no
paired run: a paired run needs a program that builds two revisions, and a report holds one,
and [`docs/evidence-format.md`](../docs/evidence-format.md) § 9 lists a paired run as
not in version 1.

Its inputs beside the shared ones:

| Input | Type | Required | What it is |
| --- | --- | --- | --- |
| `min_samples` | integer | yes | The fewest requests of an operation that qualify. It has no default: a p99 of a few requests says nothing |
| `p50_tolerance_percent` | decimal | yes | The band of `p50`, in percent of its accepted value. It has no default |
| `p95_tolerance_percent` | decimal | yes | The band of `p95`, in percent of its accepted value. It has no default |
| `p99_tolerance_percent` | decimal | yes | The band of `p99`, in percent of its accepted value. It has no default |

| Measurement | Direction | Unit | Tolerance | Evidence |
| --- | --- | --- | --- | --- |
| `operation-time@1/operations/p50` | Lower | `ms` | The input `p50_tolerance_percent`; required, no default | `timing-report@1`, output `duration`, boundary `request_start_to_response_complete`, the 50th percentile per operation |
| `operation-time@1/operations/p95` | Lower | `ms` | The input `p95_tolerance_percent`; required, no default | `timing-report@1`, output `duration`, the same boundary, the 95th percentile per operation |
| `operation-time@1/operations/p99` | Lower | `ms` | The input `p99_tolerance_percent`; required, no default | `timing-report@1`, output `duration`, the same boundary, the 99th percentile per operation |

| Requirement | Measurement | Comparison | Judged by a release |
| --- | --- | --- | --- |
| `p50-does-not-rise` | `p50` | Not above the accepted value by more than the tolerance, per operation | Not yet: sampled |
| `p95-does-not-rise` | `p95` | Not above the accepted value by more than the tolerance, per operation | Not yet: sampled |
| `p99-does-not-rise` | `p99` | Not above the accepted value by more than the tolerance, per operation | Not yet: sampled |

Each percentile has a tolerance of its own, because the three do not vary alike between two
runs of an unchanged service: a p99 moves more than a p50. A requirement has one accepted
value per operation. An operation that the accepted values hold and a run does not is
insufficient evidence for that operation, with the cause `coverage_below_plan`. An operation
that is new in a run has no accepted value until the next adoption, with the cause
`reference_missing`
([`docs/design.md`](../docs/design.md) § 5, "Verdicts").

```yaml
presets:
  latency:
    use: operation-time@1
    digest: sha256:<digest of the preset file>
    with:
      subject: orders-api
      report: target/workload/timing.json
      workload: workloads/conformance.yaml
      environments: [ci]
      runner: ci-standard
      runs: 3
      min_samples: 200
      adoption_runs: 10
      p50_tolerance_percent: 10
      p95_tolerance_percent: 15
      p99_tolerance_percent: 25
```

The numbers of this binding are illustrations and no recommendation.

## `operation-time@2`

`operation-time@1` with a bound on the failed requests of a run: the plan's `coverage` holds
`failed: {max: "${inputs.failed_requests_max}"}` beside `not_run: {max: 0}`. A run with more
failed requests than the binding allows is insufficient evidence for every requirement of the
preset, with the cause `coverage_below_plan`: a failed request is often the fast or the slow
one, so the timing of the others says nothing
([`docs/design.md`](../docs/design.md) § 3, "Evidence coverage"). The bound is a number of
requests, `timing-report@1` counts them as `failed`, and the failures themselves are judged
by [`conformance-cases@1`](functional.md) in a plan of their own. The other inputs, the
requirements and the binding are those of `operation-time@1`, with `use: operation-time@2`
and the input below. The file `@1` stays as it was released.

| Input | Type | Required | What it is |
| --- | --- | --- | --- |
| `failed_requests_max` | integer | yes | The most failed requests of a run that qualifies. It has no default: `0` says that a run with one failed request decides nothing |

| Measurement | Direction | Unit | Tolerance | Evidence |
| --- | --- | --- | --- | --- |
| `operation-time@2/operations/p50` | Lower | `ms` | The input `p50_tolerance_percent`; required, no default | `timing-report@1`, output `duration`, boundary `request_start_to_response_complete`, the 50th percentile per operation, of a run with at most `failed_requests_max` failed requests |
| `operation-time@2/operations/p95` | Lower | `ms` | The input `p95_tolerance_percent`; required, no default | `timing-report@1`, output `duration`, the same boundary, the 95th percentile per operation, of such a run |
| `operation-time@2/operations/p99` | Lower | `ms` | The input `p99_tolerance_percent`; required, no default | `timing-report@1`, output `duration`, the same boundary, the 99th percentile per operation, of such a run |

## `event-time@1`

A project whose requests cause events, such as a message that a consumer reads or a record
that appears in another store, binds this preset. The time from the request to the event does
not rise above its accepted value by more than the tolerance.

Its inputs beside the shared ones:

| Input | Type | Required | What it is |
| --- | --- | --- | --- |
| `min_samples` | integer | yes | The fewest requests of an operation with an observed event that qualify. It has no default |
| `tolerance_percent` | decimal | yes | The band, in percent of the accepted value. It has no default |

| Measurement | Direction | Unit | Tolerance | Evidence |
| --- | --- | --- | --- | --- |
| `event-time@1/events/delay` | Lower | `ms` | The input `tolerance_percent`; required, no default | `timing-report@1`, output `duration`, boundary `request_start_to_event_observed`, the 95th percentile per operation |

| Requirement | Measurement | Comparison | Judged by a release |
| --- | --- | --- | --- |
| `delay-does-not-rise` | `delay` | Not above the accepted value by more than the tolerance, per operation | Not yet: sampled |

A request whose event is not observed before the workload ends is no sample of this boundary.
That the event arrives at all is a functional criterion, which the conformance suite of the
project judges. The percentile is fixed: the delay is judged at the 95th, the one percentile of
this boundary that a report of `timing-report@1` holds.

```yaml
presets:
  events:
    use: event-time@1
    digest: sha256:<digest of the preset file>
    with:
      subject: orders-api
      report: target/workload/timing.json
      workload: workloads/conformance.yaml
      environments: [ci]
      runner: ci-standard
      runs: 3
      min_samples: 200
      adoption_runs: 10
      tolerance_percent: 15
```

## `event-time@2`

`event-time@1` that names `timing-report@2`. That declaration maps the keys `workload`, `runs`
and `min_samples` of the plan's `observation` to its inputs of those names
(`observation_inputs: {workload: workload, runs: runs, min_samples: min_samples}`), so Ratchet
passes the program the workload, the number of runs and the fewest samples of the plan
([`docs/evidence-format.md`](../docs/evidence-format.md) § 10, "Invocation"). The plan writes
the workload once, under `observation`, and passes no `workload` under `inputs`: a plan that
passes it there too is refused (`spec/presets.test.sh`, rule `assessor`). The program refuses
a report that names another workload, or holds fewer runs than `runs`, and writes on each
value the number of runs it aggregated over as `runs`, beside `samples`, so a report of one
run does not stand for a plan with `runs: 3`. The inputs of the preset, the requirement and
the binding are those of `event-time@1`, with `use: event-time@2`. The files `@1` stay as they
were released.

| Measurement | Direction | Unit | Tolerance | Evidence |
| --- | --- | --- | --- | --- |
| `event-time@2/events/delay` | Lower | `ms` | The input `tolerance_percent`; required, no default | `timing-report@2`, output `duration`, boundary `request_start_to_event_observed`, the 95th percentile per operation over the runs the result names as `runs` |

## `workload-throughput@1`

The requests answered per second do not fall below the accepted value by more than the
tolerance. Under a functional workload the number says how fast the service gets through the
workload as its client sends it. It is no capacity of the service: the catalog holds no load
test.

Its input beside the shared ones:

| Input | Type | Required | What it is |
| --- | --- | --- | --- |
| `tolerance_percent` | decimal | yes | The band, in percent of the accepted value. It has no default |

| Measurement | Direction | Unit | Tolerance | Evidence |
| --- | --- | --- | --- | --- |
| `workload-throughput@1/throughput/requests-per-second` | Higher | `requests/s` | The input `tolerance_percent`; required, no default | `timing-report@1`, output `throughput`, the median of the runs |

| Requirement | Measurement | Comparison | Judged by a release |
| --- | --- | --- | --- |
| `throughput-does-not-fall` | `requests-per-second` | Not below the accepted value by more than the tolerance | Not yet: sampled |

The value of a run of the workload is one number. The program returns the median of the runs
its report holds, names that aggregation and writes their number as `samples`
([`docs/evidence-format.md`](../docs/evidence-format.md) § 3); of one run the median is the
value of that run. It is not passed `runs` ("Not expressible yet", point 6).

```yaml
presets:
  throughput:
    use: workload-throughput@1
    digest: sha256:<digest of the preset file>
    with:
      subject: orders-api
      report: target/workload/timing.json
      workload: workloads/conformance.yaml
      environments: [ci]
      runner: ci-standard
      runs: 3
      adoption_runs: 10
      tolerance_percent: 10
```

## Candidate against a reference implementation

The rule is that of [`docs/design.md`](../docs/design.md) § 4, "A candidate against a
reference implementation", and [functional.md](functional.md) shows it for sets. For a
duration and a rate it has one form: a project binds a preset once per implementation, each
with its own subject and report, under the same workload and the same runner. Each
implementation is then judged against its own accepted values. "The candidate answers no
slower than the reference implementation" is not said by that: the first two points below.

## Not expressible yet

What the family needs and `ratchet/1` or `ratchet-assessor/1` cannot say. The catalog adds no
key to a format; each point names the place in the specification
([`spec/domains/`](../spec/domains/)) that lacks it.

1. **A reference adopted from the evidence of another plan.** The accepted p95 of the
   candidate should be the p95 of the reference implementation, measured by the binding for
   it. `ratchet.specification.RatchetPolicy` names no assessment
   ([functional.md](functional.md), "Not expressible yet", point 1).
2. **A requirement over two measurements.** "The p95 of the candidate is at most 10 percent
   above the p95 of the reference implementation" compares two measurements.
   `ratchet.specification.Condition.against` names a second measurement, and `against` compares
   two numbers of one unit, with no tolerance: it states "not above the p95 of the reference
   implementation" and not a band over it ([functional.md](functional.md), point 2). The band
   of 10 percent over the binding for the reference implementation waits for a reference from
   another plan (point 1), which a tolerance then applies to.
3. **The conditions of a plan as an input.** A project may want a bound on the host load for
   the class `local` and a runner for the class `ci`. `ratchet.specification.ObservationPlan`
   holds `conditions` as a map from a class to its conditions, and
   `ratchet.specification.InputType` has no type for a map: an input stands for a scalar or a
   list of scalars. So each preset of the family fixes the form, a `runner` in every class.
4. **A member that is there for some values of an input.** `ratchet.specification.Measurement`
   says of `aggregation` that it is absent with `runs: 1`, and a plan declares `paired` or
   leaves it out. `ratchet.specification.InputReference` stands for a value and for no key, so
   a preset cannot leave a member out when the binding passes `runs: 1`.
   `workload-throughput@1` therefore always declares the median of the runs.
5. **A coverage bound on failed units.** A run in which requests fail should not qualify for a
   timing. Up to `operation-time@1`, `ratchet.specification.CoverageBounds` bounded
   `executed`, `skipped`, `not_run` and `unsupported` and had no bound for `failed`: the
   presets leave a failed request out of the samples, and a project judges the failures with
   [`conformance-cases@1`](functional.md). Answered from `operation-time@2` on:
   `CoverageBounds.failed` is a maximum of failed units, and a run over it is insufficient
   evidence with the cause `coverage_below_plan`. `event-time@1`, `event-time@2` and
   `workload-throughput@1` keep no bound on `failed`; a share of failed units is not a bound.
6. **The inputs that hold the observation.** Up to `timing-report@1`, Ratchet passes an
   assessor its declared inputs and nothing of the `observation` of the plan. So a plan of
   `operation-time@1`, `event-time@1` and `workload-throughput@1` names the workload twice, as
   `observation.workload` and as the input `workload`, nothing checks that the two are the
   same in a plan that a project writes by hand, and the program is passed neither `runs` nor
   `min_samples`: it aggregates over the runs its report holds, and no record carries the
   number of runs behind a percentile. `observation_inputs` of
   `ratchet.assessor.Assessor` answers it from `event-time@2` on: `timing-report@2` maps the
   keys `workload`, `runs` and `min_samples` of the plan to its inputs, the plan writes the
   workload once, and a result carries `runs`
   ([`docs/evidence-format.md`](../docs/evidence-format.md) § 10, "Invocation").
   `operation-time@1`, `operation-time@2` and `workload-throughput@1` keep `timing-report@1`.
