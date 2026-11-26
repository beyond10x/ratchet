---
format: aep.planning-md/3
id: story:example-assessor-declarations
kind: story
status: implemented
title: Each assessor the examples name has a declaration
summary: ratchet-assessor/1 files for the example assessors and a test that compares the examples with them.
relations:
- decomposes: epic:format-gaps-first-format-consumer
scope:
- confidence: inferred
  path: AGENTS.md
- confidence: cited
  path: CHANGELOG.md
- confidence: cited
  path: ROADMAP.md
- confidence: inferred
  path: Taskfile.yml
- confidence: inferred
  path: docs/evidence-format.md
- confidence: cited
  path: examples/README.md
- confidence: inferred
  path: examples/quality/assessors
- confidence: inferred
  path: spec/README.md
- confidence: inferred
  path: spec/example-declarations.test.sh
revision: 10
transitions:
- {from: "draft", to: "proposed", at: "2026-11-25T19:06:07Z", actor: "agent:ratchet", revision: 8}
- {from: "proposed", to: "active", at: "2026-11-25T19:06:07Z", actor: "agent:ratchet", revision: 9}
- {from: "active", to: "implemented", at: "2026-11-26T03:37:08Z", actor: "human:operator", revision: 10, decided_on: {"recorded":{"test_result":1,"review_outcome":7}}}
---
## Context

The repository `beyond10x/inference` wrote its quality definition against the formats at
commit `f139ecc` (2026-11-25): 3 `ratchet/1` files, 8 `ratchet-assessor/1` declarations and 15
`ratchet-evidence/1` records. It is the first consumer of the formats outside this repository
and of this story. Line numbers below are those of `f139ecc`.

Finding 13. `examples/README.md:496` says every assessor id of the examples but four is a
placeholder, and the only `ratchet-assessor/1` declaration in the repository is the
illustration in `docs/evidence-format.md:691-718`. A reader cannot check the outputs, units and
scopes an example uses against anything, and a consumer has no declaration to copy.

State at `a4877e0` (2026-11-25, release 0.0.2): `presets/` holds 17 declarations, each for an
assessor a preset names. None has the id of an assessor of the examples. The five files
`examples/*.ratchet.yaml` name 10 assessor ids in 14 assessments with 20 measurements;
`examples/ratchet.toml` names `quality/assessors` as a catalog source, and
`examples/README.md:467-470` says that directory is an illustration and is not in the
repository. No step of the gate reads a file of `examples/`.

## Acceptance

`sh spec/example-declarations.test.sh` exits 0 on the tree, prints
`example-declarations: <n> of <n> broken copies refused` as its last line, and is a step of
`task check:spec`; after the story `examples/quality/assessors/` holds the nine files
`<name>@<version>.assessor.yaml`, one for each assessor but `record-series@1` that the five
files `examples/*.ratchet.yaml` name, and `presets/` holds none of them; the script holds one
broken copy for each rule below and exits 1 when a copy is accepted or is refused without the
message of its rule. Before the story
`examples/quality/assessors/` does not exist, and the script run against the tree at `a4877e0`
exits 1 and prints one line for each of the five files `examples/*.ratchet.yaml`, naming an
assessor it finds no declaration file for; it does not stop at the first.

The rules. The script reads every file `examples/*.ratchet.yaml` and, for each assessor a file
names but the built-in `record-series@1`, the declaration `<name>@<version>.assessor.yaml` in
`examples/quality/assessors/` or, when that directory holds none, in `presets/`: the two
catalog sources of `examples/ratchet.toml`. It refuses:

1. an assessor without a declaration file in either directory;
2. a measurement that names an output its assessor does not declare;
3. a measurement that states no unit for an output that declares one (`unit_missing`);
4. a measurement that states another unit than the output declares (`unit_mismatch`);
5. a measurement that states a unit for an output that declares none (`unit_not_declared`);
6. a measurement with a scope other than `run` that the output does not list;
7. a measurement of a plan over `runs_of` that states another unit or another scope than the
   measurement of its source plan that it names as `output`; such a measurement is exempt
   from rule 2, and the copies are a changed `unit` and a changed `scope`;
8. a directory that holds no file `examples/*.ratchet.yaml`.

## Notes

- Each message names the file and the measurement. The three unit messages hold
  `unit_missing`, `unit_mismatch` or `unit_not_declared`; the scope message holds "does not
  declare the scope"; the message for a missing file names the assessor id.
- `record-series@1` is built in and has no declaration file (`spec/domains/assessor.yaml`,
  the comment on the built-in assessor). A measurement of a plan over `runs_of` keeps the unit
  and the scope of the measurement of the source plan it names as its `output`.
- The three unit rules are those of `ratchet.specification.Measurement.unit`. `run` is the
  scope every assessor has; no declaration lists it.
- "An example" is a file `examples/*.ratchet.yaml`, not a file of a directory below
  `examples/`. The script states no number of examples.
