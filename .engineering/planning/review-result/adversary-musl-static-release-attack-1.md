---
format: aep.planning-md/3
id: review-result:adversary-musl-static-release-attack-1
kind: review-result
status: active
title: adversary on story:musl-static-release, attack 1 on bc0be3f
relations:
- reviews: story:musl-static-release
revision: 1
---
Adversary, attack 1 on `story:musl-static-release`, diff 6a34e7a..bc0be3f. Verdict: one warning
and five notes, no blocker; all introduced. `release.test.sh`: 156 of 156 cases pass, 15 s on the
build node; no cost is paid again per case (archives built once and copied). 25 mutants of the
attacker ran in a harness copy; 10 survived, 4 of them findings.

## Could not break

- `static-check.sh` on real binaries on both hosts: the musl ratchet (static-pie), a glibc
  static-pie and a Go static binary pass; a dynamic binary (`NEEDED` and `INTERP`), a shared
  library (`NEEDED` only) and a binary asking for an interpreter only are refused with each entry
  named; a non-ELF file, an empty file, a directory and a missing `readelf` are refused; a path
  with spaces, `llvm-readelf`, `LC_ALL=de_DE` and `gawk --posix` give the same results.
- The digest is the index digest of `alpine:3.24.4` (read anonymously from the registry), an
  OCI index with an amd64 entry. The workflow command prints `ratchet 0.0.3` on the musl binary
  and exits 255 on a glibc binary.
- Every path of a musl target in `Package` passes the shell `if`; docs-site and planning
  classes skip the step; the host's linker flags apply to the gnu target only.

```findings
[{"file":"Taskfile.yml","line":35,"category":"mutant","severity":"warning","verdict":"CONFIRMED","origin":"introduced","message":"no script test reads check:static, and the Alpine step passes a binary that asks for the musl interpreter, so dropping the static-check call keeps the PR gate green"},
{"file":".github/workflows/pages.yml","line":234,"category":"judgement","severity":"note","verdict":"CONFIRMED","origin":"introduced","message":"docker resolves alpine:<any tag>@<digest> by digest alone, so ALPINE_VERSION is never checked against the digest"},
{"file":".github/scripts/static-check.sh","line":32,"category":"boundary","severity":"note","verdict":"INFEASIBLE","origin":"introduced","message":"readelf exits 0 with Error lines on a truncated ELF and static-check reports it static; nothing builds that state"},
{"file":".github/scripts/release-verify.sh","line":117,"category":"contract-drift","severity":"note","verdict":"CONFIRMED","origin":"introduced","message":"release-verify.sh now refuses a release published before the musl archive (0.0.3 shape) at the asset check, and no document says so"},
{"file":".github/scripts/release.test.sh","line":858,"category":"mutant","severity":"note","verdict":"CONFIRMED","origin":"introduced","message":"mutants survive: readelf -l status unread, unnamed INTERP accepted, refusals on stdout, musl binary run before its static check"},
{"file":"AGENTS.md","line":330,"category":"contract-drift","severity":"note","verdict":"CONFIRMED","origin":"introduced","message":"a new target is no longer one word plus one matrix entry when it is a musl target"}]
```
