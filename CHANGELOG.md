# Changelog

All notable changes to this project are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
A release is the workspace version at a bare tag such as `0.1.0`, with Linux archives of the `ratchet` binary and their checksums.

## [Unreleased]

## [0.0.4] - 2026-11-26

### Added

- A release holds a third archive, `ratchet-<version>-x86_64-unknown-linux-musl.tar.gz`, a static `ratchet` that runs on a Linux host with any C library or none, such as one whose glibc is older than the build runner's: `.github/scripts/static-check.sh` refuses a binary with a `NEEDED` entry or an `INTERP` program header, `task check:static` builds the musl binary and runs it with an empty environment, the forge runs it in an Alpine image pinned by digest, and `release-verify.sh` checks it in a published release; there is no musl archive for `aarch64`, and the two glibc archives stay

### Changed

- `task check` runs the `ess` release `spec/ess-inputs.yaml` requires also on a host whose `ess` in `PATH` is newer and holds that release beside it: `ESS_TOOLCHAIN` in `Taskfile.yml` pins it to the release the forge installs, and `task check:scripts` fails when the pin differs from the forge's or from the requirement, or when a call of `ess` in `task check:spec` or `task check:generated` loses it; `.github/scripts/check-generated.sh` started directly, not through `task`, gets no pin
- `docs/evidence-format.md` § 3 and `spec/domains/evidence.yaml` name the identifiers of a target of the kind `workflow_run`, `run_id` and `job` (`<workflow> / <job>`), and its candidate, the commit id the run ran at, with a record of such a run in § 6; `identifiers` stays an open map, and nothing refuses a record without these names or with others
- `docs/design.md` § 3, `docs/evidence-format.md` § 3 and `spec/` state that a record under `selection: merge_result` holds the revision under judgement as `candidate` and the merged tree that was read as `target.revision`, with a record of such a run in § 6; nothing refuses a record with the two swapped yet, and the assessor invocation of § 10 still passes one revision
- The cache condition has one name, `cache_profile`, in a plan, an assessor declaration and an evidence record: `docs/design.md`, `docs/evidence-format.md` and `spec/` say so, the design example writes it, and the example declaration `command-timing@1` (`examples/quality/assessors/command-timing@1.assessor.yaml`) now declares `cache_profile` under `conditions`, changed in place: an example declaration is an illustration that no plan binds by its digest; and `task check:spec` refuses a condition `cache` in a preset or in the `conditions` of a declaration of `presets/`; `ratchet validate` does not refuse it yet
- `docs/`, `spec/` and the README of the specification answer five places the first consumer of the formats could not read: `scopes: []` is valid and means the scope `run` alone, and `scopes` stays required; with `runs: 1` an existing aggregation kind is valid where the command repeats its measurement itself in the one run; an output has one unit and every value of it is written in that unit; a `ratchet/1` file may hold comments, which a reader skips; `docs/evidence-format.md` § 2 gives the recipe for the evidence digest, § 6 states that of its first example, and `task check:spec` fails when the two disagree
- `docs/design.md` § 3 and `spec/domains/specification.yaml` state that one plan may hold exact and sampled measurements of its one run, in every observation kind, and that the conditions of the plan qualify every measurement of it, its exact ones included; no form of the mix is refused, and the header of `spec/presets.test.sh` says so
- `task check:spec` refuses an exact measurement of a preset that aggregates with anything but `sum` and an input of an assessor declaration named as a reserved argument, such as `out`; the header of `spec/presets.test.sh` lists under "Not checked", each with its reason, the twelve other forms it accepts without a word, and a case of its harness fails the run when the comparison of the line printed with `--catalog` and `--spec` is taken out
- A measurement may state `over_all_runs: true`, a value its assessor computes over all runs of the plan and no aggregation, such as a flake rate: `docs/design.md` § 3 and `spec/` say that a sampled measurement of a plan with `runs` above 1 states an aggregation or that member, and `task check:spec` refuses a preset whose plan has a literal `runs` above 1 and whose sampled measurement states neither, or states both; `presets/flake-rate@2` states it, `flake-rate@1` stays as released, and a `runs` that an input gives is not read, so no check reaches a binding yet
- An output of an assessor declaration may list the closed values of an item field under `item_values`, such as `{class: [equal, allowed, different]}`: `docs/evidence-format.md` § 10 and `spec/` declare it, `task check:spec` refuses a `filter` of a preset that names another value of such a field and a key of `item_values` that is no field of `item_fields`, and a field without a list stays open; `presets/comparison-report@2` lists the three classes and `differential-equality@2` names it, the files `@1` stay as released, and neither `ratchet validate` nor an evidence reader checks the values yet
- `presets/` holds a ninth family, production readiness (`presets/production.md`): `exposure-probes@1`, three probe assertions of a deployed service (requests without a valid credential refused, console routes unreachable through the public proxy, TLS on every public listener), and `artifact-signatures@1`, the signatures of an image and its provenance, with the declarations `http-probe-report@1` and `artifact-verification-report@1`; `examples/production-gate.ratchet.yaml` is a candidate gate over seven production checks that binds them beside `conformance-cases@1` and `known-failures@1`, and `task check:spec` refuses a binding of an example whose `use:` names no preset file of `presets/` or whose `digest` is not that file's SHA-256; the catalog ships no probe runner, no verifier and no program that reads their reports, no release judges an assertion yet, and nothing checks the inputs of a binding

## [0.0.3] - 2026-11-26

### Added

