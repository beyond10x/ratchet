# Ratchet beyond the specification: brainstorm

Status: brainstorm, 2026-11-24. Nothing here is decided. It answers the owner's question "what is
Ratchet beyond the specification?" and starts from his ideas: a binary `ratchet`, a local TOML
config that points at specs and metric settings and can ignore one, validation of the quality
gates, and a UI that shows each gate, what it means, its latest evaluation, when it was last
checked, and its history.

Citations: `F<n>` and implication numbers are in `research/synthesis.md`; `§ n` is
`docs/design.md`.

## 1. The product in six parts

| Part | What it is | From |
|---|---|---|
| Specification | `ratchet/1` YAML: requirements, plans, gates, references, exceptions | design § 1–5 |
| `ratchet` binary | validate, assess, evaluate, propose, prove, render, show | the owner; design § 5 |
| Local config | `ratchet.toml`: where specs, presets, records and tools are; local choices | the owner |
| Record store | assessment runs, gate decisions, reference changes, exceptions over time | design § 6; F11 |
| Views | a web UI and a terminal view of requirements, meaning, verdicts, history | the owner; design § 6 |
| Integrations | CI, pre-push, the build pool, agents (skill, MCP), the docs site | F3, F10; implication 16 |

## 2. Two files with different authority

The specification (`ratchet.yaml`, committed) is policy. A candidate is judged by the copy on the
trusted revision (§ 5). The local config (`ratchet.toml`) is per machine or per checkout and
carries no policy.

That draws a line through "ignore a certain one":

- **Locally**, the TOML may skip or downgrade a requirement for a run: skip sampled measurements
  on a loaded host, run only exact checks before a push, mark a requirement observe-only while
  working on it. The report then says "skipped locally by ratchet.toml", never "pass".
- **In a gate**, the TOML cannot ignore anything. A requirement leaves a gate only through the
  specification: an exception with a reason, an owner reference and an expiry (§ 5, F12), or
  report mode with the date since which it is unenforced (F8).
- `ratchet evaluate` in CI could refuse to run with a local TOML that contains skips, or ignore
  that section. Open question.

Candidate `ratchet.toml` content:

```toml
[spec]
paths = ["ratchet.yaml", "quality/*.ratchet.yaml"]

[catalog]
presets = ["git+https://github.com/beyond10x/ratchet-presets#<commit>"]

[records]
store = "git:refs/ratchet/records"

[environment]
class = "local"

[local]
skip_sampled_when_load_above = 0.8
observe_only = ["search-latency-budget"]

[tools]
nextest = "cargo nextest"
```

The values are illustrations. `store`, `class` and the skip rule are the parts with design
weight.

## 3. The `ratchet` binary

Built specification first (AGENTS.md § Specification first): the nouns below are declared in ESS
before any code, the command surface is an `ess-cli/2` binding, and `ess generate cli` and
`ess generate synthesize` produce the parser, adapter and boilerplate.

From the design (§ 5): `init`, `validate`, `assess`, `evaluate`, `reference propose`, `prove`,
`render`. Added here:

| Command | What it answers | Why |
|---|---|---|
| `ratchet status` | Every requirement: verdict, value against limit or reference, last checked, by which run, in which environment | the owner's "last checked"; F11 |
| `ratchet explain <req>` | What it means in plain words, which audience cares, how it is measured, where the evidence is | the owner's "described and their meaning"; E1 |
| `ratchet history <req>` | The series with the reference line, reference changes and exceptions marked | the owner's "over time"; § 6 |
| `ratchet diff` | Candidate against reference, item by item: new findings, lost passing cases | F7, F9 |
| `ratchet doctor` | Config, specs, tools, record store reachable; sampled plans without conditions | F10 |
| `ratchet import` | Pull history that exists elsewhere: forge runs, build-pool job logs, JUnit files | F11; slot B7 |
| `ratchet exceptions` | Active, expiring and expired exceptions | F12 |
| `ratchet serve` | The web UI over the record store | the owner |

Every non-pass result names its cause and the next step: what to fix or which evidence to
recover (§ 5). The coding agent is the main reader of that output (implication 16).

## 4. Validation, in layers

The owner's "validate our gates and the specs for them" splits into four checks of increasing cost:

