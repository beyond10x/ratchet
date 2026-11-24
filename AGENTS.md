# AGENTS.md — ratchet

Ratchet specifies how to specify software quality: a versioned YAML format (`ratchet/1`), a CLI, a
preset catalog and assessors, aimed at regression prevention. Vision: `vision.md`. Design:
`docs/design.md`.

Organization-wide rules live in the workspace `AGENTS.md` (`~/beyond10x/AGENTS.md`); this file adds
what is specific to ratchet.

## Phase: design

The repository is in the design phase.

- No planning ahead: no epics, stories or tasks in the store until Timo opens implementation
  planning. Timo, 2026-11-23: "do not do any planning ahead … we're just in the design phase".
- No implementation code yet. Changes go to `docs/design.md`, `vision.md`, `research/`,
  `website/` and this file.
- Survey answers arrive through the operator session of `~/.claude/CLAUDE.md` § Host operator.
  An answer about work outside beyond10x names nothing of that work (`research/README.md`
  § Confidentiality); check every answer against that list before committing it.
- Field names, document shapes and CLI commands in `docs/design.md` are proposals. Do not cite
  them as settled.

## Ownership

| path | what |
|---|---|
| `vision.md` | why Ratchet exists, its outcomes and what it does not do |
| `docs/design.md` | the design proposal: domain language, YAML shapes, CLI, records, ESS integration |
| `research/` | surveys and their answers, `synthesis.md`, `candidate-presets.md`, consumer input; confidentiality rules in `research/README.md` |
| `.engineering/` | AEP planning store (`aep.project/5`, profile `development.standard`), no artifacts yet |
| `website/` | the public documentation site at `https://beyond10x.github.io/ratchet/` (Docusaurus on `@beyond10x/docs-system`, pinned by commit in `package.json`). Its docs pages are `vision.md`, `docs/design.md`, `research/*.md` and `research/responses/*.md`, read in place; `docusaurus.config.ts` gives each its route, title and header (`pages`), the files stay unchanged. `product.json` is the landing page, drawn by `src/pages/index.tsx` (not withProductSite's `landing` option, which ships the build machine's path in the bundle). `.npmrc` sets `allow-git=root`: npm 12 otherwise refuses the Git-pinned dependency. A new file in `research/` (other than `responses/`) needs an entry in `pages` and in `sidebars.ts`; a new file in `docs/` also needs an `include` pattern. A Markdown link to a file the site does not publish fails the build, so link such files by GitHub URL |
| `.github/workflows/pages.yml` | `Documentation validation`: classifies the changed files (`.engineering/` and `*.md` outside `website/`, `vision.md`, `docs/`, `research/` are planning: the job ends green without building), builds the site, refuses a machine path in it, writes `.well-known/b10x-site.json` and on `main` uploads the artifact `b10x-project-site`. A new site source goes into its path list with a case in `task check:ci-paths` |
| `.github/workflows/b10x-docs-site.yml` | publishes that artifact to GitHub Pages through `beyond10x/website`'s `project-site.yml`, pinned by commit, for bot-authored pushes to `main` |
| `.github/workflows/shared-gates.yml` | the organization's shared source gates (`beyond10x/gates`, pinned by commit) |
| `Taskfile.yml` | `task check`: the repository gate; `task site`: build the site |

## Domain language

Use the terms of `docs/design.md` § 1 with those meanings: subject, audience, quality
specification, quality requirement, measurement, measurement kind (exact, sampled), scope,
identity set, assessment plan, assessor, target, evidence coverage, protected reference
(generated, accepted value), gate, ratchet policy, exception, trade-off. A gate verdict is one of
pass, fail, insufficient evidence.

## Boundary

- Ratchet runs or imports existing tools (analyzers, browsers, load runners, CI, telemetry); it
  does not reimplement them.
- ESS owns conformance scenarios and ESS UI interactions; Ratchet imports their reports
  (`docs/design.md` § 7).
- AEP owns the planning store; Ratchet records quality evidence, not plan state.

## Gate

`task check` runs `aep plan artifact validate`, `task check:ci-paths` (the cases of the change
classifier in `pages.yml`) and `task site` (`npm ci` and `npm run build` in `website/`, the build
CI runs). Run it as `slot task check`. Edit the store only through `aep plan artifact`.

## Commits

Every commit and push is `b10x-bot[bot]`'s through `b10x-gates bot -- <git command>`; every other
GitHub write goes through `b10x-gates api`, with `--policy ../gates-policy/policy.json` from the
primary checkout. Every commit has a body.

## Never

- Write Python for anything committed (workspace `AGENTS.md` § No Python for permanent tools).
- Hand-edit a `status`, `revision` or `transitions` field under `.engineering/planning/`.
