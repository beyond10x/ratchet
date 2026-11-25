---
format: aep.planning-md/3
id: review-result:adversary-changelog-release-procedure-attack-1
kind: review-result
status: active
title: adversary, story:changelog-release-procedure, attack 1 of 2
relations:
- reviews: story:changelog-release-procedure
revision: 1
---
Recorded by the coordinator from the adversary's report, verbatim except that the absolute paths of the workstation are replaced: `<S>` is the adversary's scratch directory, `<W>` the managed worktree of the unit.

findings: 9, 8 reproduced with a command (1 is a judgement on `AGENTS.md`). None is a defect that stops the first release when the procedure is followed as written; all are `warning`.

```
unit: story:changelog-release-procedure, commit ffe3e4b (tree <W>)
verdict: CONFIRMED
cases: executed 40→40 in the tree (no tracked file may be edited); 7 case files in scratch, red 7
origin: introduced 9 / pre-existing 0 / undecided 0
wrote-outside-worktree: 1 directory (scratch, listed in part 6)
needs-coordinator: none
```

`S` below is `<S>`. Every case runs as `sh $S/cases/<case>.sh $S/copy`, where `$S/copy` is `git archive ffe3e4b`. Outputs are in `$S/out/<case>.txt`.

## 1. `git --no-pager diff --stat` of the tree

Empty, and `git status --short` is empty. No file of the tree was touched.

## 2. Findings, each with its case (run alone, before the suite)

**F1. A release commit whose dated section holds no change passes `release-check.sh` and the whole suite; the run fails in its last job.** CONFIRMED, introduced.
- Measured: `sh $S/cases/c1-empty-section.sh $S/copy` exits 1.
  ```
  release-package: CHANGELOG.md has no notes for 1.2.3      (exit 1, the job Bundle)
  FAIL release-check.sh for a tag whose section holds no line: accepted, exit 0
       release-check: CHANGELOG.md has the section `## [1.2.3] - 2026-01-02`
  ```
- Reach: step 1 of § "Release" with the heading put below the lines instead of directly below `## [Unreleased]`. On the real `CHANGELOG.md` with `## [0.0.1] - 2026-11-25` appended: `release-check.sh 0.0.1` exit 0, `release.test.sh` 40 of 40, `release-package.sh notes 0.0.1` exit 1. The tag is pushed, Gate and both Package jobs pass, Bundle refuses.
- Also: `notes` accepts a section of `### Added` and `### Fixed` with no bullet (exit 0, prints the two headings), so such notes would be published.
- File: `.github/scripts/release-check.sh:66`, `.github/scripts/release-package.sh:119`.
- Smallest change: `release-check.sh` also requires a `- ` line in the section (or calls the notes cut), and `notes` requires a bullet. The case belongs in `release.test.sh`, section "release-check.sh".

**F2. § "Release" has no step for a tag run that fails.** CONFIRMED, introduced, judgement.
- `AGENTS.md:233` (step 4) goes from "wait for it" to "download its artifact". The workflow has one trigger, the tag, so its first run is the first release. A session is not told whether a failed run is rerun (a GitHub write), or whether the tag stays and the next patch version is cut, or what happens to the changelog section of the version that was never released.
- Reach: any red run of step 4.
- Smallest change: two sentences in step 4.

**F3. The three workflow cases of `release.test.sh` check that texts are present, not what the workflow does: 15 of 16 workflow mutants pass.** CONFIRMED, introduced.
- Measured: `sh $S/mutants.sh $S/copy $S/mut` (list in part 4). Surviving: `needs` of either job removed, the download pattern or `merge-multiple` changed, `--locked` dropped, the arm runner replaced, the final upload cut to `dist/*.tar.gz`, `task check || true`, `release-check.sh ... || true`, the archive written to another directory than the uploaded one.
- Reach: any later edit of `release.yml`; nothing else runs the workflow before a tag.
- File: `.github/scripts/release.test.sh:588` (`workflow_trigger`, `workflow_calls`).
- Smallest change: read `needs`, the upload name and download pattern pair and the upload paths with awk, and run the `run:` blocks of Package and Bundle taken from the file with a stub `cargo`, as `task check:ci-paths` does with the classifier step of `pages.yml`.

**F4. The stand-in for `gh` ignores its arguments, and other script lines have no case.** CONFIRMED, introduced.
- Measured, all `release.test.sh` exit 0:
  - `--json assets,author` only (a real release would then always be refused as "does not say whether ... draft");
  - `--repo` dropped from both calls;
  - the `--pattern` list dropped;
  - `SHA256SUMS` may name an archive twice;
  - the `EXIT` trap removed (16 `release-verify.*` directories left in `TMPDIR`);
  - check 5 run on the x86_64 archive only;
  - `--owner=0 --group=0 --numeric-owner`, `chmod 755`, `chmod 644`, the second `rm -rf` and `sha256sum -c` in `sums` each removed;
  - `version_of` accepting `v1.2.3`.
