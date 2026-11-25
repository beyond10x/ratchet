# The start and readiness family

How long does a service take from the start of its process until it is ready, and from there
to its first answer? One preset judges the two durations from the report of the starts:

| Preset | What it judges | Evidence |
| --- | --- | --- |
| [`start-time@1`](start-time@1.preset.yaml) | The time from process start to ready, and from ready to the first answer | An imported start report, [`start-report@1`](start-report@1.assessor.yaml) |

Every measurement of the family is sampled and has no default tolerance: the tolerance, the
number of runs and the workload are required inputs of the preset.

A sampled criterion is declared here, and no release judges it yet. The first release that
evaluates a gate, 0.1.0, judges exact numbers and identity sets
([ROADMAP.md](../ROADMAP.md), "Releases"), and the family has neither.

A row is read as on the page of the latency family ([latency.md](latency.md), "How to read a
row").

## `start-time@1`

Neither duration rises above its accepted value by more than its tolerance. A run of this plan
is one start: the process of the service is started anew, and the first request of the
workload is sent when the service says that it is ready.

| Input | Type | Required | What it is |
| --- | --- | --- | --- |
| `subject` | string | yes | The subject of the project that is started, such as `orders-api` |
| `report` | path | yes | The report of the starts, relative to the root of the tree |
| `workload` | string | yes | The workload of the project whose first request is the first answer, by its path or its name, such as `workloads/conformance.yaml`. Ratchet ships no workload and no load runner |
| `environments` | list of string | yes | The target classes the plan runs in, such as `[ci]` |
| `runner` | string | yes | The label of the runner whose runs qualify, such as `ci-standard`. It is the condition of the plan in every class |
| `runs` | integer | yes | The number of starts behind a value. It has no default; `1` is valid |
| `adoption_runs` | integer | yes | The number of qualifying runs on the trusted revision whose median becomes the accepted value. It has no default |
| `ready_tolerance_ms` | decimal | yes | The band of `start-to-ready`, in `ms`. It has no default |
| `first_answer_tolerance_ms` | decimal | yes | The band of `ready-to-first-answer`, in `ms`. It has no default |

| Measurement | Direction | Unit | Tolerance | Evidence |
| --- | --- | --- | --- | --- |
| `start-time@1/start/start-to-ready` | Lower | `ms` | The input `ready_tolerance_ms`, in `ms`; required, no default | `start-report@1`, output `duration`, boundary `process_start_to_ready`, the median of the starts |
| `start-time@1/start/ready-to-first-answer` | Lower | `ms` | The input `first_answer_tolerance_ms`, in `ms`; required, no default | `start-report@1`, output `duration`, boundary `ready_to_first_answer`, the median of the starts |

| Requirement | Measurement | Comparison | Judged by a release |
| --- | --- | --- | --- |
| `start-to-ready-does-not-rise` | `start-to-ready` | Not above the accepted value by more than the tolerance | Not yet: sampled |
| `first-answer-does-not-rise` | `ready-to-first-answer` | Not above the accepted value by more than the tolerance | Not yet: sampled |

The two tolerances are absolute, in `ms`, and not a percent as in the latency family. Each
duration is one value per start, and the second is often a few milliseconds: a percent of it
is smaller than what two starts of an unchanged service differ by.

The accepted value of each requirement is adopted from the trusted revision, as the median of
the last `adoption_runs` qualifying runs, and a run under another runner than `runner` does
not qualify.

What the program of `start-report@1` returns for a run:

- It reads `report`: for each start, the moment the process of the service was started, the
  moment the service first said that it is ready, and the moment the answer to the first
  request of the workload was complete. It refuses a report that names another workload than
  `workload`.
- The boundary `process_start_to_ready` is the time from the start of the process to the first
  readiness answer that says ready. What ready means is the service's: the answer of its
  readiness endpoint, which [`health-readiness@1`](operability.md) judges.
- The boundary `ready_to_first_answer` starts at that answer and ends when the client of the
  workload has read the whole answer to the first request.
- `duration` is one value per start and boundary, and a measurement is the median of the
  `runs` starts. With `runs: 1` it is the value of that start. `samples` holds the number of
  starts behind a value.
- Coverage, in the unit `start`: a start that got ready and gave its first answer is
  `executed`, and a start that did not is `not_run`. The plan declares `not_run: {max: 0}`,
  so a service that does not start is insufficient evidence for its start time. That it
  starts at all is a functional criterion.
- The conditions hold the runner the report names.

What a start finds on the machine is part of the conditions the project keeps the same: a
start with filled caches of the operating system is faster than the first start after a
build. The preset declares the runner alone.

```yaml
presets:
  start:
    use: start-time@1
    digest: sha256:<digest of the preset file>
    with:
      subject: orders-api
      report: target/workload/start.json
      workload: workloads/conformance.yaml
      environments: [ci]
      runner: ci-standard
      runs: 5
      adoption_runs: 10
      ready_tolerance_ms: 50
      first_answer_tolerance_ms: 5
```

The numbers of this binding are illustrations and no recommendation.

## Candidate against a reference implementation

As for a duration of the latency family ([latency.md](latency.md), "Candidate against a
reference implementation"): a project binds the preset once per implementation, each with its
own subject and report, under the same workload and the same runner, and each implementation
is judged against its own accepted values. "The candidate is ready no later than the
reference implementation" is not said by that.

## Not expressible yet

What the family needs and `ratchet/1` or `ratchet-assessor/1` cannot say. The catalog adds no
key to a format; each point names the place in the specification
([`spec/domains/`](../spec/domains/)) that lacks it. The points are those of
[latency.md](latency.md), "Not expressible yet", and the family adds none:

1. **A reference adopted from the evidence of another plan** (point 1 there):
   `ratchet.specification.RatchetPolicy` names no assessment, so the start time of the
   reference implementation cannot be the accepted value of the candidate.
2. **A requirement over two measurements** (point 2 there):
   `ratchet.specification.QualityRequirement` names one measurement.
3. **The conditions of a plan as an input** (point 3 there): `ratchet.specification.InputType`
   has no type for the map `conditions` of `ratchet.specification.ObservationPlan`.
4. **A member that is there for some values of an input** (point 4 there): the two
   measurements always declare the median of the starts, also for `runs: 1`, where
   `ratchet.specification.Measurement` says that `aggregation` is absent.
5. **The input that holds the workload** (point 6 there): `ratchet.assessor.Assessor` has no
   member that names it.