- `examples/quality/assessors/` holds the `ratchet-assessor/1` declarations of nine assessors, one for each of the ten assessor ids the examples name but the built-in `record-series@1`, with the outputs, units, scopes, inputs and coverage units the examples use, as files a project can copy into its own catalog; no program of these assessors ships with them
- `task check:spec` refuses an assessor of `examples/*.ratchet.yaml` without a declaration file, a measurement that names an output, a unit or a scope its declaration does not declare, and a measurement of a window over `runs_of` that does not keep the unit and the scope of the measurement it reads; it does not check the keys and types of those declarations

## [0.0.2] - 2026-11-25

### Added

- `presets/` holds the preset catalog with its first family: the presets `conformance-cases@1`, `differential-equality@1` and `known-failures@1` and the assessor declarations they name; the catalog ships no program that reads a report
- `presets/functional.md` states for each measurement of the functional family the direction, the unit, the tolerance and the source of the evidence, and names what `ratchet/1` cannot say yet
- A preset is the file `<name>@<version>.preset.yaml` in a catalog source and holds `statements`, `assessments` and `requirements`; no command resolves a binding yet, and `presets/README.md` says what a project writes until one does
- `task check:spec` checks every file of `presets/` against the specification, each preset against the declaration of its assessor and against the comparisons the design allows for the value type of an output, and every measurement against its row on a page of the catalog
- A reference to an input has the one spelling `${inputs.<name>}`: a value of a preset that holds `${` or `{inputs.` in another form is an error and no text
- `presets/` holds the presets of four more families, observed while a project's own workload runs against a started service: `operation-time@1`, `event-time@1` and `workload-throughput@1` (latency and throughput), `process-resources@1` (memory, CPU, file descriptors, threads), `start-time@1` (start to ready, ready to first answer), and `metric-names@1` and `health-readiness@1` (operability), with the five assessor declarations they name; the catalog ships no workload, no load runner and no program that reads a report
- `presets/latency.md`, `presets/resources.md`, `presets/start.md` and `presets/operability.md` state for each measurement the direction, the unit, the tolerance input and the source of the evidence, and name what `ratchet/1` and `ratchet-assessor/1` cannot say yet
- Every duration, memory value, rate and count of a running service in these presets is sampled: its tolerance, the number of runs, the runs of an adoption and the workload are required inputs without a default, and no release judges a sampled value yet; of the four families 0.1.0 judges the metric names of `metric-names@1` alone
- `task check:spec` refuses a preset whose plan of a sampled measurement declares no condition (a window over `runs_of` declares none), and a requirement that compares a sampled measurement with an accepted value and has no tolerance or no `adoption`
- `presets/` holds the presets of three more families, judged from reports a project's own build, test, package and lint tools write: `cold-build-time@1`, `warm-build-time@1`, `test-step-time@1`, `test-time@1` and `flake-rate@1` (build), `image-size@1`, `binary-size@1`, `dependency-count@1` and `dependency-advisories@1` (artifact), and `code-lines@1`, `generator-obligations@1` and `lint-findings@1` (code), with the nine assessor declarations they name; the catalog ships no build tool, no test runner, no scanner, no linter and no program that reads a report
- `presets/build.md`, `presets/artifact.md` and `presets/code.md` state for each measurement the direction, the unit, the tolerance and the source of the evidence, define a cold and a warm build, a flaky test, the size of an image, a dependency and the identity of a lint finding, and name what `ratchet/1` and `ratchet-assessor/1` cannot say yet
- The five measurements of the build family are sampled: the tolerance, the number of runs and the command are required inputs without a default, the limits of the test step and of its slowest test are inputs with the defaults 120 s and 60 s, and no release judges them yet; the ten measurements of the artifact and the code family are exact numbers and sets, which 0.1.0 judges, and no command resolves a binding yet

### Changed

- CI runs `task check` for every change under `presets/`, a page included, and for a file renamed out of `presets/` or `crates/`
- The site says what release 0.0.1 ships in place of "nothing is implemented": a `ratchet` binary that parses the 16 commands and prints its version; no command is built yet, so it checks nothing for a project

## [0.0.1] - 2026-11-25

### Added

- The specification in `spec/` declares the four file formats: `ratchet/1`, `ratchet-evidence/1`, `ratchet-assessor/1` and `ratchet-reference/1`
- `spec/cli.yaml` declares the 16 `ratchet` commands with the typed inputs, results and refusals of each
- A coverage bound is written `{min: N}` or `{max: N}` and an adoption `{from: ...}`; the format has no shorter spelling of them
- `docs/evidence-format.md` describes what an assessor writes (`ratchet-evidence/1`) and how it declares itself (`ratchet-assessor/1`)
- A `ratchet` binary that parses the 16 commands and prints their help; no command is built yet, so it reads no file and evaluates nothing
- Each of the 16 commands answers exit status 1 with `cli_handler_unavailable` on standard error until a release builds it
- `ratchet --version` prints `ratchet <version>`, the version of the workspace, and exits 0
- The parser, the help text and a bash completion are generated from `spec/` into `crates/ratchet-cli-contract`, and the gate fails when they differ from the specification
- `task check` is the gate of the repository: the specification, format and lints, the generated crate, the script tests, the tests and the site
- The tests have a budget: a test is ended at 60 s and the run at 120 s, each as a failure
- The compiler is pinned in `rust-toolchain.toml`, and CI runs `task check` with it on every change of code
- A tag `<major>.<minor>.<patch>` builds `ratchet-<version>-<target>.tar.gz` for `x86_64-unknown-linux-gnu` and `aarch64-unknown-linux-gnu` with `SHA256SUMS`
- `.github/scripts/release-verify.sh <version>` checks a published release: its author, its three assets, their checksums and the version the binary prints
- `AGENTS.md` § "Release" holds the steps of a release and the rule for the lines of this file
