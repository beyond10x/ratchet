# Changelog

All notable changes to this project are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
A release is the workspace version at a bare tag such as `0.1.0`, with Linux archives of the `ratchet` binary and their checksums.

## [Unreleased]

### Changed

- `task check` runs the `ess` release `spec/ess-inputs.yaml` requires also on a host whose `ess` in `PATH` is newer and holds that release beside it: `ESS_TOOLCHAIN` in `Taskfile.yml` pins it to the release the forge installs, and `task check:scripts` fails when the pin differs from the forge's or from the requirement; the scripts that run `ess` get the pin only when started through `task`

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
