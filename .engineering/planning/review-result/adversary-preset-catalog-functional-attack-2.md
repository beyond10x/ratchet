---
format: aep.planning-md/3
id: review-result:adversary-preset-catalog-functional-attack-2
kind: review-result
status: active
title: adversary, story:preset-catalog-functional, attack 2 of 2
relations:
- reviews: story:preset-catalog-functional
revision: 1
---
Recorded by the coordinator from the adversary's report, verbatim except that the absolute paths of the workstation are replaced: `<S>` is the adversary's scratch directory, `<W>` the managed worktree of the unit. The attack was stopped before its end: tests may run on the build node only, and the node did not answer. List 2 holds the cases that were prepared and not run.

unit: story:preset-catalog-functional, attack 2 of 2, commit 886e4db (base 1bda07f), attacked on a `git archive` copy of 886e4db in scratch
verdict: NEEDS-CHANGE
cases: executed 172→172, red 0 (no case added to the tree, the brief forbids writing in it; 110 scratch probes run before the stop, 25 more prepared and not run)
origin: introduced 16 / pre-existing 0 / undecided 0
wrote-outside-worktree: 32 entries, all under the assigned scratch directory (part 6)
needs-coordinator: run `slot sh <S>/run-pending.sh` when the node is back (list 2); rule on the record-series form (finding 1)

Paths below: `S=<S>`, `T=<W>`. Script lines are of `spec/presets.test.sh` at 886e4db (1894 lines, not about 2260 as the brief says). Every probe command ran from `$S` against `$S/fixed/spec/presets.test.sh`.

## 1. The tree

`git -C $T --no-pager diff --stat`: empty, exit 0. `git -C $T status --short`: empty, exit 0.
HEAD of the tree is now `0d3058e` (was `886e4db` at my start). Not my doing. `git diff --name-only 886e4db 0d3058e` lists only `.engineering/` paths and `ROADMAP.md`, so no file under attack changed.

## Blockers, plainly

Two, by the brief's definition:
- Finding 1, clause 1: a valid window preset over `runs_of` cannot pass.
- Finding 2, clause 2: a copy of a shipped preset with a control character passes, and hides a `gates:` key from the script.

Finding 6 (row inside a longer fence) also meets clause 2 by the letter. I rate it warning because it is a state I built and no shipped page reaches it.
Not measured by me: the gate (`task check` never run) and the step's time inside the gate. The script alone took 3.55 s, 3.58 s and 3.64 s, exit 0.

## List 1: reproduced with a command before the stop

All origin `introduced`: the script does not exist at the base (`git cat-file -e 1bda07f:spec/presets.test.sh` fails).

**1. blocker, CONFIRMED, :769-770. The built-in `record-series@1` is refused.**
- Command: `sh variants.sh forms`, case `record-series`. Exit 1.
- Output: ``test-step-time@1.preset.yaml:93: `assessments.second-step.assessor` names the assessor `record-series@1`, and the directory holds no `record-series@1.assessor.yaml` `` / `presets: 9 of 10 file(s) valid, 22 of 22 measurement(s) with a row, 1 failure(s)`
- What reaches it: any preset with a window over the runs of another plan. `spec/domains/specification.yaml:909-910` requires such a plan to name `record-series@1`; `spec/domains/assessor.yaml:18-26` says it declares no fixed output list and that the comment and the invariant are its declaration. The form is in `docs/design.md:308-324`.
- Smallest change: at :769 and in `output_of` (:513-519) skip the declaration lookup and the output joins for `record-series@1`, with one accepted copy. Whether a written declaration file is a way around is cases 8 and 9 of list 2, not run.

