# Response: agentplugins

- kind and stack: plugin marketplace for coding agents (Claude Code, Codex) plus a Rust checker CLI and a Docusaurus docs site
- answered by: release and maintenance session for aep and agentplugins
- date: 2026-11-23

## A. The project
A1:
- Kind: marketplace of 5 plugins (aep, b10x, connectors, ess, worktree), each skills + agent roles + manifests for two harnesses; a Rust workspace (`crates/agentplugins-check`, `crates/b10x`); a Docusaurus site under `website/`. (seen)
- Size on main: 607 tracked files: 258 md, 140 json, 92 yaml, 29 rs (18,898 lines of Rust), 22 ts. (seen, `git ls-tree` on origin/main)
- Users: coding agents read the skills; developers install the plugins and the `b10x` binary; humans read the docs site. (seen)
- I also release the `aep` repository; this answer covers agentplugins only.
A2: Packages the beyond10x tools (AEP planning, ESS specs, worktree, connectors) as installable plugins for Claude Code and Codex, so an agent session gets the skills that match the newest CLI releases. (seen, README and CHANGELOG)
A3:
- Agent sessions write and merge; one bot identity authors every commit. A person decides releases. (seen, ruleset: bot-only commits)
- Merges to main per week, last 4 weeks: 9, 3, 3, 4. (seen, `git rev-list --first-parent` per 7 days)
- 12 tags from 2026-10-14 to 2026-11-23, 2 of them today (0.26.1, 0.27.0). (seen)

