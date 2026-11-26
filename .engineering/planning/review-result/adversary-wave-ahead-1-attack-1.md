---
format: aep.planning-md/3
id: review-result:adversary-wave-ahead-1-attack-1
kind: review-result
status: active
title: adversary on the wave ahead of 0.1.0, attack 1 on 332f4f8
relations:
- reviews: story:workflow-run-target-identifiers
- reviews: story:candidate-under-merge-result
- reviews: story:cache-condition-one-name
- reviews: story:specification-answers-first-format-consumer
- reviews: story:plan-with-exact-and-sampled-measurements
- reviews: story:preset-check-unlisted-forms
- reviews: story:value-over-all-runs
- reviews: story:item-field-values
- reviews: story:production-gate-spec-executed-service
revision: 1
---
Adversary, attack 1 on the wave of `.engineering/waves/0.1.0-ahead-1.md`, diff 7aa82f8..332f4f8
(stories 1 to 9). Verdict: warnings and notes, no blocker; eleven findings, all introduced by the
diff. Executed: `spec/presets.test.sh` 99 copies and 236 defects, `spec/example-declarations.test.sh`
33 copies, `spec/gate-inputs.test.sh` 10 inputs, all unchanged and green. Mutants and probes ran
as copies under the worktree's `target/`.

## Mutants

- Killed: the `cache` refusal of a declaration and of a plan, the reserved input, the
  `item_values` key, the filter value, `runs` above 99, `over_all_runs` with an aggregation, the
  exact rule, the comparison of the harness case, and in `spec/example-declarations.test.sh`
  the existence of a `use:` file and the digest comparison.
- Survived: refusing literal `runs: 1` (`> 0`) and the boundary `runs: 2` (`> 2`), refusing an
  exact `sum`, dropping the exemption for an `over_all_runs` given by an input, and replacing
  the evidence digest comparison of `spec/record-examples.test.sh` with `if false`.

## Could not break

Quoted `"cache"`, `cache` as a second item, quoted `"median"` on exact, `best_of_n` on exact,
`runs: 2` without aggregation, an `item_values` key outside `item_fields`, a bad second filter
value, an empty value list and a non-string value are refused with their rule's message. White
space outside `evidence` of § 6 keeps the digest. The five binding digests of the example equal
`sha256sum` of their presets. The acceptance counts hold.

## Budget

`spec/presets.test.sh` took 10.4 s in an instrumented run; the harness comparison 0.45 s once,
the catalog check 0.17 s, the 99 copies the rest. No cost grows with the catalog; each copy now
holds 10 files instead of 8.

```findings
[{"file":"spec/README.md","line":300,"category":"contract-drift","severity":"warning","verdict":"CONFIRMED","origin":"introduced","message":"comment rule names no example file with a comment while examples/production-gate.ratchet.yaml:12 holds one"},
{"file":"spec/record-examples.test.sh","line":197,"category":"mutant","severity":"warning","verdict":"CONFIRMED","origin":"introduced","message":"removing the evidence digest comparison keeps record-examples and gate-inputs green; no case changes a byte of evidence"},
{"file":"spec/presets.test.sh","line":162,"category":"mutant","severity":"warning","verdict":"CONFIRMED","origin":"introduced","message":"refusing literal runs 1 (and the runs 2 boundary) stays green: no accepted copy of the valid runs 1 forms"},
{"file":"spec/presets.test.sh","line":169,"category":"mutant","severity":"warning","verdict":"CONFIRMED","origin":"introduced","message":"refusing exact aggregation sum stays green: no accepted copy of the valid exact sum form"},
{"file":"spec/presets.test.sh","line":161,"category":"mutant","severity":"note","verdict":"CONFIRMED","origin":"introduced","message":"dropping the exemption for an over_all_runs given by an input stays green"},
{"file":"examples/quality/assessors/command-timing@1.assessor.yaml","line":8,"category":"acceptance","severity":"warning","verdict":"CONFIRMED","origin":"introduced","message":"file in tag 0.0.3 changed under the same @1, as story acceptance item 4 requires"},
{"file":"presets/functional.md","line":1,"category":"contract-drift","severity":"note","verdict":"CONFIRMED","origin":"introduced","message":"catalog pages README.md, build.md, functional.md changed as acceptance requires; no released yaml changed"},
{"file":"AGENTS.md","line":65,"category":"contract-drift","severity":"warning","verdict":"CONFIRMED","origin":"introduced","message":"examples row says the check reads no other key of an example, but the binding rule reads presets bindings"},
{"file":"Taskfile.yml","line":87,"category":"contract-drift","severity":"note","verdict":"CONFIRMED","origin":"introduced","message":"check:spec description omits the binding rule and names only jq though record-examples now needs sha256sum"},
{"file":"spec/README.md","line":79,"category":"contract-drift","severity":"note","verdict":"CONFIRMED","origin":"introduced","message":"step 10 omits the new presets refusals other than cache, and presets/README.md omits the cache refusal"},
{"file":"spec/presets.test.sh","line":52,"category":"judgement","severity":"note","verdict":"CONFIRMED","origin":"introduced","message":"header rows names and row misaligned and line 70 is 132 characters"}]
```
