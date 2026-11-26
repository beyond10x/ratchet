# Ratchet executable specification

This directory declares Ratchet's domain in ESS before any code exists (`AGENTS.md`
§ Specification first). It follows `docs/design.md` revision 4 and the two record formats of
`docs/evidence-format.md`: the assessment run `ratchet-evidence/1` and the assessor declaration
`ratchet-assessor/1`. Every entity, field, enum value, command and flag here is a proposal taken
from those documents; each can still change before the first release. Each `UNMAPPED:` comment
marks a question the design does not answer yet.

| File | Declares |
|---|---|
| `domains/specification.yaml` | what a `ratchet/1` document holds: quality specification, quality statement, subject, audience, assessment plan with its map of measurements (kind, value type, scope, unit, boundary, `better`, `filter`), target with `selection`, observation plan (scenarios, `paired`, `window` as `{length, last}`, `population` as `{runs_of, from}` or `{filter}`, `min_samples`, conditions per target class, coverage bounds), quality requirement (`meaning`, `serves`, condition, reference with `paths`, tolerance and `adoption`, planted defects), gate (kind, `evidence`) and gate entry (mode, `since`, `when`), exception keyed by its id, input declarations with `local`, preset (its block, the three maps it holds, the reference to an input) and preset binding |
| `domains/assessor.yaml` | the assessor declaration `ratchet-assessor/1`: `format`, name and version, `command`, `targets` and `target_input`, the typed `inputs` by name, the declared conditions, the coverage unit and coverage counts, the `outputs` by name (value type, kind, scopes, unit or none, boundaries, identity key, item fields and the closed list of values of an item field), the population fields; the reserved arguments of the invocation and what an exit status means; the built-in `record-series@1` |
| `domains/evidence.yaml` | the assessment run `ratchet-evidence/1` in two parts. `evidence`: project, assessment, assessor, candidate, resolved target with the window (bounds, items, newest item, runs left out), resolved inputs, completion, observed conditions (host load as mean, min and max; tools), coverage with its unit and the units not executed, the list of results (complete or incomplete, the value members beside `value_type`), import source. `run`: start and end, queue wait and run time, resolved local inputs, artifacts. Proof record with the defect ids refused and accepted |
| `domains/reference.yaml` | reference record (generated or accepted value; `values`, or `items` as `{identity, reason, owner}`), reference change, trade-off with `gains` and `loosens` |
| `domains/gate.yaml` | gate decision (a candidate, or for an operational gate none) and each entry's result: evaluated or not applicable; pass, fail or insufficient evidence, with its cause from the list of its verdict (`FailCause`, `InsufficientEvidenceCause`), its next step (`candidate`, `assessment`, `system`) and in an operational gate its window |
| `domains/config.yaml` | the local config `ratchet.toml` with `[inputs.<assessment>]`, a catalog source as a git repository or a directory of the checkout, the two kinds of file a source holds (`<name>@<version>.preset.yaml`, `<name>@<version>.assessor.yaml`), the record store it names and the local record directory |
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
runs twelve steps, and `task check` calls it:

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
6. `sh spec/contract-examples.test.sh`, which reads the two YAML examples of
   `docs/evidence-format.md` § 10 and fails when a key is no declared field of the type it
   stands in. Its last line is
   `contract-examples: <k> of <k> keys of <n> example(s) are declared fields`;
7. `sh spec/cli-coverage-row.test.sh`, which fails when a field of
   `ratchet.evidence.EvidenceCoverage` is missing from `ratchet.cli.CoverageRow` or has another
   type there, or when `RunSummary.coverage` or `VerdictRow.coverage` is not that row. Its last
   line is `cli-coverage-row: <n> of <n> coverage fields reported with their type, in 2 of 2 places`;
8. `sh spec/cli-errors.test.sh`, which fails when an error or refusal that the command table of
   `docs/design.md` § 5 names for a command is not in `errors:` of that command in `cli.yaml`.
   Its last line is `cli-errors: <n> of <n> named errors declared on their command`;
