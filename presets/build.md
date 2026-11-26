# The build family

How long does a project take to build and to test, and how many of its tests give two answers
on one tree? Six presets judge it from the report of the project's own build and test runs:

| Preset | What it judges | Evidence |
| --- | --- | --- |
| [`cold-build-time@1`](cold-build-time@1.preset.yaml) | The time of a build that starts with no output of an earlier build | An imported report of the builds, [`build-report@1`](build-report@1.assessor.yaml) |
| [`warm-build-time@1`](warm-build-time@1.preset.yaml) | The time of a build that follows a finished build of the same tree | The same report |
| [`test-step-time@1`](test-step-time@1.preset.yaml) | The time of the test step, against a limit and against its accepted value | An imported report of the runs of the test step, [`test-report@1`](test-report@1.assessor.yaml) |
| [`test-time@1`](test-time@1.preset.yaml) | The time of the slowest test of the test step, against a limit and against its accepted value | The same report |
| [`flake-rate@1`](flake-rate@1.preset.yaml) | The share of the tests that pass in one execution and fail in another on one tree | The same report |
| [`flake-rate@2`](flake-rate@2.preset.yaml) | The same share, and the measurement states that the value is one over all runs of the report | The same report |

Every measurement of the family is sampled and has no default tolerance: the tolerance, the
number of runs and the command are required inputs of each preset. The two limits of the family
are inputs with a default: 120 s for the test step and 60 s for a test.

A sampled criterion is declared here, and no release judges it yet. The first release that
evaluates a gate, 0.1.0, judges exact numbers and identity sets
([ROADMAP.md](../ROADMAP.md), "Releases"), and the family has neither.

## How to read a row

A row is one measurement, named `<preset>/<assessment>/<measurement>`.

- **Direction** says which way is better.
- **Unit** is the unit the assessor declares for the output. `ratchet/1` converts no units, and a
  declaration states one: every duration of this family is in `s`. A rate has none.
- **Tolerance** is the band around the accepted value, and the input that sets it.
- **Evidence** is the assessor, the output and the part of the output the value is read from.

A project that binds a preset under the name `build` reads the requirement
`build-time-does-not-rise` as `build.build-time-does-not-rise` ([README.md](README.md)).

## What the five presets share

Each preset holds one plan of the kind `controlled_run` with these inputs:

| Input | Type | Required | What it is |
| --- | --- | --- | --- |
| `subject` | string | yes | The subject of the project that is built or tested, such as `service` |
| `report` | path | yes | The report of the builds or of the runs of the test step, relative to the root of the tree |
| `build_command` or `test_command` | string | yes | The command of the project that builds, or that runs the test step, as the project starts it, such as `task build` and `task test`. Ratchet ships no build tool and no test runner |
| `environments` | list of string | yes | The target classes the plan runs in, such as `[ci]` |
| `runner` | string | yes | The label of the runner whose runs qualify, such as `ci-standard`. It is a condition of the plan in every class |
| `runs` | integer | yes | The number of builds, or of runs of the test step, behind a value. It has no default; `1` is valid |
| `adoption_runs` | integer | yes | The number of qualifying runs on the trusted revision whose median becomes the accepted value. It has no default |

The accepted value of each requirement is adopted from the trusted revision
(`adoption: {from: trusted_revision}`), as the median of the last `adoption_runs` qualifying
runs. A run under another runner than `runner` does not qualify and is no fail
([`docs/design.md`](../docs/design.md) § 3, "Measurement kind and observation conditions").

What a time of this family is:

- **The boundary.** A time of a command is the time from the start of the command to its exit,
  the boundary `run_time`. A wait inside the command is part of the time, such as a build tool
  that waits for a lock or asks a build pool for a slot. The wait of the command itself for
  its start, for a runner or for a slot it was queued for, is outside it. No preset of the
  family judges that wait.