- Reach: the `gh` lines first run for real in step 6 of the first release. As written they are right; I ran them against the real `gh` (part 5).
- File: `.github/scripts/release.test.sh:104` (stand-in), `:564` (`gh_reads`).
- Smallest change: the stand-in refuses a call without `--repo beyond10x/ratchet`, without the four `--json` fields or without the three `--pattern` values; one case with a bad member in the aarch64 archive.

**F5. `release-verify.sh` passes a release with a fourth asset and says "its 3 assets are attached".** CONFIRMED, introduced.
- Measured: `sh $S/cases/c2-verify-extra-asset-prerelease.sh $S/copy` exits 1: `FAIL release-verify.sh for a release with a fourth asset: accepted, exit 0`.
- Reach: step 5 as written attaches exactly three files. A session that passes a glob (`target/release-assets/*` attaches `notes.md`; the sibling's procedure uses a glob), or an asset added later by hand.
- File: `.github/scripts/release-verify.sh:107`.
- Smallest change: compare the sorted names of `.assets[]` with `release-package.sh assets`.

**F6. `release-verify.sh` passes a prerelease.** INFEASIBLE (nothing in step 5 passes `--prerelease`), introduced.
- Measured: same case, `FAIL release-verify.sh for a prerelease: accepted, exit 0`. The `gh release view` call does not ask for `isPrerelease`.
- File: `.github/scripts/release-verify.sh:91`.
- Smallest change: add `isPrerelease` to `--json` and refuse `true`.

**F7. Check 5 compares member names only, and check 6 runs whatever the name `ratchet` resolves to.** INFEASIBLE (no step of the workflow builds such an archive; it needs assets replaced by hand), introduced.
- Measured: `sh $S/cases/c3-verify-link-member.sh $S/copy` exits 1. The archive's `ratchet` is a symbolic link to a script outside the archive and its `LICENSE` is an empty directory:
  ```
  FAIL release-verify.sh for an archive whose ratchet is a link and whose LICENSE is a directory: accepted, exit 0
  FAIL release-verify.sh ran the target of the link, a file outside the archive, 1 time(s)
  ```
- File: `.github/scripts/release-verify.sh:146` and `:156`.
- Smallest change: compare `tar -tvzf` types and modes (`d`, `-rw-r--r--`, `-rwxr-xr-x`), or test `-f` and not `-L` after unpacking.

**F8. "Prints the version" is the last word of the first line, and the exit status is not read.** INFEASIBLE (the binary of the stacked branch prints `ratchet <version>` and exits 0), introduced. `AGENTS.md:236` says `archive` "refuses a binary whose `--version` is not the tag".
- Measured: `sh $S/cases/c4-version-among-text.sh $S/copy` exits 1. A binary printing `ratchet 9.9.9 built for 1.2.3` is archived and verified; a binary printing an error line ending in the version and exiting 2 is archived.
- File: `.github/scripts/release-package.sh:74`, `.github/scripts/release-verify.sh:156`.
- Smallest change: compare the whole output with `ratchet <version>` and require exit 0.

**F9. The form check does less than § "Changelog lines" states.** CONFIRMED, introduced.
- Measured: `sh $S/cases/c7-form-check.sh $S/copy` exits 1. `changelog_form`, taken from `release.test.sh`, accepts sections oldest first, the same version twice, a released section without a line, and a bullet plus `### Improved` before the first section. `sh $S/cases/c6-check-inputs.sh $S/copy`: `release-check.sh` and the form check accept `## [1.2.3] - 2026-13-45` and `0000-00-00`.
- Reach: a slip in step 1. `AGENTS.md:206` says "newest first" and `:213` says the test checks the form.
- File: `.github/scripts/release.test.sh:134`, `.github/scripts/release-check.sh:67`.
- Smallest change: in the awk, keep the previous version and refuse a section that is not lower, apply the rules before the first section too, and bound month and day.

Constructed, nobody reaches it, not counted:
- under `umask 077` the directory in the archive has mode `drwx------` (`c5`; a runner has 022);
- a `version = "…"` line inside a multi-line string of `[workspace.package]` is read as the version (`c6`);
- a tag with a second line passes the form `grep` (a ref name holds no newline).

## 3. The suite, after the cases existed

`cd $S/copy && TMPDIR=$S/tmp1 sh .github/scripts/release.test.sh`: `release: 40 of 40 cases pass`, exit 0, 0.72 s wall. The scratch cases are not in the tree, so the count does not move.

## 4. Mutants (`$S/out/mutants.txt`)

Workflow (`release.yml`):
```
W1: package loses 'needs: gate' -> release.test.sh exit 0
W2: bundle loses 'needs: package' -> exit 0
W3: download pattern release-* -> archive-* -> exit 0
W4: merge-multiple: true -> false -> exit 0
W5: cargo build loses --locked -> exit 0
W6: aarch64 runner ubuntu-22.04-arm -> ubuntu-22.04 -> exit 0
W7: bundle uploads dist/*.tar.gz only -> exit 0
W8: gate step 'task check || true' -> exit 0
W9: release-check.sh ... || true -> exit 0
W10: checkout loses persist-credentials: false -> exit 0
W11: second trigger branches: [main] -> exit 0
W12: archive written to 'out', 'dist' uploaded -> exit 0
W13: --bin ratchet dropped -> exit 0
W14: sums ... || true -> exit 0
W15: a job with permissions: write-all -> exit 1
W16: curl POST of a release with a secret token -> exit 0
```
Scripts:
```
V1: gh release view --json assets,author -> exit 0
V2: both gh calls lose --repo -> exit 0
V3: gh release download loses the patterns -> exit 0
V4: SHA256SUMS may name an archive more than once -> exit 0
V5: EXIT trap removed -> exit 0
V6b: check 5 lists only the x86_64 archive -> exit 0
V7: repository read from another key -> exit 1
P1: tar without --owner=0 --group=0 --numeric-owner -> exit 0
P2: no chmod 755 -> exit 0
P3: no chmod 644 -> exit 0
P4: unpacked directory left in dist -> exit 0
P5: sums does not verify -> exit 0
P6: notes section ends only at end of file -> exit 1
P7: version_of accepts v -> exit 0
C1: date is any text -> exit 1
C2: first version line of any table -> exit 1
C3: tag form not checked -> exit 1
```
(V6 in the file was misapplied and is replaced by V6b; V8 changed nothing and is void.)

## 5. What held

- `release.yml` against the sibling `slot`'s release workflow, which has published releases: same trigger pattern, runners (`ubuntu-22.04`, `ubuntu-22.04-arm`), artifact names, `pattern`/`merge-multiple`, `contents: read`. Every action commit equals `pages.yml`'s or is used by sibling workflows on disk (`download-artifact@9000827…` is the one in `slot`'s `release.yml`). The Gate job is the `gate` job of `pages.yml` step for step.
- The three `release-package.sh` calls exactly as the workflow writes them, with relative `target/$TARGET/release/ratchet` and `dist`: archives, `SHA256SUMS` with bare file names, members `0/0`, modes 755/644 (`c5`).
- The real `gh`, read-only:
  - `gh release view 0.36.0 --repo beyond10x/slot --json assets,author,isDraft,tagName` has the shape of the fixture (`author.login` `b10x-bot[bot]`, `state` `uploaded`);
  - `release-verify.sh 0.36.0 --repository beyond10x/slot` passes checks 1 and 2 and refuses at the asset names;
  - `release-verify.sh 0.0.1` exits 1 with `gh release view 0.0.1 found no release in beyond10x/ratchet`;
  - `gh release download … --dir … --pattern …` is valid and creates the directory.
- Step 1 simulated on the real files (version 0.0.1, heading directly below `## [Unreleased]`): `release-check.sh 0.0.1` exit 0, notes 15 lines, suite 40 of 40, `b10x-gates scan-text notes.md` exit 0.
- A version bump without `Cargo.lock`: `cargo metadata --locked` exit 101, so the `--locked` of `task check` refuses it before a tag.
- `release-check.sh` refuses 16 of 19 hostile inputs (`v1.2.3`, `1.2.3-rc.1`, `1.2.30`, a version only in `[package]`, `[workspace.dependencies]` or `[workspace.package.metadata]`, a prerelease workspace version, a version in a comment, a heading with a carriage return, a trailing blank or an indent).
- The suite: 40 of 40 on a read-only filesystem without network (`bwrap --ro-bind / / --unshare-net`) with `CI=true GITHUB_ACTIONS=true`, with `TMPDIR` set and unset, nothing left behind; under `gawk --posix`, `gawk --traditional`, and busybox `ash` with busybox `awk`; from another working directory; with a blank in `TMPDIR`.
- `CHANGELOG.md` against the tree: 16 commands in `spec/cli.yaml`, exit 1 with `cli_handler_unavailable` (`crates/ratchet/tests/main.rs:55`), `completions/ratchet.bash`, 60 s and 120 s in `.config/nextest.toml`, the `{min: N}` rule, `docs/evidence-format.md`. No false line found.
- `b10x-gates gh --repository … -- …` and `b10x-gates bot --repository … -- …` exist in that form; the policy entry of `beyond10x/ratchet` has the shape of `slot`'s.
- Added lines hold no person, machine path, account or host.

Could not test:
- the workflow itself (it never ran, no `actionlint`);
- `dash` and `mawk` (not installed; busybox and `gawk --posix` stood in);
- the aarch64 build;
- `cargo build --release` (not run: no slot spent on it, the lock is covered above);
- `release create` (a write);
- whether the publishing gate scans assets: `b10x-gates scan-artifact` answers `artifact format unsupported` for a `.tar.gz` of this shape, the same format the sibling publishes;
- whether the action commits exist on GitHub (outside the organization, not read over the network).

## 6. Paths written outside the tree

All under `<S>/` (14 MB, no `target/` or `node_modules/` left):
- `cases/` (`lib.sh`, `c1` to `c7`)
- `mutants.sh`
- `out/`
- `copy/` and `mut/` (two copies of the commit, 3 MB each, `mut` equal to `copy` again)
- `elf/` (an archive of the tree's debug binary for the scan, and notes)
- `dl/assets/SHA256SUMS` (of `slot` 0.36.0)
- `awkbin/`, `bbbin/`
- `tmp-mut/` (16 directories left by mutant V5)
- `tmp1/`, `work/`, `marker`

A worktree session lease `adversary-1-changelog-release-procedure` was acquired and released. One `rm -rf *` inside the newly made, empty `elf/` was refused by a safety check and was not needed; nothing was removed there.

## 7. Findings block

```findings
[
  {"file": ".github/scripts/release-check.sh", "line": 66, "category": "boundary", "severity": "warning", "verdict": "CONFIRMED", "origin": "introduced", "message": "A dated section without a change passes release-check.sh and the suite, and release-package.sh notes refuses it only in the job Bundle after the tag is pushed, while notes itself accepts a section of headings without a bullet."},
  {"file": "AGENTS.md", "line": 233, "category": "judgement", "severity": "warning", "verdict": "CONFIRMED", "origin": "introduced", "message": "Section Release has no step for a tag run that fails, so a session is not told whether to rerun, keep the tag or cut the next version."},
  {"file": ".github/scripts/release.test.sh", "line": 588, "category": "mutant", "severity": "warning", "verdict": "CONFIRMED", "origin": "introduced", "message": "The workflow cases check that texts are present, so 15 of 16 mutants of release.yml pass, among them removed needs, a changed download pattern, a dropped --locked and task check with || true."},
  {"file": ".github/scripts/release.test.sh", "line": 104, "category": "mutant", "severity": "warning", "verdict": "CONFIRMED", "origin": "introduced", "message": "The stand-in for gh ignores its arguments, so wrong --json fields, a missing --repo and missing patterns pass, as do eight other script mutants."},
  {"file": ".github/scripts/release-verify.sh", "line": 107, "category": "boundary", "severity": "warning", "verdict": "CONFIRMED", "origin": "introduced", "message": "A release with a fourth asset passes and is reported as having 3 assets attached."},
  {"file": ".github/scripts/release-verify.sh", "line": 91, "category": "boundary", "severity": "warning", "verdict": "INFEASIBLE", "origin": "introduced", "message": "A release marked as a prerelease passes because isPrerelease is neither requested nor read, and no step of the procedure creates one."},
  {"file": ".github/scripts/release-verify.sh", "line": 146, "category": "boundary", "severity": "warning", "verdict": "INFEASIBLE", "origin": "introduced", "message": "Check 5 compares member names only, so an archive whose ratchet is a symbolic link and whose LICENSE is a directory passes and check 6 runs the target of the link, which no step of the workflow produces."},
  {"file": ".github/scripts/release-package.sh", "line": 74, "category": "contract-drift", "severity": "warning", "verdict": "INFEASIBLE", "origin": "introduced", "message": "The version is read as the last word of the first line and the exit status is ignored, so a binary of another version or a failing one is archived and verified, which the real binary does not do."},
  {"file": ".github/scripts/release.test.sh", "line": 134, "category": "contract-drift", "severity": "warning", "verdict": "CONFIRMED", "origin": "introduced", "message": "The form check accepts sections oldest first, a version twice, an impossible date and stray lines before the first section, against the rules of AGENTS.md section Changelog lines."}
]
```
