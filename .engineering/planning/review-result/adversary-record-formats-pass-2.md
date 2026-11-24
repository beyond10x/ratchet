---
format: aep.planning-md/3
id: review-result:adversary-record-formats-pass-2
kind: review-result
status: active
title: adversary, story:record-formats-in-spec, pass 2 of 2
relations:
- reviews: story:record-formats-in-spec
revision: 1
---
Recorded by the coordinator from the adversary's report, verbatim except that the absolute paths of the workstation are replaced and each `message` of the findings block is quoted so the block reads as YAML, and the last entry of the block carries no `verdict` because the store admits no `UNCERTAIN` (the prose of finding 11 keeps the word): `<P>` is the adversary's scratch directory of this pass, `<W>` the managed worktree of the unit.

unit: story:record-formats-in-spec
verdict: red
cases: executed 4→6 test scripts, red 1 (`spec/gate-inputs.test.sh`, exit 1; the two added scripts run by path, `Taskfile.yml` is the unit's)
origin: introduced 9, pre-existing 2, undecided 0
wrote-outside-worktree: <P> (46 MB) | one worktree session lease `adversary-w1-record-formats-p2`, released
needs-coordinator: yes

Pass 2 of 2, correction `d621cbe` against `cad73e9`. Worktree: `<W>`; paths below are relative to it, `<P>` is the scratch directory above.

All nine pass-1 findings are closed in the tree. The gate fails when findings 1 to 4 are reopened; it stays green when findings 6 and 9 are reopened, and when a change of form hides a broken row or example from the three scripts. Those scripts are the ones I added in pass 1, so the gaps in findings 1 to 3 below are in my own cases, now gate steps of the unit.

## 1. `git --no-pager diff --stat`

No tracked unit file changed by me. `.engineering/waves/0.1.0-wave-1.md` was already modified when the pass started; I did not touch it. `git status --short`:
```
 M .engineering/waves/0.1.0-wave-1.md
?? spec/cli-errors.test.sh
?? spec/gate-inputs.test.sh
```
Both untracked files are test scripts (POSIX sh and awk; `gate-inputs` needs `jq`). Ignored paths written: `target/gate-inputs/`, `target/record-examples/`.

## 2. Pass-1 findings: closed, and does the gate hold them

| Pass-1 finding | Closed, measured by | Reopened: `slot task check:spec` |
| --- | --- | --- |
| 1 `CoverageRow` lacks two fields | `cli-coverage-row: 9 of 9` | n1a, n1b: exit 201 |
| 2 names only | `record-types: 97 of 97` | m1, m2, m3, m5: exit 201 |
| 3 one direction | same line, `97 of 97 declared fields have a row` | m4: exit 201 |
| 4 § 6 examples unread | `record-examples: 563 of 563 members of 3 example(s)` | m6: exit 201 |
| 5 "decoders" | no "decoder" left in any document; crate synthesized now: 211 capabilities, 0 refused | prose, no gate step |
| 6 `samples` | my probe on a crate synthesized now: "a sampled number without samples ... refused" | n2: exit 0 |
| 7 bare tool version | all five `examples/*.ratchet.yaml` through `yq`: no member outside the written form | no gate step reads `examples/` |
| 8 bare bounds on the research page | no bare bound left in `docs/`, `examples/`, `research/`, `spec/` | no gate step |
| 9 `candidate_unresolved` | `spec/cli.yaml:64`, design :705 and :1055, format :653, README :229 | n3: exit 0 |

t1 (field removed) and t2 (`shorthand: min` back) still end with exit 201. All results: `<P>/mutants.txt`.

## 3. Cases added (each run alone before the suite)

| File | Asserts | Now | Time |
| --- | --- | --- | --- |
| `<W>/spec/gate-inputs.test.sh` | the four gate scripts refuse five copies with a hidden defect; the unchanged copy has to pass first | red, exit 1 | 0.5 s |
| `<W>/spec/cli-errors.test.sh` | an error or refusal the design's command table names for a command is in `errors:` of that command | green on the tree, red on n3 | 0.005 s |

First red output of `gate-inputs`, last script lines cut (`<P>/red-gate-inputs.txt`):
```
accepted: section-renumbered: the assessor contract is § 11 and its row `identity_keys` is no declared field
  record-fields: 78 of 78 field rows declared
  record-types: 78 of 78 field rows as declared, 78 of 78 declared fields have a row
accepted: table-header: the header of the output table of § 10 starts `| Member |` and its row `kinds` is no declared field
  record-fields: 90 of 90 field rows declared
accepted: example-fence: the first example of § 6 is fenced `jsonc` and holds the member `candidat`
  record-examples: 80 of 80 members of 2 example(s) decode under the specification
accepted: row-type: CoverageRow.not_executed is a list of text, and EvidenceCoverage.not_executed a list of units
accepted: row-unused: RunSummary.coverage and VerdictRow.coverage are a struct without the two lists, and CoverageRow is used nowhere
gate-inputs: 0 of 5 broken inputs refused, 5 accepted
exit 1
```
`cli-errors` on the tree: `cli-errors: 3 of 3 named errors declared on their command`. On the n3 copy: `cli-errors: 2 of 3 named errors declared on their command, 1 missing`, exit 1. It also fails when `requirement_without_reference` is removed from `reference-adopt` alone.

## 4. Suite, after the cases existed

`slot task check:spec`, exit 0, 1.9 s wall (`<P>/suite-after.txt`):
```
record-fields: 97 of 97 field rows declared
record-types: 97 of 97 field rows as declared, 97 of 97 declared fields have a row
record-examples: 563 of 563 members of 3 example(s) decode under the specification
cli-coverage-row: 9 of 9 coverage fields reported
211 capabilities: 211 generated, 0 obligation(s), 0 refused
```

## 5. Findings (commit d621cbe)

1. `spec/record-fields.test.sh:66` (and `spec/record-types.test.sh:123`, `:128`) — CONFIRMED, introduced. Measured: § 10 is found by its number and its tables by the header text, and only § 3 states a row count. v1 (§ 10 renumbered 11, one row broken), v3 (header of the output table changed, one row broken) and v8 (output table emptied) end with exit 0 and "78 of 78" or "90 of 90". Reaches: a section inserted before § 10 drops the 19 rows of the declaration from the gate. The same edits in § 3 fail (v4, exit 201).
2. `spec/record-examples.test.sh:74` — CONFIRMED, introduced. Measured: an example is a block fenced exactly `json`, and nothing states how many § 6 holds. v2 (first block fenced `jsonc`, member `candidat`) ends with exit 0 and "80 of 80 members of 2 example(s)"; v9 (two blocks deleted) with "1 example(s)". Reaches: 483 of the 563 members sit in the first block.
3. `spec/cli-coverage-row.test.sh:29` — CONFIRMED, introduced. Measured: the script compares field names of two structs. n4 (`CoverageRow.not_executed` as `Optional<List<String>>`) and n5 (`RunSummary.coverage` and `VerdictRow.coverage` typed with a new struct of the 7 counts) end with exit 0 and "9 of 9". `spec/domains/cli.yaml:67` says "with the same type". Reaches: pass-1 finding 1 reopens by either edit with the gate green.
4. `spec/domains/evidence.yaml:418` — CONFIRMED, introduced. Measured: no gate step reads an invariant. n2 (the new `samples` invariant removed), n6 (the rule-6 invariant removed) and v6 (a § 6 result with `at_least: true` and no `incomplete`) end with exit 0. `spec/README.md:94` says the generated types carry each rule as a check; only a Rust probe outside the gate measures that. Reaches: every rule § 8 marks done as an invariant.
5. `spec/cli.yaml:64` — CONFIRMED, introduced. Measured: n3 ends with exit 0; no gate step compares an error a document names with the binding. `spec/cli-errors.test.sh` fails on n3 and is not a gate step. Reaches: `candidate_unresolved` and `requirement_without_reference`.
6. `docs/evidence-format.md:688` — CONFIRMED, introduced. Measured: no gate step reads the two YAML examples of § 10. v7 (`identity_key` renamed in `assessor.yaml` and in its row) ends with exit 0 while `:713` still writes `identity_key`. Reaches: the declaration the first assessor is written from.
7. `docs/evidence-format.md:80` — CONFIRMED, introduced. Measured by reading: the row of `evidence.target.window` is Required "exactly for a time-window plan". `ratchet.evidence.ResolvedTarget` has two invariants, neither on `window`, and neither the table under § 8 nor `spec/README.md` lists the rule as the reader's. The row is as at `fe879ac`; the list that omits it is the unit's.
8. `spec/README.md:164` — CONFIRMED, introduced. Measured by reading: "`identity` against `key`: each joins a run and an assessor". Both are members of one result (§ 3: `items[].identity`, "Exactly the fields of the key"), `identity` is `Json`, and the table under § 8 of the format does not list the rule.
9. `spec/domains/specification.yaml:286` — CONFIRMED, introduced. Measured by reading: "The design's bare list is written `{ids: [...]}` here", and `docs/design.md:142` writes `{ids: [...]}` since this correction. The other three unasked changes hold (part 6).
10. `examples/generated-artifact.ratchet.yaml:52` — CONFIRMED, pre-existing. Measured: the entry `{requirement, when}` has no `mode`; `ratchet.specification.GateRequirement.mode` is required, and its summary gives `enforce` only for the bare name (`<P>/probe-example-entries.txt`). Same line at `fe879ac`.
11. `research/candidate-presets.md:98` (and `:184`, `:249`) — UNCERTAIN, pre-existing. Measured: `conditions: {toolchain: pinned}`, which `docs/design.md:955` says is removed. I did not determine whether the page is a dated record; the correction did edit its bounds.

## 6. Attacked, not broken

- **Unasked changes.** "Nine points" matches nine rows of the § 12 table, and no document says eight. The E5 wording agrees between format § 8 items 15 and 16 and `spec/README.md:116-120`. `ess` on t2 prints the reason the documents now give for the missing shorthand.
- **The tenth item.** `docs/evidence-format.md:474` agrees with U6, the Q6 row and the second § 6 example.
- **`at_least` without a value.** The format states no rule: rules 5 and 6 allow it, and U6 says only that the assessor leaves the value out. The specification declares none; the generated check accepts it. Nothing to declare or list.
- **An empty `key`.** The format says "list of text", required, and nothing on its length. Same result.
- **Other conditional rows of § 3 and § 10.** Each is an invariant or listed, except finding 7.
- **Script steps.** A row without backticks fails (v5, exit 201). A missing `jq` fails with the named message, in the task and in the script (`<P>/probe-no-jq.txt`). Nothing is left outside `target/`.
- **`examples/`.** 118 member lines do not decode as the bare entity; all are the written form (`project` and `serves` as keys, the `requires` list, YAML numbers for `Decimal`), except finding 10. `examples/ratchet.toml` matches `ratchet.config.LocalConfig`, checked by reading.
- **Not run:** `slot task check` (the whole gate).

## 7. Needs you

- Whether the two added scripts become gate steps, and whether findings 1 to 3 are fixed in the three scripts: this was the last pass.
- Finding 4: a gate step for invariants means compiling the synthesized crate in the gate.
- Findings 7 and 8 are choices of wording in the format's own list.

## 8. Written outside the worktree

All under `<P>`:
- scripts: `mkcopy.sh`, `mutants.sh`, `run-invprobe.sh`, `probe-example-specs.sh`, `probe-no-jq.sh`
- outputs: `suite-before.txt`, `suite-after.txt`, `mutants.txt`, `red-gate-inputs.txt`, `first-cli-errors.txt`, `final-*.txt` (6), `invprobe.txt`, `synthesize.txt`, `probe-example-specs.txt`, `probe-example-entries.txt`, `probe-no-jq.txt`
- directories: `synth/`, `invprobe/`, `no-jq-bin/`, `copies/` (27 scratch copies)

```findings
- file: spec/record-fields.test.sh
  line: 66
  category: mutant
  severity: warning
  verdict: CONFIRMED
  origin: introduced
  message: 'Section 10 is found by its number and its tables by the header text with no stated row count, so a renumbered section or a changed header drops its rows and a broken row passes the gate.'
- file: spec/record-examples.test.sh
  line: 74
  category: mutant
  severity: warning
  verdict: CONFIRMED
  origin: introduced
  message: 'An example is read only from a block fenced exactly json and no count of examples is stated, so a block fenced otherwise or deleted is skipped and the gate reports fewer examples with exit 0.'
- file: spec/cli-coverage-row.test.sh
  line: 29
  category: mutant
  severity: warning
  verdict: CONFIRMED
  origin: introduced
  message: 'The script compares field names of two structs only, so a CoverageRow field of another type, or a run summary typed with another struct, passes while cli.yaml says the row has the same types.'
- file: spec/domains/evidence.yaml
  line: 418
  category: mutant
  severity: warning
  verdict: CONFIRMED
  origin: introduced
  message: 'No gate step reads an invariant, so removing the new samples invariant or the rule 6 invariant, or breaking rule 6 in a section 6 example, leaves task check:spec at exit 0.'
- file: spec/cli.yaml
  line: 64
  category: mutant
  severity: warning
  verdict: CONFIRMED
  origin: introduced
  message: 'Removing candidate_unresolved from assess in the binding alone leaves the gate green; the added spec/cli-errors.test.sh fails on it and is not a gate step.'
- file: docs/evidence-format.md
  line: 688
  category: mutant
  severity: warning
  verdict: CONFIRMED
  origin: introduced
  message: 'No gate step reads the two YAML examples of section 10, so a field renamed in assessor.yaml and its row leaves the example declaration behind with the gate green.'
- file: docs/evidence-format.md
  line: 80
  category: acceptance
  severity: warning
  verdict: CONFIRMED
  origin: introduced
  message: 'The row of evidence.target.window requires it exactly for a time-window plan, and the rule is neither an invariant nor in either list of rules left to the reader.'
- file: spec/README.md
  line: 164
  category: contract-drift
  severity: warning
  verdict: CONFIRMED
  origin: introduced
  message: 'The README says identity against key joins a run and an assessor, though both are members of one result, and the format''s table of rules left to the reader omits the rule.'
- file: spec/domains/specification.yaml
  line: 286
  category: contract-drift
  severity: warning
  verdict: CONFIRMED
  origin: introduced
  message: 'The summary of ExecutedIds still says the design writes a bare list, and docs/design.md:142 writes {ids: [...]} since this correction.'
- file: examples/generated-artifact.ratchet.yaml
  line: 52
  category: contract-drift
  severity: warning
  verdict: CONFIRMED
  origin: pre-existing
  message: 'The gate entry with requirement and when has no mode, which GateRequirement requires and whose summary defaults only for a bare requirement name.'
- file: research/candidate-presets.md
  line: 98
  category: contract-drift
  severity: warning
  origin: pre-existing
  message: 'The published page still writes conditions {toolchain: pinned}, a spelling the design removed; whether the page is a dated record was not determined.'
```