9. `sh spec/gate-inputs.test.sh`, which copies `spec/` and the two documents into the ignored
   `target/gate-inputs/`, hides one defect per copy behind a change of form, and fails when
   the six scripts above accept a copy, or when `spec/record-examples.test.sh` does not refuse
   with its digest message a copy whose `evidence` of § 6 example 1 has one byte changed. Its
   last line is
   `gate-inputs: <n> of <n> broken inputs refused`;
10. `sh spec/presets.test.sh`, which reads every file of the preset catalog `presets/`: a file
    is UTF-8 without a NUL byte, a control character and a character that ends a line for a
    YAML 1.1 reader or hides or reorders text (the list is in `presets/README.md`), and its
    last line ends with a line feed; a preset and an assessor declaration
    hold only declared keys and values of the declared types, and no text that is empty; a
    preset holds no gate, no exception, no local input and no reference to an input it does not
    declare, and a requirement writes out the names of its assessment, its measurement and its
    statements; an assessment passes the inputs its assessor requires, with the declared types,
    also for each item of a list, and names a target kind the assessor takes; a measurement
    names an output, its kind, a unit, a scope, a boundary, an identity key and filter fields
    that the declaration of its assessor declares, and a plan a condition and a population
    field that it declares; the cache condition is `cache_profile` and never `cache`, in a plan
    and in a declaration, an input of a declaration has no reserved name such as `out`, a key
    of `item_values` is a field of `item_fields` of its output and a value of a `filter` one
    the output lists there, an exact measurement aggregates with `sum` or not at all, and a
    sampled measurement of a plan whose `runs` is a literal above 1 states an `aggregation` or
    `over_all_runs: true` and never both; a plan over `runs_of` names `record-series@1`, which
    no file declares, and has no target selection and no conditions; a requirement compares
    its measurement as the table "Comparisons" of design § 3 allows for the value type of the
    output, the pass rate of an assertion as a number; the plan of a sampled measurement
    declares a condition, unless it is a plan over `runs_of`, and a requirement that compares a
    sampled measurement with an accepted value has a tolerance and an adoption; and every
    measurement has one row with four filled cells on a page of the catalog. It then writes one
    defect per rule into copies of a fixed set of files of `presets/`, in the ignored
    `target/presets/`, and fails when a defect is accepted or is refused without the message of
    its rule, or when the unchanged set, checked again through `--catalog` and `--spec`, prints
    another last line. The set is `README.md` and the functional family, named once in the
    script (`set_files`): the whole of `presets/` is checked once, and a copy holds no file of
    another family, so a family that the catalog gets adds nothing to a copy. Defects that
    stand apart share a copy, each on a line of its own, and each is judged by a message that
    names its own line, path or value: the check of a copy takes most of the time of the
    script. It prints
    `presets: <d> of <d> defect(s) refused with the message of their rule`, and its last line is
    `presets: <f> of <f> file(s) valid, <r> of <r> measurement(s) with a row, <c> of <c> broken copies refused`;
11. `sh spec/example-declarations.test.sh`, which reads every file `examples/*.ratchet.yaml`
    and, for each assessor a plan names but the built-in `record-series@1`, its declaration
    `<name>@<version>.assessor.yaml` in `examples/quality/assessors/` or, when that directory
    holds none, in `presets/`: the two catalog sources of `examples/ratchet.toml`. It fails on
    an assessor without a declaration file, on a measurement that names an output its assessor
    does not declare, on a unit the output does not declare (`unit_missing`, `unit_mismatch`,
    `unit_not_declared`), on a scope other than `run` that the output does not list, on a
    measurement of a plan over `runs_of` that does not keep the unit or the scope of the
    measurement of its source plan that it names as `output`, on a directory without an
    example, and on a binding under `presets:` whose `use:` names no file of `presets/` or
    whose `digest` is not the SHA-256 that `sha256sum` gives over that file. It states no number of examples, and it does not check a declaration's own keys
    and types: `presets.test.sh` does that for `presets/` alone. It then writes one defect per
    rule into copies of a fixed set of three examples and the four declarations they name, in
    the ignored `target/example-declarations/`, and fails when a copy is accepted or is refused
    without the message of its rule. The line of its check is
    `example-declarations: <e> example file(s), <d> declaration(s) read, <m> of <m> measurement(s) as declared`,
    and its last line is `example-declarations: <c> of <c> broken copies refused`;
