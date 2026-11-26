---
format: aep.planning-md/3
id: story:plan-declares-what-its-command-needs
kind: story
status: implemented
title: A plan declares what its command needs before it runs
summary: A credential, an environment variable or a device by name, and whether a run is billed; a machine that lacks one is not assessable there.
relations:
- decomposes: epic:format-gaps-first-format-consumer
scope:
- confidence: cited
  path: docs/design.md
- confidence: cited
  path: spec/domains/specification.yaml
- confidence: cited
  path: spec/presets.test.sh
revision: 17
transitions:
- {from: "draft", to: "proposed", at: "2026-11-26T21:04:23Z", actor: "human:operator", revision: 15, decided_on: {"recorded":{"review_outcome":4}}}
- {from: "proposed", to: "active", at: "2026-11-26T21:04:24Z", actor: "human:operator", revision: 16, decided_on: {"recorded":{"review_outcome":4}}}
- {from: "active", to: "implemented", at: "2026-11-26T23:39:03Z", actor: "human:operator", revision: 17, decided_on: {"recorded":{"test_result":1,"review_outcome":4}}}
---
## Context

The repository `beyond10x/inference` wrote the second unit of its quality definition against
the formats at commit `f139ecc` (2026-11-25): measures per adapter, and latency defined
without a number. It is the first consumer of the formats outside this repository and of this
story. An adversary pass of the consumer read the finding against the specification at that
commit. Line numbers below are those of `7b01ea1`.

Finding 22. An observation has one `command` and nothing for what the command needs before it
can run (`ratchet.specification.ObservationPlan`, `spec/domains/specification.yaml:468-531`,
`command` at `:498-500`): a credential, environment variables, a device, or the fact that a
provider bills the run. A machine that lacks one of them starts the command and gets a failed
run, which reads as a failed measurement. The design already has the verdict for a location that
cannot assess a requirement: insufficient evidence with the cause `not_assessable_here`
(`docs/design.md:78`), used today for a required local input with no value on the machine
(`docs/design.md:728`, § 5 "Local config", rule 6). `story:machine-as-a-condition` (20 of the
wave) declares the machine a sampled measurement depends on; this finding is about what a run
needs to start at all.

The decision this story takes, the reversible one (`AGENTS.md` § "Phase: implementation"): a
member `needs` of `ObservationPlan`, a struct `ratchet.specification.CommandNeeds` with
`environment` (names of environment variables that must be set, a credential among them),
`files` (paths that must exist before the run, a device file such as `/dev/kfd` or a credential
file among them) and `billed` (a run costs money at a provider). A need is written by name and
never by value: the file holds no secret, and a value would differ per machine. A plan whose
command needs a credential with a value in the specification is what the design refuses for a
local input (`local_input_in_specification`), and the same reason holds here.

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

Neither `CommandNeeds` nor a key `needs:` occurs in `spec/domains/specification.yaml`,
`docs/design.md` or `spec/presets.test.sh` at `7b01ea1`.

1. `spec/domains/specification.yaml` declares the struct `ratchet.specification.CommandNeeds`
   with `environment` (`Optional<List<String>>`), `files` (`Optional<List<String>>`) and
   `billed` (`Optional<Boolean>`, absent means `false`). Check: `grep -c 'name:
   ratchet.specification.CommandNeeds$' spec/domains/specification.yaml` prints 1; `ess
   specify validate --path spec --strict-requires` exits 0 and `task check:generated` passes.
2. `ratchet.specification.ObservationPlan` has the member `needs`
   (`Optional<ratchet.specification.CommandNeeds>`). Check: `grep -c 'type:
   Optional<ratchet.specification.CommandNeeds>' spec/domains/specification.yaml` prints 1.
3. The summary of `ObservationPlan.needs` holds the phrase "a run on a machine that lacks a
   need does not start" and names the cause `not_assessable_here`. Check: `grep -F` of that
   phrase in `spec/domains/specification.yaml` finds one line.
4. `spec/presets.test.sh`, rule `place`: the accepted copy `valid-inputs` states `needs:
   {environment: [PROVIDER_TOKEN], billed: true}` under `observation` and is accepted, with no
   change of the script's code and no new copy. Check: `grep -c 'needs: {environment:
   \[PROVIDER_TOKEN\], billed: true}' spec/presets.test.sh` prints 1 and `sh
   spec/presets.test.sh` exits 0; the same copy against the specification of `7b01ea1` is
   refused, because `needs` is no declared field of `ObservationPlan` there.
5. `docs/design.md` § 3, the paragraph of the target classes that opens "The local gate and CI
   are different targets": a plan declares what its command needs by name, `ratchet assess`
   checks each need before it starts the command, and a machine that lacks one reports the
   requirement as not run there, with the cause `not_assessable_here` and the name of the need.
   Check: `grep '^The local gate and CI are different targets' docs/design.md | grep -c
   'needs'` prints 1 (0 before).
6. `docs/design.md` names a billed run: `ratchet explain` and `ratchet assess` name it, and
   only `[local] skip` leaves it out of a machine's runs, as any assessment (§ 5 "Local config",
   rule 1). Check: `grep -c 'billed' docs/design.md` prints a number above 0 (0 before).
7. `docs/design.md` § 5 "Local config", rule 6: beside the bullet "A required local input with
   no value on this machine makes the requirement not assessable there", a bullet names a
   missing need of the plan as the second case of `not_assessable_here`. Check: `awk '/^###
   Local config$/,/^### Proposed CLI$/' docs/design.md | grep -c 'need'` prints a number above
   0 (0 before).

## Notes

- Decision taken: one member `needs` with three lists and a flag (§ Context). A need with a
  value, such as an expected version of a driver, is a condition (`story:machine-as-a-condition`)
  and not a need.
- An addition to a released format: a file written before the change stays valid.
- The command part, `ratchet assess` not starting the command on a machine that lacks a need and
  recording the requirement as `not_assessable_here` with the name of the need, and
  `ratchet explain` naming a billed run, is `story:plan-declares-what-its-command-needs-in-ratchet`,
  which waits for the waves to 0.1.0 (`story:cli-skeleton-validate`, `story:assess-command`).
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of `.engineering/waves/0.1.0-ahead-2.md`,
  into one wave built in sequence on one branch: every planned wave starts behind
  `story:cli-skeleton-validate`, which waits for a release of ESS (beyond10x/ess#836), and this
  part needs no `ratchet` command. It is 24 of the 33 in the order of that page. Before it,
  `story:machine-as-a-condition` (20) and `story:plan-conditions-from-binding` (21) change the
  conditions of `ObservationPlan`, and `story:input-allowed-values` (23) the bullet "Inputs" of
  § 4. After it, `story:plan-never-assessed` (25) adds a member to
  `ratchet.specification.AssessmentPlan` and writes into § 5 "Gate modes".
- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s; the copy
  `valid-inputs` is timed before and after its edit.
