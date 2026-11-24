---
format: aep.planning-md/3
id: story:release-0-1-0
kind: story
status: active
title: Release 0.1.0
summary: The release commit, the tag and the published release with archives and checksums, by AGENTS.md § Release.
relations:
- decomposes: epic:release-line
- depends_on: story:acceptance-in-gate
- depends_on: story:changelog-release-procedure
scope:
- confidence: cited
  path: CHANGELOG.md
- confidence: cited
  path: Cargo.lock
- confidence: cited
  path: Cargo.toml
- confidence: cited
  path: README.md
- confidence: cited
  path: ROADMAP.md
revision: 4
transitions:
- {from: "draft", to: "proposed", at: "2026-11-24T13:10:22Z", actor: "agent:ratchet", revision: 3}
- {from: "proposed", to: "active", at: "2026-11-24T13:10:22Z", actor: "agent:ratchet", revision: 4}
---
## Context

`epic:release-line` promises that 0.1.0 is released when the slice of
`epic:observe-adopt-reject` is green on `main` with the acceptance run at 7 of 7. The procedure
is `AGENTS.md` § "Release" (`story:changelog-release-procedure`); this story carries it out once.

## Acceptance

`sh .github/scripts/release-verify.sh 0.1.0` exits 0 against the published release `0.1.0` of
the repository: its author is the bot, the archives for `x86_64` and `aarch64` Linux and
`SHA256SUMS` are attached, `sha256sum -c SHA256SUMS` passes on the downloaded files, and the
`ratchet` binary of the `x86_64` archive prints `0.1.0` for `--version`; before the release
exists the same command exits non-zero.

## Scope

- `Cargo.toml`, `Cargo.lock`: the workspace version `0.1.0`
- `CHANGELOG.md`: `## [0.1.0] - <date>` cut from `## [Unreleased]`
- `README.md`: how to install the release
- `ROADMAP.md`: 0.1.0 released, the next release

## Notes

- The steps are those of `AGENTS.md` § "Release": the release commit on `release/0.1.0` through
  a bot pull request, the annotated tag made and pushed by the bot, the tag workflow's artifact,
  the release created by the bot.
- Publishing goes through the bot. A refusal of the publishing gate is reported and not worked
  around.
- The tag workflow runs the gate again; its test step stays within 120 s, no test over 60 s.
- A defect the release run finds is fixed in the story that owns the file, with a test that
  failed before, and the release starts again from the release commit.