12. `ess generate synthesize --path spec --target rust --layout crate` into the ignored
    `target/check-spec/`, which fails when the Rust target refuses a declaration. Its line
    `<n> capabilities: <n> generated, 0 obligation(s), 0 refused` is printed.

Each script states how much it reads and fails on another number, so that a section, a table
or an example which an edit moves out of the form the script looks for is not skipped: 78 field
rows in 13 tables of § 3 and 20 in 2 tables of § 10 (`record-fields`, `record-types`, a number
per table), 5 examples in § 6 (`record-examples`), 2 examples in § 10 (`contract-examples`), 2
places that report coverage (`cli-coverage-row`), and 3 named errors (`cli-errors`). A row, a
table or an example that is added or removed needs the new number in the script.
`presets.test.sh` states no number of the catalog, because the catalog grows by a family at a
time. The one line of counts it states, in the case `file-last-line-of-one-file-alone`, counts
the files and the measurements of the set of its copies, which a new family does not change.
It fails
on a directory without a preset, on a preset without a requirement, on an entry that is no file
of the catalog, on a page without a table of rows, when `presets/` lacks a file of the set,
when a case edits a file that its copy does not hold, and when the edit of one of its copies
changes nothing. Before the copies it runs the cases of its own harness: an edit that
changes nothing stops the run, and so does an edit of a file that the copy does not hold; the
unchanged set is accepted; `--spec` names the
specification that is read; the run in a tree whose `presets/` is refused exits 1, and so does
the run in a tree whose `presets/` lacks a file of the set; a refusal
counts only with the message of the rule of its case, also for a case that shares its copy
with a case that is refused rightly; and an accepted copy gives exit 1. Its
header lists what it does not check, each with the reason: the invariants of the types beside
the four of a plan over `runs_of`, a value that an input gives where a rule reads the value
(only the kind of a target is read from the default of its input), a measurement of a plan of
`record-series@1` against the measurement of the source plan, the plan that `runs_of` names,
the class a condition is declared for, the value of a `Json` other than a passed input and a
default, the values of a `filter`, the prose of the four cells, whether an input is referred
to, and a fence, a code span and a comment inside a list item, a block quote or an indented
block of a page.

The parser and process adapter come from `ess generate cli` and are committed as
`crates/ratchet-cli-contract/`: `task check:generated` compares the crate with a fresh
generation, and `task generate` rewrites it (`AGENTS.md` § "Generated crates"). The crate from
`ess generate synthesize` is not committed yet. It holds the types, a `broken_constraint` check
on each type with invariants, the lifecycles of the entities, and the JSON helpers of
`json.rs`. It holds nothing that reads a file into the types: what does is settled by the
story that adds the model crate. It is drift-checked in the gate once it is in the tree.

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

Rules of `docs/evidence-format.md` § 3, § 4 and § 10 that stay the reader's to check; § 8 of
that document lists the same rules:

- **§ 3, a window exactly for a time-window plan.** `evidence.target.window` is present exactly
  on a run of a time-window plan. The kind of the observation is in the plan, and
  `ratchet.evidence.ResolvedTarget` does not hold it: the rule joins a run and its plan.
- **§ 3, `identity` against `key`.** Each `items[].identity` of an identity set holds exactly
  the fields that the `key` of the same result names. Both are members of one result, but
  `identity` is a `Json`, and an invariant selects no member of one (`defined(i.identity.rule)`
  is refused: "cannot select `rule` from `Json`").
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
- **§ 10, a result against its declaration.** Output, kind, scope, value type, unit, boundary,
  identity key and item fields of a result against the assessor's declaration: each joins a
  run and an assessor.
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
  missing or has another type, or when one of the two places does not use the row.

