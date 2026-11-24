#!/bin/sh
# The JSON examples of docs/evidence-format.md § 6 decode under the specification: every member
# of every example is a field the type at its place declares (spec/domains/*.yaml), with a JSON
# value of the declared type, and every object holds the fields its struct requires.
#
# spec/record-fields.test.sh compares the field tables of § 3 with the specification, and
# nothing compares the examples with either. A rename made in the table and in the
# specification leaves the example behind, and the gate stays green.
#
# What is checked per member, from the root type of its example:
#   place     a member of an object is a declared field of the struct there, a key of a
#             declared map, or lies under a field of the type `Json`. A struct is closed
#             (§ 1: a reader rejects a member of `evidence` it does not know) unless it
#             declares `undeclared_fields: ignored`, as `ratchet.evidence.RunDetails` does
#   type      Integer: a JSON integer. Decimal: text of a decimal number. Boolean: a boolean.
#             String, Timestamp, Duration and a newtype of String: text. An enum: one of its
#             variants. `ratchet.evidence.Digest`: `sha256:` and 64 lowercase hex digits.
#             List: an array. Map and struct: an object. No member is `null`.
#   required  a struct's object has every field that is not `Optional<...>`
# Not checked: the invariants of the types. `ess generate synthesize` writes them as Rust.
#
# The root type of an example is read from its shape: an object with `format` is a
# `ratchet.evidence.AssessmentRun`; an array of objects with `output` is a list of
# `ratchet.evidence.MeasurementResult`; an array of objects with `state` is a list of
# `ratchet.evidence.NotExecutedUnit`. An example of another shape fails.
#
# § 6 holds 3 examples, each a block fenced `json`; `want_examples` below states the number.
# Another number fails, and so does a fenced block of § 6 that is not fenced `json`, because
# this script does not read it, and a document without a section "## 6. ".
#
# Usage:
#   sh spec/record-examples.test.sh                       the examples of § 6
#   sh spec/record-examples.test.sh --json <type> <file>  one JSON file against one type
# Needs `jq`. Work files go to the ignored target/record-examples.
#
# Exit 0: the last line is
#   `record-examples: <n> of <n> members of <b> example(s) decode under the specification`.
# Exit 1: each member that does not decode is named with its example and path; or § 6 is not
# found, holds another number of examples than stated, or holds a fenced block that is not read.
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
doc=$root/docs/evidence-format.md
work=$root/target/record-examples
# The number of examples of docs/evidence-format.md § 6.
want_examples=3

command -v jq > /dev/null 2>&1 || { echo "record-examples: jq is not installed" >&2; exit 1; }

rm -rf "$work"
mkdir -p "$work"
: > "$work/nodes.tsv"

# nodes <label> <root type> <file>: one line per node of the JSON file,
# label, root type, path (steps joined by the unit separator, an index as `[]`), JSON type, and
# for an object its keys, for a scalar its text.
nodes() {
  jq -r --arg label "$1" --arg type "$2" '
    ([], paths) as $p
    | getpath($p) as $v
    | [ $label, $type,
        ($p | map(if type == "number" then "[]" else . end) | join("\u001f")),
        ($v | type),
        ($v | if type == "object" then (keys_unsorted | join("\u001f"))
              elif type == "array" then ""
              else (tostring | gsub("[\t\n\r]"; " ")) end) ]
    | join("\t")
  ' "$3" >> "$work/nodes.tsv"
}

