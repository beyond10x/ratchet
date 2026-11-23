# Response: connectors

- kind and stack: CLI plus local owner process and provider adapters, Rust workspace, generated docs site
- answered by: the session that maintains and releases the repository
- date: 2026-11-23

## A. The project
A1:
- seen: CLI + library crates + 19 provider adapter directories under `adapters/`. Rust. 4,903 tracked files (`git ls-files | wc -l`): 805 `.rs` with 420,846 lines, 1,870 `.json` (mostly generated and contract files), 1,808 `.md`. 23 workspace packages.
- seen: users are coding agents and operators on a workstation, and other repositories' services that call the CLI or the MCP server.
A2:
- One governed way to reach external providers (chat, tracker, forge, monitoring): setup, credential custody, discovery of admitted operations, reads, and writes that need an approval.
A3:
- seen: agent sessions do the work; one human decides through an operator session. `main` first-parent commits per ISO week 45-48: 7, 17, 8, 9 (squash merges). Releases: 10 in the last 14 days, 6 of them in the last 2 days.

## B. What you track today
B1:
- seen: one repository gate, `cargo run --locked -p connectors-build -- gate` (`.github/workflows/rust-gate.yml:99`), blocks merge. It holds formatting, clippy with warnings as errors, the tests, and drift checks of generated files (`AGENTS.md` § Verify: `metadata-entities --check`, `ess-boundary`, `cli --check`, `mcp-bindings --check`, `service-metadata --check`, `connectors-docs generate --check`).
- seen: a commit hook refuses personal paths and private identifiers in committed files (blocks the commit).
- seen: `planning.yml` validates the planning store on each pull request.
- seen: no `deny.toml`, no audit config, no coverage file in the tree. Dependency age, complexity, coverage: nothing.
B2:
- seen: per-test limit 60 s in `.config/nextest.toml:5` (`slow-timeout` 30 s, `terminate-after = 2`); the run prints slow tests. Host rule: test step 120 s, a pool job 10 min unless it names up to 30.
- Build time, gate time, flaky rate, wait for a verdict: not recorded. I read them from logs by hand.
B3:
- seen: 10 workflows (gate, ignored journeys, slow lane for full regeneration, macOS, Windows, custody platforms, docs site, pages, planning, release binaries). Job limits 90 min (gate) and 120 min (journeys) in the workflow file.
- seen: release = tag on the merge commit, release page, a workflow that builds 4 archives plus an image; a script checks `SHA256SUMS` and the image revision. Merge to published release today: 2 minutes.
- CI duration, time to first red, lead time, rolled-back releases: not recorded.
B4:
- seen: authored scenarios gate (56 of 56 executed in the last run I read), conformance crates per feed, CLI journeys against fake provider APIs in their own CI job, a status page whose "shipped" items each name the test that holds them.
- seen: performance only as one-off measurements in scratch scripts (ms, CPU ms, RSS and store bytes per read invoke), reported in an issue comment and a per-release verification report.
- Errors in production, SLOs: nothing. It runs on users' machines and sends nothing home (inferred).
B5:
- 60 s per test: `.config/nextest.toml`; the test is killed and counts as failed.
- 90 / 120 min per CI job: workflow files; the job is cancelled.
- Generated files: any byte of drift fails the gate.
- One test asserts a store replays at most once on a read invoke (a behaviour bound, not a time).
- No threshold on latency, binary size, store growth per invoke, build time.
B6:
- seen: generated files compare against the committed file; an `inputs.json` holds a digest of the sources and the pinned generator versions; the `slow` workflow regenerates fully and compares bytes. The baseline is updated by regenerating and committing in the same change.
- Performance compares against the previous release only by hand (before/after runs on the same store and load).
B7:
- seen: `CHANGELOG.md`; the planning store under `.engineering/` with one verification report per release and evidence records per story. No dashboard, no trend file.

## C. What went wrong
C1:
- seen: every read invoke appended 3 records and 24,500 bytes to the local store, so stores grew with use and reads slowed (median 2,939 ms on a grown store against 733 ms after the fix on a copy of it). Found by a manual measurement after a consumer reported slow reads. Which release introduced it: I don't know. A per-invoke "bytes appended" bound in the gate would have caught it.
C2:
- seen today: 3 macOS jobs cancelled by the forge for lack of a runner, green on one rerun.
- seen today: 2 of 21 store tests killed at 60 s under host load 74; one test runs 28 to 60 s depending on load; one journey ran 67 s at load 33 and 121 s at load 46-51.
C3:
- seen: the merge script lets the Windows host job fail (red at one known step since at least 2 releases). Not tightened yet; the fix is a separate pending change. A `continue-on-error` on that step was proposed and refused by the owner.

## D. Friction
D1:
- Queue wait in the shared build pool: 15 to 31 minutes per job this evening with 60 to 90 jobs queued; one regeneration of generated files is 3 jobs of up to 30 minutes each.
- Generated files going stale after a feature: one change left 35 reference pages and 2 generated-file tests stale, found only when the full check ran.
D2:
- Cost per invoke (ms, CPU, bytes written), and how each depends on host load: in scratch logs, an issue comment and verification reports.
- Which result members consumers read from the CLI's JSON: in messages between sessions, so a rename is announced by hand.
- That the `PATH` generator is newer than the pinned one and needs an environment variable: in session notes and briefs.
- Known-red items (the Windows step, one setup check item that reports `failed` on a working install): in release reports.
D3:
- The Windows job: it is red for a known reason, so a new failure behind that step is not visible; its Windows-only tests never ran on a developer machine.
- Time-bounded tests on a loaded shared host: a kill at 60 s says as much about host load as about the code.
D4: n/a

## E. Quality in plain words
E1:
- A read or a write does what its description says against the real provider, and says plainly when it did not or when the outcome is unknown.
- No write happens without an approval a human issued, and a credential never appears in output, a log or a file it does not belong in.
- A new version works on the store and configuration of the previous one, or refuses with the step to take.
- An invoke stays fast and the store stays small however long the install has been in use.
- What the documentation and the status page say is what the binary does.
E2:
- Today: descriptions against fakes (scenarios, journeys), no write without approval, docs equal generated output.
- With work: speed and store growth per invoke against a baseline; upgrade from the previous release's store; no credential in any output (partly today).
- Never fully: "against the real provider" on every merge; that stays a manual check on one install after each release.
E3:
- End users (operators): an upgrade that needs reconnecting every instance.
- Coding agents: an error that does not name the next step, or a result member that moved.
- Consumers of the CLI's JSON: a changed member path without a version note.
- Developers: a gate that fails on generated files they did not touch.
- Security owner: a write admitted without a human-issued approval.
E4:
- Bytes appended to the store and median wall ms per read invoke on a fixed fixture, each not worse than the value committed for `main` (tolerance 10 % on ms, 0 on bytes), checked in the gate of every pull request.
