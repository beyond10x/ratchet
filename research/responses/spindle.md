# Response: spindle

- kind and stack: runtime and CLI for executable specifications, Rust workspace plus two Vue 3/TypeScript front ends and a Docusaurus docs site
- answered by: implementation session of the repository (read-only survey pass, read from origin/main)
- date: 2026-11-23

## A. The project
A1: Platform/runtime plus CLI (`b10x-spindle`). Seen: 421 `.rs` files, about 140k lines of Rust (workspace of ~20 crates under `crates/`), `ui/` and `web/` (Vue 3, TypeScript, Vite, pnpm), `website/` (Docusaurus), 2,036 tracked files (`git ls-tree`). Users: developers who run a specification, other tools via the observe API, coding agents (AGENTS.md is the working contract). Source: `AGENTS.md` "Map".
A2: Spindle loads and compiles an ESS specification, derives the capabilities it needs, admits it against an environment, and executes it (in process, as processes, in microVMs, or in a browser Service Worker), with storage, timers, channels and ingress bound per environment. Source: `AGENTS.md` intro, `docs/design/spindle.md`.
A3: Agent sessions only, no human commits visible. Seen: all 659 commits on main are from one bot identity (`AGENTS.md` "Publishing": commits and pushes go through a bot wrapper). Main began 2026-11-04. Busy days: 12, 72, 116, 23 commits on 2026-11-09..12; 29 on 2026-11-22. 19 tags in 18 days (0.1.0 on 2026-11-06 to 0.18.0 on 2026-11-22).

