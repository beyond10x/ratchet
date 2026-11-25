# AGENTS.md — ratchet

Ratchet specifies how to specify software quality: a versioned YAML format (`ratchet/1`), a CLI, a
preset catalog and assessors, aimed at regression prevention. Vision: `vision.md`. Design:
`docs/design.md`.

Organization-wide rules live in the workspace `AGENTS.md` (`~/beyond10x/AGENTS.md`); this file adds
what is specific to ratchet.

## Phase: implementation

The design phase ran from 2026-11-23 ("do not do any planning ahead … we're just in the design
phase", the owner) to 2026-11-24. It held no stories and no code "until the owner opens
implementation planning".

The owner, 2026-11-24 about 13:05 CET: "So what about beyond 10x [ratchet]? Why isn't any work
being done there? I think we could also cut a release there probably." And after 13:25 CET: "make
sure we have progress in b10x: ratchet+uiux+llm+inference So please bring back those Claude Code
sessions. [...] make sure they are building stuff and they have a plan and the vision, a
trajectory, a direction."

A reading by the operator session of `~/.claude/CLAUDE.md` § Host operator, not the owner's word:
these two messages open implementation planning, so the design phase ends with them.

- § "Specification first (ESS)" applies to every change from 2026-11-24 on.
- Epics and stories live in the AEP store (`.engineering/planning/`). `ROADMAP.md` is the
  trajectory: the first consumer, the next waves by story id, and what the next release holds.
  Update it in the change that closes a wave.
- Goal first (workspace `AGENTS.md`): the waves are ordered by the first consumer's first gap,
  named in `ROADMAP.md`. Each wave report names the consumer gap it moved, or says "none".
- Field names, document shapes and CLI commands in `docs/design.md` stay proposals until a release
  ships them. A story that needs an open one (`UNMAPPED:` in `spec/`, a default-A question of the
  design) takes the reversible answer, writes it into the design and the specification in the same
  change, and reports it as a decision taken. A fork in the architecture goes to the operator
  session with options.
- Survey answers arrive through the operator session of `~/.claude/CLAUDE.md` § Host operator.
  An answer about work outside beyond10x names nothing of that work (`research/README.md`
  § Confidentiality); check every answer against that list before committing it.

## Specification first (ESS)

The owner, 2026-11-24: "when you're building this tool, the CLI tool, remember, just do ESS upfront.
So we specify stuff before we're building it … There's also a CLI spec for the CLI surface, which
you should utilize, and then you should use the ESS synthesizer to actually build the boilerplate".

- Every noun Ratchet introduces (requirement, measurement, reference, record, exception, …) is
  declared in an ESS specification before code that uses it exists; `ess specify validate`
  passes first.
- The `ratchet` command surface is declared as an `ess-cli/2` presentation binding (ESS
  `docs/design/cli-presentation-binding.md`); the parser and process adapter come from
  `ess generate cli`, not by hand.
- Other boilerplate comes from `ess generate synthesize`; generated files are never edited by
  hand and are checked for drift in the gate.
- In force since 2026-11-24 (§ "Phase: implementation").

## Ownership

| path | what |
|---|---|
| `vision.md` | why Ratchet exists, its outcomes and what it does not do |
| `docs/design.md` | the design proposal: domain language, YAML shapes, CLI, records, ESS integration |
| `research/` | surveys and their answers, `synthesis.md`, `candidate-presets.md`, consumer input; confidentiality rules in `research/README.md` |
| `spec/` | ESS specification of Ratchet's nouns (`system.yaml`, `domains/`) and the `ess-cli/2` binding of the `ratchet` commands (`cli.yaml`); proposals; `UNMAPPED:` markers are open design questions; `crates/ratchet-cli-contract/` is generated from it |
| `presets/` | the preset catalog: `<name>@<version>.preset.yaml` (a `ratchet/1` preset), `<name>@<version>.assessor.yaml` (the `ratchet-assessor/1` declaration a preset names; none for `record-series@1`, the assessor of Ratchet itself, whose name is reserved), `README.md` (the rules of the catalog, the YAML forms and the characters a file may hold, how a project binds a preset) and one page per family, such as `functional.md`. No comment in a YAML file: a binding carries the digest of the file. A list is a flow list, a requirement writes out the names of its assessment, its measurement and its statements, and every line ends with a line feed. `sh spec/presets.test.sh`, a step of `check:spec`, checks every file against `spec/domains/`, each preset against the declaration of its assessor and the table "Comparisons" of `docs/design.md` § 3, and every measurement against its row on a page. A new rule of the script gets a broken copy there that is refused with the message of the rule, so the copy fails when the rule is taken out; a form that stays valid gets a copy that is accepted. The script runs under `dash` and `mawk` as under `bash` and `gawk`: it reads bytes (`LC_ALL=C`), and no awk function has the name of a parameter. Every file under it is `code` for the classifier of `pages.yml` |
| `Cargo.toml`, `Cargo.lock` | the Cargo workspace: its members are the hand-written crates (`crates/*`), and each generated crate is in `exclude` (§ "Generated crates"). `[workspace.package]` holds the one version |
| `rust-toolchain.toml` | the one pinned rustc, with `rustfmt` and `clippy`. The local gate and the CI job both read it |
| `.config/nextest.toml` | the test budget: a test is ended at 60 s, the run at 120 s, each as a failure. `.github/scripts/test-budget.test.sh` refuses a weaker value, `on-timeout`, a `grace-period` over 10 s and every form of `slow-timeout` and `global-timeout` other than `<key> = ...` on one line (dotted keys, a table of its own), so write the two that way |
| `crates/ratchet-cli-contract/` | generated by `ess generate cli` from `spec/` and `spec/cli.yaml`: the parser, the help text, the process adapter and the `Handler` seam (library `cli_contract`). Never edited; `task generate` writes it (§ "Generated crates") |
| `crates/ratchet/` | the `ratchet` binary. `src/commands/mod.rs` selects the handler by the callable of the binding from the table `BUILT`; a command that is built has its file there with one function `call` and its row in the table, and every other command shares `unbuilt`, the unavailable answer. A unit test beside the table fails when a key is no callable of the binding. `src/main.rs` answers `ratchet --version` itself (`ratchet <version of the workspace>`, exit 0; the generated parser declares no version, so `ratchet --help` does not name it) and writes the two streams: a reader of standard output that is gone ends the binary without a panic and with the exit status of the command, any other failure to write is one line on standard error and exit 1. `tests/main.rs` is the one integration-test binary: a module and a file per command, so a story that builds a command edits `src/commands/<command>.rs` and `tests/<command>.rs` and neither `mod.rs` nor `main.rs`; `tests/version.rs` and `tests/closed_pipe.rs` test what `main.rs` answers. `tests/commands.rs` lists the commands no story builds and fails when the binding declares a command it does not list |
| `.github/scripts/` | `check-generated.sh`: one line per generated crate, the drift check and the regeneration. `*.test.sh`: script tests, each run by `task check:scripts`; a new one needs no entry anywhere |
| `.github/scripts/release-*.sh`, `release.test.sh` | the scripts of a release (§ "Release"): `release-check.sh` (the tag, the workspace version, the changelog section), `release-package.sh` (targets, archive, `SHA256SUMS`, notes), `release-verify.sh` (a published release), and `release.test.sh`, their script test |
| `CHANGELOG.md` | what each release holds, in the Keep a Changelog form; `## [Unreleased]` takes the lines of a wave when it closes (§ "Release", "Changelog lines") |
| `.engineering/` | AEP planning store (`aep.project/5`, profile `development.standard`): the epics and stories of the first milestone |
| `ROADMAP.md` | the trajectory: first consumer and its first gap, the next waves by story id, what the next release holds |
| `website/` | the public documentation site at `https://beyond10x.github.io/ratchet/` (Docusaurus on `@beyond10x/docs-system`, pinned by commit in `package.json`). Its docs pages are `vision.md`, `docs/design.md`, `research/*.md` and `research/responses/*.md`, read in place; `docusaurus.config.ts` gives each its route, title and header (`pages`), the files stay unchanged. `product.json` is the landing page, drawn by `src/pages/index.tsx` (not withProductSite's `landing` option, which ships the build machine's path in the bundle). `.npmrc` sets `allow-git=root`: npm 12 otherwise refuses the Git-pinned dependency. A new file in `research/` (other than `responses/`) needs an entry in `pages` and in `sidebars.ts`; a new file in `docs/` also needs an `include` pattern. A Markdown link to a file the site does not publish fails the build, so link such files by GitHub URL |
| `.github/workflows/pages.yml` | `Documentation validation`: classifies the changed files (`.engineering/` and `*.md` outside `website/`, `vision.md`, `docs/`, `research/`, `crates/`, `presets/` are planning: the job ends green without building), builds the site, refuses a machine path in it, writes `.well-known/b10x-site.json` and on `main` uploads the artifact `b10x-project-site`. A new site source goes into its path list with a case in `task check:ci-paths`. Its second job, `gate` (`Repository gate`), reads the class from the first and repeats no path: for the class `code` it installs the rustc of `rust-toolchain.toml`, Node, `task`, `cargo-nextest`, `ess` and `aep` and runs `task check`; for the class `docs-site` it installs `task` and `ess` and runs `task check:spec`, because that task reads `docs/evidence-format.md` and `docs/design.md`; for the class `planning` it ends green without a checkout. `task`, `cargo-nextest`, `ess` and `aep` are downloaded by URL at a pinned version and refused unless their SHA-256 is the one in the step; Node is the major the job `build` names. A step of the job that another class needs gets that class in its `if:`, and `task check:ci-paths` holds which task each class runs. Every file under `crates/` and under `presets/` is `code`, a generated `README.md` and a page of the catalog included. The step that lists the changed files runs `git diff --no-renames`, so a renamed file is listed with the path it had and a file moved out of `crates/` or `presets/` is `code` |
| `.github/workflows/b10x-docs-site.yml` | publishes that artifact to GitHub Pages through `beyond10x/website`'s `project-site.yml`, pinned by commit, for bot-authored pushes to `main` |
| `.github/workflows/shared-gates.yml` | the organization's shared source gates (`beyond10x/gates`, pinned by commit) |
| `.github/workflows/release.yml` | `Release`, on a tag `<major>.<minor>.<patch>`, with `contents: read`: `release-check.sh` and `task check`, then the archives of both Linux targets, `SHA256SUMS` and `notes.md` as the artifact `ratchet-<version>-release`. It creates no release and reads no token (§ "Release"). Its job `Gate` installs the tools of the job `gate` of `pages.yml` by the same steps, less their `if:`; a new version or digest of one is a change of both files, and `release.test.sh` fails when a step differs |
| `Taskfile.yml` | `task check`: the repository gate; `task generate`: rewrite the generated crates; `task site`: build the site. It includes `acceptance/Taskfile.yml` as `acceptance` when that file exists |

## Domain language

Use the terms of `docs/design.md` § 1 with those meanings: subject, audience, quality
specification, quality requirement, measurement, measurement kind (exact, sampled), scope,
identity set, assessment plan, assessor, target, evidence coverage, protected reference
(generated, accepted value), ratchet policy (a reference's `adoption`), gate (including the
operational gate), candidate, exception, trade-off, quality statement, preset, local config
(`ratchet.toml`), local input, coverage unit. A gate verdict is one of pass, fail, insufficient
evidence; fail takes precedence over insufficient evidence.

## Boundary

- Ratchet runs or imports existing tools (analyzers, browsers, load runners, CI, telemetry); it
  does not reimplement them.
- ESS owns conformance scenarios and ESS UI interactions; Ratchet imports their reports
  (`docs/design.md` § 7).
- AEP owns the planning store; Ratchet records quality evidence, not plan state.

## Gate

`task check` runs these steps in this order. Run it as `slot task check`. Edit the store only
through `aep plan artifact`.

| step | what it does |
|---|---|
| `aep plan artifact validate` | the planning store is valid |
| `check:spec` | the specification, the binding, the record formats and the preset catalog `presets/` (`spec/README.md`) |
| `check:rust` | `cargo fmt --check` and `cargo clippy --workspace --all-targets --locked -- -D warnings`. Both read the members of the workspace, so a generated crate is neither formatted nor linted. Do not add `--all` to `cargo fmt`: it follows path dependencies into the generated crates |
| `check:generated` | each generated crate equals a fresh generation, byte for byte (§ "Generated crates") |
| `check:scripts` | every `.github/scripts/*.test.sh` |
| `test` | `cargo nextest run --workspace --locked`, then the line `test: the ten slowest tests` and that list |
| `check:ci-paths` | the cases of the change classifier in `pages.yml`, the task its job `gate` runs for each class, that a document a script of `check:spec` reads and every file of `presets/` is a change the job runs `check:spec` for, and that a rename out of `presets/` and one out of `crates/` is `code`: the step of `pages.yml` that lists the changed files runs in a clone of depth 2 of a repository under `target/check-ci-paths/`, for a pull request and for a push |
| `site` | `npm ci` and `npm run build` in `website/`, the build CI runs |

The gate needs `task`, `ess` (the release `spec/ess-inputs.yaml` requires), `aep`, `jq`,
`cargo-nextest` and `npm`. The job `gate` of `pages.yml` installs the same versions the gate was
written with; a new version of one of them is a change of that job.

The test budget (workspace `AGENTS.md` § "Tests stay fast"):

- `.config/nextest.toml` ends a test at 60 s and the run at 120 s, and each makes the step fail.
  The bound of the run covers the tests, not the build before them.
- One integration-test binary per crate: `tests/main.rs` with modules, `autotests = false` and
  one `[[test]]` in the crate's manifest, so a file beside `main.rs` is a module and no binary of
  its own.
- A cargo test calls neither `ess` nor the network. `check:generated` and the script tests are
  steps of their own.
- `.github/scripts/test-budget.test.sh` runs the task `test` with a stand-in for `cargo` and
  refuses a configuration or a task that lost one of the three: the 60 s, the 120 s, the list.
  It also refuses a task `test` that calls `cargo` for anything but `nextest run`: `cargo test`
  reads no `.config/nextest.toml`, so nothing bounds it. A doctest or a bench is a step of its
  own with a bound of its own.
- A runner of the forge sets `GITHUB_ACTIONS=true`, and `task` then prints a line
  `::error title=Task '<name>' failed::exit status <n>` before its own
  `task: Failed to run task ...` when a command fails. It also sets `CI=true`, and `task` then
  writes its own lines in colour, into a file too (`FORCE_COLOR` and `TASK_COLOR` do the same):
  such a line starts with `ESC[31m`, not with `task: `. A script test that reads the output of
  `task` unsets these variables, `NO_COLOR` and every `TASK_*`, makes each run with none of
  them, with `CI=true`, and with `CI=true` and `GITHUB_ACTIONS=true`, and reads a line without
  its colour, as `test-budget.test.sh` does, so the gate on a workstation reads the lines the
  forge prints.

No `.cargo/config.toml` exists: the workspace needs no setting of its own. Do not add `debug`, a
compiler wrapper or a target directory there (workspace `AGENTS.md` § "One compile cache").

Every `aep` command that writes runs with `AEP_ACTOR=agent:ratchet` in its environment. Without
it the store records `human:<login>` in each transition and evidence record, which puts a
person's login name into a public repository.

## Generated crates

A generated crate is the output of a generator over `spec/`, committed and never edited. The
first is `crates/ratchet-cli-contract/` (`ess generate cli`).

How the workspace holds one:

- Its directory is in `exclude` of `[workspace]` in the root `Cargo.toml`, and it is a path
  dependency in `[workspace.dependencies]`. It is no member. `ess generate cli` writes a manifest
  with a `[workspace]` table of its own, and Cargo refuses a member that is a workspace root
  (`multiple workspace roots found in the same workspace`). A generated crate without that table
  is held the same way.
- A hand-written crate depends on it with `<package>.workspace = true` and uses its library
  (`cli_contract` for `ratchet-cli-contract`).
- Cargo builds only the library of a path dependency. The `ratchet` binary that
  `crates/ratchet-cli-contract/` declares is therefore never built in this workspace, and the one
  `ratchet` binary is that of `crates/ratchet/`.
- Its dependencies are locked in the root `Cargo.lock`. Do not run `cargo` inside its directory:
  that writes a `Cargo.lock` and a `target/` there, and `check:generated` refuses both.
- What the generated code lacks goes into a hand-written crate or the root manifest, never into
  the generated directory.

How to regenerate, after a change of the specification:

```console
task generate
```

It runs `.github/scripts/check-generated.sh --write`: each generator writes into
`target/check-generated/<name>`, and that output replaces the directory in the tree. Running
the generator on the directory in the tree is refused (`unowned output destination`), because
its record of what it wrote, `.ess-output/`, is not committed: it holds an id that is new in
each generation. `.gitignore` names it.

`task check:generated` makes the same fresh generation and compares every entry that is no
directory: a file that differs, an entry the generator did not write, a file the tree lacks, an
entry that is no regular file (a symbolic link, also one to an equal file) and an executable
bit that is not as generated each fail the step. `check-generated.test.sh` makes each of these
changes in a copy, the changed byte once per file of the crate.

The next generated crate:

1. one line in `lines` of `.github/scripts/check-generated.sh`: the directory, `|`, the
   generator line with `{out}` for the output directory;
2. its directory in `exclude` and its package in `[workspace.dependencies]`;
3. `task generate`, and a row in § "Ownership".

`.github/scripts/check-generated.test.sh` takes its cases from those lines and needs no edit.

## Commits

Every commit and push is `b10x-bot[bot]`'s through `b10x-gates bot -- <git command>`; every other
GitHub write goes through `b10x-gates api`, with `--policy ../gates-policy/policy.json` from the
primary checkout. Every commit has a body.

## Release

A release is the workspace version at a bare tag (`0.1.0`): two Linux archives of the `ratchet`
binary, `SHA256SUMS`, and notes cut from `CHANGELOG.md`. The tag workflow builds and the bot
publishes: `.github/workflows/release.yml` has `contents: read` and creates no release. A tag and
a release are publications, so they wait for the owner's order (workspace `AGENTS.md`
§ "A default proceeds").

