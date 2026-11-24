---
format: aep.planning-md/3
id: review-result:adversary-record-formats-pass-1
kind: review-result
status: active
title: adversary, story:record-formats-in-spec, pass 1 of 2
relations:
- reviews: story:record-formats-in-spec
revision: 1
---
Recorded by the coordinator from the adversary's report, verbatim except that the absolute paths of the workstation are replaced: `<S>` is the adversary's scratch directory, `<W>` the managed worktree of the unit.

unit: story:record-formats-in-spec, commit cad73e9 against base fe879ac, pass 1 of 2
verdict: red
cases: executed 97→97 by `slot task check:spec` (field rows; 3 added scripts run by path only, Taskfile.yml is the unit's file), red 1 (`spec/cli-coverage-row.test.sh`, exit 1)
origin: introduced 7, pre-existing 2, undecided 0
wrote-outside-worktree: <S> (39 MB, contents in part 6) | one worktree session lease `adversary-w1-record-formats-p1`, released
needs-coordinator: yes

Worktree: `<W>`. Paths below are relative to it; `<S>` is the scratch directory above. The acceptance statement holds: `slot task check:spec` exits 0 with `record-fields: 97 of 97 field rows declared` and `211 capabilities: 211 generated, 0 obligation(s), 0 refused`. The findings are what that gate does not measure. Needs you: findings 1, 5 and 8.

## 1. `git --no-pager diff --stat`

Empty: no tracked file changed. `git status --short`:
```
?? spec/cli-coverage-row.test.sh
?? spec/record-examples.test.sh
?? spec/record-types.test.sh
```
All three are test scripts (POSIX sh; `record-examples` also needs `jq`). No unit file was edited. Ignored paths written by runs: `target/check-spec/`, `target/record-examples/`.

## 2. Cases added (each written and run alone before the suite)

| File | Asserts | Now | Time |
| --- | --- | --- | --- |
| `<W>/spec/cli-coverage-row.test.sh` | every field of `ratchet.evidence.EvidenceCoverage` is a field of `ratchet.cli.CoverageRow` | red, exit 1 | 0.00 s |
| `<W>/spec/record-types.test.sh` | each § 3 / § 10 row resolves by path from the root type, with the optionality and type its row gives; every declared field of a described struct has a row | green on the unit, red on 5 mutants | 0.01 s |
| `<W>/spec/record-examples.test.sh` | every member of the three § 6 JSON blocks is a declared field with a JSON value of the declared type, required fields present | green on the unit, red on 3 mutants | 0.05 s |

Red output of the first, verbatim (`<S>/red-cli-coverage-row.txt`):
```
missing: ratchet.evidence.EvidenceCoverage.executed_ids is not a field of ratchet.cli.CoverageRow
missing: ratchet.evidence.EvidenceCoverage.not_executed is not a field of ratchet.cli.CoverageRow
cli-coverage-row: 7 of 9 coverage fields reported, 2 missing
exit 1
```
First run of the other two: `record-types: 97 of 97 field rows as declared, 97 of 97 declared fields have a row`, `record-examples: 563 of 563 members of 3 example(s) decode under the specification`.

Mutants, each one edit in a scratch copy, each through `slot task check:spec` (`<S>/mutants-2.txt`). All six leave the unit's gate at exit 0:

| Mutant | `task check:spec` | Caught by |
| --- | --- | --- |
| m1 `RunDetails.local_inputs` → `Optional<List<String>>` | exit 0 | record-types |
| m2 `Evidence.protocol_version` → `String` (required) | exit 0 | record-types, record-examples |
| m3 `Evidence.source` → `Optional<String>` | exit 0 | record-types |
| m4 `Evidence` gains `started_at: Optional<Timestamp>` | exit 0 | record-types |
| m5 `Evidence.results` → `Map<String, MeasurementResult>` (§ 8 item 4 undone) | exit 0 | record-types (22), record-examples (447) |
| m6 `item` renamed `scope_item` in the specification and in the § 3 row, examples untouched | exit 0 | record-examples (42) |

## 3. Suite, after the cases existed

`slot task check:spec` in the worktree, exit 0 (`<S>/suite-check-spec.txt`), last lines:
```
211 capabilities: 211 generated, 0 obligation(s), 0 refused
13 artifact(s), written to target/check-spec/crate
exit 0
```
`<before>` is the implementor's `cases:` line (97). The three added scripts are not called by `check:spec`.

## 4. Findings (commit cad73e9)

1. `spec/domains/cli.yaml:61` — CONFIRMED, introduced. Measured: `CoverageRow` lacks `executed_ids` and `not_executed` (red case above). Claim (b) is false as asked: fields are lost. At fe879ac `RunSummary.coverage` was `EvidenceCoverage` and held `executed_ids`. The implementor's reason holds (`ess specify cli`: "CLI type `ratchet.evidence.EvidenceCoverage` has unsupported invariants or union semantics"), but the loss is not forced: a copy with both lists added to `CoverageRow` passes `ess specify validate` and `ess specify cli` (`<S>/probe-coverage-row.txt`). Reaches: `RunSummary.coverage` (result of `assess`) and `VerdictRow.coverage` (gate report). `spec/README.md:157` states the drop; the implementor's report does not.
2. `spec/record-fields.test.sh:98` — CONFIRMED, introduced. Measured: the script checks a row's name only, in a type its own table names; m1, m2, m3 and m5 pass the gate. Reaches: every later specification edit; with m5 the gate is green while § 8 item 4 ("Done") is false.
3. `spec/record-fields.test.sh:54` — CONFIRMED, introduced. Measured: rows are checked document-to-specification only; m4 adds a time of day to the closed `Evidence` and the gate stays green, though `spec/README.md:100` says rule 9 "holds by declaration". Reaches: a field added to `evidence` without a row.
4. `docs/evidence-format.md:389` — CONFIRMED, introduced. Measured: nothing in `check:spec` reads the § 6 examples; m6 passes the gate with 42 example members undeclared. Reaches: any rename made in table and specification together.
5. `spec/README.md:52` — CONFIRMED, introduced. Measured: the sentence "the types and decoders from `ess generate synthesize`" (new in this unit) and `docs/design.md:142` "the generated decoder reads a bound from its object only" name something the crate does not hold. The crate synthesized from the unit has 191 `domain_type` and 20 `entity_lifecycle` capabilities and no function outside `json.rs` that takes a JSON value (`<S>/probe-decoders.txt`); removing `undeclared_fields: ignored` changes no byte of `evidence.rs` (`<S>/probe-open-struct.txt`). The same holds for fe879ac without the three shorthands (203 capabilities). Reaches: `story:cli-skeleton-validate`, whose scope says "YAML to the generated decoders" and whose context says "typed decoders".
6. `spec/domains/evidence.yaml:364` — CONFIRMED, introduced. Measured: the § 3 row of `samples` is Required "with `aggregation`, and for a sampled result"; only the first half is an invariant (`:415`), the summary drops the second, and the table of non-invariants in § 8 does not list it. The generated check accepts a sampled number without `samples` (`<S>/invprobe.txt`). `run.started_at`, Required "with a sampled result", is an invariant. Reaches: a reader built from the specification alone.
7. `examples/generated-artifact.ratchet.yaml:19` (and `:33`) — CONFIRMED, pre-existing. Measured: `tools: {ess: "0.97.4"}` is text where `ratchet.specification.ToolPin` is a struct (`{version: "0.97.4"}`); `docs/design.md:99` shows the same bare form. The added checker on the example: "`observation.conditions.all.tools.ess` is not an object" (`<S>/probe-example-specs.txt`). Same lines and same struct at fe879ac. Reaches: a decoder that reads a struct from its object only; the fixture of `epic:generated-artifact`.
8. `research/candidate-presets.md:140` (and `:228`) — CONFIRMED, introduced by decision 1. Measured: `coverage: {skipped: 0, unsupported: 0}`, valid at fe879ac and not in 0.1.0. The page is on the site (`website/sidebars.ts:20`). The implementor reported it; `research/` is outside the story's scope.
9. `spec/cli.yaml:56` — CONFIRMED, pre-existing. Measured: `docs/evidence-format.md` § 10 says the CLI "records no run and reports the error" when it cannot resolve the candidate; `assess` declares four errors and none for this. Sentence and error list are the same at fe879ac. Reaches: the story that builds `assess`.

## 5. Attacked, not broken

- Claim (a): no member of either § 6 example is undeclared or typed differently. 563 members decode by program; the § 10 YAML declaration decodes as `ratchet.assessor.Assessor`, 59 of 59 (through `yq`, `<S>/probe-examples.txt`).
- The invariants as ESS compiled them accept the § 6 shapes (document, five incomplete results, `not_executed`) and refuse 9 broken documents for rules 1, 2, 5, 6, 7, the document target and § 2 (`<S>/invprobe.txt`). Rule 3 and the sum of rule 4 are accepted, as § 8 says.
- § 8 items 1 to 25: every spelling marked done is in the specification; ESS reads `undeclared_fields` (refuses `bogus`, names `refused` or `ignored`).
- Cause lists: `FailCause` 7, `InsufficientEvidenceCause` 14, `VerdictCause` 21, the two invariant lists of `RequirementVerdict` and the design § 5 table agree (`<S>/probe-causes.txt`).
- `requirement_without_reference` is on `reference-propose` and `reference-adopt`; the exit-to-completion mapping agrees between the binding comment, `RunSummary.completion`, `AssessorExit` and § 10.
- `check:spec` exits 201 when the script fails (field removed) and when synthesis refuses (`shorthand: min` back); nothing is left outside `target/`.
- All 97 rows are read: the independent path walk finds 97 rows and 97 declared fields; the From column counts 48, 7, 23.
- Bounds and adoptions of all five `examples/*.ratchet.yaml` decode as objects; no bare bound or adoption in `docs/`, `examples/`, `spec/`.
- Not verified: `examples/ratchet.toml` against `ratchet.config.LocalConfig` (the installed `yq` reads no TOML).

Two deviations of mine: the first mutant run (`<S>/mutants-1.txt`) called `task check:spec` without `slot`; it was repeated with it. `probe-causes.sh` created and removed an empty `f.spec` in the worktree root.

## 6. Written outside the worktree

All under `<S>`:
- scripts: `mkcopy.sh`, `mutants.sh`, `probe-causes.sh`, `probe-coverage-row.sh`, `probe-decoders.sh`, `probe-example-specs.sh`, `probe-examples.sh`, `probe-open-struct.sh`
- outputs: `red-cli-coverage-row.txt`, `first-record-types.txt`, `first-record-examples.txt`, `final-record-fields.txt`, `final-cli-coverage-row.txt`, `final-record-types.txt`, `final-record-examples.txt`, `mutants-1.txt`, `mutants-2.txt`, `suite-check-spec.txt`, `invprobe.txt`, `probe-causes.txt`, `probe-coverage-row.txt`, `probe-decoders.txt`, `probe-example-specs.txt`, `probe-examples.txt`, `probe-open-struct.txt`
- directories: `synth/` (crate synthesized from the unit), `invprobe/` (Rust probe with its `target/`), `causes/`, `copies/` (17 scratch copies: `b1`, `b2`, `base-no-shorthand`, `examples`, `example-specs`, `m1-type`, `m2-optionality`, `m3-place`, `m4-undocumented`, `m5-results-map`, `m6-example-drift`, `open-bogus-key`, `open-bogus-value`, `open-rejected`, `open-removed`, `t1-script-fails`, `t2-synthesis-refuses`)

```findings
- file: spec/domains/cli.yaml
  line: 61
  category: contract-drift
  severity: warning
  verdict: CONFIRMED
  origin: introduced
  message: ratchet.cli.CoverageRow drops executed_ids and not_executed of EvidenceCoverage from the assess result and the gate report, though a row holding both passes ess specify cli.
- file: spec/record-fields.test.sh
  line: 98
  category: mutant
  severity: warning
  verdict: CONFIRMED
  origin: introduced
  message: The script checks a row's name only in a type its own table names, so a field with another type, optionality or parent type passes task check:spec.
- file: spec/record-fields.test.sh
  line: 54
  category: mutant
  severity: warning
  verdict: CONFIRMED
  origin: introduced
  message: Rows are checked from the document to the specification only, so a field added to the closed Evidence without a row, a Timestamp included, passes the gate.
- file: docs/evidence-format.md
  line: 389
  category: mutant
  severity: warning
  verdict: CONFIRMED
  origin: introduced
  message: No gate step reads the examples of section 6, so a rename made in the field table and the specification leaves 42 example members undeclared with the gate green.
- file: spec/README.md
  line: 52
  category: contract-drift
  severity: warning
  verdict: CONFIRMED
  origin: introduced
  message: The README and design.md:142 name generated decoders, and the crate synthesized from this specification holds no typed decoder of any domain type.
- file: spec/domains/evidence.yaml
  line: 364
  category: acceptance
  severity: warning
  verdict: CONFIRMED
  origin: introduced
  message: The row of samples requires it for a sampled result, and the specification neither declares that as an invariant nor lists it among the rules left to the reader.
- file: examples/generated-artifact.ratchet.yaml
  line: 19
  category: contract-drift
  severity: warning
  verdict: CONFIRMED
  origin: pre-existing
  message: The example writes a tool version as bare text where ratchet.specification.ToolPin is a struct, so it does not decode from its object.
- file: research/candidate-presets.md
  line: 140
  category: contract-drift
  severity: warning
  verdict: CONFIRMED
  origin: introduced
  message: A published page still writes bare coverage bounds, which decision 1 removed from 0.1.0; the path is outside the story's scope.
- file: spec/cli.yaml
  line: 56
  category: contract-drift
  severity: warning
  verdict: CONFIRMED
  origin: pre-existing
  message: Section 10 of the format says assess reports an error and records no run when the candidate cannot be resolved, and the binding declares no error for it.
```
