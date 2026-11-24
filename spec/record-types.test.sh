#!/bin/sh
# Every field row of docs/evidence-format.md § 3 (`ratchet-evidence/1`) and § 10
# (`ratchet-assessor/1`) is declared in spec/domains/ at the place, in the type and with the
# optionality the row gives, and every declared field of a struct the rows describe has a row.
#
# spec/record-fields.test.sh checks the name of a row against a type its own table names. This
# script names no type: it walks the path of a row from the root of the document
# (`ratchet.evidence.AssessmentRun` for § 3, `ratchet.assessor.Assessor` for § 10) through the
# declared field types, so a member that is declared and hangs under another type, or is declared
# with another type or optionality than its row says, fails here.
#
# A row is checked three ways:
#   place        the path `<table>.<field>` resolves field by field from the root; `x[]` is an
#                element of the list `x`, `<name>` a value of a map
#   optionality  `yes` in the column Required is a field that is not `Optional<...>`; every other
#                cell is one that is. The three tables "A result of the value type ..." describe
#                one flat struct, so each of their own rows is `Optional<...>`.
#   type         the column Type against the declared type (the table `class_of` below)
# And once per struct: a field the specification declares and no row names is reported, because
# a reader of version 1 rejects a member of `evidence` it does not know (§ 1).
#
# Exit 0: the last line is
#   `record-types: <n> of <n> field rows as declared, <m> of <m> declared fields have a row`.
# Exit 1: each row or field that fails is named; a table or a Type cell this script has no rule
# for fails too, and is never counted as checked.
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
doc=$root/docs/evidence-format.md

