# Vision

Quality stops going backwards once it is written down, measured and enforced by the same
declaration.

## Problem

A project's quality bar lives in scattered places: a lint config, a benchmark someone runs by hand,
a CI duration nobody watches, a dashboard with an SLO. Each tool has its own threshold format and
its own idea of a baseline. A regression slips through when no gate compares it, when a total count
hides a new violation behind an unrelated fix, or when a tolerance is re-applied on every merge.

## What Ratchet is

One versioned YAML format that states, per project:

- **what** is assessed (subject) and **for whom** (audience);
- **what must hold** (requirement);
- **how we know** (assessment plan: assessor, target, observation conditions);
- **when it is enforced** (gate at a workflow stage);
- **when it may tighten** (ratchet policy over a protected reference).

The same format serves a developer, a coding agent and CI. Presets use the same schema as a
project's own checks, so a custom measurement joins gates and history from its first run.

## Outcomes

1. **Regression prevention.** A candidate worse than the protected reference fails, with the
   requirement, the observed and allowed values, and pointers to the evidence.
2. **Brownfield adoption.** A team starts in observe mode, measures what is there, and turns
   selected findings into enforced requirements.
3. **Honest verdicts.** Too few samples, a stale window or an incompatible target is
   **insufficient evidence**, never a pass.
4. **Recorded improvement.** A better result adopted as the new reference records the previous
   value, the supporting evidence and the decision that authorized it.
5. **Policy from a trusted revision.** A candidate cannot loosen the thresholds it is judged by.

## First milestone

A project that starts in observe mode, adopts a gate, rejects a regression with actionable
evidence, and records an improvement as a new protected reference, across three integrations:
ESS UI behavior, CI turnaround, and no new findings from an existing analyzer
([docs/design.md](docs/design.md) § 7).

## Not in scope

- Replacing analyzers, load runners, browsers or telemetry: Ratchet runs or imports them.
- A database or dashboard first: versioned JSON records come first, indexes later.
