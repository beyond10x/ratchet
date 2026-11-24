---
format: aep.planning-md/3
id: review-result:parallel-safety-split-round-1
kind: review-result
status: active
title: parallel-safety critic on the split of story:cli-skeleton-validate, round 1
relations:
- reviews: story:workspace-cli-contract
- reviews: story:cli-skeleton-validate
revision: 1
---
needs-revision

Only warnings below. No blocker: the two stories are ordered, and no story of wave 4 or 5 lands on a file of the pair that it did not land on before the split.

Findings (all warnings, all rest on cited surfaces):

story:ui-loop-acceptance — says the root `Taskfile.yml` includes `acceptance/Taskfile.yml` "since `story:cli-skeleton-validate`", but the include is now written by `story:workspace-cli-contract`, and ui-loop-acceptance has no direct edge to it (only through cli-skeleton-validate) — .engineering/planning/story/ui-loop-acceptance.md:60-61, .engineering/planning/story/workspace-cli-contract.md:86
story:assess-command — "the skeleton declared the test module, wired the command" now names the wrong story: `crates/ratchet/tests/main.rs`, `src/commands/mod.rs` and the `assess::unavailable` test it replaces are created by `story:workspace-cli-contract`, which has no direct `depends_on` edge here (order holds only through evidence-reader → cli-skeleton-validate → workspace-cli-contract); name the story or add the edge — .engineering/planning/story/assess-command.md:55-56, .engineering/planning/story/workspace-cli-contract.md:79-85
story:evaluate-command — same as assess-command, and it still lists `crates/ratchet/tests/main.rs` as not edited because "the skeleton" declared it — .engineering/planning/story/evaluate-command.md:58
story:reference-adopt-command — same as assess-command — .engineering/planning/story/reference-adopt-command.md:58
story:workspace-cli-contract — the prose says "`.github/workflows/`: a job" and names `pages.yml` only as the source of the path list, while the typed scope claims `gate.yml` (the file does not exist yet; `ls .github/workflows` shows `b10x-docs-site.yml`, `pages.yml`, `shared-gates.yml`) and `pages.yml` as files it lands on; name the file the job goes in and say whether `pages.yml` is edited or only read — .engineering/planning/story/workspace-cli-contract.md:18-21, .engineering/planning/story/workspace-cli-contract.md:91-92
story:cli-skeleton-validate — the check that the test step fails when an invariant of `ratchet.specification` or `ratchet.config` has no test names no file: it reads `spec/` or `types-report.json` and lands in some script, Taskfile step or test file, and the typed scope and Scope list do not say which; the report-it-later wording leaves the surface open — .engineering/planning/story/cli-skeleton-validate.md:119-122

Judgement on each question:

1. Typed scope against `## Scope` prose.
   - `story:cli-skeleton-validate` matches. Every prose path is in the typed scope: `crates/ratchet-model`, `crates/ratchet-core`, `crates/ratchet/Cargo.toml`, `src/commands/validate.rs`, `tests/validate.rs`, `Cargo.toml`, `Cargo.lock`, `Taskfile.yml`, `check-generated.test.sh`, `AGENTS.md`.
   - Its "not edited" list (`.github/workflows/`, `crates/ratchet-cli-contract/`, `.config/nextest.toml`, `rust-toolchain.toml`) is consistent with the typed scope.
   - `story:workspace-cli-contract` matches except for the `.github/workflows/` mismatch in the findings.
2. Files both stories land on, and whether the plan orders them.
   - Shared files:
     - `Cargo.toml`, `Cargo.lock`
     - `Taskfile.yml`, `AGENTS.md`
     - `.github/scripts/check-generated.test.sh`
     - `crates/ratchet/Cargo.toml`
     - `crates/ratchet/src/commands/validate.rs`
     - `crates/ratchet/tests/validate.rs`
   - `depends_on: story:workspace-cli-contract` (cli-skeleton-validate.md:11) orders them, and `waves` puts them in waves 2 and 3.
   - Both bodies admit the sharing:
     - workspace-cli-contract.md:46-52 says cli-skeleton-validate keeps the model crate and `ratchet validate`.
     - workspace-cli-contract.md:112-113 says cli-skeleton-validate adds the two crates and their dependencies.
     - cli-skeleton-validate.md:87-88 says its two tests replace `validate::unavailable`.
   - So there is no unnamed collision.