## B. What you track today
B1:
- Local gate `task check` (`Taskfile.yml`) = CI job `Gate`. Blocks merge. Steps: `aep plan artifact validate`; `ess specify validate` on `ess/` and `examples/rally/ess`; `ui` pnpm test, typecheck, build; `docs-check`; `check:conformance`; wasm build, wasm memory-store test, IndexedDB store test, Service Worker test, static bundle build; `cargo fmt --check`; `cargo clippy --workspace --all-targets --locked -- -D warnings` (warnings are errors); `cargo test --workspace --locked --no-fail-fast`. Seen.
- Generated files in sync, all blocking: `check:the_generated_types_have_no_drift` (`ess generate ... --check` for JSON Schema, Rust and TypeScript types, then `cargo check` of the generated crate); `docs-check` (`spindle-docs generate --check` for `website/docs/reference/cli.md`, `website/docs/status.md`, `website/data/status.json`); a `shipped` status item must name an existing test (`crates/spindle-docs/src/status.rs::every_shipped_item_names_a_test_that_exists`); `check:every_fixture_answer_validates_against_its_schema`. Seen.
- Dependencies pinned and locked: `--locked` everywhere, `Cargo.lock`, `ui/pnpm-lock.yaml`, CI tool installs (go-task, aep, ess, wasm-bindgen) pinned by version and SHA256 (`.github/workflows/ci.yml`), actions pinned by commit hash. No dependency count or age metric, no coverage, no complexity metric, no cargo-audit/deny (no `deny.toml`). Seen / absence checked by file listing.
- Security and privacy: required job `common / Security and privacy` from the shared workflow `.github/workflows/shared-gates.yml` (reusable workflow in another repository, pinned by commit; its content is not in this repo, so what it scans is "I don't know"). Blocks merge.
- Docs build: required job `Build documentation` (`.github/workflows/pages.yml`): generated-page check, Docusaurus build, build bound to its commit (`provenance`). Blocks.
- Platform guards: `macOS` job (`ci.yml`) runs `cargo check --workspace --all-targets` for aarch64 and x86_64 Apple targets, clippy, and in-process test lanes. Blocks (required, and release waits for it).
- Adversarial tests: tests named `adversary_*` (54 files in `crates/*/tests/`); removing or renaming one needs a `story:<id>` comment, else the organisation release check refuses (`AGENTS.md` Rules).
- Planning store: `aep plan artifact validate` in the gate (`.engineering/`).
- Not in CI: `check:vm` (needs KVM, QEMU, Firecracker; `#[ignore]` tests), run on a capable host by hand. Seen.
B2: Nothing measured. Only hard limits: job timeouts 30 min (`Gate`, `PostgreSQL`), 45 (`macOS`), 15 (docs), wasm tests `WASM_BINDGEN_TEST_TIMEOUT=120`. No build-time, test-time or flaky tracking; waiting time is known only as "the gate runs to completion" (`AGENTS.md` "While implementing, build only the targets you change" is the mitigation). Seen.
B3: Merge requires CI `Gate`, `macOS`, `Build documentation`, `PostgreSQL` (the `PostgreSQL` job runs `task check:postgres` against PostgreSQL 17 with TLS) and `common / Security and privacy`. Release: `.github/workflows/release.yml` checks the tag is annotated, on main, equal to the workspace version and named by a dated `CHANGELOG.md` heading; waits for `Gate` and `macOS` green on the tagged commit (up to 40 min polling); builds 4 targets; uploads archives and `SHA256SUMS`. Release steps are in `AGENTS.md` "Cutting a release". Release frequency seen: 19 tags in 18 days. CI duration, queue wait, lead time, rollbacks: not recorded ("I don't know").
B4:
- Functional/conformance: `task check:conformance` runs the suite `ess conform synthesize` produces against the in-process target and checks it against `conformance.toml` (exact list of 79 executed scenario ids, `skipped = 0`, `known_failed = 0`). Blocking inside `Gate`. Seen.
- Store contract tests (`contract`: the cases every `Store` passes), PostgreSQL lane, wasm/browser lanes. Blocking.
- UI/UX: `website/ux/` ratchet (`task ux:docs`): Playwright layout contract per page, axe accessibility (serious and critical nodes), screen-only reader tasks (actions, looks, detours, glance cost), keyboard tab count, layout shift, long paragraphs. NOT part of `task check` and not in CI: run by hand per round (`Taskfile.yml` `ux:docs`, "not part of `task check`" in `AGENTS.md`). Seen.
- Performance: nothing (no latency, throughput or binary-size check). Production errors, SLOs: n/a (no hosted service).
B5: Thresholds seen:
- `conformance.toml`: exact executed set, `skipped = 0`, `known_failed = 0`; a different count or a scenario that stops executing fails `check:conformance`.
- clippy `-D warnings`; `cargo fmt --check`: zero.
- `website/ux/baseline.json` tolerances: counts 0, glance cost 5 % relative, layout shift 0.01 absolute, `keyboard.tabs` 30 % band both ways; exit 1 when crossed (`website/ux/cli/ratchet.ts`).
- Timeouts as in B2.
- Written in `conformance.toml`, `Taskfile.yml`, `website/ux/baseline.json`, workflow files.
B6: Baselines: `website/ux/baseline.json` (lower is better per key, scenario by scenario). `ratchet.ts` compares the measured values with it and compares the committed baseline with the one on `main` through `git show`; a worse baseline needs `DECISION=<id>` (stored as `decision` on the key, e.g. `"decision": "R-02"` on `environment.keyboard.tabs`). Update: `task ux:docs:baseline`. `conformance.toml` is a committed accepted value (exact-set), not a trend. `conformance-known-failures.json` is the accepted-failures baseline for conformance (currently absent by design). Generated files compare to a fresh generation, not to main.
B7: Yes, for UX only: `website/ux/rounds/R-00..R-03/` (report.md, round.json, shots/) and `website/ux/rounds/trend.md` (one row per round, 9 rows, 2026-11-10 to 2026-11-22). Also: `CHANGELOG.md` (Keep a Changelog), 19 git tags, 51 approval records and 301 evidence files under `.engineering/evidence/`, 492 stories, 78 review results, 13 verification reports (`.engineering/planning/`). Not recorded over time: CI times, test times, conformance counts (only the current `conformance.toml`), dependency age.

