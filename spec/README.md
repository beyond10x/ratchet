# Ratchet executable specification

Design phase. This directory declares Ratchet's domain in ESS before any code exists
(`AGENTS.md` § Specification first). It follows `docs/design.md` revision 4. Every entity,
field, enum value, command and flag here is a proposal taken from the design; none of them is
settled. Each `UNMAPPED:` comment marks a question the design does not answer yet.

| File | Declares |
|---|---|
| `domains/specification.yaml` | what a `ratchet/1` document holds: quality specification, quality statement, subject, audience, assessment plan with its map of measurements (kind, value type, scope, unit, boundary, `better`, `filter`), target with `selection`, observation plan (scenarios, `paired`, `window` as `{length, last}`, `population` as `{runs_of, from}` or `{filter}`, `min_samples`, conditions per target class, coverage bounds), quality requirement (`meaning`, `serves`, condition, reference with `paths`, tolerance and `adoption`, planted defects), gate (kind, `evidence`) and gate entry (mode, `since`, `when`), exception keyed by its id, input declarations with `local`, preset and preset binding |
| `domains/assessor.yaml` | assessor, its typed configuration inputs, its coverage unit and coverage counts, its population fields, and the outputs it declares (value type, kind, scopes, unit or none, boundaries, identity key, item fields); the built-in `record-series@1` |
| `domains/evidence.yaml` | assessment run record: resolved target with window bounds, observed conditions (host load as mean, min and max; tools), evidence coverage with its unit, results per measurement, queue wait and run time, resolved local inputs, window items (items, newest item, runs left out), import source; proof record with the defect ids refused and accepted |
| `domains/reference.yaml` | reference record (generated or accepted value; `values`, or `items` as `{identity, reason, owner}`), reference change, trade-off with `gains` and `loosens` |
| `domains/gate.yaml` | gate decision (a candidate, or for an operational gate none) and each entry's result: evaluated or not applicable; pass, fail or insufficient evidence, with its cause, its next step (`candidate`, `assessment`, `system`) and in an operational gate its window |
| `domains/config.yaml` | the local config `ratchet.toml` with `[inputs.<assessment>]`, and the record store it names |
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

`task check:spec` runs `ess specify validate --path spec --strict-requires` and
`ess specify cli --path spec --binding spec/cli.yaml --strict-requires`; `task check` calls it.
Nothing generated is committed yet. When implementation starts, the parser and process adapter
come from `ess generate cli` and are drift-checked in the gate.

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
- a run with window items has window bounds.

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

## Where this specification still departs from docs/design.md

Each point is a proposal for the owner to accept or reject before anything generated from this
specification is committed.

- **Bare spellings without a scalar.** An ESS shorthand stands only for a required scalar, so
  two design spellings take a key here: a tool's bare version (`ess: "0.97.4"`) is
  `{version: "0.97.4"}`, and a bare list of `executed_ids` is `{ids: [...]}`. The bare number
  of a coverage bound and the bare `same_change` of `adoption` are shorthands and keep the
  design's spelling.
- **`adoption` as a struct.** `same_change` is `{from: same_change}` and the sampled form is
  `{from: trusted_revision, runs, aggregation}`, one struct with `from` as its shorthand.
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
  `operational_gate_takes_no_candidate` of `ratchet evaluate`, the doctor check `local_inputs`,
  the assessor's `population_fields`, and the run's `window_items` and `local_inputs`.
- **A run without a candidate.** `candidate` is optional on an assessment run: a run of a
  time-window plan without `selection` is attributable to no candidate. The design's record
  table still lists "candidate identity" for every run.
- **`last` is at least 1.** The design gives `last` no lower bound; `{last: 1}` is its smallest
  example.
- **Population filter values** are text (`{service: portal, region: eu}`); the design shows no
  other value.

`ess generate cli` accepts `cli.yaml` and writes a Cargo package `ratchet-cli-contract` with a
`ratchet` binary into the ignored `target/ess-scratch/cli`.
