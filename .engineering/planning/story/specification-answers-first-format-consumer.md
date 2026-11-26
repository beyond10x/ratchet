---
format: aep.planning-md/3
id: story:specification-answers-first-format-consumer
kind: story
status: implemented
title: The specification answers five places the first format consumer could not read
summary: 'scopes: [], a value aggregated in one run, units, comments, the evidence digest.'
relations:
- decomposes: epic:format-gaps-first-format-consumer
revision: 11
transitions:
- {from: "draft", to: "proposed", at: "2026-11-26T05:20:03Z", actor: "human:operator", revision: 9}
- {from: "proposed", to: "active", at: "2026-11-26T05:20:03Z", actor: "human:operator", revision: 10}
- {from: "active", to: "implemented", at: "2026-11-26T07:54:31Z", actor: "human:operator", revision: 11, decided_on: {"recorded":{"test_result":1,"review_outcome":2}}}
---
## Context

The repository `beyond10x/inference` wrote its quality definition against the formats at
commit `f139ecc` (2026-11-25): 3 `ratchet/1` files, 8 `ratchet-assessor/1` declarations and 15
`ratchet-evidence/1` records. It is the first consumer of the formats outside this repository
and of this story. Line numbers in this section are those of `f139ecc`.

Findings 10, 11 and 14 to 16: five places where the specification is silent or two documents
disagree.

- **10, an assessor with only `run`-scope outputs.** `spec/domains/assessor.yaml:94-98`:
  `scopes` is required and lists the scopes "beside `run`". 6 of the consumer's 8 declarations
  write `scopes: []`. Whether the empty list is valid is not stated.
- **11, a value aggregated inside one run.** `specification.yaml:182-188`: `aggregation` is
  absent with `runs: 1`. `spec/domains/evidence.yaml:368-375`: a result carries `samples` and
  `aggregation`. The case: one command prints a median of three.
  Two more cases of the same place, reported by the consumer on 2026-11-25 from a read of
  `b8945e5`: a plan with `runs: 1` whose command repeats its measurement itself (an option of
  the command, two repeats), and a command that prints one value per segment of its output
  in one run. `docs/evidence-format.md` § 1 ("One document per assessment run") says that a run is one
  execution of one plan by its assessor, so the repeats are samples of one run; no sentence
  says so where a plan with `runs: 1` is described.
- **14, one unit per output.** `specification.yaml:176-181`. 45 minutes is written `2700`;
  `examples/ci-turnaround.ratchet.yaml` uses `min` and `s` for the same kind of value.
- **15, comments.** `spec/README.md:207` does not say whether a `ratchet/1` file may hold
  comments.
- **16, the evidence digest by hand.** `docs/evidence-format.md` § 2: the record id is the
  SHA-256 of the file; the evidence digest needs the byte span of one member, and no command
  or recipe computes it.

What each answer may change:

- 11: the story decides only whether the existing aggregation kinds are valid with `runs: 1`
  when the command repeats its measurement itself. It adds no aggregation kind and no member
  of a preset; the preset side stays with `story:member-for-some-input-values` and
  `story:value-over-all-runs`.
- 14: the answer is text only. It changes none of the types the slice of 0.1.0 reads
  (`ratchet.evidence.EvidenceCoverage`, `ratchet.evidence.ImportSourceKind`,
  `ratchet.specification.Condition`, § Order of `epic:format-gaps-first-format-consumer`);
  the `unit` of a `Condition` stays as it is.

## Acceptance

Each of the five places has one answer, written in `spec/` and in the document that was silent
or disagreed. Per place, the file the answer lands in and what checks it (line numbers of
`7aa82f8`):

