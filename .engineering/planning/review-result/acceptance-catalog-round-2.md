---
format: aep.planning-md/3
id: review-result:acceptance-catalog-round-2
kind: review-result
status: active
title: acceptance critic on the preset catalog drafts, round 2
relations:
- reviews: epic:preset-catalog
revision: 1
---
Recorded by the coordinator from the critic's report on `epic:preset-catalog` and its four draft stories, verbatim except that absolute paths of the workstation are replaced by `<tree>` and `<scratch>`.

approve

Round 2. All 8 round-1 findings are closed.

1. Closed (functional: family and count line undefined). The acceptance at `aep plan artifact show story:preset-catalog-functional` lines 38-43 names the family's files (`conformance-cases@1`, `differential-equality@1`, their declarations, `presets/functional.md`). It also fixes the last line of `spec/presets.test.sh` with three counts and gives the before state (script and `presets/` absent).
2. Closed (runtime: four outcomes joined). The runtime acceptance is now one outcome. The script exits 0 and its last line counts the four families, each with one row on its page. Before the story the four pages are absent and the line holds the functional counts alone (runtime lines 20-24).
3. Closed (runtime: missing-row refusal conditional on a sibling). The row rule is owned by the functional story in Scope lines 63-65: one row per measurement, four non-empty cells, and a row that names no measurement fails. Runtime Scope (lines 28-30) says the script is not edited.
4. Closed (runtime: page content not checkable). The four-cell rule above makes it a script check, and `<r> of <r> measurement(s) with a row` is in the last line (functional line 41).
5. Closed (factory: page-content clause with no check). The factory acceptance (lines 21-24) is one outcome, reads the same counts, and its before state is "the counts of the five families before it". Five is functional plus the four runtime families, which matches the new edge to `story:preset-catalog-runtime` (line 10).
6. Closed (binding: several outcomes in one sentence). The binding acceptance (lines 33-38) is one outcome, `binding_resolves` on `examples/preset-binding/`. The refusals are listed cases in Scope (lines 44-50), each exit 1 with a code.
7. Closed (binding: no code for a missing source). Scope line 48 names `unresolved_reference` for "no source holds the preset". That code is in the `ValidationCode` enum I read in round 1 (`spec/domains/cli.yaml`, `unresolved_reference`).
8. Closed (binding: before state was "refuses or ignores"). The before state is now the named case `binding_resolves` in `crates/ratchet/tests/validate.rs` failing on that directory, "because no bound requirement is reported". It holds whichever way 0.1.0 treats `presets:`.

No new finding. I checked each acceptance again for one outcome, an observable result and a stated before state.

What I read: 4 stories (`story:preset-catalog-functional`, `-runtime`, `-factory`, `story:preset-binding-resolution`) in full with `aep plan artifact show`, plus `grep binding_resolves` in `spec/` (no hits, as expected for a case this story adds). I did not re-read the epic.

What I could not establish: whether the 0.1.0 `validate` output format can carry `<binding>.<requirement>`, because no command is built. Two things are outside my lane. The new edge `story:preset-binding-resolution` to `story:preset-catalog-factory` is a coupling question for design or parallel-safety. The `crates/ratchet-cli-contract` and `crates/ratchet-core` scope entries are marked `inferred`.

```findings
[]
```
