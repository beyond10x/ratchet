# Roadmap

Vision ([vision.md](vision.md)): one versioned YAML format states what a project's quality is, how
it is measured and when it is enforced. A candidate worse than the protected reference fails, with
the evidence named. Too little evidence is insufficient evidence, never a pass.

Target: `vision.md` § "First milestone" (`initiative:first-milestone` in `.engineering/planning/`).

## First consumer

The web UI loop of [`slot`](https://github.com/beyond10x/slot) (`ui/ux/`): a committed
`baseline.json` (12 scenarios, 109 values, lower is better), a comparator of 111 lines, a gate step.
Its first gap: no command reads a result file, compares it with a reference committed in the tree
and fails with the requirement, the scenario, the observed and the allowed value.
Second consumer: [`uxui`](https://github.com/beyond10x/uxui), whose assessor writes
`ratchet-evidence/1` that nothing reads. Its first gaps, in its order, none of them closed before 0.1.0:
`ratchet evaluate --gate` on a fixed limit, `ratchet assess --report`, `ratchet validate`, then
evidence with `target.kind: build` (`story:build-target-invocation`).

## Waves to 0.1.0

The order is the one `aep plan artifact waves --kind story` derives.

1. `story:record-formats-in-spec`: every specification change 0.1.0 needs, in one change. Each
   generated file carries a digest of the whole specification, so the specification settles before
   code is generated from it.
2. `story:workspace-cli-contract`: the Rust workspace, the pinned compiler, the command surface
   generated from `spec/` and checked for drift, a `ratchet` binary whose 16 commands answer
   "unavailable", the gate tasks and the CI job.
3. `story:changelog-release-procedure`: the changelog and the release procedure.
4. `story:cli-skeleton-validate`: a project can run `ratchet validate`; the model is generated from
   `spec/` and checked for drift. The owner answered on 2026-11-25 that the model crate is the
   output of `ess generate synthesize` alone, decoders included, and that the reading rules of
   the file formats are declared in the specification and applied by the generated decoder.
   The wave is not dispatched until an ESS release emits typed decoders without a server and
   applies those rules; nothing of the model or of the reading rules is written by hand.
5. `story:evidence-reader`, `story:assessor-declaration`, `story:reference-compare`: evidence files
   are read and checked, a plan is checked against its assessor's declaration, values are compared
   with a reference.
6. `story:assess-command`, `story:reference-adopt-command`, `story:evaluate-command`,
   `story:ui-loop-acceptance`: observe, adopt a reference, reject a regression from the trusted
   revision's policy; the consumer's loop is an acceptance run that counts its passing steps.
7. `story:acceptance-in-gate`: the acceptance run passes 7 of 7 inside the gate; getting-started
   page.
8. `story:release-0-1-0`: the release, by `AGENTS.md` § "Release".

Acceptance run `ui-loop`: not built yet (0 of 7 steps).

Wave 2 was split on 2026-11-24: the workspace and the command surface do not depend on the open
question, so they are built first, and the release procedure follows them.

Wave 1 is delivered (2026-11-24): the specification 0.1.0 is built from, with seven checks of it in
`task check:spec`. Record: `.engineering/waves/0.1.0-wave-1.md`.

Wave 2 is delivered (2026-11-25): the workspace, the generated command surface with its drift
check, a `ratchet` binary whose 16 commands answer "unavailable" and that prints its version, the
test budget in the gate, and the CI job `Repository gate`. Record:
`.engineering/waves/0.1.0-wave-2.md`.

Wave 3 is delivered (2026-11-25): `CHANGELOG.md`, the release procedure in `AGENTS.md` § "Release",
the tag workflow `Release` and the scripts that check a tag, build the archives and verify a
published release. The workflow ran on the forge for release 0.0.1.
Record: `.engineering/waves/0.1.0-wave-3.md`.

## Releases

- **0.0.1**: released on 2026-11-25, the first release, ordered by the owner
  (https://github.com/beyond10x/ratchet/releases/tag/0.0.1). It holds the specification, the
  four formats, the release procedure and a
  `ratchet` binary that parses the 16 commands; no command is built, so it checks nothing for a
  project. Linux archives with checksums.
- **0.1.0**: `validate`, `assess`, `reference adopt` (first adoption and tightening of an exact
  measurement), `evaluate --gate` for exact numbers and identity sets, with an absolute or percent
  tolerance; formats `ratchet/1`, `ratchet-evidence/1`, `ratchet-assessor/1`, `ratchet-reference/1`;
  Linux archives with checksums. Closes consumer gap 1.
- **After 0.1.0**, in this order: `epic:improvement-and-policy` (the gate fails when a better value
  was not adopted, exceptions, trade-offs; consumer gaps 2, 3, 5), `epic:generated-artifact`,
  `epic:ci-turnaround` (insufficient evidence under host load; consumer gap 4),
  `epic:analyzer-findings`, `epic:ess-ui-behavior`.

## Beside the waves

Three epics run beside the waves to 0.1.0 and change the content of none of their stories.

- `epic:preset-catalog`: a standard catalog of quality criteria as `ratchet/1` presets, ordered
  by the owner on 2026-11-24. Four stories, one after another: `story:preset-catalog-functional`
  (`presets/`, the file names, the check in the gate, the functional family),
  `story:preset-catalog-runtime`, `story:preset-catalog-factory`, and after 0.1.0
  `story:preset-binding-resolution`. A catalog story starts between two waves, from the `main`
  of that moment. First consumer: a project that compares a candidate implementation of a
  service with a reference implementation; its first gap is the functional family.
  `story:preset-catalog-functional` is delivered (2026-11-25): `presets/` holds the functional
  family, and `sh spec/presets.test.sh` checks every file of the catalog in `task check:spec`.
  Record: `.engineering/waves/catalog-functional.md`.
  `story:preset-catalog-runtime` is delivered (2026-11-25): seven presets of four families
  observed while a workload runs (latency and throughput, resources, start and readiness,
  operability), five assessor declarations and four pages. Of them 0.1.0 judges
  `metric-names@1` alone. Record: `.engineering/waves/catalog-runtime.md`.
  `story:preset-catalog-factory` is delivered (2026-11-25): twelve presets of three families
  read from a build and from the tree (build, artifact, code), nine assessor declarations
  and three pages; `presets/` holds the eight families. Of the twelve 0.1.0 judges the
  seven of the artifact and the code family. Record: `.engineering/waves/catalog-factory.md`.
- `epic:format-gaps-first-format-consumer`: 22 places (23 findings, one withdrawn) from the quality definition the first
  consumer of the formats wrote against them (`beyond10x/inference`), as nineteen draft
  stories. They wait for the waves to 0.1.0, except `story:example-assessor-declarations`,
  taken ahead of them on 2026-11-25 and delivered on 2026-11-26: nine declarations in
  `examples/quality/assessors/` and their check `spec/example-declarations.test.sh`, and the
  four of the wave below.
- `epic:format-gaps-second-format-consumer`: 3 findings from the draft quality definition of
  a second repository (`beyond10x/swell`, a script engine that also compares itself with
  other engines), as three draft stories. They wait for the waves to 0.1.0.

One wave runs ahead of the waves to 0.1.0, chosen by the owner on 2026-11-26: every planned
wave starts behind `story:cli-skeleton-validate`, which waits for an ESS release
(beyond10x/ess#836). Its nine stories need no `ratchet` command and are built in sequence on one
branch and merged as one pull request: `story:workflow-run-target-identifiers`,
`story:candidate-under-merge-result`, `story:cache-condition-one-name`,
`story:specification-answers-first-format-consumer`,
`story:plan-with-exact-and-sampled-measurements`, `story:preset-check-unlisted-forms`,
`story:value-over-all-runs`, `story:item-field-values`,
`story:production-gate-spec-executed-service`. The parts that need the command are five
`-in-ratchet` drafts that wait for the waves to 0.1.0. Record:
`.engineering/waves/0.1.0-ahead-1.md`.
