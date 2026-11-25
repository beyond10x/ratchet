# Changelog

All notable changes to this project are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
A release is the workspace version at a bare tag such as `0.1.0`, with Linux archives of the `ratchet` binary and their checksums.

## [Unreleased]

### Added

- `presets/` holds the preset catalog with its first family: the presets `conformance-cases@1`, `differential-equality@1` and `known-failures@1` and the assessor declarations they name; the catalog ships no program that reads a report
- `presets/functional.md` states for each measurement of the functional family the direction, the unit, the tolerance and the source of the evidence, and names what `ratchet/1` cannot say yet
- A preset is the file `<name>@<version>.preset.yaml` in a catalog source and holds `statements`, `assessments` and `requirements`; no command resolves a binding yet, and `presets/README.md` says what a project writes until one does
- `task check:spec` checks every file of `presets/` against the specification, each preset against the declaration of its assessor and against the comparisons the design allows for the value type of an output, and every measurement against its row on a page of the catalog
- A reference to an input has the one spelling `${inputs.<name>}`: a value of a preset that holds `${` or `{inputs.` in another form is an error and no text

### Changed

- CI runs `task check` for every change under `presets/`, a page included, and for a file renamed out of `presets/` or `crates/`

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