3. Wave 4 and 5 stories against the pair.
   - Wave 4 (assessor-declaration, evidence-reader, reference-compare) lands only under `crates/ratchet-core`, which cli-skeleton-validate owned before the split and still owns. Nothing is new.
   - `story:changelog-release-procedure` lands on `AGENTS.md`, which cli-skeleton-validate listed before and now both stories list. It is ordered after both and has no other overlap with the pair.
   - Wave 4 stories do not collide with each other.
   - Wave 5 (assess, evaluate, reference-adopt commands) lands on `crates/ratchet/src/commands/<name>.rs`, `tests/<name>.rs` and `tests/fixtures/<name>`. These files are now created by workspace-cli-contract instead of cli-skeleton-validate.
     - They are ordered after it only transitively, which is why the three findings above exist.
     - The wave 5 stories do not collide with each other.
     - Each edits only its own command and test files, leaving `tests/main.rs` and `commands/mod.rs` to the pair.
   - Shared lists:
     - The test modules in `crates/ratchet/tests/main.rs` are declared once, by workspace-cli-contract (workspace-cli-contract.md:82-85).
     - `check:scripts` runs every `.github/scripts/*.test.sh` by glob, so wave 4 and 6 scripts add no edit to a shared list.
     - No story of waves 4 to 6 lands on `spec/` or `crates/ratchet-cli-contract`, so the digest in generated files is not broken by them.
4. Surfaces named in prose and not in the typed scope.
   - `workspace-cli-contract`:
     - `spec/cli.yaml` and `spec/ess-inputs.yaml` are read only. Their only lander is `story:record-formats-in-spec` (implemented), and the `depends_on` edge is recorded (workspace-cli-contract.md:10).
     - `acceptance/Taskfile.yml` is an optional include, created later by ui-loop-acceptance.
     - The file holding the shared 12-command function is not named. It is inside `crates/ratchet`, so there is no collision.
   - `cli-skeleton-validate`:
     - `examples/*.ratchet.yaml`, `spec/README.md` and the project's `ratchet.toml` are read only. The only lander of the first two is `story:record-formats-in-spec` (implemented), and the edge is recorded.
     - The invariant-comparison location is the one unassessed surface (see findings).

Closing, outside my lane:
- `story:cli-skeleton-validate` is `active` on an approval recorded at revision 6 (cli-skeleton-validate.md:35-36), but its body was rewritten to wait on an open owner question (cli-skeleton-validate.md:58-60) and now depends on a `draft` story.
- The acceptance of workspace-cli-contract lists `validate::unavailable` as passing (workspace-cli-contract.md:69), which cli-skeleton-validate removes when it lands.
- The wave 4 story evidence-reader says it decodes through "the generated decoders of `crates/ratchet-model`" (evidence-reader.md:62), while the open question in cli-skeleton-validate.md:49-60 says there are no typed decoders.

What I read: 13 stories, `.engineering/planning/story/*.md` plus the `git show origin/main` text of cli-skeleton-validate. Commands: `aep plan artifact waves --kind story`, `ls` on the repo and `.github`, and grep over scopes and bodies.

What I could not establish: none. Surface count: 2 stories placed cited, 0 inferred, 0 unplaced. Acceptance reads traced to a producer: 4 for the pair, 4 recorded by a `depends_on` edge (one in workspace-cli-contract.md:10, three in cli-skeleton-validate.md:11). The fifth read, the `acceptance/Taskfile.yml` include read by ui-loop-acceptance, is ordered only transitively.

```findings
[
  {"file": ".engineering/planning/story/ui-loop-acceptance.md", "line": 60, "category": "parallel-safety", "severity": "warning", "message": "names story:cli-skeleton-validate as the one that includes acceptance/Taskfile.yml in the root Taskfile.yml; since the split that include is written by story:workspace-cli-contract (workspace-cli-contract.md:86), which this story reaches only transitively"},
  {"file": ".engineering/planning/story/assess-command.md", "line": 55, "category": "parallel-safety", "severity": "warning", "message": "'the skeleton declared the test module, wired the command' now describes files story:workspace-cli-contract creates (crates/ratchet/tests/main.rs, commands/mod.rs, assess::unavailable); no direct depends_on edge, order holds only through evidence-reader -> cli-skeleton-validate -> workspace-cli-contract; name the story or add the edge"},
  {"file": ".engineering/planning/story/evaluate-command.md", "line": 58, "category": "parallel-safety", "severity": "warning", "message": "same as assess-command: the test module and wiring of crates/ratchet are created by story:workspace-cli-contract, reached only transitively"},
  {"file": ".engineering/planning/story/reference-adopt-command.md", "line": 58, "category": "parallel-safety", "severity": "warning", "message": "same as assess-command: the test module and wiring of crates/ratchet are created by story:workspace-cli-contract, reached only transitively"},
  {"file": ".engineering/planning/story/workspace-cli-contract.md", "line": 91, "category": "parallel-safety", "severity": "warning", "message": "prose names the directory .github/workflows/ and pages.yml only as the source of the path list, typed scope claims gate.yml (does not exist yet) and pages.yml; name the file the job goes in and whether pages.yml is edited or only read"},
  {"file": ".engineering/planning/story/cli-skeleton-validate.md", "line": 119, "category": "parallel-safety", "severity": "warning", "message": "the check that the test step fails on an invariant of ratchet.specification or ratchet.config with no named test lands in a file the Scope and typed scope do not name (script, Taskfile step or test file); surface unassessed"}
]
```