## C. What went wrong
C1: Seen in `AGENTS.md` "Rules": PR 58 had a `u32` umask in a kernel test that passed the Linux local gate and failed CI's `macOS` job (`rustix::fs::RawMode` is `u16` on Apple). Noticed at CI on the PR, so before main. Fix: the `macOS` job, plus a rule, because a Linux host cannot run the Apple `cargo check` locally (needs an Apple C compiler for `ring`). A regression that reached users: I don't know; `git log --grep fix` shows fixes such as `5d282ca1` (local state and diagnostics privacy), `9c1e8434` (a PostgreSQL store reading back its own events under an older transaction), `30ed87d9` (metrics scanned stores), each found by the adversary/review lane rather than by a production signal (inferred from `.engineering/planning/review-result/`).
C2: Not recorded. `keyboard.tabs` is declared environment-dependent in the baseline text ("Tab counts vary run to run") and has a 30 % band, which is the one known noisy metric. CI flakiness: I don't know.
C3: Seen:
- `website/ux/baseline.json`: `keyboard.tabs` raised with decisions `R-02` and `R-02-unslop` (a worse value accepted with a decision id).
- `website/ux/known-failing.json`: one mark (gate-2 "docs sidebar outside the viewport" at 1280x800, finding UXF-008, status open): a gate failure accepted until the finding is fixed. Not tightened yet.
- `Taskfile.yml` `check:postgres`: two heavy tests skipped with `--skip` (`adv2_sqlite_scans_the_same_long_logs`, `adv3_a_scan_of_1300_rows_of_a_mebibyte_each`) in the PostgreSQL lane.
- VM and user-namespace tests are `#[ignore]`d for CI (runners refuse user namespaces), run only by `task check:vm` by hand.
- The ux ratchet is out of the gate by design.

## D. Friction
D1: No timing data, so I can state only structure: `task check` runs everything (UI, wasm, browser lanes, workspace tests, docs) and needs `wasm-bindgen`, a WebDriver and `slot`-style build pools locally; `AGENTS.md` tells agents to build only changed targets while implementing and run the full gate once at the end. Number: I don't know. Second item: the `macOS` job can only be run on the forge, so a failure there costs a full CI round trip.
D2: Seen as rules in `AGENTS.md`, not as checks: confidentiality (public repository: no external names, no absolute home paths); "no technical words in a specification"; "capabilities are derived, never authored"; "docs, README and AGENTS.md change in the same commit as a command"; "no comments in manifest or workflow files"; platform-width type rule. These live in `AGENTS.md` and review habit only.
D3: `common / Security and privacy`: I cannot see what it checks (reusable workflow in another repository). `check:conformance` counts executed scenarios, which proves the suite runs, not that scenarios catch mutations (not mutation-tested here). The UX ratchet is trusted for layout, but its `keyboard.tabs` metric is noisy, hence the wide band.
D4: Partly "not needed yet / no tool fits": no performance, size, dependency-age, coverage or CI-time tracking; no history store beyond UX rounds and git tags.

## E. Quality in plain words
E1:
- What the specification says is what runs: every scenario ESS derives from a specification passes against Spindle, and none is silently skipped.
- Spindle refuses what it cannot provide: a specification that needs a capability the environment lacks is refused with the reason, never half-run.
- State is safe: a committed write survives, files and ports are private by default, and the public repository holds no external names or local paths.
- Docs match the code: every command, status item and generated page is derived from the code and carries a test that exists.
- A reader finds things on the site fast on a phone and a desktop, in both themes, without accessibility violations.
E2: Machine today: 1 (conformance counts, `conformance.toml`), 2 (admission tests), 4 (docs-check, shipped-item test names), 5 (UX ratchet, locally); part of 3 (privacy tests). With work: persistence under crash/load (property or fault-injection tests), public-repository confidentiality as a scan, UX in CI. Never: whether a refusal reason reads well to a person; whether the design decisions (design §11) are right.
E3: End users/developers: an admitted specification starts to behave differently or a documented command output changes. Coding agents: the gate takes longer or `AGENTS.md` disagrees with the code. Operators: a state directory or socket becomes readable by others, or a deployment starts to leave orphan processes. Consumers of the observe API: the generated schema or types change in a breaking way (guarded by the drift check, not a breaking-change classifier). Docs readers: a task needs more looks or actions on the site.
E4: Measured: the count of executed conformance scenarios and each UX ratchet metric; limit: never lower than the committed `conformance.toml` / `website/ux/baseline.json` on `main`, a worse value needs a decision id; checked: on every pull request in CI (today the UX ratchet runs only by hand, so this would move it into the required gate).
