# The resources family

What does a service use while a fixed functional workload runs against it? One preset judges
five numbers from the report of such a run:

| Preset | What it judges | Evidence |
| --- | --- | --- |
| [`process-resources@1`](process-resources@1.preset.yaml) | Peak and steady resident memory, CPU seconds per 1000 requests, open file descriptors and threads of the service | An imported resource report, [`resource-report@1`](resource-report@1.assessor.yaml) |

Every measurement of the family is sampled and has no default tolerance: the tolerance, the
number of runs and the workload are required inputs of the preset.

A sampled criterion is declared here, and no release judges it yet. The first release that
evaluates a gate, 0.1.0, judges exact numbers and identity sets
([ROADMAP.md](../ROADMAP.md), "Releases"), and the family has neither.

A row is read as on the page of the latency family ([latency.md](latency.md), "How to read a
row"). The workload and the runs are those of that family too: a project that writes both
reports from the same runs of its workload gets the timing and the resources of one run.

## `process-resources@1`

None of the five numbers rises above its accepted value by more than its tolerance.

| Input | Type | Required | What it is |
| --- | --- | --- | --- |
| `subject` | string | yes | The subject of the project that the workload runs against, such as `orders-api` |
| `report` | path | yes | The resource report of the workload runs, relative to the root of the tree |
| `workload` | string | yes | The workload of the project, by its path or its name, such as `workloads/conformance.yaml`. Ratchet ships no workload and no load runner |
| `environments` | list of string | yes | The target classes the plan runs in, such as `[ci]` |
| `runner` | string | yes | The label of the runner whose runs qualify, such as `ci-standard`. It is the condition of the plan in every class |
| `runs` | integer | yes | The number of runs of the workload behind a value. It has no default; `1` is valid |
| `adoption_runs` | integer | yes | The number of qualifying runs on the trusted revision whose median becomes the accepted value. It has no default |
| `peak_memory_tolerance_percent` | decimal | yes | The band of `peak-resident-memory`, in percent of its accepted value. It has no default |
| `steady_memory_tolerance_percent` | decimal | yes | The band of `steady-resident-memory`, in percent of its accepted value. It has no default |
| `cpu_tolerance_percent` | decimal | yes | The band of `cpu-seconds-per-1000-requests`, in percent of its accepted value. It has no default |
| `descriptors_tolerance` | integer | yes | The band of `open-file-descriptors`, as a number of descriptors. It has no default; `0` asks for no rise at all |
| `threads_tolerance` | integer | yes | The band of `threads`, as a number of threads. It has no default; `0` asks for no rise at all |

| Measurement | Direction | Unit | Tolerance | Evidence |
| --- | --- | --- | --- | --- |
| `process-resources@1/resources/peak-resident-memory` | Lower | `bytes` | The input `peak_memory_tolerance_percent`; required, no default | `resource-report@1`, output `peak_resident_memory`, the median of the runs |
| `process-resources@1/resources/steady-resident-memory` | Lower | `bytes` | The input `steady_memory_tolerance_percent`; required, no default | `resource-report@1`, output `steady_resident_memory`, the median of the runs |
| `process-resources@1/resources/cpu-seconds-per-1000-requests` | Lower | `s` | The input `cpu_tolerance_percent`; required, no default | `resource-report@1`, output `cpu_seconds_per_1000_requests`, the median of the runs |
| `process-resources@1/resources/open-file-descriptors` | Lower | `descriptors` | The input `descriptors_tolerance`, a number of descriptors; required, no default | `resource-report@1`, output `open_file_descriptors`, the median of the runs |
| `process-resources@1/resources/threads` | Lower | `threads` | The input `threads_tolerance`, a number of threads; required, no default | `resource-report@1`, output `threads`, the median of the runs |

| Requirement | Measurement | Comparison | Judged by a release |
| --- | --- | --- | --- |
| `peak-memory-does-not-rise` | `peak-resident-memory` | Not above the accepted value by more than the tolerance | Not yet: sampled |
| `steady-memory-does-not-rise` | `steady-resident-memory` | Not above the accepted value by more than the tolerance | Not yet: sampled |
| `cpu-does-not-rise` | `cpu-seconds-per-1000-requests` | Not above the accepted value by more than the tolerance | Not yet: sampled |
| `descriptors-do-not-rise` | `open-file-descriptors` | Not above the accepted number by more than the tolerance | Not yet: sampled |
| `threads-do-not-rise` | `threads` | Not above the accepted number by more than the tolerance | Not yet: sampled |

Open file descriptors and threads are counts, and they are sampled all the same: the highest
reading of a run depends on what the service does at once and on when a reading is taken. The
catalog gives a count the tolerance 0 where the count is exact ([README.md](README.md),
"Rules of the catalog"). Here the band is a required input in the unit of the count, and a
project whose counts do not move passes `0`.

Each measurement has a tolerance of its own, because the five do not vary alike between two
runs of an unchanged service. The accepted value of each requirement is adopted from the
trusted revision, as the median of the last `adoption_runs` qualifying runs, and a run under
another runner than `runner` does not qualify.

What the program of `resource-report@1` returns for a run:

- It reads `report`: the readings that the tool of the project took of the service while each
  run of the workload ran, and the number of requests the service answered as the workload
  expects, the count the throughput of the latency family divides ([latency.md](latency.md)).
  It refuses a report that names another workload than `workload`.
- A reading covers the process the service runs as and all its descendants, as one sum.
- `peak_resident_memory` is the highest reading of the resident memory of a run.
- `steady_resident_memory` is the median of the readings of the resident memory in the second
  half of a run, by time: what the service settles at once it has warmed up.
- `cpu_seconds_per_1000_requests` is the CPU time, user and system, that the service used from
  the first request of a run to its last answer, with the time of a process that ended during
  the run, divided by that number of requests and multiplied by 1000.
- `open_file_descriptors` and `threads` are the highest reading of each in a run.
- Each output is one value per run of the workload. The program returns the median of the runs
  its report holds, by the nearest rank ([latency.md](latency.md)), names that aggregation and
  writes their number as `samples`; of one run the median is the value of that run. It is not
  passed `runs` ("Not expressible yet", point 5).
- Coverage, in the unit `run`: a run of the workload with readings from its first request to
  its last answer is `executed`, and a run that was cut short or lacks readings is `not_run`.
  The plan declares `not_run: {max: 0}`.
- The conditions hold the runner the report names.

How often a reading is taken is the tool's: a peak between two readings is not seen. A
project keeps the interval the same between the runs it compares.

```yaml
presets:
  resources:
    use: process-resources@1
    digest: sha256:<digest of the preset file>
    with:
      subject: orders-api
      report: target/workload/resources.json
      workload: workloads/conformance.yaml
      environments: [ci]
      runner: ci-standard
      runs: 3
      adoption_runs: 10
      peak_memory_tolerance_percent: 10
      steady_memory_tolerance_percent: 5
      cpu_tolerance_percent: 15
      descriptors_tolerance: 2
      threads_tolerance: 0
```

The numbers of this binding are illustrations and no recommendation.

## Candidate against a reference implementation

As for a duration ([latency.md](latency.md), "Candidate against a reference
implementation"): a project binds the preset once per implementation, each with its own
subject and report, under the same workload and the same runner, and each implementation is
judged against its own accepted values. "The candidate uses no more memory than the reference
implementation" is not said by that.

## Not expressible yet

What the family needs and `ratchet/1` or `ratchet-assessor/1` cannot say. The catalog adds no
key to a format; each point names the place in the specification
([`spec/domains/`](../spec/domains/)) that lacks it. The points are those of
[latency.md](latency.md), "Not expressible yet", and the family adds none:

1. **A reference adopted from the evidence of another plan** (point 1 there):
   `ratchet.specification.RatchetPolicy` names no assessment, so the peak memory of the
   reference implementation cannot be the accepted value of the candidate.
2. **A requirement over two measurements** (point 2 there):
   `ratchet.specification.QualityRequirement` names one measurement.
3. **The conditions of a plan as an input** (point 3 there): `ratchet.specification.InputType`
   has no type for the map `conditions` of `ratchet.specification.ObservationPlan`.
4. **A member that is there for some values of an input** (point 4 there): the five
   measurements always declare the median of the runs, also for `runs: 1`, where
   `ratchet.specification.Measurement` says that `aggregation` is absent.
5. **The inputs that hold the observation** (point 6 there): `ratchet.assessor.Assessor` has
   `observation_inputs`, which maps a key of the plan's `observation` such as `workload` or
   `runs` to an input of the declaration, and no preset of the family uses it yet: its
   declaration names no input of the workload, and the program is not passed `runs`.
