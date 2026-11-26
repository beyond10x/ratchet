---
format: aep.planning-md/3
id: story:readme-design-citations-by-place
kind: story
status: draft
title: The README of the specification cites the design by place, not by line number
relations:
- decomposes: epic:format-gaps-first-format-consumer
scope:
- confidence: cited
  path: CHANGELOG.md
- confidence: cited
  path: spec/README.md
revision: 4
---
## Context

The table of `spec/README.md` § "How a `ratchet/1` file differs from the declared entities"
(header `:294`, rows `:296-310`) maps each rule of the file form to its place in
`docs/design.md`. Its intro says "Each row names the line of `docs/design.md` that states the
rule" (`:287-288`). Eight rows cite by line number (`:296-303`), and the numbers are out of step
at 7b01ea1:

- "The root" and "`project` is written once" cite "YAML 218, 219". The illustrative YAML of
  `docs/design.md` § 3 has `format: ratchet/1` at `:236` and `project: partner-portal` at `:237`.
- "A gate holds its entries", "A bare requirement name is an entry" and "An entry written as a
  map may leave `mode` out" cite 603. `docs/design.md:603` is the heading `### Verdicts`; the
  rule is the first paragraph of "Gate entries, deciding evidence, and gate kinds" (`:635`).
- "Several files form one specification" cites 690 for the rule; `:690` is the line
  `paths = [...]` of the `ratchet.toml` block, and the rule is rule 5 of § 5 "Local config"
  (`:722`). Its example cell cites "design, line 658" for that `paths` line, now `:690`.
- The column "Example member" cites `examples/*.ratchet.yaml` by line too, such as
  `examples/production-gate.ratchet.yaml:12` and `:16` (`:307-308`), a file that
  `story:severity-limit-on-identity-set` and `story:production-gate-kind` change later in this
  wave.

No script reads the table. The wave of `.engineering/waves/0.1.0-ahead-1.md` moved the lines;
the 32 stories after this one in `.engineering/waves/0.1.0-ahead-2.md` insert into
`docs/design.md` again. Found by the implementor of stories 4 to 6 of wave ahead 1; a
pre-existing finding.

## Decision

The table cites by place: a section of `docs/design.md` by its number and heading, and where a
section holds several rules, a phrase quoted from the sentence that states the rule, or the
key of the illustrative YAML of § 3 that shows it ("§ 3 'Illustrative project YAML', key
`project`"). An example member is cited by file and key path (`gates.production.requires` of
`examples/production-gate.ratchet.yaml`), without a line number. No script is added: an
insertion into either file moves no citation, and a script that reads `spec/README.md` would
need a path of its own in the change classifier of `pages.yml`, which classes `*.md` outside
`website/` as planning.

## Acceptance

Every outcome below is observable without a `ratchet` command.

1. `spec/README.md`, the column "`docs/design.md`" of the table of § "How a `ratchet/1` file
   differs from the declared entities": no cell holds a line number, and each cell names a
   section of `docs/design.md` by number and heading, with a quoted phrase or a key of the
   illustrative YAML where the section holds several rules. Before: eight cells cite a line
   number and at least four (those citing 603, 218, 219) do not hold what their row names.
   After: `grep -nE '\| [0-9]{3}|YAML [0-9]' spec/README.md` prints nothing, and each quoted
   phrase is found by `grep -F` in `docs/design.md` under the cited heading. Text only, no
   case.
2. `spec/README.md`, the column "Example member" of that table: each cell names its file and
   key path and no line number (`grep -nE '\.ratchet\.yaml:[0-9]' spec/README.md` prints
   nothing). Text only, no case.
3. `spec/README.md`, the intro of that section (`:286-293`): it says the rows cite the design by
   section and phrase, not by line. Text only, no case.
4. `CHANGELOG.md` has its line under `## [Unreleased]` (`### Fixed`). Text only, no case.

## Notes

- The decision taken (AGENTS.md § "Phase: implementation"): citation by place, no script. The
  other form of the draft, a script that checks each cited line, would break on each insertion
  the wave makes and needs a change of `pages.yml` and `task check:ci-paths`.
- The headings this table cites stay as they are through this wave: the stories that change
  `docs/design.md` § 5 "Gate entries, deciding evidence, and gate kinds"
  (`story:gate-entry-unless-only-paths`, `story:gate-judges-commit-of-a-tag`,
  `story:production-gate-kind`) add paragraphs and rename no heading.
- The story was a pre-existing finding of wave ahead 1, filed to wait until every planned wave
  is delivered. On 2026-11-26 the owner took it ahead of them (D87 B), with the other stories of
  `.engineering/waves/0.1.0-ahead-2.md`, into one wave built in sequence on one branch: every
  planned wave starts behind `story:cli-skeleton-validate`, which waits for a release of ESS
  (beyond10x/ess#836), and this part needs no `ratchet` command. It is 1 of the 33 in the order
  of that page: it runs first so that the insertions of the 32 after it move no citation.
- No command part: the story has no `-in-ratchet` draft.
