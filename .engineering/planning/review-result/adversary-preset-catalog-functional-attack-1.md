---
format: aep.planning-md/3
id: review-result:adversary-preset-catalog-functional-attack-1
kind: review-result
status: active
title: adversary, story:preset-catalog-functional, attack 1 of 2
relations:
- reviews: story:preset-catalog-functional
revision: 1
---
Recorded by the coordinator from the adversary's report, verbatim except that the absolute paths of the workstation are replaced: `<S>` is the adversary's scratch directory, `<W>` the managed worktree of the unit.

11 findings (A1 to A11; 0 blocker, 6 warning, 5 note). Mutants: 65 survived of 104 tried (50 with a witness copy that shows the gap, 11 without one, 4 in the harness of the copies). Broken files: 37 accepted of 75 tried (29 against a stated rule or against YAML, 8 correct or with no stated rule).

```
unit: story:preset-catalog-functional, branch catalog/functional at 954445d (unit commit 66b80de), base 1bda07f
verdict: CONFIRMED
cases: executed 44→44, red 0
origin: introduced 10 / pre-existing 1 / undecided 0
wrote-outside-worktree: 1 directory tree (42M), listed in part 6
needs-coordinator: dash and mawk are not installed on this host and the branch has no forge run, so the script is unverified under the runner's sh and awk (ubuntu-latest)
```

In the commands below:
`T=<W>`
`S=<S>`

## 1. `git --no-pager diff --stat`

Empty. `git -C $T status --short` prints 0 lines, HEAD is `954445d`. The only thing run inside the tree was its own script in `--catalog` mode, which writes nothing.

## 2. Cases added

None in the tree: the brief forbids edits there, so the suite count stays 44→44. All cases are scratch copies run against the unchanged script: 104 mutants, 75 broken copies, 52 witness copies. Each accepted broken copy is a red case the suite does not hold.

## 3. Suite run

Run in `$S/full`, a `git archive 954445d` extraction (`bash $S/probe/portability.sh`):

```
sh (bash as sh), run 1: exit 0, 2.13 s, 1 line(s)
    last: presets: 7 of 7 file(s) valid, 10 of 10 measurement(s) with a row, 44 of 44 broken copies refused
sh (bash as sh), run 2: exit 0, 1.57 s, 1 line(s)
sh (bash as sh), run 3: exit 0, 1.52 s, 1 line(s)
```

- **Time of `sh spec/presets.test.sh`:** 1.5 to 2.1 s, far inside the 60 s and 120 s bounds.
- **Exit 1 on an accepted copy:** holds. The 39 killed mutants each end with `exit=1` and a line such as `accepted: file-of-no-kind: the directory holds notes.txt` and `... 43 of 44 broken copies refused, 1 accepted`.

## 4. Findings

Every reproducer of the form `sh $T/spec/presets.test.sh --catalog $S/broken/<id>/presets; echo $?` printed this line, then `0`, in a rerun just before this report:
`presets: 7 of 7 file(s) valid, 10 of 10 measurement(s) with a row`

**A1, warning, introduced by the unit (66b80de). `spec/presets.test.sh:573`, `:583`, `:608`.**
Empty text is treated as absent, so an assessment with `output: ""`, a measurement with `scope: ""` and a requirement with `assessment: ""` pass the rules "names an output", "scope the output declares" and "names an assessment".
- `sh $T/spec/presets.test.sh --catalog $S/broken/B01-output-empty/presets; echo $?` → line above, `0`
- same for `B02-assessment-empty` and `B03-scope-empty`

**A2, warning, introduced. `spec/presets.test.sh:43` (the "Not checked:" list).**
The claim "every preset file agrees with the specification and its declaration" does not hold for five checks the design names, and the script lists none of them under "Not checked".

| Copy accepted | What the copy holds | Rule it breaks |
|---|---|---|
| `B38-target-kind-against-declaration` | plan `kind: deployment`; the declaration has `targets: [revision]` | `docs/evidence-format.md:659` |
| `B20-reference-type-against-declaration` | a passed input of another type than the declaration's | `docs/design.md:499` |
| `B26-condition-unit-other`, `B27-condition-unit-absent` | a condition with another unit, or none | `docs/design.md:183`, `spec/domains/specification.yaml:496-515` |
| `B24-operator-against-value-type`, `B25-operator-without-value`, `B28-set-operator-on-number` | an operator the value type does not take | `docs/design.md:172-177` |
| `B22-number-reference-without-better` | a number with a reference and no `better` | `docs/design.md:179` |