### Changelog lines

- `CHANGELOG.md` is in the Keep a Changelog 1.1.0 form. Before the first section stand only
  the title and its text. `## [Unreleased]` is the first section, each released one is
  `## [<version>] - <YYYY-MM-DD>` with a date of the calendar, each version once, newest first.
  Below a section stand only the headings `### Added`, `### Changed`, `### Deprecated`,
  `### Removed`, `### Fixed` and `### Security`, and below a heading one bullet per change, on
  one line. A heading has at least one bullet, and so has a released section.
- The story that closes a wave writes the lines of its wave under `## [Unreleased]`. A change
  outside a wave writes its own line, in the same change.
- A line says what a user of the repository gets, and what is not built where a name could
  suggest more. A story id alone is no line.
- `.github/scripts/release.test.sh` checks the form in the gate.

### Steps

`<version>` is `<major>.<minor>.<patch>`, greater than the newest tag on `origin/main`. It is
taken when the release branch is cut and not reserved before; a release branch that another
release overtook is cut again from `main`. The git commands of the bot are `b10x-gates bot
--repository beyond10x/ratchet -- <git command>` (§ "Commits").

1. Branch `release/<version>` from `main`, with one commit `release: ratchet <version>` that
   holds three things and nothing else: `version` in `[workspace.package]` of `Cargo.toml`;
   `Cargo.lock` as `cargo build` rewrites it; and in `CHANGELOG.md` a new line
   `## [<version>] - <YYYY-MM-DD>` directly below `## [Unreleased]`, so that the lines of the
   release stand under the new heading and `## [Unreleased]` stays, empty.
   `sh .github/scripts/release-check.sh <version>` passes and `slot task check` is green on
   that commit. The script fails when no change line stands under the new heading, which is
   what a heading put below the lines gives.