**2. blocker, NEEDS-CHANGE, :605-608 (class at :607). C1 control characters and the YAML 1.1 line breaks pass.**
- Command: `sh bytes.sh`. Exit 0 with `presets: 7 of 7 file(s) valid, 10 of 10 measurement(s) with a row` for `nel-u0085`, `c1-u0080`, `c1-u009f`, `ls-u2028`, `ps-u2029`, `noncharacter-fffe`, `noncharacter-ffff`, `bidi-override-u202e`, `zero-width-u200b`, `bom-mid-line`, `page-nel`, `page-c1`, `bom-page`, `bom-readme`.
- Command: `sh linebreak.sh`. `LB-ls` and `LB-nel` (the line `cache: warm<U+2028>gates:<U+2028>…` under the open struct `ObservationConditions` of `known-failures@1.preset.yaml`): same line, `exit=0`. Three YAML readers (a libyaml binding, `yq`, and a temporary Python probe) each read the root keys `["format", "preset", "requirements", "assessments", "gates"]` and `gates: {"merge" => {"stage" => "pre-merge", "qualifying_environments" => ["ci"], "requires" => ["size-does-not-rise"]}}`.
- Stated rule: `presets/README.md:23` "no control character"; header :16 and :24 "So a preset holds no gate".
- What reaches it: a pull request that adds or edits a catalog file; nothing in the shipped catalog.
- Smallest change: at :607 also refuse `\302[\200-\237]` and `\342\200[\250\251]`, with broken copies; decide on U+FFFE, U+FFFF and a BOM inside a file.

**3. warning, CONFIRMED, :804 (also :769, :815, :818, :879, :821-823, :837, :459). A reference is refused where a join rule reads the value.**
- Command: `sh variants.sh refs`. All eight exit 1, one failure each (three for `ref-output`):
  - `ref-assessor`: ``…:31: … names the assessor `${inputs.runner}`, and the directory holds no `${inputs.runner}.assessor.yaml` ``
  - `ref-output`: ``…:55: … names the output `${inputs.runner}`, which `command-timing@1` does not declare``
  - `ref-scope`: ``…:65: … has the scope `${inputs.runner}`, which the output `duration` of `command-timing@1` does not declare``
  - `ref-boundary`: ``…:103: … has the boundary `${inputs.runner}`, which the output `duration` … does not declare``
  - `ref-unit`: ``…:113: `requirements.step-budget` has a condition in the unit `${inputs.runner}`, and the output `duration` … declares `s` (`unit_mismatch`)``
  - `ref-identity`: ``…:83: … states the identity key `[]`, and the output `slow_tests` … declares `[test_id]` ``
  - `ref-req-assessment`: ``…:175: `requirements.window-queue-wait` names the assessment `${inputs.runner}`, which the preset does not hold``
  - `ref-dotted-name` (an input declared with `.` in its name): ``…:52: … holds `${` or `{inputs.` and is not `${inputs.<name>}` alone…``
- What reaches it: `docs/design.md:522` "It stands where a scalar or a list stands"; `research/candidate-presets.md:89`, `:131`, `:175` list the outputs, the identity key and the counters as inputs. The header's "Not checked" (:68-69) exempts only four places.
- Smallest change: skip each join where the value holds `${`, as :774, :807 and :863 already do, and add the places to :68-69. A literal per preset is the way around today.

**4. warning, CONFIRMED, :870-871 (and :807). A pass rate of assertions cannot be compared with a limit.**
- Command: `sh variants.sh forms`, case `pass-rate`. Exit 1.
- Output: ``…:81: … has the kind `sampled`, and the output `ready` of `command-timing@1` declares `exact` `` / ``…:149: `requirements.is-ready` has the operator `gte`, which takes a number or the number of items of a set, and the output `ready` … has the value type `assertion` `` / `… 2 failure(s)`
- What reaches it: `docs/design.md:161` "A window aggregates numbers, and assertions with `pass_rate`"; `research/candidate-presets.md:149` (§ 3.6). Way around: the assessor returns the rate as a number.
- Smallest change: at :870 take an assertion whose measurement has `aggregation.kind: pass_rate` as a number; same at :883.

**5. warning, CONFIRMED, :786-795 with `unfit` :492-507. A reference as a list item is not checked against the declared type.**
- Command: `sh rules.sh`, cases `input-type-in-a-list` (`exclude: ["${inputs.runs}", "${inputs.warm_up}"]` for a declared list of `string`) and `input-list-in-a-list`. Both `exit=0`, `presets: 10 of 10 file(s) valid, 22 of 22 measurement(s) with a row`.
- Stated rule: `presets/README.md:72-73` "with the declared type".
- Smallest change: in `unfit`, resolve an item that is `${inputs.<name>}` to the type of that input.

