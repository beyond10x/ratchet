---
format: aep.planning-md/3
id: story:production-gate-kind
kind: story
status: draft
title: A gate states that it is a production gate
relations:
- decomposes: epic:preset-catalog
scope:
- confidence: cited
  path: CHANGELOG.md
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
revision: 9
---
## Context

Named by `story:production-gate-spec-executed-service`. A production gate is evaluated on a
deployed environment, not on the candidate of a change. The gate kinds are `candidate` and
`operational` (`ratchet.specification.GateKind`, `spec/domains/specification.yaml:677-679`);
an operational gate takes only time-window plans without a `selection` (`docs/design.md` § 5,
"The evidence of an operational gate is a window", `:650`), and the plans of the bound presets
carry `selection: candidate`. `examples/production-gate.ratchet.yaml` therefore states
`kind: candidate` (`:75-78`, the gate `production`, `stage: pre-production`,
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
`ratchet.specification.TargetClass`, and exactly one of `tag` and `deployment` is present. The
candidate of such a gate is the revision deployed in that class. `GateKind` keeps its two
values: a third kind would repeat every rule of a candidate gate.

## Acceptance

Every outcome below is observable without a `ratchet` command.

1. `spec/domains/specification.yaml`: `JudgedCandidate` has the optional `deployment`
   (`TargetClass`), `tag` becomes optional, and an invariant states that exactly one of the two
   is present; `GateKind` (`:677-679`) is unchanged. Checked by
   `ess specify validate --path spec --strict-requires`, which exits 0, and by
   `task check:generated`.
2. `docs/design.md` § 5, the paragraph "Gate kinds" (`:648`): a production gate is a candidate
   gate with `judges: {deployment: <class>}`, its candidate is the revision deployed in that
   class, and every requirement of it names a plan that runs in that class; the value list of
   § 3 is unchanged. Text only, no case.
3. `examples/production-gate.ratchet.yaml`: the gate `production` (`:75-78`) has
   `judges: {deployment: staging}` and keeps `kind: candidate`. Before the story the gate says
   nothing of a deployment. Text only, no case: `sh spec/example-declarations.test.sh` reads the
   plans and bindings of the file, not the keys of a gate; it still exits 0.
4. `examples/README.md` § 6, the bullet on the gate kind (`:473-476`), and
   `presets/production.md`, point 1 of "Not expressible yet" (`:123-127`), say that the gate
   states it judges a deployment with `judges`, answered from this release on. Text only, no
   case.
5. `CHANGELOG.md` has its line under `## [Unreleased]`. Text only, no case.

## Notes

- An addition to a released format: a gate without `judges` stays valid.
- `ratchet validate` reporting a requirement of a gate with `judges: {deployment: <class>}`
  whose plan does not run in that class, with a code, and `ratchet evaluate` recording the
  class judged in the gate decision, are `story:production-gate-kind-in-ratchet`, which waits
  for the waves to 0.1.0 (`story:evaluate-command`).
- Before this story, `story:severity-limit-on-identity-set` (13) changes the plan and
  requirement of check 6 in `examples/production-gate.ratchet.yaml` (`:51-73`) and its row and
  bullet in `examples/README.md` § 6; this story changes only the gate block and the bullet on
  the gate kind. `story:gate-judges-commit-of-a-tag` (30) adds `judges` with `tag` just before;
  `story:gate-joins-revision-and-document` (32) changes the gate decision after.
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of `.engineering/waves/0.1.0-ahead-2.md`,
  into one wave built in sequence on one branch: every planned wave starts behind
  `story:cli-skeleton-validate`, which waits for a release of ESS (beyond10x/ess#836), and this
  part needs no `ratchet` command. It is 31 of the 33 in the order of that page.
