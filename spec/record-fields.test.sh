#!/bin/sh
# Every field row of docs/evidence-format.md § 3 (`ratchet-evidence/1`), § 10
# (`ratchet-assessor/1`) and § 12 (`ratchet-proof/1`) is declared in spec/domains/evidence.yaml
# or spec/domains/assessor.yaml, under the name the row gives, in the type § 8 of that document
# maps its table to (§ 12 names its type itself).
#
# Exit 0: every row is declared; the last line is `record-fields: <n> of <n> field rows declared`.
# Exit 1: a row is not declared (each is named), a table has no mapping here, § 3, § 10 or § 12
# is not found, a table named below is not found or holds another number of rows than its line
# states, or § 3 holds another number of rows than its own sentence "There are <n> fields" says.
#
# A field table is a table whose header starts `| Field | Type | Required |`. Its label is the
# nearest heading, or line ending in a colon, above it. A new table needs a line in `map` below
# and its type in the specification; without the line this script fails. A `map` line states the
# number of rows of its table: 82 in the 13 tables of § 3, 23 in the 2 tables of § 10 and 7 in
# the 1 table of § 12. A section that moves to another number, a header that changes, or a row
# that is added, deleted or written without its backticks changes a count, and the script fails
# until the line here says the new number.
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
doc=$root/docs/evidence-format.md
evidence=$root/spec/domains/evidence.yaml
assessor=$root/spec/domains/assessor.yaml

for f in "$doc" "$evidence" "$assessor"; do
  [ -r "$f" ] || { echo "record-fields: cannot read ${f#"$root"/}" >&2; exit 1; }
done

awk '
  # map(section, label, type, rows): the table under `label` in that section describes `type`
  # and holds `rows` field rows.
  function map(sec, label, type, n) {
    type_of[label] = type; section_of[label] = sec; want[label] = n; labels[++nlabels] = label
  }
  function nested(label, prefix, type) { nested_of[label SUBSEP prefix] = type; prefixes[prefix] = 1 }

  BEGIN {
    # docs/evidence-format.md § 3: 82 rows in 13 tables
    map(3, "### Top level", "ratchet.evidence.AssessmentRun", 3)
    map(3, "### `evidence`", "ratchet.evidence.Evidence", 12)
    map(3, "### `evidence.target`", "ratchet.evidence.ResolvedTarget", 6)
    map(3, "### `evidence.target.window`", "ratchet.evidence.Window", 5)
    map(3, "### `evidence.inputs.<name>`", "ratchet.evidence.ResolvedInput", 4)
    map(3, "### `evidence.conditions`", "ratchet.evidence.ObservedConditions", 8)
    nested("### `evidence.conditions`", "host_load_per_cpu.", "ratchet.evidence.HostLoad")
    map(3, "### `evidence.coverage`", "ratchet.evidence.EvidenceCoverage", 13)
    nested("### `evidence.coverage`", "not_executed[].", "ratchet.evidence.NotExecutedUnit")
    map(3, "### `evidence.results[]`", "ratchet.evidence.MeasurementResult", 11)
    nested("### `evidence.results[]`", "incomplete.", "ratchet.evidence.Incomplete")
    map(3, "A result of the value type `number`:", "ratchet.evidence.MeasurementResult", 6)
    map(3, "A result of the value type `identity_set`:", "ratchet.evidence.MeasurementResult", 4)
    nested("A result of the value type `identity_set`:", "items[].", "ratchet.evidence.IdentityItem")
    map(3, "A result of the value type `digest` or `assertion`:", "ratchet.evidence.MeasurementResult", 2)
    map(3, "### `evidence.source`", "ratchet.evidence.ImportSource", 2)
    map(3, "### `run`", "ratchet.evidence.RunDetails", 6)
    # docs/evidence-format.md § 10: 23 rows in 2 tables
    map(10, "### Declaration `ratchet-assessor/1`", "ratchet.assessor.Assessor", 14)
    map(10, "An output, `outputs.<name>`:", "ratchet.assessor.AssessorOutput", 9)
    # docs/evidence-format.md § 12: 7 rows in 1 table
    map(12, "### Fields of `ratchet-proof/1`", "ratchet.evidence.ProofRecord", 7)
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

  # The document: § 3, § 10 and § 12 only.
  /^## / {
    section = 0
    if ($0 ~ /^## 3\. /) section = 3
    if ($0 ~ /^## 10\. /) section = 10
    if ($0 ~ /^## 12\. /) section = 12
    if (section) found[section] = 1
    in_table = 0
  }
  section == 0 { next }
  section == 3 && stated < 0 && match($0, /There are [0-9]+ fields/) {
    stated = substr($0, RSTART + 10, RLENGTH - 17) + 0
  }
  /^#/ || /:$/ { label = $0; in_table = 0; next }
  /^\| Field \| Type \| Required \|/ {
    in_table = 1
    if (!(label in type_of) || section_of[label] != section) {
      printf "no mapping: the field table under \"%s\" in § %d has no type in spec/record-fields.test.sh\n", label, section
      broken = 1; in_table = 0
    } else tables[label]++
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
    held[label]++
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
    if (!(3 in found)) { print "not found: docs/evidence-format.md has no section \"## 3. \", which holds the fields of `ratchet-evidence/1`"; broken = 1 }
    if (!(10 in found)) { print "not found: docs/evidence-format.md has no section \"## 10. \", which holds the fields of `ratchet-assessor/1`"; broken = 1 }
    if (!(12 in found)) { print "not found: docs/evidence-format.md has no section \"## 12. \", which holds the fields of `ratchet-proof/1`"; broken = 1 }
    for (i = 1; i <= nlabels; i++) {
      l = labels[i]
      if (!(section_of[l] in found)) continue
      if (tables[l] == 0) {
        printf "not found: § %d has no field table under \"%s\", and spec/record-fields.test.sh states %d rows for it\n", section_of[l], l, want[l]
        broken = 1
      } else if (tables[l] > 1) {
        printf "rows: § %d has %d field tables under \"%s\", and spec/record-fields.test.sh states one\n", section_of[l], tables[l], l
        broken = 1
      } else if (held[l] + 0 != want[l]) {
        printf "rows: the field table under \"%s\" holds %d rows, and spec/record-fields.test.sh states %d\n", l, held[l], want[l]
        broken = 1
      }
    }
    if (rows == 0) { print "record-fields: no field row found in docs/evidence-format.md"; exit 1 }
    if (3 in found && stated != counted3) {
      printf "record-fields: § 3 says \"There are %d fields\" and its tables hold %d rows\n", stated, counted3
      broken = 1
    }
    if (missing > 0 || broken) {
      printf "record-fields: %d of %d field rows declared, %d missing%s\n", rows - missing, rows, missing, (broken ? ", and the sections or tables are not as this script states them" : "")
      exit 1
    }
    printf "record-fields: %d of %d field rows declared\n", rows, rows
  }
' DOC="$doc" "$evidence" "$assessor" "$doc"