**6. warning, INFEASIBLE (a state I built), :655-660. A row inside a longer code fence counts as a row.**
- Command: `sh rules.sh`, cases `row-in-a-longer-fence` (four backticks holding a line of three), `row-after-indented-fence-line`, `row-in-a-longer-tilde-fence`. All `exit=0`, `presets: 7 of 7 file(s) valid, 10 of 10 measurement(s) with a row`. A CommonMark renderer shows the row inside `<pre><code class="language-markdown">`.
- Stated rule: `presets/README.md:67-68` "A row inside a code fence … is no row".
- What reaches it: nothing found in the shipped page; a later page that quotes a table inside a longer fence would.
- Smallest change: keep the opening run's length; a closing line is a run of the same character at least that long, indented at most 3 spaces.

**7. warning, CONFIRMED, :941. Mutant: the full run exits 0 when `presets/` itself is refused.**
- Command: `sh script-mutants.sh`, M1 (`exit 1` to `exit 0`). Full run of the mutant: `… 172 of 172 broken copies refused`, `exit=0`. Witness with `presets/notes.txt`: failure lines printed, `exit=0`.
- Smallest change: one harness case that runs a copy of the script in a scratch tree with a broken `presets/` and expects exit 1.

**8. warning, CONFIRMED, :120. Mutant: `--spec` is parsed and not used.**
- Same command, M3 (`spec=$2;` removed). Full run: 172 of 172, `exit=0`. Witness `--catalog presets --spec <directory with no type>`: mutant `exit=0`; the unchanged script prints `presets: the specification declares no ratchet.config.CatalogFileKind…`, `exit=1`.
- Smallest change: one harness case that calls `--spec` with a differing directory.
- M2 (:931 `exit $?` to `exit 0`) is equivalent: `set -e` ends the script at :930 first.

**9. note, CONFIRMED, :65-71. An undeclared condition is accepted, and the gap is not listed.**
- `sh rules.sh`, case `condition-undeclared` (`conditions: {all: {moon_phase: full}}` against `conditions: []`): `exit=0`, 7 of 7. `docs/design.md:208` has `validate` check it. Smallest change: one line under "Not checked", or the join.

**10. note, CONFIRMED, :882-887. Two rules that do not read the reference kind are skipped when the kind is an input.**
- `sh rules.sh`, cases `better-skipped-by-reference-input`, `set-reference-no-condition-by-input`: `exit=0`, 10 of 10. Smallest change: move :886 and :887 out of the `index(rk, "${") == 0` test.

**11. note, CONFIRMED, :774. A target kind given by an input's default is not checked.**
- `sh rules.sh`, cases `target-kind-by-default` (default `telemetry_population`), `target-kind-default-no-kind`: `exit=0`, 10 of 10. The header's reason "the binding passes it" does not hold for a default.

**12. note, CONFIRMED, :673-674 (also :662, :655-661). Page forms a later page may use are refused.** `sh variants.sh pages`, all exit 1:
- `page-escaped-pipe`, `page-code-pipe`: ``runtime.md:25: a row has 6 cells; a row has 5, and no cell holds `|` ``
- `page-padded-header`, `page-indented-table`, `page-no-outer-pipes`: the header must equal the line.
- `page-four-backticks`: every row after the fence is lost, 13 failures.
- `page-comment-in-code`: `<!--` in inline code swallows the rest, 7 failures.
- `page-linked-name`: a linked measurement name is no row.

**13. note, CONFIRMED, :637. The design's own block list is refused.**
- `sh variants.sh forms`, case `block-list-planted`: ``…:158: not read: a block list; a list is written `[...]` on one line``, exit 1. `docs/design.md:350-351` writes `planted_defects` as a block list. Stated in the header; a flow list is the way around.
- Same group, all exit 1 and all stated limits: `apostrophe`, `both-quotes`, `both-quotes-single` (text with both kinds of quote cannot be written), `backslash-double`, `folded-text`, `next-line-text`, `continued-text`, `doc-start`.