2. A bot pull request from the branch to `main`, merged by the bot with a merge commit when
   its required checks are green, as a wave is.
3. An annotated tag `<version>` on that merge commit on `main`, made and pushed by the bot:
   `tag -a <version> -m "ratchet <version>" <commit>`, then `push origin <version>`.
4. The tag starts the workflow `Release` (`.github/workflows/release.yml`). Its job `Gate` runs
   `release-check.sh` and `task check`; `Package` builds `ratchet` for
   `x86_64-unknown-linux-gnu` and `aarch64-unknown-linux-gnu` and writes
   `ratchet-<version>-<target>.tar.gz` with `release-package.sh archive`, which refuses a
   binary that does not print `ratchet <version>` for `--version` and exit 0;
   `Bundle the release assets` writes `SHA256SUMS` and `notes.md` and uploads the artifact
   `ratchet-<version>-release`. Find the run with
   `gh run list --repo beyond10x/ratchet --workflow release.yml` and wait for it in the
   background. A red run: "A tag whose run fails", below. A green run: download its artifact
   and verify it, both read-only:

   ```console
   gh run download <run> --repo beyond10x/ratchet -n ratchet-<version>-release \
     -D target/release-assets
   (cd target/release-assets && sha256sum -c SHA256SUMS)
   ```

