---
format: aep.planning-md/3
id: review-result:adversary-local-gate-pinned-ess-attack-1
kind: review-result
status: active
title: adversary on story:local-gate-pinned-ess, attack 1 on 5a6c1ea
relations:
- reviews: story:local-gate-pinned-ess
revision: 1
---
Recorded by the coordinator from the adversary's report on commit `5a6c1ea` (merged in `a2876d0`) of `story:local-gate-pinned-ess`, verbatim except that absolute paths of the workstation are replaced by `<tree>`, `<scratch>` and `<home>`.

unit: story:local-gate-pinned-ess, commit 5a6c1ea as merged in a2876d0, tree <tree>
verdict: CONFIRMED (warning): the pin works on both the host and the forge, but the pin test does not check two of the three `ess` calls in `check:spec`
cases: executed 8→8, red 3
origin: introduced 4 / pre-existing 0 / undecided 0
wrote-outside-worktree: none
needs-coordinator: none

Nothing here holds the merge. The pin in the tree is correct today. All four findings are about the test or the documents.

**1. `git --no-pager diff --stat`** (in the tree): empty. I edited no tracked file. Everything I wrote is under the ignored `target/attack/`.

**2. The cases I added** (scratch only, not added to the suite). They are `target/attack/cases.sh`, `cases2.sh` and `mutants.sh`. Each case builds a tree copy under `target/attack/trees/<name>` and runs `ess-pin.test.sh` in it. I ran them alone, before the suite. Command: `cd <tree> && slot --here sh target/attack/cases.sh`, exit 0. Output, verbatim:
```
== C0 unchanged tree copy: the test passes, within 60 s, nothing left
  exit=0 secs=2 leftover_dirs=0 last: ess-pin: 8 of 8 cases pass
green C0 unchanged tree
== C1 check:spec's third ess call (synthesize) runs without the pin: the test must refuse
  exit=0 secs=9 leftover_dirs=0 last: ess-pin: 8 of 8 cases pass
RED   C1 synthesize call unpinned: wanted refuse, exit 0
== C2 check:spec's second ess call (specify cli) runs without the pin: the test must refuse
  exit=0 secs=0 leftover_dirs=0 last: ess-pin: 8 of 8 cases pass
RED   C2 specify cli call unpinned: wanted refuse, exit 0
== C4 a valid YAML single-quoted pin ESS_TOOLCHAIN: '0.98.0' (task delivers 0.98.0)
  exit=1 secs=0 leftover_dirs=0 last: ess-pin: 6 of 8 cases fail
RED   C4 single-quoted pin accepted: wanted pass, exit 1
== C5 the caller's ESS_TOOLCHAIN wins over the Taskfile's (AGENTS.md claim), stand-in ess
  caller ESS_TOOLCHAIN=0.98.1 -> ess got: 0.98.1
green C5 caller value wins (documented)
== C6 pin test run with ESS_TOOLCHAIN=0.98.0 in its environment, as task check:scripts starts it
  exit=0 secs=0 leftover_dirs=0 last: ess-pin: 8 of 8 cases pass
green C6 under the Taskfile env
cases: 6, red: 3
```
- **C1:** `if ! ess generate synthesize` in the copy's `Taskfile.yml` becomes `if ! env -i PATH="$PATH" HOME="$HOME" ess generate synthesize`.
- **C2:** the same change on `- ess specify cli`.
- **C4:** the pin is written as `ESS_TOOLCHAIN: '0.98.0'`.

C7 and C8, command `slot --here sh target/attack/cases2.sh`, exit 0:
```
slot: job 68655 waiting: 7.2 GB memory available (1.0 GB promised to jobs that just started), the job needs about 6.4 GB and 4.0 GB stays free
C7 sh check-generated.test.sh (direct): exit 1, ess got: 0.98.0
C8 sh check-generated.sh (direct): exit 1, ess got: (unset)
slot: job 68655 waited 2s for a build slot, ran 0s
```
Both use a stand-in `ess` that records the value it got and fails, so exit 1 is expected. The recorded value is the result: `check-generated.test.sh` started with `sh` directly still gets the pin, because it runs `task check:generated` in a copy that has its own `Taskfile.yml`. `check-generated.sh` started directly gets none.