1. **Shape.** The YAML matches the schema; references resolve; units and kinds agree.
   `ratchet validate`, no I/O beyond the files.
2. **Completeness.** Every sampled plan declares conditions; every exception has a reason, an
   owner and an expiry; every requirement belongs to a gate or is observe-only on purpose.
3. **Sensitivity.** The check can fail: planted defects are refused (`ratchet prove`, F15). A
   requirement with no proof and no recorded fail shows as "unproven".
4. **Meaning.** Each plain-language quality statement of the project maps to requirements, and
   each statement that no requirement checks shows as "not machine-checked". 23 answers named a
   part of quality a machine cannot check (F17); the UI should show that gap, not hide it.

## 5. The UI

One page per project. Rows are requirements, grouped by the plain-language statement they serve
and by audience.

Per requirement:

- name, plain-language meaning, audience
- verdict: pass, fail, insufficient evidence (with cause), skipped locally
- value against its limit or reference, with unit and kind (exact or sampled)
- last checked: time, run, environment class, revision
- sparkline of the series, the reference line, marks for reference changes and exceptions
- coverage of the last run: executed, skipped, unsupported
- proof status: proven, unproven
- open exception and days until expiry

Project-level views:

- gate decisions over time
- time to first verdict, split into queue wait and run time (F2, F3)
- statements not machine-checked
- expiring exceptions, stale references, unproven checks

The same data serves three forms: `ratchet serve` (local), a static export as a CI artifact, and
a page on the public docs site. A terminal form (`ratchet status`) covers the agent and the
person without a browser.

## 6. Where the records live

F11: 0 of 26 answers keep a series of CI duration or queue wait; 16 copy numbers into prose. The
store has to survive outside one run and one machine. Options:

| Option | For | Against |
|---|---|---|
| A git ref in the repository (`refs/ratchet/records`) | travels with the repo, no service | grows; CI needs push rights |
| CI artifacts, indexed by `ratchet import` | no new write path | retention limits; slow to query |
| A records directory on a branch | readable in the forge | merge conflicts on busy repos |
| A small service (later) | cross-repo views | a service to run |

The design says "versioned JSON records first, a database later" (§ 6). A local SQLite index
over the JSON records would make `status`, `history` and `serve` fast without changing the
source of truth.

## 7. Integrations

- **CI:** a step that runs `ratchet evaluate` and writes the report as a check summary; the
  required check is the gate.
- **Pre-push:** exact checks only; sampled checks stay in CI or run as observe-only locally
  (F2, F10).
- **Build pool:** read queue wait and run time per job from the pool's log (slot `jobs.jsonl`)
  so a host-caused timeout becomes insufficient evidence (F2, slot B2).
- **Agents:** a skill and an MCP server: `status`, `explain`, `diff` as tools. The agent reads
  the next step from a non-pass verdict.
- **Docs:** `ratchet render` keeps numbers in README, AGENTS.md and the site generated from
  records (F11, F14; surf D1).
- **Planning:** a fail or an expired exception could become a draft story through AEP. Ratchet
  owns evidence, AEP owns plan state (AGENTS.md § Boundary).

## 8. Beyond one repository

The survey covered 25 projects on one machine. Cross-repository questions follow:

- which repositories have unproven checks, expiring exceptions, gates in report mode
- one preset version used across many repositories, and its results compared
- the cost of host load across all repositories at once (F1: 16 answers had false reds from
  load)

This needs a shared record index, so it comes after the per-repository store.

## 9. Dogfooding

Ratchet's own repository is gated by Ratchet from its first release: test step time, generated
files, docs numbers rendered from records. It is the first place the UI shows real data.

## 10. Open questions

Options, a recommended default and what would change it, per question:
[open-questions.md](open-questions.md). Recommendations only; they await the owner.

1. TOML for the local config, YAML for the specification: two formats, or TOML for both?
2. Can a local TOML ever affect a gate, for example on a developer's pre-push?
3. Record store: git ref, CI artifacts, or both?
4. Is the UI a static export first, or a served app first?
5. Is the preset catalog a separate repository (`ratchet-presets`) or a directory here?
6. Is the cross-repository view part of Ratchet, or a consumer of its records?