[ -r "$doc" ] || { echo "record-types: cannot read docs/evidence-format.md" >&2; exit 1; }
for f in "$root"/spec/domains/*.yaml; do
  [ -r "$f" ] || { echo "record-types: cannot read spec/domains/*.yaml" >&2; exit 1; }
done

awk '
  function unopt(t) { return (t ~ /^Optional</) ? substr(t, 10, length(t) - 10) : t }
  function base(t) { while (kind[t] == "newtype") t = of[t]; return t }
  function is_text(t) { t = base(t); return t == "String" || kind[t] == "enum" }
  function is_struct(t) { return kind[t] == "struct" || kind[t] == "entity" }
  function fail(msg) { print msg; failed++ }

  # The declared type of the member a path names, from the type `t`; "" when a step does not
  # resolve. `why` is set to the reason, `holder` to the struct that declares the last field.
  function walk(t, path,    n, i, steps, s, list, f) {
    n = split(path, steps, ".")
    for (i = 1; i <= n; i++) {
      s = steps[i]
      t = unopt(t)
      if (s == "<name>") {
        if (t !~ /^Map<String, /) { why = "`" t "` is not a map"; return "" }
        t = substr(t, 13, length(t) - 13)
        continue
      }
      list = 0
      if (s ~ /\[\]$/) { list = 1; s = substr(s, 1, length(s) - 2) }
      if (!is_struct(t)) { why = "`" t "` is not a struct"; return "" }
      if (!((t SUBSEP s) in ftype)) { why = "`" s "` is not a field of " t; return "" }
      holder = t; f = s
      seen[t SUBSEP s] = 1; described[t] = 1
      t = ftype[t SUBSEP s]
      if (list) {
        t = unopt(t)
        if (t !~ /^List</) { why = "`" s "` is `" t "`, not a list"; return "" }
        t = substr(t, 6, length(t) - 6)
      }
    }
    last_field = f
    return t
  }

  # Does the declared type `t` (without Optional) fit the cell of the column Type?
  # 1 yes, 0 no, -1 no rule for the cell.
  function fits(cell, t,    e) {
    if (cell == "text") return is_text(t)
    if (cell == "count") return t == "Integer"
    if (cell == "decimal") return t == "Decimal"
    if (cell == "boolean") return t == "Boolean"
    if (cell == "time") return t == "Timestamp"
    if (cell == "duration") return t == "Duration"
    if (cell == "digest") return t == "ratchet.evidence.Digest"
    if (cell == "any JSON") return t == "Json"
    if (cell == "text, count, boolean, or a list of these") return t == "Json"
    if (cell == "object") return is_struct(t) || t == "Json" || t ~ /^Map<String, /
    if (cell == "list of text") {
      if (t !~ /^List</) return 0
      e = substr(t, 6, length(t) - 6)
      return is_text(e)
    }
    if (cell == "list" || cell == "list of results") return t ~ /^List</
    if (cell ~ /^map from .* to text$/ || cell == "map from a tool to its version") {
      return t == "Map<String, String>"
    }
    if (cell ~ /^map from /) return t ~ /^Map<String, /
    return -1
  }

  # spec/domains/*.yaml: the kind of every type, and the type of every field.
  FILENAME != DOC {
    if ($0 ~ /^entities:/) { in_entities = 1; next }
    if ($0 ~ /^types:/) { in_entities = 0; next }
    if ($0 ~ /^  - name: /) {
      type = $3; in_fields = 0; field = ""
      kind[type] = in_entities ? "entity" : ""
      next
    }
    if ($0 ~ /^    kind: / && !in_entities) { kind[type] = $2; next }
    if ($0 ~ /^    of: /) { of[type] = $2; next }
    if ($0 ~ /^    fields:/) { in_fields = 1; next }
    if ($0 ~ /^    [a-z_]+:/) { in_fields = 0; next }
    if (in_fields && $0 ~ /^      - name: /) { field = $3; order[type, ++count[type]] = field; next }
    if (in_fields && field != "" && $0 ~ /^        type: /) {
      t = $0; sub(/^        type: /, "", t)
      ftype[type SUBSEP field] = t
    }
    next
  }

  # docs/evidence-format.md: § 3 and § 10 only.
  /^## / {
    section = 0
    if ($0 ~ /^## 3\. /) { section = 3; doc_root = "ratchet.evidence.AssessmentRun" }
    if ($0 ~ /^## 10\. /) { section = 10; doc_root = "ratchet.assessor.Assessor" }
    in_table = 0
  }
  section == 0 { next }
  /^#/ || /:$/ { label = $0; in_table = 0; next }
  /^\| Field \| Type \| Required \|/ {
    in_table = 1; flat = 0; known = 1
    if (section == 3 && label == "### Top level") prefix = ""
    else if (section == 3 && label ~ /^### `[^`]+`$/) { prefix = label; gsub(/^### `|`$/, "", prefix); prefix = prefix "." }
    else if (section == 3 && label ~ /^A result of the value type /) { prefix = "evidence.results[]."; flat = 1 }
    else if (section == 10 && label ~ /^### Declaration `ratchet-assessor\/1`$/) prefix = ""
    else if (section == 10 && label == "An output, `outputs.<name>`:") prefix = "outputs.<name>."
    else { fail("no rule: the field table under \"" label "\" has no path in spec/record-types.test.sh"); known = 0 }
    next
  }
  !/^\|/ { in_table = 0; next }
  in_table && !/^\| --- / {
    rows++
    if (!known) next
    n = split($0, cell, / *\| */)
    name = cell[2]; type_cell = cell[3]; required = cell[4]
    if (name !~ /^`[^`]+`$/) { fail("no rule: the row \"" name "\" under \"" label "\" names no field"); next }
    gsub(/`/, "", name)
    path = prefix name
    why = ""
    declared_type = walk(doc_root, path)
    if (declared_type == "") { fail("place: `" path "` does not resolve from " doc_root ": " why); next }
    optional = (declared_type ~ /^Optional</)
    own_row_of_flat = (flat && name !~ /\./)
    want_optional = (required != "yes" || own_row_of_flat)
    bad = 0
    if (want_optional && !optional) {
      fail("optionality: `" path "` is Required \"" required "\" and " holder "." last_field " is `" declared_type "`, not Optional"); bad = 1
    }
    if (!want_optional && optional) {
      fail("optionality: `" path "` is Required \"yes\" and " holder "." last_field " is `" declared_type "`"); bad = 1
    }
    fit = fits(type_cell, unopt(declared_type))
    if (fit < 0) { fail("no rule: the Type cell \"" type_cell "\" of `" path "` has no rule in spec/record-types.test.sh"); bad = 1 }
    if (fit == 0) { fail("type: `" path "` is \"" type_cell "\" and " holder "." last_field " is `" declared_type "`"); bad = 1 }
    if (!bad) good++
  }

  END {
    if (rows == 0) { print "record-types: no field row found in docs/evidence-format.md"; exit 1 }
    for (t in described) {
      for (i = 1; i <= count[t]; i++) {
        fields++
        if (!((t SUBSEP order[t, i]) in seen)) {
          fail("no row: " t "." order[t, i] " is declared and docs/evidence-format.md has no row for it")
        } else documented++
      }
    }
    if (failed > 0) {
      printf "record-types: %d of %d field rows as declared, %d of %d declared fields have a row, %d failure(s)\n", good, rows, documented, fields, failed
      exit 1
    }
    printf "record-types: %d of %d field rows as declared, %d of %d declared fields have a row\n", rows, rows, fields, fields
  }
' DOC="$doc" "$root"/spec/domains/*.yaml "$doc"