if [ "${1:-}" = "--json" ]; then
  [ $# -eq 3 ] || { echo "usage: record-examples.test.sh --json <type> <file>" >&2; exit 1; }
  [ -r "$3" ] || { echo "record-examples: cannot read $3" >&2; exit 1; }
  nodes "$(basename -- "$3")" "$2" "$3"
  examples=1
else
  [ -r "$doc" ] || { echo "record-examples: cannot read docs/evidence-format.md" >&2; exit 1; }
  # The blocks of § 6: one file per block fenced `json`; a line in unread.txt per block fenced
  # otherwise, and per block that does not close.
  : > "$work/unread.txt"
  : > "$work/section.txt"
  awk -v dir="$work" '
    /^## / {
      if (inside) { printf "the block that opens at line %d does not close inside § 6\n", opened >> (dir "/unread.txt"); close(out); inside = 0 }
      skipping = 0
      section = ($0 ~ /^## 6\. /)
      if (section) print NR > (dir "/section.txt")
    }
    !section { next }
    /^ *(```|~~~)/ {
      if (inside) { if ($0 ~ /^```$/) { close(out); inside = 0 } else print > out; next }
      if (skipping) { skipping = 0; next }
      if ($0 ~ /^```json$/) { n++; out = dir "/example-" n ".json"; printf "" > out; inside = 1; opened = NR; next }
      fence = $0; sub(/^ */, "", fence)
      printf "line %d: a block fenced \"%s\"\n", NR, fence >> (dir "/unread.txt")
      skipping = 1
      next
    }
    inside { print > out }
    END { if (inside) printf "the block that opens at line %d does not close\n", opened >> (dir "/unread.txt") }
  ' "$doc"
  [ -s "$work/section.txt" ] || { echo "record-examples: docs/evidence-format.md has no section \"## 6. \", which holds the examples"; exit 1; }
  if [ -s "$work/unread.txt" ]; then
    sed 's/^/not read: § 6, /' "$work/unread.txt"
    echo "record-examples: § 6 of docs/evidence-format.md holds a fenced block this script does not read; an example is fenced \`json\`"
    exit 1
  fi
  found=0
  for f in "$work"/example-*.json; do
    [ -r "$f" ] && found=$((found + 1))
  done
  if [ "$found" -ne "$want_examples" ]; then
    echo "record-examples: § 6 of docs/evidence-format.md holds $found example(s), and spec/record-examples.test.sh states $want_examples"
    exit 1
  fi
  examples=0
  for f in "$work"/example-*.json; do
    examples=$((examples + 1))
    label="§ 6 example $examples"
    type=$(jq -r '
      if type == "object" and has("format") then "ratchet.evidence.AssessmentRun"
      elif type == "array" and length > 0 and all(.[]; type == "object" and has("output")) then "List<ratchet.evidence.MeasurementResult>"
      elif type == "array" and length > 0 and all(.[]; type == "object" and has("state")) then "List<ratchet.evidence.NotExecutedUnit>"
      else "" end
    ' "$f") || { echo "record-examples: $label is not JSON"; exit 1; }
    [ -n "$type" ] || { echo "record-examples: $label has a shape with no root type in spec/record-examples.test.sh"; exit 1; }
    nodes "$label" "$type" "$f"
  done
fi

awk -F '\t' -v examples="$examples" '
  function unopt(t) { return (t ~ /^Optional</) ? substr(t, 10, length(t) - 10) : t }
  function base(t) { while (kind[t] == "newtype") t = of[t]; return t }
  function is_struct(t) { return kind[t] == "struct" || kind[t] == "entity" }
  function fail(label, path, msg) {
    gsub(/\037\[\]/, "[]", path)
    gsub(/\037/, ".", path)
    printf "%s: `%s` %s\n", label, (path == "" ? "(root)" : path), msg
    failed++
  }

  # The declared type at a path, from the type `t`; "Json" under free JSON; "" with `why` set.
  function walk(t, path,    n, i, steps, s) {
    if (path == "") return t
    n = split(path, steps, "\037")
    for (i = 1; i <= n; i++) {
      s = steps[i]
      t = unopt(t)
      if (t == "Json") return "Json"
      if (s == "[]") {
        if (t !~ /^List</) { why = "is an element of an array where `" t "` is declared"; return "" }
        t = substr(t, 6, length(t) - 6)
      } else if (t ~ /^Map<String, /) {
        t = substr(t, 13, length(t) - 13)
      } else if (is_struct(t)) {
        if (!((t SUBSEP s) in ftype)) {
          if (open[t]) return "Json"
          why = "is not a field of " t; return ""
        }
        t = ftype[t SUBSEP s]
      } else { why = "is a member of an object where `" t "` is declared"; return "" }
    }
    return t
  }

  # "" when the JSON value fits the declared type `t`, or what was expected.
  function misfit(t, jtype, text,    b, v, n, i, list) {
    t = unopt(t)
    if (t == "Json") return ""
    if (jtype == "null") return "is null; an absent member is left out"
    if (t ~ /^List</) return jtype == "array" ? "" : "is not an array (`" t "`)"
    if (t ~ /^Map<String, / || is_struct(t)) return jtype == "object" ? "" : "is not an object (`" t "`)"
    if (t == "ratchet.evidence.Digest") {
      if (jtype == "string" && length(text) == 71 && substr(text, 1, 7) == "sha256:" && substr(text, 8) ~ /^[0-9a-f]+$/) return ""
      return "is not `sha256:` and 64 lowercase hex digits"
    }
    b = base(t)
    if (b == "Integer") return (jtype == "number" && text ~ /^-?[0-9]+$/) ? "" : "is not a JSON integer (`" t "`)"
    if (b == "Boolean") return jtype == "boolean" ? "" : "is not a boolean (`" t "`)"
    if (b == "Decimal") return (jtype == "string" && text ~ /^-?[0-9]+(\.[0-9]+)?$/) ? "" : "is not a decimal as text (`" t "`)"
    if (b == "String" || b == "Timestamp" || b == "Duration") return jtype == "string" ? "" : "is not text (`" t "`)"
    if (kind[b] == "enum") {
      if (jtype != "string") return "is not text (`" t "`)"
      return ((b SUBSEP text) in variant) ? "" : "is `" text "`, which is no value of " b
    }
    return "has the declared type `" t "`, which spec/record-examples.test.sh has no rule for"
  }

  # spec/domains/*.yaml: kinds, newtypes, enum variants, field types and their order.
  FILENAME != NODES {
    if ($0 ~ /^entities:/) { in_entities = 1; next }
    if ($0 ~ /^types:/) { in_entities = 0; next }
    if ($0 ~ /^  - name: /) {
      split($0, w, " "); type = w[3]; in_fields = 0; in_variants = 0; field = ""
      kind[type] = in_entities ? "entity" : ""
      next
    }
    if ($0 ~ /^    kind: / && !in_entities) { split($0, w, " "); kind[type] = w[2]; next }
    if ($0 ~ /^    of: /) { split($0, w, " "); of[type] = w[2]; next }
    if ($0 ~ /^    variants: \[/) {
      v = $0; sub(/^    variants: \[/, "", v); sub(/\].*$/, "", v)
      n = split(v, list, / *, */)
      for (i = 1; i <= n; i++) variant[type SUBSEP list[i]] = 1
      next
    }
    if ($0 ~ /^    variants:/) { in_variants = 1; in_fields = 0; next }
    if ($0 ~ /^    undeclared_fields: ignored/) { open[type] = 1; next }
    if ($0 ~ /^    fields:/) { in_fields = 1; in_variants = 0; next }
    if ($0 ~ /^    [a-z_]+:/) { in_fields = 0; in_variants = 0; next }
    if (in_variants && $0 ~ /^      - /) { split($0, w, " "); variant[type SUBSEP w[2]] = 1; next }
    if (in_fields && $0 ~ /^      - name: /) { split($0, w, " "); field = w[3]; order[type, ++count[type]] = field; next }
    if (in_fields && field != "" && $0 ~ /^        type: /) {
      t = $0; sub(/^        type: /, "", t)
      ftype[type SUBSEP field] = t
    }
    next
  }

  # The nodes of the examples.
  {
    label = $1; top = $2; path = $3; jtype = $4; text = $5
    members++
    why = ""
    t = walk(top, path)
    if (t == "") { fail(label, path, why); next }
    if (t == "Json") { good++; next }
    if (!(top in kind) && top !~ /^List</ && top !~ /^Map</) { fail(label, path, "has the root type `" top "`, which the specification does not declare"); next }
    m = misfit(t, jtype, text)
    if (m != "") { fail(label, path, m); next }
    u = unopt(t)
    bad = 0
    if (is_struct(u)) {
      delete has
      n = split(text, keys, "\037")
      for (i = 1; i <= n; i++) has[keys[i]] = 1
      for (i = 1; i <= count[u]; i++) {
        f = order[u, i]
        if (ftype[u SUBSEP f] !~ /^Optional</ && !(f in has)) {
          fail(label, path, "has no `" f "`, which " u " requires"); bad = 1
        }
      }
    }
    if (!bad) good++
  }

  END {
    if (members == 0) { print "record-examples: no member found in the examples"; exit 1 }
    if (failed > 0) {
      printf "record-examples: %d of %d members of %d example(s) decode under the specification, %d failure(s)\n", good, members, examples, failed
      exit 1
    }
    printf "record-examples: %d of %d members of %d example(s) decode under the specification\n", members, members, examples
  }
' NODES="$work/nodes.tsv" "$root"/spec/domains/*.yaml "$work/nodes.tsv"
