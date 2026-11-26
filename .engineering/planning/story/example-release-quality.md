---
format: aep.planning-md/3
id: story:example-release-quality
kind: story
status: active
title: An example plan for the quality of a release
summary: 'examples/release-quality.ratchet.yaml: exact counts with better: lower under a gate that starts report-only.'
relations:
- decomposes: epic:runnable-cli
scope:
- confidence: cited
  path: examples/README.md
- confidence: inferred
  path: examples/quality/assessors/release-counts@1.assessor.yaml
- confidence: inferred
  path: examples/release-quality.ratchet.yaml
revision: 18
transitions:
- {from: "draft", to: "proposed", at: "2026-11-26T21:04:25Z", actor: "human:operator", revision: 17, decided_on: {"recorded":{"review_outcome":4}}}
- {from: "proposed", to: "active", at: "2026-11-26T21:04:25Z", actor: "human:operator", revision: 18, decided_on: {"recorded":{"review_outcome":4}}}
---
## Context

A consumer reviews each release of a product and wants its review written as a `ratchet/1`
file: measurements that are exact counts where a lower value is better, and a gate that starts
report-only (2026-11-25, routed by the operator session of the workstation). It asks for an
example to copy, `examples/release-quality.ratchet.yaml`. Nothing of the consumer is named
here.

What the format says today: the direction of a measurement is the key `better` with the value
`lower` (`docs/design.md` § 3 "Value lists", the row "Direction (`better`)", `:218` at
7b01ea1), and a gate entry with `mode: report` and `since` (`docs/design.md` § 5 "Gate modes",
`:627-631`; `ratchet.specification.GateRequirement` and its invariant that a report-mode entry
has `since`, `spec/domains/specification.yaml:1078-1110`; the entry of `rust-test-step-budget`
in `examples/ci-turnaround.ratchet.yaml:130`). The six examples under `examples/` (the table of
`examples/README.md`, `:41-49`) hold no plan whose subject is a release, and none whose
measurements are all exact counts under a gate that only reports. `docs/design.md` has no list
of the examples: it names one example file in passing (§ 3, `:201`,
`examples/ci-turnaround.ratchet.yaml` for two units of one kind of value) and cites
`examples/README.md` at older commits in § 10 and § 11. The table of `examples/README.md` is the
list, so `docs/design.md` gets no line.

What checks an example today: `sh spec/example-declarations.test.sh`, step 11 of
`task check:spec` (`spec/README.md`), reads each `examples/*.ratchet.yaml`: every assessor it
names has a declaration in `examples/quality/assessors/` or `presets/`, and each measurement
names an output, a unit and a scope that declaration declares. It reads no other key, so the
gate, the requirements and `better` are read by no script. AGENTS.md (row `examples/`): a change
that adds a file `*.ratchet.yaml` adds the declaration of each assessor it names that has none.
`ratchet validate` is built by `story:cli-skeleton-validate`.

## Acceptance

Every outcome below is observable without a `ratchet` command. Before the story the files of
items 1 to 6 do not exist, so each `grep` of them exits 2.

A phrase with a space in it may wrap in a Markdown paragraph or a folded YAML summary. So where
an item says that `grep -F` finds such a phrase in a `.md` or `.yaml` file, that it finds
nothing or the phrase is gone, or that `grep -c` of it prints a count, the check reads the
joined text of the file: `tr -s '\n ' '  ' < <file> | grep -o -F '<phrase>' | wc -l` prints 1
where the item says it is found, 0 where it says nothing or gone, and the count where it names
one. A name without a space, a row of a table, a pattern with `^`, `$` or `-E`, a check that
prints the line it matches and a check that reads the output of another command read the file
line by line, as written.

1. `examples/release-quality.ratchet.yaml` (new) declares a release as its subject, the subject
   `product-release` with `kind: release`: `grep -c '^    kind: release$'
   examples/release-quality.ratchet.yaml` prints 1.
2. Its one plan, over one assessor, holds at least three exact measurements:
   `grep -c 'kind: exact' examples/release-quality.ratchet.yaml` prints 3 or more (open defects
   of the release, failed checks of its run, reverted changes since the release before).
3. Each of those measurements states `better: lower`:
   `grep -c 'better: lower' examples/release-quality.ratchet.yaml` prints the number of item 2.
4. A requirement on each measurement compares it with an accepted reference:
   `grep -c 'kind: accepted_value' examples/release-quality.ratchet.yaml` prints the number of
   item 2.
5. One gate, `release`, whose every entry has `mode: report` and a `since`:
   `grep -c 'mode: report' examples/release-quality.ratchet.yaml` and
   `grep -c 'since: ' examples/release-quality.ratchet.yaml` each print the number of item 2,
   and `grep -c '^gates:$' examples/release-quality.ratchet.yaml` prints 1.
6. `examples/quality/assessors/release-counts@1.assessor.yaml` (new), in the form of the files
   of `presets/`, declares the outputs the measurements read, each `number`, `exact`, with its
   unit and the scope `run`: `grep -c 'value_type: number'
   examples/quality/assessors/release-counts@1.assessor.yaml` prints the number of item 2.
7. `sh spec/example-declarations.test.sh` exits 0, and its line
   `example-declarations: <e> example file(s), <d> declaration(s) read, <m> of <m> measurement(s) as declared`
   counts one more example file, one more declaration and as many more measurements as item 2
   than at the commit before the story.
8. `examples/README.md`, the table of files has the row of the new file:
   `grep -F '| [`release-quality.ratchet.yaml`](release-quality.ratchet.yaml) |'
   examples/README.md` finds it (nothing before).
9. `examples/README.md` has the section "7. Quality of a release", which gives the source of
   every value: `grep -c '^## 7. Quality of a release$' examples/README.md` prints 1 (0
   before), and `grep -F "a consumer's request of 2026-11-25, not published"
   examples/README.md` finds the source (nothing before).
10. The counts with no survey source are listed under "Numbers without a source":
    `awk '/^## Numbers without a source/,0' examples/README.md | grep -c 'release-quality'`
    prints 1 or more (0 before).

## Notes

- First consumer: the repository that reviews releases. The counts of the example are generic;
  no name of a product or a tracker.
- The gate of the example states no `judges`: neither this story's original acceptance nor
  `epic:runnable-cli` asks for it, so the example does not read the form of
  `story:gate-judges-commit-of-a-tag` (30).
- A thing the example needs and the format cannot say is named in the report and filed as a
  draft of `epic:format-gaps-first-format-consumer`; the example gets no key the specification
  does not declare.
- How a record names the released version is decided by `story:record-series-git-ref`, which
  stays out of this wave; the example uses the target kind `revision` until then.
- `ratchet validate examples/release-quality.ratchet.yaml` exiting 0 is
  `story:example-release-quality-in-ratchet`, which waits for `story:cli-skeleton-validate`;
  the dependency on that story moves there.
- `examples/README.md` is changed before this story by `story:severity-limit-on-identity-set`
  (13), `story:records-tracked-baseline-directory` (28) and `story:production-gate-kind` (31);
  this story adds a row and a section of its own.
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-26 the owner
  took it ahead of them (D87 B), with the other stories of `.engineering/waves/0.1.0-ahead-2.md`,
  into one wave built in sequence on one branch: every planned wave starts behind
  `story:cli-skeleton-validate`, which waits for a release of ESS (beyond10x/ess#836), and this
  part needs no `ratchet` command. It is 33 of the 33 in the order of that page; it needs no
  unit before it and keeps its place.
