---
format: aep.planning-md/3
id: review-result:acceptance-catalog-round-1
kind: review-result
status: active
title: acceptance critic on the preset catalog drafts, round 1
relations:
- reviews: epic:preset-catalog
revision: 1
---
Recorded by the coordinator from the critic's report on `epic:preset-catalog` and its four draft stories, verbatim except that absolute paths of the workstation are replaced by `<tree>` and `<scratch>`.

needs-revision

- story:preset-catalog-functional — the acceptance covers only the gate check, so the family itself (the `conformance-cases@1` file, its declarations, `presets/functional.md`) has no checkable outcome. The check also never says the script prints the count of checked files that the runtime and factory acceptances compare against; the sibling scripts print a final `n of n` line (`spec/record-examples.test.sh:29-31`). Add the family files and the page to the acceptance, and require a final line naming the checked-file count — `aep plan artifact show story:preset-catalog-functional`, Acceptance lines 34-38; Scope line 46.
- story:preset-catalog-runtime — the acceptance joins four independent outcomes (files exist; the script passes and its count rises; the four pages state direction, unit, tolerance and source; the script fails on a measurement without a row), so one can pass while another fails. Reduce it to one outcome and move the rest to the Scope or Notes, or split the story — quoted: "`presets/` holds the preset files ... and the script test fails when a measurement of a preset has no row on the page of its family" (show output lines 21-26).
- story:preset-catalog-runtime — the "no row" refusal is conditional on a sibling's work (Scope line 32: "when `story:preset-catalog-functional` did not add it"), and the functional acceptance (lines 34-38) does not require it. Before this story the refusal may exist or not, so the acceptance reads the same either way. Assign the case to exactly one story and state it as a before/after pair: one of the two stories fails a copy with a missing row, and the script passes today without that case.
- story:preset-catalog-runtime — "each of the four pages states ... direction, unit, tolerance input or that the value is exact, and the source of the evidence" cannot be checked by a command, because the only mechanical check named is that a row exists. It leaves the page content open to a reviewer's reading, and "every criterion of `epic:preset-catalog` in its family" refers to prose with no machine list (epic lines 33-44). Make the script test assert the four columns are non-empty per row, or drop the content claim from the acceptance.
- story:preset-catalog-factory — the same defects as runtime. Two outcomes are joined by "and" (files plus a passing script, then the page content). The page-content clause has no command behind it: the story adds no row check, and Scope lists no change to `spec/presets.test.sh` (show output lines 20-24, 26-30). Add a checkable form (a row-and-column check, or the dependency on the runtime or functional check named in the acceptance) or remove the clause.
- story:preset-binding-resolution — the acceptance holds five or more independent outcomes in one sentence (exit 0 and listing as `<binding>.<requirement>`; a gate naming a bound requirement is valid; `preset_digest_mismatch`; `preset_input_invalid`; a missing-source refusal). One can pass while the others fail. Reduce it to one outcome, with the rest as listed test cases in Scope — show output lines 29-35.
- story:preset-binding-resolution — the final clause, "and when no source holds the preset", names no error code. `ValidationCode` in `spec/domains/cli.yaml:129-155` has no code for it, so a reviewer cannot tell what the command must print. Name the code, either an existing one such as `unresolved_reference` or a new one declared first in `cli.yaml`.
- story:preset-binding-resolution — the before state is "the command refuses the key `presets` or ignores it". That is two different states, and the acceptance cannot say which of them the failing test shows. Check which one holds on the 0.1.0 `validate`, or name the test that fails before, such as a new case in `crates/ratchet/tests/validate.rs`, with its expected exit status and code.

Not a finding: the functional acceptance has one outcome, and its before and after states are explicit: the step does not exist and `presets/` is absent before; the step fails on the named refused copies and passes on the story's files after.

What I read: 5 artifacts (`epic:preset-catalog` and the four stories) with `aep plan artifact show` for each, plus `spec/domains/cli.yaml:125-160`, `spec/domains/config.yaml:30-50`, the head of `spec/record-examples.test.sh`, and the `check:spec` task in `Taskfile.yml`. The `presets/` directory is absent, as the stories say.

What I could not establish: whether the 0.1.0 `validate` refuses or ignores `presets:`, because no command is built. The store paths I cited are the ids' `show` output, not verified file lines.

Out of my lane: whether a `sampled` criterion with no default tolerance belongs in a catalog (design), and whether `story:preset-catalog-runtime` and `story:preset-catalog-factory` both touch `spec/presets.test.sh` and `CHANGELOG.md` (parallel-safety).

```findings
- file: aep plan artifact show story:preset-catalog-functional
  line: 34
  category: acceptance
  severity: blocker
  verdict: needs-revision
  origin: introduced
  message: "the acceptance covers only the gate check, so the functional family (conformance-cases@1 file, declarations, functional.md) has no checkable outcome, and the check is never required to print the checked-file count that the runtime and factory acceptances compare against"
- file: aep plan artifact show story:preset-catalog-runtime
  line: 21
  category: acceptance
  severity: blocker
  verdict: needs-revision
  origin: introduced
  message: "the acceptance joins four independent outcomes (files exist; script passes and count rises; four pages state direction, unit, tolerance, source; script fails on a measurement without a row), so one can pass while another fails"
- file: aep plan artifact show story:preset-catalog-runtime
  line: 32
  category: acceptance
  severity: blocker
  verdict: needs-revision
  origin: introduced
  message: "the missing-row refusal is conditional on a sibling's work ('when story:preset-catalog-functional did not add it') and no acceptance requires it in either story, so the before state is undefined; assign it to one story as a before/after pair"
- file: aep plan artifact show story:preset-catalog-runtime
  line: 23
  category: acceptance
  severity: warning
  verdict: needs-revision
  origin: introduced
  message: "the page-content claim (direction, unit, tolerance or exact, source per criterion) has no command behind it beyond a row existing, and 'every criterion of epic:preset-catalog' refers to prose with no machine list"
- file: aep plan artifact show story:preset-catalog-factory
  line: 20
  category: acceptance
  severity: blocker
  verdict: needs-revision
  origin: introduced
  message: "the acceptance joins the files-and-script outcome with a page-content outcome that no command checks (the story adds no row check and Scope lists no change to spec/presets.test.sh)"
- file: aep plan artifact show story:preset-binding-resolution
  line: 29
  category: acceptance
  severity: blocker
  verdict: needs-revision
  origin: introduced
  message: "the acceptance holds five independent outcomes in one sentence (exit 0 and listing, gate validity, digest mismatch, invalid input, missing source), so one can pass while the others fail"
- file: spec/domains/cli.yaml
  line: 129
  category: acceptance
  severity: blocker
  verdict: needs-revision
  origin: introduced
  message: "story:preset-binding-resolution says the command exits non-zero 'when no source holds the preset' and names no error code, and ValidationCode (cli.yaml:129-155) has none for it; name an existing code or declare one first"
- file: aep plan artifact show story:preset-binding-resolution
  line: 35
  category: acceptance
  severity: warning
  verdict: needs-revision
  origin: introduced
  message: "the before state 'the command refuses the key presets or ignores it' is two different states, so the failing-before check is undefined; name the test that fails before with its expected exit status and code"
```
