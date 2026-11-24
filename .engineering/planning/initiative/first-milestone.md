---
format: aep.planning-md/3
id: initiative:first-milestone
kind: initiative
status: draft
title: 'First milestone: observe, adopt a gate, reject a regression, record an improvement'
summary: vision.md § First milestone, ordered by the gaps of the first consumer, the web UI loop of slot.
revision: 2
---
## Context

`vision.md` § "First milestone" is the target of this initiative: a project that starts in observe
mode, adopts a gate, rejects a regression with actionable evidence, and records an improvement as
a new protected reference, across four integrations (ESS UI behavior, CI turnaround, no new
findings from an existing analyzer, a generated artifact compared by digest). It returns
insufficient evidence, not a fail, when the host and not the candidate caused a limit to be
crossed.

The owner opened implementation planning on 2026-11-24 (`AGENTS.md` § "Phase: implementation").

## First consumer

The web UI loop of the `slot` repository (`ui/ux/` there). It holds a ratchet by hand: a committed
`baseline.json` of accepted values per scenario and key (12 scenarios, 109 entries, lower is
better), a comparator of 111 lines in TypeScript, and a gate step that runs it. Six more
repositories of the organization carry a copy of the same loop. Its gaps, in the order its gate
needs them:

1. A command that reads a result file, compares each value with a reference committed in the tree
   and read from the trusted revision, and fails with the requirement, the scope item, the
   observed and the allowed value.
2. A fail when a better value was measured and the reference was not tightened, and a command that
   writes the tightened reference.
3. A worse value that is accepted only with a named decision (exception, trade-off).
4. Keys that depend on the host (fonts) judged only where the declared conditions hold, and
   insufficient evidence elsewhere.
5. A relative tolerance per key.

The second consumer is `uxui`: its assessor `ux-static@1` already writes `ratchet-evidence/1`
documents, and nothing reads them.

## Done when

Every epic that decomposes this initiative is implemented, and the first consumer's loop runs on
`ratchet` with no comparator of its own.

## Releases

- 0.1.0: consumer gap 1 end to end (observe, adopt a gate, reject a regression with the evidence
  named), with the command that writes a tightened reference (part of gap 2) and a percent
  tolerance per key (part of gap 5). Epics `runnable-cli`, `observe-adopt-reject`,
  `first-consumer-ui-loop`, `release-line`.
- Later releases: `improvement-and-policy` (the rest of gap 2: the fail when a better value was
  not adopted; gap 3; the rounding rule of gap 5), then the integrations `generated-artifact`,
  `ci-turnaround` (consumer gap 4), `analyzer-findings`, `ess-ui-behavior`.
