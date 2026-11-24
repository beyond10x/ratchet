# Ratchet executable specification

This directory declares Ratchet's domain in ESS before any code exists (`AGENTS.md`
§ Specification first). It follows `docs/design.md` revision 4 and the two record formats of
`docs/evidence-format.md`: the assessment run `ratchet-evidence/1` and the assessor declaration
`ratchet-assessor/1`. Every entity, field, enum value, command and flag here is a proposal taken
from those documents; each can still change before the first release. Each `UNMAPPED:` comment
marks a question the design does not answer yet.

| File | Declares |
|---|---|
| `domains/specification.yaml` | what a `ratchet/1` document holds: quality specification, quality statement, subject, audience, assessment plan with its map of measurements (kind, value type, scope, unit, boundary, `better`, `filter`), target with `selection`, observation plan (scenarios, `paired`, `window` as `{length, last}`, `population` as `{runs_of, from}` or `{filter}`, `min_samples`, conditions per target class, coverage bounds), quality requirement (`meaning`, `serves`, condition, reference with `paths`, tolerance and `adoption`, planted defects), gate (kind, `evidence`) and gate entry (mode, `since`, `when`), exception keyed by its id, input declarations with `local`, preset and preset binding |
| `domains/assessor.yaml` | the assessor declaration `ratchet-assessor/1`: `format`, name and version, `command`, `targets` and `target_input`, the typed `inputs` by name, the declared conditions, the coverage unit and coverage counts, the `outputs` by name (value type, kind, scopes, unit or none, boundaries, identity key, item fields), the population fields; the reserved arguments of the invocation and what an exit status means; the built-in `record-series@1` |
| `domains/evidence.yaml` | the assessment run `ratchet-evidence/1` in two parts. `evidence`: project, assessment, assessor, candidate, resolved target with the window (bounds, items, newest item, runs left out), resolved inputs, completion, observed conditions (host load as mean, min and max; tools), coverage with its unit and the units not executed, the list of results (complete or incomplete, the value members beside `value_type`), import source. `run`: start and end, queue wait and run time, resolved local inputs, artifacts. Proof record with the defect ids refused and accepted |
| `domains/reference.yaml` | reference record (generated or accepted value; `values`, or `items` as `{identity, reason, owner}`), reference change, trade-off with `gains` and `loosens` |
| `domains/gate.yaml` | gate decision (a candidate, or for an operational gate none) and each entry's result: evaluated or not applicable; pass, fail or insufficient evidence, with its cause from the list of its verdict (`FailCause`, `InsufficientEvidenceCause`), its next step (`candidate`, `assessment`, `system`) and in an operational gate its window |
| `domains/config.yaml` | the local config `ratchet.toml` with `[inputs.<assessment>]`, a catalog source as a git repository or a directory of the checkout, the record store it names and the local record directory |
| `domains/cli.yaml` | the typed inputs, results and refusals of the `ratchet` commands |
| `cli.yaml` | the `ess-cli/2` presentation binding of the `ratchet` command surface |

The entities a project authors, the assessors, presets, the local config and the record store
are `provided: true`: they come from a file, and no Ratchet command creates them. Records hold
one state, `Recorded` (a reference, `Adopted`): this specification declares no ESS command that
writes a record yet, and current or superseded, active or expired are computed, not stored.

The owner decided D1 to D4 of design § 9 on 2026-11-24, all A: reference and trade-off records
are files in the tree (D1), a loosening lands in a change of its own merged before the candidate
(D2), `evidence` defaults to `any` (D3), an exception ends at a date only (D4). D5 and D6 are
open, written under default A, as the design is: the evidence of an operational gate is a
time-window plan (D5), and an input that differs per machine is declared local by its assessor
and supplied by `ratchet.toml` (D6). A different answer to D5 or D6 changes the observation plan,
the gate decision, the input declaration and `[inputs]`.

```console
task check:spec
ess generate cli --path spec --binding spec/cli.yaml --out <directory>
```

`task check:spec` needs `ess` and `jq`, and fails with a named message when `jq` is missing. It
runs seven steps, and `task check` calls it:

1. `ess specify validate --path spec --strict-requires`;
2. `ess specify cli --path spec --binding spec/cli.yaml --strict-requires`;
3. `sh spec/record-fields.test.sh`, which reads every field row of `docs/evidence-format.md`
   § 3 and § 10 and fails when one is not declared in `domains/evidence.yaml` or
   `domains/assessor.yaml` under the name the row gives. Its last line is
   `record-fields: <n> of <n> field rows declared`;
