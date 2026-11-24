# `ratchet` CLI contract

Specify software quality, assess it, and keep it from going backwards

This generated package installs an unavailable handler. Application behavior enters through the `Handler` seam; schema-selected calls also require `DynamicValidator`. See `help.txt` for process options and `binding.json` for resolved types and targets.

## Commands

### `assess`

Run selected assessors or ingest their results and record structured evidence

Callable: `assess`. Input: `ratchet.cli.AssessInput`. Result: `ratchet.cli.AssessResult`.

Error `assessor_unavailable`: `ratchet.cli.Refusal`.

Error `candidate_unresolved`: `ratchet.cli.Refusal`.

Error `input_not_local`: `ratchet.cli.Refusal`.

Error `record_store_unreachable`: `ratchet.cli.Refusal`.

Error `unknown_assessment`: `ratchet.cli.Refusal`.

### `diff`

Compare the candidate with the reference item by item

Callable: `diff`. Input: `ratchet.cli.DiffInput`. Result: `ratchet.cli.DiffReport`.

Error `reference_missing`: `ratchet.cli.Refusal`.

Error `unknown_requirement`: `ratchet.cli.Refusal`.

### `doctor`

Check that config, specifications, tools, local inputs and the record store are reachable

Callable: `doctor`. Input: `null (inputless)`. Result: `ratchet.cli.DoctorReport`.

Error `unhealthy`: `ratchet.cli.DoctorReport`.

### `evaluate`

Evaluate a named gate with qualifying evidence, or an operational gate over its windows; only a pass exits 0

Callable: `evaluate`. Input: `ratchet.cli.EvaluateInput`. Result: `ratchet.cli.GateReport`.

Error `gate_failed`: `ratchet.cli.GateReport`.

Error `insufficient_evidence`: `ratchet.cli.GateReport`.

Error `local_skips_refused`: `ratchet.cli.Refusal`.

Error `operational_gate_takes_no_candidate`: `ratchet.cli.Refusal`.

Error `record_store_unreachable`: `ratchet.cli.Refusal`.

Error `unknown_gate`: `ratchet.cli.Refusal`.

### `exceptions`

List active, expiring and expired exceptions

Callable: `exceptions`. Input: `ratchet.cli.ExceptionsInput`. Result: `ratchet.cli.ExceptionList`.

Error `unknown_requirement`: `ratchet.cli.Refusal`.

### `explain`

Say what a requirement means, who cares, how it is measured and where its evidence is

Callable: `explain`. Input: `ratchet.cli.ExplainInput`. Result: `ratchet.cli.Explanation`.

Error `unknown_requirement`: `ratchet.cli.Refusal`.

### `history`

Show a requirement's series with reference changes and exceptions marked

Callable: `history`. Input: `ratchet.cli.HistoryInput`. Result: `ratchet.cli.History`.

Error `record_store_unreachable`: `ratchet.cli.Refusal`.

Error `unknown_requirement`: `ratchet.cli.Refusal`.

### `import`

Import history that exists elsewhere as assessment runs

Callable: `import`. Input: `ratchet.cli.ImportInput`. Result: `ratchet.cli.ImportResult`.

Error `record_store_unreachable`: `ratchet.cli.Refusal`.

Error `source_unreadable`: `ratchet.cli.Refusal`.

Error `unknown_assessment`: `ratchet.cli.Refusal`.

### `init`

Create a project specification and bind selected catalog presets

Callable: `init`. Input: `ratchet.cli.InitInput`. Result: `ratchet.cli.InitResult`.

Error `preset_unresolved`: `ratchet.cli.Refusal`.

Error `spec_exists`: `ratchet.cli.Refusal`.

### `prove`

Run a requirement's planted defects and record that the check refuses each

Callable: `prove`. Input: `ratchet.cli.ProveInput`. Result: `ratchet.cli.ProofReport`.

Error `defect_accepted`: `ratchet.cli.ProofReport`.

