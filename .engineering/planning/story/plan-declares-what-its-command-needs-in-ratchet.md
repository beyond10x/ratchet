---
format: aep.planning-md/3
id: story:plan-declares-what-its-command-needs-in-ratchet
kind: story
status: draft
title: ratchet assess does not start a command whose declared need is missing
summary: 'The command part of story:plan-declares-what-its-command-needs: not_assessable_here naming the need, and a billed run named by explain.'
relations:
- decomposes: epic:format-gaps-first-format-consumer
- depends_on: story:plan-declares-what-its-command-needs
- depends_on: story:cli-skeleton-validate
- depends_on: story:assess-command
scope:
- confidence: inferred
  path: crates/ratchet-core
- confidence: inferred
  path: crates/ratchet/src/commands/assess.rs
- confidence: inferred
  path: crates/ratchet/src/commands/explain.rs
revision: 4
---
## Context

Split on 2026-11-26 from `story:plan-declares-what-its-command-needs`, which declares
`ratchet.specification.CommandNeeds` (`environment`, `files`, `billed`) as the member `needs`
of `ratchet.specification.ObservationPlan` and writes into `docs/design.md` § 3 and § 5 that a
machine that lacks a need reports the requirement as not run there. This story holds the part
that needs the `ratchet` command.

## Acceptance

1. `ratchet assess` in a fixture whose plan declares `needs: {environment: [PROVIDER_TOKEN]}`,
   run with that variable unset, does not start the command (a stand-in command that writes a
   marker file leaves none), records the plan's requirement as insufficient evidence with the
   cause `not_assessable_here` and a message that names `PROVIDER_TOKEN`, and exits as for an
   insufficient result; with the variable set the command starts. The same for a path under
   `files` that does not exist.
2. `ratchet explain <requirement>` on a requirement whose plan declares `billed: true` prints
   that a run is billed.

## Notes

- Moved from the acceptance of `story:plan-declares-what-its-command-needs`.
- The value of an environment variable is never read into a record or a message: the test
  checks that the record holds the name and not the value.
- The story is a draft. It waits for the waves to 0.1.0: `story:cli-skeleton-validate` and
  `story:assess-command`.
