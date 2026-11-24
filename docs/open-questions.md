# Open questions: options and a default for each

Status: recommendations, 2026-11-24. Nothing here is decided. Each default is a recommendation
that awaits the owner; until the owner answers, the six questions of
[product-brainstorm.md](product-brainstorm.md) § 10 stay open.

Citations: `F<n>` and implication numbers are in `research/synthesis.md`; `design § n` is
`docs/design.md`; `brainstorm § n` is `docs/product-brainstorm.md`; `id Xn` is question `Xn` of
`research/responses/<id>.md`. A path that starts with a repository name (`slot/docs/design.md`) is
a file of that beyond10x repository, read from its local checkout on 2026-11-24.

## Defaults at a glance

| Question | Default | Option |
| --- | --- | --- |
| Q1 config format | A | YAML for the specification, TOML for the local config |
| Q2 local config and gates | A | Never: a gate reads no local skip |
| Q3 record store | C | Both: CI artifact as hand-over, git ref as the series |
| Q4 UI | A | Static export first |
| Q5 preset catalog | A | A directory in this repository |
| Q6 cross-repository view | B | A consumer of Ratchet's records |

Q2 depends on Q1 (it names the local file). Q4 and Q6 read what Q3 stores: with Q3 answered B,
the export of Q4 and the consumer of Q6 read CI artifacts and lose history past their retention.

## Q1. TOML for the local config, YAML for the specification: two formats, or one?

| | Does | Costs |
| --- | --- | --- |
| A | YAML for the specification (`ratchet.yaml`), TOML for the local config (`ratchet.toml`) | Two parsers and two schemas. An author has to know which file takes which key. |
| B | TOML for both | Rewrites every shape of design § 3 and the consumer's draft `ux-ui/presets/web-ux.ratchet.yaml`. The specification nests up to 6 levels (`assessments.test-step-time.observation.conditions.host_load_per_cpu.max`) and mixes names and maps in one list (`gates.merge.requires`). The vision says "One versioned YAML format". |
| C | YAML for both (`ratchet.local.yaml`) | One parser. Drops the owner's TOML idea. A local file that looks like the policy file invites policy keys in it. |

**Default: A.** The file type then shows the authority: YAML is policy, judged from the trusted
revision; TOML is per machine and carries none (brainstorm § 2, design § 5). Most siblings split
the same way: specification documents in YAML (`inbox/ess/ess-inputs.yaml`,
`loom/ess/commission/system.yaml`, `.engineering/project.yaml`), tool settings in TOML
(`worktree/profiles/default.toml`, `conductor/b10x.toml`, `.slot.toml` in `slot/docs/design.md`
§ 4 and § 10).

The split is not uniform: `spindle/conformance.toml` is a versioned document in TOML, and
`conductor/conductor.example.yaml` is a host config in YAML.

What would change the answer:

- The local file needs nested structures, such as an override per requirement with its own
  conditions: then C.
- The ESS generators load one of the two formats and not the other (AGENTS.md § Specification
  first): then that format for both. I did not check which document loaders `ess generate` emits.

## Q2. Can a local TOML ever affect a gate, for example on a developer's pre-push?

| | Does | Costs |
| --- | --- | --- |
| A | Never. `ratchet evaluate --gate` reads no `[local]` key. A pre-push gate is declared in the specification like any other, for example `stage: pre-push` with exact checks only and `qualifying_environments: [local]`. | A developer cannot relieve a slow or broken pre-push check without a change to the specification, or without skipping the hook. |
| B | Local stages only. `[local]` may skip or downgrade a requirement of a gate that runs on a developer machine; the result says "skipped locally"; merge and promotion gates ignore the file. | One gate name means different things on two machines (F10). A skipped requirement that lets a push through is a pass under another name. |
| C | Any gate, with a mark in the report. | The candidate's checkout loosens what it is judged by. Vision outcome 5 and design § 5 rule 2 no longer hold. |

**Default: A.** "A candidate's gate uses policy from a trusted revision" (design § 5); in 3
answers the candidate could change the value it was judged by (F7, first row). A sibling states
the same rule: "Candidate ignore files and comments cannot override organization rules"
(`gates/AGENTS.md` § Contract).