Mutants of `ess-pin.test.sh`, each on a copy. Command: `slot --here sh target/attack/mutants.sh`, exit 0:
```
killed M1 (drop the Taskfile = pages.yml comparison): exit 1, ess-pin: 1 of 8 cases fail
killed M2 (drop the requirement comparison): exit 1, ess-pin: 2 of 8 cases fail
SURVIVED M3 (observe only check:generated): exit 0, ess-pin: 8 of 8 cases pass
killed M3b (observe only check:spec): exit 1, ess-pin: 1 of 8 cases fail
killed M4 (drop the named-once check): exit 1, ess-pin: 1 of 8 cases fail
SURVIVED M5 (accept any version form): exit 0, ess-pin: 8 of 8 cases pass
SURVIVED M6 (keep the caller's ESS_TOOLCHAIN (no unset), run as check:scripts runs it): exit 0, ess-pin: 8 of 8 cases pass
SURVIVED M7 (drop the more-than-one ESS_VERSION check): exit 0, ess-pin: 8 of 8 cases pass
killed M8 (keep the quotes of the Taskfile value): exit 1, ess-pin: 6 of 8 cases fail
```

Probe of an unpinned call. Command: `env -u ESS_TOOLCHAIN slot --here ess generate synthesize --path spec --target rust --layout crate --out target/attack/synth/crate`, exit 0:
```
warning: spec/ess-inputs.yaml requires ess 0.98 and this is ess 0.99.2, which is newer; continuing (--strict-requires refuses)
214 capabilities: 214 generated, 0 obligation(s), 0 refused
13 artifact(s), written to target/attack/synth/crate
slot: job 68660 waited 218s for a build slot, ran 4s
```

**3. The suite run, after the cases existed.** Command: `cd <tree> && env -u ESS_TOOLCHAIN slot sh .github/scripts/ess-pin.test.sh`, exit 0. slot printed `slot: synced to build-1d in 2.5 s, 36004 bytes sent, 4 sibling mirrors as base, at a2876d0 + 0 changed files`. The test printed eight `ok` lines and `ess-pin: 8 of 8 cases pass`. Nothing was left behind: `ls target/ess-pin-test.*` found no match. The run was well under 60 s; the slowest copy run was 9 s. The suite is green because my cases are scratch and not in it. Their red results are in part 2.

**4. Findings** (all cover a2876d0)

**F1: the pin test does not check two of the three `ess` calls in `check:spec`. Warning, CONFIRMED, introduced.**
- Where: `.github/scripts/ess-pin.test.sh:104`, together with the stand-in at :46, which exits 1.
- What was measured: the stand-in fails on its first call, so `task check:spec` stops at `ess specify validate`. The calls at `Taskfile.yml:92` (`ess specify cli`) and `Taskfile.yml:107` (`ess generate synthesize`) are never observed. C1 and C2 remove the pin from those calls with `env -i`, which leaves no `ESS_TOOLCHAIN` text for the count at :82 to see, and the test still passes 8 of 8.
- No broken copy targets `check:spec` at all, so M3 (drop `check:spec` from the loop) survives.
- Why it matters: `ess generate synthesize` has no `--strict-requires`. Unpinned, 0.99.2 only warns and still reports `0 refused`, so that step would pass on the host with another `ess` than the forge's. The acceptance case is exactly "the local gate runs another ess".
- What reaches it: nothing today; all three calls get the root `env:`. It would take a later edit to one call.
- Fix to name: add a broken copy that removes the pin from `check:spec`, and observe every call. For example, a stand-in that exits 0 for `specify` and `generate`, and `check:spec` run in a copy that includes `spec/`.

**F2: an `AGENTS.md` sentence claims more than the test does. Note, CONFIRMED, introduced.**
- Where: `AGENTS.md:73`, "Each rule refuses a broken copy under `target/` with its message".
- The rule "`task check:spec` … start `ess` with it" has no broken copy (see M3). Only `check:generated` has one.

**F3: `AGENTS.md` and `CHANGELOG.md` are wrong about `check-generated.test.sh`. Note, CONFIRMED, introduced.**
- Where: `AGENTS.md:126` and `CHANGELOG.md:11`.
- `AGENTS.md` says `check-generated.sh` "and its test" get no pin when started as `sh .github/scripts/...`. C7 shows the test does get 0.98.0, because it runs `task check:generated` in a copy that carries `Taskfile.yml`. Only `check-generated.sh` itself (C8) gets no pin.
- `CHANGELOG.md` says "the scripts that run `ess` get the pin only when started through `task`", which is wrong in the same way.
- The wording comes from the story's Notes.

