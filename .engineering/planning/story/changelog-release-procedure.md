---
format: aep.planning-md/3
id: story:changelog-release-procedure
kind: story
status: draft
title: CHANGELOG.md, release procedure and tag workflow
summary: Keep a Changelog file, AGENTS.md § Release, a tag workflow that builds Linux archives with checksums.
relations:
- decomposes: epic:release-line
- depends_on: story:cli-skeleton-validate
scope:
- confidence: cited
  path: .github/scripts
- confidence: cited
  path: .github/workflows/release.yml
- confidence: cited
  path: AGENTS.md
- confidence: cited
  path: CHANGELOG.md
revision: 2
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

`CHANGELOG.md` exists in the Keep a Changelog form with `## [Unreleased]`, `AGENTS.md`
§ "Release" lists the steps from the version bump to the published release with each command
written out, and a test in the gate feeds the tag workflow's two checks (tag equals the workspace
version, the changelog has a section for the tag) one passing and one failing case each.

## Scope

- `CHANGELOG.md`
- `AGENTS.md`: § "Release", and the rule that every change adds its line under
  `## [Unreleased]`
- `.github/workflows/release.yml`, `.github/scripts/release-check.sh` (the two checks) and
  `.github/scripts/release-check.test.sh`, which `task check:scripts` runs

## Notes

- The release steps, as the siblings do them: a branch `release/<version>` with one commit that
  sets the workspace version and `Cargo.lock` and dates the changelog section; a bot pull
  request; after the merge an annotated tag `<version>` on `main`, made and pushed by the bot;
  the tag workflow's artifact downloaded and its checksums verified; the release created by the
  bot; the release reported only when its author is the bot and the checksums pass.
- The workflow has `contents: read`: it does not create the release.
- The archive is `ratchet-<version>-<target>.tar.gz` with the binary, `LICENSE` and `README.md`.
- No Python. The workflow's toolchain is read from `rust-toolchain.toml`.
- This story lands beside the library stories; it touches no crate.
