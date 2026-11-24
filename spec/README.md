# Ratchet executable specification

Design phase. This directory declares Ratchet's domain in ESS before any code exists
(`AGENTS.md` § Specification first). It follows `docs/design.md` revision 3. Every entity,
field, enum value, command and flag here is a proposal taken from the design; none of them is
settled. Each `UNMAPPED:` comment marks a question the design does not answer yet.

| File | Declares |
|---|---|
| `domains/specification.yaml` | what a `ratchet/1` document holds: quality specification, quality statement, subject, audience, assessment plan with its map of measurements (kind, value type, scope, boundary, `better`, `filter`), target with `selection`, observation plan (scenarios, `paired`, `window`, `population`, conditions per target class, coverage bounds), quality requirement (`meaning`, `serves`, condition, reference with `paths`, tolerance and `adoption`, planted defects), gate (kind, `evidence`) and gate entry (mode, `since`, `when`), exception keyed by its id, preset and preset binding |
| `domains/assessor.yaml` | assessor, its typed configuration inputs and the outputs it declares (value type, kind, scopes, unit, boundaries, identity key, item fields, coverage counts) |
| `domains/evidence.yaml` | assessment run record: resolved target, observed conditions (host load as mean, min and max; tools), evidence coverage, results per measurement, queue wait and run time, import source; proof record with the defect ids refused and accepted |
| `domains/reference.yaml` | reference record (generated or accepted value; values or accepted items with reason and owner), reference change, trade-off with `gains` and `loosens` |
| `domains/gate.yaml` | gate decision and each entry's result: evaluated or not applicable; pass, fail or insufficient evidence, with its cause and next step |
| `domains/config.yaml` | the local config `ratchet.toml` and the record store it names |
| `domains/cli.yaml` | the typed inputs, results and refusals of the `ratchet` commands |
| `cli.yaml` | the `ess-cli/2` presentation binding of the `ratchet` command surface |

The entities a project authors, the assessors, presets, the local config and the record store
are `provided: true`: they come from a file, and no Ratchet command creates them. Records hold
one state, `Recorded` (a reference, `Adopted`): this specification declares no ESS command that
writes a record yet, and current or superseded, active or expired are computed, not stored.

The owner decided the four open questions of design § 9 on 2026-11-24, all A: reference and
trade-off records are files in the tree (D1), a loosening lands in a change of its own merged
before the candidate (D2), `evidence` defaults to `any` (D3), an exception ends at a date only
(D4). The specification is written to those answers; `docs/design.md` § 9 still lists them as
open.

```console
task check:spec
ess generate cli --path spec --binding spec/cli.yaml --out <directory>
```

`task check:spec` runs `ess specify validate --path spec --strict-requires` and
`ess specify cli --path spec --binding spec/cli.yaml --strict-requires`; `task check` calls it.
Nothing generated is committed yet. When implementation starts, the parser and process adapter
come from `ess generate cli` and are drift-checked in the gate.

## Resolved in design revision 3

Revision 3 took every point the previous list raised (design § 10): the exit status, typed rows
with decimals as text, the CLI spelling, the trade-off as a record of its own, the YAML shapes,
gate entries as `<gate>/<requirement>`, coverage bounds, computed exception expiry, exceptions
as entries of the specification, "skipped locally" as a state, `not_assessable_here`, and a
shape for preset, quality statement, `ratchet.toml` and the record store.

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

`ess generate cli` accepts `cli.yaml` and writes a Cargo package `ratchet-cli-contract` with a
`ratchet` binary into the ignored `target/ess-scratch/cli`.