4. `sh spec/record-types.test.sh`, which compares the same rows with the declarations in both
   directions: the struct a row names, whether the field is required, and its type; and every
   declared field of a struct that the two documents hold has a row. Its last line is
   `record-types: <n> of <n> field rows as declared, <m> of <m> declared fields have a row`;
5. `sh spec/record-examples.test.sh`, which reads the JSON examples of
   `docs/evidence-format.md` § 6 with `jq` and fails when a member is not declared, a required
   member is absent, or a value does not have the declared type. Its last line is
   `record-examples: <n> of <n> members of <b> example(s) decode under the specification`;
6. `sh spec/cli-coverage-row.test.sh`, which fails when a field of
   `ratchet.evidence.EvidenceCoverage` is missing from `ratchet.cli.CoverageRow`. Its last line
   is `cli-coverage-row: <n> of <n> coverage fields reported`;
7. `ess generate synthesize --path spec --target rust --layout crate` into the ignored
   `target/check-spec/`, which fails when the Rust target refuses a declaration. Its line
   `<n> capabilities: <n> generated, 0 obligation(s), 0 refused` is printed.

Nothing generated is committed yet. The parser and process adapter come from `ess generate cli`.
The crate from `ess generate synthesize` holds the types, a `broken_constraint` check on each
type with invariants, the lifecycles of the entities, and the JSON helpers of `json.rs`. It
holds nothing that reads a file into the types: what does is settled by the story that builds
the workspace. Both are drift-checked in the gate once they are in the tree.

## Resolved in design revision 4