- **The cache profile.** A build depends on what an earlier build left behind, so every plan of
  the family names a cache profile as the condition `cache_profile`, which both declarations
  declare, and the program writes the profile of the report under
  `evidence.conditions.cache_profile`
  ([`docs/evidence-format.md`](../docs/evidence-format.md) § 3). The family has two profiles:
  - `cold`: the command starts with no output of an earlier build. The build directory is
    empty, and no compile cache answers, neither on the machine nor from a network. What the
    build downloads, such as its dependencies, is in place before the command starts, so the
    time holds no download.
  - `warm`, for a build: the command starts after a run of the same command on the same tree
    that ended with success, and no file changed since.
  - `warm`, for the test step: the command starts after a build of everything the step runs,
    and no file changed since. Each run executes its tests. A run in which the test runner
    replays stored results of tests and does not execute them is no run of the step, and a
    report holds none.

  All builds or runs of one report are under one profile. A report under another profile than
  the plan declares does not qualify and is no fail. A report that names no profile gives a
  document without the condition: a declared condition that the document does not hold is
  unknown, and the evidence does not qualify for a gate
  ([`docs/evidence-format.md`](../docs/evidence-format.md) § 3, "Unknown, or not applicable").
- **The median.** The program returns the median of the builds or runs its report holds, by the
  nearest rank: of an even number of values the lower of the two in the middle
  ([latency.md](latency.md)). It names that aggregation and writes their number as `samples`;
  of one run the median is the value of that run. It is not passed `runs` ("Not expressible
  yet", point 5).

The family holds no criterion for a build after a change of some files, an incremental build:
which files change is a workload that a project would have to fix, and the family has no input
for it.

## `cold-build-time@1` and `warm-build-time@1`

The time of a build does not rise above its accepted value by more than the tolerance. The two
presets differ in the cache profile their plan declares and in nothing else, so a project that
judges both binds both, each with a report of its own.

Their input beside the shared ones:

| Input | Type | Required | What it is |
| --- | --- | --- | --- |
| `tolerance_percent` | decimal | yes | The band, in percent of the accepted value. It has no default |

| Measurement | Direction | Unit | Tolerance | Evidence |
| --- | --- | --- | --- | --- |
| `cold-build-time@1/build/build-time` | Lower | `s` | The input `tolerance_percent`; required, no default | `build-report@1`, output `duration`, boundary `run_time`, under the cache profile `cold`, the median of the builds |
| `warm-build-time@1/build/build-time` | Lower | `s` | The input `tolerance_percent`; required, no default | `build-report@1`, output `duration`, boundary `run_time`, under the cache profile `warm`, the median of the builds |

| Requirement | Measurement | Comparison | Judged by a release |
| --- | --- | --- | --- |
| `build-time-does-not-rise` of `cold-build-time@1` | `build-time` | Not above the accepted value by more than the tolerance | Not yet: sampled |
| `build-time-does-not-rise` of `warm-build-time@1` | `build-time` | Not above the accepted value by more than the tolerance | Not yet: sampled |

Neither preset holds a fixed limit: how long a build may take is a number of the project, and
a project writes it as a requirement of its own.

What the program of `build-report@1` returns for a run:

- It reads `report`: the builds of the tree, each with the command, the moment it started, the
  moment it exited, whether it ended with success, the runner and the cache profile. It refuses
  a report that names another command than `build_command`, and one whose builds are under two
  profiles.
- `duration` holds one result, the median of the times of the builds that ended with success,
  with the boundary `run_time`.
- Coverage, in the unit `build`: a build that ended with success is `executed`. A build that
  failed or that was ended from outside is `not_run`, because the time of half a build is no
  build time. Each plan declares `not_run: {max: 0}`, so a report with such a build is
  insufficient evidence, with the cause `coverage_below_plan`.
- The conditions hold the runner and the cache profile the report names.

A warm build of a tree does little work in most build tools, and what it measures is the time
the tool needs to find that nothing changed. A project whose warm build takes long has a build
step that does not see its own output.

```yaml
presets:
  cold-build:
    use: cold-build-time@1
    digest: sha256:<digest of the preset file>
    with:
      subject: service
      report: target/build/cold.json
      build_command: task build
      environments: [ci]
      runner: ci-standard
      runs: 3
      adoption_runs: 10
      tolerance_percent: 15
```

The numbers of this binding are illustrations and no recommendation.

## `test-step-time@1`

The test step is the one command of a project that runs its tests. Its time is at most a limit,
and it does not rise above its accepted value by more than the tolerance. The preset covers the
candidate `test-step-time@1` of
[`research/candidate-presets.md`](../research/candidate-presets.md) § 3.1 and takes its name.

Its inputs beside the shared ones:

| Input | Type | Required | What it is |
| --- | --- | --- | --- |
| `limit_s` | decimal | no, default `120` | The limit, in seconds. The default is the 120 s of the candidate |
| `tolerance_percent` | decimal | yes | The band, in percent of the accepted value. It has no default |

| Measurement | Direction | Unit | Tolerance | Evidence |
| --- | --- | --- | --- | --- |
| `test-step-time@1/test-step/step-time` | Lower | `s` | The input `tolerance_percent`; required, no default. The limit `limit_s` has no band | `test-report@1`, output `step_duration`, boundary `run_time`, under the cache profile `warm`, the median of the runs |

| Requirement | Measurement | Comparison | Judged by a release |
| --- | --- | --- | --- |
| `step-within-limit` | `step-time` | `lte` the input `limit_s`, 120 s by default | Not yet: sampled |
| `step-time-does-not-rise` | `step-time` | Not above the accepted value by more than the tolerance | Not yet: sampled |

The two requirements see different changes. The limit fails the step that is too long for the
project whatever it was before. The accepted value fails a step that got slower while it is
still far below the limit. A project lists one of them or both in a gate.

Whether the time of the step holds the build of the tests is decided by the cache profile, and
the preset fixes it: the plan declares `warm`, so a run of the report starts with everything
it runs already built, and the time holds no build. A project that wants the time from an
empty build directory judges the build with `cold-build-time@1`.

What the program of `test-report@1` returns for a run:

- It reads `report`: the runs of the test step on one tree, each with the command, the moment
  it started, the moment it exited, the runner, the cache profile, and every execution of a
  test with the id of the test, its result and its time. It refuses a report that names
  another command than `test_command`, and one whose runs are under two profiles.
- `step_duration` holds one result, the median of the times of the runs, with the boundary
  `run_time`.
- `slowest_test_duration` and `flake_rate` are described under `test-time@1` and
  `flake-rate@1`.
- Coverage, in the unit `run`: a run of the test step that came to its own end, so that every
  test it selected passed or failed, is `executed`. Failed tests do not change that. A run
  that stopped at a build error or at its first failed test, or that was ended at a time limit
  or from outside, is `not_run`. Each plan declares `not_run: {max: 0}`.
- A report with a run that was ended at a time limit gives incomplete results, with the cause
  `coverage_below_plan`. The program writes the time of the step as a lower bound
  (`at_least`), computed with the time until the end in place of the time the run would have
  taken. A limit or an accepted value that the bound already breaks is a fail, and every other
  comparison is insufficient evidence
  ([`docs/evidence-format.md`](../docs/evidence-format.md) § 5, U6 and E6).
- The conditions hold the runner and the cache profile the report names.

```yaml
presets:
  test-step:
    use: test-step-time@1
    digest: sha256:<digest of the preset file>
    with:
      subject: service
      report: target/test/runs.json
      test_command: task test
      environments: [ci]
      runner: ci-standard
      runs: 3
      adoption_runs: 10
      tolerance_percent: 10
```

The binding passes no `limit_s`, so the limit is the default.

## `test-time@1`

The slowest test of the test step stays within a limit, and it does not rise above its
accepted value by more than the tolerance. The preset covers the candidate `test-time@1` of
[`research/candidate-presets.md`](../research/candidate-presets.md) § 3.2 and takes its name.

Its inputs beside the shared ones:

| Input | Type | Required | What it is |
| --- | --- | --- | --- |
| `limit_s` | decimal | no, default `60` | The limit, in seconds. The default is the 60 s of the candidate |
| `tolerance_percent` | decimal | yes | The band, in percent of the accepted value. It has no default |

| Measurement | Direction | Unit | Tolerance | Evidence |
| --- | --- | --- | --- | --- |
| `test-time@1/tests/slowest-test` | Lower | `s` | The input `tolerance_percent`; required, no default. The limit `limit_s` has no band | `test-report@1`, output `slowest_test_duration`, under the cache profile `warm`, the median over the runs of the slowest execution of a run |

| Requirement | Measurement | Comparison | Judged by a release |
| --- | --- | --- | --- |
| `slowest-test-within-limit` | `slowest-test` | `lte` the input `limit_s`, 60 s by default | Not yet: sampled |
| `slowest-test-does-not-rise` | `slowest-test` | Not above the accepted value by more than the tolerance | Not yet: sampled |

What `slowest_test_duration` holds:

- The time of a test is the time the test runner reports for one execution of the test. What
  that time holds, such as the setup of the test, is the runner's, and a project keeps it the
  same between the runs it compares. A test that is executed again after a failure has one
  time per execution.
- The value of a run is the longest time of one execution in that run. The output holds one
  result, the median of those values over the runs of the report.
- A test that the runner ends at a time limit of its own is a failed test, and its run is
  still `executed`. Its time is the time at which the runner ended it. That is a plain value
  and no lower bound: `at_least` stands on an incomplete result alone
  ([`docs/evidence-format.md`](../docs/evidence-format.md) § 4, rule 6), and the run came to
  its end. So where `limit_s` equals the time limit of the runner, a test that was ended
  there has about the limit as its time, and `slowest-test-within-limit` may pass. A project
  sets the time limit of its runner above `limit_s`.

The preset measures one number for the step and not one per test: the median over the runs of
the slowest execution of a run. With a report of one run that is the time of the slowest
execution, and `slowest-test-within-limit` then says that no test takes longer than the limit.
With more runs it does not say that: of the values 50 s, 55 s and 300 s of three runs the
median is 55 s, which is within a limit of 60 s. A project that holds every execution to the
limit binds the preset with a report of one run and `runs: 1`.

A limit per test can be written: [`docs/design.md`](../docs/design.md) § 3 has one as a
measurement at the scope `test`. The preset holds none, because both of its requirements read
its one measurement. An accepted value per test is another matter: a test that a change adds
would have no accepted value until the next adoption, with the cause `reference_missing`
([`docs/design.md`](../docs/design.md) § 5, "Verdicts"), and every change that adds a test
would be insufficient evidence. `slowest-test-does-not-rise` therefore sees the slowest test
alone: a test below it that doubles its time is not seen.

The plan declares the runner and the cache profile `warm`, as the plan of `test-step-time@1`
does, so one report of the runs of the test step serves the presets that read it. Presets
that read one report are bound with the same `runs`, as the three bindings of this page are.

```yaml
presets:
  tests:
    use: test-time@1
    digest: sha256:<digest of the preset file>
    with:
      subject: service
      report: target/test/runs.json
      test_command: task test
      environments: [ci]
      runner: ci-standard
      runs: 3
      adoption_runs: 10
      tolerance_percent: 20
```

The binding passes no `limit_s`, so the limit is the default.

## `flake-rate@1`

A flaky test gives two answers on one tree. The share of such tests does not rise above its
accepted value by more than the tolerance.

Its input beside the shared ones:

| Input | Type | Required | What it is |
| --- | --- | --- | --- |
| `tolerance` | decimal | yes | The band around the accepted value, as a difference of two rates, such as `0.01`. It has no default. It is absolute, because a percentage of an accepted rate near 0 allows nothing |

| Measurement | Direction | Unit | Tolerance | Evidence |
| --- | --- | --- | --- | --- |
| `flake-rate@1/test-runs/flake-rate` | Lower | None: a share between 0 and 1 | The input `tolerance`, absolute; required, no default | `test-report@1`, output `flake_rate`, under the cache profile `warm`, over all runs of the report, at least `runs` of them |

| Requirement | Measurement | Comparison | Judged by a release |
| --- | --- | --- | --- |
| `flake-rate-does-not-rise` | `flake-rate` | Not above the accepted value by more than the tolerance | Not yet: sampled |

What `flake_rate` holds:

- A test is named by its id as the test runner writes it, in the same spelling in every run.
- An execution of a test has one of two results. It passed, or it failed: failed, ended with
  an error, ended by a time limit or aborted all count as failed. A skipped test has no
  execution.
- A test is flaky in a report when the report holds at least one execution of it that passed
  and at least one that failed. An execution that the runner repeats after a failure is an
  execution, so a test that fails and then passes in one run is flaky.
- The rate is the number of flaky tests divided by the number of tests with at least one
  execution. It lies between 0 and 1. A report whose runs executed no test has the rate 0.
- The output holds one result for the whole report, and `samples` holds the number of the
  runs of the report. The result names no aggregation ("Not expressible yet", point 6).
- A test that was skipped in every run is in neither number. The catalog holds no preset for
  skipped tests yet; the candidate `test-skips@1` of
  [`research/candidate-presets.md`](../research/candidate-presets.md) § 3.4 is one.

With a report of one run a test has two answers only where its runner executes it again after
a failure. A project whose runner does not repeat a test binds the preset with `runs` above 1,
and the rate it then sees grows with the number of runs: `runs` and `adoption_runs` stay the
same between an adoption and the runs that are compared with it. The plan declares
`min_samples` with the value of `runs`: evidence with fewer samples than `min_samples` does
not qualify. A report with more runs is not caught by that, and its rate is compared with an
accepted value from fewer runs. The tool of the project makes `runs` runs.

Each run executes its tests, as the profile `warm` says above: a run that replays stored
results gives every test the answer it had before, and the rate would be 0.

A runner that stops at the first failed test does not execute the tests after it, and such a
run is `not_run`. The plan declares `not_run: {max: 0}`, so with such a runner every report in
which a test fails is insufficient evidence, with the cause `coverage_below_plan`, and the
preset decides nothing where a flaky test failed. A project binds `flake-rate@1` with a runner
that runs every test of a run.

```yaml
presets:
  flakes:
    use: flake-rate@1
    digest: sha256:<digest of the preset file>
    with:
      subject: service
      report: target/test/runs.json
      test_command: task test
      environments: [ci]
      runner: ci-standard
      runs: 3
      adoption_runs: 10
      tolerance: 0.01
```

## `flake-rate@2`

`flake-rate@1` with one key more: its measurement states `over_all_runs: true`, so the file
says that the assessor computes the rate once over all runs of the report, which is no
aggregation of a rate per run ([`docs/design.md`](../docs/design.md) § 3, "One run per
candidate is valid"). The inputs, the plan, the requirement, what `flake_rate` holds and the
binding are those of `flake-rate@1`, with `use: flake-rate@2`. A result of the output holds the
number of runs of the report in `samples` and no aggregation. `flake-rate@1` stays as it was
released.

| Measurement | Direction | Unit | Tolerance | Evidence |
| --- | --- | --- | --- | --- |
| `flake-rate@2/test-runs/flake-rate` | Lower | None: a share between 0 and 1 | The input `tolerance`, absolute; required, no default | `test-report@1`, output `flake_rate`, under the cache profile `warm`, computed once over all runs of the report (`over_all_runs: true`), at least `runs` of them |

| Requirement | Measurement | Comparison | Judged by a release |
| --- | --- | --- | --- |
| `flake-rate-does-not-rise` | `flake-rate` | Not above the accepted value by more than the tolerance | Not yet: sampled |

## Candidate against a reference implementation

The rule is that of [`docs/design.md`](../docs/design.md) § 4, "A candidate against a
reference implementation". A build and a test step belong to a tree, so a project with two
implementations binds a preset once per implementation, each with its own subject, command and
report, under the same runner. Each implementation is then judged against its own accepted
values. "The candidate builds no slower than the reference implementation" is not said by
that: the first two points below.

## Not expressible yet

What the family needs and `ratchet/1` or `ratchet-assessor/1` cannot say. The catalog adds no
key to a format; each point names the place in the specification
([`spec/domains/`](../spec/domains/)) that lacks it.

1. **A reference adopted from the evidence of another plan.** The accepted build time of the
   candidate should be the build time of the reference implementation.
   `ratchet.specification.RatchetPolicy` names no assessment
   ([functional.md](functional.md), "Not expressible yet", point 1).
2. **A requirement over two measurements.** "The warm build takes at most a tenth of the cold
   build" compares two measurements. `ratchet.specification.QualityRequirement` names one
   ([functional.md](functional.md), point 2).
3. **The conditions of a plan as an input.** As for the latency family
   ([latency.md](latency.md), "Not expressible yet", point 3): up to `operation-time@1` an input
   stood for a scalar or a list of scalars and for no map. So each preset fixes the form, a
   `runner` in every class, and a binding cannot pass the tools that decide a build time, such
   as the version of the compiler, as the condition `tools`.
   The input type `conditions` answers it from `operation-time@2` on, as the whole value of
   `observation.conditions`, and the presets of this family still fix their conditions until a
   version of their own takes the input. The cache profile is a text, and the presets still fix
   it: `cold` and `warm` are two criteria with a row each, and an input would give one row for
   both.
4. **A member that is there for some values of an input.** As for the latency family
   ([latency.md](latency.md), point 4): a preset cannot leave `aggregation` out when the
   binding passes `runs: 1`, so the four durations always declare the median of the runs.
   This point is answered without a new form
   ([`docs/design.md`](../docs/design.md) § 3, "One run per candidate is valid"): an
   aggregation of one value is that value, so at `runs: 1` the result carries `samples: 1`
   and is judged as observed. The presets stay as they are.
5. **The inputs that hold the observation.** As for the latency family
   ([latency.md](latency.md), point 6): a plan names the command twice, as
   `observation.command` and as the input `build_command` or `test_command`, and
   `ratchet.assessor.Assessor` has no member that names the input of the command. The program
   is passed neither `runs` nor `min_samples`: the tool of the project makes the builds and
   the runs, and the program aggregates over those its report holds. So it cannot refuse a
   report with fewer runs than the binding names itself, and writes their number as `samples`.
6. **A value over the runs that no aggregation of the format gives.**
   `ratchet.specification.AggregationKind` has `sum`, `median`, `percentile`, `best_of_n` and
   `pass_rate`. The flake rate is one value over all runs of a report and is none of them:
   it is no median of a value per run, and `pass_rate` aggregates an assertion. So
   `flake-rate@1` declares no `aggregation`, also where `runs` is above 1, though
   `ratchet.specification.Aggregation` says that one is declared where a sampled plan has more
   than one run. Answered from `flake-rate@2` on: `ratchet.specification.Measurement` has the
   member `over_all_runs`, and a measurement that states `over_all_runs: true` has a value its
   assessor computes over all runs of the plan, which is no aggregation. `flake-rate@2` states
   it; `flake-rate@1` stays as it was released.
