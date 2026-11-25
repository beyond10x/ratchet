---
format: aep.planning-md/3
id: review-result:design-catalog-round-2
kind: review-result
status: active
title: design critic on the preset catalog drafts, round 2
relations:
- reviews: epic:preset-catalog
revision: 1
---
Recorded by the coordinator from the critic's report on `epic:preset-catalog` and its four draft stories, verbatim except that absolute paths of the workstation are replaced by `<tree>` and `<scratch>`.

approve

Round 1 findings, each re-read in the revised drafts (`aep plan artifact show`, `aep plan artifact graph`):

- D1 (page-row rule owned by two stories): closed. The rule is in story:preset-catalog-functional alone (Scope, `spec/presets.test.sh` bullet 4: one row per measurement, four non-empty cells, a row naming no measurement fails; Acceptance last line counts `<r> of <r> measurement(s) with a row` and the broken copies). Runtime and factory say `presets/README.md` and `spec/presets.test.sh` are not edited, and their acceptance reads the script's count line.
- D2 (body of a preset undeclared): closed. Functional Scope bullet 1 declares the body (statements, assessments, requirements by the project's types, no gate, exception or binding) in `spec/domains/specification.yaml` before a file uses it, and Notes keep "specification first" with `ess specify validate --strict-requires`.
- D3 (classifier and page check split): closed. Functional Scope `pages.yml` bullet makes every file under `presets/`, pages included, a change for which `gate` runs `task check:spec`, with three `task check:ci-paths` cases, both sides covered. The decision is in the story that owns the page check.
- D4 (two presets undefined): closed. Functional Acceptance names `conformance-cases@1` and `differential-equality@1`; story:preset-binding-resolution Acceptance binds exactly those two, and it depends on functional.
- D5 (trade-off, shared CHANGELOG.md): now the chain you describe. Each ordering edge has its reason written beside it (runtime-to-functional by files; factory-to-runtime and binding-to-factory by `CHANGELOG.md`, stated in each Notes and in the epic "Order"), so it is the trade-off in the rubric, not a defect. The alternative to the order is splitting the shared surface (separate changelog lines per story); the drafter chose the order and the cost is that the three can only be worked one after another.

New checks on the revised set:
- Cycles: none. I walked the edges of the four stories and the ones they reach (changelog-release-procedure, workspace-cli-contract, release-0-1-0, acceptance-in-gate, cli-skeleton-validate, record-formats-in-spec): about 25 edges, outside the set included. The graph is acyclic. `aep plan artifact validate` reports `valid` (it also notes review-result:design-catalog-round-1 has prose findings only; that is not mine).
- Acceptance reads traced to a producer: 9 in the set (runtime 2, factory 2, binding 3, functional script and its own files 2), all recorded by an edge, directly or through the chain. The binding story's read of `validate` is recorded by its edge to story:release-0-1-0.
- Fit with docs/design.md § 4 and the specification: the file name of a preset sits beside the assessor file name already in `spec/domains/config.yaml:38`; the body reuses the project's types; no sampled default is added to the format; no accepted story to 0.1.0 is edited in its scope (functional depends on story:changelog-release-procedure for `CHANGELOG.md`; binding resolution sits behind story:release-0-1-0).

Not findings, for the owners of those lanes:
- Scope or parallel-safety: functional's scope names `crates/ratchet-cli-contract` only, but the epic's "Order" says whichever of functional and story:cli-skeleton-validate lands second runs `task generate` for the model crate its domains feed. Functional does not name that crate, and it adds fields to `Preset`. One line in functional's scope would close it.
- Weak reason in story:preset-binding-resolution Notes: it says it edits `presets/README.md` "inside the directory" factory adds to, but factory does not edit the README; the `CHANGELOG.md` reason still holds the edge.
