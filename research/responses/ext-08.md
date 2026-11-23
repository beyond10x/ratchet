# Response: ext-08

- kind and stack: tool plus versioned data archive for release reviews, Python 3.12 (stdlib + one YAML lib), small Node UI test loop
- answered by: coding-agent session that runs the repository's recurring review job
- date: 2026-11-23

## A. The project
A1: Developer tool + archive. ~10.3k tracked files (9.9k are archived review data), ~30k lines Python, 53 test files (seen: `git ls-files`). Users: operators/release managers reading a static site; coding agents that write the reviews.
A2: Reads a release candidate of a multi-service platform, diffs it against what runs in production, collects evidence (tests, tickets, lint, merge requests) and records a scored verdict (go / go-with-conditions / no-go / incomplete) per revision as committed JSON plus a published static page.
A3: Agent sessions do nearly all commits; people review and decide. 365 commits on main in 30 days, 18 in the last 7 (seen: `git log`). One author identity holds 357 of the 365 (seen), so the count does not separate agents from people.

## B. What you track today
B1: Seen. Lint (ruff, 12 rule families, `ruff.toml`) and unit tests (pytest) in local gate and CI, both block. An archive gate fails on: a stale derived view, a review whose score does not recompute, an unreviewed credential/personal-data scan match (27 reviewed allowlist entries), a review that no longer matches its source hash. Schema validation of committed JSON. Coverage: nothing. Complexity: nothing. Dependency age: nothing (stdlib-only by choice).
B2: Seen. The test step has a written budget of 2 minutes. Last run of the full gate before the speed story merged: 1016 s run, 487 s queue wait (reported by the job runner). A story to bring it under 2 minutes merged today; I have not re-measured. Flaky tests: I don't know.
B3: CI: test job on every pipeline, deploy job publishes the site, one scheduled job (20 min timeout) posts a status message. Release frequency of the tool: inferred from commits, not tracked. Lead time, failed releases: nothing.
B4: Seen. UI loop of 7 scripted scenarios on the page, layout contract (no sideways scroll, nav in view), axe-core accessibility (serious/critical), page height and layout shift, run in a headless browser locally only. CI has no browser; what a UI finding fixed is re-checked as an HTML-string pytest. Page size: a 2.9 MB hard refusal before upload to chat. Site size cap: 100 MB host limit, pruned by rule. Production errors, SLOs: n/a (not a service).
B5: Seen. Page upload limit 2.9 MB (refused in code). Attachment limits 1 MB/file, 8 MB/chart (gate fails). Test step 2 min (written rule; not enforced by a runner I could find). UI ratchet tolerances in a JSON file (fails when crossed). Review verdict rules are thresholds on findings (no-go on a confirmed critical fail).
B6: Seen. The UI loop compares every value and gate violation count lower-is-better against a committed `baseline.json`; worse fails, an unrecorded improvement also fails (forces `--update`); a worse baseline than main needs a decision id. Review scores are recomputed, not baselined. Review revisions are compared with the previous revision of the same chart.
B7: Seen. Git history of every review JSON. UI loop writes a per-round report and a trend table (`ux/rounds/trend.md`). Test duration over time: nothing. Review score over time: only through git.

## C. What went wrong
C1: I don't know a regression that reached users; I read no incident record. Seen in the job state: the last daemon-run of the review job before today ended red/orphaned twice because of host problems (a machine crash, a lost ssh key), not a code defect. A check that could have caught a stale-environment cause: none; they were detected by the failure itself.
C2: Seen (indirect): the full gate exceeded a 3480 s step deadline once or more, which the job runner now reports as "waited vs ran". Cause was queueing for a shared build pool plus a slow suite. Count: I don't know.
C3: Seen: a 27-line scan allowlist (each line has a written reason); loosened per finding, never observed tightened. Test deadlines were raised in the job runner (1800 s run, 1080 s queue budget) instead of the suite being sped up until the story above. I cannot say whether either was ever lowered.

## D. Friction
D1: (1) Test/gate wall time: 1016 s run + 487 s wait in the last measured run (seen), which is 12x the written 2-minute budget. (2) Derived views must be re-rendered and committed after any renderer change; a stale view fails the gate (seen; minutes per change: I don't know).
D2: Rules live in the repository's `AGENTS.md` (seen: ~580 lines) and in CHANGELOG entries for scoring rules; which findings are real defects lives in the reviewing agent's judgement and a person's later reading. A person's sign-off or a delegated visual check is recorded only when that person gave it.
D3: Inferred: the headless UI loop (local-only, not in CI, so it can go stale) and any claim of "no test results published" made without reading the pipeline's artifacts (an earlier miss is recorded in AGENTS.md).
D4: n/a for most areas. Coverage and complexity: not needed yet (small stdlib code base, review data dominates).

## E. Quality in plain words
E1: A review is good when every claim in it points at evidence a reader can open: a commit, a test name, a run. The page shows what is unknown as unknown, never as passed. A derived file always equals a fresh render of its source. Nothing secret or personal gets published. The page is readable on a laptop without sideways scrolling and keyboard-reachable.
E2: Machine today: derived files fresh, scores recompute, schemas valid, secret scan, size caps, layout and accessibility rules. With work: every cited test exists at the cited revision; step time budgets enforced by the runner; page load time. Never: whether a judged finding is right; whether the verdict was the correct call for the release.
E3: End users (readers): a number on the page that is wrong or missing evidence. Developers: gate wall time rising above 2 minutes. Coding agents: a gate that is red for host reasons (queue, missing key) and says so poorly. Operators: a review that says go and the release then fails on something the review listed as "not checked". API consumers (the JSON files): a schema change with no version bump.
E4: Gate wall time (run, not queue) of the full test step must be <= 120 s, enforced by the runner killing at 120 s, checked on every pull request, and a baseline file that only lowers.
