---
format: aep.planning-md/3
id: story:changelog-release-procedure
kind: story
status: active
title: CHANGELOG.md, release procedure and tag workflow
summary: 'Keep a Changelog file, AGENTS.md § Release, a tag workflow and the scripts it runs: checks, archives with checksums, release verification.'
relations:
- decomposes: epic:release-line
- depends_on: story:workspace-cli-contract
scope:
- confidence: cited
  path: .github/scripts/release-check.sh
- confidence: cited
  path: .github/scripts/release-package.sh
- confidence: cited
  path: .github/scripts/release-verify.sh
- confidence: cited
  path: .github/scripts/release.test.sh
- confidence: cited
  path: .github/workflows/release.yml
- confidence: cited
  path: AGENTS.md
- confidence: cited
  path: CHANGELOG.md
revision: 7
transitions:
- {from: "draft", to: "proposed", at: "2026-11-24T13:10:22Z", actor: "agent:ratchet", revision: 6, decided_on: {"recorded":{"review_outcome":3}}}
- {from: "proposed", to: "active", at: "2026-11-24T13:10:22Z", actor: "agent:ratchet", revision: 7, decided_on: {"recorded":{"review_outcome":3}}}
---
## Context

Two sibling repositories were read on 2026-11-24. `llm` keeps `CHANGELOG.md` in the Keep a
Changelog 1.1.0 form (`## [Unreleased]`, `## [<version>] - <date>`, the six headings, one bullet
per change on one line) and releases the source at a bare tag. `slot` releases archives: a
workflow on a tag `[0-9]+.[0-9]+.[0-9]+` runs the gate, checks that the tag equals the workspace
version and that the changelog has the section, builds `x86_64` and `aarch64` Linux archives with
`SHA256SUMS` and the notes cut from the changelog, and uploads them as one artifact; the bot then
creates the release from that artifact with `b10x-gates gh -- release create <version>
--verify-tag`.

## Acceptance

`sh .github/scripts/release.test.sh` exits 0 and prints one `ok` line per case: `CHANGELOG.md`
has `## [Unreleased]` in the Keep a Changelog form, `AGENTS.md` has a § "Release", the tag check
passes for a tag equal to the workspace version and fails for another, the changelog check passes
for a tag with a section and fails for one without, the notes cut for a tag equal that section,
the archive built from a stub binary holds `ratchet`, `LICENSE` and `README.md` and verifies
against the `SHA256SUMS` written beside it, and `release-verify.sh` passes for a recorded release
description with the bot as author beside a directory of its three assets and fails for another
author, for a missing asset, for a changed archive and for a binary that prints another version.

## Scope

- `CHANGELOG.md`
- `AGENTS.md`: § "Release", and the rule for changelog lines: the story that closes a wave
  writes the lines of its wave under `## [Unreleased]`, and a change outside a wave writes its
  own
- `.github/workflows/release.yml`
- `.github/scripts/release-check.sh` (tag equals the workspace version, the changelog has the
  section), `.github/scripts/release-package.sh` (archive, `SHA256SUMS`, notes cut from the
  changelog), `.github/scripts/release-verify.sh` (reads a published release: its author is the
  bot, its three assets are attached, `sha256sum -c` passes, the binary of the `x86_64` archive
  prints the version), and `.github/scripts/release.test.sh`, which `task check:scripts` runs

## Notes

- The release steps, as the siblings do them: a branch `release/<version>` with one commit that
  sets the workspace version and `Cargo.lock` and dates the changelog section; a bot pull
  request; after the merge an annotated tag `<version>` on `main`, made and pushed by the bot;
  the tag workflow's artifact downloaded and its checksums verified; the release created by the
  bot; the release reported only when `release-verify.sh` passes.
- The workflow has `contents: read`: it does not create the release. Its steps call the scripts
  above, so the test exercises what the workflow runs.
- The archive is `ratchet-<version>-<target>.tar.gz` with the binary, `LICENSE` and `README.md`.
- `release-verify.sh <version>` has one set of checks and two sources: without options it reads
  the description and the assets of the published release with `gh`; with `--description <file>
  --assets <dir>` it reads them from disk. `release.test.sh` uses the second form and reaches no
  network; `story:release-0-1-0` uses the first.
- No Python. The workflow's toolchain is read from `rust-toolchain.toml`.
- This story lands beside the library stories; it touches no crate.
