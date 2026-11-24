#!/bin/sh
# Every key of the two YAML examples of docs/evidence-format.md § 10 is a declared field of the
# type it stands in (spec/domains/*.yaml).
#
# spec/record-fields.test.sh and spec/record-types.test.sh compare the field tables of § 10 with
# the specification, and spec/record-examples.test.sh reads the JSON examples of § 6. Nothing
# else reads the two YAML examples, so a field renamed in the table and in the specification
# leaves the declaration of the first assessor behind.
#
# The examples and their root types:
#   1  the declaration of an assessor: a mapping whose `format` is `ratchet-assessor/1` is a
#      `ratchet.assessor.Assessor`
#   2  a part of a `ratchet/1` file. That file is not the declared entities written out
#      (spec/README.md, "How a `ratchet/1` file differs from the declared entities"), so the
#      member at its root is read by the table `file_member` below: `assessments` is a map from
#      a name to a `ratchet.specification.AssessmentPlan`. Another member at the root fails.
#
# A key is read from the root type along its path: it is a declared field of the struct or
# entity there, a name in a declared map, or lies under a field of the type `Json`. Not checked:
# the values, the fields a type requires and its invariants.
#
# This is no YAML reader. It reads the forms the two examples use and fails on a line of another
# form: a mapping by indentation (`key:` and `key: value`), a flow mapping `{key: value, ...}`
# on one line, a flow list `[...]` on one line, and plain or quoted scalars.
#
# § 10 holds 2 examples, each a block fenced `yaml`; `want_examples` below states the number.
# Another number fails, and so does a block of § 10 fenced otherwise, except `sh` (the
# invocation, which holds no key), and a document without a section "## 10. ".
#
# Exit 0: the last line is
#   `contract-examples: <k> of <k> keys of <n> example(s) are declared fields`.
# Exit 1: each key that is no declared field is named with its example and path.
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
doc=$root/docs/evidence-format.md