Reproducer: `sh $T/spec/presets.test.sh --catalog $S/broken/B38-target-kind-against-declaration/presets; echo $?` → line above, `0`; the same for the other seven ids.

**A3, warning, introduced. `spec/presets.test.sh:169`, `:184`.**
The reader opens a quote in the middle of a plain scalar and keeps a lone carriage return in the text. It therefore reads four copies differently from a YAML reader and refuses none, against the header at `:48-51` ("fails on a line of another form").
Reproducer, per id: `sh $T/spec/presets.test.sh --catalog $S/broken/<id>/presets; echo $?` → line above, `0`.
The difference in nodes (`<` the script, `>` PyYAML), from `DUMP_NODES=1 sh $S/probe/spec/presets.test.sh --catalog $S/broken/<id>/presets | grep '^NODE' | sort` against `python3 -I $S/probe/flat.py $S/broken/<id>/presets/*.yaml | sort`:

```
== B05-comment-after-quote
< NODE	conformance-cases@1.preset.yaml	requirements.no-case-lost.meaning	str	Every case of the "accepted #1 set" still passes.
> NODE	conformance-cases@1.preset.yaml	requirements.no-case-lost.meaning	str	Every case of the "accepted
== B06-comment-after-lone-quote
< ... str	Every case of the 'accepted set still passes. # and a comment
> ... str	Every case of the 'accepted set still passes.
== B07-flow-list-quote
< NODE	differential-equality@1.preset.yaml	assessments.comparison.measurements.equal-cases.filter.class[1]	str	equal 'a, b' c
> ...filter.class[1]	str	equal 'a
> ...filter.class[2]	str	b' c
== B18-lone-cr
< ... str	Every case^M#  of the accepted set.
> ... str	Every case
```

`$S/probe/spec/presets.test.sh` is an instrumented copy of the script (two print lines added at `:498-499`); `flat.py` is a scratch probe, not for the repository.

**A4, note, introduced. `spec/presets.test.sh:451`.**
The key pattern reads `15`, `0o17`, `true` and an empty key as text, while a core-schema reader takes them as integer, boolean and null. Two keys that are equal as integers are accepted as distinct.
- `sh $T/spec/presets.test.sh --catalog $S/broken/B08-keys-equal-as-integers/presets; echo $?` → line above, `0`; same for `B09-key-true`, `B10-key-null`
- yq v4.30.8 tags the keys `0o17 !!int`, `15 !!int`, `true !!bool`; Ruby reads `["refused-does-not-rise", "0o17", 15]` and `["refused-does-not-rise", true]`

**A5, note, introduced. `spec/presets.test.sh:48`.**
Bytes that YAML refuses are accepted: invalid UTF-8, a control character and NUL.
- `sh $T/spec/presets.test.sh --catalog $S/broken/B16-invalid-utf8/presets; echo $?` → line above, `0`; same for `B17-control-character`, `B19-nul`

**A6, warning, introduced. `spec/presets.test.sh:431`.**
The catalog rule "**No comment in a preset or a declaration.**" (`presets/README.md:62`, repeated in `AGENTS.md:64`) is not enforced: the script skips a comment line (`if ($0 ~ /^ *$/ || $0 ~ /^ *#/) next`).
- `sh $T/spec/presets.test.sh --catalog $S/broken/B04-comment-line/presets; echo $?` → line above, `0`

