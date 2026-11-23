# Response: ux-ui

- kind and stack: agent plugin (Claude Code + Codex) holding one skill, a measured UI improvement loop; Markdown, JSON manifests, POSIX sh + jq checks
- answered by: the session that created the repository and ran the skill once
- date: 2026-11-23

## A. The project
A1: Agent plugin, docs-heavy. 21 tracked files, 1327 lines (`git ls-files | xargs wc -l`). Users: coding agents (the skill), developers who install the plugin. seen
A2: Gives agents a procedure to improve a web UI in measured rounds (trial, measure, triage, design decision, build, gate), with hard gates on every merge, findings turned into regression tests and lower-is-better ratchets against a baseline. Also holds research and reviews on making UI/UX quality machine-checkable from a specification. seen
A3: Agent sessions only so far. 1 commit (created 2026-11-23), no remote yet. seen

## B. What you track today
B1: `task check` (Taskfile.yml): `claude plugin validate --strict` on plugin and marketplace; `tools/check-plugin.sh` (manifests and marketplaces agree on name/version/description/author/license/repository, CHANGELOG has the version, every skill has `name` = dir and `description`, every `references/` path a skill names exists); `tools/check-plugin.test.sh` 8 cases that plant a broken copy and expect the check to fail. Local only, 2.0 s, exit 0. Nothing on coverage, lint of prose, links. seen
B2: Gate time 2.0 s wall (seen). Nothing measured over time.
B3: nothing: no CI, no remote, no release yet. seen
B4: The repo's product is a procedure; its "product check" is running it on a UI. Run once this session on a one-file explainer page (outside the repo): 304 Playwright tests, 6 gate kinds (no horizontal overflow, result element in viewport, completion visible, screen-only bot completes each scenario by role+name, axe-core 0 serious/critical WCAG 2.2 AA, keyboard-only), 30 walks x 14 metrics. R-01: 20 of 74 gating tests red, 12 findings filed. seen
B5: In the skill (SKILL.md § 4, § 6): no-scroll, always-visible = 100 % in viewport, completion_miss = 0, false_complete = 0, axe serious+critical = 0, cue accuracy >= 95 %, every fix <= 2 actions; tolerances counts 0, steps 5 %, layout_shift 0.01. Crossing fails the merge. seen (as written; enforced only where a project builds the harness)
B6: Skill: `ux/baseline.json` {scenario: {metric: {value, tolerance, decision?}}}; compared with the baseline on `main` via git; an improvement must be written into the baseline in the same merge; making it worse needs a decision id. In the run: baseline written from R-01's own walks, so the first ratchet "pass" compared a value with itself (reviewer finding T5). seen
B7: Skill: `rounds/trend.md`, one row per round. One row so far. seen

## C. What went wrong
C1: n/a for the repo (1 day old). In the run: the keyboard-only scenario reported completion_miss 0 while 2 of 3 sub-tasks were never done (a `not_done` truth counted as no miss); trend said 2 misses, the true count is 12. Caught by an independent report reviewer recomputing from raw walks, same day. A unit test per truth kind would have caught it. seen
C2: Wall time: the round reported 1912 s; Playwright's own run was 108.6 s, the rest was waiting for a shared build slot (host disk and CPU holds). A test-budget check on wall time would go red on queue wait. Once, this session. seen
C3: In the run, layout shift within 500 ms after a scripted action was excluded (scripted clicks are not trusted input, so the browser's own exclusion did not apply). Defensible but a loosening; not revisited. seen

## D. Friction
D1: Queue wait for browser runs on a shared machine: about 30 min of 32 min round time (seen). Second: a ratchet that is green on the first run proves nothing (inferred cost: false confidence, not minutes).
D2: (1) Whether readers understand the page: no metric for comprehension or for a false statement on the page (a demo printed a wrong verdict; triage ranked it 0.50, below the change set). (2) "Equal visual weight, no focus": the original author of the loop reports it climbs effort metrics but does not improve design; two of their metrics showed the same value on all 28 design variants. Lives in a review file and research notes in this repo, nowhere checked. seen
D3: Metrics read at a scroll position (reading load = words in the end viewport) and page-level results summed per scenario (one axe defect counted 12 times). Also the triage formula: weights 9/3/1 and a guessed cost make judgement look like arithmetic. seen
D4: The repo itself tracks little: created today, research phase, the owner's direction is to build its tooling with zero third-party dependencies over time. seen

## E. Quality in plain words
E1: A person can finish every task on the screen without hunting, scrolling sideways or guessing what to do next. Everything needed is visible and reachable by keyboard and pointer alike. What the screen says is true. The same task never gets harder after a change unless someone decided that trade-off on purpose. The design shows what matters first.
E2: Now: visible, reachable, keyboard parity, no sideways scroll, "never harder without a decision" (action counts, a ratchet with decision ids). With work: "what the screen says is true" (a check of rendered content against a declared source, as a UI spec renderer can do), "without guessing" (a deterministic bot plus a model probe as a proposal only). Never fully: "shows what matters first" (aesthetics, focus); only proxies such as one emphasis per region.
E3: End users: a task takes more clicks or a control drops below the fold. Developers: a red gate that was red for the queue, not the code. Coding agents: a gate they can make green by editing the baseline or the scenarios. Operators: rounds that cost paid model calls with no bound per run.
E4: Every closed S1/S2 finding names a regression test that failed before its fix and passes after; checked in the local gate on every change.

## Notes for ratchet
Seen, from a read-only sweep of the org this session: the same UI loop with its own baseline.json and ratchet exists 7 times in 3 languages: modelspec/ui/ux, slot/ui/ux, slot/website/ux, runbook/ui/ux, conductor dashboard/ux and conductor/ux, substrate/xtask/src/site_ux.rs. runbook/ui/ux `ratchet.mjs:43-44` has a tolerance band; modelspec `self-test.spec.ts` and conductor `breaks.ts` plant defects to prove a gate can fail. Research notes in the ux-ui repository: research/2026-11-23-internal-building-blocks.md, research/2026-11-23-external-machine-checkable-ux.md (ratchet practice: median of 5 for noisy metrics, baseline keyed by rule and scope, lowered only by an explicit command).
