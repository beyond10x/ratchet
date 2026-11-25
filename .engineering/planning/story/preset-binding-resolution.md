---
format: aep.planning-md/3
id: story:preset-binding-resolution
kind: story
status: active
title: ratchet validate resolves a preset binding
summary: 'A binding of a catalog preset from a path source: bound requirements join the project, digest and inputs are checked.'
relations:
- decomposes: epic:preset-catalog
- depends_on: story:preset-catalog-functional
- depends_on: story:release-0-1-0
- depends_on: story:preset-catalog-factory
scope:
- confidence: cited
  path: CHANGELOG.md
- confidence: inferred
  path: crates/ratchet-core
- confidence: cited
  path: crates/ratchet/src/commands/validate.rs
- confidence: cited
  path: crates/ratchet/tests/fixtures/validate
- confidence: cited
  path: crates/ratchet/tests/validate.rs
- confidence: cited
  path: docs/design.md
- confidence: cited
  path: examples/README.md
- confidence: cited
  path: examples/preset-binding
- confidence: cited
  path: presets/README.md
revision: 15
transitions:
- {from: "draft", to: "proposed", at: "2026-11-25T01:07:33Z", actor: "agent:ratchet", revision: 14}
- {from: "proposed", to: "active", at: "2026-11-25T01:09:50Z", actor: "agent:ratchet", revision: 15}
---
## Context

A project binds a preset under `presets:` with `use`, `digest` and `with`
(`docs/design.md` § 4; `ratchet.specification.PresetBinding`,
`spec/domains/specification.yaml:1133`). The validation codes `preset_digest_mismatch`,
`preset_input_invalid`, `preset_input_local` and `unresolved_reference` are declared
(`spec/domains/cli.yaml:132-156`). `ratchet validate` of 0.1.0 is built by
`story:cli-skeleton-validate` on specifications without bindings, and no case of its tests
holds one; until this story a consumer of the catalog reads the preset file itself.

## Acceptance

`ratchet validate` on `examples/preset-binding/`, a specification that binds
`conformance-cases@1` and `differential-equality@1` from a path source and lists two bound
requirements in a gate, exits 0 and reports each bound requirement as
`<binding>.<requirement>`; before the story the case `binding_resolves` of
`crates/ratchet/tests/validate.rs` fails on that directory, because no bound requirement is
reported.

## Scope

- `crates/ratchet/src/commands/validate.rs`, `crates/ratchet/tests/validate.rs`,
  `crates/ratchet/tests/fixtures/validate/`: the resolution and its cases. Beside
  `binding_resolves`, one case per refusal, each exit 1 with the code named:
  - the digest of the binding is not that of the file found: `preset_digest_mismatch`;
  - `with` passes a name the preset does not declare, a value of another type, or leaves a
    required input out: `preset_input_invalid`, three cases;
  - no source holds the preset: `unresolved_reference`, naming the binding;
  - the source is a `git` source: a refusal whose message says a `git` source is not resolved
    yet.
- `crates/ratchet-core/` (inferred): the reader of a specification and the resolution of a
  catalog source live there after `story:cli-skeleton-validate` and
  `story:assessor-declaration`; the binding is resolved beside them.
- `examples/preset-binding/` (new): the specification and its `ratchet.toml` with a path
  source; `examples/README.md` loses the sentence that no example uses a binding.
- `presets/README.md`: what `ratchet validate` prints for a binding.
- `docs/design.md` § 4: the sentence "no example has tested it" goes.
- `CHANGELOG.md`: lines under `## [Unreleased]`.

## Notes

- Only a path source is resolved. A `git` source needs a fetch at a commit and gets a story of
  its own when a consumer needs it (`epic:preset-catalog` § "Stories").
- The digest is the SHA-256 of the bytes of the preset file, as the binding says.
- Every example is generic: no name of a consumer, a product or a customer.
- The edge to `story:preset-catalog-factory` records an order, not a need: both edit
  `CHANGELOG.md`, and this story edits `presets/README.md` inside the directory that story
  adds files to.
- No test calls the network. The test step ends within 120 s, no test over 60 s.
- The crate that holds the model of a `ratchet/1` document is decided before
  `story:cli-skeleton-validate`; this story uses what that story built.
