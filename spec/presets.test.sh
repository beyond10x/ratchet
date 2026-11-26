#!/bin/sh
# The preset catalog `presets/` is what the specification declares (spec/domains/*.yaml), and
# every measurement of a preset has its row on a page of the directory.
#
# Nothing else in the gate reads a `ratchet/1` file. A field renamed in the specification, a
# preset that names an output its assessor no longer declares, and a measurement that the page
# of its family leaves out would each stay green.
#
# What a directory of the catalog holds, and what is checked:
#   file      every entry is a regular file with text in it, and no symbolic link. Its name
#             holds letters, digits, `@`, `.`, `_` and `-` and does not start with `.`. It is
#             `README.md`, a page `<family>.md`, or a file `<name>@<version>.<kind>.yaml` whose
#             kind is a value of `ratchet.config.CatalogFileKind` and whose name and version
#             are those the file states, neither with an `@` in it. The directory holds a
#             `README.md` and at least one preset, and a preset holds at least one requirement
#   bytes     a file is UTF-8 and holds no NUL byte and no control character: every line,
#             the last one too, ends with a line feed, and a page may hold tabs. It holds
#             none of these characters either, in a preset, a declaration, a page and
#             README.md: a control character of the range U+0080 to U+009F (U+0085, the
#             next line, is one); U+2028 and U+2029, the line and the paragraph separator
#             (with U+0085 a line break to a YAML 1.1 reader, which would read keys that
#             this script does not see); U+FEFF, the byte order mark, anywhere; U+FFFE and
#             U+FFFF, which are no characters; and the characters that hide or reorder
#             text: U+200B, U+200E, U+200F, U+202A to U+202E, U+2060 and U+2066 to U+2069.
#             U+200C and U+200D stay: some writing systems are spelled with them
#   place     a key of a preset or of a declaration is a declared field of the struct or entity
#             there, a key of a declared map, or lies under a field of the type `Json`. The
#             root of a declaration is a `ratchet.assessor.Assessor`. The root of a preset
#             holds `format` (`ratchet/1`), `preset` (the fields of
#             `ratchet.specification.Preset`) and the maps `ratchet.specification.PresetMember`
#             lists, each a map of the entity that the relation of that name of
#             `ratchet.specification.QualitySpecification` targets. So a preset holds no gate,
#             no exception, no subject and no binding. An entry states no `project`
#   type      Integer: a YAML integer. Decimal: a number without exponent and sign `+`, or
#             that text quoted. Boolean: `true` or `false`. String and a newtype of String:
#             text that is not empty, so `version: 1` and `output: ""` are refused and
#             `version: "1"` is read. An enum: one of its variants. List: a list. Map and
#             struct: a mapping
#   required  a mapping of a struct has every field that is not `Optional<...>`. A requirement
#             may leave `serves` out (spec/README.md)
#   inputs    no input of a preset is local, and a default is a value of the type of its
#             input. A scalar of a preset that holds `${` or `{inputs.` is
#             `${inputs.<name>}` alone, `<name>` is a declared input of the preset, and the
#             type of the input fits the place (`ratchet.specification.InputReference`). An
#             input of the type `conditions` stands as the whole value of
#             `observation.conditions` of a plan, a map from a target class to its
#             conditions, and nowhere else, and only a preset declares one: an input of a
#             declaration of that type is refused, because an assessor reads no plan's
#             conditions as an input.
#             `<name>` is the key of the input as this script reads a key, so
#             `${inputs.a.b}` refers to the input `a.b`: the specification gives the name of
#             an input no type but text. In a declaration `${` is text, and only a scalar
#             that is `${inputs.<name>}` alone is refused there: a declaration has no
#             inputs to refer to. An input of a declaration has no name of
#             `ratchet.assessor.ReservedArgument`, such as `out`: Ratchet passes those
#             arguments itself (docs/evidence-format.md § 10, "Reserved names"). An input of
#             the type `string` that lists `values` (`InputDeclaration.values`) is read
#             against them: its default, of a preset or of a declaration, and each item of a
#             list default is one of the values, and a reference to it at the place of an
#             enum, such as `better`, stands there only where each of its values is a value
#             of that enum. An input of the type `string` without `values` stays accepted at
#             the place of an enum, as `code-lines@1` writes it: the binding passes the word.
#             A literal that a plan passes to an input of its assessor's declaration with
#             `values` is checked by the rule `assessor`
#   names     a requirement names an assessment of its preset and a measurement of that
#             assessment, and the statements it serves are statements of the preset. These
#             three names are written out: a reference there is refused, because no row
#             `<name>@<version>/<assessment>/<measurement>` could be checked against it
#   assessor  the assessor of an assessment has its declaration in the directory. The kind of
#             the target is one of its `targets`; a kind that an input gives is checked
#             against the default of that input. An input the assessment passes is an input
#             of the declaration that is not local, and its value has the declared type: a
#             literal by its YAML kind, a reference by the type of the input of the preset
#             (an `integer` also where a `decimal` is declared), and so each item of a list.
#             A literal, and each item of a literal list, is one of the `values` the
#             declaration lists for the input, where it lists them.
#             Every required input that is not local is passed. An input that the
#             declaration names in `observation_inputs` under a key
#             is passed by the key of the plan's `observation`: a plan has that key where
#             the input is required, and passes the input under `inputs` nowhere
#             (docs/evidence-format.md § 10, "Invocation"). A key of `observation_inputs` is
#             one of `ratchet.assessor.ObservationKey` and names an input of the declaration,
#             and so does each entry of `revision_inputs`.
#             A measurement names an
#             output of the declaration, the kind of that output (`kind_mismatch`), its unit
#             or none where it has none, the scope `run` or one the output declares, a
#             boundary the output declares (`run_time` and `queue_wait`, which are Ratchet's,
#             also where the output declares no boundaries), the identity key the output
#             declares where it states one, and in a `filter` only fields the output declares
#             for its items and, for a field whose values the output lists under
#             `item_values`, only those values; a field without such a list is open. A key of
#             `item_values` is a field of `item_fields` of its output. `pass_rate` aggregates
#             an assertion and nothing else, and the measurement of such a rate may be
#             `sampled`. A condition of the observation is one of the seven that have a field
#             in ratchet.specification.ObservationConditions (`host_load_per_cpu`, `tools`,
#             `runner`, `cpu_model`, `memory`, `accelerator` and `build_profile`, read from
#             the specification) or one the declaration lists, and a field of a population
#             filter is one of its `population_fields` (`population_field_mismatch`). The
#             cache condition is `cache_profile`, the member of the record: a condition
#             `cache` of a plan and an item `cache` of the `conditions` of a declaration are
#             refused, also where the two agree. The output `coverage.<count>` is Ratchet's
#             where the declaration declares no output of that name: it reads a count of the
#             coverage of the run, so the count is a value of `ratchet.assessor.CoverageCount`
#             that the declaration lists under `coverage`, and the measurement is `exact`, at
#             the scope `run` and without a unit, and is compared as a number without a unit
#             (docs/design.md § 3 "Evidence coverage")
#   series    `record-series@1` is the assessor of Ratchet itself that reads the runs of
#             another plan (spec/domains/assessor.yaml). The name is reserved: no file of
#             the directory declares it, and a plan that names it needs no declaration. As
#             the invariants of `ratchet.specification.AssessmentPlan` say, a plan with
#             `observation.population.runs_of` names it and has no `target.selection` and no
#             `observation.conditions`, and a plan that names it has `runs_of`. It passes no
#             input: that assessor takes none
#   compare   a requirement compares its measurement as the table of docs/design.md § 3
#             "Comparisons" allows for the value type of the output. `lt`, `lte`, `gt`, `gte`
#             and `eq` take a number or a set and have a `value`. `within` takes a number
#             or a set and has `min` and `max`, `min` not above `max`, and no `value`;
#             `min` and `max` stand on no other operator. `no_new_items` and
#             `no_lost_items` take a set, have no `value` and need a reference of the kind
#             `accepted_value`. `subset_of` takes a set and has `against`. `against`
#             names an assessment of the preset and a measurement of it, the one it holds
#             where it holds one, and with it `lt`, `lte`, `gt`, `gte` and `eq` have no
#             `value`; the output of that measurement has the value type and, for a
#             number, the unit of the output (`against_value_type_mismatch`,
#             `against_unit_mismatch`). `holds` takes an assertion and has no `value`. A digest
#             takes `eq` with a `digest` and no `value`, and a `digest` stands on a
#             condition of no other value type. The reference of a number and of a set is
#             `accepted_value`, that of a digest `generated`, and an assertion has none. A
#             set with a reference has a condition. A number that is compared with a
#             reference states `better`. A condition states the unit of the output, or none
#             where the output has none. An assertion that its measurement aggregates with
#             `pass_rate` is a number here
#   sampled   what docs/design.md § 3 and § 5 say `ratchet validate` reports. The plan of a
#             measurement of the kind `sampled` declares at least one condition under
#             `observation.conditions`, unless it reads the runs of another plan (`runs_of`),
#             which declares none, or an input of the type `conditions` gives them. A
#             requirement that compares such a measurement with a
#             reference of the kind `accepted_value` has a `reference.tolerance` with a
#             `percent` or an `absolute`, and a `reference.adoption`. The last two are read
#             without a declaration, so also on a plan of `record-series@1`. A measurement of
#             the kind `exact` aggregates with `sum` or not at all, as the table of the two
#             kinds in docs/design.md § 3 says ("None, or a sum"). A sampled measurement of a
#             plan whose `runs` is a literal above 1 states an `aggregation` or
#             `over_all_runs: true`, the value its assessor computes over all runs of the plan,
#             and no measurement states both: that value is no aggregation (docs/design.md
#             § 3, "One run per candidate is valid"). A `runs` that an input gives is not read,
#             so the rule does not reach `flake-rate@1`. A plan may hold exact and sampled
#             measurements of its one run, in every observation kind, and its conditions then
#             qualify every measurement of it (docs/design.md § 3, "Exact and sampled
#             measurements of one run"). The design refuses no mix, so no rule reads it: the
#             copy `valid-plans` holds a sampled pass rate beside the exact counts of a
#             snapshot plan, and it is accepted
#   adoption  an adoption `{from: assessment, assessment: <plan>, measurement: <measurement>}`
#             (docs/design.md § 5 "The ratchet policy") names an assessment of the preset and a
#             measurement of it, and that measurement has the value type and the unit of the
#             requirement's measurement, read from the outputs the two declarations declare,
#             as for `against` under `compare`. It names both, and `assessment` and
#             `measurement` stand on `from: assessment` alone: the invariants of
#             `ratchet.specification.RatchetPolicy`. The adopted plan may be the requirement's
#             own
#   row       a measurement is named `<name>@<version>/<assessment>/<measurement>`. It has one
#             row in the tables of the pages, the rows of one preset stand on one page, the
#             four cells after the name are not empty, and a row names a measurement. A table
#             is found by its header line `| Measurement | Direction | Unit | Tolerance |
#             Evidence |`, written as here, and a page holds at least one with a row. A
#             line inside a code fence and the text of an HTML comment `<!-- ... -->` are
#             not read, and a cell that holds only spaces, tabs and no-break spaces is
#             empty. A fence closes as CommonMark says: at a run of the character that
#             opened it, at least as long, indented by at most three spaces, with nothing
#             but spaces and tabs after it. `\|` in a cell is a bar of the text and no
#             border of a cell, and `<!--` inside a code span that closes on its line opens
#             no comment
# Not checked: every form that the rules above could read and that the script accepts without a
# word stands here, each with its reason. A form that docs/design.md or
# docs/evidence-format.md forbids is refused by a rule above, and a form that no sentence of
# the two forbids outright stays accepted: the catalog adds no rule to the format.
#   - a percentile without `parameter`, and a percentile with a rank above 100, such as
#     `{kind: percentile, parameter: 250}`: `ratchet.specification.Aggregation` holds
#     `parameter` as an optional integer without a range or an invariant, and no sentence of
#     the design requires a rank or bounds it
#   - a measurement of a duration without `boundary`: docs/design.md § 3 says which part a
#     boundary names where the evidence records the parts, and requires none;
#     `ratchet.specification.Measurement.boundary` is optional
#   - a measurement of a set without `identity`: the key is the one the declaration states
#     (`identity_key`), and the copy `valid-forms` holds that form as valid
#   - `tolerance: {}`, a `reference.tolerance` with neither `percent` nor `absolute`
#     (`ratchet.specification.Tolerance`, both members optional and no invariant), on an
#     exact measurement with a reference `accepted_value`, as `presets/image-size@1.preset.yaml`
#     writes a tolerance there, and with a reference `generated`: docs/design.md § 3 gives an
#     exact measurement the band 0 by default and a digest the tolerance 0, and an empty band
#     states no other. On a sampled measurement and on a window over runs the rule `sampled`
#     refuses it
#   - an input, of a preset or of a declaration, that is required and has a default, and one
#     that is neither required nor has a default: `ratchet.specification.InputDeclaration`
#     holds `required` and an optional `default` without an invariant, and docs/design.md § 4
#     names neither form as an error
#   - the one row of a preset with one measurement on the page of another family:
#     presets/README.md says that a measurement has its row on the page of its family, and no
#     file names the family of a preset. The script checks that the rows of one preset stand
#     on one page
#   - a plan without a condition that the declaration of its assessor lists: the declaration
#     lists the conditions the assessor can observe (`ratchet.assessor.Assessor.conditions`),
#     and the plan declares those that qualify (docs/design.md § 3)
#   - `min_samples` above `runs`, both literals: a run can collect many samples
#     (docs/design.md § 3, "Controlled run"), so the two count different things
#   - `over_all_runs: true` on an exact measurement: docs/design.md § 3 states the form for a
#     sampled measurement of a plan with more than one run and forbids it nowhere else, and an
#     exact value is the same in every run
#   - `runs: 1` with an aggregation. docs/design.md § 3, "One run per candidate is valid":
#     "An aggregation of one value is that value", so a measurement may declare its
#     aggregation for every value of `runs`, and a preset whose `runs` is an input does so,
#     such as `workload-throughput@1`; at `runs: 1` with a command that measures once the
#     result carries `samples: 1` and is judged as observed. And "With `runs: 1` a measurement
#     may declare one of the existing aggregation kinds when the command repeats its
#     measurement itself within the one run": the repeats are samples of that run. So the form
#     is valid whether or not the command repeats its measurement, which the script cannot see
#   - the invariants of the types, beside the four of an assessment plan under `series` and
#     those of a condition that `compare` reads (`within` with its two bounds in order, `min`
#     and `max` on no other operator, `subset_of` with `against`, a `digest` with `eq`) and the
#     four of an adoption that `adoption` reads: they are written in the expression language
#     of ESS, and `ess generate synthesize` writes them as Rust. So a `digest` beside a
#     `value` on a number, and `against` beside a `value`, a `digest`, a `min` or a `max`,
#     are left to the decoder, and so are a default and a `list` on an input of the type
#     `conditions`, and `values` on an input of another type than `string`, whose default
#     and literals are then not read against `values`
#   - a value that an input gives, where a rule reads the value: the binding passes it. These
#     are the assessor of an assessment, and with it every rule that reads its declaration;
#     the output of a measurement, and with it the rules on that measurement and on the
#     requirements that compare it; the kind, the unit, the scope, the boundary and the
#     identity key of a measurement, also where one item of the key is a reference; a value of
#     a `filter`; the kind of an aggregation over an assertion; the `runs` of a plan and the
#     `over_all_runs` of a measurement; an operator; the unit of a condition; the kind of a
#     reference; the conditions of a plan, which the rule `sampled` then counts as
#     declared; and a reference that a plan passes to an input of its assessor that lists
#     `values`. Only the kind of a target is read from the default of its input
#   - a measurement of a plan of `record-series@1` against the measurement of the source plan
#     it reads (the output, the kind, the unit, the scope, the boundary, the identity key,
#     the fields of a `filter`), and the comparison of a requirement on it: its outputs are
#     the measurements of the source plan, and the source plan may be in another file
#   - the plan that `runs_of` names: it may be in another file
#   - the number of runs of an adoption from the trusted revision (`reference.adoption.runs`):
#     docs/design.md § 5 "Ratchet policy" says that it has no default and names no report of
#     `ratchet validate` for an adoption without it, and `ratchet.specification.RatchetPolicy`
#     holds `runs` as an optional member without an invariant
#   - the class a condition is declared for (`all`, `ci`, ...): the key of an open map
#   - the value of a `Json` other than a passed input and a default: no type is declared
#   - the text of the four cells of a row against the preset: the cells are prose
#   - whether an input of a preset is referred to: an input may be there for a later version
#   - a code fence, a code span and a comment as a Markdown reader takes them inside a list
#     item, a block quote or an indented block, and a code span over two lines: a page of
#     the catalog writes its tables outside them
#
# This is no YAML reader. It reads the forms the catalog is written in and fails on a line of
# another form: a mapping by indentation (`key:` and `key: value`), a flow mapping
# `{key: value, ...}` and a flow list `[...]` on one line, plain scalars, and quoted scalars
# without an escape. A list is a flow list. A key holds letters, digits, `_`, `.`, `@` and `-`
# and is not quoted. Refused, because a YAML reader takes them another way than this script
# would: a comment (a preset and a declaration hold none, presets/README.md), a tab, a quote
# inside a plain scalar, a folded or literal scalar (`>`, `|`), a text over two lines, a
# document marker (`---`), and a key that YAML reads as a number, a boolean or null (`15`,
# `0o17`, `1.5`, `true`, `null`).
#
# Usage:
#   sh spec/presets.test.sh                      `presets/`, then one defect per rule in copies of
#                                                the set of its files that `set_files` names
#   sh spec/presets.test.sh --catalog <directory> [--spec <directory>]
#                                                one directory, against `spec/domains` or the
#                                                named directory of domain files; no copy
# The whole of `presets/` is checked once. A copy holds `README.md` and the functional family
# and no file of another family: a defect tests a rule of this script, so the run with the
# copies takes the same time when the catalog gets a family.
# Work files go to the ignored target/presets. It needs POSIX sh and awk, and of the other
# utilities `cat`, `cmp`, `cp`, `dirname`, `grep`, `ln`, `mkdir`, `mv`, `rm`, `sed`, `tail`,
# `tr` and `wc`. `tr` and `wc` find a NUL byte, which an awk may not read, and count the line
# feeds; awk finds what is no UTF-8 and a character that is refused, reading bytes under
# `LC_ALL=C`, and `tail` and `wc` name the file whose last line has no line feed.
#
# Exit 0: the last line is
#   `presets: <f> of <f> file(s) valid, <r> of <r> measurement(s) with a row, <c> of <c> broken copies refused`
# (with `--catalog`, without the third count). `<f>` counts the presets, the declarations and
# the pages, and not `README.md`; `<r>` counts the measurements of the presets; `<c>` counts the
# copies that hold a defect. A copy holds one defect or several that stand apart, and the line
# before the last counts the defects:
#   `presets: <d> of <d> defect(s) refused with the message of their rule`
# Exit 1: each failure is named with its file and line; or a defect in a copy is accepted, or
# refused without the message of its rule; or the harness of the copies fails a case of its own;
# or `presets/` lacks a file of the set of the copies; or a case edits a file its copy does not
# hold.
set -eu

# Bytes, not characters of the locale of the caller: the same reading under every awk.
LC_ALL=C
export LC_ALL

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
self=$root/spec/presets.test.sh
catalog=$root/presets
spec=$root/spec/domains
work=$root/target/presets
copies=1

usage() {
  echo "usage: presets.test.sh [--catalog <directory> [--spec <directory>]]" >&2
  exit 1
}

while [ $# -gt 0 ]; do
  case $1 in
    --catalog) [ $# -ge 2 ] || usage; catalog=$2; copies=0; shift 2 ;;
    --spec) [ $# -ge 2 ] || usage; spec=$2; shift 2 ;;
    *) usage ;;
  esac
done

