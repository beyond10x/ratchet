---
format: aep.planning-md/3
id: epic:release-line
kind: epic
status: draft
title: Changelog, release procedure and release 0.1.0
summary: CHANGELOG.md, AGENTS.md § Release, a tag workflow that builds archives, and the first release.
relations:
- decomposes: initiative:first-milestone
revision: 2
---
## Context

The repository has no release, no tag and no `CHANGELOG.md`. The owner, 2026-11-24: "I think we
could also cut a release there probably." The sibling repositories release by a written
procedure: a changelog in the Keep a Changelog form, a release commit through a bot pull request,
a bare SemVer tag made by the bot, and a GitHub release whose archives a tag workflow builds.

## Outcome

`CHANGELOG.md` exists with `## [Unreleased]`, `AGENTS.md` has a § "Release" a session can follow
without asking, a tag workflow builds the `ratchet` archives for Linux with checksums
(`story:changelog-release-procedure`), and 0.1.0 is released when the slice of
`epic:observe-adopt-reject` is green on `main` with the acceptance run at 7 of 7
(`story:release-0-1-0`).

## What 0.1.0 holds

`ratchet validate`, `ratchet assess`, `ratchet reference adopt` (first adoption and tightening of
an exact measurement) and `ratchet evaluate --gate` for exact numbers and identity sets, with the
formats `ratchet/1`, `ratchet-evidence/1`, `ratchet-assessor/1` and `ratchet-reference/1` as read
by that slice. The other 12 commands are declared and return the generated adapter's
"unavailable" answer.

## Done when

`story:changelog-release-procedure` and `story:release-0-1-0` are implemented: the release 0.1.0
exists, authored by the bot, with its archives and checksums attached.
