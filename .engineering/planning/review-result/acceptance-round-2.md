---
format: aep.planning-md/3
id: review-result:acceptance-round-2
kind: review-result
status: active
title: acceptance critic, round 2
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
needs-revision
story:acceptance-in-gate — the acceptance says the getting-started check compares every block "with the transcript the acceptance run writes", but no story makes the run write one: `story:ui-loop-acceptance` prints only `ok`/`FAIL` per step and a count, and `run.sh` and `acceptance/` are outside this story's scope, so the check has nothing to compare against — .engineering/planning/story/acceptance-in-gate.md:45
story:changelog-release-procedure — the acceptance prints one `ok` per case and lists none for `release-verify.sh` (bot author, three assets attached, `sha256sum -c`, version printed), although the Notes say it is tested against a recorded release description and `story:release-0-1-0` takes its exit status as its own acceptance, so the script can be absent or wrong and this story still closes — .engineering/planning/story/changelog-release-procedure.md:41

What I read: all 12 stories (11 round-1 stories plus `story:release-0-1-0`) with `aep plan artifact show` for each, `review-result:acceptance-round-1`, `aep plan artifact waves --kind story`, the store files for line numbers, and in the worktree `Taskfile.yml`, `spec/cli.yaml` (error lists of `reference-adopt` and `evaluate`), `spec/domains/cli.yaml` (ValidationCode names), `spec/domains/reference.yaml` (change kinds), `spec/domains/config.yaml` (`[records] store`), and `docs/evidence-format.md` § 10 "Exit status". Commit `7673482` exists in the history.

Round-1 findings:
- `story:cli-skeleton-validate`: resolved. The drift outcome is now the script `check-generated.test.sh` listed in the gate output.
- `story:record-formats-in-spec`: resolved. The script prints `<n> of <n> field rows declared` and exits 1 on commit `7673482`, and the generator's refusal is the stated before-state.
- `story:evidence-reader`: resolved. `store::write_list_read` is named.
- `story:reference-compare`: resolved. The cause is now the one the result carries, and the rows are named.
- `story:assess-command`: resolved. `assess::report_file` is named.
- `story:reference-adopt-command`: resolved. The second call is `not_better` with the file bytes unchanged.
- `story:acceptance-in-gate`: partly resolved. The check is now named, but the finding above is new.
- `story:changelog-release-procedure`: resolved for the archive, `SHA256SUMS`, archive contents and notes. The finding above is what remains.

Judged sound, no finding: `story:assessor-declaration`, `story:evaluate-command`, `story:ui-loop-acceptance`, `story:release-0-1-0`.

Could not establish:
- Whether the `ess generate synthesize` output prints the "0 refused" line `story:record-formats-in-spec` quotes. It is quoted from the story's measurement, and I ran no generator.
- Whether `docs/evidence-format.md` § 3 and § 10 rows can be read by a POSIX sh script. Reading the rows is the story's own work.
- `story:release-0-1-0` calls `release-verify.sh 0.1.0` against the live release, while the changelog story tests that script against a directory and a recorded description. Whether both call forms are one interface is for the design critic.

Out of my lane, not set into the verdict: the 40 file collisions in `waves`, and the `ROADMAP.md` collisions between `story:release-0-1-0`, `story:ui-loop-acceptance` and `story:acceptance-in-gate`, belong to the parallel-safety critic.

```findings
- file: .engineering/planning/story/acceptance-in-gate.md
  line: 45
  category: acceptance
  severity: blocker
  verdict: needs-revision
  origin: introduced
  message: "the acceptance compares every command and output block of docs/getting-started.md with 'the transcript the acceptance run writes', but no story makes the run write a transcript (story:ui-loop-acceptance prints ok/FAIL per step and a count; run.sh and acceptance/ are outside this story's scope), so the getting-started check has nothing to compare against"
- file: .engineering/planning/story/changelog-release-procedure.md
  line: 41
  category: acceptance
  severity: warning
  verdict: needs-revision
  origin: introduced
  message: "the acceptance names no case for release-verify.sh (bot author, three assets attached, sha256sum -c, version printed), although the Notes say it is tested against a recorded release description and story:release-0-1-0 uses its exit status as its own acceptance, so the script can be absent or wrong and this story still closes"
```