5. The bot creates the release, from the checkout and with paths relative to it. A refusal of
   the publishing gate is reported and not worked around.

   ```console
   b10x-gates gh --repository beyond10x/ratchet -- release create <version> --verify-tag \
     --title "ratchet <version>" --notes-file target/release-assets/notes.md \
     target/release-assets/ratchet-<version>-x86_64-unknown-linux-gnu.tar.gz \
     target/release-assets/ratchet-<version>-aarch64-unknown-linux-gnu.tar.gz \
     target/release-assets/SHA256SUMS
   ```

6. `sh .github/scripts/release-verify.sh <version>` exits 0. Only then is the release reported
   as released. It reads the published release with `gh`, read-only, and checks in this order:
   the release is `<version>`, no draft and no prerelease; its author is `b10x-bot[bot]`; the
   two archives and `SHA256SUMS` are attached, no other asset is, and they are downloaded;
   `sha256sum -c SHA256SUMS` passes on them; each archive holds `ratchet`, `LICENSE` and
   `README.md` as regular files and nothing else; the `ratchet` of the `x86_64` archive prints
   `ratchet <version>` for `--version` and exits 0. Before the release exists it exits 1.

### A tag whose run fails

The run of step 4 is the only build of a tag. Read a red run before anything else, read-only:
`gh run view <run> --repo beyond10x/ratchet --log-failed`.