Revision 4 ([§ 11](https://github.com/beyond10x/ratchet/blob/main/docs/design.md#11-changes-from-revision-3))
answers two of the markers revision 3 left here: the shape of `population` (G26), and part of the
absent `selection` (a time-window plan without one serves an operational gate). The other
changes it brings are written in: `window` and `min_samples` for a window, the built-in
`record-series@1`, gate kinds with the next step `system`, local inputs and `input_not_local`,
the coverage unit on the assessor, accepted items as `{identity, reason, owner}`, and the unit
rule.

ESS checks these rules as invariants:

- a `window` holds `length` or `last`; a `population` is `{runs_of, from}` or `{filter}`;
- a time-window plan declares `window`, `population` and `min_samples`, and a plan of another
  kind declares neither `window` nor `population`;
- a plan over `runs_of` names `record-series@1` (and only such a plan does), has no `selection`
  and declares no conditions;
- a local input has the type `path` and is not a list;
- a gate decision has a candidate exactly when its gate is a candidate gate;
- a reference record has `values` or `items`, not both;
- a window with items names the time of the newest;
- a verdict that is not a pass has a cause, from `FailCause` for a fail and from
  `InsufficientEvidenceCause` for insufficient evidence.

And these rules of `docs/evidence-format.md` § 4 and § 10. The Rust types that
`ess generate synthesize` writes carry each as a check (`broken_constraint` on a struct,
`broken_invariant` on an entity):

- an assessment run has the `format` `ratchet-evidence/1`, an assessor declaration
  `ratchet-assessor/1`;
- rule 1: `candidate` is present exactly when `target.selection` is;
- rule 2: a result has `item` exactly when its `scope` is not `run`;
- rule 4, in part: `passed` and `failed` are each at most `executed`, and no id is twice in
  `executed_ids` and `not_executed`, within one list or across the two;
- rule 5: a complete result has the value of its type, an incomplete one has none or a number
  with `at_least`, and a result has only the value members of its `value_type`;
- rule 6: `at_least: true` only on an incomplete result;
- rule 7: when `completion` is not `completed`, every result is incomplete with the cause of
  that completion;
- a document with a sampled result has `run.started_at` and `run.ended_at`;
- a number has `samples` when it has `aggregation`, and when its `kind` is `sampled`
  (format § 3);
- a resolved input has `value` or `digest`, and `digest_form` exactly with `digest`; a target
  of the kind `document` has `identifiers` and no `revision`;
- an output declares `identity_key` exactly for the value type `identity_set`, and an assessor
  declares `target_input` exactly when its `targets` hold `document`.

Rule 9 holds by declaration for a time: `Evidence` has no `Timestamp` outside the window of its
target. `Evidence` is a closed struct and `RunDetails` an open one (`undeclared_fields:
ignored`), which is E5: a reader rejects an unknown member of `evidence` and ignores one of
`run`. That is a declaration, and the reader's to apply: the key changes nothing in the
synthesized crate.

## What ESS cannot express here

These rules join two declarations, or need an instance, and an ESS invariant reads only the
fields of one entity or struct. Each is a `ratchet validate` code, a CLI refusal or a summary
in the domain files, and is the implementation's to check.

- **Gate kind against plans.** Every requirement of an operational gate names a time-window plan
  without `selection`, and its entries have no `when`; a candidate gate takes no time-window
  plan without `selection` (`plan_does_not_fit_gate_kind`, `when_in_operational_gate`). The
  rule joins a gate, its entries and their plans.
- **Unit.** A measurement, its `condition` and a record value have a `unit` exactly when the
  assessor declares one for the output (`unit_missing`, `unit_mismatch`, `unit_not_declared`).
  The rule joins a plan and its assessor.
- **Next step and window in a decision.** `system` replaces `candidate`, and a row carries its
  window, only in an operational gate. The kind is on the decision, not on its rows.
- **Local inputs.** The specification sets no local input (`local_input_in_specification`), a
  preset declares none (`preset_input_local`), and `[inputs.<assessment>]` sets only inputs
  the plan's assessor declares local (`input_not_local`). Each joins a plan, a preset or the
  local config with an assessor's declaration.
- **`record-series@1`.** ESS declares no instance of a provided entity. Its declaration is a
  comment in `domains/assessor.yaml` and the invariant on the assessment plan.
- **`runs_of`.** It sits inside the observation plan, which a relation's `via:` cannot name, so
  the link to the source plan has no relation entry.
- **The project, plan and assessor of a run.** They are members of `evidence`, and a relation's
  `via:` cannot name a member of a struct (`evidence.project`), so the three links of an
  assessment run have no relation entry.

Rules of `docs/evidence-format.md` § 4 that stay the reader's to check:

- **Rule 3, one result per output, scope, item, boundary and aggregation.** `distinct` takes one
  member as its key and no combination of five.
- **Rule 4, the sum.** `passed` plus `failed` is at most `executed`: a comparison reads one fact
  on each side and a constant, not the sum of two facts
  (`passed + failed <= executed` is refused). The two single comparisons are declared.
- **Rule 4, the entries.** Where `not_executed` is present it holds one entry per unit of
  `skipped`, `not_run` and `unsupported`: the rule counts the entries of a list by a member's
  value and compares the count with a field. That a unit is counted once and has the same id in
  every run is a statement about the assessor's work, not about one document.
- **Rule 8, a result for every scope item.** The scope items come from the inputs of the run,
  which the document does not hold.
- **Rule 9, no absolute path.** The paths are text; no invariant reads the form of a text.
- **A result against its declaration.** Output, scope, unit, boundary, identity key and item
  fields of a result against the assessor's declaration, and `identity` against `key`: each
  joins a run and an assessor.
- **The exit status of an assessor.** Which completion the CLI records for which exit is a
  comment on `ratchet.assessor.AssessorExit` and on `assess` in `cli.yaml`: ESS declares no
  map from an enum value to another.

Two limits of the generators shape the declarations:

- **`shorthand:`.** The Rust target of `ess generate synthesize` refuses a struct that declares
  a shorthand. No struct declares one.
- **A struct with invariants in a command payload.** `ess specify cli` refuses it. The coverage
  of a run summary and of a verdict row is therefore `ratchet.cli.CoverageRow`, which has every
  field of `ratchet.evidence.EvidenceCoverage`, the lists `executed_ids` and `not_executed`
  included, and none of its invariants. `spec/cli-coverage-row.test.sh` fails when a field is
  missing.

## Where this specification still departs from docs/design.md

Each point is a proposal for the owner to accept or reject before anything generated from this
specification is committed.

- **No bare spellings in 0.1.0.** A coverage bound is `{min: 18}` or `{max: 0}` and an adoption
  `{from: same_change}`; the design and the examples are written that way since 2026-11-24. The
  bare number and the bare `same_change` were ESS shorthands, which the Rust target refuses
  (above). They can return without breaking a document written in the long form. Two more
  spellings take a key because an ESS shorthand stands only for a required scalar: a tool's
  version is `{version: "0.97.4"}`, and a list of `executed_ids` is `{ids: [...]}`. The design
  and `examples/generated-artifact.ratchet.yaml` write both that way too (design § 12).
- **`adoption` as a struct.** `{from: same_change}`, and the sampled form
  `{from: trusted_revision, runs, aggregation}`, are one struct.
- **A result is one flat struct.** `docs/evidence-format.md` § 8 item 6 asks for the value
  members beside `value_type`. An ESS union writes its payload one level down, so
  `MeasurementResult` holds every value member as an optional field and invariants say which
  belong to which value type.
- **The id of a run** is the identity `run_id` of `AssessmentRun`, because `run` is now a
  member of the document.
- **Three cause lists.** `VerdictCause` repeats the values of `FailCause` and
  `InsufficientEvidenceCause`; ESS has no enum made of two others, so the three lists are kept
  in step by hand.
- **`evidence_missing`.** A requirement with no qualifying run, for the candidate or in an
  operational gate for the window, is insufficient evidence with this cause. The design named
  none for it before 2026-11-24.
- **An input is an entry of a map.** `InputDeclaration` has no `name`: an assessor's and a
  preset's `inputs` are maps by input name, as the declaration `ratchet-assessor/1` writes
  them.
- **Not-applicable entries.** A gate decision keeps one row per entry with `entry_state`
  (`evaluated` or `not_applicable`) and no verdict when not applicable, rather than a separate
  list.
- **Exceptions in a decision.** The decision copies each applied exception (id, reason, owner,
  expiry) into its row; there is no relation from a record to an authored exception.
- **Exit status.** `ess-cli/2` gives a declared error exit 1, so a failed gate and a gate with
  insufficient evidence both exit 1 and the JSON code tells them apart, as the design says.
- **`reference adopt` input.** It takes the same input as `reference propose`, plus
  `--trade-off <id>` on both for the trade-off's id. `render --export <directory>` names where
  the static export goes; the design names no flag for either.
- **Proof ids.** A defect in neither `refused` nor `accepted` returned insufficient evidence.
- **The `reference` command group** has an empty help line, a property of the binding.
- **`local` absent means not local.** The design lists "whether it is local" beside "whether it
  is required"; `local` is optional here so that a preset's inputs, never local, need not say so.
- **Names the design does not give.** The validation codes added for revision 4 (`unit_missing`,
  `unit_not_declared`, `population_field_mismatch`, `time_window_incomplete`,
  `window_on_other_kind`, `plan_does_not_fit_gate_kind`, `when_in_operational_gate`,
  `local_input_in_specification`, `preset_input_local`), the refusal
  `operational_gate_takes_no_candidate` of `ratchet evaluate`, the refusal
  `requirement_without_reference` of `ratchet reference propose` and `ratchet reference adopt`
  (the requirement holds a `condition` and no `reference`), the error `candidate_unresolved`
  of `ratchet assess` (the candidate of a plan cannot be resolved, and no run is recorded for
  that plan), the doctor check `local_inputs`,
  the assessor's `population_fields`, the run's `local_inputs`, and the type names
  `Evidence`, `RunDetails`, `ResolvedInput`, `NotExecutedUnit`, `Incomplete`, `IdentityItem`,
  `ReservedArgument`, `AssessorExit` and `CoverageRow`.
- **A catalog source without `git`** is a directory relative to the root, and an assessor
  declaration is the file `<name>@<version>.assessor.yaml` in a source.
- **The local record directory** is `.ratchet/records` under the root without a `[records]`
  section or with a `store` that names no path; `store` is optional.
- **`ratchet evaluate` without `--trusted`** reads the policy at the merge base of `HEAD` and
  `origin/main`.
- **A run without a candidate.** `candidate` is optional on an assessment run: a run of a
  time-window plan without `selection` is attributable to no candidate. The design's record
  table still lists "candidate identity" for every run.
- **`last` is at least 1.** The design gives `last` no lower bound; `{last: 1}` is its smallest
  example.
- **Population filter values** are text (`{service: portal, region: eu}`); the design shows no
  other value.

`ess generate cli` accepts `cli.yaml` and writes a Cargo package `ratchet-cli-contract` with a
`ratchet` binary into the ignored `target/ess-scratch/cli`.
