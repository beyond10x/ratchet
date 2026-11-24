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
`ratchet-evidence/1` that nothing reads.

## Waves to 0.1.0

1. `story:cli-skeleton-validate`, `story:record-formats-in-spec`: a project can run
   `ratchet validate`; the command surface and the model are generated from `spec/` and checked for
   drift; the record formats are declared.
2. `story:evidence-reader`, `story:assessor-declaration`, `story:reference-compare`,
   `story:ui-loop-acceptance`, `story:changelog-release-procedure`: evidence files are read and
   checked, values are compared with a reference, the consumer's loop is an acceptance run that
   counts its passing steps, the release procedure is written.
3. `story:assess-command`, `story:reference-adopt-command`, `story:evaluate-command`: observe,
   adopt a first reference, reject a regression from the trusted revision's policy.
4. `story:acceptance-in-gate`: the acceptance run passes 7 of 7 inside the gate; getting-started
   page. Then 0.1.0 is cut.

Acceptance run `ui-loop`: not built yet (0 of 7 steps).

## Releases

- **0.1.0**: `validate`, `assess`, `reference adopt` (first adoption), `evaluate --gate` for exact
  numbers and identity sets; formats `ratchet/1`, `ratchet-evidence/1`, `ratchet-assessor/1`,
  `ratchet-reference/1`; Linux archives with checksums. Closes consumer gap 1.
- **After 0.1.0**, in this order: `epic:improvement-and-policy` (record an improvement, exceptions,
  trade-offs; consumer gaps 2, 3, 5), `epic:generated-artifact`, `epic:ci-turnaround` (insufficient
  evidence under host load; consumer gap 4), `epic:analyzer-findings`, `epic:ess-ui-behavior`.
