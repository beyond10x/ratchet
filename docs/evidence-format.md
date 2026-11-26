# Evidence format `ratchet-evidence/1`

**Status:** Design proposal, revision 2, 2026-11-24. Written against [design](design.md) revision 4 and the ESS specification at revision 3 ([`spec/domains/evidence.yaml`](https://github.com/beyond10x/ratchet/blob/main/spec/domains/evidence.yaml)); § 10 and items 18 to 25 of § 8 are against revision 4. Field names and shapes are proposals, as in the design. The six questions E1 to E6 are decided, all A (the owner's delegate, 2026-11-24). The three questions E7 to E9 are taken as A for 0.1.0, 2026-11-24: the defaults the document is written under. Since that day the specification declares both formats, and § 8 says for each of its items how.

An assessment run is an entity of the specification and a row of the records table (design § 6). Neither says how a run is written to a file. The first assessor built against the design, `ux-static@1` of the [`uxui`](https://github.com/beyond10x/uxui) repository, wrote a shape of its own, `ratchet-evidence/draft`, and reported nine gaps, U1 to U9 ([consumer input](../research/consumer-input-ux-ui.md), section “Second input”). This document names the format, lists every field, decides the gaps, and maps the draft onto the format. Six decisions were the owner’s: E1 to E6 in § 5.

**Revision 2.** The consumer then wrote `ratchet-evidence/1` from this document and raised 13 questions, Q1 to Q13. Each answer is written into the rule or the field it belongs to, and § 11 lists where. Two things the questions asked for are new: how Ratchet starts an assessor, and how an assessor is declared (§ 10). Three choices are the owner’s: E7 to E9 in § 5, each with a default, and each taken as A for 0.1.0.

## 1. Name, version, and file

- **Name.** `ratchet-evidence/1`, in the member `format`, as `ratchet-reference/1` and `ratchet-trade-off/1` are (design § 3, § 5).
- **One document per assessment run.** A run is one execution of one assessment plan by its assessor, and every measurement of the plan reads that run (design § 3). A command that repeats its measurement itself within the run, by an option of its own or with one value per segment of its output, gives samples of that one run: under a plan with `runs: 1` the result is one value with the aggregation of its measurement and the number of repeats in `samples` (design § 3, “One run per candidate is valid”). The document holds all results of the run and one set of coverage counts. A document per measurement or per scope item is not this format.
- **File.** One JSON object, UTF-8 without a byte order mark. The file name ends in `.evidence.json`; `<assessment>.evidence.json` is the proposed name. A reader takes nothing from the name. Where the record store keeps the file is not decided here: design § 6 names the hand-over and the ref and not their layout.
- **Types.** A count is a JSON integer. A decimal is text, so no value changes in a conversion (design § 3). A time is text in UTC, `2026-11-24T02:49:16Z`. A duration is decimal text in seconds, `94.3`. A digest is `sha256:` and 64 lowercase hex digits. A path in `evidence` is relative to the root of the repository, with `/`. A file outside that root has no path in `evidence`: the member that would hold the path is left out, and the digest of the file identifies it (Q8). Where a file lay on one machine is not evidence.
- **Spelling.** Members and the values Ratchet defines are snake_case (design § 3, value lists).
- **Version.** The number after the slash is the version. A reader of version 1 rejects a member of `evidence` that it does not know: such a member can change what a value means, and a reader that skipped `at_least` would read a lower bound as an exact value. It ignores a member of `run` that it does not know. A new member of `evidence`, or a new value of a list that Ratchet closes, therefore makes version 2, and a new member of `run` does not. A reader of a version reads every earlier one (E5). Revision 2 of this document is still version 1: no reader exists yet, and every document that the first assessor writes under revision 1 is valid under revision 2.

## 2. Two parts and three digests

The document has two members beside `format`.

- **`evidence`** holds what was assessed and what was found: the target, the inputs, the conditions, the coverage, and the results. For exact results it is a function of the inputs. It holds no time of day, no duration of the assessor’s own run, no machine name, and no absolute path. Two things that look like exceptions are data: the bounds of a time window, which define the population, and a duration that is a measured value.
- **`run`** holds what differs between two runs over the same inputs: when the run started and ended, how long it waited and ran, the resolved local inputs, and pointers to logs. Nothing in `run` changes how the results of this run are judged. A window over the runs of a plan (design § 3) reads `run.ended_at` to place a run, and a run without `run` is placed by the time it reached the record store.

A document with a sampled result has `run.started_at` and `run.ended_at`, so two observations are two records. A document whose results are all exact can leave `run` out. The same inputs then give the same file, byte for byte.

| Digest | Over | Written as | Answers |
| --- | --- | --- | --- |
| Evidence digest | The bytes of the value of `evidence` as written in the file, from its `{` to the matching `}` | `sha256:<hex>`. Not a member of the document. | Did two runs find the same thing? The same inputs give the same evidence digest. |
| Record id | The bytes of the file | `run:<hex>` (design § 6). Not a member of the document. | Which record is this? |
| File digest | The bytes of a file that the document names: the target document, an input file | `sha256:<hex>`, with `digest_form: bytes` beside it | Which file was read? |

Every digest is SHA-256 over bytes as they were written (U9). The format fixes no key order and no white space. It asks one thing of a writer: the same inputs give the same bytes of `evidence`. Neither the evidence digest nor the record id is stored in the document; whoever needs one computes it.

**The evidence digest by hand.** The record id is `sha256sum` of the file. The evidence digest is over a span of it, found without parsing and writing the JSON again, which would give other bytes:

1. Read the file as bytes and find the member `evidence` of the top-level object.
2. From the `{` that opens its value, count each `{` up and each `}` down until the count is back at 0. A brace inside a JSON string is not counted: a string runs from a `"` to the next `"` that no `\` escapes.
3. The bytes from that `{` to that `}`, both included, are the span. `sha256:` and the 64 lowercase hex digits of their SHA-256 are the evidence digest.

§ 6 states the evidence digest of its first example, and `spec/record-examples.test.sh` applies this recipe to that example as the block stands in this document.

**When ESS has a canonical form.** ESS defines no canonical form of a document today, and the consumer has filed that gap with ESS.

- A file digest of an ESS document then names the form: `digest_form` takes the name ESS gives it. `digest_form` is a label that the assessor declares and Ratchet compares for equality, as a unit is, so this is no new version of the format. One document has another digest under another form. Evidence is matched to a candidate by `candidate` and `digest_form` together, so a run recorded under `bytes` is assessed again. Accepted values hold no digest and stay.
- The evidence digest and the record id stay over bytes in version 1. A canonical form for the JSON of this format would let a reader compute the evidence digest after parsing. It changes every id, so it is version 2.

## 3. Fields

The column **From** says where a field comes from. `spec`: the field is in the specification with this meaning, and only its place in the JSON may differ. `changed`: it is in the specification with another name, type, or number. `new`: the specification does not have it. `§` is a section of the design. Specification types are in the domain `ratchet.evidence` unless they say otherwise.

There are 78 fields: 48 `spec`, 7 `changed`, 23 `new`. The fields of an assessor’s declaration are in § 10 and are not counted here. The column compares with the specification at revision 3. Since 2026-11-24 the specification declares every row of these tables and of § 10 under the name the row gives, and `spec/record-fields.test.sh` checks that in the gate (§ 8).

### Top level

| Field | Type | Required | Meaning | From |
| --- | --- | --- | --- | --- |
| `format` | text | yes | `ratchet-evidence/1` | new: § 6, records are versioned JSON |
| `evidence` | object | yes | The part under the evidence digest (§ 2) | new: U8 |
| `run` | object | with a sampled result | The part outside the evidence digest (§ 2) | new: U8 |

### `evidence`

| Field | Type | Required | Meaning | From |
| --- | --- | --- | --- | --- |
| `project` | text | yes | The `project` of the quality specification that holds the plan | spec: `AssessmentRun.project` |
| `assessment` | text | yes | The key of the plan under `assessments` | spec: `AssessmentRun.assessment` |
| `assessor` | text | yes | The assessor and its version, `ux-static@1` | spec: `AssessmentRun.assessor`; § 6 |
| `protocol_version` | text | no | The version of the assessment protocol. A change that affects comparability starts a new evidence series (§ 5). | spec: `AssessmentRun.protocol_version` |
| `candidate` | text | exactly when `target.selection` is present | The identity the evidence is attributable to: the commit id for a target of the kind `revision`, the digest of the document for `document`, the artifact digest for `build`, and for `workflow_run` the commit id the run ran at, equal to `target.revision`. Under `target.selection: merge_result` it is the revision under judgement, such as the head of a pull request, and not the merged tree, which is `target.revision` | changed: `AssessmentRun.candidate` is required and a revision |
| `target` | object | yes | The resolved target (§ 3) | spec: `ResolvedTarget` |
| `inputs` | map from an input name to an input | no | The resolved value of each input of the plan that is not local (§ 4) and is not the target (§ 10) | new: § 4, § 6 |
| `completion` | text | yes | `completed`, `timed_out`, `stopped_by_infrastructure`, `skipped_locally`, or `refused_inputs`. The CLI writes the document of a run whose assessor left none (§ 10). | changed: `RunCompletion`; `refused_inputs` is a new value (E9) |
| `conditions` | object | yes | The observed conditions. A declared condition that is absent is unknown (§ 6). One that nobody declares does not apply (below, `evidence.conditions`). | spec: `ObservedConditions` |
| `coverage` | object | yes | How much of the plan the run executed (§ 3) | spec: `EvidenceCoverage` |
| `results` | list of results | yes | One result per output, scope item, boundary, and aggregation. Empty when nothing ran. | changed: `AssessmentRun.results` is a map keyed by measurement name (E3) |
| `source` | object | exactly for an imported run | Where an imported run came from (§ 6) | spec: `ImportSource` |

### `evidence.target`

| Field | Type | Required | Meaning | From |
| --- | --- | --- | --- | --- |
| `kind` | text | yes | `revision`, `build`, `deployment`, `workflow_run`, `telemetry_population`, or `document` | changed: `ResolvedTarget.kind`; `document` is a new value (E1) |
| `class` | text | yes | Where the evidence was produced: `local`, `ci`, `ephemeral`, `staging`, or `production` | spec: `ResolvedTarget.class` |
| `selection` | text | no | `candidate` or `merge_result`. Absent: the evidence is attributable to no candidate (§ 3). Under `merge_result`, `candidate` is the revision under judgement and `revision` the merged tree that was read, two different commits. | spec: `ResolvedTarget.selection` |
| `revision` | text | no | The repository revision the target was read at, where there is one. The assessor writes the revision it is given and looks none up (§ 10). Absent for `document`. | spec: `ResolvedTarget.revision` |
| `identifiers` | map from text to text | for `document` | The identifiers of § 3 by name: `lockfile`, `environment_id`, `artifact_digest`, `workload_version`, `service`, `region`, `cohort`. For `document`: `digest`, `digest_form`, and `path` where the document is a file of the tree. A document outside the tree has no `path` (§ 1). For `workflow_run`: `run_id`, the forge’s id of the run, as text, and `job`, `<workflow> / <job>`, the file name of the workflow and the key of the job in it; two jobs of one run are two records with the same `run_id`. The map stays open (E5). | spec: `ResolvedTarget.identifiers` |
| `window` | object | exactly for a time-window plan | The window that was read (§ 3) | spec: `ResolvedTarget.window` |

### `evidence.target.window`

| Field | Type | Required | Meaning | From |
| --- | --- | --- | --- | --- |
| `starts_at` | time | yes | The start of the window | spec: `Window.starts_at` |
| `ends_at` | time | yes | The end of the window: when the plan was assessed | spec: `Window.ends_at` |
| `items` | count | yes | The number of population items in the window | new: § 3 time windows, § 6 |
| `newest_at` | time | when `items` is above 0 | The time of the newest item | new: § 3 time windows, § 6 |
| `left_out` | count | yes | Runs left out because they did not qualify under the source plan | new: § 3 time windows, § 6 |

### `evidence.inputs.<name>`

| Field | Type | Required | Meaning | From |
| --- | --- | --- | --- | --- |
| `value` | text, count, boolean, or a list of these | yes, unless it is a path outside the tree | The value the plan passed, after defaults. A path and a decimal are text. | new: § 4 inputs |
| `digest` | digest | for a path that was read | The file digest of the file at that path | new: U9 |
| `digest_form` | text | with `digest` | `bytes` (§ 2) | new: U9 |

### `evidence.conditions`

| Field | Type | Required | Meaning | From |
| --- | --- | --- | --- | --- |
| `runner` | text | no | The runner that ran | spec: `ObservedConditions.runner` |
| `host_load_per_cpu` | object | no | The 1-minute load average over the run, divided by the number of CPUs (§ 3) | spec: `HostLoad` |
| `host_load_per_cpu.mean` | decimal | yes | The mean, which the declared bound applies to | spec: `HostLoad.mean` |
| `host_load_per_cpu.min` | decimal | yes | The lowest reading | spec: `HostLoad.min` |
| `host_load_per_cpu.max` | decimal | yes | The highest reading | spec: `HostLoad.max` |
| `tools` | map from a tool to its version | no | The resolved version of each tool, the assessor’s own included | spec: `ObservedConditions.tools` |
| `cache_profile` | text | no | The cache profile, such as `warm` | spec: `ObservedConditions.cache_profile` |
| `other` | map from text to text | no | Every further condition that the plan or the assessor declares | spec: `ObservedConditions.other` |

**The cache condition.** A plan and a declaration write the cache condition as `cache_profile`, the key of its row above, and under no other name; a record holds it in `cache_profile` and not under `other`.

**Unknown, or not applicable** (Q13). A condition is read only where it is declared: by the plan, for the class of the run, or by the assessor in its declaration (§ 10). A declared condition that the document does not hold is unknown, and the evidence does not qualify for a gate (design § 6). A condition that neither declares does not apply to the run, and its absence says nothing. `ux-static@1` declares no condition and reads no viewport, so its documents hold `tools` alone and no viewport is unknown. The format has no value for “does not apply”: the declaration says it once, for every run.

### `evidence.coverage`

| Field | Type | Required | Meaning | From |
| --- | --- | --- | --- | --- |
| `unit` | text | yes | The assessor’s coverage unit, such as `walk`, `test`, or `check` | new: § 3 evidence coverage, § 6 (G29) |
| `executed` | count | yes | Units that ran and gave a result | spec: `EvidenceCoverage.executed` |
| `skipped` | count | yes | Units that the run left out on purpose | spec: `EvidenceCoverage.skipped` |
| `not_run` | count | yes | Units that should have run and did not | spec: `EvidenceCoverage.not_run` |
| `unsupported` | count | yes | Units that the assessor cannot evaluate | spec: `EvidenceCoverage.unsupported` |
| `passed` | count | yes | Executed units whose own outcome is a pass | spec: `EvidenceCoverage.passed` |
| `failed` | count | yes | Executed units whose own outcome is a fail | spec: `EvidenceCoverage.failed` |
| `executed_ids` | list of text | no | The ids of the executed units, for a plan that declares `executed_ids` | spec: `EvidenceCoverage.executed_ids` |
| `not_executed` | list | no | The units that were not executed, each with its state and reason | new: U3 |
| `not_executed[].id` | text | yes | The id of the unit, in the assessor’s spelling. Unique within the run, and the same for the same unit in every run (rule 4). | new: U3 |
| `not_executed[].state` | text | yes | `skipped`, `not_run`, or `unsupported` | new: U3 |
| `not_executed[].reason` | text | no | Why the unit did not execute | new: U3 |

The design names the four counts and does not say what tells `skipped` from `not_run`. The meanings above are a proposal.

A unit is one piece of work, and it is counted once, however often the inputs name it (Q1). Where the unit is a check, one rule applied to one node for one scope item is one check: a node that a journey lists among its required nodes and as its signal is checked once for that journey. The same node under two scope items is two checks.

### `evidence.results[]`

| Field | Type | Required | Meaning | From |
| --- | --- | --- | --- | --- |
| `output` | text | yes | The output of the assessor that the result belongs to | spec: `MeasurementResult.output` |
| `kind` | text | yes | `exact` or `sampled` | spec: `MeasurementResult.kind` |
| `scope` | text | yes | The scope the result was observed at: `run`, or one the assessor declares | spec: `MeasurementResult.scope` |
| `item` | text | exactly when `scope` is not `run` | The scope item: the journey, the page, the test. The same spelling in every run, because accepted values are kept per item. | changed: `MeasurementResult.scope_item` |
| `boundary` | text | no | The part of a duration: `run_time`, `queue_wait`, or one the assessor declares | spec: `MeasurementResult.boundary` |
| `value_type` | text | yes | `number`, `identity_set`, `digest`, or `assertion`. It decides which of the members below the result has. | spec: the tag of `MeasuredValue` |
| `incomplete` | object | no | Present when the result has no value, or less than the whole value (U5, U6) | new: U5 |
| `incomplete.cause` | text | yes | One of the causes of insufficient evidence of § 5. One cause, also when several apply (§ 5, U5). | new: U5; `ratchet.gate.VerdictCause` |
| `incomplete.detail` | text | no | One sentence for the reader of a report | new: U5 |
| `details` | any JSON | no | What the assessor wants kept beside the result. Ratchet stores it and compares nothing in it. | new: U3, U4 |

A result of the value type `number`:

| Field | Type | Required | Meaning | From |
| --- | --- | --- | --- | --- |
| `value` | decimal | unless `incomplete` | The value | spec: `NumberValue.value` |
| `unit` | text | exactly when the assessor declares a unit for the output | The unit (§ 3) | spec: `NumberValue.unit` |
| `at_least` | boolean | no | `true`: the value is a lower bound (U6). Absent means `false`. | spec: `NumberValue.at_least` |
| `samples` | count | with `aggregation`, and for a sampled result | The number of samples or runs behind the value | changed: `AssessmentRun.samples` is one number per run |
| `aggregation` | object | no | The aggregation the value already is, in the plan’s shape: `{kind: percentile, parameter: 95}` (§ 3) | new: § 3 measurement kind, § 6 |

A result of the value type `identity_set`:

| Field | Type | Required | Meaning | From |
| --- | --- | --- | --- | --- |
| `key` | list of text | yes | The identity key, such as `[rule, node_path]` | spec: `IdentitySet.key` |
| `items` | list | yes | The items found for this scope item. Empty when nothing was found: on a complete result the item was evaluated, and on an incomplete one it was not, or not wholly (rule 8). | changed: `IdentitySet.items` is a list of free objects |
| `items[].identity` | object | yes | Exactly the fields of the key. A field can be a map (§ 3). | new: U4; § 3 reference record (G28) |
| `items[].fields` | object | no | The item fields the assessor declares, such as severity, message, and location. A measurement’s `filter` reads them. | new: U4; § 3, § 4 |

A result of the value type `digest` or `assertion`:

| Field | Type | Required | Meaning | From |
| --- | --- | --- | --- | --- |
| `digest` | digest | for `digest`, unless `incomplete` | The digest of a generated file (§ 5) | spec: `DigestValue.digest` |
| `holds` | boolean | for `assertion`, unless `incomplete` | Whether the assertion holds for this scope item (§ 3) | spec: `AssertionValue.holds` |

### `evidence.source`

| Field | Type | Required | Meaning | From |
| --- | --- | --- | --- | --- |
| `kind` | text | yes | `forge_runs`, `build_pool_log`, or `junit` | spec: `ImportSource.kind` |
| `location` | text | yes | The forge run, the job log, or the file that was read | spec: `ImportSource.location` |

### `run`

| Field | Type | Required | Meaning | From |
| --- | --- | --- | --- | --- |
| `started_at` | time | with a sampled result | When the run started | spec: `AssessmentRun.started_at` |
| `ended_at` | time | with a sampled result | When the run ended | spec: `AssessmentRun.ended_at` |
| `queue_wait` | duration | no | How long the run waited before it started, where the runner or build pool reports it (§ 3) | spec: `AssessmentRun.queue_wait` |
| `run_time` | duration | no | How long the run ran | spec: `AssessmentRun.run_time` |
| `local_inputs` | map from an input name to text | no | The resolved value of each local input on this machine (§ 5, local config, rule 6) | new: § 5, § 6 (G27) |
| `artifacts` | list of text | no | Pointers to logs, traces, and reports (§ 5, § 6) | spec: `AssessmentRun.artifacts` |

## 4. Rules

A reader checks these and rejects a document that breaks one.

1. `candidate` is present exactly when `target.selection` is.
2. `item` is absent exactly when `scope` is `run`.
3. `results` holds at most one result per `output`, `scope`, `item`, `boundary`, and `aggregation`.
4. Each unit is in one of `executed`, `skipped`, `not_run`, and `unsupported`, and is counted once (§ 3, `evidence.coverage`). `passed` plus `failed` is at most `executed`: a unit that is counted and not judged, such as a step, is executed and neither. `not_executed`, where present, has one entry per unit of the other three counts. The id of a unit is unique within the run: no id is twice in `executed_ids` and `not_executed` taken together. The same unit has the same id in every run.
5. A result is complete or incomplete. A complete result has the value of its type and no `incomplete`. An incomplete result has `incomplete`, and either no value or less than the whole one: a number with `at_least`, or the items of a set that were found.
6. `at_least: true` appears only on an incomplete result.
7. When `completion` is not `completed`, every result is incomplete, with the cause of that completion (§ 5, U5).
8. An output of the value type `identity_set` has a result for every scope item that the run was to evaluate. The result is complete when the item was evaluated, also when the set is empty. It is incomplete when the item was not evaluated or not wholly, also when the set is empty (§ 5, U3). No result means that the inputs of the run hold no such item. An assessor does not leave a result out to say that it could not evaluate an item.
9. `evidence` holds no time outside `target.window` and no absolute path. A file outside the tree has no path there (§ 1).

Rules 1 to 7 and 9 can be checked on one document, with two exceptions in rule 4: that a unit is counted once, and that its id is the same in every run. Those two and rule 8 need the inputs or a second run. They bind the assessor, and a reader cannot check them.

A measurement of the plan reads the results whose `output`, `scope`, `boundary`, and `aggregation` are its own. A requirement that reads an incomplete result returns insufficient evidence with the cause of the result, unless a lower bound proves a fail (§ 5, U6).

## 5. Decisions for the consumer’s gaps

| Gap | Decision | Reason | Owner |
| --- | --- | --- | --- |
| U1 the format | `ratchet-evidence/1`: one JSON document per run, written by the assessor, with the fields of § 3 | The run is one entity and one record already, and one document keeps the one set of coverage counts that design § 3 asks for | E3, E5 |
| U2 target kind | A target kind `document`. `candidate` is the digest of the document. The other files that the assessor reads are `inputs`. | A design variant is a digest that may never be committed, and “variant” is a scope already | E1 |
| U3 ACT outcomes | passed and failed are executed units. cantTell is an unsupported unit, listed in `not_executed`. inapplicable is no unit. Table below. | No new count: “the assessor cannot evaluate this unit” is what `unsupported` counts | E2 |
| U4 findings | Findings are the results of an output of the value type `identity_set`, one result per scope item. An item is `{identity, fields}`. | An identity set is a value type already, and the item of a reference record is `{identity, reason, owner}` already; a separate list would be a second place for the same items | |
| U5 causes | `incomplete.cause` takes the causes of design § 5. Table below. | One vocabulary from the assessor to the gate report | |
| U6 lower bound | `value` with `at_least: true` on an incomplete result | Design § 3 has the words “at least the limit”, and the specification has the field | E6 |
| U7 direction | Nothing in the evidence. `better` is declared on the plan’s measurement. | Closed in revision 3 | |
| U8 digested part | `evidence` is under the evidence digest. Times are in `run`. An assessor whose results are all exact writes no `run`. | The same inputs then give the same bytes, and a sampled run stays a record of its own | E4 |
| U9 digest over bytes | Every digest is over bytes, and a file digest says so with `digest_form: bytes`. § 2 says what changes with a canonical form. | The form is named where the digest is, so a later form needs no new version | |

### U3. ACT outcomes

The consumer’s rules give one outcome per rule and node, in the terms of the W3C ACT Rules Format. Its coverage unit is the **check**: one rule applied to one node or step, for one scope item. A node that the inputs name twice for one scope item is one check (rule 4, Q1).

| Outcome of a check | Coverage | Results | Verdict of a requirement that reads the result |
| --- | --- | --- | --- |
| passed | `executed` and `passed` | Nothing of its own | Counts toward a pass |
| failed | `executed` and `failed` | One more in the count; one item in the set | Fail by the comparison: `limit_crossed`, `new_items`, or `assertion_not_held` |
| cantTell | `unsupported`, with an entry in `not_executed` | The results of its scope item are incomplete, with the cause `coverage_below_plan`. A count becomes a lower bound. | Insufficient evidence, `coverage_below_plan`. A fail when the bound alone breaks the limit, or when an item that was found is new (E6). |
| inapplicable | None. It is not a unit. | The scope item still has its results, both complete: a count of 0 and an empty set. An assertion has no result for it. | None of its own |

A plan that declares `coverage: {unsupported: {max: 0}}` returns insufficient evidence as soon as one check is cantTell, for every requirement of the plan that no bound fails (E6). The counts per scope item, in the assessor’s own spelling, belong in `details`.

**A scope item without a check** has one of two results, and the assessor knows which.

| Case | Example | Results of the scope item | Coverage |
| --- | --- | --- | --- |
| The assessor evaluated the item and no check applies (Q7) | A page with no node that needs a name | Complete: the value `0` and an empty set. The rule looked at the whole page and found nothing to judge. | No unit |
| The assessor lacks what says which checks apply (Q4) | The declarations name no required node and no signal for a journey | Incomplete, with the cause `coverage_below_plan`: a number without a value, and an empty set. Never no result (rule 8), and never a complete `0`, which would read as a pass. | No unit, and no entry in `not_executed` |

The first is a fact about the candidate, and the second is a fact about the assessment.

### U5. Causes

The assessor gives no verdict. It says why a result is incomplete, in the words the gate will use.

| Draft cause | When | Cause of § 5 | Coverage |
| --- | --- | --- | --- |
| `coverage` | The assessor cannot evaluate a unit: a cantTell node, a step keyword it does not know, a step on a node where the document alone cannot say what is drawn (Q2) | `coverage_below_plan` | The unit is `unsupported` |
| `input` | A step names a node path that the document does not have: the journey cannot be followed on this document | `incompatible_target` | The step is `not_run` |
| `declaration` | Nothing is declared to measure for the scope item (Q4) | `coverage_below_plan` | No unit: the item executed none |

The line between the first two rows is what the assessor knows about the node. It cannot tell whether the node is there: `unsupported`. It can tell that the node is not there: `not_run`.

Of the 14 causes, an assessor can observe seven: `too_few_samples`, `assessor_timed_out`, `assessor_infrastructure_failure`, `stale_telemetry`, `incompatible_target`, `coverage_below_plan`, and `tool_mismatch`. The other seven are the gate’s; one of them, `evidence_missing`, was added on 2026-11-24 for a requirement with no qualifying run (design § 5, “Verdicts”). `completion` maps the same way: `timed_out` is `assessor_timed_out`, `stopped_by_infrastructure` is `assessor_infrastructure_failure`, `skipped_locally` is `skipped_locally`, and `refused_inputs` is `incompatible_target` (E9).

**One cause per result** (Q3). `incomplete.cause` holds one cause, because the verdict that reads it has one (design § 5). When several apply to one result, the assessor writes the first of them in this order, and `detail` names every one:

1. the cause of `completion`, when the run did not complete (rule 7);
2. `tool_mismatch`;
3. `coverage_below_plan`;
4. `incompatible_target`;
5. `stale_telemetry`;
6. `too_few_samples`.

The first two hold for every result of the run. `coverage_below_plan` comes before `incompatible_target`, as the first assessor has it: a journey with an unknown step and a step on a missing node reports `coverage_below_plan`. A plan that bounds `unsupported` or `not_run` reports that cause for such a run too (design § 3), so one run shows one word. A list of causes in place of the one would change the member and the verdict of design § 5, and is not version 1.

### U6. A lower bound

`"value": "2", "at_least": true` says that the true value is 2 or more. The assessor stopped counting, or could not count everything.

- A limit or an accepted value that the bound already breaks gives a fail: `eq 0` and `lte 1` are broken by “at least 2”, and the report shows those words. This is the rule of design § 3 for a run that reached its time limit (E6).
- Every other comparison returns insufficient evidence with the cause of the result. A bound never gives a pass, and it is never adopted as an accepted value.
- A bound of 0 says nothing. The assessor leaves the value out.
- An assessor that knows a bound above 0 writes it (Q6). A bound is a value that the missing part can only keep or raise. The actions of a journey with one step that the assessor does not know are at least the actions of its other steps, so that sum is the bound. Without it, a fail that the run proves is reported as insufficient evidence (E6). A document that leaves a bound out is still valid: a reader cannot know that one existed.
- A result has no bound when the value does not exist on this target. A journey with a step on a missing node cannot be followed on the document. It has no number of actions there, so its result has no value, whichever cause it names.

An incomplete identity set is a bound of the same kind: it holds the items that were found, and more may exist.

### E1. Which target kind is a design variant or a document? (U2)

| | Does | Costs |
| --- | --- | --- |
| A | Adds `document` to the target kinds: one file identified by the digest of its bytes, committed or not. A design variant, an `ess-ui/1` document, and a report are documents. | A sixth value in a list that Ratchet closes. A document made of several files needs a rule for which file is the candidate. |
| B | Uses `build` with the identifier `artifact_digest`. | No new value. A generated document and a compiled artifact share a kind, and a plan cannot say which of the two its assessor supports. |
| C | Makes target kinds a list that the assessor declares, with `ui-variant` as the consumer’s. | Ratchet cannot compute the candidate identity of a kind it does not know, so it cannot check that evidence belongs to a candidate. |

**Decided: A** (2026-11-24). What would change the answer: a second consumer whose target is neither a revision nor one file.

### E2. Where do cantTell and inapplicable go? (U3)

| | Does | Costs |
| --- | --- | --- |
| A | cantTell is an `unsupported` unit. inapplicable is no unit. The counts per scope item stay in `details`. | Coverage alone does not tell a cantTell node from another unsupported unit; `not_executed` does. |
| B | Adds the counts `cant_tell` and `inapplicable` to the evidence and to the plan’s `coverage` keys. | Six count keys for every assessor, two of which only a rule-based assessor uses. Changes design § 3. |
| C | Counts cantTell as executed, with a third outcome beside passed and failed. | `executed` no longer means that the unit gave a result, and `unsupported: {max: 0}` no longer catches it. |

**Decided: A** (2026-11-24). What would change the answer: a requirement that must bound cantTell apart from other unsupported units.

### E3. Who writes the document, and what does a result name? (U1)

| | Does | Costs |
| --- | --- | --- |
| A | The assessor writes the document. A result names an output of the assessor. The CLI binds results to the plan’s measurements when it judges. The assessor is given `project` and `assessment`. | `results` is a list, where the specification has a map keyed by measurement name. A measurement’s `filter` is applied when the result is judged and is not stored. |
| B | The CLI writes the document from what the assessor returns, keyed by measurement name as in the specification. | A second format between the assessor and the CLI, which nothing names. The consumer cannot write evidence before the CLI exists. |
| C | Both: `ratchet-evidence/1` from the assessor as in A, and a record of its own that the CLI writes around it. | Two formats and two ids for one run. |

**Decided: A** (2026-11-24). A custom assessor “returns evidence in the same format as bundled assessors” (design § 4). What would change the answer: an output that several measurements read with different aggregations that the assessor cannot know.

### E4. What does the id of a run digest? (U8)

| | Does | Costs |
| --- | --- | --- |
| A | `run:<hex>` digests the whole file. The evidence digest is a second digest, over `evidence` alone. An exact assessor writes no `run`, so its file and its id are the same for the same inputs. | Two digests. The same evidence written with two `run` members has two ids. |
| B | `run:<hex>` digests `evidence` alone. | Two sampled runs of one candidate with equal values are one record. `adoption: {runs: N}` and `window: {last: N}` then count one where there were two. |
| C | As B, and a document with a sampled result carries its start time inside `evidence`. | A time in the digested part, and one field in two places by kind. |

**Decided: A** (2026-11-24). Design § 6 gives a record “a digest of its content” as its id. What would change the answer: references that must cite evidence and not a run. They then cite the evidence digest.

### E5. What does a reader do with a member it does not know? (U1)

| | Does | Costs |
| --- | --- | --- |
| A | Rejects it in `evidence` and ignores it in `run`. A new member of `evidence` is a new version. | A version for every addition to `evidence`. A reader keeps reading the old versions. |
| B | Ignores it everywhere. | A reader of version 1 judges a document whose values mean something else, without notice. |
| C | Rejects it everywhere. | A new pointer or duration in `run` needs a version too. |

**Decided: A** (2026-11-24). `details`, `identifiers`, `conditions.other`, and an item’s `fields` are the places an assessor extends without a version.

### E6. Does a failure stand when the run is below its coverage? (U3, U6)

| | Does | Costs |
| --- | --- | --- |
| A | A fail that a lower bound or a found item proves stands, also when the run is below the plan’s coverage. Such a run decides nothing else: every other requirement of the plan returns insufficient evidence. | One evaluation of a plan can return a fail and `coverage_below_plan`, and the report shows both. Design § 3 says that a run below its coverage is insufficient evidence and names no exception. |
| B | A run below its coverage is insufficient evidence for every requirement, as design § 3 says. The bound is shown and decides nothing. | A defect that the run found is reported as a problem of the assessment, and the agent is told to leave the candidate as it is (design § 5). |
| C | The plan decides, with a key of its own. | A key for a question that has the same answer in every project. |

**Decided: A** (2026-11-24). Design § 5 puts a fail first “because a fail is a result about the candidate”, and what a partial run found is true of the candidate. What would change the answer: an assessor whose partial runs report failures that a full run would not.

### E7. How does Ratchet give a run to an assessor? (Q10)

| | Does | Costs |
| --- | --- | --- |
| A | Arguments. `--project`, `--assessment`, `--root`, `--class`, `--out`, `--revision` where there is one, and one `--<input>` per input (§ 10). | The six names are reserved, and no input can take one. An assessor refuses an argument it does not know, so a new reserved argument is a new version of the declaration format. |
| B | Environment variables for the run (`RATCHET_PROJECT` and so on), and arguments for the inputs. | A run by hand reads variables that nobody set, and the command line alone does not repeat a run. The first assessor changes its command line. |
| C | One request document, with its path as the only argument. | A third format beside the evidence and the declaration. The first assessor reads a file where it reads arguments today. |

**Default: A. Taken as A for 0.1.0, 2026-11-24.** The first assessor chose it, the command line is the whole request, and it is the spelling of the `ratchet` commands themselves (design § 5). What would change the answer: an input with more structure than a list, such as a matrix of conditions.

### E8. Where is an assessor declared? (Q11)

| | Does | Costs |
| --- | --- | --- |
| A | A document of its own, `ratchet-assessor/1`: one YAML file per assessor and version, kept with the assessor (§ 10). | The file can disagree with the program. The CLI checks every evidence document against it, so a disagreement is an error at the first run and not a wrong verdict. Where Ratchet looks for the file is not decided (§ 9). |
| B | The program prints its declaration when asked. | `ratchet validate` runs a program of this machine to check a plan, so what a plan may say is read from a local binary and not from the trusted revision. |
| C | A block `assessors` in the project’s specification. | Every project that uses a packaged assessor copies its declaration, and `ratchet/1` gets a new top-level key. |

**Default: A. Taken as A for 0.1.0, 2026-11-24.** Where Ratchet looks for the file is decided with it: `<name>@<version>.assessor.yaml` in a source of `[catalog] sources` (§ 9; design § 5, “Local config”). Design § 4 has the assessor declare its outputs, and the specification has the assessor as an entity of its own with a version. What would change the answer: assessors that only one project uses, where a second file is overhead.

### E9. What is recorded when an assessor refuses its inputs? (Q12)

In every option the assessor exits 1 and writes no document, as the first assessor does. The options differ in what the CLI does next.

| | Does | Costs |
| --- | --- | --- |
| A | The CLI writes the run with a fifth completion, `refused_inputs`. A requirement that reads it returns insufficient evidence with the cause `incompatible_target`. | A fifth value in a list that Ratchet closes. `incompatible_target` then also covers an input that is unreadable. |
| B | The CLI records nothing. `ratchet assess` reports the refusal and exits non-zero. | The record store has no trace of the run. A gate finds no run for the candidate, and the design had no cause for that when the question was put (`evidence_missing` since 2026-11-24). |
| C | The CLI writes the run as `stopped_by_infrastructure`. | No new value. The report says `assessor_infrastructure_failure`, which reads as “run it again”, and the same inputs are refused again. |

**Default: A. Taken as A for 0.1.0, 2026-11-24.** None of the four values fits, as the consumer found: the run did not complete, reached no time limit, lost no infrastructure, and was not skipped. What would change the answer: a cause of its own for refused inputs in design § 5, which the completion would then map to.

## 6. Example

One run of `ux-static@1` over the consumer’s own UI document, its journeys, and its declarations. Since revision 2 the example is the document that the assessor writes, built at commit `edbbc27` of its repository, over the fixed copy of those inputs that its tests keep. Two things differ from the file it writes:

- The list of every node with its name, 53 entries under `details.items` of the results of `a11y.accessible_names@1`, is left out here. `details` is optional, so the document below is complete.
- The white space. The format fixes none (§ 2), and the assessor writes the part before `results` on one line.

So the evidence digest stated after the example is over its bytes as printed here, and not over those of the file the assessor wrote.

`project` and `assessment` are the arguments the run was given, and the names are illustrations.

The run is exact and has no `run` member. Coverage counts 95 checks: 20 declared nodes, 22 steps, and 53 nodes that need a name. The 73 checks on nodes have an outcome, and all passed; a step is counted and has none. Two journeys name their signal among their required nodes as well. Each of those nodes is one check (rule 4), where revision 1 counted it twice and showed 97 and 75 (Q1).

```json
{
  "format": "ratchet-evidence/1",
  "evidence": {
    "project": "uxui",
    "assessment": "studio-static",
    "assessor": "ux-static@1",
    "candidate": "sha256:7addf7e5edea0518081b6e9eaf92d5e857f2f579a561bd74f23e01fefe05e628",
    "target": {
      "kind": "document",
      "class": "local",
      "selection": "candidate",
      "identifiers": {"path":"ess/ui/studio.ui.yaml","digest":"sha256:7addf7e5edea0518081b6e9eaf92d5e857f2f579a561bd74f23e01fefe05e628","digest_form":"bytes"}
    },
    "inputs": {
      "journeys": {"value":"ess/ui/tests/studio.yaml","digest":"sha256:52a6291756d4e36fa3ba663114e77b26dc2d46f7c2ae874702f86a1e24f0cb4a","digest_form":"bytes"},
      "declarations": {"value":"ess/ui/studio.uxui.yaml","digest":"sha256:4bf0e72bdf937270b9f9135243721dc4fa69ad985196e0159fb52eb6a86782f6","digest_form":"bytes"}
    },
    "completion": "completed",
    "conditions": {"tools":{"ux-static":"0.1.0"}},
    "coverage": {"unit":"check","executed":95,"skipped":0,"not_run":0,"unsupported":0,"passed":73,"failed":0},
    "results": [
      {"output":"structure.required_present@1","kind":"exact","scope":"variant","item":"document","value_type":"number","value":"0","unit":"nodes","details":{"outcomes":{"passed":3,"failed":0,"cantTell":0}}},
      {"output":"structure.required_present@1","kind":"exact","scope":"journey","item":"stopping a running campaign asks first and sends the command","value_type":"number","value":"0","unit":"nodes","details":{"outcomes":{"passed":4,"failed":0,"cantTell":0}}},
      {"output":"structure.required_present@1","kind":"exact","scope":"journey","item":"a progress event lands in the live climb","value_type":"number","value":"0","unit":"nodes","details":{"outcomes":{"passed":2,"failed":0,"cantTell":0}}},
      {"output":"structure.required_present@1","kind":"exact","scope":"journey","item":"switching one axis of a variant sends the switch","value_type":"number","value":"0","unit":"nodes","details":{"outcomes":{"passed":3,"failed":0,"cantTell":0}}},
      {"output":"structure.required_present@1","kind":"exact","scope":"journey","item":"the owner sees what gets worse and is offered only the accept that applies","value_type":"number","value":"0","unit":"nodes","details":{"outcomes":{"passed":5,"failed":0,"cantTell":0}}},
      {"output":"structure.required_present@1","kind":"exact","scope":"journey","item":"starting a campaign from the catalog opens the form on that target","value_type":"number","value":"0","unit":"nodes","details":{"outcomes":{"passed":3,"failed":0,"cantTell":0}}},
      {"output":"effort.actions_per_journey@1","kind":"exact","scope":"journey","item":"stopping a running campaign asks first and sends the command","value_type":"number","value":"2","unit":"actions","details":{"items":[{"step":3,"keyword":"act","at":"pages/campaigns.list/sections/list/rows/cp-01/row_actions/stop"},{"step":4,"keyword":"act","at":"pages/campaigns.list/sections/list/rows/cp-01/row_actions/stop/confirm/overlay"}]}},
      {"output":"effort.actions_per_journey@1","kind":"exact","scope":"journey","item":"a progress event lands in the live climb","value_type":"number","value":"0","unit":"actions"},
      {"output":"effort.actions_per_journey@1","kind":"exact","scope":"journey","item":"switching one axis of a variant sends the switch","value_type":"number","value":"1","unit":"actions","details":{"items":[{"step":2,"keyword":"act","at":"pages/variants.detail/sections/axes/rows/av-04/row_actions/switch"}]}},
      {"output":"effort.actions_per_journey@1","kind":"exact","scope":"journey","item":"the owner sees what gets worse and is offered only the accept that applies","value_type":"number","value":"1","unit":"actions","details":{"items":[{"step":4,"keyword":"open","at":"pages/promotions.detail"}]}},
      {"output":"effort.actions_per_journey@1","kind":"exact","scope":"journey","item":"starting a campaign from the catalog opens the form on that target","value_type":"number","value":"1","unit":"actions","details":{"items":[{"step":2,"keyword":"act","at":"pages/targets.catalog/sections/list/rows/tg-02/row_actions/start"}]}},
      {"output":"a11y.accessible_names@1","kind":"exact","scope":"page","item":"pages/targets.catalog","value_type":"number","value":"0","unit":"nodes","details":{"outcomes":{"passed":2,"failed":0,"cantTell":0,"inapplicable":0}}},
      {"output":"a11y.accessible_names@1","kind":"exact","scope":"page","item":"pages/campaigns.start","value_type":"number","value":"0","unit":"nodes","details":{"outcomes":{"passed":10,"failed":0,"cantTell":0,"inapplicable":0}}},
      {"output":"a11y.accessible_names@1","kind":"exact","scope":"page","item":"pages/campaigns.list","value_type":"number","value":"0","unit":"nodes","details":{"outcomes":{"passed":6,"failed":0,"cantTell":0,"inapplicable":0}}},
      {"output":"a11y.accessible_names@1","kind":"exact","scope":"page","item":"pages/campaigns.climb","value_type":"number","value":"0","unit":"nodes","details":{"outcomes":{"passed":4,"failed":0,"cantTell":0,"inapplicable":0}}},
      {"output":"a11y.accessible_names@1","kind":"exact","scope":"page","item":"pages/campaigns.frontier","value_type":"number","value":"0","unit":"nodes","details":{"outcomes":{"passed":8,"failed":0,"cantTell":0,"inapplicable":0}}},
      {"output":"a11y.accessible_names@1","kind":"exact","scope":"page","item":"pages/variants.detail","value_type":"number","value":"0","unit":"nodes","details":{"outcomes":{"passed":2,"failed":0,"cantTell":0,"inapplicable":0}}},
      {"output":"a11y.accessible_names@1","kind":"exact","scope":"page","item":"pages/variants.compare","value_type":"number","value":"0","unit":"nodes","details":{"outcomes":{"passed":8,"failed":0,"cantTell":0,"inapplicable":0}}},
      {"output":"a11y.accessible_names@1","kind":"exact","scope":"page","item":"pages/promotions.list","value_type":"number","value":"0","unit":"nodes","details":{"outcomes":{"passed":1,"failed":0,"cantTell":0,"inapplicable":0}}},
      {"output":"a11y.accessible_names@1","kind":"exact","scope":"page","item":"pages/promotions.detail","value_type":"number","value":"0","unit":"nodes","details":{"outcomes":{"passed":9,"failed":0,"cantTell":0,"inapplicable":0}}},
      {"output":"a11y.accessible_names@1","kind":"exact","scope":"page","item":"pages/judgements.list","value_type":"number","value":"0","unit":"nodes","details":{"outcomes":{"passed":3,"failed":0,"cantTell":0,"inapplicable":0}}},
      {"output":"findings","kind":"exact","scope":"variant","item":"document","value_type":"identity_set","key":["rule","node_path"],"items":[]},
      {"output":"findings","kind":"exact","scope":"journey","item":"stopping a running campaign asks first and sends the command","value_type":"identity_set","key":["rule","node_path"],"items":[]},
      {"output":"findings","kind":"exact","scope":"journey","item":"a progress event lands in the live climb","value_type":"identity_set","key":["rule","node_path"],"items":[]},
      {"output":"findings","kind":"exact","scope":"journey","item":"switching one axis of a variant sends the switch","value_type":"identity_set","key":["rule","node_path"],"items":[]},
      {"output":"findings","kind":"exact","scope":"journey","item":"the owner sees what gets worse and is offered only the accept that applies","value_type":"identity_set","key":["rule","node_path"],"items":[]},
      {"output":"findings","kind":"exact","scope":"journey","item":"starting a campaign from the catalog opens the form on that target","value_type":"identity_set","key":["rule","node_path"],"items":[]},
      {"output":"findings","kind":"exact","scope":"page","item":"pages/targets.catalog","value_type":"identity_set","key":["rule","node_path"],"items":[]},
      {"output":"findings","kind":"exact","scope":"page","item":"pages/campaigns.start","value_type":"identity_set","key":["rule","node_path"],"items":[]},
      {"output":"findings","kind":"exact","scope":"page","item":"pages/campaigns.list","value_type":"identity_set","key":["rule","node_path"],"items":[]},
      {"output":"findings","kind":"exact","scope":"page","item":"pages/campaigns.climb","value_type":"identity_set","key":["rule","node_path"],"items":[]},
      {"output":"findings","kind":"exact","scope":"page","item":"pages/campaigns.frontier","value_type":"identity_set","key":["rule","node_path"],"items":[]},
      {"output":"findings","kind":"exact","scope":"page","item":"pages/variants.detail","value_type":"identity_set","key":["rule","node_path"],"items":[]},
      {"output":"findings","kind":"exact","scope":"page","item":"pages/variants.compare","value_type":"identity_set","key":["rule","node_path"],"items":[]},
      {"output":"findings","kind":"exact","scope":"page","item":"pages/promotions.list","value_type":"identity_set","key":["rule","node_path"],"items":[]},
      {"output":"findings","kind":"exact","scope":"page","item":"pages/promotions.detail","value_type":"identity_set","key":["rule","node_path"],"items":[]},
      {"output":"findings","kind":"exact","scope":"page","item":"pages/judgements.list","value_type":"identity_set","key":["rule","node_path"],"items":[]}
    ]
  }
}
```

The evidence digest of the example above is `sha256:a3b6301af6bbd4f089a8094634a592f26b7aa07f08d9478836aaee2a2c4fdd10`.

The sample has no finding and no incomplete result. The results below come from the same assessor over a copy of the inputs with four edits taken from its own tests: a chart replaced by a component the assessor does not know, a label emptied, a step with an unknown keyword added, and the declarations of one journey removed. They are the five incomplete results of that run, whose coverage is `executed: 93`, `unsupported: 2`, `passed: 70`, and `failed: 1`. The fourth is new in revision 2: the journey with nothing declared has an empty set that is incomplete, and not no result (rule 8, Q4).

```json
[
  {"output":"structure.required_present@1","kind":"exact","scope":"journey","item":"a progress event lands in the live climb","value_type":"number","unit":"nodes","incomplete":{"cause":"coverage_below_plan","detail":"the declarations name no required node and no signal for this journey"}},
  {"output":"effort.actions_per_journey@1","kind":"exact","scope":"journey","item":"a progress event lands in the live climb","value_type":"number","unit":"actions","incomplete":{"cause":"coverage_below_plan","detail":"step 4: `hover` is not a step ux-static@1 knows"}},
  {"output":"a11y.accessible_names@1","kind":"exact","scope":"page","item":"pages/campaigns.climb","value_type":"number","value":"1","unit":"nodes","at_least":true,"incomplete":{"cause":"coverage_below_plan","detail":"1 nodes whose name the document alone cannot give"},"details":{"outcomes":{"passed":3,"failed":1,"cantTell":1,"inapplicable":0}}},
  {"output":"findings","kind":"exact","scope":"journey","item":"a progress event lands in the live climb","value_type":"identity_set","key":["rule","node_path"],"items":[],"incomplete":{"cause":"coverage_below_plan","detail":"the declarations name no required node and no signal for this journey"}},
  {"output":"findings","kind":"exact","scope":"page","item":"pages/campaigns.climb","value_type":"identity_set","key":["rule","node_path"],"items":[{"identity":{"rule":"a11y.accessible_names@1","node_path":"pages/campaigns.climb/sections/hill_kpis/row_actions/show"},"fields":{"reason":"`label` is declared empty"}}],"incomplete":{"cause":"coverage_below_plan","detail":"1 nodes whose name the document alone cannot give"}}
]
```

The two checks that could not be evaluated are entries of `coverage.not_executed`. The spelling of `id` is the assessor’s: the rule, the scope item, and the node or the step. The rule at the scope `page` leaves the scope item out, because the node path starts with the page. An id is unique within the run (rule 4, Q5).

```json
[
  {"id":"effort.actions_per_journey@1 a progress event lands in the live climb step 4","state":"unsupported","reason":"`hover` is not a step ux-static@1 knows"},
  {"id":"a11y.accessible_names@1 pages/campaigns.climb/sections/hill","state":"unsupported","reason":"component `sparkline` is not an ess-ui/1 composite"}
]
```

Under E6 (A), a requirement `eq 0` on the accessible names of that page fails, because “at least 1” already breaks the limit. A requirement on the actions of that journey returns insufficient evidence with the cause `coverage_below_plan`. Its result has no value: the steps the assessor knows take 0 actions in that journey, and a bound of 0 says nothing (U6). In the journey that stops a campaign, the same unknown step gives `"value": "2", "at_least": true` under U6. The assessor writes that bound: `value` and `at_least` for a journey with an unknown step, where the bound is above 0 (Q6).

A run of a CI workflow: the plan `ci-gate-timing` of `examples/ci-turnaround.ratchet.yaml`, a target of the kind `workflow_run` with `selection: candidate`. The ids and times are illustrations. `run_id` and `job` name the run and its job (§ 3, `evidence.target`); a second job of the same run is a second record with the same `run_id`. `candidate` is the commit id the run ran at, the same as `target.revision`. The plan declares the condition `runner` for the class `ci`, and the results are sampled, so the document has `run` (§ 2).

```json
{
  "format": "ratchet-evidence/1",
  "evidence": {
    "project": "build-pool",
    "assessment": "ci-gate-timing",
    "assessor": "forge-workflow-timing@1",
    "candidate": "4b8e1f2a9c3d5e7f60a1b2c3d4e5f6a7b8c9d0e1",
    "target": {
      "kind": "workflow_run",
      "class": "ci",
      "selection": "candidate",
      "revision": "4b8e1f2a9c3d5e7f60a1b2c3d4e5f6a7b8c9d0e1",
      "identifiers": {"run_id":"19733281406","job":"gate.yml / gate"}
    },
    "inputs": {"workflow": {"value":"gate.yml"}},
    "completion": "completed",
    "conditions": {"runner":"ci-standard"},
    "coverage": {"unit":"run","executed":1,"skipped":0,"not_run":0,"unsupported":0,"passed":0,"failed":0},
    "results": [
      {"output":"duration","kind":"sampled","scope":"run","boundary":"run_time","value_type":"number","value":"24.6","unit":"min","samples":1},
      {"output":"duration","kind":"sampled","scope":"run","boundary":"queue_wait","value_type":"number","value":"1.8","unit":"min","samples":1}
    ]
  },
  "run": {"started_at":"2026-11-25T09:14:02Z","ended_at":"2026-11-25T09:38:38Z"}
}
```

A run on a pull request under `selection: merge_result`: the plan `regenerated-scenarios` of `examples/generated-artifact.ratchet.yaml`. The run checked out the merge of the head of the pull request into the trusted revision. `candidate` is the head, the revision under judgement, and `target.revision` the merge commit, the tree that was read: two different commit ids (§ 3, `evidence.candidate` and `evidence.target`). The ids, the paths, and the digests are illustrations. The results are exact, so the document has no `run`.

```json
{
  "format": "ratchet-evidence/1",
  "evidence": {
    "project": "protocol-compiler",
    "assessment": "regenerated-scenarios",
    "assessor": "generator-check@1",
    "candidate": "1a954628a960aaef81d7b2d4521929579f3541e6",
    "target": {
      "kind": "revision",
      "class": "ci",
      "selection": "merge_result",
      "revision": "14091a9f2461267ee7e02525b4f1f2923f1c9849"
    },
    "completion": "completed",
    "conditions": {"tools":{"ess":"0.97.4"}},
    "coverage": {"unit":"file","executed":3,"skipped":0,"not_run":0,"unsupported":0,"passed":0,"failed":0},
    "results": [
      {"output":"digest","kind":"exact","scope":"file","item":"conformance/scenarios/accept.yaml","value_type":"digest","digest":"sha256:4a914640d8fccf507beb813f1f09b1d5bf887f0162909f1c6ac05bd8acc48e16"},
      {"output":"digest","kind":"exact","scope":"file","item":"conformance/scenarios/refuse.yaml","value_type":"digest","digest":"sha256:6f1413daffe6465e4c9789c2a1d33fa54c11f0cc4a7f36a5244413905146018f"},
      {"output":"digest","kind":"exact","scope":"file","item":"conformance/scenarios/retry.yaml","value_type":"digest","digest":"sha256:5d80094427a2678b1b821895bb56f233501651c84f575420b22f7963c01e425f"}
    ]
  }
}
```

## 7. Mapping from the uxui draft

The draft is `ratchet-evidence/draft` as `docs/ux-static.md` and `engine/static/src/record.rs` define it on the consumer’s branch `ux-static`. The branch is not pushed, so nothing here links to it. `results[]` is short for `evidence.results[]`.

| Draft | `ratchet-evidence/1` | Note |
| --- | --- | --- |
| One JSON line per metric and scope item, 21 for the sample | One document per run; each line is one entry of `results[]` | The file is `<assessment>.evidence.json`, not JSON lines |
| `format: ratchet-evidence/draft` | `format: ratchet-evidence/1` | |
| `record: assessment-run` | Dropped | The format name says it |
| `id` | Dropped | The id is `run:<hex>` over the file (§ 2). A result is found by `output`, `scope`, and `item`. |
| `assessor` | `evidence.assessor` | |
| None | `evidence.project`, `evidence.assessment` | New and required. The assessor takes them as arguments. |
| None | `evidence.completion: completed` | New and required |
| `candidate.digest` | `evidence.candidate` | Text, not an object |
| `candidate.kind: ui-document` | Dropped | `target.kind` says it |
| `target.kind: ui-variant` | `evidence.target.kind: document` | E1 |
| `target.class` | `evidence.target.class` | |
| None | `evidence.target.selection: candidate` | Present because `candidate` is |
| `resolved_target.document.path`, `.digest` | `evidence.target.identifiers.path`, `.digest`, and `digest_form: bytes` | The path is relative to the root of the repository, never absolute |
| `resolved_target.journeys`, `resolved_target.declarations` | `evidence.inputs.journeys`, `evidence.inputs.declarations`, each `{value, digest, digest_form}` | `value` is the path |
| `resolved_target.journey` | Dropped | It is the `item` of the result |
| `resolved_target.tool`, `resolved_target.tool_version` | `evidence.conditions.tools`, as `{"ux-static": "0.1.0"}` | |
| `observation.kind`, `observation.runs` | Dropped | The plan declares the observation. An exact result has no `samples`. |
| `observation.conditions` | `evidence.conditions` | |
| `measurement.output` | `results[].output` | |
| `measurement.kind` | `results[].kind` | |
| `measurement.unit`, `unit` | `results[].unit` | Written once |
| `measurement.direction` | Dropped | `better` is on the plan’s measurement (U7) |
| `measurement.aggregation: count` | Dropped | A count is a number. `count` is no aggregation kind of design § 3. |
| `measurement.scope`, `scope.kind` | `results[].scope` | Written once |
| `scope.id` | `results[].item` | |
| None | `results[].value_type: number` | New and required |
| `result: measured` | No member | A result without `incomplete` is complete |
| `result: insufficient` | `results[].incomplete` | |
| `value`, a number or `null` | `results[].value`, as text | Absent in place of `null` |
| `value_at_least: N` | `value: "N"` and `at_least: true` | U6 |
| `insufficient.cause` | `results[].incomplete.cause` | `coverage` and `declaration` become `coverage_below_plan`, `input` becomes `incompatible_target` (U5) |
| `insufficient.detail` | `results[].incomplete.detail` | |
| `coverage`, one per record | `evidence.coverage`, one per run, with `unit: check` | The sums of the records. A cantTell node leaves `executed`, where the draft counts it in both. A step that names no node is `not_run`. |
| `outcomes.passed`, `outcomes.failed` | Summed into `evidence.coverage.passed` and `.failed` | |
| `outcomes.cantTell` | Summed into `evidence.coverage.unsupported` | |
| `outcomes`, per record | `results[].details.outcomes` | In the assessor’s spelling |
| `findings[]` with `outcome: failed` | An item of a result of the output `findings`: `{identity: {rule, node_path}, fields: {reason}}` | One result of the value type `identity_set` per scope item, also when it is empty (U4) |
| `findings[]` with `outcome: cantTell` | An entry of `evidence.coverage.not_executed`: `{id, state: unsupported, reason}` | A node that could not be judged is no finding |
| `items` | `results[].details.items` | |
| No time | No `run` member | The results are exact (U8) |

What the consumer changes beyond a rename:

1. It writes one document per run and not a line per record.
2. It takes `project` and `assessment` as arguments and writes `completion`, `value_type`, and `target.selection`.
3. It counts coverage once per run in one unit, with four counts that do not overlap, and adds `passed` and `failed`.
4. It writes findings as results of an output of its own, with failed nodes alone as items, and moves cantTell nodes to `coverage.not_executed`.
5. It writes values as text, leaves a value out where the draft writes `null`, and writes a lower bound as `value` with `at_least`.
6. It maps its three causes to two of design § 5.
7. It writes paths relative to the root of the repository.

The consumer made these seven changes in its commit `edbbc27`. What revision 2 asks of it beyond them is in § 11.

## 8. What the ESS specification needs

The format should later be a projection of the specification and not a second definition. Items 1 to 17 are against revision 3 of [`spec/`](https://github.com/beyond10x/ratchet/blob/main/spec/README.md). Revision 4 has since brought the coverage unit (10, 14), `local_inputs` (3), and the window counts (11, as `WindowItems` on the run, with other names). Items 18 to 25 are from revision 2 of this document, against revision 4.

**Status, 2026-11-24.** The specification now declares both formats. Each item ends with what was done about it: **Done**, with the spelling in the specification, or **Left out of 0.1.0**, with the reason. 19 items are done, 3 are done in part (4, 10, 25), and 3 are left out (15, 17, 24), all three because they are ESS’s to supply. `spec/record-fields.test.sh` reads every field row of § 3 and § 10 and fails the gate when the specification does not declare one under the name the row gives.

In [`spec/domains/evidence.yaml`](https://github.com/beyond10x/ratchet/blob/main/spec/domains/evidence.yaml):

1. **Two parts.** `AssessmentRun` holds `evidence` and an optional `run`, each a struct: `started_at`, `ended_at`, `queue_wait`, `run_time`, `artifacts`, and the new `local_inputs` in the second, every other field in the first. The projection then writes the two members, and the evidence digest has one subtree. **Done:** `AssessmentRun` holds `format`, `evidence` (the struct `ratchet.evidence.Evidence`), and an optional `run` (the struct `ratchet.evidence.RunDetails`). The record id is its identity, written `run_id`, because `run` is now a member.
2. **`candidate`.** Optional, and a candidate identity that is a commit id or a digest, where it is a required `Revision`. An invariant: present exactly when `target.selection` is. **Done:** `Evidence.candidate` is `Optional<ratchet.evidence.CandidateIdentity>`, with two invariants on `Evidence` for rule 1.
3. **`inputs`.** A map from an input name to `{value, digest, digest_form}`, and `local_inputs` as a map from an input name to text. **Done:** `Evidence.inputs` is `Optional<Map<String, ratchet.evidence.ResolvedInput>>`, and `RunDetails.local_inputs` is `Optional<Map<String, String>>`.
4. **`results`.** A list of `MeasurementResult`, where it is a map keyed by measurement name (E3). An invariant: at most one result per output, scope, item, boundary, and aggregation. **Done in part:** `Evidence.results` is `List<ratchet.evidence.MeasurementResult>`. **Left out of 0.1.0:** the invariant, rule 3. An ESS `distinct` takes one member as its key and not five, so the reader checks the rule.
5. **`MeasurementResult`.** `scope_item` is written `item`. New fields `incomplete` (`{cause, detail}`) and `details` (`Json`). The cause is one of the 13 causes of insufficient evidence, which are part of `ratchet.gate.VerdictCause` today: the list is split into the causes of a fail and the causes of insufficient evidence, so that the evidence domain can name the second. **Done:** `MeasurementResult.item`, `incomplete` (the struct `ratchet.evidence.Incomplete`), and `details`. The list is split into `ratchet.gate.FailCause`, with 7 values, and `ratchet.gate.InsufficientEvidenceCause`, with 14: the 13 and `evidence_missing`, which only a gate names. `VerdictCause` keeps both lists for a row that holds either.
6. **`MeasuredValue`.** Its members are written in the result, beside `value_type`, and not one level down under `value`. **Done:** `MeasuredValue` and its four structs are gone. `MeasurementResult` holds `value_type` and every value member as an optional field, and invariants say which members a value type has. An ESS union would write its payload one level down.
7. **`NumberValue`.** `value` is optional, for an incomplete result. `at_least` is optional and absent means false. `samples` moves here from `AssessmentRun`. A new optional `aggregation`, of the type the plan uses. **Done:** `MeasurementResult.value` (`Optional<Decimal>`), `unit`, `at_least` (`Optional<Boolean>`), `samples`, and `aggregation` (`Optional<ratchet.specification.Aggregation>`), with the invariants of rules 5 and 6, and two for `samples` as § 3 has it: present with `aggregation`, and present on a number whose `kind` is `sampled`.
8. **`IdentitySet.items`.** A list of `{identity, fields}`, where it is a list of `Json`. `identity` has the shape of the reference record’s item in revision 4 (G28). **Done:** `MeasurementResult.key` and `MeasurementResult.items`, an `Optional<List<ratchet.evidence.IdentityItem>>`.
9. **`DigestValue.digest` and `AssertionValue.holds`.** Optional, for an incomplete result. **Done:** `MeasurementResult.digest` (`Optional<ratchet.evidence.Digest>`) and `MeasurementResult.holds` (`Optional<Boolean>`).
10. **`EvidenceCoverage`.** A new `unit`. A new optional `not_executed`, a list of `{id, state, reason}`, with `state` one of `skipped`, `not_run`, and `unsupported`. Two invariants: the four counts do not overlap, and `passed` plus `failed` is at most `executed`. **Done in part:** `EvidenceCoverage.unit` and `not_executed` (a list of `ratchet.evidence.NotExecutedUnit`, with `state` a `ratchet.evidence.NotExecutedState`). The overlap is the invariant of item 19. `passed` and `failed` are each at most `executed`. **Left out of 0.1.0:** the sum. An ESS comparison reads one fact on each side and no sum of two, so `passed + failed <= executed` is refused, and the reader checks it.
11. **`Window`.** New `items`, `newest_at`, and `left_out`. **Done:** `Window.items`, `newest_at`, and `left_out`, with an invariant: a window with items names the newest. `WindowItems` is gone.
12. **`RunId`.** Its summary says which bytes the digest is over (E4). **Done:** the summary of `ratchet.evidence.RunId`.

In the other domains:

13. [`specification.yaml`](https://github.com/beyond10x/ratchet/blob/main/spec/domains/specification.yaml): `TargetKind` gets `document` (E1). **Done:** `ratchet.specification.TargetKind` has `document`.
14. [`assessor.yaml`](https://github.com/beyond10x/ratchet/blob/main/spec/domains/assessor.yaml): one coverage unit on `Assessor`, in place of `coverage` on each `AssessorOutput` (G29). **Done**, since revision 4: `Assessor.coverage_unit` and `Assessor.coverage`.

From ESS, and not from this specification:

15. A projection of an entity as one JSON document with a constant `format` member: `Decimal` as text, `Timestamp` as UTC text, `Duration` as decimal seconds, and an absent member for an empty `Optional`. **Left out of 0.1.0:** ESS has no such projection. `ess generate synthesize --target rust` writes the types, a `broken_constraint` check on each type with invariants, the lifecycles of the entities, and the JSON helpers of `json.rs`. It writes nothing that reads a file into the types: what reads the file form of § 1 is settled by the story that builds the workspace. `AssessmentRun.format` is declared with the invariant `format == "ratchet-evidence/1"`. One difference is open until that reader exists: ESS writes a `Duration` as an ISO 8601 duration, such as `P30D`, and § 1 writes decimal seconds for `run.queue_wait` and `run.run_time`. § 1 stands until then.
16. A way to say that a reader rejects an unknown member in one struct and ignores it in another (E5). **Done:** ESS has it. `Evidence` and the structs under it are closed, which is the default, and `RunDetails` declares `undeclared_fields: ignored`. The key is a declaration: it changes nothing in the synthesized crate, and the reader of item 15 applies it.
17. A canonical form of a document (U9). The consumer has filed it. **Left out of 0.1.0:** ESS defines none, so every digest stays over bytes (§ 2).

From revision 2, in [`spec/domains/evidence.yaml`](https://github.com/beyond10x/ratchet/blob/main/spec/domains/evidence.yaml):

18. **`RunCompletion`.** A fifth value, `refused_inputs`, which maps to the cause `incompatible_target` (E9). The comment above the type says which completions the CLI writes and which the assessor writes (§ 10). **Done:** the value and the comment, and five invariants on `Evidence` for rule 7: every result of a run that did not complete is incomplete, and for each of the four other completions its results name the cause of that completion.
19. **`EvidenceCoverage`.** An invariant: no id is twice in `executed_ids` and `not_executed` taken together (rule 4). Its summary says that a unit is counted once. **Done:** three invariants (the ids of `not_executed` are distinct, those of `executed_ids` are distinct, and none is in both) and the summary.
20. **`ObservedConditions`.** Its summary says that an absent value is unknown only for a condition that the plan or the assessor declares (Q13). **Done:** the summary. `tools` and `other` are optional, as § 3 has them.
21. **`ResolvedTarget.identifiers`.** Its summary names the identifiers of a `document`: `digest`, `digest_form`, and `path`, which is absent for a document outside the tree (Q8). **Done:** the summary, and two invariants: a target of the kind `document` has `identifiers` and no `revision`.
22. **The input of item 3.** `value` is optional, for a path outside the tree. **Done:** `ResolvedInput.value` is `Optional<Json>`, with the invariants that an input has `value` or `digest`, and `digest_form` exactly with `digest`.

From revision 2, in [`assessor.yaml`](https://github.com/beyond10x/ratchet/blob/main/spec/domains/assessor.yaml) and the CLI binding:

23. **`Assessor`.** New fields `command` and `target_input` (§ 10). `supported_targets` and `configuration_inputs` are written `targets` and `inputs` in the declaration, and `configuration_inputs` and `outputs` are maps keyed by name there, or the declaration takes the names of the specification. An invariant on `AssessorOutput`: `identity_key` is present exactly for the value type `identity_set`. **Done:** the specification takes the names of the declaration. `Assessor` has `format`, `name`, `version`, `command`, `targets`, `target_input`, `inputs` (a map from an input name to `ratchet.specification.InputDeclaration`, which no longer has a `name`), `conditions`, `coverage_unit`, `coverage`, `outputs` (a map from an output name to `ratchet.assessor.AssessorOutput`), and `population_fields`. The invariant is on `AssessorOutput`, and one more is on `Assessor`: `target_input` is present exactly when `targets` holds `document`.
24. **The declaration as a document.** A projection of `Assessor` as one YAML document with the constant `format: ratchet-assessor/1` (E8), as item 15 asks for the run. **Left out of 0.1.0**, as item 15 is: ESS has no such projection. `Assessor.format` is declared with the invariant `format == "ratchet-assessor/1"`.
25. **`assess` in [`spec/cli.yaml`](https://github.com/beyond10x/ratchet/blob/main/spec/cli.yaml).** Nothing there says how the command starts an assessor. It needs the invocation of § 10 and the completion that each exit status is recorded as. **Done in part:** the six reserved arguments are the enum `ratchet.assessor.ReservedArgument`, and the four meanings of an exit status are `ratchet.assessor.AssessorExit` (`ended`, `refused_inputs`, `wrong_invocation`, `broke`). The comment on `assess` in `spec/cli.yaml` and the comment on `AssessorExit` say which completion each is recorded as. **Left out of 0.1.0:** that table as a declaration. ESS declares no map from the values of one enum to those of another, so the CLI implements it from the comment.

Rules of § 3, § 4, and § 10 that are not invariants, and why. A reader of 0.1.0 checks them in code.

| Rule | What is not an invariant | Why |
| --- | --- | --- |
| § 3 | `target.window` is present exactly for a time-window plan | The kind of the observation is in the plan, which the document does not hold. The rule joins a run and its plan. |
| § 3 | `items[].identity` holds exactly the fields that the `key` of its result names | Both are members of one result, but `identity` is free JSON, and no invariant reads the names of the members of a JSON value |
| 3 | At most one result per `output`, `scope`, `item`, `boundary`, and `aggregation` | A `distinct` takes one member as its key (item 4) |
| 4 | `passed` plus `failed` is at most `executed` | A comparison reads no sum of two facts (item 10) |
| 4 | `not_executed`, where present, has one entry per unit of `skipped`, `not_run`, and `unsupported` | The rule counts the entries of a list by the value of a member and compares the count with a field |
| 4 | A unit is counted once and has the same id in every run | It needs the inputs or a second run (§ 4) |
| 8 | A result for every scope item that the run was to evaluate | The scope items come from the inputs, which the document does not hold |
| 9 | No absolute path in `evidence` | A path is text, and no invariant reads the form of a text. That `evidence` holds no time outside `target.window` holds by declaration: no other member of `Evidence` is a `Timestamp`. |
| § 10 | A result against the assessor’s declaration: `output`, `kind`, `scope`, `value_type`, `unit`, `boundary`, `key`, and the names under `fields` | Each joins a run and a declaration, and an invariant reads one of them |

## 9. Not in version 1

- **A paired run** (design § 3). Its evidence is two values of one run, and the specification has no field for the second.
- **Raw samples.** A result is one value. An assessor that aggregates names the aggregation and the number of samples.
- **A result per condition cell**, such as a viewport and a theme. A finding carries its environment in its identity (design § 3). A number has no field for it, and the first assessor runs under no conditions.
- **The other records** of design § 6: gate decision, reference change, trade-off, and proof. A reference and a trade-off have a format name in the design; none of the four has a field list like this one.
- **A list of causes on one result.** A result has one cause, chosen in a fixed order (§ 5, U5).
- **The rest of the invocation** (§ 10). The contract covers a plan whose target has the kind `revision` or `document` and the selection `candidate`. It does not say how an assessor learns the observation of a plan (`scenarios`, `workload`, `command`, `runs`, `min_samples`), a `merge_result` selection, a plan without a selection, or a target of another kind. The first assessor needs none of these.
- **A digest pin on a declaration.** Where a declaration is found is decided (2026-11-24): the file `<name>@<version>.assessor.yaml` in a source of `[catalog] sources` of the local config, and a source without `git` is a directory relative to the root (design § 5, “Local config”). Whether a plan pins the declaration by digest, as a binding pins a preset (design § 4), is not.

## 10. The assessor contract

Design § 4 says what an assessor declares and that it returns evidence in the format of the bundled assessors. It does not say how Ratchet starts an assessor, what an exit status means, or how the declaration is written. This section defines the least that the first assessor needs for the three (Q10, Q11, Q12). Three choices in it are the owner’s: E7, E8, and E9 (§ 5). No CLI exists yet, so nothing here is built on Ratchet’s side.

### Invocation

Ratchet runs the assessor’s command once per run of a plan. The working directory is the root of the tree that is assessed. Every value is an argument, `--name value` (E7).

| Argument | Value | Passed | The assessor writes it as |
| --- | --- | --- | --- |
| `--project` | The `project` of the specification | Always | `evidence.project` |
| `--assessment` | The key of the plan | Always | `evidence.assessment` |
| `--root` | The root of the tree that is assessed: the checkout, or the scratch copy that `ratchet prove` makes | Always | Nothing. Paths in `evidence` are relative to it (§ 1). |
| `--class` | The target class of this run | Always | `evidence.target.class` |
| `--out` | The file that the document is written to | Always | Nothing |
| `--revision` | The commit id of the tree | For a target of the kind `revision` | `evidence.candidate` and `evidence.target.revision` |
| `--<input>` | The value of an input that the assessor declares: from the plan after defaults, or from the local config for a local input | For each input that has a value | `evidence.inputs.<input>`, or `run.local_inputs.<input>` for a local input |

- **Values.** Text is passed as it is, and a count or a decimal as decimal text. A boolean is `true` or `false`, and a list is one argument of JSON, as for the `ratchet` commands (design § 5). A path that is not local is passed as the plan wrote it, relative to the root.
- **Reserved names.** An assessor declares no input named `project`, `assessment`, `root`, `class`, `out`, or `revision`.
- **Nothing else.** Ratchet passes no argument beside these. A new reserved argument is a new version of the declaration format, so an assessor can refuse an argument that it does not know.
- **The target of the kind `document`** is an input: the declaration names it as `target_input`. The assessor reads the file, writes the digest of its bytes as `candidate` and under `target.identifiers`, and does not repeat it under `inputs`. The target may lie outside the root, as a generated variant in a scratch directory does. It then has no `path` (§ 1, Q8). The same holds for another input file outside the root: its entry under `inputs` has the digest and no `value`. A plan names its paths relative to the root, so only a caller other than the CLI passes such a file.
- **The revision** (Q9). The assessor writes the revision it is given and looks none up. For a `document`, Ratchet passes none and `target.revision` is absent: the digests identify the document and the inputs, so the same files give the same document at every commit. The CLI never fills a member of a document that an assessor wrote, because the record id is over the bytes of the file (E4).
- **Without the CLI.** An assessor may give `--root`, `--class`, and `--out` a default, as the first assessor does (the working directory, `local`, and the standard output), so that it runs by hand.

The first assessor at `edbbc27` takes this call, run in the root, and writes the document of § 6:

```sh
ux-static --project uxui --assessment studio-static --root . --class local \
  --out studio-static.evidence.json \
  --document ess/ui/studio.ui.yaml --journeys ess/ui/tests/studio.yaml --declarations ess/ui/studio.uxui.yaml
```

### Exit status

The assessor gives no verdict, and its exit status is not one: a document with 40 findings is written with exit 0, and the gate decides.

| Exit status | Means | Document | The CLI records |
| --- | --- | --- | --- |
| 0 | The run ended, and the document is at `--out` | From the assessor | That document, after it checks the rules of § 4 and the declaration. A missing document or one that breaks a rule is recorded as the last row is. |
| 1 | The assessor refuses its inputs: a file is unreadable or malformed, or the inputs do not belong together (Q12) | None | A run with `completion: refused_inputs` (E9) |
| 2 | The invocation is wrong: an argument the assessor does not know, a required one missing, a value that a reserved argument cannot have | None | A run with `completion: stopped_by_infrastructure`. The declaration and the program do not match. |
| Any other, or a signal | The assessor or a tool under it broke | None | A run with `completion: stopped_by_infrastructure` |

Two more completions have no exit status, because the CLI decides them. It ends an assessor that reaches its time limit and records `timed_out`. It does not start an assessment that the local config skips and records `skipped_locally` (design § 5).

So an assessor writes `completed` in the document it leaves with exit 0, and the CLI writes the other four. There is one exception. An assessor that ended a tool under it, at a limit or after a failure, and still has results to keep writes `timed_out` or `stopped_by_infrastructure` itself, with every result incomplete (rule 7), and exits 0.

An assessor writes one line per problem to the standard error, and the CLI shows those lines. It writes no document with exit 1 or 2, and no part of one.

**A document that the CLI writes** holds what the CLI passed: `project`, `assessment`, `assessor`, the target and the candidate it resolved, the inputs with the digests it could compute, the completion, empty `conditions`, the six counts as 0 in the declared unit, and no result. Rule 7 holds for it, because it has no result. Where the CLI cannot resolve the candidate, as for a target document that does not exist, it records no run for that plan and reports the error `candidate_unresolved`, because a run without its candidate is evidence about nothing.

### Declaration `ratchet-assessor/1`

One YAML document per assessor and version (E8). `ratchet validate` checks a plan against it: the target kind, the names and types of the inputs, and for each measurement the output, the kind, the scope, the unit, the boundary, the identity key, and the fields of a `filter` and the values of a field that the output lists under `item_values` (design § 4). The CLI checks an evidence document against it: `assessor`, `coverage.unit`, and for each result `output`, `kind`, `scope`, `value_type`, `unit`, `boundary`, `key`, and the names under `fields`.

| Field | Type | Required | Meaning | From |
| --- | --- | --- | --- | --- |
| `format` | text | yes | `ratchet-assessor/1`. The version covers the invocation above too. | new: E8 |
| `name` | text | yes | The part of `ux-static@1` before the `@` | spec: `Assessor.name` |
| `version` | text | yes | The part after the `@` | spec: `Assessor.version` |
| `command` | text | for an assessor that Ratchet runs | The program. `[tools]` of the local config says how it is started on one machine (design § 5). | new: § 4, a project command |
| `targets` | list of text | yes | The target kinds it supports | changed: `Assessor.supported_targets` |
| `target_input` | text | exactly when `targets` holds `document` | The input that holds the path of the target document | new: Q10 |
| `inputs` | map from an input name to an input | no | Each input: `type` (`string`, `integer`, `decimal`, `boolean`, or `path`), `list`, `required`, `default`, and `local` (design § 4) | changed: `Assessor.configuration_inputs` is a list |
| `conditions` | list of text | no | The conditions it declares beside `host_load_per_cpu`, `tools`, and `runner`. Absent or empty: it declares none (§ 3, Q13). | spec: `Assessor.conditions` |
| `coverage_unit` | text | yes | The one unit its coverage counts count | spec: `Assessor.coverage_unit` |
| `coverage` | list of text | yes | The counts it reports, of `executed`, `skipped`, `not_run`, `unsupported`, `passed`, and `failed`. A count it does not report is 0 in its documents. | spec: `Assessor.coverage` |
| `outputs` | map from an output name to an output | yes | The outputs a measurement can read | changed: `Assessor.outputs` is a list |
| `population_fields` | list of text | no | The fields a time-window plan’s `population: {filter}` may name | spec: `Assessor.population_fields` |

An output, `outputs.<name>`:

| Field | Type | Required | Meaning | From |
| --- | --- | --- | --- | --- |
| `value_type` | text | yes | `number`, `identity_set`, `digest`, or `assertion` | spec: `AssessorOutput.value_type` |
| `kind` | text | yes | `exact` or `sampled` | spec: `AssessorOutput.kind` |
| `scopes` | list of text | yes | The scopes its results can have, beside `run`, which every assessor has (design § 3). The scope items are not declared: they come from the inputs of a run. The list may be empty: `scopes: []` declares an output whose results have the scope `run` alone, and the member stays required. | spec: `AssessorOutput.scopes` |
| `unit` | text | no | The unit of its values. Absent: the output has no unit, as the number of items of a set has none. | spec: `AssessorOutput.unit` |
| `boundaries` | list of text | no | For a duration, the parts it reports | spec: `AssessorOutput.boundaries` |
| `identity_key` | list of text | exactly for `identity_set` | The fields of an item’s `identity` | spec: `AssessorOutput.identity_key` |
| `item_fields` | list of text | no | The names an item may have under `fields`, which a `filter` may read | spec: `AssessorOutput.item_fields` |
| `item_values` | map from an item field to its values | no | The closed list of values of a field of `item_fields`, such as `{class: [equal, allowed, different]}`. A `filter` on that field names only these values, and an item has one of them under it. A field without a list is open: any value is read. | spec: `AssessorOutput.item_values` |

The declaration of the first assessor, written from the documents it writes at `edbbc27`. The consumer has no such file yet. Files to copy: `examples/quality/assessors/` of this repository holds nine declarations, one for each of the ten assessor ids the examples name but the built-in `record-series@1`, such as `command-timing@1.assessor.yaml` with its local input `job_log`, and `presets/` holds those its presets name. `task check:spec` checks that every output, unit and scope a measurement of an example reads is declared there.

```yaml
format: ratchet-assessor/1
name: ux-static
version: "1"
command: ux-static
targets: [document]
target_input: document
inputs:
  document: {type: path, required: true}
  journeys: {type: path, required: true}
  declarations: {type: path, required: true}
conditions: []
coverage_unit: check
coverage: [executed, skipped, not_run, unsupported, passed, failed]
outputs:
  structure.required_present@1:
    {value_type: number, kind: exact, scopes: [variant, journey], unit: nodes}
  effort.actions_per_journey@1:
    {value_type: number, kind: exact, scopes: [journey], unit: actions}
  a11y.accessible_names@1:
    {value_type: number, kind: exact, scopes: [page], unit: nodes}
  findings:
    value_type: identity_set
    kind: exact
    scopes: [variant, journey, page]
    identity_key: [rule, node_path]
    item_fields: [reason]
```

A plan then reads it like this. The plan is an illustration. `document` is a target kind of design § 3 and of the specification (E1).

```yaml
assessments:
  studio-static:
    subject: studio
    assessor: ux-static@1
    inputs:
      document: ess/ui/studio.ui.yaml
      journeys: ess/ui/tests/studio.yaml
      declarations: ess/ui/studio.uxui.yaml
    target: {kind: document, environments: [local, ci], selection: candidate}
    observation:
      kind: snapshot
      coverage: {not_run: {max: 0}, unsupported: {max: 0}}
    measurements:
      names-missing:
        {kind: exact, output: a11y.accessible_names@1, scope: page, unit: nodes, better: lower}
      new-findings:
        {kind: exact, output: findings, scope: page, identity: [rule, node_path]}
```

## 11. Revision 2 (answers to the first implementation)

The 13 questions of the consumer, from its implementation at `edbbc27`, and where each answer is written. The last column says what the answer asks of the first assessor.

| | Question | Answer | Where | The first assessor |
| --- | --- | --- | --- | --- |
| Q1 | Is a node that the inputs name twice for one scope item one check or two? | One. A unit is counted once. The example now shows 95 and 73. | § 3 `evidence.coverage`; § 4 rule 4; § 6 | No change |
| Q2 | Is a step on a node that the document cannot judge `unsupported`, with `coverage_below_plan`? | Yes | § 5, U5 | No change |
| Q3 | Several causes on one result: a list, or an order? | One cause, in a fixed order; `detail` names every one. `coverage_below_plan` comes before `incompatible_target`. | § 5, U5 | No change |
| Q4 | Nothing is declared for a scope item: an empty incomplete set, or no result? | An incomplete result: a number without a value and an empty set, with `coverage_below_plan` | § 4 rule 8; § 5, U3 | No change |
| Q5 | Are the ids in `not_executed` unique within a run? | Yes, and the same unit has the same id in every run. The spelling is the assessor’s. | § 4 rule 4 | No change |
| Q6 | Does an incomplete count of actions carry its lower bound? | Yes, where the bound is above 0 and the journey can be followed. A document without it stays valid. | § 5, U6 | Writes `value` and `at_least` for a journey with an unknown step |
| Q7 | A page with no check: complete or incomplete? | Complete: `0` and an empty set | § 5, U3 | No change |
| Q8 | What is `identifiers.path` for a document outside the tree? | Left out. The digest identifies the document. | § 1 Types; § 3 `evidence.target`; § 10 | Accepts a target document outside `--root` and leaves `path` out, where it refuses today |
| Q9 | Who fills `target.revision`? | The assessor, from `--revision`. Ratchet passes none for a `document`, and the CLI edits no document. | § 3 `evidence.target`; § 10 | No change |
| Q10 | How does Ratchet pass the project, the assessment, and the root? | As the arguments `--project`, `--assessment`, and `--root`, with `--class`, `--out`, and one argument per input | § 10 Invocation; E7 | No change |
| Q11 | How does an assessor declare its outputs, units, scopes, coverage unit, and item fields? | In a document `ratchet-assessor/1` | § 10 Declaration; E8 | Adds the file `ux-static@1.assessor.yaml`: E8 is taken as A |
| Q12 | Inputs that do not belong together: exit 1 and no document? | Yes. The CLI records the run as `refused_inputs`. | § 10 Exit status; E9 | No change. An unknown `--class` and an empty `--project` or `--assessment` are exit 2, where they are exit 1 today. |
| Q13 | Does an absent condition read as unknown for a static run? | No. Only a declared condition can be unknown, and the assessor declares none. | § 3 `evidence.conditions` | No change |