## How a `ratchet/1` file differs from the declared entities

A `ratchet/1` file is not the entities of `domains/specification.yaml` written out. What reads
the file applies the rules below and infers no other. Each row names the line of
`docs/design.md` that states the rule; where no sentence states it, the line is that of the
illustrative YAML of § 3 which shows it, marked "YAML". Three rules were taken on 2026-11-24
and one on 2026-11-26, and they are stated in § 12 of the design alone; their row names that
section. The example member is
from `examples/`, or from the design where no example file uses the form.

| Rule | `docs/design.md` | Example member |
| --- | --- | --- |
| **The root.** A file holds `format`, `project`, and one map per kind of entity: `statements`, `subjects`, `assessments`, `requirements`, `gates`, `exceptions` and `presets`. `project` is the identity of the `QualitySpecification` and `format` its field. The maps are no field of it. | 690; YAML 218, 219 | `format: ratchet/1` (`examples/analyzer-findings.ratchet.yaml:1`) |
| **An entity is an entry of the map of its kind, and its identity is the key.** `statements.<statement>` is a `QualityStatement`, `subjects.<subject>` a `Subject`, `assessments.<assessment>` an `AssessmentPlan`, `requirements.<requirement>` a `QualityRequirement`, `gates.<gate>` a `Gate`, `exceptions.<exception>` an `Exception`, and `presets.<binding>` a `PresetBinding`. The identity is not a member of the entry. | YAML 222, 227, 241, 340, 377, 398, 510 | `subjects.source-tree` (`examples/analyzer-findings.ratchet.yaml:5`) |
| **`project` is written once.** Every one of these entities declares the field `project`. The file states it at the root, and no entry repeats it. | 690; YAML 219 | `project: workflow-driver` (`examples/analyzer-findings.ratchet.yaml:2`) |
| **Several files form one specification.** The files of `[spec] paths` declare one `format` and one `project`, and an id is unique across them. | 690 | `paths = ["ratchet.yaml", "quality/*.ratchet.yaml"]` (design, line 658; each example is one file) |
| **A gate holds its entries.** `requires` is a list under the gate, and `Gate` declares no such field: each element is a `GateRequirement`. Its `gate` is the gate that holds the list, and its identity is `<gate>/<requirement>`. | 603; YAML 380 | `gates.merge.requires` (`examples/analyzer-findings.ratchet.yaml:97`) |
| **A bare requirement name is an entry.** It stands for `{requirement: <name>, mode: enforce}`. | 603 | `- no-lint-findings` (`examples/analyzer-findings.ratchet.yaml:98`) |
| **An entry written as a map may leave `mode` out.** It then means `enforce`; `GateRequirement.mode` is required in the entity. | 603; YAML 385 | `{requirement: scenario-files-current, when: {changed: [...]}}` (`examples/generated-artifact.ratchet.yaml:52`) |
| **A decimal is written as a YAML number.** `condition.value`, `tolerance.percent`, `tolerance.absolute` and `host_load_per_cpu.max` are `Decimal`, which the record formats write as text. | YAML 344, 297 | `condition: {operator: lte, value: 0}` (`examples/analyzer-findings.ratchet.yaml:79`) |
| **A number is the decimal of its text as written.** `max: 2.125` is `2.125`; the number never passes through a binary float. A scalar in exponent form or with a sign `+` is refused. A quoted decimal text is accepted and means the same. | § 12 | `max: 2.125` (`examples/host-caused-limit.ratchet.yaml:21`) |
| **A requirement may leave `serves` out.** An absent `serves` is the empty list; `QualityRequirement.serves` is a required list in the entity. | § 12 | `requirements.no-lint-findings` (`examples/analyzer-findings.ratchet.yaml:77`) |
| **A date is the text of its scalar.** A `ratchet/1` file is read by the YAML 1.2 core schema, which has no date type. `since`, `created` and `expires` are the text of the scalar, quoted or plain. | § 12 | `expires: 2026-11-30` (`examples/analyzer-findings.ratchet.yaml:113`) |
| **A comment carries nothing.** A `ratchet/1` file may hold YAML comments, and a reader of the format skips them: no rule, value or entity is read from a comment. A preset is bound by the digest of its bytes, so a comment changes that digest, and the catalog `presets/` writes none (`presets/README.md`). What the scripts of the gate skip or refuse of a comment is their own reading, not the format. | § 12 | `# Checks 1 to 5 and 7 bind presets of presets/; ...` (`examples/production-gate.ratchet.yaml:12`) |
| **A preset is a file of its own.** It is a `ratchet/1` document with a `preset` block in place of `project`, named `<name>@<version>.preset.yaml` in a catalog source (`ratchet.config.CatalogFileKind`). Its entries refer to an input as `${inputs.<name>}` and join the project under the name of the binding, as `ux.steps-do-not-rise`. | § 4, "Presets"; § 5, "Local config" | `presets/conformance-cases@1.preset.yaml`; `presets.served-operations.use: conformance-cases@1` (`examples/production-gate.ratchet.yaml:16`) |
| **A preset holds three of the seven maps.** Beside `format` and `preset` its root holds `statements`, `assessments` and `requirements` (`ratchet.specification.PresetMember`), each a map of the entity that the relation of that name of `QualitySpecification` targets. An entry states no `project`. `subjects`, `gates`, `exceptions` and `presets` are refused. | § 4, "Presets" | `assessments.conformance` (`presets/conformance-cases@1.preset.yaml`) |
| **A reference to an input is the whole of a value.** `${inputs.<name>}` stands where a scalar or a list stands, with no text beside it, and the type of the input fits the place (`ratchet.specification.InputReference`). Inside a flow collection it is quoted. No key is a reference, and neither is a name by which a requirement names another entry of its preset: `assessment`, `measurement` and the items of `serves` are written out. `<name>` is the key of the input, which is text and may hold a `.`. The spelling is the only one: a scalar of a preset that holds `${` or `{inputs.` and is not `${inputs.<name>}` alone, such as `${ inputs.report }` and `${{inputs.report}}`, is an error and no text. | § 4, "Presets" | `environments: ${inputs.environments}` (`presets/conformance-cases@1.preset.yaml`) |

