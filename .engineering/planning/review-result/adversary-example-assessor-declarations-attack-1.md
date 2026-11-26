---
format: aep.planning-md/3
id: review-result:adversary-example-assessor-declarations-attack-1
kind: review-result
status: active
title: adversary on story:example-assessor-declarations, attack 1 on 247d298
relations:
- reviews: story:example-assessor-declarations
revision: 1
---
Recorded by the coordinator from the adversary's report on commit `247d298` of `story:example-assessor-declarations`, verbatim except that absolute paths of the workstation are replaced by `<tree>` and `<scratch>`.

unit: story:example-assessor-declarations, commit 247d298 on example-declarations (tree <tree>, base a4877e0)
verdict: NEEDS-CHANGE
cases: executed 20→20, red 0 in the suite (I added no tracked case); scratch cases 29, red 4; mutants 25, 19 survive the script's own run
origin: introduced 7 / pre-existing 0 / undecided 0
wrote-outside-worktree: none
needs-coordinator: none. No step I ran calls `ess`, so the ESS_TOOLCHAIN note did not apply. I took no worktree lease.

**Verdict:** no blocker. Two warnings need a change before this ships; five notes do not. The nine declarations pass `presets.test.sh`'s key and type checks, and the acceptance case against the base passes.

## 1. git diff --stat
Empty. I edited no tracked file. Everything I wrote is under the ignored `target/attack/`.

## 2. The cases I added
They live in `target/attack/cases.sh` (POSIX sh and awk). Each case runs the script once with `--examples <copy> --presets <dir>` and states the correct outcome. I ran them alone first, against the unit's script:
`cd <tree> && slot --here sh target/attack/cases.sh` → exit 1, `cases: 29, as expected: 25, red: 4`.

The four red cases, output verbatim:
```
RED   measurements-block-list: exit 0, wanted a refusal holding: ess-ui-behavior.ratchet.yaml: (measurements of keyboard-task-completion as a block list with an undeclared output, scope and unit)
      example-declarations: 5 example file(s), 9 declaration(s) read, 19 of 19 measurement(s) as declared
RED   assessments-block-list: exit 0, wanted a refusal holding: extra.ratchet.yaml (an example whose assessments are a block list naming an assessor without a declaration)
      example-declarations: 6 example file(s), 9 declaration(s) read, 20 of 20 measurement(s) as declared
RED   compact-block-list: exit 1, and it is valid: a block list at the indentation of its key (requires of the merge gate)
      analyzer-findings.ratchet.yaml:98: not read: `- no-lint-findings` is a block list item that is the value of no key
      ...
      analyzer-findings.ratchet.yaml:97: `gates.merge.requires` has no value on its line and nothing under it
RED   trailing-comma: exit 1, and it is valid: a flow list with a trailing comma, [journey, ]
      ux-eval@1.assessor.yaml:13: not read: the flow list of `outputs.steps.scopes` holds an empty item
```

The 25 green cases:
- **Acceptance against the base:** the examples from `git show a4877e0:examples/*`, with no `quality/assessors/`, give exit 1, and each of the five files names an assessor without a declaration.
- **Refused as they should be:** a measurement that is a scalar, a duplicate `output` key, a key indented under a scalar, uneven indentation, a tab, an integer key, an escape, an example or declaration entry that is a broken symbolic link, `runs_of` naming its own plan, a window measurement without `output`, an unusual version with no file, and a scope missing from a block list of scopes.
- **Accepted as they should be:** a quoted assessor id, a quoted `record-series@1`, a single-quoted unit, a quoted `"run"`, keys in another order, a flow map without spaces after commas, the version `1.0.0-rc_1` with its file, `scopes` as a block list, `outputs` as one flow map, comment lines in four places, and a broken `notes.yaml` beside the examples.

