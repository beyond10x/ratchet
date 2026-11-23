# ratchet

Specify software quality, then keep it from going backwards.

Ratchet defines a versioned YAML format for declaring what quality means for a project, how to
assess it, and what evidence a candidate must produce before it can advance. A requirement such as
"search p95 below 100 ms" or "no new analyzer findings" is bound to an assessor, a target and a
gate. A gate returns **pass**, **fail** or **insufficient evidence**; only a pass clears it. When a
candidate is measurably better, the protected reference can be tightened, so a tolerance cannot
accumulate across merges.

```yaml
format: ratchet/1
project: partner-portal

requirements:
  search-latency-budget:
    assessment: search-request-latency
    condition: {operator: lt, value: 100, unit: ms}

gates:
  promote:
    stage: pre-promotion
    requires: [search-latency-budget]
```

## Status

Design phase. Nothing is implemented; field names and commands are proposals.

- [vision.md](vision.md): what Ratchet is for
- [docs/design.md](docs/design.md): the design proposal

## What it will ship

- **Specification**: YAML document shapes, typed comparisons, evidence and gate semantics, and a
  machine-readable schema for authoring.
- **CLI**: `ratchet init`, `validate`, `assess`, `evaluate --gate <name>`, `reference propose`.
- **Preset catalog**: reusable YAML for web, backend, code quality, build and CI concerns.
- **Assessors**: adapters that run a tool or import its report as structured evidence.
- **Agent integration**: a skill that uses the same specification and CLI as CI.

## License

Apache-2.0, see [LICENSE](LICENSE).