What A leaves to the TOML, and what follows from it:

- `[local]` selects what `ratchet assess` and `ratchet status` run on this machine. A requirement
  skipped that way reaches a gate as not run, which is insufficient evidence and not a pass
  (design § 3: "It is not left out of the list, and the run does not exit 0").
- Outside environment class `local`, `ratchet evaluate` refuses a config that carries `[local]`
  skips and names the key; it does not ignore them. 12 answers describe good quality as a system
  that "refuses in place of a silent downgrade" (F17, third row). This answers the open point of
  brainstorm § 2.
- A loaded host needs no local skip in a gate: sampled evidence outside the declared conditions
  is already insufficient evidence (design § 3).

What would change the answer:

- Measured bypass: developers or agents skip the pre-push hook because one requirement cannot be
  relieved locally. A marked skip (B) then keeps more checks running than no hook.
- Pre-push is not a gate at all, only `ratchet assess` on exact checks: then the question does not
  arise.

## Q3. Record store: git ref, CI artifacts, or both?

Assumed, not decided: reference records are files in the tree. Design § 5 rule 1 reads the copy
on the trusted revision and rule 4 has the candidate adopt a better value "in the same change"; 8
answers commit the new value with the change and 4 compare with the copy on `main` (F6). Rule 6
also allows "with the Ratchet records". If references live there, the store needs a rule for who
may write them. The options below are about assessment runs and gate decisions.

| | Does | Costs |
| --- | --- | --- |
| A | Git ref only. Every run pushes its records to `refs/ratchet/records`. | Every job needs push rights, pull-request jobs included. Concurrent pushes race on a busy repository. The ref grows without a bound. |
| B | CI artifacts only. `ratchet import` builds a series from them when asked. | No new write path. The series ends at the forge's artifact retention. Reading needs the forge API and a token, so a local gate cannot read what CI reads (F10). A local run leaves no record. |
| C | Both, one role each. A run hands over its records as a CI artifact. One job on the trusted branch appends them to `refs/ratchet/records`. Gates and views read the ref. | One writer with push rights to one ref; its commits need an author the organization's commit check admits (`gates/README.md`, commit authorship). Two places to explain. |

**Default: C.** No answer keeps a series of CI duration or queue wait (F11, 0 of 26), so the
store has to outlive artifact retention, and it has to be "Stored where the gate can read it"
(design § 5 rule 6). With a ref, `git fetch` gives the local gate the records CI reads
(`~/beyond10x/AGENTS.md` § The local gate equals the forge; F10, 14 answers). One writer keeps
pull-request jobs without push rights. A tool-owned ref namespace has a precedent:
`refs/takt/candidates/<case>` (`takt/README.md`).