- 10, `scopes: []` — the answer: the empty list is valid and means an output whose results
  have the scope `run` alone; `scopes` stays required. Written in the summary of `scopes` in
  `spec/domains/assessor.yaml` (`:94-98`) and in `docs/evidence-format.md` § 10 —
  `sh spec/presets.test.sh`, rules `type` and `required`: the catalog's declarations write
  `scopes: []` (`presets/advisory-report@1.assessor.yaml:15`) and stay accepted, unchanged. A
  new case of that script takes `scopes` out of the output of its copied declaration (the line
  `number_output`, `  failed: {value_type: number, kind: exact, scopes: [], unit: cases}`,
  becomes `  failed: {value_type: number, kind: exact, unit: cases}`) and expects the message
  of rule `required`, "has no `scopes`, which ratchet.assessor.AssessorOutput requires"; no
  case drops `scopes` before the story, and the last line counts one broken copy more.
- 11, a value aggregated inside one run — `docs/design.md` § 3 (`:114`, "One run per candidate
  is valid"), the summary of `aggregation` in `spec/domains/specification.yaml` (`:182-188`)
  and `docs/evidence-format.md` § 1 (`:12`) — text only, no case: no script reads `runs`
  together with `aggregation`, and `story:preset-check-unlisted-forms` lists `runs: 1` with an
  aggregation under "Not checked" of `spec/presets.test.sh`.
- 14, one unit per output — `docs/design.md` § 3 "Comparisons" (`:183`) and the summary of the
  measurement's `unit` in `spec/domains/specification.yaml` (`:175-181`) — text only, no case;
  the rules that bind the unit of a measurement to its output stay
  (`spec/example-declarations.test.sh:14-16`).
- 15, comments — `spec/README.md` § "How a `ratchet/1` file differs from the declared entities"
  (`:275`) and `docs/design.md` — text only, no case: the scripts that read `ratchet/1` files
  are no YAML readers, and what they skip or refuse of a comment is their own reading
  (`spec/example-declarations.test.sh:60`, `spec/presets.test.sh:141`), not the format.
- 16, the evidence digest — the recipe in `docs/evidence-format.md` § 2 (beside the table of
  the three digests, `:27-31`), and the evidence digest of the first example of § 6 written in
  the text of § 6 as one line of the form
  ``The evidence digest of the example above is `sha256:<64 lowercase hex digits>`.``, after
  that example's block. The digest is over the bytes of the example as printed in the
  document, not of the file the assessor wrote: § 6 says the printed example leaves out
  `details.items` of one output and changes the white space (`:380-383`). A new rule of
  `sh spec/record-examples.test.sh`: it finds that one line in § 6, applies the recipe to the
  first example (the bytes from the `{` of the value of `evidence` to its matching `}`, as the
  block stands in the document), computes the SHA-256 with `sha256sum`, and fails when the
  line is missing or the result differs from the digest it states; the script passes, and with
  one byte of that `evidence` changed it fails. The header's line "Needs `jq`." (`:34`) names
  `sha256sum` beside `jq`.

`ess specify validate` passes, and the story runs `task check:generated` when it edits
`spec/domains/`.

## Notes

- Taken ahead of the waves to 0.1.0 into one wave built in sequence on one branch: every
  planned wave starts behind `story:cli-skeleton-validate`, which waits for an ESS release
  (beyond10x/ess#836). No `ratchet` command exists in this wave, so every acceptance item is
  observed through `task check` steps, the POSIX sh scripts under `spec/` and
  `.github/scripts/`, `ess specify validate`, or files. It is 4 of the nine in the order of
  `.engineering/waves/0.1.0-ahead-1.md`.
- Finding 8 (`observation.command`) left this story: `story:assessor-learns-observation`
  decides how an assessor learns the observation of its plan, `command` with it.
- Finding 9 (`holds` at a scope other than `run`) was withdrawn by the consumer on 2026-11-25:
  `docs/design.md` § 3 "Comparisons" states it ("`holds` requires it for every item").
- The form shown is the consumer's proposal. The story decides the form, declares it in
  `spec/` first, and writes it into `docs/design.md` or `docs/evidence-format.md` in the same
  change.
- A new value or field of a released format is an addition: a file written for the format
  before the change stays valid.
- POSIX sh, no Python. The test step ends within 120 s, no test over 60 s.