## 3. The suite, after the cases
`cd <tree> && slot sh spec/example-declarations.test.sh` → exit 0:
```
slot: synced to build-1d in 61.9 s, 119159450 bytes sent, 1 sibling mirror as base, at 247d298 + 0 changed files
example-declarations: 5 example file(s), 9 declaration(s) read, 20 of 20 measurement(s) as declared
example-declarations: 20 of 20 broken copies refused
```

**Mutants.** `cd <tree> && slot --here --timeout 30m sh target/attack/mutants.sh` → exit 0. Each mutant is a copy of the script in a tree of its own under `target/attack/mut/`.
- **Killed by the script's own 20 copies (6):** rule 2 (:391), rule 4 (:396), rule 6 (:399), rule 7 scope (:369), rule 8 (:418), and swapping the lookup order (:343).
- **Survive and make the script accept a defect (7):** caught only by my cases:
  - :166 duplicate key
  - :123 broken example link
  - :130 broken declaration link (it falls through to `presets/`)
  - :360 `runs_of` naming its own plan
  - :219 integer key
  - :227 escape
  - :287 key indented under a scalar
- **Survive, other effects (4), caught only by my cases:**
  - :122 glob widened to `*.yaml`: refuses a valid tree.
  - :274 tab check removed: only the message changes, because :275 also refuses a tab.
  - :290 uneven indent and :364 window measurement without output: the copy is still refused, under another rule's message.
- **Survive everything (8):**
  - Cosmetic: :384 entry "-" and :401 the `good` count.
  - Unreached: :399 a measurement without `scope`, :367 unit presence in rule 7, :286 indentation at the root, :309 a key after a flow collection, :293 a flow collection that is no key's value.
  - Not covered: :275 control characters. A CRLF line would then pass in a field the script does not check.

## 4. Findings (all on 247d298)
1. **spec/example-declarations.test.sh:386 (also :421, :361). Warning, NEEDS-CHANGE, introduced.**
   - What was measured: when `assessments` or `measurements` is a list or a scalar instead of a map, the script reads zero plans or measurements and exits 0. The header at :24 says no plan and no measurement passes unread. Cases measurements-block-list and assessments-block-list above.
   - What reaches it: any new example. No other gate step checks the types of an example (examples/README.md:9-12).
   - Fix: refuse when the node kind of `assessments`, of a plan, or of `measurements` is not `map`.
2. **spec/example-declarations.test.sh:455. Warning, NEEDS-CHANGE, introduced.**
   - What was measured: the 7 refusals in the "survive and accept a defect" group above (:166, :123, :130, :360, :219, :227, :287) have no copy, so their mutants stay green at "20 of 20". The script's own comment at :455-456 says "A rule without a case here is not guarded". `spec/presets.test.sh` has a `form-*` case for each refusal of its reader.
   - Fix: one copy each. `target/attack/cases.sh` has a ready case for every one.
3. **spec/example-declarations.test.sh:299. Note, CONFIRMED, introduced.** A block list at the same indentation as its key is valid YAML. The script refuses it, and :331 then reports that `gates.merge.requires` "has no value", which is false.
4. **spec/example-declarations.test.sh:203. Note, CONFIRMED, introduced.** A flow list with a trailing comma, `[journey, ]`, is valid YAML 1.2. It is refused as "holds an empty item".
5. **docs/evidence-format.md:688 (also CHANGELOG.md:11). Note, CONFIRMED, introduced.** Both say "the nine assessors the examples name". The examples name ten ids. examples/README.md:472 says it correctly ("all but `record-series@1`").
6. **spec/example-declarations.test.sh:342. Note, INFEASIBLE, introduced.** The script reads `quality/assessors` before `presets`, which is the reverse of the order in examples/ratchet.toml:5-8. docs/design.md § 5 sets no precedence. No id is in both directories today, so nothing reaches it.
7. **examples/quality/assessors/command-timing@1.assessor.yaml:8. Note, CONFIRMED, introduced.**
   - What was measured: the file has `conditions: []`, while docs/design.md:296 plans the same `command-timing@1` with `cache: warm`. docs/evidence-format.md:688 now offers this file to copy.
   - What reaches it: the story recorded "no cache condition" as its decision, and the critics tied it to `story:cache-condition-one-name`. This is drift between two documents, not a script defect.