# tables <directory of domain files>: what the check reads of the specification, one fact a
# line, the parts between tabs: the kind of a type, the type a newtype is of, a variant of an
# enum, a type with undeclared fields, a field with its type, a relation with its target.
# A check reads these lines and not the domain files, so a run with many copies reads the
# specification once.
tables() {
  awk '
  function out(what, a, b, c) { print what "\t" a "\t" b "\t" c }
  /^entities:/ { in_entities = 1; next }
  /^types:/ { in_entities = 0; next }
  /^  - name: / {
    type = $3; in_fields = 0; in_variants = 0; in_relations = 0; field = ""; rel = ""
    if (in_entities) out("kind", type, "entity")
    next
  }
  /^    kind: / { if (!in_entities) out("kind", type, $2); next }
  /^    of: / { out("of", type, $2); next }
  /^    variants: \[/ {
    v = $0; sub(/^    variants: \[/, "", v); sub(/\].*$/, "", v)
    n = split(v, list, / *, */)
    for (i = 1; i <= n; i++) out("variant", type, list[i])
    next
  }
  /^    variants:/ { in_variants = 1; in_fields = 0; in_relations = 0; next }
  /^    undeclared_fields: ignored/ { out("open", type); next }
  /^    fields:/ { in_fields = 1; in_variants = 0; in_relations = 0; next }
  /^    relations:/ { in_relations = 1; in_fields = 0; in_variants = 0; next }
  /^    [a-z_]+:/ { in_fields = 0; in_variants = 0; in_relations = 0; next }
  in_variants && /^      - / { out("variant", type, $2); next }
  in_fields && /^      - name: / { field = $3; next }
  in_fields && field != "" && /^        type: / {
    t = $0; sub(/^        type: /, "", t)
    out("field", type, field, t)
    field = ""
    next
  }
  in_relations && /^      - name: / { rel = $3; next }
  in_relations && rel != "" && /^        target: / { out("target", type, rel, $2); next }
  ' "$1"/*.yaml
}

# spec_ok: the directory of domain files is one.
spec_ok() {
  [ -d "$spec" ] || { echo "presets: $spec is no directory of domain files"; return 1; }
  for f in "$spec"/*.yaml; do
    [ -r "$f" ] || { echo "presets: cannot read the specification, $spec/*.yaml"; return 1; }
  done
}

# check_catalog <directory, absolute> <file of tables, absolute, or `-` for the standard
# input>: the failures of the directory and the line with the two counts.
check_catalog() {
  dir=$1
  given_tables=$2
  # The line feeds and the NUL bytes of all files at once: what is left of the files without
  # every other byte, as lines and as bytes. A file is looked at alone when there is a NUL
  # byte, and awk looks at the last byte of each file when it reads more lines than there
  # are line feeds.
  set -- $(cat "$dir"/*.yaml "$dir"/*.md 2> /dev/null | tr -d '\001-\011\013-\377' | wc -lc)
  feeds=$1
  nuls=$(($2 - $1))
  others=0
  readme=0
  # An operand of the form `name=value` is an assignment to awk, so every path is absolute.
  set -- reading=tables "$given_tables"
  for f in "$dir"/* "$dir"/.[!.]* "$dir"/..?*; do
    [ -e "$f" ] || [ -L "$f" ] || continue
    entry=${f##*/}
    why=
    if [ -L "$f" ]; then
      why='is a symbolic link'
    elif [ ! -f "$f" ]; then
      why='is no regular file'
    elif [ ! -s "$f" ]; then
      why='is an empty file'
    else
      case $entry in
        .*) why='is hidden: its name starts with `.`' ;;
        *[!A-Za-z0-9@._-]*) why='has a name with a character that is no letter, no digit and none of `@`, `.`, `_` and `-`' ;;
        *.yaml | *.md)
          if [ "$((nuls))" -gt 0 ]; then
            n=$(tr -d '\001-\377' < "$f" | wc -c)
            [ "$((n))" -eq 0 ] || why='holds a NUL byte'
          fi ;;
        *) why='is no preset, no declaration and no page: a file of the catalog is `README.md`, `<family>.md` or `<name>@<version>.<kind>.yaml`' ;;
      esac
    fi
    if [ -n "$why" ]; then
      printf '%s: the entry %s\n' "$entry" "$why"
      others=$((others + 1))
      continue
    fi
    case $entry in
      README.md) readme=1; set -- "$@" reading=readme "$f" ;;
      *.yaml) set -- "$@" reading=yaml "$f" ;;
      *) set -- "$@" reading=page "$f" ;;
    esac
  done

  awk -v nothers="$others" -v readme="$readme" -v feeds="$feeds" '
  function unopt(t) { return (t ~ /^Optional</) ? substr(t, 10, length(t) - 10) : t }
  function base(t) { while (kind[t] == "newtype") t = of[t]; return t }
  function is_struct(t) { return kind[t] == "struct" || kind[t] == "entity" }
  function trim(s) { sub(/^ +/, "", s); sub(/ +$/, "", s); return s }
  function short(f) { sub(/^.*\//, "", f); return f }
  function shown(path) { gsub(/\037\[/, "[", path); gsub(/\037/, ".", path); return path }
  function named(path) { return "`" shown(path) "` " }
  function under(path, step) { return path == "" ? step : path SEP step }
  function fail(file, line, msg) { printf "%s:%d: %s\n", short(file), line, msg; failed++; bad[file] = 1 }
  function norule(msg) { fail(FILE, FNR, "not read: " msg) }
  function has(file, path) { return (file, path) in at }
  function text(file, path) { return ((file, path) in at) ? n_text[at[file, path]] : "" }
  # The items of the list at `path`, as `[a, b]`.
  function items(file, path,    j, s) {
    s = ""
    for (j = 1; has(file, path SEP "[" j "]"); j++) s = s (j > 1 ? ", " : "") text(file, path SEP "[" j "]")
    return "[" s "]"
  }
  # 1 when the list at `path` holds the text `x`.
  function holds(file, path, x,    j) {
    for (j = 1; has(file, path SEP "[" j "]"); j++) if (text(file, path SEP "[" j "]") == x) return 1
    return 0
  }
  # The key of `observation_inputs` of the declaration `d` that names the input `x`, or "".
  function observed_by(d, x,    j, k) {
    for (j = 1; j <= nkeys[d, "observation_inputs"]; j++) {
      k = keyof[d, "observation_inputs", j]
      if (text(d, "observation_inputs" SEP k) == x) return k
    }
    return ""
  }
  function variants(type,    i, s) {
    s = ""
    for (i = 1; i <= vcount[type]; i++) s = s (i > 1 ? ", " : "") "`" vorder[type, i] "`"
    return s
  }
  # 1 when the text is given by an input: the binding passes the value, and no rule that
  # reads the value is applied. A scalar of a preset that holds `${` is a reference or is
  # refused as none.
  function given(x) { return index(x, "${") > 0 }
  # 1 when the node at `path` is given by an input, or one item of the list there is.
  function list_given(file, path,    j) {
    if (given(text(file, path))) return 1
    for (j = 1; has(file, path SEP "[" j "]"); j++) if (given(text(file, path SEP "[" j "]"))) return 1
    return 0
  }
  # The name of the input a reference names: what stands between `${inputs.` and `}`.
  function input_name(x) { return substr(x, 10, length(x) - 10) }
  # A path as one word of a shell command, between quotes (the byte 047).
  function shell_word(s,    out, i, c, len) {
    out = ""; len = length(s)
    for (i = 1; i <= len; i++) { c = substr(s, i, 1); out = out (c == "\047" ? "\047\\\047\047" : c) }
    return "\047" out "\047"
  }

  # ---- the bytes of a line ----------------------------------------------------------------

  # 1 when the bytes of `s` are UTF-8: what is left of the bytes above 127 after every
  # well-formed sequence is taken out is nothing.
  function utf8(s) {
    if (s !~ /[\200-\377]/) return 1
    gsub(/[\302-\337][\200-\277]|\340[\240-\277][\200-\277]|[\341-\354\356\357][\200-\277][\200-\277]|\355[\200-\237][\200-\277]|\360[\220-\277][\200-\277][\200-\277]|[\361-\363][\200-\277][\200-\277][\200-\277]|\364[\200-\217][\200-\277][\200-\277]/, "", s)
    return s !~ /[\200-\377]/
  }

  # ---- the YAML forms this script reads -------------------------------------------------

  # A node of the file at `path`: a mapping, a list or a scalar. A key without a value on
  # its line is `pending` until the first line under it says what it holds.
  function node(path, k, x,    id) {
    if ((FILE, path) in at) id = at[FILE, path]
    else { id = ++nn; at[FILE, path] = id; n_file[id] = FILE; n_line[id] = FNR; n_path[id] = path }
    n_kind[id] = k; n_text[id] = x
  }

  # The path of the key `key` in the mapping at `parent`; "" when the key stands there twice.
  function child(parent, key,    p) {
    p = under(parent, key)
    if ((FILE, p) in at) { norule("the key `" shown(p) "` stands twice in its mapping"); return "" }
    keyof[FILE, parent, ++nkeys[FILE, parent]] = key
    return p
  }

  # What a line holds outside its quoted scalars: 1 with a comment (` #`), 2 with a quote
  # that opens no scalar, 0 with neither. A quote opens a scalar at the start of a value:
  # after `: `, `[`, `{` and `,`. YAML reads any other quote as a character of a plain
  # scalar, and a ` #` after it as a comment.
  function scan(s,    i, n, c, q) {
    q = ""; n = length(s)
    for (i = 1; i <= n; i++) {
      c = substr(s, i, 1)
      if (q != "") { if (c == q) q = ""; continue }
      if (c == "\"" || c == "\047") {
        if (substr(s, 1, i - 1) !~ /(^|[{,[]|: ) *$/) return 2
        q = c
      } else if (c == "#" && substr(s, i - 1, 1) == " ") return 1
    }
    return 0
  }

  # The parts of `s` between commas that lie in no bracket and no quote; the number of parts,
  # -1 when a bracket or a quote does not close. Every quote of `s` opens or closes a scalar:
  # a line with another quote is refused before (`scan`).
  function parts(s, out,    n, i, c, depth, quote, cur) {
    split("", out)
    n = 0; depth = 0; quote = ""; cur = ""
    for (i = 1; i <= length(s); i++) {
      c = substr(s, i, 1)
      if (quote != "") { if (c == quote) quote = ""; cur = cur c; continue }
      if (c == "\"" || c == "\047") { quote = c; cur = cur c; continue }
      if (c == "{" || c == "[") depth++
      if (c == "}" || c == "]") depth--
      if (depth < 0) return -1
      if (c == "," && depth == 0) { out[++n] = trim(cur); cur = ""; continue }
      cur = cur c
    }
    if (depth != 0 || quote != "") return -1
    if (trim(cur) != "" || n > 0) out[++n] = trim(cur)
    return n
  }

  # The kind of a plain scalar under the YAML 1.2 core schema.
  function plain_kind(s) {
    if (s ~ /^(null|Null|NULL|~)$/) return "null"
    if (s ~ /^(true|True|TRUE|false|False|FALSE)$/) return "bool"
    if (s ~ /^[-+]?[0-9]+$/ || s ~ /^0o[0-7]+$/ || s ~ /^0x[0-9a-fA-F]+$/) return "int"
    if (s ~ /^[-+]?([.][0-9]+|[0-9]+([.][0-9]*)?)([eE][-+]?[0-9]+)?$/) return "float"
    if (s ~ /^[-+]?[.](inf|Inf|INF)$/ || s ~ /^[.](nan|NaN|NAN)$/) return "float"
    return "str"
  }

  function kind_name(k) { return k == "int" ? "integer" : k == "float" ? "number" : k == "bool" ? "boolean" : k }

  # A key is text. YAML reads `15` and `0o17` as one integer, and `true` as a boolean.
  function text_key(k) {
    if (plain_kind(k) != "str") norule("the key `" k "` is a YAML " kind_name(plain_kind(k)) " and no text; a key is text")
  }

  function scalar(path, s, inflow,    c, inner) {
    c = substr(s, 1, 1)
    if (c == "\"" || c == "\047") {
      inner = substr(s, 2, length(s) - 2)
      if (length(s) < 2 || substr(s, length(s), 1) != c) { norule("the quoted scalar of `" shown(path) "` does not end at its quote"); return }
      if (c == "\"" && index(inner, "\\") > 0) { norule("the quoted scalar of `" shown(path) "` holds an escape, `\\`, and this script reads none"); return }
      node(path, "str", inner)
      return
    }
    if (s ~ /^[]|>&*!%@`,}#]/ || s ~ /^[-?:]( |$)/) { norule("the value `" s "` of `" shown(path) "` is in a form this script does not read"); return }
    if (index(s, ": ") > 0 || s ~ /:$/) { norule("the plain scalar of `" shown(path) "` holds `: `; quote it"); return }
    if (inflow && s ~ /[][{}]/) { norule("the plain scalar `" s "` of `" shown(path) "` holds a bracket or a brace inside a flow collection; quote it"); return }
    node(path, plain_kind(s), s)
  }

  function value(s, path, inflow) {
    if (s ~ /^[{]/) flow_map(s, path)
    else if (s ~ /^\[/) flow_list(s, path)
    else scalar(path, s, inflow)
  }

  function flow_map(s, path,    n, i, item, k, rest, p) {
    if (s !~ /[}]$/) { norule("the flow mapping of `" shown(path) "` does not close on its line"); return }
    n = parts(substr(s, 2, length(s) - 2), item)
    if (n < 0) { norule("a bracket or a quote in the flow mapping of `" shown(path) "` does not close"); return }
    node(path, "map", "")
    for (i = 1; i <= n; i++) {
      if (!match(item[i], /^[A-Za-z0-9_.@-]+:( |$)/)) { norule("`" item[i] "` in the flow mapping of `" shown(path) "` is no `key: value`"); continue }
      k = substr(item[i], 1, RLENGTH); sub(/: ?$/, "", k)
      rest = trim(substr(item[i], RLENGTH + 1))
      text_key(k)
      p = child(path, k)
      if (p == "") continue
      if (rest == "") { norule("`" shown(p) "` has no value in its flow mapping"); continue }
      value(rest, p, 1)
    }
  }

  function flow_list(s, path,    n, i, item) {
    if (s !~ /\]$/) { norule("the flow list of `" shown(path) "` does not close on its line"); return }
    n = parts(substr(s, 2, length(s) - 2), item)
    if (n < 0) { norule("a bracket or a quote in the flow list of `" shown(path) "` does not close"); return }
    node(path, "list", "")
    for (i = 1; i <= n; i++) {
      if (item[i] == "") { norule("the flow list of `" shown(path) "` holds an empty item"); continue }
      value(item[i], path SEP "[" i "]", 1)
    }
  }

  # ---- the declared type of a node --------------------------------------------------------

  # The declared type at `path` of a file of the kind `fk`; "Json" under free JSON; "" with
  # `why` set where the last step has no place, and "" without it where an earlier step has
  # none or the node above is of another kind than its type (that node is named itself).
  function decl_type(fk, path,    n, i, steps, s, t) {
    n = split(path, steps, SEP)
    if (fk == "assessor") { t = "ratchet.assessor.Assessor"; i = 1 }
    else {
      s = steps[1]
      if (s == "format") t = "String"
      else if (s == "preset") t = "ratchet.specification.Preset"
      else if (s in member) t = "Map<String, " member[s] ">"
      else {
        why = (n == 1) ? "is no member of a preset: beside `format` and `preset` its file holds " variants("ratchet.specification.PresetMember") " (ratchet.specification.PresetMember)" : ""
        return ""
      }
      i = 2
    }
    for (; i <= n; i++) {
      s = steps[i]
      t = unopt(t)
      if (t == "Json") return "Json"
      if (s ~ /^\[[0-9]+\]$/) {
        if (t !~ /^List</) return ""
        t = substr(t, 6, length(t) - 6)
      } else if (t ~ /^Map<String, /) {
        t = substr(t, 13, length(t) - 13)
      } else if (is_struct(t)) {
        if ((t in entry) && s == "project") { why = (i == n) ? "is the `project` of an entry, which the project that binds the preset gives it" : ""; return "" }
        if (!((t, s) in ftype)) {
          if (open[t]) return "Json"
          why = (i == n) ? "is not a field of " t : ""
          return ""
        }
        t = ftype[t, s]
      } else return ""
    }
    return t
  }

  # "" when the node fits the declared type `t`, or what is wrong.
  function misfit(t, k, x,    b) {
    t = unopt(t)
    if (t == "Json") return ""
    if (k == "null") return "is null; an absent member is left out"
    if (t ~ /^List</) return k == "list" ? "" : "is not a list (`" t "`)"
    if (t ~ /^Map<String, / || is_struct(t)) return k == "map" ? "" : "is not a mapping (`" t "`)"
    if (k == "map" || k == "list") return "is a " (k == "map" ? "mapping" : "list") " where `" t "` is declared"
    b = base(t)
    if (b == "Integer") return (k == "int" && x ~ /^-?[0-9]+$/) ? "" : "is not an integer (`" t "`)"
    if (b == "Boolean") return (k == "bool" && (x == "true" || x == "false")) ? "" : "is not `true` or `false` (`" t "`)"
    if (b == "Decimal") return ((k == "int" || k == "float" || k == "str") && x ~ /^-?[0-9]+([.][0-9]+)?$/) ? "" : "is not a decimal without exponent and sign `+` (`" t "`)"
    if (kind[b] == "enum") {
      if (k != "str") return "is a YAML " kind_name(k) " where a value of " b " is declared"
      return ((b, x) in variant) ? "" : "is `" x "`, which is no value of " b
    }
    if (b == "String" || b == "Timestamp" || b == "Duration") {
      if (k != "str") return "is a YAML " kind_name(k) " where text is declared (`" t "`); quote it"
      return x == "" ? "is empty text (`" t "`); a member without a value is left out" : ""
    }
    return "has the declared type `" t "`, which spec/presets.test.sh has no rule for"
  }

  # The fields the struct `u` requires, at the mapping of the node at `path`.
  function required(F, line, path, u,    j, f) {
    for (j = 1; j <= count[u]; j++) {
      f = order[u, j]
      if (ftype[u, f] ~ /^Optional</) continue
      if ((u in entry) && f == "project") continue
      if ((u, f) in may_be_absent) continue
      if (!has(F, under(path, f))) fail(F, line, "`" (path == "" ? "(root)" : shown(path)) "` has no `" f "`, which " u " requires")
    }
  }

  # 1 when `path` is a name by which a requirement names another entry of its preset: its
  # assessment, its measurement, or a statement it serves.
  function inner_name(path,    n, s) {
    n = split(path, s, SEP)
    if (s[1] != "requirements") return 0
    if (n == 3) return s[3] == "assessment" || s[3] == "measurement" || s[3] == "serves"
    return n == 4 && s[3] == "serves"
  }

  # 1 when `path` is the `observation.conditions` of a plan, where an input of the type
  # `conditions` stands.
  function plan_conditions(path,    n, s) {
    n = split(path, s, SEP)
    return n == 4 && s[1] == "assessments" && s[3] == "observation" && s[4] == "conditions"
  }

  # A scalar of a preset that holds `${` or `{inputs.`, or a scalar of a declaration that is
  # `${inputs.<name>}` alone: a reference to an input of the preset.
  function reference(i, F, fk, path, t,    x, name, ip, it, il, u, e, b, ok, here, j, v) {
    x = n_text[i]
    here = "`" shown(path) "` "
    if (x !~ REF) { fail(F, n_line[i], here "holds `${` or `{inputs.` and is not `${inputs.<name>}` alone: a reference to an input is the whole of a value and has this one spelling"); return }
    name = input_name(x)
    if (fk != "preset") { fail(F, n_line[i], here "refers to the input `" name "`, and only a preset declares inputs to refer to"); return }
    if (path == "preset" || index(path, "preset" SEP) == 1) { fail(F, n_line[i], here "is a reference inside the `preset` block, which holds none"); return }
    if (inner_name(path)) { fail(F, n_line[i], here "is a reference, and the name by which a requirement names an assessment, a measurement or a statement of its preset is written out: no row `<name>@<version>/<assessment>/<measurement>` can be checked against a name that the binding gives"); return }
    ip = "preset" SEP "inputs" SEP name
    if (!has(F, ip)) { fail(F, n_line[i], here "refers to the input `" name "`, which the preset does not declare"); return }
    it = text(F, ip SEP "type")
    il = (text(F, ip SEP "list") == "true")
    u = unopt(t)
    if (u == "Json") return
    if (u ~ /^List</) {
      if (!il) { fail(F, n_line[i], here "takes a list (`" u "`), and the input `" name "` declares no `list`"); return }
      e = substr(u, 6, length(u) - 6)
    } else {
      if (il) { fail(F, n_line[i], here "takes one value (`" u "`), and the input `" name "` declares a list"); return }
      e = u
    }
    # An input of the type `conditions` stands as the whole value of `observation.conditions`
    # of a plan, and nowhere else.
    if (it == "conditions" && plan_conditions(path)) return
    if (e ~ /^Map<String, / || e ~ /^List</ || is_struct(e)) { fail(F, n_line[i], here "is a `" e "`, and an input stands for a scalar or a list of scalars" (plan_conditions(path) ? ", or for the conditions of a plan where it has the type `conditions`" : "")); return }
    b = base(e)
    if (b == "Integer") ok = (it == "integer")
    else if (b == "Decimal") ok = (it == "integer" || it == "decimal")
    else if (b == "Boolean") ok = (it == "boolean")
    else ok = (it == "string" || it == "path")
    if (!ok) { fail(F, n_line[i], here "takes `" e "`, and the input `" name "` has the type `" it "`"); return }
    # An input with `values` stands at the place of a closed list only where each of its
    # values is a value of that list.
    if (kind[b] == "enum" && it == "string" && has(F, ip SEP "values"))
      for (j = 1; has(F, ip SEP "values" SEP "[" j "]"); j++) {
        v = text(F, ip SEP "values" SEP "[" j "]")
        if (!((b, v) in variant)) { fail(F, n_line[i], here "takes `" e "`, and the input `" name "` lists the value `" v "`, which is no value of " b); return }
      }
  }

  # ---- what joins two places of the directory -----------------------------------------------

  # An input type in words: `path`, or a list of `string`.
  function typed(it, il) { return (il ? "a list of " : "") "`" it "`" }

  # "" when the node at `path` is a literal of the input type `it`, a list of it with `il`;
  # or what it is not. With `refs`, where an assessment passes the value, an item that is a
  # reference has the type of the input it names; without, in a default, `${` is text.
  function unfit(F, path, it, il, refs,    id, k, x, j, m, ip, rt) {
    id = at[F, path]; k = n_kind[id]; x = n_text[id]
    if (il) {
      if (k != "list") return "is no list"
      for (j = 1; has(F, path SEP "[" j "]"); j++) {
        m = unfit(F, path SEP "[" j "]", it, 0, refs)
        if (m != "") return "holds an item that " m
      }
      return ""
    }
    if (k == "list" || k == "map") return "is a " (k == "map" ? "mapping" : "list") " and no scalar"
    if (refs && x ~ REF) {
      ip = "preset" SEP "inputs" SEP input_name(x)
      # An input the preset does not declare is named where the reference stands.
      if (!has(F, ip)) return ""
      if (text(F, ip SEP "list") == "true") return "is the input `" input_name(x) "` of the preset, a list"
      rt = text(F, ip SEP "type")
      return (rt == it || (rt == "integer" && it == "decimal")) ? "" : "is the input `" input_name(x) "` of the preset, `" rt "`"
    }
    if (it == "integer") return (k == "int" && x ~ /^-?[0-9]+$/) ? "" : "is no integer"
    if (it == "decimal") return ((k == "int" || k == "float") && x ~ /^-?[0-9]+([.][0-9]+)?$/) ? "" : "is no decimal without exponent and sign `+`"
    if (it == "boolean") return (k == "bool" && (x == "true" || x == "false")) ? "" : "is not `true` or `false`"
    return k == "str" ? "" : "is no text"
  }

  # The path of the output a measurement reads, in the declaration of its assessor; "" where
  # the output is not declared. Sets A (the assessor), D (its declaration, "" without one)
  # and O (the name of the output). An output `coverage.<count>` that the declaration does
  # not declare reads a count of the coverage of the run (docs/design.md § 3 "Evidence
  # coverage"): CC is then the count, a variant of ratchet.assessor.CoverageCount or not,
  # and "" for every other output, and counted is 1 where the declaration lists the count
  # under `coverage`.
  function output_of(F, mp,    s) {
    split(mp, s, SEP)
    A = text(F, "assessments" SEP s[2] SEP "assessor"); D = ""; O = text(F, mp SEP "output")
    CC = ""; counted = 0
    if (!(A in declaration)) return ""
    D = declaration[A]
    if (has(D, "outputs" SEP O)) return "outputs" SEP O
    if (substr(O, 1, 9) == "coverage.") {
      CC = substr(O, 10)
      counted = (("ratchet.assessor.CoverageCount", CC) in variant) && holds(D, "coverage", CC)
    }
    return ""
  }

  # The path of the measurement a requirement compares: the one it names, or the one its
  # assessment holds; "" where there is none (named at the requirement).
  function compared(F, path,    mp) {
    if (!has(F, path SEP "assessment")) return ""
    mp = "assessments" SEP text(F, path SEP "assessment") SEP "measurements"
    if (has(F, path SEP "measurement")) {
      mp = mp SEP text(F, path SEP "measurement")
      return has(F, mp) ? mp : ""
    }
    return nkeys[F, mp] == 1 ? mp SEP keyof[F, mp, 1] : ""
  }

  # The number of conditions a plan declares, over the classes of `observation.conditions`.
  function conditions_of(F, plan,    cp, j, c) {
    cp = plan SEP "observation" SEP "conditions"
    for (j = 1; j <= nkeys[F, cp]; j++) c += nkeys[F, cp SEP keyof[F, cp, j]]
    return c + 0
  }
  function last(path) { sub(/^.*\037/, "", path); return path }

  # The first value at `path` of the file F, or the first item of the list there, that the
  # list at `vp` of the file VF does not hold; "" where it holds each. With `refs`, where a
  # plan passes the value, a reference is not read: the binding passes its value.
  function outside(F, path, VF, vp, refs,    j, x) {
    if (has(F, path SEP "[1]")) {
      for (j = 1; has(F, path SEP "[" j "]"); j++) {
        x = text(F, path SEP "[" j "]")
        if (!(refs && given(x)) && !holds(VF, vp, x)) return x
      }
      return ""
    }
    x = text(F, path)
    return ((refs && given(x)) || holds(VF, vp, x)) ? "" : x
  }

  # ---- a page: what Markdown does not show ---------------------------------------------------

  # The run of backticks or of tildes that a line starts with after at most three spaces: its
  # length, or 0 where the line starts with fewer than three. Sets RUN_CHAR, the character,
  # and RUN_REST, what follows the run.
  function fence_run(s,    c, n) {
    RUN_CHAR = ""; RUN_REST = ""
    if (s !~ /^ ? ? ?(```|~~~)/) return 0
    sub(/^ +/, "", s)
    c = substr(s, 1, 1)
    n = 0
    while (substr(s, n + 1, 1) == c) n++
    RUN_CHAR = c; RUN_REST = substr(s, n + 1)
    return n
  }

  # Where the code span ends that the backticks at the place `j` of `s` open: the place after
  # its closing run, a run of the same length; or the place after the opening run where no
  # such run follows on the line, and the backticks are text.
  function span_end(s, j,    m, p, r, len) {
    len = length(s)
    m = 0
    while (substr(s, j + m, 1) == "`") m++
    p = j + m
    while (p <= len) {
      if (substr(s, p, 1) != "`") { p++; continue }
      r = 0
      while (substr(s, p + r, 1) == "`") r++
      if (r == m) return p + r
      p += r
    }
    return j + m
  }

  # The line without the text of its HTML comments; a comment may end on a later line. A
  # `<!--` inside a code span that starts before it and closes on the line opens no comment.
  function uncomment(s,    i, j, k, out) {
    out = ""
    while (1) {
      if (in_comment) {
        i = index(s, "-->")
        if (i == 0) return out
        s = substr(s, i + 3); in_comment = 0
      }
      i = index(s, "<!--")
      if (i == 0) return out s
      j = index(s, "`")
      if (j > 0 && j < i) {
        k = span_end(s, j)
        out = out substr(s, 1, k - 1); s = substr(s, k)
        continue
      }
      out = out substr(s, 1, i - 1); s = substr(s, i + 4); in_comment = 1
    }
  }

  # A row with its escaped bars put aside: `\|`, a bar of the text and no border of a cell,
  # becomes the byte 1, and `\\`, a backslash of the text, the byte 2. No line that is read
  # holds these bytes: a control character is refused before.
  function masked(s,    out, i, c, d, len) {
    out = ""; len = length(s)
    for (i = 1; i <= len; i++) {
      c = substr(s, i, 1)
      if (c == "\\") {
        d = substr(s, i + 1, 1)
        if (d == "|") { out = out "\001"; i++; continue }
        if (d == "\\") { out = out "\002"; i++; continue }
      }
      out = out c
    }
    return out
  }
  # A cell of a masked row as it is written.
  function unmasked(s,    out, i, c, len) {
    if (s !~ /[\001\002]/) return s
    out = ""; len = length(s)
    for (i = 1; i <= len; i++) {
      c = substr(s, i, 1)
      out = out (c == "\001" ? "\\|" : c == "\002" ? "\\\\" : c)
    }
    return out
  }

  # 1 when a cell shows nothing: spaces, tabs and no-break spaces.
  function blank(s) { gsub(/[ \t]|\302\240/, "", s); return s == "" }

  BEGIN {
    SEP = "\037"
    HEADER = "| Measurement | Direction | Unit | Tolerance | Evidence |"
    # A reference to an input: the name is a key as this script reads one.
    REF = "^[$][{]inputs[.][A-Za-z0-9_.@-]+[}]$"
    # The assessor of Ratchet itself that reads the runs of another plan
    # (spec/domains/assessor.yaml); no file declares it.
    SERIES = "record-series@1"
    # spec/README.md, "How a `ratchet/1` file differs from the declared entities".
    may_be_absent["ratchet.specification.QualityRequirement", "serves"] = 1
  }

  # ---- the tables of the specification (`tables`) --------------------------------------------
  reading == "tables" {
    split($0, f, "\t")
    if (f[1] == "kind") kind[f[2]] = f[3]
    else if (f[1] == "of") of[f[2]] = f[3]
    else if (f[1] == "variant") { variant[f[2], f[3]] = 1; vorder[f[2], ++vcount[f[2]]] = f[3] }
    else if (f[1] == "open") open[f[2]] = 1
    else if (f[1] == "field") { order[f[2], ++count[f[2]]] = f[3]; ftype[f[2], f[3]] = f[4] }
    else if (f[1] == "target") target[f[2], f[3]] = f[4]
    next
  }

  # The lists of the specification this script reads, once, before the first file of the
  # directory.
  !lists_read {
    lists_read = 1
    read_lists()
  }
  function read_lists(    i, m) {
    if (vcount["ratchet.config.CatalogFileKind"] == 0) { print "presets: the specification declares no ratchet.config.CatalogFileKind, the kinds of file of a catalog source"; broken = 1; exit 1 }
    if (vcount["ratchet.specification.PresetMember"] == 0) { print "presets: the specification declares no ratchet.specification.PresetMember, the maps of a preset"; broken = 1; exit 1 }
    for (i = 1; i <= vcount["ratchet.specification.PresetMember"]; i++) {
      m = vorder["ratchet.specification.PresetMember", i]
      if (!(("ratchet.specification.QualitySpecification", m) in target)) { print "presets: ratchet.specification.PresetMember holds `" m "`, and ratchet.specification.QualitySpecification has no relation of that name"; broken = 1; exit 1 }
      member[m] = target["ratchet.specification.QualitySpecification", m]
      entry[member[m]] = 1
    }
  }

  # ---- a file of the directory: its first line, and the bytes of every line ------------------
  FNR == 1 {
    FILE = FILENAME
    if (reading == "yaml") {
      depth = 0
      yf[++ny] = FILE
      node("", "map", "")
      b = short(FILE); stem = b; sub(/[.]yaml$/, "", stem)
      k = stem; sub(/^.*[.]/, "", k)
      if (index(stem, ".") == 0 || !(("ratchet.config.CatalogFileKind", k) in variant)) {
        fkind[FILE] = "unknown"
        fail(FILE, 1, "the file is no `<name>@<version>.<kind>.yaml` with a kind of ratchet.config.CatalogFileKind: " variants("ratchet.config.CatalogFileKind"))
      } else { fkind[FILE] = k; ident[FILE] = substr(stem, 1, length(stem) - length(k) - 1) }
    }
    if (reading == "page") { pg[++np] = FILE; in_table = 0; fence = ""; fence_len = 0; in_comment = 0 }
    read_file[++nread] = FILE
  }
  # The lines of the files of the directory, for the line feed of the last line of each.
  { nlines++; last_line[FILE] = FNR }
  # Only a line with a byte that is no printable ASCII and no tab is looked at further. The
  # line is UTF-8 from the second test on, so the first byte of each sequence below starts a
  # character: 302, 342 and 357 are no second or third byte of one.
  /[^\011\040-\176]/ {
    if (!utf8($0)) { fail(FILE, FNR, "the line is not UTF-8"); next }
    if ($0 ~ /[\001-\010\013-\037\177]/) { fail(FILE, FNR, "the line holds a control character, such as a carriage return; a line ends with a line feed, and only a page holds tabs"); next }
    # U+0080 to U+009F.
    if ($0 ~ /\302[\200-\237]/) { fail(FILE, FNR, "the line holds a C1 control character, U+0080 to U+009F, such as the next line U+0085, which a YAML 1.1 reader takes as the end of a line"); next }
    # U+2028 and U+2029.
    if ($0 ~ /\342\200[\250\251]/) { fail(FILE, FNR, "the line holds the line separator U+2028 or the paragraph separator U+2029, which a YAML 1.1 reader takes as the end of a line"); next }
    # U+FEFF.
    if ($0 ~ /\357\273\277/) { fail(FILE, FNR, "the line holds the byte order mark U+FEFF; a file of the catalog holds none, also not as its first character"); next }
    # U+FFFE and U+FFFF.
    if ($0 ~ /\357\277[\276\277]/) { fail(FILE, FNR, "the line holds U+FFFE or U+FFFF, which is no character"); next }
    # U+200B, U+200E, U+200F and U+202A to U+202E; U+2060 and U+2066 to U+2069.
    if ($0 ~ /\342\200[\213\216\217\252-\256]|\342\201[\240\246-\251]/) { fail(FILE, FNR, "the line holds a character that hides or reorders text: U+200B, U+200E, U+200F, U+202A to U+202E, U+2060 or U+2066 to U+2069"); next }
  }
  reading == "readme" { next }

  # ---- a YAML file of the directory -----------------------------------------------------
  reading == "yaml" {
    if ($0 ~ /^ *$/) next
    if (index($0, "\t") > 0) { norule("a tab"); next }
    if ($0 ~ /^ *#/) { norule("a comment; a preset and a declaration hold none"); next }
    if ($0 ~ /[#"\047]/) {
      found = scan($0)
      if (found == 1) { norule("a comment after a value; a preset and a declaration hold none"); next }
      if (found == 2) { norule("a quote inside a plain scalar; a scalar that holds a quote is quoted whole, in the other kind of quote"); next }
    }
    indent = match($0, /[^ ]/) - 1
    content = substr($0, indent + 1); sub(/ +$/, "", content)
    while (depth > 0 && ind[depth] >= indent) depth--
    parent = depth > 0 ? pth[depth] : ""
    if (depth == 0 && indent > 0) { norule("`" content "` is indented at the root of the file"); next }
    if (depth > 0 && !opens[depth]) { norule("`" content "` is indented under `" shown(parent) "`, which has a value on its line"); next }
    if (depth > 0) {
      if (cind[depth] == "") cind[depth] = indent
      else if (cind[depth] != indent) { norule("`" content "` is not indented as the line before it under `" shown(parent) "`"); next }
    }
    if (content ~ /^[{[]/) {
      if (depth == 0 || state[depth] != "") { norule("a flow collection that is the value of no key"); next }
      state[depth] = "flow"
      value(content, parent, 0)
      next
    }
    if (content ~ /^- /) { norule("a block list; a list is written `[...]` on one line"); next }
    if (!match(content, /^[A-Za-z0-9_.@-]+:( |$)/)) { norule("`" content "` is no `key:` and no `key: value`"); next }
    if (depth > 0 && state[depth] == "flow") { norule("`" content "` follows the flow collection of `" shown(parent) "`"); next }
    if (depth > 0 && state[depth] == "") { state[depth] = "map"; n_kind[at[FILE, parent]] = "map" }
    k = substr(content, 1, RLENGTH); sub(/: ?$/, "", k)
    rest = trim(substr(content, RLENGTH + 1))
    text_key(k)
    p = child(parent, k)
    if (p == "") next
    depth++; ind[depth] = indent; pth[depth] = p; opens[depth] = (rest == ""); state[depth] = ""; cind[depth] = ""
    if (rest == "") node(p, "pending", "")
    else value(rest, p, 0)
    next
  }

  # ---- a page of the directory: the rows of its tables --------------------------------------
  reading == "page" {
    line = $0
    # A code fence (CommonMark): it opens at a run of three or more backticks or tildes that
    # is indented by at most three spaces, and after a run of backticks the line holds no
    # further backtick. It closes at a run of the same character that is at least as long,
    # indented by at most three spaces, with nothing but spaces and tabs after it.
    marks = fence_run(line)
    if (fence != "") {
      if (marks >= fence_len && RUN_CHAR == fence && RUN_REST ~ /^[ \t]*$/) fence = ""
      next
    }
    if (!in_comment && marks >= 3 && (RUN_CHAR == "~" || index(RUN_REST, "`") == 0)) { fence = RUN_CHAR; fence_len = marks; in_table = 0; next }
    if (in_comment || index(line, "<!--") > 0) line = uncomment(line)
    if (line == HEADER) { in_table = 1; ruled = 0; tables[FILE]++; next }
    if (!in_table) next
    if (line !~ /^\|/) { in_table = 0; next }
    if (!ruled) {
      ruled = 1
      if (line !~ /^\|( *:?-+:? *\|)+ *$/) fail(FILE, FNR, "the line under the header of a table is no `| --- | ... |`")
      next
    }
    rows_in[FILE]++
    # `\|` is a bar of the text of a cell, as a Markdown reader with tables takes it.
    escaped = (index(line, "\\") > 0)
    if (escaped) line = masked(line)
    if (line !~ /\| *$/) { fail(FILE, FNR, "a row does not end with `|`"); next }
    sub(/^\| */, "", line); sub(/ *\| *$/, "", line)
    n = split(line, cell, /\|/)
    if (n != 5) { fail(FILE, FNR, "a row has " n " cells; a row has 5, and a `|` inside a cell is written `\\|`"); next }
    if (escaped) for (i = 1; i <= 5; i++) cell[i] = unmasked(cell[i])
    cell[1] = trim(cell[1])
    if (cell[1] !~ /^`[^`]+`$/) { fail(FILE, FNR, "the first cell of a row is `" cell[1] "`; it is the name of a measurement between backticks, `<name>@<version>/<assessment>/<measurement>`"); next }
    id = substr(cell[1], 2, length(cell[1]) - 2)
    rw[++nr] = id; rw_file[nr] = FILE; rw_line[nr] = FNR
    row_count[id]++
    row_page[id] = FILE
    filled = 1
    for (i = 2; i <= 5; i++) if (blank(cell[i])) {
      split(HEADER, head, /\|/)
      fail(FILE, FNR, "the cell `" trim(head[i + 1]) "` of the row `" id "` is empty")
      filled = 0
    }
    if (filled) row_filled[id]++
    next
  }

  END {
    if (broken) exit 1
    if (!lists_read) read_lists()

    if (!readme) { print "README.md: the directory holds no README.md"; failed++ }

    # The name and the version a file states.
    for (y = 1; y <= ny; y++) {
      F = yf[y]; fk = fkind[F]
      if (fk == "preset") {
        name = text(F, "preset" SEP "name"); version = text(F, "preset" SEP "version"); presets++
        if (nkeys[F, "requirements"] + 0 == 0) fail(F, 1, "the preset holds no requirement; a preset of the catalog holds at least one, and with it an assessment and a measurement")
      } else if (fk == "assessor") { name = text(F, "name"); version = text(F, "version") }
      else continue
      id = name "@" version
      stated[F] = id
      if (index(name, "@") > 0 || index(version, "@") > 0) fail(F, 1, "the name `" name "` or the version `" version "` holds `@`; `<name>@<version>` is cut at its one `@`")
      if (id != ident[F]) fail(F, 1, "the file is named `" ident[F] "." fk ".yaml` and states the name and the version `" id "`; it is the file `<name>@<version>." fk ".yaml`")
      if (fk == "assessor") {
        if (ident[F] == SERIES || id == SERIES) fail(F, 1, "the file declares `" SERIES "`, the assessor of Ratchet itself that reads the runs of another plan: the name is reserved, and a directory of the catalog holds no declaration of it")
        else declaration[ident[F]] = F
      }
    }
    if (presets == 0) { print "presets: the directory holds no preset, a file `<name>@<version>.preset.yaml`"; failed++ }

    # Place, type, required fields and references to inputs.
    for (i = 1; i <= nn; i++) {
      F = n_file[i]; fk = fkind[F]; path = n_path[i]
      if (fk != "preset" && fk != "assessor") continue
      if (path == "") {
        if (fk == "assessor") {
          required(F, 1, "", "ratchet.assessor.Assessor")
          if (text(F, "format") != "ratchet-assessor/1") fail(F, 1, "`format` is not `ratchet-assessor/1`")
        } else {
          if (!has(F, "format")) fail(F, 1, "`(root)` has no `format`")
          else if (text(F, "format") != "ratchet/1") fail(F, n_line[at[F, "format"]], "`format` is not `ratchet/1`")
          if (!has(F, "preset")) fail(F, 1, "`(root)` has no `preset` block")
        }
        continue
      }
      why = ""
      t = decl_type(fk, path)
      if (t == "") { if (why != "") fail(F, n_line[i], "`" shown(path) "` " why); continue }
      k = n_kind[i]
      if (k == "pending") { fail(F, n_line[i], "`" shown(path) "` has no value on its line and nothing under it"); continue }
      # In a declaration `${` is text, and only what is spelled as a reference is refused.
      if (k != "map" && k != "list" && (index(n_text[i], "${") > 0 || index(n_text[i], "{inputs.") > 0) && (fk == "preset" || n_text[i] ~ REF)) { reference(i, F, fk, path, t); continue }
      m = misfit(t, k, n_text[i])
      if (m != "") { fail(F, n_line[i], "`" shown(path) "` " m); continue }
      u = unopt(t)
      if (is_struct(u)) required(F, n_line[i], path, u)
    }

    # The default of an input, and what joins two places of the directory.
    for (i = 1; i <= nn; i++) {
      F = n_file[i]; fk = fkind[F]
      path = n_path[i]
      n = split(path, s, SEP)
      if (s[n] == "default" && ((fk == "preset" && n == 4 && s[1] == "preset" && s[2] == "inputs") || (fk == "assessor" && n == 3 && s[1] == "inputs"))) {
        ip = substr(path, 1, length(path) - 8)
        it = text(F, ip SEP "type"); il = (text(F, ip SEP "list") == "true")
        # An input of the type `conditions` has no default: the decoder reads that invariant.
        if (("ratchet.specification.InputType", it) in variant && it != "conditions") {
          m = unfit(F, path, it, il, 0)
          if (m != "") fail(F, n_line[i], named(path) m ", and its input has the type " typed(it, il))
          # A default is one of the values of its input.
          else if (it == "string" && has(F, ip SEP "values") && (v = outside(F, path, F, ip SEP "values", 0)) != "")
            fail(F, n_line[i], named(path) (il ? "holds the item `" : "is `") v "`, which is none of the values `" items(F, ip SEP "values") "` of the input `" last(ip) "`")
        }
      }
      # The cache condition has one name in a plan, a declaration and a record:
      # `cache_profile`, the member of ratchet.evidence.ObservedConditions.
      if (fk == "assessor" && n == 2 && s[1] == "conditions" && s[2] ~ /^\[[0-9]+\]$/ && n_text[i] == "cache")
        fail(F, n_line[i], named(path) "is the condition `cache`; a declaration writes the cache condition as `cache_profile` and under no other name")
      # An input of a declaration takes no name of ratchet.assessor.ReservedArgument: Ratchet
      # passes those arguments itself (docs/evidence-format.md § 10, "Reserved names").
      if (fk == "assessor" && n == 2 && s[1] == "inputs" && (("ratchet.assessor.ReservedArgument", s[2]) in variant))
        fail(F, n_line[i], named(path) "has the name of a reserved argument, which Ratchet passes itself (ratchet.assessor.ReservedArgument: " variants("ratchet.assessor.ReservedArgument") "); an assessor declares no input of these names")
      # An assessor reads the conditions of no plan as an input: only a preset declares an
      # input of the type `conditions` (ratchet.specification.InputDeclaration).
      if (fk == "assessor" && n == 3 && s[1] == "inputs" && s[3] == "type" && n_text[i] == "conditions")
        fail(F, n_line[i], "`inputs." s[2] "` has the type `conditions`, and only a preset declares an input of the type `conditions`: an assessor reads no plan'"'"'s conditions as an input")
      # A key of `observation_inputs` is a key of the observation that Ratchet passes, and
      # names an input of the declaration (docs/evidence-format.md § 10, "Invocation").
      if (fk == "assessor" && n == 2 && s[1] == "observation_inputs") {
        if (!(("ratchet.assessor.ObservationKey", s[2]) in variant))
          fail(F, n_line[i], named(path) "is no key of the observation that Ratchet passes (ratchet.assessor.ObservationKey: " variants("ratchet.assessor.ObservationKey") ")")
        if (!has(F, "inputs" SEP n_text[i]))
          fail(F, n_line[i], named(path) "names the input `" n_text[i] "`, which the declaration does not declare under `inputs`")
      }
      # An entry of `revision_inputs` names an input of the declaration
      # (docs/evidence-format.md § 10, "The revision").
      if (fk == "assessor" && n == 2 && s[1] == "revision_inputs" && s[2] ~ /^\[[0-9]+\]$/ && !has(F, "inputs" SEP n_text[i]))
        fail(F, n_line[i], named(path) "names the input `" n_text[i] "`, which the declaration does not declare under `inputs`")
      # The values of an item field are listed under a field of `item_fields`
      # (docs/evidence-format.md § 10).
      if (fk == "assessor" && n == 4 && s[1] == "outputs" && s[3] == "item_values" && !holds(F, "outputs" SEP s[2] SEP "item_fields", s[4]))
        fail(F, n_line[i], named(path) "lists the values of the field `" s[4] "`, which the output `" s[2] "` does not name under `item_fields` " items(F, "outputs" SEP s[2] SEP "item_fields"))
      if (fk != "preset") continue

      if (n == 4 && s[1] == "preset" && s[2] == "inputs" && s[4] == "local" && n_text[i] == "true")
        fail(F, n_line[i], "the input `" s[3] "` is local, and a preset declares no local input (`preset_input_local`)")

      if (n == 2 && s[1] == "assessments") {
        a = text(F, path SEP "assessor")
        # A window over the runs of another plan: the four invariants of
        # ratchet.specification.AssessmentPlan, which name the assessor of Ratchet itself.
        if (has(F, path SEP "observation" SEP "population" SEP "runs_of")) {
          if (has(F, path SEP "assessor") && a != SERIES && !given(a))
            fail(F, n_line[i], named(path) "reads the runs of another plan (`observation.population.runs_of`) and names the assessor `" a "`; such a plan names `" SERIES "`")
          if (has(F, path SEP "target" SEP "selection"))
            fail(F, n_line[i], named(path) "reads the runs of another plan (`observation.population.runs_of`) and has a `target.selection`; such a plan has none")
          if (has(F, path SEP "observation" SEP "conditions"))
            fail(F, n_line[i], named(path) "reads the runs of another plan (`observation.population.runs_of`) and declares `observation.conditions`; such a plan declares none, because only runs that qualified under the source plan enter its population")
        } else if (a == SERIES)
          fail(F, n_line[i], named(path) "names the assessor `" SERIES "` and has no `observation.population.runs_of`: that assessor reads the runs of another plan")
        if (!has(F, path SEP "assessor") || !(a in declaration)) continue
        D = declaration[a]
        for (j = 1; j <= nkeys[D, "inputs"]; j++) {
          dp = "inputs" SEP keyof[D, "inputs", j]
          if (text(D, dp SEP "required") != "true" || text(D, dp SEP "local") == "true") continue
          # An input that the declaration names in `observation_inputs` is passed by that
          # key of the `observation` of the plan.
          okey = observed_by(D, keyof[D, "inputs", j])
          if (okey != "") {
            if (!has(F, path SEP "observation" SEP okey))
              fail(F, n_line[i], named(path) "has no `observation." okey "`, which `" a "` passes as its required input `" keyof[D, "inputs", j] "` (`observation_inputs`)")
          } else if (!has(F, path SEP dp))
            fail(F, n_line[i], named(path) "passes no `" keyof[D, "inputs", j] "`, which `" a "` requires")
        }
      }

      # No declaration is looked for where the assessor is the one of Ratchet itself, and
      # where an input gives it.
      if (n == 3 && s[1] == "assessments" && s[3] == "assessor" && n_text[i] != SERIES && !given(n_text[i]) && !(n_text[i] in declaration))
        fail(F, n_line[i], named(path) "names the assessor `" n_text[i] "`, and the directory holds no `" n_text[i] ".assessor.yaml`")

      if (n == 4 && s[1] == "assessments" && s[3] == "target" && s[4] == "kind") {
        a = text(F, "assessments" SEP s[2] SEP "assessor")
        if (a in declaration) {
          # A kind that an input gives is the default of that input until a binding passes
          # another; without a default the binding passes it.
          tk = n_text[i]; by = ""
          if (given(tk)) {
            ip = "preset" SEP "inputs" SEP input_name(tk)
            if (tk ~ REF && has(F, ip SEP "default")) { by = ", the default of the input `" input_name(tk) "`"; tk = text(F, ip SEP "default") }
            else tk = ""
          }
          if (tk != "" && !holds(declaration[a], "targets", tk))
            fail(F, n_line[i], named(path) "is `" tk "`" by ", and `" a "` declares the targets `" items(declaration[a], "targets") "`")
        }
      }

      if (n == 4 && s[1] == "assessments" && s[3] == "inputs") {
        a = text(F, "assessments" SEP s[2] SEP "assessor")
        if (a == SERIES) { fail(F, n_line[i], named(path) "passes the input `" s[4] "`, and `" SERIES "` takes no input"); continue }
        if (!(a in declaration)) continue
        D = declaration[a]; dp = "inputs" SEP s[4]
        if (!has(D, dp)) { fail(F, n_line[i], named(path) "passes the input `" s[4] "`, which `" a "` does not declare"); continue }
        if (text(D, dp SEP "local") == "true") { fail(F, n_line[i], named(path) "passes the input `" s[4] "`, which `" a "` declares local: the local config supplies it (`local_input_in_specification`)"); continue }
        okey = observed_by(D, s[4])
        if (okey != "") { fail(F, n_line[i], named(path) "passes the input `" s[4] "`, which `" a "` takes from the key `" okey "` of the plan'"'"'s `observation` (`observation_inputs`); the plan writes the value once, under `observation`"); continue }
        dt = text(D, dp SEP "type"); dl = (text(D, dp SEP "list") == "true")
        x = n_text[i]
        if (n_kind[i] != "map" && n_kind[i] != "list" && (index(x, "${") > 0 || index(x, "{inputs.") > 0)) {
          ip = "preset" SEP "inputs" SEP input_name(x)
          if (x !~ REF || !has(F, ip)) continue
          it = text(F, ip SEP "type"); il = (text(F, ip SEP "list") == "true")
          if (il != dl || !(it == dt || (it == "integer" && dt == "decimal")))
            fail(F, n_line[i], named(path) "passes the input `" input_name(x) "` of the preset, " typed(it, il) ", and `" a "` declares the input `" s[4] "` as " typed(dt, dl))
        } else {
          m = unfit(F, path, dt, dl, 1)
          if (m != "") fail(F, n_line[i], named(path) m ", and `" a "` declares the input `" s[4] "` as " typed(dt, dl))
          # A literal is one of the values that the declaration lists for the input.
          else if (dt == "string" && has(D, dp SEP "values") && (v = outside(F, path, D, dp SEP "values", 1)) != "")
            fail(F, n_line[i], named(path) (dl ? "holds the item `" : "is `") v "`, which is none of the values `" items(D, dp SEP "values") "` that `" a "` declares for the input `" s[4] "`")
        }
      }

      if (n == 4 && s[1] == "assessments" && s[3] == "measurements") {
        id = stated[F] "/" s[2] "/" s[4]
        ms[++nm] = id; ms_file[nm] = F; ms_line[nm] = n_line[i]; ms_preset[nm] = stated[F]
        is_measurement[id] = 1
        # Sampled evidence qualifies under declared conditions (docs/design.md § 3,
        # "Measurement kind and observation conditions"). A window over the runs of another
        # plan declares none: only runs that qualified under the source plan enter it.
        # Conditions that an input of the type `conditions` gives are passed by the binding,
        # and not read.
        plan = "assessments" SEP s[2]
        if (text(F, path SEP "kind") == "sampled" && !has(F, plan SEP "observation" SEP "population" SEP "runs_of") && conditions_of(F, plan) == 0 && !given(text(F, plan SEP "observation" SEP "conditions")))
          fail(F, n_line[i], named(path) "is sampled, and the plan `" s[2] "` declares no condition under `observation.conditions`: sampled evidence qualifies under declared conditions")
        # A sampled measurement of a plan with more than one run states an aggregation, or
        # `over_all_runs: true`, a value the assessor computes over all runs of the plan, which
        # is no aggregation: a measurement states one of the two (docs/design.md § 3, "One run
        # per candidate is valid"). A `runs` and an `over_all_runs` that an input gives are not
        # read.
        rn = text(F, plan SEP "observation" SEP "runs")
        ov = text(F, path SEP "over_all_runs"); oar = (ov == "true")
        if (text(F, path SEP "kind") == "sampled" && rn ~ /^[0-9]+$/ && rn + 0 > 1 && !has(F, path SEP "aggregation") && !oar && !given(ov))
          fail(F, n_line[i], named(path) "is sampled, and the plan `" s[2] "` has `runs: " rn "` and the measurement states neither an `aggregation` nor `over_all_runs: true`, the value its assessor computes over all runs of the plan")
        if (oar && has(F, path SEP "aggregation"))
          fail(F, n_line[i], named(path) "states `over_all_runs: true` and an `aggregation`; a value the assessor computes over all runs of the plan is no aggregation, and a measurement states one of the two")
        # An exact measurement aggregates with `sum` or not at all (docs/design.md § 3, the
        # table of the two kinds: "None, or a sum within the declared scope").
        ek = text(F, path SEP "kind"); ea = text(F, path SEP "aggregation" SEP "kind")
        if (ek == "exact" && has(F, path SEP "aggregation" SEP "kind") && !given(ea) && ea != "sum")
          fail(F, n_line[i], named(path) "is exact and aggregates with `" ea "`; an exact measurement aggregates with `sum` or not at all")
        op = output_of(F, path)
        # Nothing is joined without a declaration (`record-series@1`, an assessor that an
        # input gives, an assessor that is named as absent) and where an input gives the output.
        if (D == "" || !has(F, path SEP "output") || given(O)) continue
        # A count of the coverage of the run, `coverage.<count>`, is an output of Ratchet itself:
        # a count the declaration lists under `coverage`, read as an exact number at the scope
        # `run` without a unit (docs/design.md § 3 "Evidence coverage").
        if (op == "" && CC != "") {
          what = "the coverage count `" O "`"
          if (!(("ratchet.assessor.CoverageCount", CC) in variant)) {
            fail(F, n_line[i], named(path) "names the output `" O "`, and `" CC "` is no count of the coverage: `coverage.<count>` takes one of " variants("ratchet.assessor.CoverageCount")); continue
          }
          if (!counted) {
            fail(F, n_line[i], named(path) "names the output `" O "`, and `" A "` lists the counts `" items(D, "coverage") "` under `coverage`, not `" CC "`"); continue
          }
          mk = text(F, path SEP "kind")
          if (has(F, path SEP "kind") && !given(mk) && mk != "exact")
            fail(F, n_line[i], named(path) "has the kind `" mk "`, and " what " is `exact` (`kind_mismatch`)")
          mu = text(F, path SEP "unit")
          if (has(F, path SEP "unit") && !given(mu))
            fail(F, n_line[i], named(path) "states the unit `" mu "`, and " what " has none (`unit_not_declared`)")
          sc = text(F, path SEP "scope")
          if (has(F, path SEP "scope") && sc != "run" && !given(sc))
            fail(F, n_line[i], named(path) "has the scope `" sc "`, and " what " has the scope `run` alone")
          continue
        }
        if (op == "") { fail(F, n_line[i], named(path) "names the output `" O "`, which `" A "` does not declare"); continue }
        what = "the output `" O "` of `" A "`"
        vt = text(D, op SEP "value_type")
        ak = text(F, path SEP "aggregation" SEP "kind")
        if (ak == "pass_rate" && vt != "assertion")
          fail(F, n_line[i], named(path) "aggregates with `pass_rate`, which takes an assertion, and " what " has the value type `" vt "`")
        # The pass rate of an assertion is a number over runs or samples: it may be `sampled`
        # where the assertion is declared `exact`.
        rate = (vt == "assertion" && (ak == "pass_rate" || given(ak)))
        mk = text(F, path SEP "kind"); dk = text(D, op SEP "kind")
        if (has(F, path SEP "kind") && !given(mk) && mk != dk && !(rate && mk == "sampled"))
          fail(F, n_line[i], named(path) "has the kind `" mk "`, and " what " declares `" dk "` (`kind_mismatch`)")
        has_du = has(D, op SEP "unit"); du = text(D, op SEP "unit")
        has_mu = has(F, path SEP "unit"); mu = text(F, path SEP "unit")
        if (!(has_mu && given(mu))) {
          if (has_du && !has_mu) fail(F, n_line[i], named(path) "has no `unit`, and " what " declares `" du "` (`unit_missing`)")
          else if (has_du && mu != du) fail(F, n_line[i], named(path) "states the unit `" mu "`, and " what " declares `" du "` (`unit_mismatch`)")
          else if (!has_du && has_mu) fail(F, n_line[i], named(path) "states the unit `" mu "`, and " what " declares none (`unit_not_declared`)")
        }
        sc = text(F, path SEP "scope")
        if (has(F, path SEP "scope") && sc != "run" && !given(sc) && !holds(D, op SEP "scopes", sc))
          fail(F, n_line[i], named(path) "has the scope `" sc "`, which " what " does not declare")
        # `run_time` and `queue_wait` are boundaries of Ratchet itself (docs/design.md § 3,
        # value lists): an output that declares no boundaries has them, as every output has
        # the scope `run`. An output that declares boundaries has those it lists.
        bd = text(F, path SEP "boundary")
        if (has(F, path SEP "boundary") && !given(bd) && !holds(D, op SEP "boundaries", bd) && !((bd == "run_time" || bd == "queue_wait") && !has(D, op SEP "boundaries")))
          fail(F, n_line[i], named(path) "has the boundary `" bd "`, which " what " does not declare")
        if (has(F, path SEP "identity") && !list_given(F, path SEP "identity")) {
          mi = items(F, path SEP "identity"); di = items(D, op SEP "identity_key")
          if (!has(D, op SEP "identity_key")) fail(F, n_line[i], named(path) "states an identity key, and " what " declares none")
          else if (mi != di) fail(F, n_line[i], named(path) "states the identity key `" mi "`, and " what " declares `" di "`")
        }
      }

      if (n == 6 && s[1] == "assessments" && s[3] == "measurements" && s[5] == "filter") {
        op = output_of(F, "assessments" SEP s[2] SEP "measurements" SEP s[4])
        if (op == "") continue
        if (!holds(D, op SEP "item_fields", s[6]))
          fail(F, n_line[i], named(path) "filters by the field `" s[6] "`, which the output `" O "` of `" A "` does not declare for its items")
        # A field whose values the output lists under `item_values` is filtered by those
        # values; a field without such a list is open (docs/evidence-format.md § 10).
        if (holds(D, op SEP "item_fields", s[6]) && has(D, op SEP "item_values" SEP s[6]))
          for (j = 1; has(F, path SEP "[" j "]"); j++) {
            fv = text(F, path SEP "[" j "]")
            if (!given(fv) && !holds(D, op SEP "item_values" SEP s[6], fv))
              fail(F, n_line[i], named(path) "filters the field `" s[6] "` by the value `" fv "`, which is none of the values `" items(D, op SEP "item_values" SEP s[6]) "` that the output `" O "` of `" A "` declares for it")
          }
      }

      # A condition of the observation, under its class: one of the seven that have a field
      # in ratchet.specification.ObservationConditions (`host_load_per_cpu`, `tools`,
      # `runner`, `cpu_model`, `memory`, `accelerator`, `build_profile`), or one the
      # declaration lists. The cache condition is `cache_profile` and never `cache`, also
      # where a declaration lists it.
      if (n == 6 && s[1] == "assessments" && s[3] == "observation" && s[4] == "conditions") {
        a = text(F, "assessments" SEP s[2] SEP "assessor")
        if (s[6] == "cache")
          fail(F, n_line[i], named(path) "is the condition `cache`; a plan writes the cache condition as `cache_profile` and under no other name")
        else if ((a in declaration) && !(("ratchet.specification.ObservationConditions", s[6]) in ftype) && !holds(declaration[a], "conditions", s[6]))
          fail(F, n_line[i], named(path) "is the condition `" s[6] "`, which is none of Ratchet itself, and `" a "` declares the conditions `" items(declaration[a], "conditions") "`")
      }

      # A field of a population filter is one the declaration lists.
      if (n == 6 && s[1] == "assessments" && s[3] == "observation" && s[4] == "population" && s[5] == "filter") {
        a = text(F, "assessments" SEP s[2] SEP "assessor")
        if ((a in declaration) && !holds(declaration[a], "population_fields", s[6]))
          fail(F, n_line[i], named(path) "filters the population by the field `" s[6] "`, and `" a "` declares the population fields `" items(declaration[a], "population_fields") "` (`population_field_mismatch`)")
      }

      if (n == 2 && s[1] == "requirements") {
        # A name that is a reference is refused where it stands (`inner_name`).
        ra = text(F, path SEP "assessment")
        if (has(F, path SEP "assessment") && !given(ra)) {
          if (!has(F, "assessments" SEP ra)) fail(F, n_line[i], named(path) "names the assessment `" ra "`, which the preset does not hold")
          else if (has(F, path SEP "measurement")) {
            rm = text(F, path SEP "measurement")
            if (!given(rm) && !has(F, "assessments" SEP ra SEP "measurements" SEP rm)) fail(F, n_line[i], named(path) "names the measurement `" rm "`, which the assessment `" ra "` does not hold")
          } else if (nkeys[F, "assessments" SEP ra SEP "measurements"] != 1)
            fail(F, n_line[i], named(path) "names no measurement, and the assessment `" ra "` holds " (nkeys[F, "assessments" SEP ra SEP "measurements"] + 0))
        }
        for (j = 1; has(F, path SEP "serves" SEP "[" j "]"); j++) {
          st = text(F, path SEP "serves" SEP "[" j "]")
          if (!given(st) && !has(F, "statements" SEP st)) fail(F, n_line[i], named(path) "serves the statement `" st "`, which the preset does not hold")
        }

        # The comparison against the value type of the output (docs/design.md § 3
        # "Comparisons").
        mp = compared(F, path)
        if (mp == "") continue
        # A sampled measurement that is compared with an accepted value: the reference has a
        # band and says where its value is adopted from (docs/design.md § 3 "Comparisons" and
        # § 5 "Ratchet policy"). Read without a declaration, so also on a window over runs.
        if (text(F, mp SEP "kind") == "sampled" && text(F, path SEP "reference" SEP "kind") == "accepted_value") {
          tp = path SEP "reference" SEP "tolerance"
          if (!has(F, tp SEP "percent") && !has(F, tp SEP "absolute"))
            fail(F, n_line[i], named(path) "compares the sampled measurement `" last(mp) "` with an accepted value and has no tolerance, a `reference.tolerance` with `percent` or `absolute`: Ratchet ships no default band")
          if (!has(F, path SEP "reference" SEP "adoption"))
            fail(F, n_line[i], named(path) "compares the sampled measurement `" last(mp) "` with an accepted value and has no `reference.adoption`, which says from which runs the value is adopted")
        }
        # An adoption from another assessment (docs/design.md § 5 "The ratchet policy"): it
        # names the assessment and the measurement, and the two stand on `from: assessment`
        # alone. The measurement it names is read below, once the output is known.
        adp = path SEP "reference" SEP "adoption"
        afrom = text(F, adp SEP "from")
        adopted = (afrom == "assessment")
        if (has(F, adp) && afrom != "" && !given(afrom) && !adopted) {
          if (has(F, adp SEP "assessment")) fail(F, n_line[i], named(path) "has an adoption with `assessment`, and `from: " afrom "`: `assessment` and `measurement` stand on `from: assessment` alone")
          if (has(F, adp SEP "measurement")) fail(F, n_line[i], named(path) "has an adoption with `measurement`, and `from: " afrom "`: `assessment` and `measurement` stand on `from: assessment` alone")
        }
        if (adopted && !has(F, adp SEP "assessment")) { fail(F, n_line[i], named(path) "has an adoption `from: assessment` and names no `assessment`"); adopted = 0 }
        if (adopted && !has(F, adp SEP "measurement")) { fail(F, n_line[i], named(path) "has an adoption `from: assessment` and names no `measurement`"); adopted = 0 }
        op = output_of(F, mp)
        if (op == "" && !counted) continue
        # A coverage count is a number without a unit.
        vt = counted ? "number" : text(D, op SEP "value_type")
        what = counted ? "the coverage count `" O "` of `" A "`" : "the output `" O "` of `" A "`"
        is = what " has the value type `" vt "`"
        # An assertion that the measurement aggregates with `pass_rate` is compared as a
        # number (docs/design.md § 3, "A series of runs as a population"). Where an input
        # gives the kind of the aggregation, it is not known which of the two it is.
        ak = text(F, mp SEP "aggregation" SEP "kind")
        if (vt == "assertion" && given(ak)) continue
        if (vt == "assertion" && ak == "pass_rate") { vt = "number"; is = what " is an assertion that the measurement aggregates with `pass_rate`, a number" }
        hc = has(F, path SEP "condition"); hr = has(F, path SEP "reference")
        opr = text(F, path SEP "condition" SEP "operator")
        rk = text(F, path SEP "reference" SEP "kind")
        hv = has(F, path SEP "condition" SEP "value")
        hd = has(F, path SEP "condition" SEP "digest")
        hmin = has(F, path SEP "condition" SEP "min"); hmax = has(F, path SEP "condition" SEP "max")
        ha = has(F, path SEP "condition" SEP "against")
        if (hc && vt == "digest") {
          if (hv) fail(F, n_line[i], named(path) "has a `value`, and " is ", which is compared with a `digest` and takes no `value`")
          if (opr != "" && !given(opr) && opr != "eq") fail(F, n_line[i], named(path) "has the operator `" opr "`, and " is ", which takes `eq` with a `digest`")
          if (!hd) fail(F, n_line[i], named(path) "has a condition without a `digest`, and " is ", which takes `eq` with a `digest`")
        } else if (hc && opr != "" && !given(opr)) {
          limit = (opr ~ /^(lt|lte|gt|gte|eq)$/)
          range = (opr == "within")
          if (opr == "holds") {
            if (vt != "assertion") fail(F, n_line[i], named(path) "has the operator `holds`, which takes an assertion, and " is)
          } else if (opr == "no_new_items" || opr == "no_lost_items") {
            if (vt != "identity_set") fail(F, n_line[i], named(path) "has the operator `" opr "`, which takes an identity set, and " is)
            else if (rk != "accepted_value") fail(F, n_line[i], named(path) "has the operator `" opr "` and no reference of the kind `accepted_value`, the set it compares with")
          } else if (opr == "subset_of") {
            if (vt != "identity_set") fail(F, n_line[i], named(path) "has the operator `subset_of`, which takes an identity set, and " is)
            if (!ha) fail(F, n_line[i], named(path) "has the operator `subset_of` and no `against`, the set it is compared with")
          } else if ((limit || range) && vt != "number" && vt != "identity_set")
            fail(F, n_line[i], named(path) "has the operator `" opr "`, which takes a number or the number of items of a set, and " is)
          if (limit && !hv && !ha) fail(F, n_line[i], named(path) "has the operator `" opr "` and no `value`, the limit")
          if (!limit && !range && hv) fail(F, n_line[i], named(path) "has the operator `" opr "`, which takes no `value`")
          if (range) {
            mn = text(F, path SEP "condition" SEP "min"); mx = text(F, path SEP "condition" SEP "max")
            if (hv) fail(F, n_line[i], named(path) "has the operator `within`, which takes `min` and `max` and no `value`")
            if (!hmin) fail(F, n_line[i], named(path) "has the operator `within` and no `min`, its lower bound")
            if (!hmax) fail(F, n_line[i], named(path) "has the operator `within` and no `max`, its upper bound")
            if (hmin && hmax && !given(mn) && !given(mx) && mn + 0 > mx + 0)
              fail(F, n_line[i], named(path) "has the operator `within` with the `min` " mn " above the `max` " mx)
          }
        }
        if (hc && opr != "" && !given(opr) && opr != "within") {
          if (hmin) fail(F, n_line[i], named(path) "has a `min`, and the operator `" opr "`: `min` and `max` stand on `within` alone")
          if (hmax) fail(F, n_line[i], named(path) "has a `max`, and the operator `" opr "`: `min` and `max` stand on `within` alone")
        }
        if (hd && vt != "digest") fail(F, n_line[i], named(path) "has a condition with a `digest`, and " is ", which takes no `digest`")
        if (hc) {
          has_du = has(D, op SEP "unit"); du = text(D, op SEP "unit")
          has_cu = has(F, path SEP "condition" SEP "unit"); cu = text(F, path SEP "condition" SEP "unit")
          if (!(has_cu && given(cu))) {
            if (has_du && !has_cu) fail(F, n_line[i], named(path) "has a condition without a `unit`, and " what " declares `" du "` (`unit_missing`)")
            else if (has_du && cu != du) fail(F, n_line[i], named(path) "has a condition in the unit `" cu "`, and " what " declares `" du "` (`unit_mismatch`)")
            else if (!has_du && has_cu) fail(F, n_line[i], named(path) "has a condition in the unit `" cu "`, and " what " declares none (`unit_not_declared`)")
          }
        }
        if (hr) {
          # The kind of the reference is read where no input gives it.
          if (rk != "" && !given(rk)) {
            if (vt == "assertion") fail(F, n_line[i], named(path) "has a reference, and " is ", which takes none")
            else if (vt == "digest" && rk != "generated") fail(F, n_line[i], named(path) "has the reference `" rk "`, and " is ", which takes `generated`")
            else if ((vt == "number" || vt == "identity_set") && rk != "accepted_value") fail(F, n_line[i], named(path) "has the reference `" rk "`, and " is ", which takes `accepted_value`")
          }
          # These two read that there is a reference, and not its kind.
          if (vt == "identity_set" && !hc) fail(F, n_line[i], named(path) "compares a set with a reference and has no condition: `no_new_items` or `no_lost_items` says which way is worse")
          if (vt == "number" && !has(F, mp SEP "better")) fail(F, n_line[at[F, mp]], "`" shown(mp) "` states no `better`, and `" shown(path) "` compares it with a reference")
        }
        # The measurement an adoption from another assessment names: a measurement of an
        # assessment of the preset, whose output has the value type and the unit of this one.
        # It reads a second declaration, so the unit of this output is kept first.
        if (adopted) {
          aa = text(F, adp SEP "assessment")
          am = text(F, adp SEP "measurement")
          has_ru = (op != "" && has(D, op SEP "unit")); ru = has_ru ? text(D, op SEP "unit") : ""
          if (given(aa) || given(am)) {
          } else if (!has(F, "assessments" SEP aa)) {
            fail(F, n_line[i], named(path) "adopts from the assessment `" aa "`, which the preset does not hold")
          } else if ((dmp = compared(F, adp)) == "") {
            fail(F, n_line[i], named(path) "adopts from the measurement `" am "`, which the assessment `" aa "` does not hold")
          } else if ((dop = output_of(F, dmp)) != "" || counted) {
            dvt = counted ? "number" : text(D, dop SEP "value_type")
            if (dvt == "assertion" && text(F, dmp SEP "aggregation" SEP "kind") == "pass_rate") dvt = "number"
            has_au = (dop != "" && has(D, dop SEP "unit")); au = has_au ? text(D, dop SEP "unit") : ""
            if (dvt != vt)
              fail(F, n_line[i], named(path) "adopts from `" shown(dmp) "` of the value type `" dvt "`, and " is)
            else if (has_au != has_ru || au != ru)
              fail(F, n_line[i], named(path) "adopts from `" shown(dmp) "` in the unit `" (has_au ? au : "none") "`, and " what " declares `" (has_ru ? ru : "none") "`")
          }
        }
        # A comparison with another measurement of the preset: `against` names an assessment
        # of the preset and a measurement of it, whose output has the value type of this one
        # and, for a number, its unit. Last, because it reads a second declaration.
        if (ha) {
          ap = path SEP "condition" SEP "against"
          aa = text(F, ap SEP "assessment")
          if (given(aa)) continue
          if (!has(F, "assessments" SEP aa)) {
            fail(F, n_line[i], named(path) "has `against` the assessment `" aa "`, which the preset does not hold"); continue
          }
          amp = compared(F, ap)
          if (amp == "") {
            if (!has(F, ap SEP "measurement"))
              fail(F, n_line[i], named(path) "has `against` the assessment `" aa "` and names no measurement of it, and the assessment holds " (nkeys[F, "assessments" SEP aa SEP "measurements"] + 0))
            else if (!given(text(F, ap SEP "measurement")))
              fail(F, n_line[i], named(path) "has `against` the measurement `" text(F, ap SEP "measurement") "`, which the assessment `" aa "` does not hold")
            continue
          }
          aop = output_of(F, amp)
          if (aop == "" && !counted) continue
          avt = counted ? "number" : text(D, aop SEP "value_type")
          if (avt == "assertion" && text(F, amp SEP "aggregation" SEP "kind") == "pass_rate") avt = "number"
          if (avt != vt) {
            fail(F, n_line[i], named(path) "has `against` `" shown(amp) "` of the value type `" avt "`, and " is " (`against_value_type_mismatch`)"); continue
          }
          if (vt == "number" && (has(D, aop SEP "unit") != has_du || text(D, aop SEP "unit") != du))
            fail(F, n_line[i], named(path) "has `against` `" shown(amp) "` in the unit `" (has(D, aop SEP "unit") ? text(D, aop SEP "unit") : "none") "`, and " what " declares `" (has_du ? du : "none") "` (`against_unit_mismatch`)")
        }
      }
    }

    # A row per measurement, and a measurement per row.
    for (i = 1; i <= nm; i++) {
      id = ms[i]
      if (row_count[id] == 0) { fail(ms_file[i], ms_line[i], "the measurement `" id "` has no row on a page of the directory"); continue }
      if (row_count[id] > 1) { fail(row_page[id], 1, "the measurement `" id "` has " row_count[id] " rows; it has one"); continue }
      if (ms_preset[i] in preset_page) {
        if (preset_page[ms_preset[i]] != row_page[id]) { fail(row_page[id], 1, "the row `" id "` stands on another page than the rows of its preset, " short(preset_page[ms_preset[i]])); continue }
      } else preset_page[ms_preset[i]] = row_page[id]
      if (row_filled[id] == 1) with_row++
    }
    for (i = 1; i <= nr; i++)
      if (!(rw[i] in is_measurement)) fail(rw_file[i], rw_line[i], "the row `" rw[i] "` names no measurement of a preset of the directory")
    for (i = 1; i <= np; i++) {
      if (tables[pg[i]] == 0) fail(pg[i], 1, "the page holds no table with the header `" HEADER "`; every `*.md` beside README.md is the page of a family")
      else if (rows_in[pg[i]] == 0) fail(pg[i], 1, "the tables of the page hold no row")
    }

    # A line ends with a line feed, the last one too. awk reads a last line without one as a
    # line, so it has then read more lines than the files have line feeds. `feeds` counts
    # those of every `*.yaml` and `*.md`, and these are the files awk read where no entry is
    # refused. Only then the last byte of each file is looked at.
    if (nothers == 0 && nlines != feeds + 0) {
      for (i = 1; i <= nread; i++) {
        look = "tail -c 1 " shell_word(read_file[i]) " | wc -l"
        ends = ""
        look | getline ends
        close(look)
        if (ends + 0 == 0) fail(read_file[i], last_line[read_file[i]], "the last line does not end with a line feed; a line ends with a line feed")
      }
    }

    total = ny + np + nothers
    failed += nothers
    good = ny + np
    for (y = 1; y <= ny; y++) if (yf[y] in bad) good--
    for (i = 1; i <= np; i++) if (pg[i] in bad) good--
    if (failed > 0) {
      printf "presets: %d of %d file(s) valid, %d of %d measurement(s) with a row, %d failure(s)\n", good, total, with_row, nm, failed
      exit 1
    }
    printf "presets: %d of %d file(s) valid, %d of %d measurement(s) with a row\n", total, total, nm, nm
  }
  ' "$@"
}

if [ "$copies" -eq 0 ]; then
  if [ ! -d "$catalog" ]; then
    echo "presets: $catalog is no directory; the catalog is the directory presets/ of the repository"
    exit 1
  fi
  spec_ok || exit 1
  catalog=$(CDPATH= cd -- "$catalog" && pwd)
  tables "$spec" | check_catalog "$catalog" -
  exit $?
fi

rm -rf "$work"
mkdir -p "$work"

spec_ok || exit 1
tables "$spec" > "$work/tables"
if check_catalog "$catalog" "$work/tables" > "$work/catalog.out" 2>&1; then :; else
  cat "$work/catalog.out"
  exit 1
fi
summary=$(tail -n 1 "$work/catalog.out")

# ---- one defect per rule, in copies of a set of files of presets/ ------------------------------
#
# Each case is one defect in a copy of the set (`set_files` below), the directory
# target/presets/<case> of the case that starts the copy. The case holds when the check of the
# copy exits non-zero and names the defect with the words of its rule, so a case fails when
# its rule is taken out of the check, also where another rule refuses the copy then. A rule
# without a case here is not guarded: a new rule gets its case.
#
# `copy` starts a case in a fresh copy. `again` starts a case in the copy of the case before
# it: that copy then holds the defect of each of its cases, each on a line of its own, and is
# checked once, when the next copy starts. A case that shares a copy states a message that no
# other defect of the copy gives: it names the line, the path or the value of its own defect.
# The check takes most of the time of this script, so the cases of one group share a copy
# where their defects stand apart.

stop() {
  echo "presets: $1"
  exit 1
}

# The files that the cases edit. A case names a file by its variable.
conf='conformance-cases@1.preset.yaml'
conf_d='conformance-report@1.assessor.yaml'
differ='differential-equality@1.preset.yaml'
differ_d='comparison-report@1.assessor.yaml'
known='known-failures@1.preset.yaml'
known_d='case-list@1.assessor.yaml'
page='functional.md'
# The second version of the comparison: no case edits it, and its rows stand on the page.
differ2='differential-equality@2.preset.yaml'
differ2_d='comparison-report@2.assessor.yaml'
# The second version of the list of known failures and the declaration it names: no case edits
# them, and the rows of the preset stand on the page.
known2='known-failures@2.preset.yaml'
conf2_d='conformance-report@2.assessor.yaml'
# The third version of the comparison, which adopts from another plan: no case edits it, its
# rows stand on the page, and the two declarations it names are in the set.
differ3='differential-equality@3.preset.yaml'

# The set: the files a copy holds. They are `README.md`, which every directory of the catalog
# holds, and the functional family: its presets, the declarations they name and its page. A
# copy holds no file of another family, so a family that the catalog gets adds its files to the
# one check of presets/ above and to no copy. The set is a directory of its own,
# target/presets/set, which is valid alone: the case `harness-unchanged` below fails where it
# is not. A file of the set that presets/ does not hold stops the run.
set_files="README.md $page $conf $conf_d $differ $differ_d $differ2 $differ2_d $differ3 $known $known_d $known2 $conf2_d"
set_dir=$work/set
mkdir "$set_dir"
for set_file in $set_files; do
  [ -f "$catalog/$set_file" ] || stop "presets/ holds no $set_file, a file of the set that every copy of this script holds ($set_files)"
  cp "$catalog/$set_file" "$set_dir/$set_file"
done

# copy <case>: a fresh copy of the set as the directory $c; sets $c and $name. What a case
# writes beside its copy is named $c.<word>. The copy is checked against the specification of
# the repository until `own_spec` gives it one of its own. The cases of the copy before it are
# judged first.
copy() {
  judge_cases
  name=$1
  c=$work/$1
  cp -R "$set_dir" "$c"
  case_tables=$work/tables
}

# again <case>: a further case in the copy of the case before it; sets $name.
again() {
  name=$1
}

# own_spec: the copy gets its own copy of spec/domains, $c.domains, for `edit_spec`.
own_spec() {
  cp -R "$root/spec/domains" "$c.domains"
  case_tables=
}

# An edit that changes nothing stops the run: its case would test the unchanged set.
nothing() {
  echo "presets: the edit of the case $name changes nothing in $1" >&2
  exit 1
}

# An edit of a file that the copy does not hold stops the run: a copy holds the set and what
# its case wrote, and no file of another family.
holds() {
  [ -f "$c/$1" ] && return 0
  echo "presets: the case $name edits $1, and its copy holds no $1: a copy holds the set ($set_files) and what its case wrote" >&2
  exit 1
}

# edit <file of the copy> <awk program>
edit() {
  holds "$1"
  awk "$2" "$c/$1" > "$c.new"
  if cmp -s "$c/$1" "$c.new"; then nothing "$1"; fi
  mv "$c.new" "$c/$1"
}

# edit_spec <domain file of the copy> <awk program>
edit_spec() {
  awk "$2" "$c.domains/$1" > "$c.new"
  if cmp -s "$c.domains/$1" "$c.new"; then nothing "$1"; fi
  mv "$c.new" "$c.domains/$1"
}

# swap <file of the copy> <line> <text> [<n>]: the n-th line that is <line>, the first
# without <n>, becomes <text>. awk reads the escapes of <text>: `\n` starts a further line.
swap() {
  holds "$1"
  awk -v old="$2" -v new="$3" -v nth="${4:-1}" '
    ($0 "") == (old "") && ++seen == nth { print new; swapped = ((new "") != (old "")); next }
    { print }
    END { exit !swapped }' "$c/$1" > "$c.new" || nothing "$1"
  mv "$c.new" "$c/$1"
}

# drop <file of the copy> <line> [<n>]: the n-th line that is <line> is taken out.
drop() {
  holds "$1"
  awk -v old="$2" -v nth="${3:-1}" '
    ($0 "") == (old "") && ++seen == nth { dropped = 1; next }
    { print }
    END { exit !dropped }' "$c/$1" > "$c.new" || nothing "$1"
  mv "$c.new" "$c/$1"
}

# check_copy: the check of the copy, once: its output is $c.out, its exit status $checked.
check_copy() {
  if [ -z "$case_tables" ]; then
    tables "$c.domains" > "$c.tables"
    case_tables=$c.tables
  fi
  if check_catalog "$c" "$case_tables" > "$c.out" 2>&1; then checked=0; else checked=1; fi
}

# judge <message>: sets $verdict from the check of the copy: `accepted`, `refused` with the
# message in the output of the check, or `other` for a refusal without it.
judge() {
  if [ "$checked" -eq 0 ]; then
    verdict=accepted
  elif grep -F -q -e "$1" "$c.out"; then
    verdict=refused
  else
    verdict=other
  fi
}

# verdict <message>: checks the copy and sets $verdict.
verdict() {
  check_copy
  judge "$1"
}

# The counts: `cases` are the defects, `accepted` those of them that were accepted or refused
# without the message of their rule; `broken` are the copies that hold a defect, `kept` those of
# them with such a case.
cases=0
accepted=0
broken=0
kept=0
# The cases of the copy that wait for its check: a line a case, with the name, what the copy
# holds and the message of the rule, between tabs.
tab=$(printf '\t')
waiting=$work/waiting
: > "$waiting"

# refused <the message of the rule> <what the copy holds>: the case waits for the check of its
# copy, which `judge_cases` runs.
refused() {
  cases=$((cases + 1))
  printf '%s\t%s\t%s\n' "$name" "$2" "$1" >> "$waiting"
}

# judge_cases: checks the copy once and judges every case that waits for it. The copy counts
# as refused when each of its cases is refused with the message of its rule.
judge_cases() {
  [ -s "$waiting" ] || return 0
  check_copy
  broken=$((broken + 1))
  before=$accepted
  while IFS="$tab" read -r case_name case_holds case_message; do
    judge "$case_message"
    case $verdict in
      refused) ;;
      accepted)
        accepted=$((accepted + 1))
        echo "accepted: $case_name: $case_holds"
        echo "  $(tail -n 1 "$c.out")" ;;
      *)
        accepted=$((accepted + 1))
        echo "refused without the message of its rule: $case_name: $case_holds"
        echo "  wanted: $case_message"
        sed 's/^/  /' "$c.out" ;;
    esac
  done < "$waiting"
  [ "$accepted" -eq "$before" ] || kept=$((kept + 1))
  : > "$waiting"
}

# accepts <what the copy holds>: a copy with forms that are valid; a refusal stops the run.
accepts() {
  verdict 'presets:'
  if [ "$verdict" != accepted ]; then
    echo "presets: refused, and it is valid: $name: $1"
    sed 's/^/  /' "$c.out"
    exit 1
  fi
}

# result: the line of the defects and the last line; fails when a defect was accepted or was
# refused without the message of its rule.
result() {
  judge_cases
  if [ "$accepted" -gt 0 ]; then
    echo "presets: $((cases - accepted)) of $cases defect(s) refused with the message of their rule, $accepted not"
    echo "$summary, $((broken - kept)) of $broken broken copies refused, $kept accepted"
    return 1
  fi
  echo "presets: $cases of $cases defect(s) refused with the message of their rule"
  echo "$summary, $broken of $broken broken copies refused"
}

# Lines of the set that many cases change.
meaning='    meaning: Every case of the accepted set of passing cases still passes.'
meaning_passed='    meaning: The number of passed cases is not below the accepted number.'
meaning_failed='    meaning: The number of failed cases is not above the accepted number.'
meaning_skipped='    meaning: The number of skipped cases is not above the accepted number.'
meaning_refused='    meaning: The number of refused cases is not above the accepted number.'
passes='      report: ${inputs.report}'
set_rule='    condition: {operator: no_lost_items}'
accepted_value='    reference: {kind: accepted_value}'
of_failed='    measurement: failed'
limit='      value: ${inputs.different_limit}'
number_output='  failed: {value_type: number, kind: exact, scopes: [], unit: cases}'
the_row='index($0, "| `conformance-cases@1/conformance/skipped` |") == 1'
table='| Measurement | Direction | Unit | Tolerance | Evidence |\n| --- | --- | --- | --- | --- |\n'

# add_row <row>: a further table at the end of the page of the copy, with the row.
add_row() {
  printf '\n'"$table"'%s\n' "$1" >> "$c/$page"
}

# cell <n> <text>: the cell <n> of the row of the measurement `skipped` becomes <text>; cell 1
# is the name.
cell() {
  edit "$page" "$the_row"' { n = split($0, cell, /\|/); cell['"$(($1 + 1))"'] = "'"$2"'"; printf "|%s|%s|%s|%s|%s|\n", cell[2], cell[3], cell[4], cell[5], cell[6]; next } { print }'
}

# The eleven lines of `meaning` of the presets, as <file>:<line>.
meanings="$conf:56 $conf:62 $conf:67 $conf:72 $conf:77 $differ:46 $differ:52 $differ:58 $differ:64 $known:38 $known:44"

# meaning_bytes <n> <bytes, as awk writes them>: the n-th of those lines of the copy becomes a
# text with the bytes; sets $at to its <file>:<line>. A line that is no line of `meaning`
# stays, and the edit that changes nothing stops the run.
meaning_bytes() {
  bytes=$2
  set -- $(($1 - 1)) $meanings
  shift "$(($1 + 1))"
  at=$1
  edit "${at%:*}" 'NR == '"${at##*:}"' && /^    meaning: / { print "    meaning: Every case '"$bytes"' still passes."; next } { print }'
}

# add_window: the preset known-failures@1 of the copy gets a second plan, a window over the
# runs of the first, as docs/design.md § 3 writes `pool-queue-wait`; with its requirement and
# its row.
window_plan='  size-over-runs:\n    subject: ${inputs.subject}\n    assessor: record-series@1\n    target: {kind: revision, environments: "${inputs.environments}"}\n    observation:\n      kind: time_window\n      window: {last: 20}\n      population: {runs_of: known-failures, from: trusted_revision}\n      min_samples: 10\n    measurements:\n      median:\n        kind: sampled\n        output: size\n        scope: run\n        aggregation: {kind: median}\n        unit: cases\n        better: lower\n\nrequirements:'
add_window() {
  swap "$known" 'requirements:' "$window_plan"
  printf '  median-size-does-not-rise:\n    meaning: The median size of the list over the last 20 runs is not above the accepted median.\n    assessment: size-over-runs\n    reference:\n      kind: accepted_value\n      tolerance: {percent: 10}\n      adoption: {from: trusted_revision, runs: 4, aggregation: {kind: median}}\n' >> "$c/$known"
  add_row '| `known-failures@1/size-over-runs/median` | Lower | `cases` | 10 percent | `record-series@1`, the measurement `size` of the plan `known-failures` |'
}

# window_copy <case>: a copy with that plan.
window_copy() {
  copy "$1"
  add_window
}

# add_rate: the preset conformance-cases@1 of the copy reads the pass rate of an assertion
# that conformance-report@1 declares; with its requirement and its row. It writes to the end of
# the declaration, which is the map `outputs` until a case writes there. The measurement is
# sampled, so the plan gets a condition and the reference a tolerance and an adoption.
add_rate() {
  printf '  all_pass: {value_type: assertion, kind: exact, scopes: []}\n' >> "$c/$conf_d"
  swap "$conf" '      kind: snapshot' '      kind: snapshot\n      conditions: {all: {runner: ci-standard}}'
  swap "$conf" '        better: lower' '        better: lower\n      pass-rate:\n        kind: sampled\n        output: all_pass\n        scope: run\n        aggregation: {kind: pass_rate}\n        better: higher' 3
  printf '  pass-rate-holds:\n    meaning: Nine of ten runs pass every case.\n    assessment: conformance\n    measurement: pass-rate\n    condition: {operator: gte, value: 0.9}\n    reference:\n      kind: accepted_value\n      tolerance: {absolute: 0.05}\n      adoption: {from: trusted_revision, runs: 10, aggregation: {kind: median}}\n' >> "$c/$conf"
  add_row '| `conformance-cases@1/conformance/pass-rate` | Higher | None | 0.05 | `conformance-report@1`, output `all_pass` |'
}

# rate_copy <case>: a copy with that measurement.
rate_copy() {
  copy "$1"
  add_rate
}

# add_runs: the plan of conformance-cases@1 of the copy becomes a controlled run of three runs
# under a condition, and gets a sampled measurement without an aggregation, the time of the
# step, with its row. conformance-report@1 declares the output at the end of its file, which is
# the map `outputs` until a case writes there.
add_runs() {
  printf '  duration: {value_type: number, kind: sampled, scopes: [], unit: s}\n' >> "$c/$conf_d"
  swap "$conf" '      kind: snapshot' '      kind: controlled_run\n      command: task test\n      runs: 3\n      conditions: {all: {runner: ci-standard}}'
  swap "$conf" '        better: lower' '        better: lower\n      step-time:\n        kind: sampled\n        output: duration\n        scope: run\n        unit: s\n        better: lower' 3
  add_row '| `conformance-cases@1/conformance/step-time` | Lower | `s` | None | `conformance-report@1`, output `duration` |'
}

# runs_copy <case>: a copy with that plan.
runs_copy() {
  copy "$1"
  add_runs
}

# -- the harness of the copies ------------------------------------------------------------------
#
# The cases of the harness itself, none counted as a copy: without them every case below
# could pass for a reason that is no refusal.

# An edit that changes nothing stops the run, with each of the four ways to edit.
copy harness-edit
if (swap "$conf" 'a line the file does not hold' 'another line') 2> /dev/null; then
  stop "a swap of a line the file does not hold does not stop the run"
fi
if (swap "$conf" "$meaning" "$meaning") 2> /dev/null; then
  stop "a swap of a line for itself does not stop the run"
fi
if (drop "$conf" 'a line the file does not hold') 2> /dev/null; then
  stop "a drop of a line the file does not hold does not stop the run"
fi
if (edit "$conf" '{ print }') 2> /dev/null; then
  stop "an edit that changes nothing does not stop the run"
fi
if (own_spec; edit_spec specification.yaml '{ print }') 2> /dev/null; then
  stop "an edit of the specification that changes nothing does not stop the run"
fi

# An edit of a file that the copy does not hold stops the run and names the case and the
# file, with each of the three ways to edit a file of the copy.
outside='a-page-of-another-family.md'
for way in edit swap drop; do
  if (
    case $way in
      edit) edit "$outside" '{ print }' ;;
      swap) swap "$outside" 'a line' 'another line' ;;
      drop) drop "$outside" 'a line' ;;
    esac
  ) 2> "$c.outside"; then
    stop "the $way of a file that the copy does not hold does not stop the run"
  fi
  grep -F -q "presets: the case harness-edit edits $outside, and its copy holds no $outside" "$c.outside" || {
    cat "$c.outside"
    stop "the $way of a file that the copy does not hold does not name the case and the file"
  }
done

# The unchanged set is accepted, also through the options, and is not counted as refused.
copy harness-unchanged
verdict 'presets:'
if [ "$verdict" != accepted ]; then
  cat "$c.out"
  stop "the unchanged copy of the set is not accepted"
fi
set_summary=$(tail -n 1 "$c.out")
if sh "$self" --catalog "$c" --spec "$spec" > "$c.options" 2>&1 && [ "$(cat "$c.options")" = "$set_summary" ]; then :; else
  cat "$c.options"
  stop "the unchanged copy of the set fails with --catalog and --spec, or prints another line than: $set_summary"
fi

# `--spec` names the specification that is read: against a directory of domain files that
# declares no type, the unchanged copy is refused for the list this script needs first.
mkdir "$work/harness-spec"
printf 'types: []\n' > "$work/harness-spec/empty.yaml"
if sh "$self" --catalog "$c" --spec "$work/harness-spec" > "$work/harness-spec.out" 2>&1; then
  cat "$work/harness-spec.out"
  stop "--spec is not read: the copy is accepted against a specification that declares no type"
fi
grep -F -q 'presets: the specification declares no ratchet.config.CatalogFileKind' "$work/harness-spec.out" || {
  cat "$work/harness-spec.out"
  stop "against a specification that declares no type the copy is refused for another reason than the absent list"
}

# The run without options fails where presets/ itself is refused: this script in a tree of its
# own, target/presets/harness-tree, whose presets/ is the set and a file of no kind.
mkdir -p "$work/harness-tree/spec"
cp "$self" "$work/harness-tree/spec/presets.test.sh"
cp -R "$root/spec/domains" "$work/harness-tree/spec/domains"
cp -R "$set_dir" "$work/harness-tree/presets"
printf 'A note.\n' > "$work/harness-tree/presets/notes.txt"
if sh "$work/harness-tree/spec/presets.test.sh" > "$work/harness-tree.out" 2>&1; then
  cat "$work/harness-tree.out"
  stop "the run in a tree whose presets/ holds notes.txt exits 0"
fi
grep -F -q 'notes.txt: the entry is no preset, no declaration and no page' "$work/harness-tree.out" || {
  cat "$work/harness-tree.out"
  stop "the run in a tree whose presets/ holds notes.txt does not name the entry"
}

# The run without options stops where presets/ lacks a file of the set, and names the file:
# this script in a tree of its own, target/presets/harness-set, whose presets/ is valid and
# holds the page of the set under another name.
mkdir -p "$work/harness-set/spec"
cp "$self" "$work/harness-set/spec/presets.test.sh"
cp -R "$root/spec/domains" "$work/harness-set/spec/domains"
cp -R "$set_dir" "$work/harness-set/presets"
mv "$work/harness-set/presets/$page" "$work/harness-set/presets/family.md"
if sh "$work/harness-set/spec/presets.test.sh" > "$work/harness-set.out" 2>&1; then
  cat "$work/harness-set.out"
  stop "the run in a tree whose presets/ lacks a file of the set exits 0"
fi
grep -F -q "presets: presets/ holds no $page, a file of the set that every copy of this script holds" "$work/harness-set.out" || {
  cat "$work/harness-set.out"
  stop "the run in a tree whose presets/ lacks a file of the set does not name the file"
}

# The case `harness-unchanged` compares the line printed with --catalog and --spec with the
# line of the check in process. A case cannot take out its own line, so this one runs a copy of
# this script in a tree of its own, target/presets/harness-compare, whose presets/ is the set.
# The copy prints another line with --catalog and stops with exit 0 at the line `mkdir` of the
# case after `harness-unchanged`, before it would run this case again. The copy exits 1 with the
# message of the comparison; a script without the comparison gives a copy that exits 0.
compare_tree=$work/harness-compare
mkdir -p "$compare_tree/spec"
cp -R "$root/spec/domains" "$compare_tree/spec/domains"
cp -R "$set_dir" "$compare_tree/presets"
awk '
  $0 == "  tables \"$spec\" | check_catalog \"$catalog\" -" { print "  tables \"$spec\" | check_catalog \"$catalog\" - | sed \"s/\\$/, and a word more/\""; edited++; next }
  $0 == "mkdir \"$work/harness-spec\"" { print "exit 0"; edited++ }
  { print }
  END { exit (edited != 2) }
' "$self" > "$compare_tree/spec/presets.test.sh" || stop "the case harness-compare finds no line of --catalog or no line mkdir of the case harness-spec in this script to edit"
if sh "$compare_tree/spec/presets.test.sh" > "$compare_tree.out" 2>&1; then
  cat "$compare_tree.out"
  stop "a copy of this script that prints another line with --catalog and --spec than its check in process exits 0: the comparison of the case harness-unchanged is gone"
fi
grep -F -q "presets: the unchanged copy of the set fails with --catalog and --spec, or prints another line than: " "$compare_tree.out" || {
  cat "$compare_tree.out"
  stop "a copy of this script that prints another line with --catalog and --spec than its check in process exits 1 without the message of the comparison"
}

# A refusal counts only with the message of the rule of its case.
copy harness-message
printf 'A note.\n' > "$c/notes.txt"
verdict 'the message of no rule'
[ "$verdict" = other ] || stop "a refusal without the message of its rule counts as the refusal of its case"

# An accepted copy, and a copy refused without the message of its rule, give exit 1.
if (cases=0; accepted=0; broken=0; kept=0; copy harness-accepted; refused 'the message of no rule' 'the unchanged set'; result) > "$work/harness.out" 2>&1; then
  stop "an accepted copy does not fail the run"
fi
grep -q '^accepted: harness-accepted: ' "$work/harness.out" || stop "an accepted copy is not named"
grep -q ', 0 of 1 broken copies refused, 1 accepted$' "$work/harness.out" || stop "an accepted copy is not counted as accepted in the last line"
if (cases=0; accepted=0; broken=0; kept=0; name=harness-message; c=$work/harness-message; refused 'the message of no rule' 'the directory holds notes.txt'; result) > "$work/harness.out" 2>&1; then
  stop "a copy refused without the message of its rule does not fail the run"
fi
grep -q '^refused without the message of its rule: harness-message: ' "$work/harness.out" || stop "a copy refused without the message of its rule is not named"

# Two cases that share a copy are judged each by its own message: the copy is refused with the
# message of the first and without the message of the second, and the second alone is named.
if (cases=0; accepted=0; broken=0; kept=0; name=harness-message; c=$work/harness-message; refused 'notes.txt: the entry is no preset, no declaration and no page' 'the directory holds notes.txt'; again harness-shared; refused 'the message of no rule' 'nothing more'; result) > "$work/harness.out" 2>&1; then
  stop "a case that shares a copy and is refused without the message of its rule does not fail the run"
fi
grep -q '^refused without the message of its rule: harness-shared: ' "$work/harness.out" || stop "a case that shares a copy and is refused without the message of its rule is not named"
if grep -q ': harness-message: ' "$work/harness.out"; then
  stop "a case that shares a copy and is refused with the message of its rule is named as a failure"
fi
grep -q '^presets: 1 of 2 defect(s) refused with the message of their rule, 1 not$' "$work/harness.out" || stop "two cases that share a copy are not counted each"
grep -q ', 0 of 1 broken copies refused, 1 accepted$' "$work/harness.out" || stop "a copy with a case that is refused without the message of its rule is not counted as accepted"

# A copy that is refused stops the run where its case says that it is valid.
if (name=harness-message; c=$work/harness-message; accepts 'the directory holds notes.txt') > /dev/null 2>&1; then
  stop "a refused copy passes as a valid form"
fi

# -- forms that are valid ------------------------------------------------------------------------
#
# A copy holds several valid forms, each on a line of its own, and `accepts` checks it once: a
# form that is refused stops the run, and the output names its line.

copy valid-forms
# spaces at the end of a line
swap "$conf" '        kind: exact' '        kind: exact   '
# a quoted reference as the value of a key
swap "$conf" "$passes" '      report: "${inputs.report}"'
# a measurement of a set that leaves the identity key to the declaration
drop "$conf" '        identity: [case_id]'
# U+200C and U+200D, with which some writing systems are spelled, and the characters beside
# the refused ranges: U+00A0, U+2027, U+202F, U+205F and U+FFFD
swap "$conf" "$meaning" '    meaning: Every case \342\200\214 \342\200\215 \302\240 \342\200\247 \342\200\257 \342\201\237 \357\277\275 still passes.'
# a default of a declaration that holds `${`, which is text there
swap "$conf_d" '  report: {type: path, required: true}' '  report: {type: path, required: true}\n  label: {type: string, required: false, default: "${run}"}'
# a decimal written as quoted text
swap "$differ" "$limit" '      value: "0.5"'
# an assessment that passes an integer input where a decimal is declared
swap "$differ_d" '  report: {type: path, required: true}' '  report: {type: path, required: true}\n  limit: {type: decimal, required: true}'
swap "$differ" "$passes" '      report: ${inputs.report}\n      limit: ${inputs.different_limit}'
accepts "spaces at the end of a line, a quoted reference, a set without identity key, the characters beside the refused ranges, a default of a declaration with a dollar sign and a brace, a quoted decimal, an integer input for a decimal"

# A value that an input gives is not joined with the declaration. Each place has a value that
# the declaration does not hold, and each stands in a plan, a measurement or a requirement of
# its own, because a plan whose assessor an input gives and a measurement whose output an
# input gives are not joined at all.
copy valid-references
# the assessor of a plan
swap "$known" '    assessor: case-list@1' '    assessor: ${inputs.subject}'
# the output of the measurement `passed`
swap "$conf" '        output: passed' '        output: ${inputs.subject}'
# the scope of `failed`
swap "$conf" '        scope: run' '        scope: ${inputs.subject}' 3
# the unit of `skipped`
swap "$conf" '        unit: cases' '        unit: ${inputs.subject}' 3
# the boundary and the kind of `refused`
swap "$conf" '        output: refused' '        output: refused\n        boundary: ${inputs.subject}'
swap "$conf" '        kind: exact' '        kind: ${inputs.subject}' 5
# the unit of the condition of `failed-does-not-rise`, the operator of a condition of
# `skipped-does-not-rise`, and the kind of the reference of `refused-does-not-rise`: each is
# the third line with the accepted value that is left
swap "$conf" "$accepted_value" '    condition: {operator: lte, value: 3, unit: "${inputs.subject}"}' 3
swap "$conf" "$accepted_value" '    condition: {operator: "${inputs.subject}", value: 3, unit: cases}' 3
swap "$conf" "$accepted_value" '    reference: {kind: "${inputs.subject}"}' 3
# an identity key, and an item of one
swap "$differ" '        identity: [case_id]' '        identity: ${inputs.environments}'
swap "$differ" '        identity: [case_id]' '        identity: ["${inputs.subject}"]'
# the kind of the aggregation of an assertion, which is then not taken as a number
add_rate
swap "$conf" '        aggregation: {kind: pass_rate}' '        aggregation: {kind: "${inputs.subject}"}'
# the assessor of a plan over the runs of another plan
add_window
swap "$known" '    assessor: record-series@1' '    assessor: ${inputs.list}'
accepts "an assessor, an output, a scope, a unit, a boundary, a kind, the unit and the operator of a condition, the kind of a reference, an identity key, an item of one, the kind of an aggregation and the assessor of a window over runs, each given by an input"

copy valid-inputs
# The name of an input is text (`ratchet.specification.Preset.inputs`), so it may hold a `.`.
swap "$conf" '    report: {type: path, required: true}' '    report.file: {type: path, required: true}'
swap "$conf" "$passes" '      report: ${inputs.report.file}'
# an assessment that passes a list of text with a text input as one item
swap "$differ_d" '  report: {type: path, required: true}' '  report: {type: path, required: true}\n  exclude: {type: string, list: true, required: false}'
swap "$differ" "$passes" '      report: ${inputs.report}\n      exclude: ["${inputs.subject}", other]'
# The kind of a target by an input: with a default that the declaration takes, and without one.
swap "$conf" '    subject: {type: string, required: true}' '    subject: {type: string, required: true}\n    target_kind: {type: string, required: false, default: revision}'
swap "$conf" '      kind: revision' '      kind: ${inputs.target_kind}'
swap "$differ" '    subject: {type: string, required: true}' '    subject: {type: string, required: true}\n    target_kind: {type: string, required: true}'
swap "$differ" '      kind: revision' '      kind: ${inputs.target_kind}'
# a measurement with the boundary queue_wait on an output that declares no boundaries
swap "$conf" '        output: failed' '        output: failed\n        boundary: queue_wait'
# A condition and a field of a population filter that the declaration lists, beside a
# condition of Ratchet itself, and two conditions of the machine and the build that the
# declaration does not list: the rule reads the members of ObservationConditions. The plan
# declares what its command needs, by name (ObservationPlan.needs).
swap "$conf_d" 'conditions: []' 'conditions: [cache_profile]'
printf 'population_fields: [service]\n' >> "$c/$conf_d"
swap "$conf" '      kind: snapshot' '      kind: time_window\n      window: {last: 20}\n      population: {filter: {service: orders-api}}\n      min_samples: 10\n      conditions: {all: {cache_profile: warm, runner: ci-standard, build_profile: release, cpu_model: \"AMD EPYC 7763\"}}\n      needs: {environment: [PROVIDER_TOKEN], billed: true}'
# The conditions of a plan as the whole value of `observation.conditions`, given by an input
# of the type `conditions`.
swap "$known" '    environments: {type: string, list: true, required: true}' '    environments: {type: string, list: true, required: true}\n    conditions: {type: conditions, required: true}'
swap "$known" '      kind: snapshot' '      kind: snapshot\n      conditions: ${inputs.conditions}'
accepts "an input named report.file, a text input as an item of a list, a target kind by an input with and without a default, the boundary queue_wait, a declared condition, the conditions runner, build_profile and cpu_model of Ratchet, a declared field of a population filter, the needs of a command and the conditions of a plan by an input of the type conditions"

# A sampled measurement that aggregates an exact assertion with pass_rate, compared with a limit
# and with a reference; and a second plan that names record-series@1 and reads the runs of the
# first, with its requirement and its row. The rate is sampled: its plan declares a condition
# and its reference a tolerance and an adoption, the window declares no conditions, and a
# requirement that compares the rate with a limit alone needs no reference. The plan then holds
# the sampled rate beside its exact counts, which docs/design.md § 3 allows ("Exact and sampled
# measurements of one run"), and its condition qualifies both.
copy valid-plans
add_rate
add_window
printf '  pass-rate-above-half:\n    meaning: At least half of the runs pass every case.\n    assessment: conformance\n    measurement: pass-rate\n    condition: {operator: gte, value: 0.5}\n' >> "$c/$conf"
accepts "a pass rate of an assertion with a reference and with a limit alone, and a window over the runs of another plan"

# -- file ------------------------------------------------------------------------------------

copy file-of-no-kind
printf 'A note.\n' > "$c/notes.txt"
refused 'notes.txt: the entry is no preset, no declaration and no page' "the directory holds notes.txt"

copy file-hidden
printf 'A note.\n' > "$c/.hidden"
refused '.hidden: the entry is hidden' "the directory holds .hidden"

copy file-two-dots
printf 'A note.\n' > "$c/..notes.txt"
refused '..notes.txt: the entry is hidden' "the directory holds ..notes.txt"

copy file-symbolic-link
mv "$c/$page" "$c.page"
ln -s "../$name.page" "$c/$page"
refused 'functional.md: the entry is a symbolic link' "the page is a symbolic link to a file outside the directory"

copy file-empty
: > "$c/empty.md"
refused 'empty.md: the entry is an empty file' "a page is empty"

copy file-name-characters
mv "$c/$page" "$c/functional+page.md"
refused 'functional+page.md: the entry has a name with a character that is no letter' "the page is named functional+page.md"

copy file-directory
mkdir "$c/functional"
mv "$c/$differ" "$c/functional/"
refused 'functional: the entry is no regular file' "a preset lies in a directory of the catalog"

copy file-directory-named-as-a-page
mkdir "$c/notes.md"
refused 'notes.md: the entry is no regular file' "a directory is named notes.md"

copy file-nul
printf 'note: a\000b\n' >> "$c/$conf"
refused 'conformance-cases@1.preset.yaml: the entry holds a NUL byte' "a preset holds a NUL byte"

# Bytes that are refused in every file, each in a line of `meaning` of its own, eleven to a
# copy: the byte 255 and six sequences that look like UTF-8 and are none; the byte 1; and the
# characters that are UTF-8 and are refused, with the ends of each range and each character
# that stands alone. The message names the line, so a case holds for its bytes alone.
byte_case=0
for case_bytes in \
  'file-not-utf8|\377|the byte 255|is not UTF-8' \
  'file-utf8-two-bytes-for-one|\300\200|U+0000 in two bytes|is not UTF-8' \
  'file-utf8-three-bytes-for-two|\340\200\200|U+0000 in three bytes|is not UTF-8' \
  'file-utf8-surrogate|\355\240\200|the surrogate U+D800|is not UTF-8' \
  'file-utf8-four-bytes-for-three|\360\200\200\200|U+0000 in four bytes|is not UTF-8' \
  'file-utf8-above-the-last|\364\220\200\200|U+110000, above the last character|is not UTF-8' \
  'file-utf8-lead-of-five|\365\200\200\200|the lead byte 245|is not UTF-8' \
  'file-control-character|\001|the byte 1|holds a control character' \
  'file-c1-first|\302\200|U+0080, the first C1 control character|holds a C1 control character' \
  'file-c1-last|\302\237|U+009F, the last C1 control character|holds a C1 control character' \
  'file-paragraph-separator|\342\200\251|the paragraph separator U+2029|holds the line separator U+2028 or the paragraph separator U+2029' \
  'file-byte-order-mark-in-a-line|\357\273\277|the byte order mark U+FEFF inside a line|holds the byte order mark U+FEFF' \
  'file-noncharacter-fffe|\357\277\276|U+FFFE|holds U+FFFE or U+FFFF' \
  'file-noncharacter-ffff|\357\277\277|U+FFFF|holds U+FFFE or U+FFFF' \
  'file-zero-width-space|\342\200\213|the zero width space U+200B|holds a character that hides or reorders text' \
  'file-left-to-right-mark|\342\200\216|the left-to-right mark U+200E|holds a character that hides or reorders text' \
  'file-right-to-left-mark|\342\200\217|the right-to-left mark U+200F|holds a character that hides or reorders text' \
  'file-embedding-first|\342\200\252|U+202A, the first of the embeddings and overrides|holds a character that hides or reorders text' \
  'file-override-last|\342\200\256|U+202E, the last of the embeddings and overrides|holds a character that hides or reorders text' \
  'file-word-joiner|\342\201\240|the word joiner U+2060|holds a character that hides or reorders text' \
  'file-isolate-first|\342\201\246|U+2066, the first of the isolates|holds a character that hides or reorders text' \
  'file-isolate-last|\342\201\251|U+2069, the last of the isolates|holds a character that hides or reorders text'
do
  if [ $((byte_case % 11)) -eq 0 ]; then copy "${case_bytes%%|*}"; else again "${case_bytes%%|*}"; fi
  byte_case=$((byte_case + 1))
  case_bytes=${case_bytes#*|}
  meaning_bytes $(((byte_case - 1) % 11 + 1)) "${case_bytes%%|*}"
  case_bytes=${case_bytes#*|}
  refused "$at: the line ${case_bytes#*|}" "a preset holds ${case_bytes%%|*}"
done

copy file-carriage-return
swap "$conf" "$meaning" '    meaning: Every case\r#  of the accepted set.'
refused 'conformance-cases@1.preset.yaml:56: the line holds a control character' "a line of a preset holds a carriage return and no line feed after it"

# The same in a page and in README.md.
copy file-utf8-cut-short
edit "$page" 'NR == 1 { print $0 " \342\202"; next } { print }'
refused 'functional.md:1: the line is not UTF-8' "a character of the page ends after two of its three bytes"

again file-control-character-in-readme
printf 'A line.\033\n' >> "$c/README.md"
refused "README.md:$(($(wc -l < "$c/README.md"))): the line holds a control character" "README.md holds the byte 27"

again file-next-line-in-readme
printf 'A line.\302\205And a line more for a YAML 1.1 reader.\n' >> "$c/README.md"
refused "README.md:$(($(wc -l < "$c/README.md"))): the line holds a C1 control character" "README.md holds the next line U+0085"

copy file-byte-order-mark-at-the-start-of-a-page
edit "$page" 'NR == 1 { print "\357\273\277" $0; next } { print }'
refused 'functional.md:1: the line holds the byte order mark U+FEFF' "the page starts with the byte order mark"

# hidden_gate <the bytes of a character, as awk writes them>: the preset known-failures@1 of
# the copy gets its assessments after its requirements, and its last two lines are a condition
# whose text holds the character twice, around `gates:`. A reader that takes the character as
# the end of a line reads a root key `gates` with a gate `merge` there; this script reads one
# line of text.
hidden_gate() {
  edit "$known" '
    /^assessments:$/ { moved = 1 }
    /^requirements:$/ { moved = 0 }
    moved && ($0 == "    observation:" || $0 == "      kind: snapshot") { next }
    moved { if ($0 != "") held = held $0 "\n"; next }
    { print }
    END { printf "\n%s    observation:\n      kind: snapshot\n      conditions:\n        all:\n          cache_profile: warm'"$1"'gates:'"$1"'\n          merge: {stage: pre-merge, qualifying_environments: [ci], requires: [size-does-not-rise]}\n", held }'
}

copy file-line-separator-hides-a-gate
hidden_gate '\342\200\250'
refused 'known-failures@1.preset.yaml:50: the line holds the line separator U+2028 or the paragraph separator U+2029' "a condition of a preset holds the line separator U+2028 before and after gates:"

copy file-next-line-hides-a-gate
hidden_gate '\302\205'
refused 'known-failures@1.preset.yaml:50: the line holds a C1 control character' "a condition of a preset holds the next line U+0085 before and after gates:"

# The directory of this copy has a quote and a space in its name: the check makes the path of
# each file one word of a shell command, to look at its last byte. The second case holds when
# that one file is named and no other: a command that the shell cannot read names every file.
copy file-last-line-without-line-feed
mv "$c" "$work/a copy's last line"
c="$work/a copy's last line"
printf '%s' "$(cat "$c/$conf")" > "$c.new"
mv "$c.new" "$c/$conf"
refused 'conformance-cases@1.preset.yaml:80: the last line does not end with a line feed' "the last line of a preset has no line feed"

again file-last-line-of-one-file-alone
refused 'presets: 11 of 12 file(s) valid, 21 of 21 measurement(s) with a row, 1 failure(s)' "the last line of one file has no line feed, in a directory with a quote and a space in its name"

copy file-kind-undeclared
mv "$c/$conf" "$c/conformance-cases@1.presets.yaml"
refused 'is no `<name>@<version>.<kind>.yaml` with a kind of ratchet.config.CatalogFileKind' "a preset is named conformance-cases@1.presets.yaml"

copy file-without-name
mv "$c/$conf" "$c/preset.yaml"
refused 'preset.yaml:1: the file is no `<name>@<version>.<kind>.yaml`' "a preset is named preset.yaml"

copy file-name-preset
mv "$c/$conf" "$c/conformance@1.preset.yaml"
refused 'the file is named `conformance@1.preset.yaml` and states the name and the version `conformance-cases@1`' "the preset conformance-cases@1 is the file conformance@1.preset.yaml"

copy file-name-declaration
swap "$conf_d" 'version: "1"' 'version: "2"'
refused 'the file is named `conformance-report@1.assessor.yaml` and states the name and the version `conformance-report@2`' "the declaration conformance-report@1.assessor.yaml states the version 2"

copy file-name-with-at
mv "$c/$known_d" "$c/case@list@1.assessor.yaml"
swap 'case@list@1.assessor.yaml' 'name: case-list' 'name: case'
swap 'case@list@1.assessor.yaml' 'version: "1"' 'version: "list@1"'
refused 'the name `case` or the version `list@1` holds `@`' "a declaration states the name case and the version list@1"

copy file-readme-absent
rm "$c/README.md"
refused 'README.md: the directory holds no README.md' "the directory holds no README.md"

copy file-no-preset
rm "$c/"*.preset.yaml "$c/$page"
refused 'presets: the directory holds no preset' "the directory holds README.md and three declarations"

copy file-preset-without-requirement
printf 'format: ratchet/1\npreset:\n  name: empty\n  version: "1"\n  inputs: {}\n' > "$c/empty@1.preset.yaml"
refused 'empty@1.preset.yaml:1: the preset holds no requirement' "a preset holds the preset block alone"

# -- form ------------------------------------------------------------------------------------

# Ten forms on ten lines of one copy. No edit of this copy adds or takes a line, and six
# messages name their line.
copy form-comment-after-value
swap "$conf" "$meaning" '    meaning: Every case still passes. # the first rule'
refused 'conformance-cases@1.preset.yaml:56: not read: a comment after a value' "a comment follows a value"

again form-quote-before-comment
swap "$conf" "$meaning_passed" '    meaning: The number of "passed #1 cases" is not below the accepted number.'
refused 'conformance-cases@1.preset.yaml:62: not read: a quote inside a plain scalar' 'a plain scalar holds a quoted part with " #" in it, where YAML starts a comment'

again form-lone-quote
swap "$conf" "$meaning_failed" "    meaning: The number of 'failed cases is not above the accepted number. # and a comment"
refused 'conformance-cases@1.preset.yaml:67: not read: a quote inside a plain scalar' "a plain scalar holds one quote and a comment after it"

again form-tab
swap "$conf" "$meaning_skipped" '    meaning: The number of skipped cases\tis not above the accepted number.'
refused 'conformance-cases@1.preset.yaml:72: not read: a tab' "a value holds a tab"

again form-single-quote-doubled
swap "$conf" "$meaning_refused" "    meaning: 'The number of \"refused\" cases, it''s said, is not above the accepted number.'"
refused 'conformance-cases@1.preset.yaml:77: not read: a quote inside a plain scalar' "a single-quoted scalar holds both kinds of quote, its own one doubled"

again form-quote-in-flow-list
swap "$differ" '        filter: {class: [equal]}' "        filter: {class: [equal 'a, b' c]}"
refused 'differential-equality@1.preset.yaml:30: not read: a quote inside a plain scalar' "an item of a flow list holds a quoted part with a comma in it, which YAML reads as two items"

again form-unquoted-reference
swap "$conf" "$passes" '      {report: ${inputs.report}}'
refused 'holds a bracket or a brace inside a flow collection; quote it' "a reference stands plain in a flow mapping"

again form-flow-mapping-open
swap "$conf" "$set_rule" '    condition: {operator: no_lost_items x'
refused 'the flow mapping of `requirements.no-case-lost.condition` does not close on its line' "a flow mapping does not close"

again form-flow-list-open
swap "$conf" '        identity: [case_id]' '        identity: [case_id x'
refused 'the flow list of `assessments.conformance.measurements.passing-cases.identity` does not close on its line' "a flow list does not close"

again form-flow-list-bracket
swap "$conf_d" 'conditions: []' 'conditions: []]'
refused 'a bracket or a quote in the flow list of `conditions` does not close' "a flow list holds a bracket too many"

# Eleven forms on lines of their own of a second copy, each named by its path or its text.
copy form-escape
swap "$conf" "$meaning" '    meaning: "Every case \\n still passes."'
refused 'the quoted scalar of `requirements.no-case-lost.meaning` holds an escape' "a double-quoted scalar holds an escape"

again form-quote-not-closed
swap "$conf" "$meaning_passed" '    meaning: "The number of passed cases is not below the accepted number.'
refused 'the quoted scalar of `requirements.passed-does-not-fall.meaning` does not end at its quote' "a quoted scalar does not close"

again form-tag
swap "$conf" "$meaning_failed" '    meaning: !!str The number of failed cases is not above the accepted number.'
refused 'the value `!!str The number of failed cases is not above the accepted number.` of `requirements.failed-does-not-rise.meaning` is in a form this script does not read' "a value has a tag"

again form-colon-in-plain
swap "$conf" "$meaning_skipped" '    meaning: The number of skipped cases: it is not above the accepted number.'
refused 'the plain scalar of `requirements.skipped-does-not-rise.meaning` holds `: `; quote it' "a plain scalar holds a colon and a space"

again form-folded-scalar
swap "$conf" "$meaning_refused" '    meaning: >-\n      The number of refused cases is not above the accepted number.'
refused 'the value `>-` of `requirements.refused-does-not-rise.meaning` is in a form this script does not read' "a text is written as a folded scalar"

again form-key-twice
swap "$conf" '        output: passed' '        output: passed\n        output: failed'
refused 'stands twice in its mapping' "a measurement holds the key output twice"

again form-block-list
swap "$conf" '        identity: [case_id]' '        identity:\n          - case_id'
refused 'not read: a block list' "an identity key is written as a block list"

again form-under-a-value
swap "$conf" "$passes" '      report: ${inputs.report}\n        extra: 1'
refused 'not read: `extra: 1` is indented under `assessments.conformance.inputs.report`, which has a value on its line' "a key stands under a key that has a value"

again form-flow-mapping-no-pair
swap "$conf" "$set_rule" '    condition: {operator}'
refused '`operator` in the flow mapping of `requirements.no-case-lost.condition` is no `key: value`' "a flow mapping holds a word and no key with a value"

again form-flow-mapping-bracket
swap "$differ" '        filter: {class: [equal]}' '        filter: {class: [equal]]}'
refused 'a bracket or a quote in the flow mapping of `assessments.comparison.measurements.equal-cases.filter` does not close' "a flow mapping holds a bracket too many"

again form-flow-list-empty-item
swap "$conf_d" 'conditions: []' 'conditions: [,]'
refused 'the flow list of `conditions` holds an empty item' "a flow list holds an empty item"

# Forms that change how the lines after them are read, each in a copy of its own.
copy form-comment-line
edit "$conf" 'NR == 1 { print "# The conformance preset of the functional family." } { print }'
refused 'conformance-cases@1.preset.yaml:1: not read: a comment; a preset and a declaration hold none' "a preset starts with a comment line"

copy form-indented-at-root
swap "$conf" 'format: ratchet/1' ' format: ratchet/1'
refused 'not read: `format: ratchet/1` is indented at the root of the file' "the first key is indented by one space"

copy form-uneven-indent
swap "$conf" '      refused:' '     refused:'
refused 'is not indented as the line before it under `assessments.conformance.measurements`' "one key of a mapping is indented by one space less"

copy form-flow-of-no-key
printf '{}\n' >> "$c/$conf"
refused 'not read: a flow collection that is the value of no key' "a flow mapping stands at the root"

copy form-key-after-flow
swap "$conf" '    subject: {type: string, required: true}' '    {subject: {type: string, required: true}}'
refused 'follows the flow collection of `preset.inputs`' "keys follow a flow mapping in one block mapping"

copy form-key-quoted
swap "$conf" '  no-case-lost:' '  "no-case-lost":'
refused 'not read: `"no-case-lost":` is no `key:` and no `key: value`' "a requirement has a quoted key"

copy form-flow-mapping-no-value
swap "$conf" "$set_rule" '    condition: {operator: no_lost_items, unit:}'
refused '`requirements.no-case-lost.condition.unit` has no value in its flow mapping' "a key of a flow mapping has no value"

copy form-key-empty
swap "$conf" '  no-case-lost:' '  :'
refused 'not read: `:` is no `key:` and no `key: value`' "a key is empty"

copy form-key-integer
printf '  0o17:\n    assessment: conformance\n    measurement: failed\n%s\n  15:\n    assessment: conformance\n    measurement: failed\n%s\n' "$accepted_value" "$accepted_value" >> "$c/$conf"
refused 'not read: the key `0o17` is a YAML integer and no text' "two requirements have the keys 0o17 and 15, one integer to YAML"

copy form-key-boolean
swap "$conf" '  no-case-lost:' '  true:'
refused 'not read: the key `true` is a YAML boolean and no text' "a requirement has the key true"

copy form-key-null
swap "$conf" '  no-case-lost:' '  null:'
refused 'not read: the key `null` is a YAML null and no text' "a requirement has the key null"

copy form-key-number-in-flow
swap "$conf" "$set_rule" '    condition: {1.5: no_lost_items}'
refused 'not read: the key `1.5` is a YAML number and no text' "a flow mapping has the key 1.5"

# -- place, type, required --------------------------------------------------------------------

copy key-preset
swap "$conf" '        better: higher' '        improves: higher'
refused '`assessments.conformance.measurements.passed.improves` is not a field of ratchet.specification.Measurement' "a measurement holds the key improves"

again key-declaration
swap "$conf_d" 'coverage_unit: case' 'coverage_units: case'
refused '`coverage_units` is not a field of ratchet.assessor.Assessor' "a declaration holds the key coverage_units"

again value-preset
swap "$conf" "$set_rule" '    condition: {operator: no_lost_item}'
refused 'is `no_lost_item`, which is no value of ratchet.specification.ComparisonOperator' "a condition has the operator no_lost_item"

again value-declaration
swap "$conf_d" '    value_type: identity_set' '    value_type: set'
refused 'is `set`, which is no value of ratchet.specification.ValueType' "an output has the value type set"

again value-absent
swap "$conf" "$passes" '      report:'
refused '`assessments.conformance.inputs.report` has no value on its line and nothing under it' "a key has no value"

copy key-renamed-in-specification
own_spec
edit_spec specification.yaml '
  /^  - name: / { t = $3 }
  t == "ratchet.specification.Measurement" && $0 == "      - name: better" { print "      - name: improves"; next }
  { print }'
refused '`assessments.conformance.measurements.passed.better` is not a field of ratchet.specification.Measurement' "the specification names the field improves and the presets still write better"

copy value-format
swap "$conf" 'format: ratchet/1' 'format: ratchet/2'
refused '`format` is not `ratchet/1`' "a preset has the format ratchet/2"

again value-format-of-declaration
swap "$conf_d" 'format: ratchet-assessor/1' 'format: ratchet-assessor/2'
refused '`format` is not `ratchet-assessor/1`' "a declaration has the format ratchet-assessor/2"

copy value-format-absent
drop "$conf" 'format: ratchet/1'
refused 'conformance-cases@1.preset.yaml:1: `(root)` has no `format`' "a preset states no format"

copy value-preset-block-absent
edit "$conf" '
  /^preset:$/ { block = 1; next }
  block && /^( |$)/ { next }
  { block = 0; print }'
refused 'conformance-cases@1.preset.yaml:1: `(root)` has no `preset` block' "a preset has no preset block"

# Seventeen values of another type than the declared one, each at a path of its own in one copy.
copy type-null
swap "$conf" "$meaning" '    meaning: null'
refused '`requirements.no-case-lost.meaning` is null; an absent member is left out' "a text member is null"

again type-text
swap "$conf" '  version: "1"' '  version: 1'
refused '`preset.version` is a YAML integer where text is declared' "the version of a preset is the integer 1"

again type-text-number
swap "$conf" "$meaning_passed" '    meaning: 1.5'
refused '`requirements.passed-does-not-fall.meaning` is a YAML number where text is declared' "a text member is the number 1.5"

again type-text-infinity
swap "$conf" "$meaning_failed" '    meaning: .inf'
refused '`requirements.failed-does-not-rise.meaning` is a YAML number where text is declared' "a text member is .inf"

again type-text-not-a-number
swap "$conf" "$meaning_skipped" '    meaning: .nan'
refused '`requirements.skipped-does-not-rise.meaning` is a YAML number where text is declared' "a text member is .nan"

again type-text-hexadecimal
swap "$conf" "$meaning_refused" '    meaning: 0x1F'
refused '`requirements.refused-does-not-rise.meaning` is a YAML integer where text is declared' "a text member is 0x1F"

again type-text-empty-output
swap "$conf" '        output: failed' '        output: ""'
refused '`assessments.conformance.measurements.failed.output` is empty text' "a measurement has the output \"\""

again type-text-empty-scope
swap "$conf" '        scope: run' '        scope: ""' 3
refused '`assessments.conformance.measurements.failed.scope` is empty text' "a measurement has the scope \"\""

again type-text-empty-assessment
swap "$conf" '    assessment: conformance' '    assessment: ""' 3
refused '`requirements.failed-does-not-rise.assessment` is empty text' "a requirement has the assessment \"\""

# The third `kind: exact` is the kind of `failed`, then of `skipped`, then of `refused`: each
# swap takes one away.
again type-enum-boolean
swap "$conf" '        kind: exact' '        kind: true' 3
refused '`assessments.conformance.measurements.failed.kind` is a YAML boolean where a value of ratchet.specification.MeasurementKind is declared' "the kind of a measurement is true"

again type-list-for-scalar
swap "$conf" '        kind: exact' '        kind: [exact]' 3
refused '`assessments.conformance.measurements.skipped.kind` is a list where `ratchet.specification.MeasurementKind` is declared' "the kind of a measurement is a list"

again type-mapping-for-scalar
swap "$conf" '        kind: exact' '        kind: {a: b}' 3
refused '`assessments.conformance.measurements.refused.kind` is a mapping where `ratchet.specification.MeasurementKind` is declared' "the kind of a measurement is a mapping"

again type-scalar-for-list
swap "$conf_d" 'targets: [revision]' 'targets: revision'
refused '`targets` is not a list (`List<ratchet.specification.TargetKind>`)' "the targets of a declaration are one word"

again type-scalar-for-mapping
swap "$differ" '        filter: {class: [equal]}' '        filter: equal'
refused '`assessments.comparison.measurements.equal-cases.filter` is not a mapping' "a filter is one word"

again type-integer
swap "$conf" '      kind: snapshot' '      kind: snapshot\n      runs: one'
refused '`assessments.conformance.observation.runs` is not an integer' "the runs of an observation are the word one"

again type-boolean
swap "$conf" '    report: {type: path, required: true}' '    report: {type: path, required: "true"}'
refused '`preset.inputs.report.required` is not `true` or `false`' "an input is required by the text \"true\""

again type-decimal
swap "$conf" "$of_failed" '    measurement: failed\n    condition: {operator: lte, value: 1e3, unit: cases}'
refused '`requirements.failed-does-not-rise.condition.value` is not a decimal without exponent' "the limit of a condition is 1e3"

# add_case_holds <meanings>: the preset conformance-cases@1 of the copy reads an assertion per
# case that conformance-report@1 declares at the scope `case`, with the map `meanings` and its
# row. It writes to the end of the declaration, which is the map `outputs`, and after the third
# `better: lower`, that of `refused`, the last measurement of the plan.
add_case_holds() {
  printf '  case_holds: {value_type: assertion, kind: exact, scopes: [case]}\n' >> "$c/$conf_d"
  swap "$conf" '        better: lower' '        better: lower\n      case-holds:\n        kind: exact\n        output: case_holds\n        scope: case\n        meanings: '"$1" 3
  add_row '| `conformance-cases@1/conformance/case-holds` | Holds for every case | None: an assertion | 0, no input | `conformance-report@1`, output `case_holds` |'
}

# A statement per scope item of a measurement at the scope `case` (docs/design.md § 3 "Scope and
# aggregation").
copy measurement-meanings
add_case_holds '{case-1: "the default timeout"}'
accepts "a measurement at the scope case whose meanings state what the item case-1 stands for"

copy type-meanings-number
add_case_holds '{case-1: 1.5}'
refused '`assessments.conformance.measurements.case-holds.meanings.case-1` is a YAML number where text is declared' "a statement of meanings is a number"

copy type-without-rule
own_spec
edit_spec specification.yaml '
  /^  - name: / { t = $3 }
  t == "ratchet.specification.Measurement" && $0 == "        type: Optional<ratchet.specification.Direction>" { print "        type: Optional<Blob>"; next }
  { print }'
refused 'has the declared type `Blob`, which spec/presets.test.sh has no rule for' "the specification gives better a type this script has no rule for"

copy required-field
drop "$conf" '        output: passed'
refused '`assessments.conformance.measurements.passed` has no `output`, which ratchet.specification.Measurement requires' "a measurement names no output"

again required-field-of-declaration
drop "$conf_d" 'coverage_unit: case'
refused '`(root)` has no `coverage_unit`, which ratchet.assessor.Assessor requires' "a declaration states no coverage unit"

# the third is the reference of `failed-does-not-rise`
again required-source-cites
swap "$conf" "$accepted_value" '    condition: {operator: lte, value: 3, unit: cases, source: {since: 2026-03-01}}\n'"$accepted_value" 3
refused '`requirements.failed-does-not-rise.condition.source` has no `cites`, which ratchet.specification.NumberSource requires' "a source without cites"

# `scopes` stays required where an output has the scope `run` alone: that output writes
# `scopes: []` (spec/domains/assessor.yaml, AssessorOutput), as every output of the set does.
copy required-scopes
swap "$conf_d" "$number_output" '  failed: {value_type: number, kind: exact, unit: cases}'
refused '`outputs.failed` has no `scopes`, which ratchet.assessor.AssessorOutput requires' "an output of a declaration leaves scopes out"

# -- what a preset does not hold ---------------------------------------------------------------

copy preset-gate
printf '\ngates:\n  merge:\n    stage: pre-merge\n    qualifying_environments: [ci]\n    requires: [no-case-lost]\n' >> "$c/$conf"
refused '`gates` is no member of a preset' "a preset holds a gate"

again preset-exception
printf '\nexceptions:\n  known-failing:\n    requirement: no-case-lost\n    item: {case_id: case-0042}\n    reason: The fix is planned.\n    owner: story:case-0042\n    expires: 2027-01-31\n' >> "$c/$conf"
refused '`exceptions` is no member of a preset' "a preset holds an exception"

again preset-binding
printf '\npresets:\n  inner:\n    use: known-failures@1\n    digest: sha256:0000\n' >> "$c/$conf"
refused '`presets` is no member of a preset' "a preset binds a preset"

again preset-project
swap "$conf" '  conformance:' '  conformance:\n    project: orders-api'
refused '`assessments.conformance.project` is the `project` of an entry' "an assessment of a preset states a project"

again preset-local-input
swap "$conf" '    report: {type: path, required: true}' '    report: {type: path, required: true, local: true}'
refused 'the input `report` is local, and a preset declares no local input' "an input of a preset is local"

# -- the inputs of a preset ----------------------------------------------------------------------

# Thirteen references, each at a path of its own in one copy, and an input of a declaration.
copy input-undeclared
swap "$conf" "$passes" '      report: ${inputs.reports}'
refused 'refers to the input `reports`, which the preset does not declare' "an assessment refers to the input reports"

again input-beside-text
swap "$differ" "$passes" '      report: target/${inputs.report}'
refused '`assessments.comparison.inputs.report` holds `${` or `{inputs.` and is not `${inputs.<name>}` alone' "a reference stands beside text"

again input-with-a-space
swap "$conf" '    subject: ${inputs.subject}' '    subject: $ {inputs.subject}'
refused '`assessments.conformance.subject` holds `${` or `{inputs.` and is not `${inputs.<name>}` alone' "a reference has a space after its dollar sign"

again input-in-double-braces
swap "$known" '      list: ${inputs.list}' '      list: "{{inputs.list}}"'
refused '`assessments.known-failures.inputs.list` holds `${` or `{inputs.` and is not `${inputs.<name>}` alone' "a reference is written in double braces"

again input-in-declaration
swap "$conf_d" 'command: conformance-report' 'command: ${inputs.command}'
refused 'refers to the input `command`, and only a preset declares inputs to refer to' "a declaration refers to an input"

again input-scalar-for-list
swap "$conf" '      environments: ${inputs.environments}' '      environments: ${inputs.report}'
refused 'takes a list (`List<ratchet.specification.TargetClass>`), and the input `report` declares no `list`' "the classes of a target are one path"

again input-list-for-scalar
swap "$conf" '      selection: candidate' '      selection: ${inputs.environments}'
refused '`assessments.conformance.target.selection` takes one value' "the selection of a target is a list input"

again input-for-mapping
swap "$conf" "$set_rule" '    condition: ${inputs.subject}'
refused '`requirements.no-case-lost.condition` is a `ratchet.specification.Condition`, and an input stands for a scalar or a list of scalars' "a condition is a reference"

again input-text-for-decimal
swap "$differ" "$limit" '      value: ${inputs.subject}'
refused 'takes `Decimal`, and the input `subject` has the type `string`' "the limit of a condition is a text input"

again input-text-for-integer
swap "$conf" '      kind: snapshot' '      kind: snapshot\n      runs: ${inputs.subject}'
refused 'takes `Integer`, and the input `subject` has the type `string`' "the runs of an observation are a text input"

again input-integer-for-text
swap "$differ" '    subject: ${inputs.subject}' '    subject: ${inputs.different_limit}'
refused 'takes `ratchet.specification.SubjectName`, and the input `different_limit` has the type `integer`' "the subject of an assessment is an integer input"

# An input of the type `conditions` stands as the whole value of `observation.conditions`, and
# only a preset declares one.
again conditions-input-at-a-scalar
swap "$known" '    environments: {type: string, list: true, required: true}' '    environments: {type: string, list: true, required: true}\n    conditions: {type: conditions, required: true}'
swap "$known" '      kind: snapshot' '      kind: snapshot\n      conditions: {all: {runner: "${inputs.conditions}"}}'
refused '`assessments.known-failures.observation.conditions.all.runner` takes `String`, and the input `conditions` has the type `conditions`' "the runner of a class is a conditions input"

again conditions-input-in-a-declaration
swap "$known_d" '  list: {type: path, required: true}' '  list: {type: path, required: true}\n  machine: {type: conditions, required: false}'
refused '`inputs.machine` has the type `conditions`, and only a preset declares an input of the type `conditions`' "a declaration declares an input of the type conditions"

# An input with `values` stands at the place of an enum only where each value is a variant.
again input-values-outside-enum
swap "$conf" '    report: {type: path, required: true}' '    report: {type: path, required: true}\n    way: {type: string, required: true, values: [lower, sideways]}'
swap "$conf" '        better: higher' '        better: ${inputs.way}'
refused '`assessments.conformance.measurements.passed.better` takes `ratchet.specification.Direction`, and the input `way` lists the value `sideways`, which is no value of ratchet.specification.Direction' "an input whose values hold sideways stands at better"

copy input-in-preset-block
swap "$conf" '    subject: {type: string, required: true}' '    subject: {type: "${inputs.subject}", required: true}'
refused '`preset.inputs.subject.type` is a reference inside the `preset` block' "the type of an input is a reference"

copy input-text-for-boolean
own_spec
edit_spec specification.yaml '
  /^  - name: / { t = $3 }
  t == "ratchet.specification.AssessmentPlan" && $0 == "        type: ratchet.specification.SubjectName" { print "        type: Boolean"; next }
  { print }'
refused 'takes `Boolean`, and the input `subject` has the type `string`' "the specification makes the subject of a plan a boolean, and the presets pass a text input"

# Five defaults of five inputs in one copy, and in a second two more of two of those inputs and
# the default of an input with `values`.
copy input-default-integer
swap "$differ" '    different_limit: {type: integer, required: true}' '    different_limit: {type: integer, required: true, default: banana}'
refused '`preset.inputs.different_limit.default` is no integer, and its input has the type `integer`' "the default of an integer input is a word"

again input-default-boolean
swap "$differ" '    subject: {type: string, required: true}' '    subject: {type: string, required: true}\n    strict: {type: boolean, required: false, default: "true"}'
refused '`preset.inputs.strict.default` is not `true` or `false`, and its input has the type `boolean`' "the default of a boolean input is the text \"true\""

again input-default-text
swap "$conf" '    subject: {type: string, required: true}' '    subject: {type: string, required: true, default: 3}'
refused '`preset.inputs.subject.default` is no text, and its input has the type `string`' "the default of a text input is the integer 3"

again input-default-no-list
swap "$conf" '    environments: {type: string, list: true, required: true}' '    environments: {type: string, list: true, required: true, default: ci}'
refused '`preset.inputs.environments.default` is no list, and its input has the type a list of `string`' "the default of a list input is one word"

again input-default-list-for-scalar
swap "$conf_d" '  report: {type: path, required: true}' '  report: {type: path, required: true, default: [report.json]}'
refused '`inputs.report.default` is a list and no scalar, and its input has the type `path`' "the default of a path input of a declaration is a list"

copy input-default-decimal
swap "$differ" '    different_limit: {type: integer, required: true}' '    different_limit: {type: decimal, required: true, default: 1e3}'
refused '`preset.inputs.different_limit.default` is no decimal without exponent' "the default of a decimal input is 1e3"

again input-default-item
swap "$conf" '    environments: {type: string, list: true, required: true}' '    environments: {type: string, list: true, required: true, default: [ci, 3]}'
refused '`preset.inputs.environments.default` holds an item that is no text' "the default of a list of text holds the integer 3"

again input-default-outside-values
swap "$known" '    environments: {type: string, list: true, required: true}' '    environments: {type: string, list: true, required: true}\n    direction: {type: string, required: false, values: [lower, higher], default: sideways}'
refused '`preset.inputs.direction.default` is `sideways`, which is none of the values `[lower, higher]` of the input `direction`' "the default of an input is none of its values"

# -- names inside a preset -----------------------------------------------------------------------

# Four names in four requirements of one copy.
copy name-assessment
swap "$conf" '    assessment: conformance' '    assessment: conformances'
refused '`requirements.no-case-lost` names the assessment `conformances`, which the preset does not hold' "a requirement names the assessment conformances"

again name-measurement
swap "$conf" '    measurement: passed' '    measurement: passing'
refused '`requirements.passed-does-not-fall` names the measurement `passing`, which the assessment `conformance` does not hold' "a requirement names the measurement passing"

again name-no-measurement
drop "$conf" "$of_failed"
refused '`requirements.failed-does-not-rise` names no measurement, and the assessment `conformance` holds 5' "a requirement names no measurement of an assessment with five"

again name-statement
swap "$conf" "$meaning_skipped" "$meaning_skipped"'\n    serves: [nothing]'
refused '`requirements.skipped-does-not-rise` serves the statement `nothing`, which the preset does not hold' "a requirement serves a statement the preset does not hold"

# The three names are written out: a reference is refused where it stands.
copy name-assessment-by-reference
swap "$conf" '    assessment: conformance' '    assessment: ${inputs.subject}'
refused '`requirements.no-case-lost.assessment` is a reference, and the name by which a requirement names an assessment, a measurement or a statement of its preset is written out' "a requirement names its assessment by an input"

again name-measurement-by-reference
swap "$conf" '    measurement: passed' '    measurement: ${inputs.subject}'
refused '`requirements.passed-does-not-fall.measurement` is a reference, and the name by which a requirement names an assessment, a measurement or a statement of its preset is written out' "a requirement names its measurement by an input"

again name-statement-by-reference
swap "$conf" "$meaning_failed" "$meaning_failed"'\n    serves: ["${inputs.subject}"]'
refused '`requirements.failed-does-not-rise.serves[1]` is a reference, and the name by which a requirement names an assessment, a measurement or a statement of its preset is written out' "a requirement serves a statement that an input names"

# -- a preset against the declaration of its assessor -------------------------------------------

copy assessor-absent
rm "$c/$conf_d"
refused 'names the assessor `conformance-report@1`, and the directory holds no `conformance-report@1.assessor.yaml`' "the declaration of conformance-report@1 is absent"

# The joins of a plan, of the input it passes and of a measurement are apart from each other
# (each is one `if` of the check). The three copies below hold one defect in a plan, in the
# one input of a plan and in a measurement, and no two in the same.
copy assessor-target-kind
swap "$conf" '      kind: revision' '      kind: deployment'
refused '`assessments.conformance.target.kind` is `deployment`, and `conformance-report@1` declares the targets `[revision]`' "a plan has a target of the kind deployment"

again assessor-input
swap "$conf" "$passes" '      reports: ${inputs.report}'
refused 'passes the input `reports`, which `conformance-report@1` does not declare' "an assessment passes the input reports"

again assessor-input-absent
swap "$conf_d" '  report: {type: path, required: true}' '  report: {type: path, required: true}\n  suite: {type: string, required: true}'
refused '`assessments.conformance` passes no `suite`, which `conformance-report@1` requires' "a declaration requires an input the assessment does not pass"

again assessor-input-type
swap "$differ" "$passes" '      report: ${inputs.different_limit}'
refused 'passes the input `different_limit` of the preset, `integer`, and `comparison-report@1` declares the input `report` as `path`' "an assessment passes an integer input where a path is declared"

again assessor-input-list
swap "$known" '      list: ${inputs.list}' '      list: ${inputs.environments}'
refused 'passes the input `environments` of the preset, a list of `string`, and `case-list@1` declares the input `list` as `path`' "an assessment passes a list input where one path is declared"

again assessor-output
swap "$conf" '        output: passing_cases' '        output: passing'
refused 'names the output `passing`, which `conformance-report@1` does not declare' "a measurement names the output passing"

again assessor-kind
swap "$conf" '        kind: exact' '        kind: sampled' 3
refused '`assessments.conformance.measurements.failed` has the kind `sampled`, and the output `failed` of `conformance-report@1` declares `exact`' "a measurement of an exact output has the kind sampled"

again assessor-unit-other
swap "$conf" '        unit: cases' '        unit: case'
refused 'states the unit `case`, and the output `passed` of `conformance-report@1` declares `cases`' "a measurement has the unit case"

# The second `unit: cases` that is left is the unit of `skipped`.
again assessor-unit-absent
drop "$conf" '        unit: cases' 2
refused 'has no `unit`, and the output `skipped` of `conformance-report@1` declares `cases`' "a measurement of a count has no unit"

again assessor-scope
swap "$conf" '        scope: run' '        scope: case' 5
refused 'has the scope `case`, which the output `refused` of `conformance-report@1` does not declare' "a measurement has the scope case"

again assessor-identity-key
swap "$known" '        identity: [case_id]' '        identity: [case_id, suite]'
refused 'states the identity key `[case_id, suite]`, and the output `cases` of `case-list@1` declares `[case_id]`' "a measurement has the identity key case_id and suite"

again assessor-filter-field
swap "$differ" '        filter: {class: [different]}' '        filter: {result: [different]}'
refused 'filters by the field `result`, which the output `cases` of `comparison-report@1` does not declare for its items' "a measurement filters by the field result"

again assessor-condition
swap "$conf" '      kind: snapshot' '      kind: snapshot\n      conditions: {all: {moon_phase: full}}'
refused '`assessments.conformance.observation.conditions.all.moon_phase` is the condition `moon_phase`, which is none of Ratchet itself, and `conformance-report@1` declares the conditions `[]`' "a plan states a condition that its assessor does not declare"

# The cache condition has one name, `cache_profile`, the member of the record
# (spec/domains/specification.yaml, ObservationConditions). The declaration lists `cache` and
# the plan writes it: both are refused, though the declaration lists what the plan writes.
copy assessor-cache-condition
swap "$conf_d" 'conditions: []' 'conditions: [cache]'
swap "$conf" '      kind: snapshot' '      kind: snapshot\n      conditions: {all: {cache: warm}}'
refused '`conditions[1]` is the condition `cache`; a declaration writes the cache condition as `cache_profile` and under no other name' "a declaration lists the condition cache"
refused '`assessments.conformance.observation.conditions.all.cache` is the condition `cache`; a plan writes the cache condition as `cache_profile` and under no other name' "a plan states the condition cache that its assessor declares"

# An exact measurement aggregates with `sum` or not at all (docs/design.md § 3, the table of the
# two kinds). The set is exact, an identity set, and declares the median.
copy exact-aggregation
swap "$differ" '        filter: {class: [different]}' '        filter: {class: [different]}\n        aggregation: {kind: median}'
refused '`assessments.comparison.measurements.different-cases` is exact and aggregates with `median`; an exact measurement aggregates with `sum` or not at all' "an exact identity set aggregates with median"

# The sum is the one aggregation of an exact measurement: the number `failed` declares it.
copy valid-exact-sum
swap "$conf" '        output: failed' '        output: failed\n        aggregation: {kind: sum}'
accepts "an exact number that aggregates with sum"

# An input of a declaration takes no name that Ratchet passes itself
# (docs/evidence-format.md § 10, "Reserved names").
copy declaration-reserved-input
swap "$conf_d" '  report: {type: path, required: true}' '  report: {type: path, required: true}\n  out: {type: path, required: false}'
refused '`inputs.out` has the name of a reserved argument, which Ratchet passes itself' "a declaration has the input out"

# A `filter` names values that the declaration lists for its field under `item_values`
# (docs/evidence-format.md § 10). A field without such a list stays open: any value is read.
copy assessor-filter-value
swap "$differ_d" '    item_fields: [class]' '    item_fields: [class]\n    item_values: {class: [equal, allowed, different]}'
swap "$differ" '        filter: {class: [different]}' '        filter: {class: [diferent]}'
refused '`assessments.comparison.measurements.different-cases.filter.class` filters the field `class` by the value `diferent`, which is none of the values `[equal, allowed, different]` that the output `cases` of `comparison-report@1` declares for it' "a filter names the value diferent of a field whose values the declaration lists"

again declaration-item-values-field
swap "$differ_d" '    item_values: {class: [equal, allowed, different]}' '    item_values: {class: [equal, allowed, different], severity: [low, high]}'
refused '`outputs.cases.item_values.severity` lists the values of the field `severity`, which the output `cases` does not name under `item_fields` [class]' "a declaration lists the values of a field that is none of its item fields"

copy valid-filter-open-field
swap "$differ" '        filter: {class: [different]}' '        filter: {class: [diferent]}'
accepts "a filter names the value diferent of a field that the declaration declares without a list of values"

copy assessor-input-local
swap "$conf_d" '  report: {type: path, required: true}' '  report: {type: path, required: true, local: true}'
refused 'passes the input `report`, which `conformance-report@1` declares local' "an assessment passes an input its assessor declares local"

again assessor-input-type-in-a-list
swap "$differ_d" '  report: {type: path, required: true}' '  report: {type: path, required: true}\n  exclude: {type: string, list: true, required: false}'
swap "$differ" "$passes" '      report: ${inputs.report}\n      exclude: ["${inputs.subject}", "${inputs.different_limit}"]'
refused '`assessments.comparison.inputs.exclude` holds an item that is the input `different_limit` of the preset, `integer`, and `comparison-report@1` declares the input `exclude` as a list of `string`' "an assessment passes a list of text with an integer input as one item"

again assessor-input-literal
swap "$known" '      list: ${inputs.list}' '      list: 3'
refused '`assessments.known-failures.inputs.list` is no text, and `case-list@1` declares the input `list` as `path`' "an assessment passes the integer 3 where a path is declared"

again plan-literal-outside-values
swap "$known_d" '  list: {type: path, required: true}' '  list: {type: path, required: true}\n  mode: {type: string, required: false, values: [strict, lenient]}'
swap "$known" '    inputs:' '    inputs:\n      mode: loose'
refused '`assessments.known-failures.inputs.mode` is `loose`, which is none of the values `[strict, lenient]` that `case-list@1` declares for the input `mode`' "a plan passes a word that is none of the values of the input of its assessor"

again assessor-unit-undeclared
swap "$conf" '        identity: [case_id]' '        identity: [case_id]\n        unit: cases'
refused 'states the unit `cases`, and the output `passing_cases` of `conformance-report@1` declares none' "a measurement of a set has a unit"

again assessor-boundary
swap "$conf" '        output: failed' '        output: failed\n        boundary: request_start_to_response_complete'
refused 'has the boundary `request_start_to_response_complete`, which the output `failed` of `conformance-report@1` does not declare' "a measurement has a boundary that is none of Ratchet itself, on an output that declares no boundaries"

again assessor-identity-of-a-number
swap "$conf" '        output: skipped' '        output: skipped\n        identity: [case_id]'
refused 'states an identity key, and the output `skipped` of `conformance-report@1` declares none' "a measurement of a number states an identity key"

again assessor-pass-rate-of-a-number
swap "$conf" '        output: refused' '        output: refused\n        aggregation: {kind: pass_rate}'
refused '`assessments.conformance.measurements.refused` aggregates with `pass_rate`, which takes an assertion, and the output `refused` of `conformance-report@1` has the value type `number`' "a measurement aggregates a number with pass_rate"

again assessor-target-kind-by-default
swap "$conf" '    subject: {type: string, required: true}' '    subject: {type: string, required: true}\n    target_kind: {type: string, required: false, default: deployment}'
swap "$conf" '      kind: revision' '      kind: ${inputs.target_kind}'
refused '`assessments.conformance.target.kind` is `deployment`, the default of the input `target_kind`, and `conformance-report@1` declares the targets `[revision]`' "the kind of a target is an input whose default the declaration does not take"

again assessor-population-field
swap "$conf" '      kind: snapshot' '      kind: time_window\n      window: {last: 20}\n      population: {filter: {service: orders-api}}\n      min_samples: 10'
refused '`assessments.conformance.observation.population.filter.service` filters the population by the field `service`, and `conformance-report@1` declares the population fields `[]` (`population_field_mismatch`)' "a plan filters its population by a field that its assessor does not declare"

rate_copy assessor-kind-of-an-assertion-without-rate
swap "$conf" '        aggregation: {kind: pass_rate}' '        aggregation: {kind: median}'
refused '`assessments.conformance.measurements.pass-rate` has the kind `sampled`, and the output `all_pass` of `conformance-report@1` declares `exact` (`kind_mismatch`)' "a sampled measurement of an exact assertion aggregates with median and not with pass_rate"

again assessor-boundary-not-listed
swap "$conf_d" "$number_output" '  failed: {value_type: number, kind: exact, scopes: [], unit: cases, boundaries: [request_start_to_response_complete]}'
swap "$conf" '        output: failed' '        output: failed\n        boundary: run_time'
refused 'has the boundary `run_time`, which the output `failed` of `conformance-report@1` does not declare' "a measurement has the boundary run_time on an output that declares its boundaries without it"

again assessor-input-list-of-its-type
swap "$conf" '    report: {type: path, required: true}' '    report: {type: path, list: true, required: true}'
refused 'passes the input `report` of the preset, a list of `path`, and `conformance-report@1` declares the input `report` as `path`' "an assessment passes a list of paths where one path is declared"

again assessor-input-list-in-a-list
swap "$differ_d" '  report: {type: path, required: true}' '  report: {type: path, required: true}\n  exclude: {type: string, list: true, required: false}'
swap "$differ" "$passes" '      report: ${inputs.report}\n      exclude: ["${inputs.environments}"]'
refused '`assessments.comparison.inputs.exclude` holds an item that is the input `environments` of the preset, a list, and `comparison-report@1` declares the input `exclude` as a list of `string`' "an assessment passes a list of text with a list input as one item"

# -- a count of the coverage as a measurement ----------------------------------------------------
#
# `coverage.<count>` is an output of Ratchet itself: the count of the run's coverage, for a
# count that the declaration lists under `coverage`, an exact number at the scope `run` without
# a unit (docs/design.md § 3 "Evidence coverage"). conformance-report@1 lists all six counts,
# comparison-report@1 four, without `passed`.

# add_count <file> <preset> <assessment> <measurement> <kind> <output> <scope> [<line>]: a
# measurement of the plan, before the map `requirements` of the file, with its row; <line> is
# a further key of the measurement, such as `unit: cases`.
add_count() {
  swap "$1" 'requirements:' "      $4:\n        kind: $5\n        output: $6\n        scope: $7${8:+\n        $8}\n\nrequirements:"
  add_row "| \`$2/$3/$4\` | Higher | None | 0 | Ratchet, the count \`${6#coverage.}\` of the coverage |"
}

copy coverage-count-measurement
add_count "$conf" conformance-cases@1 conformance executed exact coverage.executed run 'better: higher'
printf '  executed-does-not-fall:\n    meaning: The number of executed cases is not below the accepted number.\n    assessment: conformance\n    measurement: executed\n    reference: {kind: accepted_value}\n' >> "$c/$conf"
accepts "a requirement executed-does-not-fall on the count executed of the coverage, with better: higher and an accepted value"

copy coverage-count-not-listed
add_count "$differ" differential-equality@1 comparison passed-cases exact coverage.passed run
refused '`assessments.comparison.measurements.passed-cases` names the output `coverage.passed`, and `comparison-report@1` lists the counts `[executed, skipped, not_run, unsupported]` under `coverage`, not `passed`' "a coverage count the declaration does not list"

again coverage-count-with-unit
add_count "$conf" conformance-cases@1 conformance executed-in-cases exact coverage.executed run 'unit: cases'
refused '`assessments.conformance.measurements.executed-in-cases` states the unit `cases`, and the coverage count `coverage.executed` has none (`unit_not_declared`)' "a coverage count with a unit"

again coverage-count-sampled
add_count "$conf" conformance-cases@1 conformance sampled-skipped sampled coverage.skipped run
refused '`assessments.conformance.measurements.sampled-skipped` has the kind `sampled`, and the coverage count `coverage.skipped` is `exact` (`kind_mismatch`)' "a coverage count that is sampled"

again coverage-count-no-count
add_count "$conf" conformance-cases@1 conformance passed-ids exact coverage.passed_ids run
refused '`assessments.conformance.measurements.passed-ids` names the output `coverage.passed_ids`, and `passed_ids` is no count of the coverage' "a coverage name that is no count"

again coverage-count-scope
add_count "$conf" conformance-cases@1 conformance not-run-per-case exact coverage.not_run case
refused '`assessments.conformance.measurements.not-run-per-case` has the scope `case`, and the coverage count `coverage.not_run` has the scope `run` alone' "a coverage count at another scope than run"

# -- the inputs that hold the observation --------------------------------------------------------
#
# A declaration names under `observation_inputs` the input that Ratchet passes the value of a
# key of the plan's `observation` as (docs/evidence-format.md § 10, "Invocation"). The plan
# writes that value once, under `observation`, and passes nothing to the input under `inputs`.
# A declaration writes `observation_inputs` at its end, where `outputs` ends.

copy observation-input-passed-twice
swap "$conf_d" '  report: {type: path, required: true}' '  report: {type: path, required: true}\n  workload: {type: string, required: true}'
printf 'observation_inputs: {workload: workload}\n' >> "$c/$conf_d"
swap "$conf" '      kind: snapshot' '      kind: snapshot\n      workload: ${inputs.subject}'
swap "$conf" "$passes" "$passes"'\n      workload: ${inputs.subject}'
refused '`assessments.conformance.inputs.workload` passes the input `workload`, which `conformance-report@1` takes from the key `workload` of the plan'"'"'s `observation` (`observation_inputs`)' "a plan passes under inputs the input that its assessor takes from observation.workload"

again observation-input-absent
swap "$differ_d" '  report: {type: path, required: true}' '  report: {type: path, required: true}\n  runs: {type: integer, required: true}'
printf 'observation_inputs: {runs: runs}\n' >> "$c/$differ_d"
refused '`assessments.comparison` has no `observation.runs`, which `comparison-report@1` passes as its required input `runs` (`observation_inputs`)' "a declaration takes a required input from observation.runs, and the plan has no runs"

copy observation-input-undeclared
printf 'observation_inputs: {workload: workload}\n' >> "$c/$conf_d"
refused '`observation_inputs.workload` names the input `workload`, which the declaration does not declare under `inputs`' "a declaration takes from observation.workload an input it does not declare"

again observation-input-key
swap "$differ_d" '  report: {type: path, required: true}' '  report: {type: path, required: true}\n  warmup: {type: integer, required: false}'
printf 'observation_inputs: {warmup: warmup}\n' >> "$c/$differ_d"
refused '`observation_inputs.warmup` is no key of the observation that Ratchet passes (ratchet.assessor.ObservationKey: ' "a declaration takes an input from the key warmup, which is no observation key"

# A declaration names under `revision_inputs` the inputs whose file states the revision it was
# produced from (docs/evidence-format.md § 10, "The revision"); each is one of its inputs.
again revision-input-undeclared
printf 'revision_inputs: [lists]\n' >> "$c/$known_d"
refused '`revision_inputs[1]` names the input `lists`, which the declaration does not declare under `inputs`' "a declaration lists under revision_inputs an input it does not declare"

# -- a window over the runs of another plan ------------------------------------------------------

window_copy series-without-runs-of
swap "$known" '      population: {runs_of: known-failures, from: trusted_revision}' '      population: {filter: {service: orders-api}}'
refused '`assessments.size-over-runs` names the assessor `record-series@1` and has no `observation.population.runs_of`' "a plan names record-series@1 and reads no runs of another plan"

window_copy series-other-assessor
swap "$known" '    assessor: record-series@1' '    assessor: case-list@1'
refused '`assessments.size-over-runs` reads the runs of another plan (`observation.population.runs_of`) and names the assessor `case-list@1`' "a plan over the runs of another plan names case-list@1"

again series-with-selection
swap "$known" '    target: {kind: revision, environments: "${inputs.environments}"}' '    target: {kind: revision, environments: "${inputs.environments}", selection: candidate}'
refused '`assessments.size-over-runs` reads the runs of another plan (`observation.population.runs_of`) and has a `target.selection`' "a plan over the runs of another plan has a target selection"

again series-with-conditions
swap "$known" '      min_samples: 10' '      min_samples: 10\n      conditions: {ci: {runner: ci-standard}}'
refused '`assessments.size-over-runs` reads the runs of another plan (`observation.population.runs_of`) and declares `observation.conditions`' "a plan over the runs of another plan declares conditions"

window_copy series-with-input
swap "$known" '    assessor: record-series@1' '    assessor: record-series@1\n    inputs:\n      list: ${inputs.list}'
refused '`assessments.size-over-runs.inputs.list` passes the input `list`, and `record-series@1` takes no input' "a plan of record-series@1 passes an input"

copy series-declared
printf 'format: ratchet-assessor/1\nname: record-series\nversion: "1"\ncommand: record-series\ntargets: [revision]\nconditions: []\ncoverage_unit: entry\ncoverage: [executed]\noutputs:\n  size: {value_type: number, kind: exact, scopes: [], unit: cases}\n' > "$c/record-series@1.assessor.yaml"
refused 'record-series@1.assessor.yaml:1: the file declares `record-series@1`, the assessor of Ratchet itself' "the directory holds a declaration of record-series@1"

# -- a sampled measurement -----------------------------------------------------------------------
#
# The set holds no sampled measurement. Each copy takes the pass rate of `add_rate` or the
# window of `add_window`, which the copy `valid-plans` holds unchanged, and takes one thing out.

rate_copy sampled-without-conditions
drop "$conf" '      conditions: {all: {runner: ci-standard}}'
refused '`assessments.conformance.measurements.pass-rate` is sampled, and the plan `conformance` declares no condition' "a plan with a sampled measurement declares no conditions"

again sampled-without-tolerance
drop "$conf" '      tolerance: {absolute: 0.05}'
refused '`requirements.pass-rate-holds` compares the sampled measurement `pass-rate` with an accepted value and has no tolerance' "a requirement compares a sampled measurement with an accepted value and has no tolerance"

again sampled-without-adoption
drop "$conf" '      adoption: {from: trusted_revision, runs: 10, aggregation: {kind: median}}'
refused '`requirements.pass-rate-holds` compares the sampled measurement `pass-rate` with an accepted value and has no `reference.adoption`' "a requirement compares a sampled measurement with an accepted value and has no adoption"

rate_copy sampled-with-a-class-without-condition
swap "$conf" '      conditions: {all: {runner: ci-standard}}' '      conditions: {all: {}}'
refused '`assessments.conformance.measurements.pass-rate` is sampled, and the plan `conformance` declares no condition' "a plan with a sampled measurement declares a class of conditions that holds none"

again sampled-with-an-empty-tolerance
swap "$conf" '      tolerance: {absolute: 0.05}' '      tolerance: {}'
refused '`requirements.pass-rate-holds` compares the sampled measurement `pass-rate` with an accepted value and has no tolerance' "a requirement on a sampled measurement has a tolerance without a percent and without an absolute band"

# A window over the runs of another plan declares no conditions, and its requirement is under
# the two rules of the reference all the same: its plan has no declaration to be read.
again sampled-window-without-tolerance
add_window
drop "$known" '      tolerance: {percent: 10}'
refused '`requirements.median-size-does-not-rise` compares the sampled measurement `median` with an accepted value and has no tolerance' "a requirement on a window over runs has an accepted value and no tolerance"

again sampled-window-without-adoption
drop "$known" '      adoption: {from: trusted_revision, runs: 4, aggregation: {kind: median}}'
refused '`requirements.median-size-does-not-rise` compares the sampled measurement `median` with an accepted value and has no `reference.adoption`' "a requirement on a window over runs has an accepted value and no adoption"

# A sampled measurement of a plan whose `runs` is a literal above 1 states an aggregation, or
# `over_all_runs: true`, a value the assessor computes over all runs of the plan
# (docs/design.md § 3, the row "Aggregation" and "One run per candidate is valid").
runs_copy sampled-runs-without-aggregation
swap "$conf" '      runs: 3' '      runs: 2'
refused '`assessments.conformance.measurements.step-time` is sampled, and the plan `conformance` has `runs: 2` and the measurement states neither an `aggregation` nor `over_all_runs: true`' "a sampled measurement of a plan with runs: 2 states no aggregation"

# A plan of one run needs neither: its measurement may state no aggregation, or one, when the
# command repeats its measurement itself within the run (docs/design.md § 3, "One run per
# candidate is valid").
runs_copy valid-one-run
swap "$conf" '      runs: 3' '      runs: 1'
accepts "a sampled measurement of a plan with runs: 1 that states no aggregation and no over_all_runs"

runs_copy valid-one-run-with-aggregation
swap "$conf" '      runs: 3' '      runs: 1'
swap "$conf" '        unit: s' '        unit: s\n        aggregation: {kind: median}'
accepts "a sampled measurement of a plan with runs: 1 that aggregates with median"

# An `over_all_runs` that an input gives is not read: the binding passes it.
runs_copy valid-over-all-runs-by-input
swap "$conf" '    environments: {type: string, list: true, required: true}' '    environments: {type: string, list: true, required: true}\n    all_runs: {type: boolean, required: true}'
swap "$conf" '        unit: s' '        unit: s\n        over_all_runs: "${inputs.all_runs}"'
accepts "a sampled measurement of a plan with runs: 3 whose over_all_runs an input gives, without an aggregation"

# A value over all runs is no aggregation: a measurement states one of the two.
runs_copy sampled-over-all-runs-and-aggregation
swap "$conf" '        unit: s' '        unit: s\n        over_all_runs: true\n        aggregation: {kind: median}'
refused '`assessments.conformance.measurements.step-time` states `over_all_runs: true` and an `aggregation`' "a sampled measurement states over_all_runs and an aggregation"

runs_copy valid-over-all-runs
swap "$conf" '        unit: s' '        unit: s\n        over_all_runs: true'
accepts "a sampled measurement of a plan with runs: 3 that states over_all_runs: true and no aggregation"

# -- a requirement against the value type of its output -----------------------------------------
#
# The comparison is checked a requirement at a time. The two copies below hold one defect in a
# requirement, and where a requirement holds two, the two are apart in the check and each has
# its own message. The comments say which line `$accepted_value` is left to be the n-th.

copy compare-holds-on-a-set
swap "$conf" "$set_rule" '    condition: {operator: holds}'
refused '`requirements.no-case-lost` has the operator `holds`, which takes an assertion, and the output `passing_cases` of `conformance-report@1` has the value type `identity_set`' "a requirement on a set has the operator holds"

# the third is the reference of `failed-does-not-rise`
again compare-set-operator-on-a-number
swap "$conf" "$accepted_value" '    condition: {operator: no_new_items}' 3
refused '`requirements.failed-does-not-rise` has the operator `no_new_items`, which takes an identity set, and the output `failed` of `conformance-report@1` has the value type `number`' "a requirement on a number has the operator no_new_items"

# then of `skipped-does-not-rise`
again compare-limit-without-value
swap "$conf" "$accepted_value" '    condition: {operator: lte}' 3
refused '`requirements.skipped-does-not-rise` has the operator `lte` and no `value`' "a requirement with lte has no value"

# then of `refused-does-not-rise`
again compare-unit-other
swap "$conf" "$accepted_value" '    condition: {operator: lte, value: 3, unit: seconds}' 3
refused '`requirements.refused-does-not-rise` has a condition in the unit `seconds`, and the output `refused` of `conformance-report@1` declares `cases`' "a condition has another unit than its output"

# the second is the reference of `passed-does-not-fall`
again compare-reference-of-a-number
swap "$conf" "$accepted_value" '    reference: {kind: generated}' 2
refused '`requirements.passed-does-not-fall` has the reference `generated`, and the output `passed` of `conformance-report@1` has the value type `number`, which takes `accepted_value`' "a requirement on a number has the reference generated"

again compare-limit-on-an-assertion
swap "$differ_d" '    value_type: identity_set' '    value_type: assertion'
refused '`requirements.different-cases-within-limit` has the operator `lte`, which takes a number or the number of items of a set, and the output `cases` of `comparison-report@1` has the value type `assertion`' "a requirement with lte reads an output that is an assertion"

again compare-unit-undeclared
swap "$differ" "$limit" "$limit"'\n      unit: cases'
refused '`requirements.different-cases-within-limit` has a condition in the unit `cases`, and the output `cases` of `comparison-report@1` declares none' "a condition on the number of items of a set has a unit"

again compare-set-operator-without-reference
drop "$known" "$accepted_value"
refused '`requirements.no-new-known-failure` has the operator `no_new_items` and no reference of the kind `accepted_value`' "a requirement with no_new_items has no reference"

again compare-number-without-better
drop "$known" '        better: lower'
refused '`assessments.known-failures.measurements.size` states no `better`, and `requirements.size-does-not-rise` compares it with a reference' "a number that is compared with a reference states no better"

# The two rules that read that there is a reference, and not its kind, hold where an input
# gives the kind: the first two cases of this copy.
copy compare-set-without-condition-by-reference-input
drop "$conf" "$set_rule"
swap "$conf" "$accepted_value" '    reference: {kind: "${inputs.subject}"}'
refused '`requirements.no-case-lost` compares a set with a reference and has no condition' "a requirement on a set has no operator and a reference whose kind an input gives"

# the first that is left is the reference of `passed-does-not-fall`
again compare-number-without-better-by-reference-input
drop "$conf" '        better: higher'
swap "$conf" "$accepted_value" '    reference: {kind: "${inputs.subject}"}'
refused '`assessments.conformance.measurements.passed` states no `better`, and `requirements.passed-does-not-fall` compares it with a reference' "a number without better is compared with a reference whose kind an input gives"

# then of `failed-does-not-rise`
again compare-unit-absent
swap "$conf" "$accepted_value" '    condition: {operator: lte, value: 3}'
refused '`requirements.failed-does-not-rise` has a condition without a `unit`, and the output `failed` of `conformance-report@1` declares `cases`' "a condition on an output with a unit has none"

again compare-reference-of-an-assertion
swap "$conf_d" '  skipped: {value_type: number, kind: exact, scopes: [], unit: cases}' '  skipped: {value_type: assertion, kind: exact, scopes: [], unit: cases}'
refused '`requirements.skipped-does-not-rise` has a reference, and the output `skipped` of `conformance-report@1` has the value type `assertion`, which takes none' "a requirement with a reference reads an output that is an assertion"

again compare-reference-of-a-digest
swap "$conf_d" '  refused: {value_type: number, kind: exact, scopes: [], unit: cases}' '  refused: {value_type: digest, kind: exact, scopes: [], unit: cases}'
refused '`requirements.refused-does-not-rise` has the reference `accepted_value`, and the output `refused` of `conformance-report@1` has the value type `digest`, which takes `generated`' "a requirement with an accepted value reads an output that is a digest"

again compare-condition-on-a-digest
swap "$differ_d" '    value_type: identity_set' '    value_type: digest'
refused '`requirements.different-cases-within-limit` has a condition without a `digest`, and the output `cases` of `comparison-report@1` has the value type `digest`, which takes `eq` with a `digest`' "a requirement with a condition reads an output that is a digest"

again compare-value-without-limit
swap "$known" '    condition: {operator: no_new_items}' '    condition: {operator: no_new_items, value: 3}'
refused '`requirements.no-new-known-failure` has the operator `no_new_items`, which takes no `value`' "a requirement with no_new_items has a value"

copy compare-set-without-condition
drop "$conf" "$set_rule"
refused '`requirements.no-case-lost` compares a set with a reference and has no condition' "a requirement on a set has a reference and no operator"

# A limit on the items of a filtered set: `eq` with the value 0 and no reference, at the end of
# differential-equality@1, where the map `requirements` ends.
copy compare-eq-zero-on-filtered-set
printf '  no-different-case:\n    meaning: No case is different.\n    assessment: comparison\n    measurement: different-cases\n    condition: {operator: eq, value: 0}\n' >> "$c/$differ"
accepts "a requirement with eq and the value 0 on a set filtered by a field of its items, without a reference"

# The source of a limit and of a band: prose for a reader, which no rule reads. The third
# reference is that of `failed-does-not-rise`.
copy condition-and-tolerance-with-source
swap "$conf" "$accepted_value" '    condition: {operator: lte, value: 3, unit: cases, source: {cites: decision:x}}\n    reference:\n      kind: accepted_value\n      tolerance: {absolute: 1, source: {cites: decision:x, since: 2026-03-01}}' 3
accepts "a condition and a tolerance that each state their source"

# A digest is compared with `eq` and a `digest`. The copies make the output `refused` of
# `conformance-report@1` a digest without a unit, and `refused-does-not-rise`, the fifth
# requirement of conformance-cases@1, compares it. case-list@1 is no file to edit here:
# known-failures@2 names it too.
digest_output='  refused: {value_type: digest, kind: exact, scopes: []}'
pinned='sha256:9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08'
number_refused='  refused: {value_type: number, kind: exact, scopes: [], unit: cases}'
# digest_copy <case>: a fresh copy whose measurement `refused` reads a digest.
digest_copy() {
  copy "$1"
  swap "$conf_d" "$number_refused" "$digest_output"
  drop "$conf" '        unit: cases' 4
  drop "$conf" '        better: lower' 3
}

digest_copy compare-digest-eq
swap "$conf" "$accepted_value" '    condition: {operator: eq, digest: "'"$pinned"'"}' 5
accepts "a requirement on a digest output with the operator eq and a digest"

digest_copy compare-digest-with-lt
swap "$conf" "$accepted_value" '    condition: {operator: lt, digest: "'"$pinned"'"}' 5
refused '`requirements.refused-does-not-rise` has the operator `lt`, and the output `refused` of `conformance-report@1` has the value type `digest`, which takes `eq` with a `digest`' "a digest condition with the operator lt"

# the third is the reference of `failed-does-not-rise`
again compare-digest-on-a-number
swap "$conf" "$accepted_value" '    condition: {operator: eq, digest: "'"$pinned"'", unit: cases}' 3
refused '`requirements.failed-does-not-rise` has a condition with a `digest`, and the output `failed` of `conformance-report@1` has the value type `number`, which takes no `digest`' "a digest condition on a number output"

digest_copy compare-value-on-a-digest
swap "$conf" "$accepted_value" '    condition: {operator: eq, value: "'"$pinned"'"}' 5
refused '`requirements.refused-does-not-rise` has a `value`, and the output `refused` of `conformance-report@1` has the value type `digest`, which is compared with a `digest` and takes no `value`' "a value on a digest output"

# A range is `within` with `min` and `max`. The copies hold the plan of `add_runs`, whose
# measurement `step-time` reads a number in `s`, with the median of its runs, and add a
# requirement on it at the end of conformance-cases@1, where the map `requirements` ends.
# add_range <requirement> <condition>: that requirement on `step-time`.
add_range() {
  printf '  %s:\n    meaning: The median time of the step is in its range.\n    assessment: conformance\n    measurement: step-time\n    condition: %s\n' "$1" "$2" >> "$c/$conf"
}
# range_copy <case>: a fresh copy with the plan of `add_runs` and the median of `step-time`.
range_copy() {
  runs_copy "$1"
  swap "$conf" '        unit: s' '        unit: s\n        aggregation: {kind: median}'
}

range_copy compare-within
add_range step-time-in-range '{operator: within, min: 50, max: 60, unit: s}'
accepts "a requirement on a number in s with the operator within, min 50 and max 60"

range_copy compare-range-with-a-value
add_range range-with-value '{operator: within, min: 50, max: 60, value: 55, unit: s}'
refused '`requirements.range-with-value` has the operator `within`, which takes `min` and `max` and no `value`' "a range with a value"

again compare-range-without-max
add_range range-without-max '{operator: within, min: 50, unit: s}'
refused '`requirements.range-without-max` has the operator `within` and no `max`, its upper bound' "a range without max"

again compare-min-on-lte
add_range min-on-lte '{operator: lte, value: 60, min: 50, unit: s}'
refused '`requirements.min-on-lte` has a `min`, and the operator `lte`: `min` and `max` stand on `within` alone' "min on the operator lte"

again compare-range-min-above-max
add_range min-above-max '{operator: within, min: 60, max: 50, unit: s}'
refused '`requirements.min-above-max` has the operator `within` with the `min` 60 above the `max` 50' "a range whose min is above its max"

# the median of `step-time` is in `s`, and `failed` counts `cases`
again compare-against-two-units
add_range two-units '{operator: lte, against: {assessment: conformance, measurement: failed}, unit: s}'
refused '`requirements.two-units` has `against` `assessments.conformance.measurements.failed` in the unit `cases`, and the output `duration` of `conformance-report@1` declares `s` (`against_unit_mismatch`)' "against compares two units"

# the median of `step-time` is in `s`, and its value is adopted from `failed`, which counts
# `cases`
again adoption-other-unit
printf '  adopted-in-cases:\n    meaning: The median time of the step is not above the adopted value.\n    assessment: conformance\n    measurement: step-time\n    condition: {operator: lte, value: 60, unit: s}\n    reference:\n      kind: accepted_value\n      tolerance: {percent: 10}\n      adoption: {from: assessment, assessment: conformance, measurement: failed}\n' >> "$c/$conf"
refused '`requirements.adopted-in-cases` adopts from `assessments.conformance.measurements.failed` in the unit `cases`, and the output `duration` of `conformance-report@1` declares `s`' "an adoption from another assessment in another unit"

# A requirement over two measurements: `against` names a measurement of another plan of the
# preset. The copies give conformance-report@1 the set `failing_cases` and known-failures@1 a
# second plan, `suite`, that reads it as `failing-cases`, with its row.
suite_plan='  suite:\n    subject: ${inputs.subject}\n    assessor: conformance-report@1\n    inputs:\n      report: ${inputs.report}\n    target:\n      kind: revision\n      environments: ${inputs.environments}\n      selection: candidate\n    observation:\n      kind: snapshot\n    measurements:\n      failing-cases:\n        kind: exact\n        output: failing_cases\n        scope: run\n        identity: [case_id]\n\nrequirements:'
# subset_copy <case>: a fresh copy with the plan `suite` in known-failures@1.
subset_copy() {
  copy "$1"
  printf '  failing_cases:\n    value_type: identity_set\n    kind: exact\n    scopes: []\n    identity_key: [case_id]\n' >> "$c/$conf_d"
  swap "$known" '    list: {type: path, required: true}' '    list: {type: path, required: true}\n    report: {type: path, required: true}'
  swap "$known" 'requirements:' "$suite_plan"
  add_row '| `known-failures@1/suite/failing-cases` | Lower: the set gains no case | None: a set of case ids | 0, no input | `conformance-report@1`, output `failing_cases` |'
}
# add_compare <requirement> <assessment> <measurement> <condition>: that requirement at the end
# of known-failures@1, where the map `requirements` ends.
add_compare() {
  printf '  %s:\n    meaning: The two measurements compare.\n    assessment: %s\n    measurement: %s\n    condition: %s\n' "$1" "$2" "$3" "$4" >> "$c/$known"
}

subset_copy compare-subset-of
add_compare every-failed-case-listed suite failing-cases '{operator: subset_of, against: {assessment: known-failures, measurement: listed-cases}}'
accepts "the failing cases of one plan subset_of the listed cases of another plan of the preset, through against"

subset_copy compare-against-set-and-number
add_compare set-and-number suite failing-cases '{operator: subset_of, against: {assessment: known-failures, measurement: size}}'
refused '`requirements.set-and-number` has `against` `assessments.known-failures.measurements.size` of the value type `number`, and the output `failing_cases` of `conformance-report@1` has the value type `identity_set` (`against_value_type_mismatch`)' "against compares a set with a number"

again compare-against-assessment-not-held
add_compare not-held suite failing-cases '{operator: subset_of, against: {assessment: nowhere, measurement: cases}}'
refused '`requirements.not-held` has `against` the assessment `nowhere`, which the preset does not hold' "against names an assessment the preset does not hold"

again compare-against-without-measurement
add_compare without-measurement suite failing-cases '{operator: subset_of, against: {assessment: known-failures}}'
refused '`requirements.without-measurement` has `against` the assessment `known-failures` and names no measurement of it, and the assessment holds 2' "against names no measurement of an assessment with two"

again compare-against-measurement-not-held
add_compare measurement-not-held suite failing-cases '{operator: subset_of, against: {assessment: known-failures, measurement: unlisted-cases}}'
refused '`requirements.measurement-not-held` has `against` the measurement `unlisted-cases`, which the assessment `known-failures` does not hold' "against names a measurement its assessment does not hold"

again compare-subset-of-without-against
add_compare without-against suite failing-cases '{operator: subset_of}'
refused '`requirements.without-against` has the operator `subset_of` and no `against`, the set it is compared with' "subset_of without against"

again compare-subset-of-on-a-number
add_compare on-a-number known-failures size '{operator: subset_of, against: {assessment: known-failures, measurement: size}, unit: cases}'
refused '`requirements.on-a-number` has the operator `subset_of`, which takes an identity set, and the output `count` of `case-list@1` has the value type `number`' "subset_of on a number output"

# A reference adopted from the evidence of another plan (docs/design.md § 5 "The ratchet
# policy"): `adoption: {from: assessment, assessment: <plan>, measurement: <measurement>}`.
# The copies of `subset_copy` hold two plans of known-failures@1 whose sets have the value
# type `identity_set` and no unit.
# add_adopt <requirement> <assessment> <measurement> <condition> <adoption>: that requirement
# at the end of known-failures@1, with a reference of the kind `accepted_value`.
add_adopt() {
  printf '  %s:\n    meaning: The set keeps to its adopted value.\n    assessment: %s\n    measurement: %s\n    condition: %s\n    reference:\n      kind: accepted_value\n      adoption: %s\n' "$1" "$2" "$3" "$4" "$5" >> "$c/$known"
}

subset_copy adoption-other-assessment
add_adopt adopted-from-the-list suite failing-cases '{operator: no_new_items}' '{from: assessment, assessment: known-failures, measurement: listed-cases}'
accepts "the accepted set of the failing cases of one plan is adopted from the listed cases of another plan of the preset"

subset_copy adoption-other-value-type
add_adopt adopted-from-a-number suite failing-cases '{operator: no_new_items}' '{from: assessment, assessment: known-failures, measurement: size}'
refused '`requirements.adopted-from-a-number` adopts from `assessments.known-failures.measurements.size` of the value type `number`, and the output `failing_cases` of `conformance-report@1` has the value type `identity_set`' "an adoption from a measurement of another value type"

again adoption-assessment-not-held
add_adopt adopted-from-nowhere suite failing-cases '{operator: no_new_items}' '{from: assessment, assessment: nowhere, measurement: cases}'
refused '`requirements.adopted-from-nowhere` adopts from the assessment `nowhere`, which the preset does not hold' "an adoption from an assessment the preset does not hold"

again adoption-measurement-not-held
add_adopt adopted-from-unlisted suite failing-cases '{operator: no_new_items}' '{from: assessment, assessment: known-failures, measurement: unlisted-cases}'
refused '`requirements.adopted-from-unlisted` adopts from the measurement `unlisted-cases`, which the assessment `known-failures` does not hold' "an adoption from a measurement its assessment does not hold"

again adoption-without-measurement
add_adopt adopted-without-measurement suite failing-cases '{operator: no_new_items}' '{from: assessment, assessment: known-failures}'
refused '`requirements.adopted-without-measurement` has an adoption `from: assessment` and names no `measurement`' "an adoption from an assessment without a measurement"

again adoption-without-assessment
add_adopt adopted-without-assessment suite failing-cases '{operator: no_new_items}' '{from: assessment, measurement: listed-cases}'
refused '`requirements.adopted-without-assessment` has an adoption `from: assessment` and names no `assessment`' "an adoption from an assessment that names none"

again adoption-assessment-on-trusted-revision
add_adopt adopted-from-trusted suite failing-cases '{operator: no_new_items}' '{from: trusted_revision, runs: 1, assessment: known-failures, measurement: listed-cases}'
refused '`requirements.adopted-from-trusted` has an adoption with `assessment`, and `from: trusted_revision`: `assessment` and `measurement` stand on `from: assessment` alone' "an adoption from the trusted revision that names an assessment"

# -- rows ----------------------------------------------------------------------------------------

copy row-absent
edit "$page" "$the_row"' { next } { print }'
refused 'the measurement `conformance-cases@1/conformance/skipped` has no row on a page of the directory' "the page has no row for a measurement"

copy row-of-no-measurement
edit "$page" "$the_row"' { sub(/conformance\/skipped/, "conformance/ignored") } { print }'
refused 'the row `conformance-cases@1/conformance/ignored` names no measurement of a preset of the directory' "a row names a measurement that no preset holds"

copy row-twice
edit "$page" "$the_row"' { print } { print }'
refused 'the measurement `conformance-cases@1/conformance/skipped` has 2 rows' "a measurement has two rows"

copy row-direction-empty
cell 2 ' '
refused 'the cell `Direction` of the row `conformance-cases@1/conformance/skipped` is empty' "the direction of a row is empty"

again row-unit-empty
cell 3 ''
refused 'the cell `Unit` of the row `conformance-cases@1/conformance/skipped` is empty' "the unit of a row is empty"

again row-tolerance-empty
cell 4 '  '
refused 'the cell `Tolerance` of the row `conformance-cases@1/conformance/skipped` is empty' "the tolerance of a row is empty"

again row-evidence-empty
cell 5 ' '
refused 'the cell `Evidence` of the row `conformance-cases@1/conformance/skipped` is empty' "the evidence of a row is empty"

copy row-cell-no-break-space
cell 3 ' \302\240 '
refused 'the cell `Unit` of the row `conformance-cases@1/conformance/skipped` is empty' "the unit of a row is a no-break space"

copy row-cell-tab
cell 3 ' \t '
refused 'the cell `Unit` of the row `conformance-cases@1/conformance/skipped` is empty' "the unit of a row is a tab"

copy row-cell-html-comment
cell 3 ' <!-- --> '
refused 'the cell `Unit` of the row `conformance-cases@1/conformance/skipped` is empty' "the unit of a row is an HTML comment"

copy row-ends-with-escaped-bar
edit "$page" "$the_row"' { print substr($0, 1, length($0) - 1) "\\|"; next } { print }'
refused 'functional.md:44: a row does not end with `|`' 'the last bar of a row is written `\|`'

copy row-in-code-fence
edit "$page" "$the_row"' { row = $0; next } { print } END { printf "\n```text\n'"$table"'%s\n```\n", row }'
refused 'the measurement `conformance-cases@1/conformance/skipped` has no row on a page of the directory' "the row of a measurement stands in a code fence"

copy row-in-tilde-fence
edit "$page" "$the_row"' { row = $0; next } { print } END { printf "\n~~~\n'"$table"'%s\n~~~\n", row }'
refused 'the measurement `conformance-cases@1/conformance/skipped` has no row on a page of the directory' "the row of a measurement stands in a code fence of tildes"

copy row-in-html-comment
edit "$page" "$the_row"' { row = $0; next } { print } END { printf "\n<!--\n'"$table"'%s\n-->\n", row }'
refused 'the measurement `conformance-cases@1/conformance/skipped` has no row on a page of the directory' "the row of a measurement stands in an HTML comment"

# A fence closes at a run of its character that is at least as long, indented by at most
# three spaces, with nothing but spaces and tabs after it (CommonMark).
copy row-in-a-longer-fence
edit "$page" "$the_row"' { row = $0; next } { print } END { printf "\n````markdown\n```\n'"$table"'%s\n````\n", row }'
refused 'the measurement `conformance-cases@1/conformance/skipped` has no row on a page of the directory' "the row of a measurement stands in a fence of four backticks, after a line of three"

copy row-in-a-longer-tilde-fence
edit "$page" "$the_row"' { row = $0; next } { print } END { printf "\n~~~~markdown\n~~~\n'"$table"'%s\n~~~~\n", row }'
refused 'the measurement `conformance-cases@1/conformance/skipped` has no row on a page of the directory' "the row of a measurement stands in a fence of four tildes, after a line of three"

copy row-after-indented-fence-line
edit "$page" "$the_row"' { row = $0; next } { print } END { printf "\n```markdown\n    ```\n'"$table"'%s\n```\n", row }'
refused 'the measurement `conformance-cases@1/conformance/skipped` has no row on a page of the directory' "the row of a measurement stands in a fence, after a line of three backticks that is indented by four spaces"

copy row-after-fence-line-with-text
edit "$page" "$the_row"' { row = $0; next } { print } END { printf "\n```markdown\n``` and text\n'"$table"'%s\n```\n", row }'
refused 'the measurement `conformance-cases@1/conformance/skipped` has no row on a page of the directory' "the row of a measurement stands in a fence, after a line of three backticks with text after them"

# Four forms that are valid, in one copy: `\|` is a bar of the text of a cell and no border of
# a cell; a fence closes at a run of its character that is at least as long, indented by at
# most three spaces, with nothing but spaces and tabs after it (CommonMark), and the table
# after it is read; a row follows an HTML comment that ends on its line; and `<!--` inside a
# code span that closes on its line is text of the page.
copy row-forms-that-are-valid
cell 4 ' 0 \\| none '
edit "$page" "$the_row"' { row = $0; next } { print } END { printf "\n````markdown\n```\n| a line of the example |\n   `````  \n\n'"$table"'%s\n", row }'
edit "$page" "$the_row"' { print "<!-- " $0 " -->" $0; next } { print }'
edit "$page" 'NR == 3 { print "The mark `<!--` in a code span opens no comment, and `` ` <!-- `` in a longer span opens none."; print "" } { print }'
accepts 'a cell of a row holds `\|`, the row follows a fence of four backticks that holds a line of three and closes at a line of five, indented by three spaces, with spaces after it, the row follows an HTML comment that ends on its line, and the page holds the mark of a comment in two code spans before its tables'

copy row-after-comment-mark-behind-a-lone-backtick
edit "$page" 'NR == 3 { print "A lone ` closes no code span, and <!-- after it opens a comment."; print "" } { print }'
refused 'the measurement `conformance-cases@1/conformance/skipped` has no row on a page of the directory' "the page holds a backtick that opens no code span and the mark of a comment after it, before its tables"

copy row-on-another-page
edit "$page" "$the_row"' { next } { print }'
{
  printf '# Other\n\n'"$table"
  grep -F '| `conformance-cases@1/conformance/skipped` |' "$set_dir/$page"
} > "$c/other.md"
refused 'stands on another page than the rows of its preset' "one row of a preset stands on a second page"

copy row-header
swap "$page" '| Measurement | Direction | Unit | Tolerance | Evidence |' '| Criterion | Direction | Unit | Tolerance | Evidence |'
refused 'the measurement `conformance-cases@1/conformance/passing-cases` has no row on a page of the directory' "the header of a table starts with Criterion"

copy row-rule-line
swap "$page" '| --- | --- | --- | --- | --- |' '| a | b | c | d | e |'
refused 'the line under the header of a table is no `| --- | ... |`' "the line under a header is a row of words"

copy row-not-closed
edit "$page" "$the_row"' { sub(/ \|$/, "") } { print }'
refused 'functional.md:44: a row does not end with `|`' "a row does not end with a bar"

copy row-six-cells
edit "$page" "$the_row"' { print $0 " more |"; next } { print }'
refused 'functional.md:44: a row has 6 cells' "a row has six cells"

copy row-name-without-backticks
edit "$page" "$the_row"' { sub(/`conformance-cases@1\/conformance\/skipped`/, "*conformance-cases@1/conformance/skipped*") } { print }'
refused 'functional.md:44: the first cell of a row is `*conformance-cases@1/conformance/skipped*`' "the name of a row stands between asterisks"

copy page-without-table
printf '# Notes\n\nA page that lists no measurement.\n' > "$c/notes.md"
refused 'notes.md:1: the page holds no table with the header' "a page of the directory holds no table"

copy page-without-row
printf '# Notes\n\n'"$table" > "$c/notes.md"
refused 'notes.md:1: the tables of the page hold no row' "a page of the directory holds a table without a row"

result
