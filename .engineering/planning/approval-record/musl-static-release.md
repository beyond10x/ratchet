---
format: aep.planning-md/3
id: approval-record:musl-static-release
kind: approval-record
status: approved
title: The static musl release is accepted into the wave ahead of 0.1.0
relations:
- decides: story:musl-static-release
revision: 2
transitions:
- {from: "draft", to: "approved", at: "2026-11-26T07:10:36Z", actor: "human:operator", revision: 2}
---
## Decision

`story:musl-static-release` is accepted for implementation as the tenth story of the wave of
`.engineering/waves/0.1.0-ahead-1.md`, on the branch of that wave.

## On whose word

- The owner, 2026-11-25 about 23:10 CET, picked "A": static musl Linux releases for all
  Beyond10x Rust tools, mimalloc where allocation-heavy, consumers pin the musl archives.
- The operator session of the workstation, 2026-11-26, relaying it: into the next wave, not a
  pull request of its own.

## What the critic said

Round 1 of the acceptance critic: needs-revision, ten findings
(`review-result:critic-acceptance-musl-static-release-round-1`), each taken into the body; no
second round. The mimalloc part is carried by the draft `story:mimalloc-measure`.
