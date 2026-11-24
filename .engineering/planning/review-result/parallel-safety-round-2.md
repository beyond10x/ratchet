---
format: aep.planning-md/3
id: review-result:parallel-safety-round-2
kind: review-result
status: active
title: parallel-safety critic, round 2
relations:
- reviews: story:cli-skeleton-validate
- reviews: story:record-formats-in-spec
- reviews: story:evidence-reader
- reviews: story:assessor-declaration
- reviews: story:reference-compare
- reviews: story:assess-command
- reviews: story:reference-adopt-command
- reviews: story:evaluate-command
- reviews: story:ui-loop-acceptance
- reviews: story:acceptance-in-gate
- reviews: story:changelog-release-procedure
- reviews: story:release-0-1-0
revision: 1
---
approve

What I read: all 12 stories (`aep plan artifact show story:<id>` for each), `aep plan artifact waves --kind story` and `review-result:parallel-safety-round-1`. I also read `spec/domains/config.yaml` and `docs/design.md` for how `ratchet.toml` is decoded, and listed the worktree root. The root has a `LICENSE`, no `crates/` and no `Cargo.toml`, so the generated crates are not on `main` yet. Surfaces placed from cited bodies: 12 of 12. By inference: 0 for placement. One inference is that the generated model crate decodes every `ratchet.toml` section, so no later story edits a config reader. It rests on `config.yaml` declaring `catalog`, `records`, `environment` and `tools` as struct members. Unplaceable: 0. Acceptance reads traced to a producer in the set: 28, of which 25 are recorded by a `depends_on` edge. The other 3 are `story:ui-loop-acceptance` reading the output of `assess`, `reference adopt` and `evaluate` (steps 2 to 7). They have no edge, and the body states that a step failing because its command is not built is the expected state and that the run prints the count the merged commands reach (`ui-loop-acceptance.md:65`). I do not count them as defects.

Per wave:
- **Wave 3** (assessor-declaration, changelog-release-procedure, evidence-reader, reference-compare): no two stories share a file. Each story's scope lists only its own `src` module, test file and fixtures, all created empty by the skeleton, which the ordering edge covers. Each body says that `tests/main.rs`, `Cargo.toml` and `Cargo.lock` are not edited. `assessor-declaration` alone lists `validate.rs` and says no other story of the wave edits it (`assessor-declaration.md:49`). `changelog-release-procedure` is the only story of the wave on `AGENTS.md`, `CHANGELOG.md` and `.github/workflows/release.yml`.
- **Wave 4** (assess-command, evaluate-command, reference-adopt-command, ui-loop-acceptance): no two stories share a file. The three commands each own their `commands/*.rs`, test file and fixtures, all pre-created and pre-wired by the skeleton. `ui-loop-acceptance` owns only `acceptance/` and `ROADMAP.md`.
- **`ROADMAP.md`, `CHANGELOG.md`, `README.md`, `Taskfile.yml`, `Cargo.toml`** are each touched across waves 4, 5 and 6, and every pair of those stories has a `depends_on` path between them. The shared files are ordered, so the plan says so.
- **No story names no surface.**

Round-1 findings, all resolved:
- **Core test modules**: the skeleton now creates them with their files (`cli-skeleton-validate.md:54-55`).
- **Binary test modules**: the skeleton now creates them (`cli-skeleton-validate.md:59-60`).
- **Dependencies, `evidence-reader` and `reference-compare`**: the skeleton declares SHA-256, a decimal type, a YAML reader and a TOML reader (`cli-skeleton-validate.md:61-64`).
- **Dependencies, `assess-command` and `evaluate-command`**: the child process uses the standard library and git goes through the `git` binary (`cli-skeleton-validate.md:62-64`, `assess-command.md:46`, `evaluate-command.md:48`).
- **`CHANGELOG.md` lines**: `acceptance-in-gate` writes them (`acceptance-in-gate.md:44`), and each wave story says it writes none.
- **`validate.rs` and the generated crates in `assessor-declaration`**: `validate.rs` is now in scope (`assessor-declaration.md:7`), and the body says no generated file changes (`assessor-declaration.md:47`).
- **`record-formats-in-spec`**: it owns every `spec/` change and lands before any generated file exists (`record-formats-in-spec.md:32-35`, `:100`).
- **`ui-loop-acceptance`**: it now has `depends_on` edges to `assessor-declaration` and `record-formats-in-spec` (`ui-loop-acceptance.md:10-11`).

What I could not establish:
- I cannot see the code, so I cannot confirm that the skeleton's `lib.rs` and `validate.rs` declare every pre-created module (`evidence`, `assessor`, `reference`, `compare`, `store`, `assess`, `adopt`, `gate` and `validate/assessor`). The body says it creates them (`cli-skeleton-validate.md:51-55`).
- `story:evaluate-command` reads the policy from a git revision (`evaluate-command.md:37`), while the skeleton's `spec` module reads files from the working tree. Evaluate may need a loader on the skeleton's `spec` module that its scope does not list. No other story of the set edits that module, so this is not a collision, but it is a scope gap. It belongs to the design or scope critic.
- Out of my lane, and it does not set my verdict: the skeleton's typed scope is the whole `crates` directory.
- Out of my lane: the acceptance of `evidence-reader` reads `.ratchet/records` for the case "without `[records] store`". `RecordsSection.store` is required in `spec/domains/config.yaml:61-62`.

```findings
[]
```
