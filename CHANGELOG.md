# Changelog

All notable changes to this project are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
A release is the workspace version at a bare tag such as `0.1.0`, with Linux archives of the `ratchet` binary and their checksums.

## [Unreleased]

### Added

- The specification in `spec/` declares the four file formats: `ratchet/1`, `ratchet-evidence/1`, `ratchet-assessor/1` and `ratchet-reference/1`
- `spec/cli.yaml` declares the 16 `ratchet` commands with the typed inputs, results and refusals of each
- A coverage bound is written `{min: N}` or `{max: N}` and an adoption `{from: ...}`; the format has no shorter spelling of them
- `docs/evidence-format.md` describes what an assessor writes (`ratchet-evidence/1`) and how it declares itself (`ratchet-assessor/1`)
- A `ratchet` binary that parses the 16 commands and prints their help; no command is built yet, so it reads no file and evaluates nothing
- Each of the 16 commands answers exit status 1 with `cli_handler_unavailable` on standard error until a release builds it
- The parser, the help text and a bash completion are generated from `spec/` into `crates/ratchet-cli-contract`, and the gate fails when they differ from the specification
- `task check` is the gate of the repository: the specification, format and lints, the generated crate, the script tests, the tests and the site
- The tests have a budget: a test is ended at 60 s and the run at 120 s, each as a failure
- The compiler is pinned in `rust-toolchain.toml`, and CI runs `task check` with it on every change of code
- A tag `<major>.<minor>.<patch>` builds `ratchet-<version>-<target>.tar.gz` for `x86_64-unknown-linux-gnu` and `aarch64-unknown-linux-gnu` with `SHA256SUMS`
- `.github/scripts/release-verify.sh <version>` checks a published release: its author, its three assets, their checksums and the version the binary prints
- `AGENTS.md` § "Release" holds the steps of a release and the rule for the lines of this file