## 5. Attacked and not broken
- **The nine declarations:** checked against `assessor.yaml`, `specification.yaml`, design § 3 and the examples, field by field: targets, inputs and their types, `local`/`required`, outputs, value types, kinds, units, scopes, boundaries, `identity_key`, `item_fields`, coverage units and counts. No reserved argument name is used, and `presets/` holds none of the nine. `slot --here sh spec/presets.test.sh --catalog target/attack/catalog` (presets plus the nine) → job 68557, "waited 26s for a build slot, ran 0s", exit 0, `presets: 56 of 56 file(s) valid, 41 of 41 measurement(s) with a row`.
- **The 8 rules and 12 guards:** every quoting, ordering, flow and version form I tried behaves as described.
- **Documents:** the step count "twelve" in `spec/README.md` is right. The CHANGELOG lines keep the form `release-check.sh` reads. The `pages.yml` class AGENTS.md states for files under `examples/` is right.
- **Private data:** nothing private and no time estimate in the diff.
- **Not tried:** dash and mawk (not on this host).

## 6. Paths written outside the worktree
None. Scratch, all in the ignored `target/attack/` of the tree: `cases.sh`, `mutants.sh`, `cases-real.out`, `mutants.out`, `suite.out`, `catalog/`, `catalog.out`, `mut/`.

**Slot jobs:**
- cases: exit 1, 4 red, slot printed no line
- mutants: exit 0, slot printed no line
- presets catalog: job 68557, ran 0s, exit 0
- suite: synced to build-1d, exit 0

## 7. findings
```findings
- file: spec/example-declarations.test.sh
  line: 386
  category: boundary
  severity: warning
  verdict: NEEDS-CHANGE
  origin: introduced
  message: assessments or measurements written as a list or scalar give zero plans or measurements and exit 0, so an undeclared output, unit, scope or assessor passes, contrary to the header at :24
- file: spec/example-declarations.test.sh
  line: 455
  category: mutant
  severity: warning
  verdict: NEEDS-CHANGE
  origin: introduced
  message: seven refusals (:166 duplicate key, :123 and :130 dangling link, :360 runs_of itself, :219 integer key, :227 escape, :287 key under a scalar) have no copy, and each mutant that removes one stays green at 20 of 20 while accepting a defect
- file: spec/example-declarations.test.sh
  line: 299
  category: boundary
  severity: note
  verdict: CONFIRMED
  origin: introduced
  message: a block list at the indentation of its key, valid YAML, is refused, and :331 then wrongly says the key has no value
- file: spec/example-declarations.test.sh
  line: 203
  category: boundary
  severity: note
  verdict: CONFIRMED
  origin: introduced
  message: a flow list with a trailing comma, valid YAML 1.2, is refused as holding an empty item
- file: docs/evidence-format.md
  line: 688
  category: contract-drift
  severity: note
  verdict: CONFIRMED
  origin: introduced
  message: says the examples name nine assessors where they name ten ids, record-series@1 being the one without a file; CHANGELOG.md:11 repeats it
- file: spec/example-declarations.test.sh
  line: 342
  category: judgement
  severity: note
  verdict: INFEASIBLE
  origin: introduced
  message: the lookup reads quality/assessors before presets, the reverse of the sources order of examples/ratchet.toml, a precedence the design does not set; no id is in both today
- file: examples/quality/assessors/command-timing@1.assessor.yaml
  line: 8
  category: judgement
  severity: note
  verdict: CONFIRMED
  origin: introduced
  message: declares no conditions while docs/design.md:296 plans the same command-timing@1 with cache warm, and docs/evidence-format.md:688 offers this file to copy
```
