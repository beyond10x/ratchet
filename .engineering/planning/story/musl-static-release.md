---
format: aep.planning-md/3
id: story:musl-static-release
kind: story
status: implemented
title: A release holds a static x86_64 musl Linux archive
relations:
- decomposes: epic:release-line
scope:
- confidence: inferred
  path: .github/scripts/release-package.sh
- confidence: inferred
  path: .github/scripts/release-verify.sh
- confidence: inferred
  path: .github/scripts/release.test.sh
- confidence: inferred
  path: .github/scripts/static-check.sh
- confidence: inferred
  path: .github/workflows/pages.yml
- confidence: inferred
  path: .github/workflows/release.yml
- confidence: inferred
  path: AGENTS.md
- confidence: inferred
  path: CHANGELOG.md
- confidence: inferred
  path: Taskfile.yml
- confidence: inferred
  path: rust-toolchain.toml
revision: 7
transitions:
- {from: "draft", to: "proposed", at: "2026-11-26T07:10:36Z", actor: "human:operator", revision: 5}
- {from: "proposed", to: "active", at: "2026-11-26T07:10:37Z", actor: "human:operator", revision: 6}
- {from: "active", to: "implemented", at: "2026-11-26T07:54:35Z", actor: "human:operator", revision: 7, decided_on: {"recorded":{"test_result":1,"review_outcome":5}}}
---
## Context

A release of ratchet holds two Linux archives built against glibc on `ubuntu-22.04`
(`.github/workflows/release.yml`, the matrix of the job `Package`: `x86_64-unknown-linux-gnu`
and `aarch64-unknown-linux-gnu`). A host with an older glibc than the runner's cannot run such a
binary; the build node of the owner's workstation runs glibc 2.34. The owner approved on
2026-11-25 (relayed by the operator session of the workstation on 2026-11-26) that every
Beyond10x Rust tool publishes a static musl Linux archive and that consumers pin it, with
mimalloc where a tool is allocation-heavy, kept only if it is not slower.

ratchet builds no command yet: each of its 16 commands answers "unavailable"
(`crates/ratchet/src/commands/`). Nothing allocates, so mimalloc is not added here; the
draft `story:mimalloc-measure` carries the measurement to the first command that builds.

The story is the tenth of the wave of `.engineering/waves/0.1.0-ahead-1.md`, added on the
owner's order to put it into the current wave rather than a pull request of its own. It changes
none of the files of the nine stories before it.

## Acceptance

1. Archive. `release-package.sh targets` lists `x86_64-unknown-linux-musl` beside the two gnu
   targets; the matrix of `Package` in `release.yml` builds it on `ubuntu-22.04`, and its
   archive `ratchet-<version>-x86_64-unknown-linux-musl.tar.gz` holds `ratchet`, `LICENSE` and
   `README.md` like the others. Before: two targets, two lines in `SHA256SUMS`; after: three.
   The `release create` command of `AGENTS.md` § Release step 5 lists the third archive.
2. Static check. A script `.github/scripts/static-check.sh <binary>` exits 0 when `readelf -d`
   shows no `NEEDED` entry and `readelf -l` no `INTERP` program header, and exits 1 naming the
   entry otherwise. `release.test.sh` feeds it stand-in `readelf` output for both sides (a static
   binary passes, one with `NEEDED`, one with `INTERP` each fail), and a mutant that drops the
   `INTERP` half is refused by a case.
3. Alpine run. `docker run --rm -v <binary>:/ratchet:ro alpine:<tag>@sha256:<digest> /ratchet --version`
   prints `ratchet <version>` and exits 0; the image is pinned by digest, as the workflows pin
   actions and tools. It runs in `Package` for the musl target before packaging, and in the
   required job `Repository gate` of `pages.yml` as one step under
   `if: steps.class.outputs.task == 'check'`, on the musl binary that `task check` built from
   the job's checkout. A docs-site or planning change runs neither.
4. Toolchain. `rust-toolchain.toml` lists `targets = ["x86_64-unknown-linux-musl"]`; the install
   steps of `Repository gate` and of the release `Gate` job name the target, and stay equal as
   `release.test.sh` requires.
5. Local gate. A task `check:static` after `check:rust` in the list of `check` (`Taskfile.yml`)
   builds `ratchet` for the musl target in the release profile through the cargo shim, runs
   `static-check.sh` on it, and runs `env -i <binary> --version` and compares the output with
   `ratchet <version of Cargo.toml>`. `AGENTS.md` § Gate has its row and names the Alpine run
   as the one part that runs on the forge only. The musl link is the same on both sides: the
   linker setting of the workstation's cargo configuration applies to the gnu target only, and
   the repository has no `.cargo/config.toml`.
6. Verify. `release-verify.sh <version>` runs `static-check.sh` and `--version` on the binary
   of the musl archive and keeps `--version` on the gnu x86_64 one; its messages name the
   target; the counts of assets in its messages and in `release.test.sh` read four. Two
   mutants of `release.test.sh` are refused: a musl runner that is not `ubuntu-22.04`, and
   `release-verify.sh` without the static check.
7. Documents. `AGENTS.md`: the opening sentence of § Release and steps 4, 5 and 6 name three
   archives; § Gate has the row of `check:static`, `readelf` and the musl target in the list of
   what the gate needs; § The scripts names `static-check.sh`. `CHANGELOG.md`: one line under
   `## [Unreleased]`.
8. Time. The cold and the warm time of `task check:static` on the build node are reported; the
   warm run ends within 120 s, and the step is one `slot` job under its 10-minute limit. No
   `cargo` call is added to the task `test` (`test-budget.test.sh` refuses one).

## Scope

- `.github/workflows/release.yml`, `.github/workflows/pages.yml`
- `.github/scripts/release-package.sh`, `release-verify.sh`, `release.test.sh`,
  `static-check.sh`
- `Taskfile.yml`, `rust-toolchain.toml`
- `AGENTS.md`, `CHANGELOG.md`

## Notes

- No `aarch64-unknown-linux-musl` archive in this story; the order names `x86_64`.
- The gnu archives stay; consumers move to the musl archive by their own change.
- Round 1 of the acceptance critic: `review-result:critic-acceptance-musl-static-release-round-1`.