**14. note, CONFIRMED, :818. `boundary: run_time` on an output without `boundaries` is refused.**
- Case `boundary-of-ratchet`: ``…:75: … has the boundary `run_time`, which the output `duration_ms` … does not declare``, exit 1. `docs/design.md:208` calls `run_time` and `queue_wait` Ratchet's own. The design is ambiguous here.

**15. note, CONFIRMED, :733 with :459. `${` in a default of a declaration is refused with the reference message.**
- Case `dollar-brace-declaration`: ``command-timing@1.assessor.yaml:12: `inputs.label.default` holds `${` or `{inputs.` and is not `${inputs.<name>}` alone…``, exit 1. `docs/design.md:522` speaks of a value of a preset only.

**16. note, judgement (no command), :807-808 and :820-823. The kind rule is implied by the design, not stated.**
- For it: `docs/design.md:501` has the assessor declare the kind per output; `docs/evidence-format.md:659` checks a result's `kind` against the declaration; `kind_mismatch` is in `ratchet.cli.ValidationCode` (`spec/domains/cli.yaml:139`) since the base with no sentence that defines it.
- Against: the list of plan checks at `docs/evidence-format.md:659` names neither the kind nor the identity key.
- Smallest change: add both to that list and cite `kind_mismatch` in the message at :808.

## List 2: prepared, NOT RUN. No finding yet.

Runner: `slot sh $S/run-pending.sh` (catalog cases, rename cases, host half of portability), then `sh $S/run-pending.sh container` (starts an `ubuntu:24.04` container without network). It prints one line a case: `ok` or `DIFFERS`, exit status, expected status, last line of output; whole outputs go to `$S/pending-out/`. The scripts were parse-checked with `sh -n` only, so `rename-cases.sh` may hold a defect of its own.

Catalog cases, each run by `sh $S/fixed/spec/presets.test.sh --catalog $S/X/<case> --spec $S/fixed/spec/domains`:

| Case | Expected | Rests on |
|---|---|---|
| `population-field-undeclared` | exit 0 | no line of the script reads `population_fields`; `docs/design.md:208`, `population_field_mismatch` at `spec/domains/cli.yaml:143` |
| `pass-rate-number-condition` | exit 1 | :870-871, with the declaration set to `sampled` so it is the only failure |
| `pass-rate-reference` | exit 1 | :883 |
| `tool-key-plus` (`g++:` in a flow map) | exit 1 | :358 |
| `tool-key-quoted` (a quoted key with `@` and `/`) | exit 1 | :358 |
| `tool-key-quoted-block` | exit 1 | :638 |
| `last-line-without-line-feed` | exit 0 | no rule; `presets/README.md:23-24` says lines end with a line feed |
| `record-series-declared` (a written `record-series@1.assessor.yaml`) | exit 0 | :769, :804-816 |
| `record-series-two-units` (two source measurements `run-time`, in `s` and `min`) | exit 1, `unit_mismatch` | :812; one declaration cannot serve both |
| `minimal-forms` (`inputs: {}`, no statements, declaration without `command`, `inputs`, `conditions`; a `document` target) | exit 0 | :354-356; fields Optional in `$S/tables.txt:34-38` |

Rename cases, `sh $S/rename-cases.sh` (the two `run:` blocks of `pages.yml` in clones of depth 2 under `$S/RN/`), expected by reading `pages.yml:39-43` and `:53-61`:
- `copy-out-of-presets`: `planning`.
- `rename-inside-presets` (pull request and push), `rename-into-presets`, `delete-from-presets`, `rename-to-path-with-space`, `merge-commit-of-a-pull-request`, `push-of-two-commits`: `code`.
- `push-of-a-new-branch`, `push-with-a-before-that-is-gone`: empty list, `code`.
- `nonascii-name-in-presets`, `nonascii-name-in-planning`, `nonascii-name-in-docs`: `code`. Git quotes such a path, so it falls to `*)`. For `.engineering/` and `docs/` that is stricter than `AGENTS.md:76`; the classifier lines are pre-existing.