C can be built in two steps. The artifact half needs nothing new and matches design § 6 ("Start
with versioned JSON records and CI artifacts"); the ref follows with the first requirement that
needs a series.

What would change the answer:

- No CI job gets push rights. That is a decision about credentials and rulesets, which is the
  owner's alone: then B, with the retention limit reported by `ratchet doctor`.
- A project has no CI, or one machine: then A with the local run as the writer.
- The ref becomes a cost for every clone. Not measured; no record exists yet to size one. Then the
  series moves to the service row of brainstorm § 6.

## Q4. Is the UI a static export first, or a served app first?

| | Does | Costs |
| --- | --- | --- |
| A | Static export first. `ratchet render` writes one HTML page and its JSON data from the records: a CI artifact, a committed file or a page of the docs site. | No live refresh. Filters and history depth are fixed at export. A committed page goes stale without `ratchet render --check`. |
| B | Served app first. `ratchet serve` answers queries over the record store. | A process and a port per repository on a shared host. Nothing to show in CI or on the docs site until a second form exists. Needs the local index of brainstorm § 6 first. |
| C | Both at once, from one page and one data document. | The most work before the first verdict is visible. |

**Default: A.** Ratchet has no daemon. Two siblings with a served view serve it from a daemon
they already run (`slot serve`, `slot/docs/design.md` § 10; `conductor daemon serve`,
`conductor/README.md`). The public docs path packages declared files and "must never run
repository code" (`gates/AGENTS.md` § Public documentation operations), so the docs-site form of
brainstorm § 5 is a static file in any case. The vision excludes "a database or dashboard first".
Static forms are in use: a generated trend page in the repository (ext-04 B7), an HTML dashboard
as a CI artifact (ext-07 B7), a progress page written by a command with a staleness check
(runbook B7).

Before either form: `ratchet status` in the terminal, because the coding agent is the main reader
(implication 16). A later `ratchet serve` shows the same page over the same JSON, so A does not
close B.

What would change the answer:

- A person has to query a long history by requirement, environment and time, and a fixed export
  does not cover it.
- The local index gets built first to make `status` and `history` fast. `serve` is then a small
  step and C costs little more than A.

## Q5. Is the preset catalog a separate repository (`ratchet-presets`) or a directory here?

| | Does | Costs |
| --- | --- | --- |
| A | A directory here (`presets/`), released with the format and the CLI. | A preset fix waits for a release of this repository. Every contributed preset passes this repository's gate. |
| B | A separate repository `ratchet-presets`, pinned by commit. | A second gate, release and docs manifest. A format change is two coordinated pull requests while `ratchet/1` is a proposal. The pins of the two repositories drift. |
| C | No central catalog. Each consumer keeps its presets, as `ux-ui/presets/web-ux.ratchet.yaml` does; Ratchet ships examples. | The duplication a catalog removes stays: one UI loop exists "7 times in 3 languages" (F6; ux-ui Notes). |

**Default: A.** The format is a proposal (AGENTS.md § Phase: design) and shows no syntax yet for
binding a preset or declaring its inputs (`research/candidate-presets.md` § 6 item 1). Until it
does, a preset and the schema it instantiates have to change in one commit under one gate. A
split sibling shows the drift: `connectors-definitions/toolchain.json` pins ESS 0.75.0,
`connectors/crates/connectors-spec/toolchain.json` pins 0.87.0.

Under A the catalog entry of `ratchet.toml` stays a source with a commit (brainstorm § 2). A
consumer's own family, such as `web-ux@1` in `ux-ui`, resolves the same way, and a later split is
a file move and a changed source.

What would change the answer:

- `ratchet/1` is declared stable and presets change more often than the CLI. Measure: releases
  that change only presets.
- Presets become data that many contributors add with no build, the reason
  `connectors-definitions` is apart ("a YAML change, with no Rust build",
  `connectors-definitions/AGENTS.md` § Serves): then B.
- A preset carries content that must not be in a public repository, the reason `gates-policy` is
  apart from `gates` (`gates/AGENTS.md` § Contract): then B for those presets.

## Q6. Is the cross-repository view part of Ratchet, or a consumer of its records?

| | Does | Costs |
| --- | --- | --- |
| A | Part of Ratchet. The CLI gains a shared index and views across repositories. | A shared index or service in a tool whose vision excludes "a database or dashboard first". Credentials for many repositories. Ratchet starts to own a list of repositories. |
| B | A consumer of the records. Ratchet publishes a versioned record format and an export per repository; another project aggregates. | The questions of brainstorm § 8 wait for that consumer. The record format is a public contract from its first release. |
| C | A thin command here over several stores, with no index; anything more is a consumer. | Slow over many repositories. No history across them. One more surface to keep. |

**Default: B.** The view needs a shared record index, which comes after the store per repository
(brainstorm § 8), and the vision keeps a database out of the first scope. The list of
repositories has an owner already: `atlas/catalog/store` is "the canonical organization
inventory" (`atlas/AGENTS.md` § Operating Atlas). Docs aggregation is built the same way: each
repository declares, another project collects ("Atlas owns delivery and routing, repositories own
source and presentation fields", header of `ess/b10x.docs.yaml`).

This names no consumer. Which project aggregates is a separate question.

What would change the answer:

- A verdict needs records of other repositories. The nearest case, host load from every
  repository's jobs (F1, F2: 16 answers), reads one log of the build pool (slot B7) and no other
  repository's records, so it stays an assessor.
- A preset's default has to be set from its results across repositories (brainstorm § 8, second
  item). That comparison is then a function of the catalog, and A or C for that one view.
