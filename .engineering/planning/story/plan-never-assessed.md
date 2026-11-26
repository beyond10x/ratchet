---
format: aep.planning-md/3
id: story:plan-never-assessed
kind: story
status: draft
title: A plan that was never assessed is told apart from a plan whose record is missing
summary: A plan in observe mode with no run is reported as never assessed, and a file can state that no run is expected yet.
relations:
- decomposes: epic:format-gaps-first-format-consumer
scope:
- confidence: cited
  path: CHANGELOG.md
- confidence: cited
  path: crates/ratchet-cli-contract
- confidence: cited
  path: docs/design.md
- confidence: cited
  path: spec/domains/cli.yaml
- confidence: cited
  path: spec/domains/specification.yaml
revision: 14
---
## Context

The repository `beyond10x/inference` wrote the second unit of its quality definition against
the formats at commit `f139ecc` (2026-11-25): measures per adapter, and latency defined
without a number. It is the first consumer of the formats outside this repository and of this
story. An adversary pass of the consumer read the finding against the specification at that
commit. Line numbers below are those of `7b01ea1`.

Finding 21. A file cannot say that no evidence was ever collected for a plan. "An assessment
with no requirement in any gate is in observe mode" (`docs/design.md:629`, § 5 "Gate modes";
`ratchet.specification.AssessmentPlan`, `spec/domains/specification.yaml:919-927`). A plan in
observe mode whose command never ran and a plan whose record is missing look the same in the
file and in a verdict. The consumer has 26 latency measures of that kind: the command is billed
by a provider and no run was kept. It says so on a page, with the line "Baseline: none.".

What the command surface declares: `ratchet status` shows every requirement with its verdict
and when it was last checked (`docs/design.md:743`). Its row, `ratchet.cli.StatusRow`
(`spec/domains/cli.yaml:584-625`), has `verdict` "absent when no run qualifies yet" and no
member that says whether the plan ever ran. A requirement with no qualifying run in a gate is
insufficient evidence with the cause `evidence_missing` (`docs/design.md:618`, § 5 "Verdicts").

The decision this story takes, the reversible one (`AGENTS.md` § "Phase: implementation"):

- In the file: a member `no_run_expected` of `AssessmentPlan`, a struct
  `ratchet.specification.NoRunExpected` with a required `reason` (text). It states that no run
  of the plan is expected yet and why.
- In the status row: a member `plan_state` of `StatusRow`, of the enum
  `ratchet.cli.PlanRunState` with `assessed` (the record store holds a run of the plan),
  `never_assessed` (it holds none) and `no_run_expected` (it holds none and the file says so).
  A plan that ran before and has no run for this revision is `assessed` with no `verdict`, and
  a gate gives it `evidence_missing` as today.

## Acceptance

Every outcome below is observable without a `ratchet` command.

1. `spec/domains/specification.yaml`: the struct `ratchet.specification.NoRunExpected` with
   `reason` (`String`) and the member `no_run_expected`
   (`Optional<ratchet.specification.NoRunExpected>`) of `AssessmentPlan` (`:919`), whose
   summary says what it states and that the plan stays in observe mode or in report mode until
   a run exists. Checked by `ess specify validate --path spec --strict-requires`, which exits 0.
2. `spec/domains/cli.yaml`: the enum `ratchet.cli.PlanRunState` with `assessed`,
   `never_assessed` and `no_run_expected`, and the member `plan_state` of
   `ratchet.cli.StatusRow` (`:584`). Checked by `ess specify validate` and by
   `ess specify cli --path spec --binding spec/cli.yaml --strict-requires` (step 2 of
   `task check:spec`), each exit 0, and by `task check:generated` after `task generate` has
   rewritten `crates/ratchet-cli-contract/` (its `binding.json` holds the members of the
   result rows).
3. `docs/design.md` § 5 "Gate modes" (`:629`): a paragraph tells the three states apart: a plan
   never assessed, a plan whose file states `no_run_expected` with a reason, and a plan whose
   run is missing for the revision (`evidence_missing` in a gate, § 5 "Verdicts", `:618`); and
   that a requirement in an enforced gate entry whose plan states `no_run_expected` is a
   validation error, because the entry could never pass. The row of `ratchet status` in the
   table of § 5 "Proposed CLI" (`:743`) names the state of the plan. Text only, no case.
4. `CHANGELOG.md` has its line under `## [Unreleased]`. Text only, no case.

## Notes

- Decision taken: a statement in the file and a state in the status row (§ Context). The
  statement is a struct with one member so that a later member, such as a date until which no
  run is expected, is an addition.
- An addition to a released format: a file written before the change stays valid. The status
  row is a result of a command no release builds.
- `spec/presets.test.sh` gets no case: a preset states no `no_run_expected`, which is a
  project's statement about its own runs.
- The command part, `ratchet status` printing the three states apart and `ratchet validate`
  refusing an enforced entry whose plan states `no_run_expected` with a code, is
  `story:plan-never-assessed-in-ratchet`, which waits for the waves to 0.1.0
  (`story:cli-skeleton-validate`, `story:evidence-reader`).
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of `.engineering/waves/0.1.0-ahead-2.md`,
  into one wave built in sequence on one branch: every planned wave starts behind
  `story:cli-skeleton-validate`, which waits for a release of ESS (beyond10x/ess#836), and this
  part needs no `ratchet` command. It is 25 of the 33 in the order of that page. Before it,
  `story:plan-declares-what-its-command-needs` (24) adds a member to `ObservationPlan`; after
  it, `story:new-item-without-accepted-value` (26) writes into § 5 "Protected references" and
  "Verdicts". Any other story of the wave that changes `spec/domains/cli.yaml` regenerates
  `crates/ratchet-cli-contract/` in its own change, so this one starts from a crate that
  `task check:generated` accepts.
- No script changes. The test step ends within 120 s, no test over 60 s.