Portability (brief point 7): `sh $S/port.sh $S` on the host, then `docker run --rm --network none -v $S:/s:ro ubuntu:24.04 sh /s/port.sh /s full`. Expected: the same verdict and output checksum for every copy under `L1`, `LB-*`, `V`, `B`, `R`, `X`, and three full runs with `172 of 172 broken copies refused`, exit 0, under dash and mawk.

Also not run because of the two changes: `slot task check` (the gate), any re-run of `slot task check:ci-paths`.

## List 3: every command I ran that builds or tests

| Command | Runs |
|---|---|
| `sh fixed/spec/presets.test.sh --catalog <scratch copy> --spec fixed/spec/domains` | 110 (1 initial, 1 L1, 8 refs, 19 forms, 9 pages, 53 bytes, 2 linebreak, 14 rules, 3 mutant witnesses) |
| `sh spec/presets.test.sh`, full run, in scratch copies | 7 (3 timing, 3 mutants, 1 M1 witness) |
| `slot --here task check:ci-paths`, in scratch copies `CI/m0` to `CI/m3` | 4, ended before the first withdrawal |
| container, `task check`, `cargo`, `ess` | 0 |
| any of the above after the second message | 0 |

All ran outside the tree. Not tests: three YAML readers and a Markdown renderer as oracles (one a temporary Python probe, not kept anywhere), git read commands in the tree, `sh -n` on four scratch scripts.

## Attacked and held

- A later-family preset with every design form I could write (`$S/L1`): `presets: 10 of 10 file(s) valid, 22 of 22 measurement(s) with a row`, exit 0.
- UTF-8: all 26 invalid forms refused with "the line is not UTF-8" (overlong, surrogates, above U+10FFFF, lead F5 to FF, lone continuation, cut at end of line and end of file, in a preset, a page and the README).
- DEL, ESC, CR, VT, FF refused; a tab refused in YAML and accepted on a page; a BOM at the start of a preset refused.
- Rename fix: `sh ci-mutants.sh`. Unchanged: 4 `ok`, `48 cases`, `exit=0`. Without `--no-renames` on the pull_request line: 2 FAIL ("got planning, the step lists examples/functional.md"), `exit=201`. On the push line: 2 FAIL, `exit=201`. On both: 4 FAIL, `exit=201`.
- `condition-unit-with-operator-input`, `requirements-empty-map`, `kind-other`: refused.
- Statements of the correction: no count in prose to drift; the sentence of `functional.md` on the two reference records is true; `AGENTS.md` "no awk function has the name of a parameter" holds per awk program.
- Script alone: under 5 s, one line of output on success.

## Paths written, all under `$S`

- Directories: `fixed/` (archive of 886e4db; a full run created `fixed/target/presets/`), `L1/`, `V/`, `B/`, `R/`, `X/`, `LB-ls/`, `LB-nel/`, `SM/`, `CI/` (each copy holds `target/check-ci-paths/`), `linebreak/`, `pending/`.
- Scripts: `run.sh`, `variants.sh`, `bytes.sh`, `linebreak.sh`, `rules.sh`, `script-mutants.sh`, `ci-mutants.sh`, `port.sh`, `tables-fn.sh`, `make-pending.sh`, `rename-cases.sh`, `run-pending.sh`.
- Outputs: `tables.txt`, `functions.txt`, `fnames.txt`, `pnames.txt`, `ci-mutants.out`, `time-1.out`, `time-2.out`, `time-3.out`.
- `run-pending.sh` will create `pending-out/` and `RN/`.
- Nothing in the tree, nothing under `.engineering/`, nothing in `/tmp`.

