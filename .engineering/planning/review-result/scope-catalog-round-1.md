---
format: aep.planning-md/3
id: review-result:scope-catalog-round-1
kind: review-result
status: active
title: scope critic on the preset catalog drafts, round 1
relations:
- reviews: epic:preset-catalog
revision: 1
---
Recorded by the coordinator from the critic's report on `epic:preset-catalog` and its four draft stories, verbatim except that absolute paths of the workstation are replaced by `<tree>` and `<scratch>`.

needs-revision

preset-catalog-factory (story:preset-catalog-factory) — the Notes give exact values "the tolerance zero unless the binding passes one", but the epic's rule is "An exact value ... has the tolerance zero and no input for it"; drop the clause, or have the epic say that an exact value may take a binding-passed tolerance — .engineering/planning/story/preset-catalog-factory.md:55 against .engineering/planning/epic/preset-catalog.md:68
preset-catalog-runtime (story:preset-catalog-runtime) — the scope adds a script-test case "a measurement without a row on its page" and its acceptance requires it to fail. The epic asks only that the gate check the files against the specification, and it states page content without asking for a check of it. The case also covers four of the eight families, so the other four have none. Drop the case, or make the epic ask for it and move it to story:preset-catalog-functional so it covers all eight — .engineering/planning/story/preset-catalog-runtime.md:39 and the acceptance at :20-26, against .engineering/planning/epic/preset-catalog.md:61-63
preset-binding-resolution (story:preset-binding-resolution) — the epic's rule "Nothing private: no name of a consumer, a product or a customer, in a file or in an example" has no claim here. This story writes `examples/` and the README text, and unlike the three catalog stories its Notes carry no "every example is generic" line. Add the line to the Notes — .engineering/planning/story/preset-binding-resolution.md:51 against .engineering/planning/epic/preset-catalog.md:80
epic:preset-catalog — the "Done when" promise "the first consumer has been told the path and commit of the catalog, which part 0.1.0 evaluates, and what to write before the commands exist" is claimed by none of the four stories. Only the "which part 0.1.0 evaluates" half is covered, by the per-page markers in the runtime and factory stories. Either record in the epic that the coordinator does this after the stories land, or add the "what to write before `ratchet validate` resolves" text to the scope of `presets/README.md` in story:preset-catalog-functional — .engineering/planning/epic/preset-catalog.md:110-113

Part 3. I extracted 27 promises from the epic and traced 24 of them to a story. They are:
- the eight families with their listed criteria (8, plus the sub-criteria, all traced);
- the per-criterion fields and the per-family page;
- the check in the gate;
- binding resolution;
- the rules: preset shape, tolerance, reference implementation, names, evidence, nothing private;
- the "Done when" notification.
The three that did not trace are the tolerance rule (finding 1, contradicted), the "nothing private" rule for the binding story (finding 3) and the notification (finding 4). Finding 2 is reach, not a gap.

Part 4. What I could not establish:
- I did not see the drafter's report, so I could not tell whether finding 4 is a promise the drafter already named as left to the coordinator.
- story:preset-binding-resolution resolves only a path source, a narrowing the story's Notes state at :60. The epic does not mention it, and the epic's own motivation, projects binding the catalog instead of copying it, usually means a `git` source, as `spec/domains/config.yaml:38` shows. It is named, so it is not a finding here, and I leave its weight to the caller.
- factory:43 pairs `test-time@1` and `test-step-time@1` with § 3.1 and § 3.2 in the wrong order, since § 3.1 is test-step-time. This is a wording slip, so it is not a finding.
- Out of my lane:
  - whether the functional acceptance (the gate failing) also covers the page-content requirement of the "functional family" section;
  - how the 0.1.0 judging of exact values interacts with inputs;
  - whether the draft stories listed as filed by the coordinator are checkable.

Part 1 checks done: nothing else in the graph claims any part of the parent, since the other epics are unrelated and the accepted stories (`story:assessor-declaration`, `story:reference-compare`) are unchanged by the set.

```findings
- file: .engineering/planning/story/preset-catalog-factory.md
  line: 55
  category: scope
  severity: warning
  verdict: needs-revision
  origin: introduced
  message: "the Notes give exact values 'the tolerance zero unless the binding passes one', but the epic's rule is that an exact value has the tolerance zero and no input for it; drop the clause or amend the epic"
- file: .engineering/planning/story/preset-catalog-runtime.md
  line: 39
  category: scope
  severity: warning
  verdict: needs-revision
  origin: introduced
  message: "the script-test case 'a measurement without a row on its page' is a check the epic did not ask for, and it covers four of eight families; drop it or have the epic ask for it and move it to the functional story to cover all eight"
- file: .engineering/planning/story/preset-binding-resolution.md
  line: 51
  category: scope
  severity: warning
  verdict: needs-revision
  origin: introduced
  message: "the epic's 'nothing private ... in an example' rule has no claim here although this story writes examples/ and README text; add the generic-examples line to the Notes"
- file: .engineering/planning/epic/preset-catalog.md
  line: 110
  category: scope
  severity: warning
  verdict: needs-revision
  origin: introduced
  message: "the 'Done when' promise that the first consumer is told the path, commit, what 0.1.0 evaluates and what to write before the commands exist is claimed by no story; name the coordinator as owner in the epic or put the 'what to write before resolution' text in presets/README.md of story:preset-catalog-functional"
```
