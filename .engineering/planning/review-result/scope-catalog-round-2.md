---
format: aep.planning-md/3
id: review-result:scope-catalog-round-2
kind: review-result
status: active
title: scope critic on the preset catalog drafts, round 2
relations:
- reviews: epic:preset-catalog
revision: 1
---
Recorded by the coordinator from the critic's report on `epic:preset-catalog` and its four draft stories, verbatim except that absolute paths of the workstation are replaced by `<tree>` and `<scratch>`.

approve

Round-1 findings, all four closed. I re-read the epic (revision 2) and the four stories with `aep plan artifact show`.
1. story:preset-catalog-factory, tolerance on exact values: closed. The epic now says a count and a set have no input and a size may have a tolerance input defaulting to zero (.engineering/planning/epic/preset-catalog.md:66-68). Factory Notes follow it: counts and sets "exact with the tolerance zero and no input", a size in bytes with an input defaulting to zero (story/preset-catalog-factory.md:49-51).
2. story:preset-catalog-runtime, the page-row check: closed. The epic's Outcome asks for the row rule (epic:56-59). story:preset-catalog-functional owns it for every page (story/preset-catalog-functional.md:63-65). Runtime and factory now only add pages and say the script is not edited (runtime:29-30, factory:29).
3. story:preset-binding-resolution, nothing private: closed. It carries the generic-examples line at story/preset-binding-resolution.md:65.
4. epic "Done when": closed. `presets/README.md` carries what a project writes before resolution (epic:133-134, functional:53-54). Telling the consumer is named as the coordinator's act and "no story" (epic:134-136).

I raise no new finding. Epic promises, as the 27 from round 1:
- all 27 trace to an item;
- the epic now says the path-source narrowing (epic:92-94, binding story:62-63);
- the § 3.1/§ 3.2 order is fixed (factory:36-38).

What I read: 5 artifacts with `aep plan artifact show`, each in full.

What I could not establish: none. Out of my lane, and not setting the verdict:
- The binding story's acceptance names one passing case, while the refusal cases are only in its scope (binding story:33-38 against :43-50). That is for the acceptance critic.
- The functional story leaves open whether the known-failure list is its own preset or part of `conformance-cases@1` (functional:93-94). I count it as claimed, since the story decides.

```findings
[]
```