Error `no_planted_defects`: `ratchet.cli.Refusal`.

Error `unknown_requirement`: `ratchet.cli.Refusal`.

### `reference adopt`

Write the proposed reference records, and the trade-off record, into the working tree

Callable: `reference-adopt`. Input: `ratchet.cli.ProposeInput`. Result: `ratchet.cli.AdoptResult`.

Error `gain_not_shown`: `ratchet.cli.Refusal`.

Error `no_qualifying_evidence`: `ratchet.cli.Refusal`.

Error `not_better`: `ratchet.cli.Refusal`.

Error `requirement_without_reference`: `ratchet.cli.Refusal`.

Error `unknown_requirement`: `ratchet.cli.Refusal`.

Error `unnamed_regression`: `ratchet.cli.Refusal`.

### `reference propose`

Print a stronger protected reference, or a trade-off that names its gains; write nothing

Callable: `reference-propose`. Input: `ratchet.cli.ProposeInput`. Result: `ratchet.cli.ReferenceProposal`.

Error `gain_not_shown`: `ratchet.cli.Refusal`.

Error `no_qualifying_evidence`: `ratchet.cli.Refusal`.

Error `not_better`: `ratchet.cli.Refusal`.

Error `requirement_without_reference`: `ratchet.cli.Refusal`.

Error `unknown_requirement`: `ratchet.cli.Refusal`.

Error `unnamed_regression`: `ratchet.cli.Refusal`.

### `render`

Write the marked blocks of numbers in documents and the static export from records

Callable: `render`. Input: `ratchet.cli.RenderInput`. Result: `ratchet.cli.RenderReport`.

Error `render_drift`: `ratchet.cli.RenderReport`.

Error `unknown_record`: `ratchet.cli.Refusal`.

### `serve`

Serve the page and data document of the views over the record store

Callable: `serve`. Input: `ratchet.cli.ServeInput`. Result: `ratchet.cli.ServeResult`.

Error `listen_failed`: `ratchet.cli.Refusal`.

Error `record_store_unreachable`: `ratchet.cli.Refusal`.

### `status`

Show every requirement's verdict, value, limit or reference, and when it was checked

Callable: `status`. Input: `ratchet.cli.StatusInput`. Result: `ratchet.cli.StatusReport`.

Error `record_store_unreachable`: `ratchet.cli.Refusal`.

Error `unknown_gate`: `ratchet.cli.Refusal`.

### `validate`

Check the specification, resolve references and validate assessor configuration

Callable: `validate`. Input: `ratchet.cli.ValidateInput`. Result: `ratchet.cli.ValidationReport`.

Error `spec_invalid`: `ratchet.cli.ValidationReport`.

Error `spec_unreadable`: `ratchet.cli.Refusal`.

## Runtime obligations

- handler:assess: implement the owner-qualified callable and its declared result/error contract
- handler:diff: implement the owner-qualified callable and its declared result/error contract
- handler:doctor: implement the owner-qualified callable and its declared result/error contract
- handler:evaluate: implement the owner-qualified callable and its declared result/error contract
- handler:exceptions: implement the owner-qualified callable and its declared result/error contract
- handler:explain: implement the owner-qualified callable and its declared result/error contract
- handler:history: implement the owner-qualified callable and its declared result/error contract
- handler:import: implement the owner-qualified callable and its declared result/error contract
- handler:init: implement the owner-qualified callable and its declared result/error contract
- handler:prove: implement the owner-qualified callable and its declared result/error contract
- handler:reference-adopt: implement the owner-qualified callable and its declared result/error contract
- handler:reference-propose: implement the owner-qualified callable and its declared result/error contract
- handler:render: implement the owner-qualified callable and its declared result/error contract
- handler:serve: implement the owner-qualified callable and its declared result/error contract
- handler:status: implement the owner-qualified callable and its declared result/error contract
- handler:validate: implement the owner-qualified callable and its declared result/error contract