**A7, warning, introduced. `spec/presets.test.sh:54`, `:668-671`; `AGENTS.md:64`.**
The script says "one broken copy per rule", and `AGENTS.md:64` says a new rule gets a broken copy. 50 rules that work have none: each can be removed with the suite still green, and a witness copy shows the unchanged script refuses what the mutant accepts.
- `sh $S/mutants/M86-serves/spec/presets.test.sh; echo $?` → `presets: 7 of 7 file(s) valid, 10 of 10 measurement(s) with a row, 44 of 44 broken copies refused`, `0` (the run writes `target/presets` under the mutant's directory)
- `bash $S/witness/run.sh` prints, for that mutant:
  ```
  M86	GAP	original exit=1, mutant exit=0	W86: a requirement serves a statement the preset does not hold
      original: conformance-cases@1.preset.yaml:55: `requirements.no-case-lost` serves the statement `nothing`, which the preset does not hold
  ```
- Two of the 50 are rules `spec/README.md:86-91` names by word: "a directory without a preset" (M11) and "a page without a table of rows" (M98).
- The case `file-directory` does not guard the regular-file test: with `[ ! -f "$f" ] ||` removed from `:109` the suite stays green (M103), and a directory named `notes.md` is then accepted:
  ```
  M103	GAP	original exit=1, mutant exit=0	W103: a directory named notes.md
      mutant:   presets: 7 of 7 file(s) valid, 10 of 10 measurement(s) with a row
  ```
- The full list of the 50 is in part "Mutants" below.

**A8, warning, pre-existing mechanism (`1bda07f:.github/workflows/pages.yml:39`), statement introduced by the unit (`CHANGELOG.md:18`, `AGENTS.md:76`). `.github/workflows/pages.yml:39`.**
`git diff --name-only HEAD^1 HEAD` lists a rename by its new path only, so a page moved out of `presets/` to a `*.md` elsewhere is classed `planning` and `task check` does not run, against "CI runs `task check` for every change under `presets/`". No case of `check:ci-paths` holds a rename.
- `bash $S/probe/classifier.sh` prints:
  ```
  git diff --name-only HEAD^1 HEAD:
      notes/functional.md
  change class: planning; task of the job gate: none
  git diff --name-only --no-renames HEAD^1 HEAD:
      notes/functional.md
      presets/functional.md
  change class: code; task of the job gate: check
  the script on the tree after the rename:
      presets: 3 of 6 file(s) valid, 0 of 10 measurement(s) with a row, 10 failure(s)
  ```
- At the base, `bash $S/probe/classifier-base.sh` (a move of `crates/ratchet-cli-contract/README.md` to `notes/README.md`, base workflow) prints `change class: planning`.

**A9, note, introduced. `spec/presets.test.sh:467-494`.**
A row inside a code fence or an HTML comment counts as the measurement's row, and a cell holding only a no-break space, a tab or an empty HTML comment counts as filled.
- `sh $T/spec/presets.test.sh --catalog $S/broken/B29-row-in-code-fence/presets; echo $?` → line above, `0`; same for `B30-row-in-html-comment`, `B31-cell-nbsp`, `B32-cell-tab`, `B33-cell-html-comment`

**A10, note, introduced. `spec/presets.test.sh:106`.**
The glob `"$dir"/* "$dir"/.[!.]*` skips a name that starts with `..`, so such an entry lies in the directory unseen, against `presets/README.md:21-22` ("Nothing else lies in the directory").
- `sh $T/spec/presets.test.sh --catalog $S/broken/B34-dotdot-file/presets; echo $?` → line above, `0`

**A11, note, judgement (no reproducer), introduced. `presets/functional.md:164-165`.**
"A list that passes `no-new-known-failure` is no longer than the accepted list, so `size-does-not-rise` adds no refusal" holds only while both accepted values come from the same adoption. The two requirements keep separate reference records, so after an adoption of one alone the size rule can refuse a list the other passes. Covers 954445d.

## Mutants

Reproduce one with `sh $S/mutants/<id>/spec/presets.test.sh; echo $?`; rebuild and rerun with `bash $S/mutants/run.sh <id>` (`run3.sh` for M103, M104). Verdicts: `$S/mutants/results.tsv`, `results3.tsv`. Witness records: `$S/witness/results.txt`, `results2.txt`.

**Killed (39):** M05-other-extension, M06-others-not-counted, M07-readme, M08-kind-of-file, M10-name-and-version, M12-key-twice, M19-block-list, M25-brace-in-flow, M33-kind-bool, M34-kind-int, M37-no-member, M39-project-of-entry, M40-no-field, M50-enum-variant, M51-text, M53-required, M56-format-of-preset, M60-reference-alone, M61-reference-in-declaration, M63-reference-undeclared, M64-list-place-scalar-input, M72-local-input, M73-assessor-absent, M74-assessor-input, M75-output-undeclared, M76-unit-missing, M77-unit-mismatch, M78-unit-not-declared, M79-scope, M81-identity-mismatch, M82-filter-field, M83-requirement-assessment, M84-requirement-measurement, M92-empty-cell, M93-no-row, M94-two-rows, M95-another-page, M96-row-of-no-measurement, M97-page-without-table.

**Survived, with a witness (50; finding A7):** each at `$S/mutants/<id>/spec/presets.test.sh`.
- Files of the directory: M01-dotfile-glob, M02-symlink, M03-empty-file, M04-name-characters, M11-no-preset, M103-directory
- Reader: M13-comment-after-value, M14-tab, M15-indented-at-root, M16-under-a-value, M17-uneven-indent, M18-flow-of-no-key, M20-after-flow, M21-quoted-escape, M22-quoted-unclosed, M23-indicator-scalar, M24-colon-in-plain, M26-flow-map-open, M27-flow-map-parts, M28-flow-no-value, M29-flow-list-open, M30-flow-list-parts, M31-flow-empty-item
- Scalar kinds: M32-kind-null, M35-kind-float, M36-kind-inf-nan, M104-hex-and-octal
- Types of the specification: M43-not-a-list, M44-not-a-mapping, M46-integer, M47-boolean, M48-decimal, M54-required-of-assessor, M55-format-of-assessor, M59-pending
- References: M62-reference-in-preset-block, M65-scalar-place-list-input, M66-reference-for-struct, M67-reference-type, M68-integer-input-only, M69-decimal-input, M71-text-input
- Requirements: M85-requirement-no-measurement, M86-serves
- Page: M87-rule-line, M88-row-end, M89-five-cells, M90-first-cell, M91-empty-cell-unit-only, M98-table-without-row

**Survived, no witness found (11; equivalent, dead on this specification, or caught by another rule):** M09-stem-without-dot, M38-item-of-no-list, M41-key-of-no-mapping, M42-null, M45-collection-for-scalar, M49-enum-not-text, M52-no-rule-for-type, M57-format-absent, M58-preset-block-absent, M70-boolean-input (no Boolean field outside the input declaration), M80-identity-none-declared.

**Survived, harness of the copies (4; nothing in the suite tests the harness, by construction, no finding):** M99-edit-changes-nothing, M100-message-of-the-rule, M101-accepted-exit, M102-unchanged-copy.

## Broken copies

Verdicts: `$S/broken/results.txt`, `results2.txt`; each copy at `$S/broken/<id>/presets`. Verdicts are the same under `LC_ALL=C` and `LC_ALL=en_US.utf8` (67 cases compared, `verdicts-C.txt`, `verdicts-utf8.txt`).

- **Accepted against a stated rule or YAML (29):** B01, B02, B03 (A1); B04 (A6); B05, B06, B07, B18 (A3); B08, B09, B10 (A4); B16, B17, B19 (A5); B20, B22, B24, B25, B26, B27, B28, B38 (A2); B29, B30, B31, B32, B33 (A9); B34 (A10); B40-input-default-of-another-type (a `Json` default, which the script lists as not checked, so no finding).
- **Accepted, correct or no rule found that forbids it (8):** B15-trailing-spaces and B44-reference-quoted-in-block (correct); B21-kind-against-declaration, B23-identity-absent, B42-reference-with-space, B43-reference-in-double-braces (no sentence found); B35-preset-without-entries and B36-name-with-at (print `8 of 8 file(s) valid`; my reading, no rule found).
- **Refused (38):** B11-crlf, B12-bom, B13-document-marker, B14-document-end, B37-unreferenced-requirement-only, B39-subjects-map, B41-measurement-key-integer, B45-input-name-with-dot, H01 to H30.

## 5. What was attacked and held

- The green line and exit 0: three runs, same line.
- Exit 1 when a broken copy is accepted: 39 mutants show it.
- The six shipped YAML files against PyYAML: 340 nodes, identical (`SAME-NODES`).
- The specification tables the script reads against PyYAML: 969 lines, identical.
- Anchors, aliases, merge keys, block scalars, multi-line plain scalars, flow on two lines, quoted keys, a space before a colon, a trailing comma, CRLF, BOM, document markers, tabs: all refused (H19 to H24, H27 to H29, B11 to B14).
- Undeclared keys, enum values, duplicate keys in flow, null values, quoted integers, a float version: refused (H01 to H03, H08, H12 to H14).
- Reference rules: undeclared input, list input for a scalar, text input for a decimal, reference in the preset block, reference for a struct, a default spelling: refused (H06, H07, H09, H10, H30).
- Page rules: two rows on a second page, a row in the README only: refused (H25, H26).
- Classifier, single paths: every path under `presets/` (nested, hidden, with a space, quoted with octal escapes, the bare name `presets`) is `code`, task `check`.
- `slot task check:ci-paths` in `$S/full`: exit 0, `44 cases`, 44 `ok`, 0 `FAIL`. With the `presets/*` arm removed from the workflow: exit 201, `FAIL code <- presets/functional.md: got planning` and two more FAIL lines, so the arm is guarded.
- Portability: green line and exit 0 under `sh` (bash), `bash --posix`, `zsh --emulate sh`, `gawk --posix`, `gawk --traditional`, `gawk --lint` (warnings only: uninitialized variables, `substr` past the end), `LC_ALL=C`, `C.utf8`, `en_US.utf8`, `de_DE.utf8`, from `/`, from `spec/`, with `CDPATH` set.
- Not run: `dash` and `mawk` (`dash not found`, `mawk not found`).
- Contract statements checked by hand and found true: the binding examples pass every declared input; the requirement and input tables of `presets/functional.md` match the presets; "three of the seven maps"; "eleven steps" of `check:spec`; `lte` on a set is the item count.
- `ratchet validate` could not be driven: `crates/ratchet/src/commands/validate.rs` returns `HandlerReply::Unavailable`.
- Base `1bda07f` holds neither the script nor `presets/`, so every script finding is introduced.

## 6. Paths written outside the worktree

All under `<S>/` (42M after I removed the `target/` work directories my runs wrote there; nothing elsewhere, nothing in `/tmp`):
- `repo/`: copy of `presets/`, `spec/domains/`, the script, `Taskfile.yml`, `pages.yml`
- `full/`: `git archive 954445d` extraction
- `mutants/`: `run.sh`, `run3.sh`, `results.tsv`, `results3.tsv`, `stderr.log`, `done`, and one directory per mutant (104)
- `broken/`: `run.sh`, `run2.sh`, `results.txt`, `results2.txt`, `verdicts-C.txt`, `verdicts-utf8.txt`, and one directory per copy (75)
- `witness/`: `run.sh`, `run2.sh`, `results.txt`, `results2.txt`, directories `W01` to `W104` (52)
- `probe/`: `flat.py`, `spec.py` (temporary Python probes, not for the repository), `spec/presets.test.sh` (instrumented copy), `awk-nodes.txt`, `py-nodes.txt`, `awk-spec.txt`, `py-spec.txt`, `a.txt`, `p.txt`, `portability.sh`, `portability.out`, `awk--posix/`, `awk--traditional/`, `awk--lint/`, `classifier.sh`, `classifier.out`, `classifier-base.sh`, `classifier-base.out`, `pages-base.yml`, `one-path`, `rename-files`, `rename-files-norenames`, `rename-base-files`, `rename-repo/`, `rename-base/` (scratch git repositories), `ci-paths.out`, `ci-mutant/`, `ci-mutant.out`

## 7. Findings block

```findings
- file: spec/presets.test.sh
  line: 573
  category: boundary
  severity: warning
  verdict: CONFIRMED
  origin: introduced
  message: empty text for output, scope and a requirement's assessment is treated as absent and passes the rules that these name a declared thing
- file: spec/presets.test.sh
  line: 43
  category: contract-drift
  severity: warning
  verdict: CONFIRMED
  origin: introduced
  message: target kind, type of a passed input, unit of a condition, operator against value type and better on a number with a reference are neither checked nor listed as not checked
- file: spec/presets.test.sh
  line: 169
  category: boundary
  severity: warning
  verdict: CONFIRMED
  origin: introduced
  message: a quote inside a plain scalar and a lone carriage return are read differently from a YAML reader and not refused
- file: spec/presets.test.sh
  line: 451
  category: boundary
  severity: note
  verdict: CONFIRMED
  origin: introduced
  message: keys a core-schema reader takes as integer, boolean or null are read as text, so two keys equal as integers are accepted
- file: spec/presets.test.sh
  line: 48
  category: boundary
  severity: note
  verdict: CONFIRMED
  origin: introduced
  message: invalid UTF-8, a control character and NUL in a YAML file are accepted
- file: spec/presets.test.sh
  line: 431
  category: contract-drift
  severity: warning
  verdict: CONFIRMED
  origin: introduced
  message: the catalog rule that a preset or declaration holds no comment is not enforced, a comment line is skipped
- file: spec/presets.test.sh
  line: 54
  category: mutant
  severity: warning
  verdict: CONFIRMED
  origin: introduced
  message: 50 working rules have no broken copy although the script and AGENTS.md state one per rule, and the case file-directory does not guard the regular-file test
- file: .github/workflows/pages.yml
  line: 39
  category: contract-drift
  severity: warning
  verdict: CONFIRMED
  origin: pre-existing
  message: a rename out of presets/ is listed by its new path only and classed planning, so task check does not run although the changelog says it runs for every change under presets/
- file: spec/presets.test.sh
  line: 467
  category: boundary
  severity: note
  verdict: CONFIRMED
  origin: introduced
  message: a row in a code fence or an HTML comment counts as a measurement's row, and a cell of a no-break space, a tab or an empty HTML comment counts as filled
- file: spec/presets.test.sh
  line: 106
  category: boundary
  severity: note
  verdict: CONFIRMED
  origin: introduced
  message: an entry whose name starts with two dots is not seen by the glob, against the README sentence that nothing else lies in the directory
- file: presets/functional.md
  line: 164
  category: judgement
  severity: note
  verdict: CONFIRMED
  origin: introduced
  message: the sentence that size-does-not-rise adds no refusal holds only while both accepted values come from the same adoption
```

