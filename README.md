# ratchet

Specify software quality, then keep it from going backwards.

Documentation: https://beyond10x.github.io/ratchet/

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

Implementation started on 2026-11-24. Nothing is released yet; field names and commands are
proposals until a release ships them. [ROADMAP.md](ROADMAP.md) has the first consumer, the waves
and what 0.1.0 holds.

- [vision.md](vision.md): what Ratchet is for
- [docs/design.md](docs/design.md): the design proposal, revised from survey 1
- [research/synthesis.md](research/synthesis.md): what 26 projects said about tracking quality

## What it will ship

- **Specification**: YAML document shapes, typed comparisons, evidence and gate semantics, and a
  machine-readable schema for authoring.
- **CLI**: `ratchet init`, `validate`, `assess`, `evaluate --gate <name>`, `reference propose`.
- **Preset catalog**: reusable YAML for web, backend, code quality, build and CI concerns.
- **Assessors**: adapters that run a tool or import its report as structured evidence.
- **Agent integration**: a skill that uses the same specification and CLI as CI.

## License

Apache-2.0, see [LICENSE](LICENSE).
