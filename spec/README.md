# Ratchet executable specification

Design phase. This directory declares Ratchet's domain in ESS before any code exists
(`AGENTS.md` § Specification first). Every entity, field, enum value, command and flag here is a
proposal taken from `docs/design.md` and `docs/product-brainstorm.md`; none of them is settled.
Each `UNMAPPED:` comment marks a question the design does not answer yet.

| File | Declares |
|---|---|
| `domains/specification.yaml` | what a `ratchet/1` document holds: quality specification, subject, audience, assessment plan with its measurement (kind exact or sampled, scope, aggregation), target and observation conditions, quality requirement with its condition, protected reference declaration and ratchet policy, gate and each gate entry's mode (enforce or report), exception (reason, owner, expiry) |
| `domains/assessor.yaml` | assessor and the outputs it declares |
| `domains/evidence.yaml` | assessment run record: resolved target, observed conditions, evidence coverage, identity sets and measured values, queue wait and run time; proof record |
| `domains/reference.yaml` | protected reference (generated or accepted value), reference change, trade-off |
| `domains/gate.yaml` | gate decision and each requirement's verdict: pass, fail or insufficient evidence, with its cause and next step |
| `domains/cli.yaml` | the typed inputs, results and refusals of the `ratchet` commands |
| `cli.yaml` | the `ess-cli/2` presentation binding of the `ratchet` command surface |

The entities a project authors are `provided: true`: they come from the document on the trusted
revision, and no Ratchet command creates them. Records hold one state, `Recorded`: this draft
declares no ESS command that writes a record yet.

```console
ess specify validate --path spec --strict-requires
ess specify cli --path spec --binding spec/cli.yaml --strict-requires
ess generate cli --path spec --binding spec/cli.yaml --out <directory>
```

Nothing generated is committed yet. When implementation starts, the parser and process adapter
come from `ess generate cli` and are drift-checked in the gate.

## Where this specification sharpens or departs from docs/design.md

Each point is a proposal for the owner to accept or reject before anything generated from this
specification is committed.

- **Exit status.** `ess-cli/2` gives a declared error exit 1, so a failed gate and a gate with
  insufficient evidence both exit 1. CI tells them apart by the JSON code (`gate_failed`,
  `insufficient_evidence`).
- **No Json in error data.** The gate report is error data, which `ess-cli/2` refuses as Json.
  Observed and allowed values are typed `ValueRow` and `LimitRow`, decimals as text.
- **CLI spelling.** No valueless or repeated flags: `render --check` becomes `--check true`;
  lists are JSON (`--presets '["web-ux@1"]'`). The `reference` group has an empty help line.
- **Trade-off.** Design § 1 calls it "one reference change", but a § 6 reference change has one
  requirement. Modelled as its own record; each change it loosens names it.
- **YAML shapes.** `environment:` (one class or a list) becomes `environments`, always a list.
  `aggregation: p95` becomes `{kind: percentile, parameter: 95}`. `no-new-items` becomes
  `no_new_items`; `no_lost_items`, `gt`, `gte` and `eq` are added.
- **Gate entries.** Each `requires:` entry is an entity with id `<gate>/<requirement>`; a bare
  requirement name means `enforce`.
- **Coverage bounds.** `{skipped: 0}` is read as a maximum.
- **Exception expiry.** Active or expired is computed from the date at evaluation, not stored.
- **Exceptions.** Authored in the specification YAML (§ 3) and named as records (§ 6); modelled
  as authored entities.
- **Skipped locally** (product brainstorm) is a status flag, not a verdict.
- **"Reported there as not run"** (§ 3) is the insufficient-evidence cause `not_assessable_here`.
- **Not declared yet:** preset, quality statement, `ratchet.toml` and the record store; the
  design gives them no shape.

`ess generate cli` accepts `cli.yaml` and writes a Cargo package `ratchet-cli-contract` with a
`ratchet` binary (10 files) into the ignored `target/ess-scratch/cli`.
