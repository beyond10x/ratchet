#!/bin/sh
# Every field row of docs/evidence-format.md § 3 (`ratchet-evidence/1`) and § 10
# (`ratchet-assessor/1`) is declared in spec/domains/evidence.yaml or spec/domains/assessor.yaml,
# under the name the row gives, in the type § 8 of that document maps its table to.
#
# Exit 0: every row is declared; the last line is `record-fields: <n> of <n> field rows declared`.
# Exit 1: a row is not declared (each is named), a table has no mapping here, or § 3 holds
# another number of rows than its own sentence "There are <n> fields" says.
#
# A field table is a table whose header starts `| Field | Type | Required |`. Its label is the
# nearest heading, or line ending in a colon, above it. A new table needs a line in `map` below
# and its type in the specification; without the line this script fails.
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
doc=$root/docs/evidence-format.md
evidence=$root/spec/domains/evidence.yaml
assessor=$root/spec/domains/assessor.yaml

for f in "$doc" "$evidence" "$assessor"; do
  [ -r "$f" ] || { echo "record-fields: cannot read ${f#"$root"/}" >&2; exit 1; }
done

awk '
  function map(label, type) { type_of[label] = type }
  function nested(label, prefix, type) { nested_of[label SUBSEP prefix] = type; prefixes[prefix] = 1 }

  BEGIN {
    # docs/evidence-format.md § 3
    map("### Top level", "ratchet.evidence.AssessmentRun")
    map("### `evidence`", "ratchet.evidence.Evidence")
    map("### `evidence.target`", "ratchet.evidence.ResolvedTarget")
    map("### `evidence.target.window`", "ratchet.evidence.Window")
    map("### `evidence.inputs.<name>`", "ratchet.evidence.ResolvedInput")
    map("### `evidence.conditions`", "ratchet.evidence.ObservedConditions")
    nested("### `evidence.conditions`", "host_load_per_cpu.", "ratchet.evidence.HostLoad")
    map("### `evidence.coverage`", "ratchet.evidence.EvidenceCoverage")
    nested("### `evidence.coverage`", "not_executed[].", "ratchet.evidence.NotExecutedUnit")
    map("### `evidence.results[]`", "ratchet.evidence.MeasurementResult")
    nested("### `evidence.results[]`", "incomplete.", "ratchet.evidence.Incomplete")
    map("A result of the value type `number`:", "ratchet.evidence.MeasurementResult")
    map("A result of the value type `identity_set`:", "ratchet.evidence.MeasurementResult")
    nested("A result of the value type `identity_set`:", "items[].", "ratchet.evidence.IdentityItem")
    map("A result of the value type `digest` or `assertion`:", "ratchet.evidence.MeasurementResult")
    map("### `evidence.source`", "ratchet.evidence.ImportSource")
    map("### `run`", "ratchet.evidence.RunDetails")
    # docs/evidence-format.md § 10
    map("### Declaration `ratchet-assessor/1`", "ratchet.assessor.Assessor")
    map("An output, `outputs.<name>`:", "ratchet.assessor.AssessorOutput")
    section = 0; rows = 0; missing = 0; broken = 0; stated = -1; counted3 = 0
  }

  # The two domain files: `Type.field` for every entry of a `fields:` list.
  FILENAME != DOC {
    if ($0 ~ /^  - name: /) { type = $3; in_fields = 0; next }
    if ($0 ~ /^    fields:/) { in_fields = 1; next }
    if ($0 ~ /^    [a-z_]+:/) { in_fields = 0; next }
    if (in_fields && $0 ~ /^      - name: /) declared[type "." $3] = 1
    next
  }

  # The document: § 3 and § 10 only.
  /^## / {
    section = 0
    if ($0 ~ /^## 3\. /) section = 3
    if ($0 ~ /^## 10\. /) section = 10
    in_table = 0
  }
  section == 0 { next }
  section == 3 && stated < 0 && match($0, /There are [0-9]+ fields/) {
    stated = substr($0, RSTART + 10, RLENGTH - 17) + 0
  }
  /^#/ || /:$/ { label = $0; in_table = 0; next }
  /^\| Field \| Type \| Required \|/ {
    in_table = 1
    if (!(label in type_of)) {
      printf "no mapping: the field table under \"%s\" has no type in spec/record-fields.test.sh\n", label
      broken = 1; in_table = 0
    }
    next
  }
  !/^\|/ { in_table = 0; next }
  in_table && /^\| `/ {
    field = $0
    sub(/^\| `/, "", field); sub(/`.*$/, "", field)
    type = type_of[label]; name = field
    for (p in prefixes) {
      if (index(field, p) == 1) {
        if ((label SUBSEP p) in nested_of) { type = nested_of[label SUBSEP p]; name = substr(field, length(p) + 1) }
      }
    }
    rows++
    if (section == 3) counted3++
    if (name ~ /[^a-z0-9_]/) {
      printf "no mapping: `%s` under \"%s\" is nested and has no type in spec/record-fields.test.sh\n", field, label
      broken = 1; next
    }
    if (!((type "." name) in declared)) {
      printf "missing: `%s` (%s) is not declared as %s.%s\n", field, label, type, name
      missing++
    }
  }

  END {
    if (rows == 0) { print "record-fields: no field row found in docs/evidence-format.md"; exit 1 }
    if (stated != counted3) {
      printf "record-fields: § 3 says \"There are %d fields\" and its tables hold %d rows\n", stated, counted3
      broken = 1
    }
    if (missing > 0 || broken) {
      printf "record-fields: %d of %d field rows declared, %d missing\n", rows - missing, rows, missing
      exit 1
    }
    printf "record-fields: %d of %d field rows declared\n", rows, rows
  }
' DOC="$doc" "$evidence" "$assessor" "$doc"
