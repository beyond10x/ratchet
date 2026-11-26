---
format: aep.planning-md/3
id: review-result:critic-acceptance-musl-static-release-round-1
kind: review-result
status: active
title: acceptance critic on story:musl-static-release, round 1
relations:
- reviews: story:musl-static-release
revision: 1
---
Acceptance critic, round 1, on `story:musl-static-release`. Verdict: needs-revision; items 1, 3,
4, 6 and 7 of the draft were not checkable as written. All findings were taken into the body of
the next revision; no second round was run.

- AGENTS.md § Release has steps 1 to 6; the archives are named in steps 4, 5 and 6, the opening
  sentence, § Gate and § The scripts.
- The upload is the `gh release create` of step 5, not the workflow.
- `readelf -d` on a static binary prints no dynamic section and exits 0: the static check needs
  a script with cases on both sides and a mutant.
- The Alpine image is pinned by digest; the command and the jobs that run it are named.
- The CI step runs under `task == 'check'` on the job's checkout; both install steps name the
  musl target; `rust-toolchain.toml` pins it.
- The local gate runs the static check and `env -i <binary> --version`; the Alpine run is the
  one forge-only part.
- The time bounds of nextest do not cover a build: the warm time of `check:static` ends within
  120 s and the cold time is reported.
- `release-verify.sh` runs the gnu binary only (line 175); it gains the static check and
  `--version` on the musl binary, with two mutants.
- mimalloc needs a carrier artifact: `story:mimalloc-measure`.

```findings
[
{"file":"AGENTS.md","line":262,"category":"acceptance","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"item 6 names steps 6 and 7; the release steps that name archives are 4, 5 and 6, plus the opening sentence, the Gate table, the needs list and The scripts"},
{"file":"AGENTS.md","line":287,"category":"acceptance","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"the upload is the step 5 gh release create asset list, not release.yml; name it in item 1 or release-verify.sh exits 1 on a real release"},
{"file":".github/scripts/release-verify.sh","line":175,"category":"acceptance","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"run_target is gnu only; the musl binary gets the static check and --version, and asset counts become 4"},
{"file":".github/scripts/release.test.sh","line":1240,"category":"acceptance","severity":"note","verdict":"needs-revision","origin":"introduced","message":"the target equality is already derived from release-package.sh targets; replace the equality case with mutants for a musl runner change and a dropped static check"},
{"file":".github/workflows/release.yml","line":133,"category":"acceptance","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"pin the alpine image by digest, name the docker command, and add a negative control for the static check"},
{"file":".github/workflows/pages.yml","line":144,"category":"acceptance","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"state the new step under task check, the musl target in both install steps, and that the pull request checkout is the merge commit"},
{"file":"Taskfile.yml","line":12,"category":"acceptance","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"name the task check:static, its place in check, and the local env -i --version run; the Alpine run is the one forge-only part"},
{"file":"Taskfile.yml","line":54,"category":"acceptance","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"item 7 has no number; give 120 s warm for check:static, report the cold time, keep cargo out of test"},
{"file":"rust-toolchain.toml","line":3,"category":"acceptance","severity":"warning","verdict":"needs-revision","origin":"introduced","message":"add targets x86_64-unknown-linux-musl so the local gate and CI read one pin"},
{"file":".engineering/planning/story/musl-static-release.md","line":1,"category":"scope","severity":"note","verdict":"needs-revision","origin":"introduced","message":"the mimalloc deferral has no carrier artifact; create a follow-up story"}
]
```