- The proof is the pattern of `spec/presets.test.sh`: the broken copies stand under the
  ignored `target/`, each case is judged by its message, and the script's own harness cases
  prove that a copy accepted, and a copy refused without its message, give exit 1.
  `spec/presets.test.sh` itself is not changed.
- `sh spec/example-declarations.test.sh` ends within 60 s.
- The formats are enough as released: `ratchet.assessor.AssessorOutput` holds `unit` and
  `scopes`, and the outputs are the keys of `Assessor.outputs`. The story adds no field and no
  value to `spec/domains/`. A declaration that needs one stops the story, and the gap gets a
  draft.
- Four things the declarations decide, each reported as a decision taken: whether `job_log`
  of `command-timing@1` is required (`examples/README.md:238-240` leaves it open; one plan
  passes none); `scopes: []` for an output that belongs to `run` only (the precedent is
  `presets/lint-report@1.assessor.yaml`; finding 10 of
  `story:specification-answers-first-format-consumer` asks whether the empty list is valid);
  the coverage units (`examples/README.md:511-514`); and the `conditions` of
  `command-timing@1`, which are the conditions the example plans use (`tools`, `ci`, `local`)
  and no cache condition.
- The script does not check a declaration's own keys and types against
  `ratchet.assessor.Assessor`, and it does not compare `kind` or `boundary`;
  `spec/presets.test.sh` checks the files of `presets/` only. The header of the new script
  lists both under "Not checked".
- The epic's outcome asks for an answer in `spec/` and in the design documents. For finding 13
  no format answer is asked: the `spec/` part is the script and `spec/README.md`, and the
  design part is the sentence of `docs/evidence-format.md` below the table of
  `AssessorOutput` ("The consumer has no such file yet"), which names the nine declarations
  as files to copy.
- A story that adds a file `examples/*.ratchet.yaml` after this one adds, in the same change,
  the declaration of each assessor it names that has none in `examples/quality/assessors/` or
  `presets/`: `story:example-release-quality` adds its own to `examples/quality/assessors/`,
  and `story:production-gate-spec-executed-service` adds its own to `presets/`.
- A new value or field of a released format is an addition: a file written for the format
  before the change stays valid.
- The story was a draft that waited for the planned waves to 0.1.0. On 2026-11-25 it was
  taken ahead of them: every planned wave starts behind `story:cli-skeleton-validate`, which
  waits for a release of ESS, and this story needs no generated model.
- POSIX sh and awk, no Python. The test step ends within 120 s, no test over 60 s; the new
  script is timed before it is added.

## Scope

Derived 2026-11-25 by `story-scoper` at `main` `a4877e0`. Every line is **cited** (read from
the story or the tree) or **inferred** (a reading that could be wrong).

- **Primary surface:** `examples/quality/assessors/` (new): nine files
  `<name>@<version>.assessor.yaml`, one per assessor id of the five `examples/*.ratchet.yaml`,
  none for `record-series@1` (inferred; it is the second catalog source of
  `examples/ratchet.toml:7`).
- **Files:** `spec/example-declarations.test.sh` (new, POSIX sh and awk), with its broken
  copies under the ignored `target/example-declarations/` (inferred).
- **Files:** `Taskfile.yml`, the description of `check:spec` and one line in its list of
  scripts (inferred; the task lists each script of `spec/` by name).
- **Documents:** `examples/README.md`: the placeholder row (`:496`), the directory that now
  exists (`:467-470`), "no tool has validated them" (`:9-10`), the coverage units
  (`:511-514`), whether `job_log` is required (`:238-240`) (cited; the story names line 496).
- **Documents:** `spec/README.md`: the number of steps (`:40`), a new step in the list, and
  "No gate step reads `examples/*.ratchet.yaml`" (`:285`) (inferred).
- **Documents:** `AGENTS.md`: a row for `examples/` in the table of files and what
  `check:spec` checks (inferred).
- **Documents:** `CHANGELOG.md`, lines under `## [Unreleased]` (cited; `AGENTS.md`
  § "Release").
- **Documents:** `docs/evidence-format.md`, the sentence below the table of `AssessorOutput`:
  it names the declarations to copy (inferred).
- **Documents:** `ROADMAP.md`, the line of `epic:format-gaps-first-format-consumer`: this
  story is taken ahead of the waves (cited; the line says the stories wait).
- **Symbols:** none changed.
- **Confidence:** medium. The story cites one line and names no path; the directory and the
  test are read from the README, the local config and the pattern of `spec/presets.test.sh`.
- **Would collide with:** a unit that adds or edits a file under `examples/`, the step list of
  `check:spec` in `Taskfile.yml` and `spec/README.md`, the table of files of `AGENTS.md`, and
  `## [Unreleased]` of `CHANGELOG.md`. Active stories that name one of these files:
  `story:acceptance-in-gate` (`CHANGELOG.md`, `Taskfile.yml`), `story:preset-binding-resolution`
  (`CHANGELOG.md`, `examples/README.md`), `story:release-0-1-0` (`CHANGELOG.md`),
  `story:cli-skeleton-validate` (`AGENTS.md`). None of them is dispatched.