The files `examples/*.ratchet.yaml` are in the form above, not in that of the entities. One gate
step reads them, `sh spec/example-declarations.test.sh` (step 11): it reads the assessor of each
plan and the output, the unit and the scope of each measurement against the declarations of
`examples/quality/assessors/` and `presets/`, and no other key and no type. Its reader takes the
forms that the next sentences name for `presets.test.sh`, and also a block list whose items are
scalars or flow collections, as `gates.*.requires` of the examples is written; it skips a line
that holds only a comment.
`sh spec/presets.test.sh` reads the `ratchet/1` files of `presets/` and the
`ratchet-assessor/1` declarations beside them in the same form. It is no YAML reader: it reads
mappings by indentation and one-line flow collections, and fails on a line of another form, on
a comment, on a quote inside a plain scalar, on a quoted key and on a key that YAML reads as a
number, a boolean or null. A list is a flow list, also where the design shows a block list, and
a text with both kinds of quote, a backslash escape or a folded scalar cannot be written
(`presets/README.md`, "How a file is written").

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
- **The kinds of file of a catalog source** are the enum `ratchet.config.CatalogFileKind`
  (`preset`, `assessor`), and the maps of a preset are the enum
  `ratchet.specification.PresetMember`. No field has either as its type: ESS takes no entity as
  the type of a field and gives an entity one owner, so the body of a preset is declared as the
  names of three relations of `QualitySpecification`. `spec/presets.test.sh` reads both lists.
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

`ess generate cli` accepts `cli.yaml` and writes the Cargo package `ratchet-cli-contract`,
committed as `crates/ratchet-cli-contract/`. The workspace builds its library only; the
`ratchet` binary is that of `crates/ratchet/`.