[ -r "$doc" ] || { echo "contract-examples: cannot read docs/evidence-format.md" >&2; exit 1; }
for f in "$root"/spec/domains/*.yaml; do
  [ -r "$f" ] || { echo "contract-examples: cannot read spec/domains/*.yaml" >&2; exit 1; }
done

awk -v want_examples=2 '
  function unopt(t) { return (t ~ /^Optional</) ? substr(t, 10, length(t) - 10) : t }
  function is_struct(t) { return kind[t] == "struct" || kind[t] == "entity" }
  function trim(s) { sub(/^ +/, "", s); sub(/ +$/, "", s); return s }
  function join(prefix, step) { return prefix == "" ? step : prefix SEP step }
  function shown(path) { gsub(SEP "\\[\\]", "[]", path); gsub(SEP, ".", path); return path }
  function norule(msg) { printf "no rule: § 10 example %d, line %d: %s\n", example, FNR, msg; failed++ }

  # A key of the example at `path`; its scalar value, where it has one, is kept for the root.
  function emit(path, value) {
    nkeys++; key_path[nkeys] = path; key_example[nkeys] = example; key_line[nkeys] = FNR
    if (index(path, SEP) == 0) root_value[example SUBSEP path] = value
  }

  # The parts of `s` between commas that lie in no bracket and no quote; the number of parts,
  # -1 when a bracket or a quote does not close.
  function parts(s, out,    n, i, c, depth, quote, cur) {
    split("", out)
    n = 0; depth = 0; quote = ""; cur = ""
    for (i = 1; i <= length(s); i++) {
      c = substr(s, i, 1)
      if (quote != "") { if (c == quote) quote = ""; cur = cur c; continue }
      if (c == "\"" || c == "\047") { quote = c; cur = cur c; continue }
      if (c == "{" || c == "[") depth++
      if (c == "}" || c == "]") depth--
      if (c == "," && depth == 0) { out[++n] = trim(cur); cur = ""; continue }
      cur = cur c
    }
    if (depth != 0 || quote != "") return -1
    if (trim(cur) != "" || n > 0) out[++n] = trim(cur)
    return n
  }

  function value(s, path) {
    s = trim(s)
    if (s ~ /^\{/) { flow_map(s, path); return }
    if (s ~ /^\[/) { flow_list(s, path); return }
    if (s ~ /^[|>&*!]/) norule("the value `" s "` of `" shown(path) "` is a form this script does not read")
  }

  function flow_map(s, prefix,    n, i, item, k, rest) {
    if (s !~ /\}$/) { norule("the flow mapping of `" shown(prefix) "` does not close on its line"); return }
    n = parts(substr(s, 2, length(s) - 2), item)
    if (n < 0) { norule("a bracket or a quote of `" shown(prefix) "` does not close"); return }
    for (i = 1; i <= n; i++) {
      if (!match(item[i], /^[A-Za-z0-9_.@-]+:( |$)/)) { norule("`" item[i] "` in the flow mapping of `" shown(prefix) "` is no `key: value`"); continue }
      k = substr(item[i], 1, RLENGTH); sub(/: ?$/, "", k)
      rest = substr(item[i], RLENGTH + 1)
      emit(join(prefix, k), trim(rest))
      value(rest, join(prefix, k))
    }
  }

  function flow_list(s, prefix,    n, i, item) {
    if (s !~ /\]$/) { norule("the flow list of `" shown(prefix) "` does not close on its line"); return }
    n = parts(substr(s, 2, length(s) - 2), item)
    if (n < 0) { norule("a bracket or a quote of `" shown(prefix) "` does not close"); return }
    for (i = 1; i <= n; i++) {
      if (item[i] ~ /^\{/) flow_map(item[i], join(prefix, "[]"))
      else if (item[i] ~ /^\[/) flow_list(item[i], join(prefix, "[]"))
    }
  }

  # The declared type the last step of `path` stands in resolves, from the type `t`: 1, or 0
  # with `why` set.
  function resolves(t, path,    n, i, steps, s) {
    n = split(path, steps, SEP)
    for (i = 1; i <= n; i++) {
      s = steps[i]
      t = unopt(t)
      if (t == "Json") return 1
      if (s == "[]") {
        if (t !~ /^List</) { why = "is in an element of a list where `" t "` is declared"; return 0 }
        t = substr(t, 6, length(t) - 6)
      } else if (t ~ /^Map<String, /) {
        t = substr(t, 13, length(t) - 13)
      } else if (is_struct(t)) {
        if (!((t SUBSEP s) in ftype)) {
          if (open[t]) return 1
          why = "is not a field of " t; return 0
        }
        t = ftype[t SUBSEP s]
      } else { why = "is a key of a mapping where `" t "` is declared"; return 0 }
    }
    return 1
  }

  BEGIN {
    SEP = "\037"
    # The members at the root of a `ratchet/1` file that an example of § 10 holds.
    file_member["assessments"] = "Map<String, ratchet.specification.AssessmentPlan>"
  }

  # spec/domains/*.yaml: the kind of every type and the type of every field.
  FILENAME != DOC {
    if ($0 ~ /^entities:/) { in_entities = 1; next }
    if ($0 ~ /^types:/) { in_entities = 0; next }
    if ($0 ~ /^  - name: /) {
      type = $3; in_fields = 0; field = ""
      kind[type] = in_entities ? "entity" : ""
      next
    }
    if ($0 ~ /^    kind: / && !in_entities) { kind[type] = $2; next }
    if ($0 ~ /^    undeclared_fields: ignored/) { open[type] = 1; next }
    if ($0 ~ /^    fields:/) { in_fields = 1; next }
    if ($0 ~ /^    [a-z_]+:/) { in_fields = 0; next }
    if (in_fields && $0 ~ /^      - name: /) { field = $3; next }
    if (in_fields && field != "" && $0 ~ /^        type: /) {
      t = $0; sub(/^        type: /, "", t)
      ftype[type SUBSEP field] = t
    }
    next
  }

  # docs/evidence-format.md: the fenced blocks of § 10.
  /^## / {
    if (inside) { printf "not read: § 10, the block that opens at line %d does not close inside the section\n", opened; failed++; inside = 0 }
    skipping = 0
    section = ($0 ~ /^## 10\. /)
    if (section) found = 1
  }
  !section { next }
  /^ *(```|~~~)/ {
    if (inside) {
      if ($0 ~ /^```$/) inside = 0
      else norule("a fence inside the example")
      next
    }
    if (skipping) { skipping = 0; next }
    if ($0 ~ /^```yaml$/) { example++; inside = 1; opened = FNR; depth = 0; next }
    fence = $0; sub(/^ */, "", fence)
    if (fence != "```sh") { printf "not read: § 10, line %d: a block fenced \"%s\"\n", FNR, fence; failed++ }
    skipping = 1
    next
  }
  !inside { next }

  # One line of an example.
  /^ *$/ || /^ *#/ { next }
  {
    if ($0 ~ /\t/) { norule("a tab"); next }
    if ($0 ~ / #/) { norule("a comment after a value"); next }
    indent = match($0, /[^ ]/) - 1
    content = substr($0, indent + 1); sub(/ +$/, "", content)
    while (depth > 0 && ind[depth] >= indent) depth--
    parent = depth > 0 ? pth[depth] : ""
    if (depth > 0 && !opens[depth]) { norule("`" content "` is indented under `" shown(parent) "`, which has a value on its line"); next }
    if (content ~ /^\{/) {
      if (depth == 0 || filled[depth]) { norule("a flow mapping that is the value of no key"); next }
      filled[depth] = 1
      flow_map(content, parent)
      next
    }
    if (!match(content, /^[A-Za-z0-9_.@-]+:( |$)/)) { norule("`" content "` is no `key:` and no `key: value`"); next }
    if (depth > 0 && filled[depth]) { norule("`" content "` follows the flow mapping of `" shown(parent) "`"); next }
    k = substr(content, 1, RLENGTH); sub(/: ?$/, "", k)
    rest = trim(substr(content, RLENGTH + 1))
    path = join(parent, k)
    emit(path, rest)
    depth++; ind[depth] = indent; pth[depth] = path; opens[depth] = (rest == ""); filled[depth] = 0
    if (rest != "") value(rest, path)
  }

  END {
    if (inside) { printf "not read: § 10, the block that opens at line %d does not close\n", opened; failed++ }
    if (!found) { print "contract-examples: docs/evidence-format.md has no section \"## 10. \", which holds the examples"; exit 1 }
    if (example != want_examples) {
      printf "contract-examples: § 10 of docs/evidence-format.md holds %d example(s), and spec/contract-examples.test.sh states %d\n", example, want_examples
      exit 1
    }
    for (i = 1; i <= nkeys; i++) {
      e = key_example[i]; path = key_path[i]
      why = ""
      if (root_value[e SUBSEP "format"] == "ratchet-assessor/1") ok = resolves("ratchet.assessor.Assessor", path)
      else {
        n = split(path, step, SEP)
        if (!(step[1] in file_member)) {
          ok = 0
          why = (n == 1) ? "is a member at the root of a `ratchet/1` file with no type in spec/contract-examples.test.sh" : "lies under `" step[1] "`, which has no type in spec/contract-examples.test.sh"
        } else if (n == 1) ok = 1
        else ok = resolves(file_member[step[1]], substr(path, length(step[1]) + 2))
      }
      if (ok) good++
      else { printf "§ 10 example %d, line %d: `%s` %s\n", e, key_line[i], shown(path), why; failed++ }
    }
    if (nkeys == 0) { print "contract-examples: no key found in the examples of § 10"; exit 1 }
    if (failed > 0) {
      printf "contract-examples: %d of %d keys of %d example(s) are declared fields, %d failure(s)\n", good, nkeys, example, failed
      exit 1
    }
    printf "contract-examples: %d of %d keys of %d example(s) are declared fields\n", nkeys, nkeys, example
  }
' DOC="$doc" "$root"/spec/domains/*.yaml "$doc"
