---
format: aep.planning-md/3
id: review-result:acceptance-split-round-2
kind: review-result
status: active
title: acceptance critic on the split of story:cli-skeleton-validate, round 2
relations:
- reviews: story:workspace-cli-contract
- reviews: story:cli-skeleton-validate
revision: 1
---
needs-revision

All findings are warnings. Neither story has a blocker.

story:workspace-cli-contract — the CI-job bullet asks for "one [case] for a change that runs that job and one for a change that skips it". `task check:ci-paths` already holds `code|Taskfile.yml` and `planning|.engineering/planning/story/x.md`, and it only compares the classifier's `class=` output. So the bullet reads the same before the work as after it. Name what a new case asserts about the job (for example the job's `if` result for a `code` list and for a `planning` list) — .engineering/planning/story/workspace-cli-contract.md:80
story:workspace-cli-contract — the acceptance observes the `check:scripts` step and the `test` step through `slot task check`. The scope lists `check:scripts`, `check:generated`, `check:rust` and `test` as tasks to add, but never says `check` runs them. `check` currently runs only `aep plan artifact validate`, `check:spec`, `check:ci-paths` and `site`. Without that edit `task check` exits 0 with none of the named steps. `check:rust` (fmt and clippy) is named in no acceptance bullet — .engineering/planning/story/workspace-cli-contract.md:101
story:workspace-cli-contract — the pinned compiler (Context, line 43; scope line 86) and the nextest 60 s bound with the 120 s step bound (Notes, lines 119-120, 123-124) are promised but no acceptance bullet observes them. This is the part of round-1 finding 3 that is still open. Either add a statement a person can see pass, such as "the CI job installs the channel `rust-toolchain.toml` names", or move both out of the story's promise — .engineering/planning/story/workspace-cli-contract.md:123
story:cli-skeleton-validate — `validate::accepts_examples` requires only "no finding `schema_violation`". The unavailable stub also meets that: it prints no finding at all. A `validate` that fails with `spec_unreadable` meets it too. Add the exit status or a report with a `valid` field, or name a successful outcome — .engineering/planning/story/cli-skeleton-validate.md:81
story:cli-skeleton-validate — the "What `ratchet validate` checks" section and the scope promise `schema_violation` on a file that does not decode, and `unresolved_reference` for a missing assessment, measurement or requirement. Scope also promises the `invariants` test. The acceptance observes only `duplicate_id` as a refusal. A `validate` that never emits `schema_violation` or `unresolved_reference` meets all four bullets, and the byte-flip bullet does not touch `invariants`. Add a refusal case for each, or drop the promise from the section — .engineering/planning/story/cli-skeleton-validate.md:121

**Round-1 findings of this lane**

- Contract, "lists as passed the script": resolved. The bullet now names the `check:scripts` step and the script's exit-0 condition (`workspace-cli-contract.md:77-79`). It has a new gap, the wiring finding above.
- Contract, circular unavailable answer: resolved. The bullet names exit 1, empty standard output and the line `cli_handler_unavailable` on standard error. I generated the CLI package with the installed `ess` into scratch. `src/runtime.rs:864` maps `HandlerReply::Unavailable` to `internal(output, 1, "cli_handler_unavailable")`. `failure` at `:449` leaves stdout empty. In the default human mode stderr is exactly `cli_handler_unavailable` followed by a newline. In `--output json` mode stderr is a JSON object instead, so "the line" holds only for human mode. The tests must not pass `--output json`.
- Contract, CI job, toolchain and nextest unobserved: partly resolved. The CI job is now observed by the green PR run and the `check:ci-paths` cases, with the weakness in my first finding. The toolchain pin and the nextest bound are still unobserved, per my third finding.
- Skeleton, `accepts_valid_project` names no project: resolved. The bullet names the fixture directory and its contents (assessment with a measurement, a requirement naming both, a gate naming the requirement). `accepts_examples` moved into the acceptance. The five `examples/*.ratchet.yaml` files exist. The gap left is the fourth finding.
- Skeleton, dependency checkable only at its merge point: resolved. Contract acceptance says "in a clean checkout of this story's merge commit", and its Notes say each of the four `unavailable` tests is replaced by the story that builds the command (`workspace-cli-contract.md:68`, `:115-116`).

**Skeleton under either generator answer**

- Checkable under either answer. Every bullet observes behaviour (exit status, `valid: true`, code `spec_invalid`, finding `duplicate_id`) or a byte-flip on `crates/ratchet-model/`, and none names a generator's output shape.
- The script test reads one line per generated crate, so the byte-flip case needs no wording change.
- If the answer is to wait for ESS to emit decoders, the story does not start and there is nothing to judge.
- The fourth and fifth findings do not depend on the answer.

**New from the corrections**

My first, second and fourth findings are new; the third and fifth are residual gaps of round 1 or earlier. The conjunction-of-bullets form of both acceptances (several checks under one `slot task check`) is the same in round 1. I did not raise it, since each bullet is separately checkable.

**Read:** both ids in full (2 of 2): `story:workspace-cli-contract` and the rewritten `story:cli-skeleton-validate`. Also read:
- the `origin/main` text of `cli-skeleton-validate`;
- `review-result:acceptance-split-round-1`;
- `Taskfile.yml`, `spec/cli.yaml` (16 commands, so 12 plus 4 is right; `validate` takes `--spec` as one file) and the `ValidationReport` and `ValidationCode` entries of `spec/domains/cli.yaml`;
- the `examples/` list;
- the CLI package I generated once into scratch, with the output only under the scratch path.

**Could not establish:**
- Whether the five examples decode without a `schema_violation`. I built and ran nothing.
- Whether `ess generate types` or `synthesize` has a check mode, or carries a spec digest in every file. The scope allows a byte comparison either way.
- Whether `check:ci-paths` cases can observe the job's `if` condition. That depends on how the new job is written.

Out of my lane: the shared edit of `check-generated.test.sh` and `check-generated.sh` across the two stories is parallel-safety. Whether the 12/4 command split matches the wave is scope.

```findings
[
{"file":".engineering/planning/story/workspace-cli-contract.md","line":80,"category":"acceptance","severity":"warning","message":"The CI bullet asks for one check:ci-paths case that runs the job and one that skips it, but the task already holds code and planning cases and compares only the class, so the bullet reads the same before the work as after it. Name what a new case asserts about the job."},
{"file":".engineering/planning/story/workspace-cli-contract.md","line":101,"category":"acceptance","severity":"warning","message":"The acceptance observes the check:scripts and test steps through slot task check, but the scope lists them as new tasks without saying that the check task runs them; check:rust is named in no acceptance bullet. task check can exit 0 with none of the steps wired."},
{"file":".engineering/planning/story/workspace-cli-contract.md","line":123,"category":"acceptance","severity":"warning","message":"The pinned compiler (Context line 43, scope line 86) and the nextest 60 s and 120 s bounds (Notes lines 119-120) are promised but no acceptance bullet observes them."},
{"file":".engineering/planning/story/cli-skeleton-validate.md","line":81,"category":"acceptance","severity":"warning","message":"validate::accepts_examples requires only no finding schema_violation, which the unavailable stub, which prints no finding, and a spec_unreadable failure also meet; add the exit status or valid field."},
{"file":".engineering/planning/story/cli-skeleton-validate.md","line":121,"category":"acceptance","severity":"warning","message":"Scope and the 'What ratchet validate checks' section promise schema_violation on an undecodable file, unresolved_reference, and the invariants test; the acceptance observes only duplicate_id as a refusal, so a validate that never emits the other two satisfies every bullet."}
]
```