**F4: the pin test refuses a valid single-quoted pin. Note, CONFIRMED, introduced.**
- Where: `.github/scripts/ess-pin.test.sh:58`; the `gsub` strips only double quotes.
- C4: with `ESS_TOOLCHAIN: '0.98.0'`, which `task` delivers as `0.98.0`, 6 of 8 cases fail with `ESS_TOOLCHAIN of Taskfile.yml is '0.98.0', not a release`. It refuses safely; nothing writes this form today.

**Surviving mutants with no finding row** (note level, residue):
- M5: the version regex at :89 has no case of its own. The other checks cover most forms; `0.98.x` written in both files would get through, but the forge's download would then fail loudly.
- M6: removing the `unset` at :70 survives. I found no Taskfile that the static checks pass where it matters, so I treat it as equivalent.
- M7: the "more than one `ESS_VERSION`" check at :93 has no case.

**5. What I attacked and could not break**
- **The forge:** ess 0.98.0 with `ESS_TOOLCHAIN=0.98.0` and an empty `HOME` printed `ess 0.98.0`, and `specify validate --strict-requires` printed `ratchet v1 — 8 file(s), valid`, both exit 0. `ESS_TOOLCHAIN=v0.98.0` is refused by ess itself, and the test refuses that form. The workflows are unchanged. The forge's go-task is 3.54.0, the same as the local one.
- **The host:** `ESS_TOOLCHAIN=0.98.0 ess specify validate --strict-requires` printed `note: ess 0.99.2 is the dispatcher; delegating to ess 0.98.0 …`, then `valid`, exit 0.
- **The caller's `ESS_TOOLCHAIN` wins over the Taskfile's:** true, as `AGENTS.md` says (C5). Only a value with the same minor and another patch would differ from the forge without an error; a newer value is refused by `--strict-requires`.
- **The test under `check:scripts`:** it passes with `ESS_TOOLCHAIN=0.98.0` already in its environment, as it runs there (C6).
- **Leftovers, temp paths and run time:** no `target/ess-pin-test.*` is left behind, no `/tmp` path is used, and no run took over 9 s.
- **Mutants killed:** M1, M2, M3b, M4, M8.
- **Private data:** no private name, workstation path or time estimate in the added lines, `.engineering/` included.
- **Version forms:** no pre-release or `v`-prefixed form gets through.

**6. Paths written outside the worktree:** none. All scratch is under `<tree>/target/attack/` (`cases.sh`, `cases2.sh`, `mutants.sh`, `cases.out`, `synth.out`, `synth/`, `trees/`, `mutants/`, `home/`).

**Slot jobs:**

| Job | Result |
|---|---|
| `slot --here sh target/attack/cases.sh` | exit 0, no slot line printed |
| `slot --here sh target/attack/cases2.sh` | `slot: job 68655 waited 2s for a build slot, ran 0s`, exit 0 |
| `slot --here sh target/attack/mutants.sh` | exit 0, no slot line printed |
| `slot --here ess generate synthesize …` | `slot: job 68660 waited 218s for a build slot, ran 4s`, exit 0 |
| `slot sh .github/scripts/ess-pin.test.sh` | synced to build-1d at a2876d0, exit 0 |

**Case totals:** 8 cases. 5 went as expected (C0, C5, C6, C7, C8); 3 are red (C1, C2, C4). Mutants: 9 tried, 5 killed, 4 survived.

```findings
- file: .github/scripts/ess-pin.test.sh
  line: 104
  category: mutant
  severity: warning
  verdict: CONFIRMED
  origin: introduced
  message: the stand-in ess fails on the first call so only `ess specify validate` of check:spec is observed and no broken copy targets check:spec; an unpinned `ess specify cli` or `ess generate synthesize` (which has no --strict-requires and passes under 0.99.2) passes 8 of 8, and the mutant that drops check:spec from the loop survives
- file: AGENTS.md
  line: 73
  category: contract-drift
  severity: note
  verdict: CONFIRMED
  origin: introduced
  message: '"Each rule refuses a broken copy" is false for the rule that task check:spec starts ess with the pin, which has no broken copy'
- file: AGENTS.md
  line: 126
  category: contract-drift
  severity: note
  verdict: CONFIRMED
  origin: introduced
  message: check-generated.test.sh started as plain sh does get the pin (it runs task check:generated in a copy carrying Taskfile.yml), so "its test ... gets no pin" is false, and CHANGELOG.md:11 repeats it
- file: .github/scripts/ess-pin.test.sh
  line: 58
  category: boundary
  severity: note
  verdict: CONFIRMED
  origin: introduced
  message: 'a valid single-quoted pin ESS_TOOLCHAIN: ''0.98.0'', which task delivers as 0.98.0, is refused because only double quotes are stripped'
```