```findings
- file: spec/presets.test.sh
  line: 769
  category: acceptance
  severity: blocker
  verdict: CONFIRMED
  origin: introduced
  message: a plan that names the built-in record-series@1, which the specification requires over runs_of and says has no declaration, is refused for a missing record-series@1.assessor.yaml
- file: spec/presets.test.sh
  line: 607
  category: boundary
  severity: blocker
  verdict: NEEDS-CHANGE
  origin: introduced
  message: C1 control characters and U+0085, U+2028, U+2029 pass the control-character rule, and a line break of YAML 1.1 hides a root key gates from the script while three YAML readers read it
- file: spec/presets.test.sh
  line: 804
  category: acceptance
  severity: warning
  verdict: CONFIRMED
  origin: introduced
  message: a reference to an input is refused as assessor, output, scope, boundary, condition unit, identity key and assessment name, where the design lets it stand for any scalar or list
- file: spec/presets.test.sh
  line: 870
  category: acceptance
  severity: warning
  verdict: CONFIRMED
  origin: introduced
  message: an assertion aggregated with pass_rate cannot be compared with a limit or an accepted value, which the design names for a window
- file: spec/presets.test.sh
  line: 786
  category: boundary
  severity: warning
  verdict: CONFIRMED
  origin: introduced
  message: a reference that is an item of a passed list is not checked against the declared type, so an integer and a boolean input pass as items of a list of string
- file: spec/presets.test.sh
  line: 657
  category: boundary
  severity: warning
  verdict: INFEASIBLE
  origin: introduced
  message: a fence closes on any line of three marks, so a row inside a fence of four or after an indented fence line counts as the row of its measurement; built by me, no shipped page reaches it
- file: spec/presets.test.sh
  line: 941
  category: mutant
  severity: warning
  verdict: CONFIRMED
  origin: introduced
  message: with exit 1 turned to exit 0 the script's own 172 cases stay green and a refused presets/ exits 0
- file: spec/presets.test.sh
  line: 120
  category: mutant
  severity: warning
  verdict: CONFIRMED
  origin: introduced
  message: with the assignment of --spec removed the script's own 172 cases stay green and the option is ignored
- file: spec/presets.test.sh
  line: 65
  category: contract-drift
  severity: note
  verdict: CONFIRMED
  origin: introduced
  message: a condition the declaration does not list is accepted, and the list of what is not checked does not name it
- file: spec/presets.test.sh
  line: 882
  category: boundary
  severity: note
  verdict: CONFIRMED
  origin: introduced
  message: the rules that a number with a reference states better and that a set with a reference has a condition are skipped when the reference kind is an input, though neither reads the kind
- file: spec/presets.test.sh
  line: 774
  category: boundary
  severity: note
  verdict: CONFIRMED
  origin: introduced
  message: a target kind given by an input is not checked against the default of that input, where no binding passes a value
- file: spec/presets.test.sh
  line: 673
  category: acceptance
  severity: note
  verdict: CONFIRMED
  origin: introduced
  message: a page with a pipe in a cell, a padded or indented header, a table without outer pipes, a four-backtick fence before a table or a comment mark in inline code is refused
- file: spec/presets.test.sh
  line: 637
  category: acceptance
  severity: note
  verdict: CONFIRMED
  origin: introduced
  message: the block list the design writes for planted_defects is refused, as are text with both kinds of quote, an escape and a folded scalar; each has a flow or quoted spelling or none
- file: spec/presets.test.sh
  line: 818
  category: contract-drift
  severity: note
  verdict: CONFIRMED
  origin: introduced
  message: boundary run_time on an output that declares no boundaries is refused, while the design calls run_time and queue_wait boundaries of Ratchet itself
- file: spec/presets.test.sh
  line: 733
  category: contract-drift
  severity: note
  verdict: CONFIRMED
  origin: introduced
  message: a default of a declaration that holds a dollar sign and a brace is refused with the message of a reference, which the design defines for a value of a preset only
- file: spec/presets.test.sh
  line: 807
  category: judgement
  severity: note
  verdict: CONFIRMED
  origin: introduced
  message: the kind rule and the identity-key rule are implied by the design and by kind_mismatch, and the list of plan checks in docs/evidence-format.md names neither
```