## B. What you track today
B1:
- Local gate `task check` = CI job `Gate` (`ci.yml`): `cargo fmt --check`, `clippy -D warnings`, `cargo test --workspace`, then `agentplugins-check` (manifests, marketplace, 22 eval cases, recorded transcript replay). Blocks merge. (seen, `Taskfile.yml:9-18`)
- `common / Security and privacy` from a shared workflow pinned by sha (`shared-gates.yml:16`). Blocks merge. (seen)
- `Build Docusaurus` and a docs source check (`b10x-docs-check.yml`). Build Docusaurus blocks merge. (seen)
- No coverage, no complexity, no dependency-age check. (seen: none in workflows)
- Release check `agentplugins-check release verify <version>`: all 16 version sites agree, CHANGELOG entry exists. Run by hand before the tag. (seen, ran today: "valid: 22 eval case(s), 1 recorded transcript(s) replayed / valid: marketplace b10x, 5 plugin(s)")
B2:
- Gate wall time on CI: 1 min in each of the last 10 runs. (seen, `gh run list --workflow ci.yml`)
- Local pre-push hook: 3-9 min observed in this session. (seen; not recorded anywhere)
- No build-time or test-time record; no flaky-test tracking. (seen: nothing in repo)
B3:
- Release workflow duration: 3, 4, 5, 5, 10, 30 min for the last 6 tags; 30 min today because a macOS arm64 job got no hosted runner and needed a re-run. (seen)
- Ruleset: branch must be up to date with main; 3 required checks. A behind branch is replayed onto main by hand. (seen)
- Release frequency, lead time, failed releases: not recorded. (seen: nothing)
B4:
- Docs site UX gate (`website/ux/`, `task site-ux`): every page at 1366x768 and 1280x720, both themes: no sideways scroll, nothing past its box, navbar/sidebar visible, 0 serious axe-core violations. Blocks via `Build Docusaurus`. (seen)
- Plugin behaviour: 22 eval cases validated and recorded transcripts replayed in the gate (free, no model call). Live model evals (`eval.yml`) run only with the `run-eval` label or by hand; the last 5 runs were skipped. (seen)
- Skills vs newest CLI releases: `tools.yml` job "Skills match the newest CLI releases", daily 05:17 UTC + push + PR. Not required. It is red on main now: "connectors v0.76.1 is newer than verified.json (v0.76.0)". (seen, run log)
- No production errors or SLOs: not applicable, nothing runs as a service.
B5:
- UX counts: tolerance 0 per key; `layout_shift.per_load` tolerance 0.01, only in a round. `website/ux/baseline.json`. Crossing it fails the docs check. (seen)
- clippy: 0 warnings (`-D warnings`). Fails the gate. (seen)
- Live eval budget cap in US dollars (`EVAL_BUDGET_USD`; default 20 per a comment). (seen in `eval.yml`; value of the variable: I don't know)
- CI job timeouts: Gate 15 min, Tools 30, docs check 10, live eval 90. (seen)
B6:
- `website/ux/baseline.json`: lower-is-better per key and per scenario, written by `ux/ratchet.ts --update`, committed with the change that improves it. (seen)
- `verified.json`: the CLI versions the skills were last verified against; the Tools job compares it with the newest releases. Updated by hand in a PR. (seen)
B7:
- UX round reports in `website/ux/rounds/` and findings in `website/ux/findings/`. (seen)
- CHANGELOG per release. Nothing else over time: no dashboard, no time series. (seen)

## C. What went wrong
C1:
- 2026-11-23: the skills lagged the newest ESS release (a stale-ESS story is open). The non-required Tools job reported it; nothing blocked. (seen in this session)
- 2026-11-23, after 0.27.0: connectors v0.76.1 shipped, and the Tools job went red on main within hours. Same class: a check that reports but does not block. (seen)
C2:
- Release run, 2026-11-23: macOS arm64 hosted runner never acquired ("The job was not acquired by Runner of type hosted even after multiple attempts"); 1 of 6 recent release runs. Fixed by a re-run. (seen)
- Local `agentplugins-check release verify` read a stale build-time path from an old binary; `cargo clean -p agentplugins-check` first fixed it. Happened in earlier releases this session. (seen)
C3: I don't know of one in this repository.

## D. Friction
D1:
- Up-to-date-with-main rule plus serial merges: each merge of one PR makes the next PR behind; replay + push + 3 checks again. Pre-push hook 3-9 min per push. (seen; per-day total not measured)
- Release is about 8 hand steps (bump 16 version sites, PR, merge, tag, verify, push tag, wait for artifact, checksum, publish): 1.5 h wall time today for 0.27.0, 30 min of it the runner wait. (seen, inferred total)
D2:
- That the 16 version sites must agree, and that skills must name the newest CLI versions, is checked; that a skill's prose still matches the CLI's behaviour is checked only by live evals, which mostly do not run. (seen)
- Docs prose quality (padding, AI register) is kept by running the unslop skill by hand; no check. (seen)
D3: The live eval: it is skipped unless labelled, so a green PR says nothing about model behaviour. (seen: last 5 runs skipped)
D4: n/a

## E. Quality in plain words
E1:
- An agent that installs a plugin gets skills that describe the CLI it will actually run, at its newest release.
- Every plugin installs the same way in both harnesses and every version number agrees.
- The docs site reads on a laptop screen in both themes without sideways scrolling, and a screen reader can use it.
- The docs say each thing once, in plain words, and every command and link in them works.
- A release ships checked binaries for 4 platforms with checksums and setup notes.
E2:
- Checked today: version agreement, manifests, two-harness install shape, docs layout and accessibility, release checksums.
- With work: skills match the newest CLI (exists, needs to block); commands and links in docs work (could be executed or link-checked).
- Never fully: "says each thing once, in plain words" (a heuristic census only).
E3:
- Coding agents: a skill names a flag or subcommand the installed CLI no longer has.
- Developers: `b10x` install or upgrade fails on one of the 4 platforms.
- Docs readers: a page scrolls sideways or a link opens the wrong place.
- Operators (release): a release step that needed a hand fix.
E4: Measured: CLI versions in `verified.json` vs newest release of each tool. Limit: equal, or the newer release is at most 1 day old. Checked: as a required check on every PR and before the tag.
