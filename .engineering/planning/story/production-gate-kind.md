---
format: aep.planning-md/3
id: story:production-gate-kind
kind: story
status: active
title: A gate states that it is a production gate
relations:
- decomposes: epic:preset-catalog
scope:
- confidence: cited
  path: docs/design.md
- confidence: cited
  path: examples/README.md
- confidence: cited
  path: examples/production-gate.ratchet.yaml
- confidence: cited
  path: presets/production.md
- confidence: cited
  path: spec/domains/specification.yaml
revision: 14
transitions:
- {from: "draft", to: "proposed", at: "2026-11-26T21:04:25Z", actor: "human:operator", revision: 13, decided_on: {"recorded":{"review_outcome":4}}}
- {from: "proposed", to: "active", at: "2026-11-26T21:04:25Z", actor: "human:operator", revision: 14, decided_on: {"recorded":{"review_outcome":4}}}
---
## Context

Named by `story:production-gate-spec-executed-service`. A production gate is evaluated on a
deployed environment, not on the candidate of a change. The gate kinds are `candidate` and
`operational` (`ratchet.specification.GateKind`, `spec/domains/specification.yaml:677-679` at
7b01ea1); an operational gate takes only time-window plans without a `selection`
(`docs/design.md` § 5, "The evidence of an operational gate is a window", `:650`), and the
plans of the bound presets carry `selection: candidate`. `examples/production-gate.ratchet.yaml`
therefore states `kind: candidate` (`:75-78`, the gate `production`, `stage: pre-production`,
`qualifying_environments: [staging]`), and nothing in the file says that the gate judges a
deployment. `presets/production.md`, point 1 of "Not expressible yet" (`:123-127`), and
`examples/README.md` § 6 (`:473-476`) say so.

`story:gate-judges-commit-of-a-tag` (30 in the order) adds `judges` to `Gate`, a struct
`ratchet.specification.JudgedCandidate` with the form `{tag: <pattern>}`: a candidate gate
that judges a revision other than the candidate of a change.

## The question and the decision

Whether a production gate is a third gate kind, a candidate gate that names the deployment it
judges, or a candidate gate over plans of the target kind `deployment` with nothing new.

Decided on 2026-11-26 by the operator session acting for the owner (D88 A; B, a third gate
kind, and C, nothing new, were not taken): a production gate is a candidate gate
whose `judges` names the deployment it judges, `judges: {deployment: <target class>}`, such as
`staging`. `JudgedCandidate` gets the optional `deployment` of the type
`ratchet.specification.TargetClass`, and exactly one of `tag` and `deployment` is present.
`GateKind` keeps its two values: a third kind would repeat every rule of a candidate gate.

D88 A says only `judges: {deployment: <class>}`. Which revision is deployed in the class, and
so which revision the gate judges as its candidate, is a question of the design that D88 did
not answer: `docs/design.md` names it as left open, in one sentence of the paragraph "Gate
kinds", and this story answers it no further. No rule of this story ties the plans of the
gate's requirements to the class.

## Acceptance

Every outcome below is observable without a `ratchet` command.

A phrase with a space in it may wrap in a Markdown paragraph or a folded YAML summary. So where
an item says that `grep -F` finds such a phrase in a `.md` or `.yaml` file, that it finds
nothing or the phrase is gone, or that `grep -c` of it prints a count, the check reads the
joined text of the file: `tr -s '\n ' '  ' < <file> | grep -o -F '<phrase>' | wc -l` prints 1
where the item says it is found, 0 where it says nothing or gone, and the count where it names
one. A name without a space, a row of a table, a pattern with `^`, `$` or `-E`, a check that
prints the line it matches and a check that reads the output of another command read the file
line by line, as written.

1. `spec/domains/specification.yaml`, `ratchet.specification.JudgedCandidate` has the
   optional member `deployment` of the type `ratchet.specification.TargetClass`:
   `grep -c 'name: deployment' spec/domains/specification.yaml` prints 1 (0 before), and
   `ess specify validate --path spec --strict-requires` and `task check:generated` exit 0.
2. `tag` of `JudgedCandidate` becomes optional and an invariant states that exactly one of
   `tag` and `deployment` is present: `grep -F 'any: ["defined(tag)", "defined(deployment)"]'
   spec/domains/specification.yaml` and `grep -F 'any: ["not defined(tag)", "not
   defined(deployment)"]' spec/domains/specification.yaml` each find a line (nothing before).
3. `docs/design.md` § 5, the paragraph "Gate kinds", says that a production gate is a candidate
   gate with `judges: {deployment: <class>}`: `grep -F 'A production gate is a candidate gate
   with `judges: {deployment: <class>}`' docs/design.md` finds it (nothing before).
4. The same paragraph names, in one sentence, which revision is deployed in the class as left
   open: `grep -F 'Which revision is deployed in the class is left open' docs/design.md` finds
   it (nothing before).
5. `examples/production-gate.ratchet.yaml`, the gate `production` has
   `judges: {deployment: staging}` and keeps `kind: candidate`:
   `grep -c '^    judges: {deployment: staging}$' examples/production-gate.ratchet.yaml`
   prints 1 (0 before), and `sh spec/example-declarations.test.sh`, which reads the plans and
   bindings of the file and not the keys of a gate, still exits 0.
6. `examples/README.md` § 6, the bullet on the gate kind, says that the gate states with
   `judges` that it judges a deployment: `grep -F 'states with `judges: {deployment: staging}`
   that it judges the deployment in `staging`' examples/README.md` finds it (nothing before).
7. `presets/production.md`, point 1 of "Not expressible yet", rewritten in place, says that
   the point is answered: `grep -F 'answered by `judges: {deployment: <class>}`'
   presets/production.md` finds it (nothing before), and the list keeps its numbering.

## Notes

- An addition to a released format: a gate without `judges` stays valid.
- `ratchet evaluate` judging such a gate is `story:production-gate-kind-in-ratchet`, which
  waits for the waves to 0.1.0 (`story:evaluate-command`). It judges the revision given with
  `--candidate`; finding the revision deployed in the class waits for the answer to the open
  question of item 4. `ratchet.specification.GateKind` keeps its two values.
- Before this story, `story:severity-limit-on-identity-set` (13) changes the plan and
  requirement of check 6 in `examples/production-gate.ratchet.yaml` and its row and bullet in
  `examples/README.md` § 6; this story changes only the gate block and the bullet on the gate
  kind. `story:gate-judges-commit-of-a-tag` (30) adds `judges` with `tag` just before;
  `story:gate-joins-revision-and-document` (32) changes the gate decision after.
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of `.engineering/waves/0.1.0-ahead-2.md`,
  into one wave built in sequence on one branch: every planned wave starts behind
  `story:cli-skeleton-validate`, which waits for a release of ESS (beyond10x/ess#836), and this
  part needs no `ratchet` command. It is 31 of the 33 in the order of that page.