- The runner is at fault (no runner, a network error, a cancelled run): the bot starts the run
  again, once: `b10x-gates gh --repository beyond10x/ratchet -- run rerun <run>`.
- The tree is at fault (`release-check.sh`, `task check`, the build or a script fails on the
  tagged commit): the tag stays, it is never moved or deleted, and no release is created for
  it. The correction lands by pull request and writes its line under `## [Unreleased]`. The
  next patch version is then cut by the same steps, and its section holds one more line under
  `### Changed`: "`<earlier version>` was tagged and not released; this release holds its
  changes too". The section of the earlier version stays where it is.
- A version with a section and a tag and without a release is in order for the scripts: they
  read no list of tags or releases. `release-check.sh` and the form check pass for the next
  version, and `release-verify.sh <earlier version>` exits 1, as for every version that has no
  release.

### The scripts

- `release-check.sh <tag>`: the tag is the workspace version, and the changelog has its dated
  section with a date of the calendar and at least one change line under a heading.
- `release-package.sh`: `targets` and `assets <version>` name what a release is built for and
  carries; `archive`, `sums` and `notes` write the archive, `SHA256SUMS` and the notes. A new
  target is one word in `targets` there and one entry in the matrix of the workflow.
- `release-verify.sh <version>`: the checks of step 6. With `--description <file> --assets
  <directory>` it reads a description in the form `gh release view <version> --json
  assets,author,isDraft,isPrerelease,tagName` and the assets from disk, and calls no `gh`.
- `release.test.sh` runs the three on fixtures with a stub binary and a stand-in for `gh`
  that answers only the calls `release-verify.sh` is meant to make. It reads the workflow as a
  structure: the trigger, the permissions, `needs` and the runner of each job, the commands,
  the names and paths of the artifacts, and the steps that install the tools of the gate,
  which equal those of `pages.yml`. Its cases stand in groups, and a group reads nothing
  another group wrote but the archives. Its last part are mutants: a copy of the workflow or
  of a script with one change, each refused by a case of the group named with it. A mutant
  whose line was rewritten fails until its expression is written anew, and a new refusal of
  a script gets a case and a mutant. It reaches no network, builds nothing and makes no tag,
  and needs GNU `date`.

## Never

- Write Python for anything committed (workspace `AGENTS.md` § No Python for permanent tools).
- Hand-edit a `status`, `revision` or `transitions` field under `.engineering/planning/`.
