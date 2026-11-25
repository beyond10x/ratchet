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
#   bytes     a file is UTF-8 and holds no NUL byte and no control character: a line ends
#             with a line feed, and a page may hold tabs
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
#             input. A scalar that holds `${` or `{inputs.` is `${inputs.<name>}` alone,
#             `<name>` is a declared input of the preset, and the type of the input fits the
#             place (`ratchet.specification.InputReference`)
#   names     a requirement names an assessment of its preset and a measurement of that
#             assessment, and the statements it serves are statements of the preset
#   assessor  the assessor of an assessment has its declaration in the directory. The kind of
#             the target is one of its `targets`. An input the assessment passes is an input
#             of the declaration that is not local, and its value has the declared type: a
#             literal by its YAML kind, a reference by the type of the input of the preset
#             (an `integer` also where a `decimal` is declared). Every required input that
#             is not local is passed. A measurement names an output of the declaration, the
#             kind of that output, its unit or none where it has none, the scope `run` or one
#             the output declares, a boundary the output declares, the identity key the output
#             declares where it states one, and in a `filter` only fields the output declares
#             for its items
#   compare   a requirement compares its measurement as the table of docs/design.md § 3
#             "Comparisons" allows for the value type of the output. `lt`, `lte`, `gt`, `gte`
#             and `eq` take a number or a set and have a `value`. `no_new_items` and
#             `no_lost_items` take a set, have no `value` and need a reference of the kind
#             `accepted_value`. `holds` takes an assertion and has no `value`. A digest has
#             no condition. The reference of a number and of a set is `accepted_value`, that
#             of a digest `generated`, and an assertion has none. A set with a reference has a
#             condition. A number that is compared with a reference states `better`. A
#             condition states the unit of the output, or none where the output has none
#   row       a measurement is named `<name>@<version>/<assessment>/<measurement>`. It has one
#             row in the tables of the pages, the rows of one preset stand on one page, the
#             four cells after the name are not empty, and a row names a measurement. A table
#             is found by its header line `| Measurement | Direction | Unit | Tolerance |
#             Evidence |`, and a page holds at least one with a row. A line inside a code
#             fence and the text of an HTML comment `<!-- ... -->` are not read, and a cell
#             that holds only spaces, tabs and no-break spaces is empty
# Not checked, each with its reason:
#   - the invariants of the types: they are written in the expression language of ESS, and
#     `ess generate synthesize` writes them as Rust
#   - a value that an input gives, where the rule reads the value (the kind of a target, the
#     kind of a measurement, an operator, the kind of a reference): the binding passes it
#   - the value of a `Json` other than a passed input and a default: no type is declared
#   - the values of a `filter`: no declaration lists the values of an item field
#   - the text of the four cells of a row against the preset: the cells are prose
#   - whether an input of a preset is referred to: an input may be there for a later version
#
# This is no YAML reader. It reads the forms the catalog is written in and fails on a line of
# another form: a mapping by indentation (`key:` and `key: value`), a flow mapping
# `{key: value, ...}` and a flow list `[...]` on one line, plain scalars, and quoted scalars
# without an escape. A list is a flow list. Refused, because a YAML reader takes them another
# way than this script would: a comment (a preset and a declaration hold none, presets/README.md),
# a tab, a quote inside a plain scalar, and a key that YAML reads as a number, a boolean or
# null (`15`, `0o17`, `1.5`, `true`, `null`).
#
# Usage:
#   sh spec/presets.test.sh                      `presets/`, then one broken copy per rule
#   sh spec/presets.test.sh --catalog <directory> [--spec <directory>]
#                                                one directory, against `spec/domains` or the
#                                                named directory of domain files; no copy
# Work files go to the ignored target/presets. It needs POSIX sh and awk, and of the other
# utilities `cat`, `cmp`, `cp`, `dirname`, `grep`, `ln`, `mkdir`, `mv`, `rm`, `sed`, `tail`,
# `tr` and `wc`. `tr` and `wc` find a NUL byte, which an awk may not read; awk finds what is no
# UTF-8 and a control character, reading bytes under `LC_ALL=C`.
#
# Exit 0: the last line is
#   `presets: <f> of <f> file(s) valid, <r> of <r> measurement(s) with a row, <c> of <c> broken copies refused`
# (with `--catalog`, without the third count). `<f>` counts the presets, the declarations and
# the pages, and not `README.md`; `<r>` counts the measurements of the presets.
# Exit 1: each failure is named with its file and line; or a broken copy is accepted, or
# refused without the message of its rule; or the harness of the copies fails a case of its own.
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
  # The NUL bytes of all files at once; a file is looked at alone when there is one.
  nuls=$(cat "$dir"/*.yaml "$dir"/*.md 2> /dev/null | tr -d '\001-\377' | wc -c)
  others=0
  readme=0
  # An operand of the form `name=value` is an assignment to awk, so every path is absolute.
  set -- reading=tables "$2"
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

  awk -v nothers="$others" -v readme="$readme" '
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
  function variants(type,    i, s) {
    s = ""
    for (i = 1; i <= vcount[type]; i++) s = s (i > 1 ? ", " : "") "`" vorder[type, i] "`"
    return s
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

  # A scalar that holds `${` or `{inputs.`: a reference to an input of the preset.
  function reference(i, F, fk, path, t,    x, name, ip, it, il, u, e, b, ok, here) {
    x = n_text[i]
    here = "`" shown(path) "` "
    if (x !~ /^[$][{]inputs[.][A-Za-z0-9_-]+[}]$/) { fail(F, n_line[i], here "holds `${` or `{inputs.` and is not `${inputs.<name>}` alone: a reference to an input is the whole of a value and has this one spelling"); return }
    name = substr(x, 10, length(x) - 10)
    if (fk != "preset") { fail(F, n_line[i], here "refers to the input `" name "`, and only a preset declares inputs to refer to"); return }
    if (path == "preset" || index(path, "preset" SEP) == 1) { fail(F, n_line[i], here "is a reference inside the `preset` block, which holds none"); return }
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
    if (e ~ /^Map<String, / || e ~ /^List</ || is_struct(e)) { fail(F, n_line[i], here "is a `" e "`, and an input stands for a scalar or a list of scalars"); return }
    b = base(e)
    if (b == "Integer") ok = (it == "integer")
    else if (b == "Decimal") ok = (it == "integer" || it == "decimal")
    else if (b == "Boolean") ok = (it == "boolean")
    else ok = (it == "string" || it == "path")
    if (!ok) fail(F, n_line[i], here "takes `" e "`, and the input `" name "` has the type `" it "`")
  }

  # ---- what joins two places of the directory -----------------------------------------------

  # An input type in words: `path`, or a list of `string`.
  function typed(it, il) { return (il ? "a list of " : "") "`" it "`" }

  # "" when the node at `path` is a literal of the input type `it`, a list of it with `il`;
  # or what it is not.
  function unfit(F, path, it, il,    id, k, x, j, m) {
    id = at[F, path]; k = n_kind[id]; x = n_text[id]
    if (il) {
      if (k != "list") return "is no list"
      for (j = 1; has(F, path SEP "[" j "]"); j++) {
        m = unfit(F, path SEP "[" j "]", it, 0)
        if (m != "") return "holds an item that " m
      }
      return ""
    }
    if (k == "list" || k == "map") return "is a " (k == "map" ? "mapping" : "list") " and no scalar"
    if (it == "integer") return (k == "int" && x ~ /^-?[0-9]+$/) ? "" : "is no integer"
    if (it == "decimal") return ((k == "int" || k == "float") && x ~ /^-?[0-9]+([.][0-9]+)?$/) ? "" : "is no decimal without exponent and sign `+`"
    if (it == "boolean") return (k == "bool" && (x == "true" || x == "false")) ? "" : "is not `true` or `false`"
    return k == "str" ? "" : "is no text"
  }

  # The path of the output a measurement reads, in the declaration of its assessor; "" where
  # the output is not declared. Sets A (the assessor), D (its declaration, "" without one)
  # and O (the name of the output).
  function output_of(F, mp,    s) {
    split(mp, s, SEP)
    A = text(F, "assessments" SEP s[2] SEP "assessor"); D = ""; O = text(F, mp SEP "output")
    if (!(A in declaration)) return ""
    D = declaration[A]
    return has(D, "outputs" SEP O) ? "outputs" SEP O : ""
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

  # ---- a page: what Markdown does not show ---------------------------------------------------

  # The line without the text of its HTML comments; a comment may end on a later line.
  function uncomment(s,    i, out) {
    out = ""
    while (1) {
      if (in_comment) {
        i = index(s, "-->")
        if (i == 0) return out
        s = substr(s, i + 3); in_comment = 0
      }
      i = index(s, "<!--")
      if (i == 0) return out s
      out = out substr(s, 1, i - 1); s = substr(s, i + 4); in_comment = 1
    }
  }

  # 1 when a cell shows nothing: spaces, tabs and no-break spaces.
  function blank(s) { gsub(/[ \t]|\302\240/, "", s); return s == "" }

  BEGIN {
    SEP = "\037"
    HEADER = "| Measurement | Direction | Unit | Tolerance | Evidence |"
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
    if (reading == "page") { pg[++np] = FILE; in_table = 0; fence = ""; in_comment = 0 }
  }
  # Only a line with a byte that is no printable ASCII and no tab is looked at further.
  /[^\011\040-\176]/ {
    if (!utf8($0)) { fail(FILE, FNR, "the line is not UTF-8"); next }
    if ($0 ~ /[\001-\010\013-\037\177]/) { fail(FILE, FNR, "the line holds a control character, such as a carriage return; a line ends with a line feed, and only a page holds tabs"); next }
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
    mark = line; sub(/^ +/, "", mark); mark = substr(mark, 1, 3)
    if (fence != "") {
      if (mark == fence && line ~ /^ *[`~]+ *$/) fence = ""
      next
    }
    if (!in_comment && (mark == "```" || mark == "~~~")) { fence = mark; in_table = 0; next }
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
    if (line !~ /\| *$/) { fail(FILE, FNR, "a row does not end with `|`"); next }
    sub(/^\| */, "", line); sub(/ *\| *$/, "", line)
    n = split(line, cell, /\|/)
    if (n != 5) { fail(FILE, FNR, "a row has " n " cells; a row has 5, and no cell holds `|`"); next }
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
      if (fk == "assessor") declaration[ident[F]] = F
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
      if (k != "map" && k != "list" && (index(n_text[i], "${") > 0 || index(n_text[i], "{inputs.") > 0)) { reference(i, F, fk, path, t); continue }
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
        if (("ratchet.specification.InputType", it) in variant) {
          m = unfit(F, path, it, il)
          if (m != "") fail(F, n_line[i], named(path) m ", and its input has the type " typed(it, il))
        }
      }
      if (fk != "preset") continue

      if (n == 4 && s[1] == "preset" && s[2] == "inputs" && s[4] == "local" && n_text[i] == "true")
        fail(F, n_line[i], "the input `" s[3] "` is local, and a preset declares no local input (`preset_input_local`)")

      if (n == 2 && s[1] == "assessments") {
        a = text(F, path SEP "assessor")
        if (!has(F, path SEP "assessor") || !(a in declaration)) continue
        D = declaration[a]
        for (j = 1; j <= nkeys[D, "inputs"]; j++) {
          dp = "inputs" SEP keyof[D, "inputs", j]
          if (text(D, dp SEP "required") == "true" && text(D, dp SEP "local") != "true" && !has(F, path SEP dp))
            fail(F, n_line[i], named(path) "passes no `" keyof[D, "inputs", j] "`, which `" a "` requires")
        }
      }

      if (n == 3 && s[1] == "assessments" && s[3] == "assessor" && !(n_text[i] in declaration))
        fail(F, n_line[i], named(path) "names the assessor `" n_text[i] "`, and the directory holds no `" n_text[i] ".assessor.yaml`")

      if (n == 4 && s[1] == "assessments" && s[3] == "target" && s[4] == "kind") {
        a = text(F, "assessments" SEP s[2] SEP "assessor")
        if ((a in declaration) && index(n_text[i], "${") == 0 && !holds(declaration[a], "targets", n_text[i]))
          fail(F, n_line[i], named(path) "is `" n_text[i] "`, and `" a "` declares the targets `" items(declaration[a], "targets") "`")
      }

      if (n == 4 && s[1] == "assessments" && s[3] == "inputs") {
        a = text(F, "assessments" SEP s[2] SEP "assessor")
        if (!(a in declaration)) continue
        D = declaration[a]; dp = "inputs" SEP s[4]
        if (!has(D, dp)) { fail(F, n_line[i], named(path) "passes the input `" s[4] "`, which `" a "` does not declare"); continue }
        if (text(D, dp SEP "local") == "true") { fail(F, n_line[i], named(path) "passes the input `" s[4] "`, which `" a "` declares local: the local config supplies it (`local_input_in_specification`)"); continue }
        dt = text(D, dp SEP "type"); dl = (text(D, dp SEP "list") == "true")
        x = n_text[i]
        if (n_kind[i] != "map" && n_kind[i] != "list" && (index(x, "${") > 0 || index(x, "{inputs.") > 0)) {
          ip = "preset" SEP "inputs" SEP substr(x, 10, length(x) - 10)
          if (x !~ /^[$][{]inputs[.][A-Za-z0-9_-]+[}]$/ || !has(F, ip)) continue
          it = text(F, ip SEP "type"); il = (text(F, ip SEP "list") == "true")
          if (il != dl || !(it == dt || (it == "integer" && dt == "decimal")))
            fail(F, n_line[i], named(path) "passes the input `" substr(x, 10, length(x) - 10) "` of the preset, " typed(it, il) ", and `" a "` declares the input `" s[4] "` as " typed(dt, dl))
        } else {
          m = unfit(F, path, dt, dl)
          if (m != "") fail(F, n_line[i], named(path) m ", and `" a "` declares the input `" s[4] "` as " typed(dt, dl))
        }
      }

      if (n == 4 && s[1] == "assessments" && s[3] == "measurements") {
        id = stated[F] "/" s[2] "/" s[4]
        ms[++nm] = id; ms_file[nm] = F; ms_line[nm] = n_line[i]; ms_preset[nm] = stated[F]
        is_measurement[id] = 1
        op = output_of(F, path)
        if (D == "" || !has(F, path SEP "output")) continue
        if (op == "") { fail(F, n_line[i], named(path) "names the output `" O "`, which `" A "` does not declare"); continue }
        what = "the output `" O "` of `" A "`"
        mk = text(F, path SEP "kind")
        if (has(F, path SEP "kind") && index(mk, "${") == 0 && mk != text(D, op SEP "kind"))
          fail(F, n_line[i], named(path) "has the kind `" mk "`, and " what " declares `" text(D, op SEP "kind") "`")
        has_du = has(D, op SEP "unit"); du = text(D, op SEP "unit")
        has_mu = has(F, path SEP "unit"); mu = text(F, path SEP "unit")
        if (has_du && !has_mu) fail(F, n_line[i], named(path) "has no `unit`, and " what " declares `" du "` (`unit_missing`)")
        else if (has_du && mu != du) fail(F, n_line[i], named(path) "states the unit `" mu "`, and " what " declares `" du "` (`unit_mismatch`)")
        else if (!has_du && has_mu) fail(F, n_line[i], named(path) "states the unit `" mu "`, and " what " declares none (`unit_not_declared`)")
        sc = text(F, path SEP "scope")
        if (has(F, path SEP "scope") && sc != "run" && !holds(D, op SEP "scopes", sc))
          fail(F, n_line[i], named(path) "has the scope `" sc "`, which " what " does not declare")
        bd = text(F, path SEP "boundary")
        if (has(F, path SEP "boundary") && !holds(D, op SEP "boundaries", bd))
          fail(F, n_line[i], named(path) "has the boundary `" bd "`, which " what " does not declare")
        if (has(F, path SEP "identity")) {
          mk = items(F, path SEP "identity"); dk = items(D, op SEP "identity_key")
          if (!has(D, op SEP "identity_key")) fail(F, n_line[i], named(path) "states an identity key, and " what " declares none")
          else if (mk != dk) fail(F, n_line[i], named(path) "states the identity key `" mk "`, and " what " declares `" dk "`")
        }
      }

      if (n == 6 && s[1] == "assessments" && s[3] == "measurements" && s[5] == "filter") {
        op = output_of(F, "assessments" SEP s[2] SEP "measurements" SEP s[4])
        if (op == "") continue
        if (!holds(D, op SEP "item_fields", s[6]))
          fail(F, n_line[i], named(path) "filters by the field `" s[6] "`, which the output `" O "` of `" A "` does not declare for its items")
      }

      if (n == 2 && s[1] == "requirements") {
        if (has(F, path SEP "assessment")) {
          ra = text(F, path SEP "assessment")
          if (!has(F, "assessments" SEP ra)) fail(F, n_line[i], named(path) "names the assessment `" ra "`, which the preset does not hold")
          else if (has(F, path SEP "measurement")) {
            rm = text(F, path SEP "measurement")
            if (!has(F, "assessments" SEP ra SEP "measurements" SEP rm)) fail(F, n_line[i], named(path) "names the measurement `" rm "`, which the assessment `" ra "` does not hold")
          } else if (nkeys[F, "assessments" SEP ra SEP "measurements"] != 1)
            fail(F, n_line[i], named(path) "names no measurement, and the assessment `" ra "` holds " (nkeys[F, "assessments" SEP ra SEP "measurements"] + 0))
        }
        for (j = 1; has(F, path SEP "serves" SEP "[" j "]"); j++) {
          st = text(F, path SEP "serves" SEP "[" j "]")
          if (!has(F, "statements" SEP st)) fail(F, n_line[i], named(path) "serves the statement `" st "`, which the preset does not hold")
        }

        # The comparison against the value type of the output (docs/design.md § 3
        # "Comparisons").
        mp = compared(F, path)
        if (mp == "") continue
        op = output_of(F, mp)
        if (op == "") continue
        vt = text(D, op SEP "value_type")
        what = "the output `" O "` of `" A "`"
        is = what " has the value type `" vt "`"
        hc = has(F, path SEP "condition"); hr = has(F, path SEP "reference")
        opr = text(F, path SEP "condition" SEP "operator")
        rk = text(F, path SEP "reference" SEP "kind")
        hv = has(F, path SEP "condition" SEP "value")
        if (hc && vt == "digest") fail(F, n_line[i], named(path) "has a condition, and " is ", which takes none")
        else if (hc && opr != "" && index(opr, "${") == 0) {
          limit = (opr ~ /^(lt|lte|gt|gte|eq)$/)
          if (opr == "holds") {
            if (vt != "assertion") fail(F, n_line[i], named(path) "has the operator `holds`, which takes an assertion, and " is)
          } else if (opr == "no_new_items" || opr == "no_lost_items") {
            if (vt != "identity_set") fail(F, n_line[i], named(path) "has the operator `" opr "`, which takes an identity set, and " is)
            else if (rk != "accepted_value") fail(F, n_line[i], named(path) "has the operator `" opr "` and no reference of the kind `accepted_value`, the set it compares with")
          } else if (limit && vt != "number" && vt != "identity_set")
            fail(F, n_line[i], named(path) "has the operator `" opr "`, which takes a number or the number of items of a set, and " is)
          if (limit && !hv) fail(F, n_line[i], named(path) "has the operator `" opr "` and no `value`, the limit")
          if (!limit && hv) fail(F, n_line[i], named(path) "has the operator `" opr "`, which takes no `value`")
        }
        if (hc) {
          has_du = has(D, op SEP "unit"); du = text(D, op SEP "unit")
          has_cu = has(F, path SEP "condition" SEP "unit"); cu = text(F, path SEP "condition" SEP "unit")
          if (has_du && !has_cu) fail(F, n_line[i], named(path) "has a condition without a `unit`, and " what " declares `" du "` (`unit_missing`)")
          else if (has_du && cu != du) fail(F, n_line[i], named(path) "has a condition in the unit `" cu "`, and " what " declares `" du "` (`unit_mismatch`)")
          else if (!has_du && has_cu) fail(F, n_line[i], named(path) "has a condition in the unit `" cu "`, and " what " declares none (`unit_not_declared`)")
        }
        if (hr && rk != "" && index(rk, "${") == 0) {
          if (vt == "assertion") fail(F, n_line[i], named(path) "has a reference, and " is ", which takes none")
          else if (vt == "digest" && rk != "generated") fail(F, n_line[i], named(path) "has the reference `" rk "`, and " is ", which takes `generated`")
          else if ((vt == "number" || vt == "identity_set") && rk != "accepted_value") fail(F, n_line[i], named(path) "has the reference `" rk "`, and " is ", which takes `accepted_value`")
          if (vt == "identity_set" && !hc) fail(F, n_line[i], named(path) "compares a set with a reference and has no condition: `no_new_items` or `no_lost_items` says which way is worse")
          if (vt == "number" && !has(F, mp SEP "better")) fail(F, n_line[at[F, mp]], "`" shown(mp) "` states no `better`, and `" shown(path) "` compares it with a reference")
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

# ---- one broken copy per rule ---------------------------------------------------------------
#
# Each case is a copy of presets/, the directory target/presets/<case>, with one defect. The case
# holds when the check of the copy exits non-zero and names the defect with the words of its rule,
# so a case fails when its rule is taken out of the check, also where another rule refuses the
# copy then. A rule without a case here is not guarded: a new rule gets its copy.

stop() {
  echo "presets: $1"
  exit 1
}

# copy <case>: a fresh copy of presets/ as the directory $c; sets $c and $name. What a case
# writes beside its copy is named $c.<word>. The copy is checked against the specification of
# the repository until `own_spec` gives it one of its own.
copy() {
  name=$1
  c=$work/$1
  cp -R "$catalog" "$c"
  case_tables=$work/tables
}

# own_spec: the copy gets its own copy of spec/domains, $c.domains, for `edit_spec`.
own_spec() {
  cp -R "$root/spec/domains" "$c.domains"
  case_tables=
}

# An edit that changes nothing stops the run: its case would test the unchanged catalog.
nothing() {
  echo "presets: the edit of the case $name changes nothing in $1" >&2
  exit 1
}

# edit <file of the copy> <awk program>
edit() {
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
  awk -v old="$2" -v new="$3" -v nth="${4:-1}" '
    ($0 "") == (old "") && ++seen == nth { print new; swapped = ((new "") != (old "")); next }
    { print }
    END { exit !swapped }' "$c/$1" > "$c.new" || nothing "$1"
  mv "$c.new" "$c/$1"
}

# drop <file of the copy> <line> [<n>]: the n-th line that is <line> is taken out.
drop() {
  awk -v old="$2" -v nth="${3:-1}" '
    ($0 "") == (old "") && ++seen == nth { dropped = 1; next }
    { print }
    END { exit !dropped }' "$c/$1" > "$c.new" || nothing "$1"
  mv "$c.new" "$c/$1"
}

# verdict <message>: sets $verdict for the copy: `accepted`, `refused` with the message in
# the output of the check, or `other` for a refusal without it.
verdict() {
  if [ -z "$case_tables" ]; then
    tables "$c.domains" > "$c.tables"
    case_tables=$c.tables
  fi
  if check_catalog "$c" "$case_tables" > "$c.out" 2>&1; then
    verdict=accepted
  elif grep -F -q -e "$1" "$c.out"; then
    verdict=refused
  else
    verdict=other
  fi
}

cases=0
accepted=0

# refused <the message of the rule> <what the copy holds>
refused() {
  cases=$((cases + 1))
  verdict "$1"
  case $verdict in
    refused) ;;
    accepted)
      accepted=$((accepted + 1))
      echo "accepted: $name: $2"
      echo "  $(tail -n 1 "$c.out")" ;;
    *)
      accepted=$((accepted + 1))
      echo "refused without the message of its rule: $name: $2"
      echo "  wanted: $1"
      sed 's/^/  /' "$c.out" ;;
  esac
}

# accepts <what the copy holds>: a copy with a form that is valid; a refusal stops the run.
accepts() {
  verdict 'presets:'
  if [ "$verdict" != accepted ]; then
    echo "presets: refused, and it is valid: $name: $1"
    sed 's/^/  /' "$c.out"
    exit 1
  fi
}

# result: the last line; fails when a copy was accepted.
result() {
  if [ "$accepted" -gt 0 ]; then
    echo "$summary, $((cases - accepted)) of $cases broken copies refused, $accepted accepted"
    return 1
  fi
  echo "$summary, $cases of $cases broken copies refused"
}

conf='conformance-cases@1.preset.yaml'
conf_d='conformance-report@1.assessor.yaml'
differ='differential-equality@1.preset.yaml'
differ_d='comparison-report@1.assessor.yaml'
known_d='case-list@1.assessor.yaml'
page='functional.md'

# Lines of the catalog that many cases change.
meaning='    meaning: Every case of the accepted set of passing cases still passes.'
passes='      report: ${inputs.report}'
set_rule='    condition: {operator: no_lost_items}'
accepted_value='    reference: {kind: accepted_value}'
of_failed='    measurement: failed'
limit='      value: ${inputs.different_limit}'
number_output='  failed: {value_type: number, kind: exact, scopes: [], unit: cases}'
the_row='index($0, "| `conformance-cases@1/conformance/skipped` |") == 1'
table='| Measurement | Direction | Unit | Tolerance | Evidence |\n| --- | --- | --- | --- | --- |\n'

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

# The unchanged catalog is accepted, also through the options, and is not counted as refused.
copy harness-unchanged
verdict 'presets:'
if [ "$verdict" != accepted ]; then
  cat "$c.out"
  stop "the unchanged copy of presets/ is not accepted"
fi
if sh "$self" --catalog "$c" --spec "$spec" > "$c.options" 2>&1 && [ "$(cat "$c.options")" = "$summary" ]; then :; else
  cat "$c.options"
  stop "the unchanged copy of presets/ fails with --catalog and --spec, or prints another line than: $summary"
fi

# A refusal counts only with the message of the rule of its case.
copy harness-message
printf 'A note.\n' > "$c/notes.txt"
verdict 'the message of no rule'
[ "$verdict" = other ] || stop "a refusal without the message of its rule counts as the refusal of its case"

# An accepted copy, and a copy refused without the message of its rule, give exit 1.
if (cases=0; accepted=0; copy harness-accepted; refused 'the message of no rule' 'the unchanged catalog'; result) > "$work/harness.out" 2>&1; then
  stop "an accepted copy does not fail the run"
fi
grep -q '^accepted: harness-accepted: ' "$work/harness.out" || stop "an accepted copy is not named"
if (cases=0; accepted=0; name=harness-message; c=$work/harness-message; refused 'the message of no rule' 'the directory holds notes.txt'; result) > "$work/harness.out" 2>&1; then
  stop "a copy refused without the message of its rule does not fail the run"
fi
grep -q '^refused without the message of its rule: harness-message: ' "$work/harness.out" || stop "a copy refused without the message of its rule is not named"

# A copy that is refused stops the run where its case says that it is valid.
if (name=harness-message; c=$work/harness-message; accepts 'the directory holds notes.txt') > /dev/null 2>&1; then
  stop "a refused copy passes as a valid form"
fi

# -- forms that are valid ------------------------------------------------------------------------

copy valid-trailing-spaces
swap "$conf" '        kind: exact' '        kind: exact   '
accepts "spaces at the end of a line"

copy valid-quoted-reference
swap "$conf" "$passes" '      report: "${inputs.report}"'
accepts "a quoted reference as the value of a key"

copy valid-identity-absent
drop "$conf" '        identity: [case_id]'
accepts "a measurement of a set that leaves the identity key to the declaration"

copy valid-quoted-decimal
swap "$differ" "$limit" '      value: "0.5"'
accepts "a decimal written as quoted text"

copy valid-integer-input-for-decimal
swap "$differ_d" '  report: {type: path, required: true}' '  report: {type: path, required: true}\n  limit: {type: decimal, required: true}'
swap "$differ" "$passes" '      report: ${inputs.report}\n      limit: ${inputs.different_limit}'
accepts "an assessment that passes an integer input where a decimal is declared"

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

copy file-not-utf8
swap "$conf" "$meaning" '    meaning: Every case \377 still passes.'
refused 'conformance-cases@1.preset.yaml:56: the line is not UTF-8' "a preset holds the byte 255"

copy file-utf8-cut-short
edit "$page" 'NR == 1 { print $0 " \342\202"; next } { print }'
refused 'functional.md:1: the line is not UTF-8' "a character of the page ends after two of its three bytes"

copy file-control-character
swap "$conf" "$meaning" '    meaning: Every case \001 still passes.'
refused 'conformance-cases@1.preset.yaml:56: the line holds a control character' "a preset holds the byte 1"

copy file-carriage-return
swap "$conf" "$meaning" '    meaning: Every case\r#  of the accepted set.'
refused 'conformance-cases@1.preset.yaml:56: the line holds a control character' "a line of a preset holds a carriage return and no line feed after it"

# Six byte sequences that look like UTF-8 and are none, each on the line of `meaning`.
for case_bytes in \
  'file-utf8-two-bytes-for-one|\300\200|U+0000 in two bytes' \
  'file-utf8-three-bytes-for-two|\340\200\200|U+0000 in three bytes' \
  'file-utf8-surrogate|\355\240\200|the surrogate U+D800' \
  'file-utf8-four-bytes-for-three|\360\200\200\200|U+0000 in four bytes' \
  'file-utf8-above-the-last|\364\220\200\200|U+110000, above the last character' \
  'file-utf8-lead-of-five|\365\200\200\200|the lead byte 245'
do
  copy "${case_bytes%%|*}"
  case_bytes=${case_bytes#*|}
  swap "$conf" "$meaning" "    meaning: Every case ${case_bytes%%|*} still passes."
  refused 'conformance-cases@1.preset.yaml:56: the line is not UTF-8' "a preset holds ${case_bytes#*|}"
done

copy file-control-character-in-readme
printf 'A line.\033\n' >> "$c/README.md"
refused "README.md:$(($(wc -l < "$c/README.md"))): the line holds a control character" "README.md holds the byte 27"

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

copy form-block-list
swap "$conf" '        identity: [case_id]' '        identity:\n          - case_id'
refused 'not read: a block list' "an identity key is written as a block list"

copy form-key-twice
swap "$conf" '        output: passed' '        output: passed\n        output: failed'
refused 'stands twice in its mapping' "a measurement holds the key output twice"

copy form-unquoted-reference
swap "$conf" "$passes" '      {report: ${inputs.report}}'
refused 'holds a bracket or a brace inside a flow collection; quote it' "a reference stands plain in a flow mapping"

copy form-comment-line
edit "$conf" 'NR == 1 { print "# The conformance preset of the functional family." } { print }'
refused 'conformance-cases@1.preset.yaml:1: not read: a comment; a preset and a declaration hold none' "a preset starts with a comment line"

copy form-comment-after-value
swap "$conf" "$meaning" '    meaning: Every case still passes. # the first rule'
refused 'not read: a comment after a value' "a comment follows a value"

copy form-quote-before-comment
swap "$conf" "$meaning" '    meaning: Every case of the "accepted #1 set" still passes.'
refused 'conformance-cases@1.preset.yaml:56: not read: a quote inside a plain scalar' 'a plain scalar holds a quoted part with " #" in it, where YAML starts a comment'

copy form-lone-quote
swap "$conf" "$meaning" "    meaning: Every case of the 'accepted set still passes. # and a comment"
refused 'conformance-cases@1.preset.yaml:56: not read: a quote inside a plain scalar' "a plain scalar holds one quote and a comment after it"

copy form-quote-in-flow-list
swap "$differ" '        filter: {class: [equal]}' "        filter: {class: [equal 'a, b' c]}"
refused 'differential-equality@1.preset.yaml:30: not read: a quote inside a plain scalar' "an item of a flow list holds a quoted part with a comma in it, which YAML reads as two items"

copy form-tab
swap "$conf" "$meaning" '    meaning: Every case\tstill passes.'
refused 'conformance-cases@1.preset.yaml:56: not read: a tab' "a value holds a tab"

copy form-indented-at-root
swap "$conf" 'format: ratchet/1' ' format: ratchet/1'
refused 'not read: `format: ratchet/1` is indented at the root of the file' "the first key is indented by one space"

copy form-under-a-value
swap "$conf" "$passes" '      report: ${inputs.report}\n        extra: 1'
refused 'not read: `extra: 1` is indented under `assessments.conformance.inputs.report`, which has a value on its line' "a key stands under a key that has a value"

copy form-uneven-indent
swap "$conf" '      refused:' '     refused:'
refused 'is not indented as the line before it under `assessments.conformance.measurements`' "one key of a mapping is indented by one space less"

copy form-flow-of-no-key
printf '{}\n' >> "$c/$conf"
refused 'not read: a flow collection that is the value of no key' "a flow mapping stands at the root"

copy form-key-after-flow
swap "$conf" '    subject: {type: string, required: true}' '    {subject: {type: string, required: true}}'
refused 'follows the flow collection of `preset.inputs`' "keys follow a flow mapping in one block mapping"

copy form-escape
swap "$conf" "$meaning" '    meaning: "Every case \\n still passes."'
refused 'the quoted scalar of `requirements.no-case-lost.meaning` holds an escape' "a double-quoted scalar holds an escape"

copy form-quote-not-closed
swap "$conf" "$meaning" '    meaning: "Every case still passes.'
refused 'the quoted scalar of `requirements.no-case-lost.meaning` does not end at its quote' "a quoted scalar does not close"

copy form-tag
swap "$conf" "$meaning" '    meaning: !!str Every case still passes.'
refused 'the value `!!str Every case still passes.` of `requirements.no-case-lost.meaning` is in a form this script does not read' "a value has a tag"

copy form-colon-in-plain
swap "$conf" "$meaning" '    meaning: Every case: it still passes.'
refused 'the plain scalar of `requirements.no-case-lost.meaning` holds `: `; quote it' "a plain scalar holds a colon and a space"

copy form-flow-mapping-open
swap "$conf" "$set_rule" '    condition: {operator: no_lost_items x'
refused 'the flow mapping of `requirements.no-case-lost.condition` does not close on its line' "a flow mapping does not close"

copy form-flow-mapping-bracket
swap "$differ" '        filter: {class: [equal]}' '        filter: {class: [equal]]}'
refused 'a bracket or a quote in the flow mapping of `assessments.comparison.measurements.equal-cases.filter` does not close' "a flow mapping holds a bracket too many"

copy form-flow-mapping-no-pair
swap "$conf" "$set_rule" '    condition: {operator}'
refused '`operator` in the flow mapping of `requirements.no-case-lost.condition` is no `key: value`' "a flow mapping holds a word and no key with a value"

copy form-flow-mapping-no-value
swap "$conf" "$set_rule" '    condition: {operator: no_lost_items, unit:}'
refused '`requirements.no-case-lost.condition.unit` has no value in its flow mapping' "a key of a flow mapping has no value"

copy form-flow-list-open
swap "$conf" '        identity: [case_id]' '        identity: [case_id x'
refused 'the flow list of `assessments.conformance.measurements.passing-cases.identity` does not close on its line' "a flow list does not close"

copy form-flow-list-bracket
swap "$conf_d" 'conditions: []' 'conditions: []]'
refused 'a bracket or a quote in the flow list of `conditions` does not close' "a flow list holds a bracket too many"

copy form-flow-list-empty-item
swap "$conf_d" 'conditions: []' 'conditions: [,]'
refused 'the flow list of `conditions` holds an empty item' "a flow list holds an empty item"

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

copy key-declaration
swap "$conf_d" 'coverage_unit: case' 'coverage_units: case'
refused '`coverage_units` is not a field of ratchet.assessor.Assessor' "a declaration holds the key coverage_units"

copy key-renamed-in-specification
own_spec
edit_spec specification.yaml '
  /^  - name: / { t = $3 }
  t == "ratchet.specification.Measurement" && $0 == "      - name: better" { print "      - name: improves"; next }
  { print }'
refused '`assessments.conformance.measurements.passed.better` is not a field of ratchet.specification.Measurement' "the specification names the field improves and the presets still write better"

copy value-preset
swap "$conf" "$set_rule" '    condition: {operator: no_lost_item}'
refused 'is `no_lost_item`, which is no value of ratchet.specification.ComparisonOperator' "a condition has the operator no_lost_item"

copy value-declaration
swap "$conf_d" '    value_type: identity_set' '    value_type: set'
refused 'is `set`, which is no value of ratchet.specification.ValueType' "an output has the value type set"

copy value-format
swap "$conf" 'format: ratchet/1' 'format: ratchet/2'
refused '`format` is not `ratchet/1`' "a preset has the format ratchet/2"

copy value-format-of-declaration
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

copy value-absent
swap "$conf" "$passes" '      report:'
refused '`assessments.conformance.inputs.report` has no value on its line and nothing under it' "a key has no value"

copy type-null
swap "$conf" "$meaning" '    meaning: null'
refused '`requirements.no-case-lost.meaning` is null; an absent member is left out' "a text member is null"

copy type-text
swap "$conf" '  version: "1"' '  version: 1'
refused '`preset.version` is a YAML integer where text is declared' "the version of a preset is the integer 1"

copy type-text-number
swap "$conf" "$meaning" '    meaning: 1.5'
refused '`requirements.no-case-lost.meaning` is a YAML number where text is declared' "a text member is the number 1.5"

copy type-text-infinity
swap "$conf" "$meaning" '    meaning: .inf'
refused '`requirements.no-case-lost.meaning` is a YAML number where text is declared' "a text member is .inf"

copy type-text-not-a-number
swap "$conf" "$meaning" '    meaning: .nan'
refused '`requirements.no-case-lost.meaning` is a YAML number where text is declared' "a text member is .nan"

copy type-text-hexadecimal
swap "$conf" "$meaning" '    meaning: 0x1F'
refused '`requirements.no-case-lost.meaning` is a YAML integer where text is declared' "a text member is 0x1F"

copy type-text-empty-output
swap "$conf" '        output: failed' '        output: ""'
refused '`assessments.conformance.measurements.failed.output` is empty text' "a measurement has the output \"\""

copy type-text-empty-scope
swap "$conf" '        scope: run' '        scope: ""' 3
refused '`assessments.conformance.measurements.failed.scope` is empty text' "a measurement has the scope \"\""

copy type-text-empty-assessment
swap "$conf" '    assessment: conformance' '    assessment: ""' 3
refused '`requirements.failed-does-not-rise.assessment` is empty text' "a requirement has the assessment \"\""

copy type-enum-boolean
swap "$conf" '        kind: exact' '        kind: true' 3
refused '`assessments.conformance.measurements.failed.kind` is a YAML boolean where a value of ratchet.specification.MeasurementKind is declared' "the kind of a measurement is true"

copy type-list-for-scalar
swap "$conf" '        kind: exact' '        kind: [exact]' 3
refused '`assessments.conformance.measurements.failed.kind` is a list where `ratchet.specification.MeasurementKind` is declared' "the kind of a measurement is a list"

copy type-mapping-for-scalar
swap "$conf" '        kind: exact' '        kind: {a: b}' 3
refused '`assessments.conformance.measurements.failed.kind` is a mapping where `ratchet.specification.MeasurementKind` is declared' "the kind of a measurement is a mapping"

copy type-scalar-for-list
swap "$conf_d" 'targets: [revision]' 'targets: revision'
refused '`targets` is not a list (`List<ratchet.specification.TargetKind>`)' "the targets of a declaration are one word"

copy type-scalar-for-mapping
swap "$differ" '        filter: {class: [equal]}' '        filter: equal'
refused '`assessments.comparison.measurements.equal-cases.filter` is not a mapping' "a filter is one word"

copy type-integer
swap "$conf" '      kind: snapshot' '      kind: snapshot\n      runs: one'
refused '`assessments.conformance.observation.runs` is not an integer' "the runs of an observation are the word one"

copy type-boolean
swap "$conf" '    report: {type: path, required: true}' '    report: {type: path, required: "true"}'
refused '`preset.inputs.report.required` is not `true` or `false`' "an input is required by the text \"true\""

copy type-decimal
swap "$conf" "$of_failed" '    measurement: failed\n    condition: {operator: lte, value: 1e3, unit: cases}'
refused '`requirements.failed-does-not-rise.condition.value` is not a decimal without exponent' "the limit of a condition is 1e3"

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

copy required-field-of-declaration
drop "$conf_d" 'coverage_unit: case'
refused '`(root)` has no `coverage_unit`, which ratchet.assessor.Assessor requires' "a declaration states no coverage unit"

# -- what a preset does not hold ---------------------------------------------------------------

copy preset-gate
printf '\ngates:\n  merge:\n    stage: pre-merge\n    qualifying_environments: [ci]\n    requires: [no-case-lost]\n' >> "$c/$conf"
refused '`gates` is no member of a preset' "a preset holds a gate"

copy preset-exception
printf '\nexceptions:\n  known-failing:\n    requirement: no-case-lost\n    item: {case_id: case-0042}\n    reason: The fix is planned.\n    owner: story:case-0042\n    expires: 2027-01-31\n' >> "$c/$conf"
refused '`exceptions` is no member of a preset' "a preset holds an exception"

copy preset-binding
printf '\npresets:\n  inner:\n    use: known-failures@1\n    digest: sha256:0000\n' >> "$c/$conf"
refused '`presets` is no member of a preset' "a preset binds a preset"

copy preset-project
swap "$conf" '  conformance:' '  conformance:\n    project: orders-api'
refused '`assessments.conformance.project` is the `project` of an entry' "an assessment of a preset states a project"

copy preset-local-input
swap "$conf" '    report: {type: path, required: true}' '    report: {type: path, required: true, local: true}'
refused 'the input `report` is local, and a preset declares no local input' "an input of a preset is local"

# -- the inputs of a preset ----------------------------------------------------------------------

copy input-undeclared
swap "$conf" "$passes" '      report: ${inputs.reports}'
refused 'refers to the input `reports`, which the preset does not declare' "an assessment refers to the input reports"

copy input-beside-text
swap "$conf" "$passes" '      report: target/${inputs.report}'
refused 'is not `${inputs.<name>}` alone' "a reference stands beside text"

copy input-with-a-space
swap "$conf" "$passes" '      report: $ {inputs.report}'
refused '`assessments.conformance.inputs.report` holds `${` or `{inputs.` and is not `${inputs.<name>}` alone' "a reference has a space after its dollar sign"

copy input-in-double-braces
swap "$conf" "$passes" '      report: "{{inputs.report}}"'
refused '`assessments.conformance.inputs.report` holds `${` or `{inputs.` and is not `${inputs.<name>}` alone' "a reference is written in double braces"

copy input-in-declaration
swap "$conf_d" 'command: conformance-report' 'command: ${inputs.command}'
refused 'refers to the input `command`, and only a preset declares inputs to refer to' "a declaration refers to an input"

copy input-in-preset-block
swap "$conf" '    subject: {type: string, required: true}' '    subject: {type: "${inputs.subject}", required: true}'
refused '`preset.inputs.subject.type` is a reference inside the `preset` block' "the type of an input is a reference"

copy input-scalar-for-list
swap "$conf" '      environments: ${inputs.environments}' '      environments: ${inputs.report}'
refused 'takes a list (`List<ratchet.specification.TargetClass>`), and the input `report` declares no `list`' "the classes of a target are one path"

copy input-list-for-scalar
swap "$conf" '      selection: candidate' '      selection: ${inputs.environments}'
refused '`assessments.conformance.target.selection` takes one value' "the selection of a target is a list input"

copy input-for-mapping
swap "$conf" "$set_rule" '    condition: ${inputs.subject}'
refused '`requirements.no-case-lost.condition` is a `ratchet.specification.Condition`, and an input stands for a scalar or a list of scalars' "a condition is a reference"

copy input-text-for-decimal
swap "$differ" "$limit" '      value: ${inputs.subject}'
refused 'takes `Decimal`, and the input `subject` has the type `string`' "the limit of a condition is a text input"

copy input-text-for-integer
swap "$conf" '      kind: snapshot' '      kind: snapshot\n      runs: ${inputs.subject}'
refused 'takes `Integer`, and the input `subject` has the type `string`' "the runs of an observation are a text input"

copy input-integer-for-text
swap "$differ" '    subject: ${inputs.subject}' '    subject: ${inputs.different_limit}'
refused 'takes `ratchet.specification.SubjectName`, and the input `different_limit` has the type `integer`' "the subject of an assessment is an integer input"

copy input-text-for-boolean
own_spec
edit_spec specification.yaml '
  /^  - name: / { t = $3 }
  t == "ratchet.specification.AssessmentPlan" && $0 == "        type: ratchet.specification.SubjectName" { print "        type: Boolean"; next }
  { print }'
refused 'takes `Boolean`, and the input `subject` has the type `string`' "the specification makes the subject of a plan a boolean, and the presets pass a text input"

copy input-default-integer
swap "$differ" '    different_limit: {type: integer, required: true}' '    different_limit: {type: integer, required: true, default: banana}'
refused '`preset.inputs.different_limit.default` is no integer, and its input has the type `integer`' "the default of an integer input is a word"

copy input-default-decimal
swap "$differ" '    different_limit: {type: integer, required: true}' '    different_limit: {type: decimal, required: true, default: 1e3}'
refused '`preset.inputs.different_limit.default` is no decimal without exponent' "the default of a decimal input is 1e3"

copy input-default-boolean
swap "$differ" '    subject: {type: string, required: true}' '    subject: {type: string, required: true}\n    strict: {type: boolean, required: false, default: "true"}'
refused '`preset.inputs.strict.default` is not `true` or `false`, and its input has the type `boolean`' "the default of a boolean input is the text \"true\""

copy input-default-text
swap "$conf" '    subject: {type: string, required: true}' '    subject: {type: string, required: true, default: 3}'
refused '`preset.inputs.subject.default` is no text, and its input has the type `string`' "the default of a text input is the integer 3"

copy input-default-no-list
swap "$conf" '    environments: {type: string, list: true, required: true}' '    environments: {type: string, list: true, required: true, default: ci}'
refused '`preset.inputs.environments.default` is no list, and its input has the type a list of `string`' "the default of a list input is one word"

copy input-default-item
swap "$conf" '    environments: {type: string, list: true, required: true}' '    environments: {type: string, list: true, required: true, default: [ci, 3]}'
refused '`preset.inputs.environments.default` holds an item that is no text' "the default of a list of text holds the integer 3"

copy input-default-list-for-scalar
swap "$conf_d" '  report: {type: path, required: true}' '  report: {type: path, required: true, default: [report.json]}'
refused '`inputs.report.default` is a list and no scalar, and its input has the type `path`' "the default of a path input of a declaration is a list"

# -- names inside a preset -----------------------------------------------------------------------

copy name-assessment
swap "$conf" '    assessment: conformance' '    assessment: conformances'
refused '`requirements.no-case-lost` names the assessment `conformances`, which the preset does not hold' "a requirement names the assessment conformances"

copy name-measurement
swap "$conf" '    measurement: passing-cases' '    measurement: passing'
refused 'names the measurement `passing`, which the assessment `conformance` does not hold' "a requirement names the measurement passing"

copy name-no-measurement
drop "$conf" "$of_failed"
refused '`requirements.failed-does-not-rise` names no measurement, and the assessment `conformance` holds 5' "a requirement names no measurement of an assessment with five"

copy name-statement
swap "$conf" "$meaning" "$meaning"'\n    serves: [nothing]'
refused '`requirements.no-case-lost` serves the statement `nothing`, which the preset does not hold' "a requirement serves a statement the preset does not hold"

# -- a preset against the declaration of its assessor -------------------------------------------

copy assessor-absent
rm "$c/$conf_d"
refused 'names the assessor `conformance-report@1`, and the directory holds no `conformance-report@1.assessor.yaml`' "the declaration of conformance-report@1 is absent"

copy assessor-target-kind
swap "$conf" '      kind: revision' '      kind: deployment'
refused '`assessments.conformance.target.kind` is `deployment`, and `conformance-report@1` declares the targets `[revision]`' "a plan has a target of the kind deployment"

copy assessor-input
swap "$conf" "$passes" '      reports: ${inputs.report}'
refused 'passes the input `reports`, which `conformance-report@1` does not declare' "an assessment passes the input reports"

copy assessor-input-absent
swap "$conf_d" '  report: {type: path, required: true}' '  report: {type: path, required: true}\n  suite: {type: string, required: true}'
refused '`assessments.conformance` passes no `suite`, which `conformance-report@1` requires' "a declaration requires an input the assessment does not pass"

copy assessor-input-local
swap "$conf_d" '  report: {type: path, required: true}' '  report: {type: path, required: true, local: true}'
refused 'passes the input `report`, which `conformance-report@1` declares local' "an assessment passes an input its assessor declares local"

copy assessor-input-type
swap "$differ" "$passes" '      report: ${inputs.different_limit}'
refused 'passes the input `different_limit` of the preset, `integer`, and `comparison-report@1` declares the input `report` as `path`' "an assessment passes an integer input where a path is declared"

copy assessor-input-list
swap "$conf" "$passes" '      report: ${inputs.environments}'
refused 'passes the input `environments` of the preset, a list of `string`, and `conformance-report@1` declares the input `report` as `path`' "an assessment passes a list input where one path is declared"

copy assessor-input-literal
swap "$conf" "$passes" '      report: 3'
refused '`assessments.conformance.inputs.report` is no text, and `conformance-report@1` declares the input `report` as `path`' "an assessment passes the integer 3 where a path is declared"

copy assessor-output
swap "$conf" '        output: passing_cases' '        output: passing'
refused 'names the output `passing`, which `conformance-report@1` does not declare' "a measurement names the output passing"

copy assessor-input-list-of-its-type
swap "$conf" '    report: {type: path, required: true}' '    report: {type: path, list: true, required: true}'
refused 'passes the input `report` of the preset, a list of `path`, and `conformance-report@1` declares the input `report` as `path`' "an assessment passes a list of paths where one path is declared"

copy assessor-kind
swap "$conf" '        kind: exact' '        kind: sampled' 3
refused '`assessments.conformance.measurements.failed` has the kind `sampled`, and the output `failed` of `conformance-report@1` declares `exact`' "a measurement of an exact output has the kind sampled"

copy assessor-unit-other
swap "$conf" '        unit: cases' '        unit: case'
refused 'states the unit `case`, and the output `passed` of `conformance-report@1` declares `cases`' "a measurement has the unit case"

copy assessor-unit-absent
drop "$conf" '        unit: cases'
refused 'has no `unit`, and the output `passed` of `conformance-report@1` declares `cases`' "a measurement of a count has no unit"

copy assessor-unit-undeclared
swap "$conf" '        identity: [case_id]' '        identity: [case_id]\n        unit: cases'
refused 'states the unit `cases`, and the output `passing_cases` of `conformance-report@1` declares none' "a measurement of a set has a unit"

copy assessor-scope
swap "$conf" '        scope: run' '        scope: case' 2
refused 'has the scope `case`, which the output `passed` of `conformance-report@1` does not declare' "a measurement has the scope case"

copy assessor-boundary
swap "$conf" '        output: failed' '        output: failed\n        boundary: run_time'
refused 'has the boundary `run_time`, which the output `failed` of `conformance-report@1` does not declare' "a measurement has a boundary its output does not declare"

copy assessor-identity-key
swap "$conf" '        identity: [case_id]' '        identity: [case_id, suite]'
refused 'states the identity key `[case_id, suite]`, and the output `passing_cases` of `conformance-report@1` declares `[case_id]`' "a measurement has the identity key case_id and suite"

copy assessor-identity-of-a-number
swap "$conf" '        output: failed' '        output: failed\n        identity: [case_id]'
refused 'states an identity key, and the output `failed` of `conformance-report@1` declares none' "a measurement of a number states an identity key"

copy assessor-filter-field
swap "$differ" '        filter: {class: [different]}' '        filter: {result: [different]}'
refused 'filters by the field `result`, which the output `cases` of `comparison-report@1` does not declare for its items' "a measurement filters by the field result"

# -- a requirement against the value type of its output -----------------------------------------

copy compare-holds-on-a-set
swap "$conf" "$set_rule" '    condition: {operator: holds}'
refused '`requirements.no-case-lost` has the operator `holds`, which takes an assertion, and the output `passing_cases` of `conformance-report@1` has the value type `identity_set`' "a requirement on a set has the operator holds"

copy compare-set-operator-on-a-number
swap "$conf" "$accepted_value" '    condition: {operator: no_new_items}' 3
refused '`requirements.failed-does-not-rise` has the operator `no_new_items`, which takes an identity set, and the output `failed` of `conformance-report@1` has the value type `number`' "a requirement on a number has the operator no_new_items"

copy compare-set-operator-without-reference
drop "$conf" "$accepted_value"
refused '`requirements.no-case-lost` has the operator `no_lost_items` and no reference of the kind `accepted_value`' "a requirement with no_lost_items has no reference"

copy compare-limit-on-an-assertion
swap "$differ_d" '    value_type: identity_set' '    value_type: assertion'
refused '`requirements.different-cases-within-limit` has the operator `lte`, which takes a number or the number of items of a set, and the output `cases` of `comparison-report@1` has the value type `assertion`' "a requirement with lte reads an output that is an assertion"

copy compare-limit-without-value
swap "$conf" "$accepted_value" '    condition: {operator: lte}' 3
refused '`requirements.failed-does-not-rise` has the operator `lte` and no `value`' "a requirement with lte has no value"

copy compare-value-without-limit
swap "$conf" "$set_rule" '    condition: {operator: no_lost_items, value: 3}'
refused '`requirements.no-case-lost` has the operator `no_lost_items`, which takes no `value`' "a requirement with no_lost_items has a value"

copy compare-condition-on-a-digest
swap "$differ_d" '    value_type: identity_set' '    value_type: digest'
refused '`requirements.different-cases-within-limit` has a condition, and the output `cases` of `comparison-report@1` has the value type `digest`, which takes none' "a requirement with a condition reads an output that is a digest"

copy compare-unit-other
swap "$conf" "$accepted_value" '    condition: {operator: lte, value: 3, unit: seconds}' 3
refused '`requirements.failed-does-not-rise` has a condition in the unit `seconds`, and the output `failed` of `conformance-report@1` declares `cases`' "a condition has another unit than its output"

copy compare-unit-absent
swap "$conf" "$accepted_value" '    condition: {operator: lte, value: 3}' 3
refused '`requirements.failed-does-not-rise` has a condition without a `unit`, and the output `failed` of `conformance-report@1` declares `cases`' "a condition on an output with a unit has none"

copy compare-unit-undeclared
swap "$differ" "$limit" "$limit"'\n      unit: cases'
refused '`requirements.different-cases-within-limit` has a condition in the unit `cases`, and the output `cases` of `comparison-report@1` declares none' "a condition on the number of items of a set has a unit"

copy compare-reference-of-an-assertion
swap "$conf_d" "$number_output" '  failed: {value_type: assertion, kind: exact, scopes: [], unit: cases}'
refused '`requirements.failed-does-not-rise` has a reference, and the output `failed` of `conformance-report@1` has the value type `assertion`, which takes none' "a requirement with a reference reads an output that is an assertion"

copy compare-reference-of-a-digest
swap "$conf_d" "$number_output" '  failed: {value_type: digest, kind: exact, scopes: [], unit: cases}'
refused '`requirements.failed-does-not-rise` has the reference `accepted_value`, and the output `failed` of `conformance-report@1` has the value type `digest`, which takes `generated`' "a requirement with an accepted value reads an output that is a digest"

copy compare-reference-of-a-number
swap "$conf" "$accepted_value" '    reference: {kind: generated}' 3
refused '`requirements.failed-does-not-rise` has the reference `generated`, and the output `failed` of `conformance-report@1` has the value type `number`, which takes `accepted_value`' "a requirement on a number has the reference generated"

copy compare-set-without-condition
drop "$conf" "$set_rule"
refused '`requirements.no-case-lost` compares a set with a reference and has no condition' "a requirement on a set has a reference and no operator"

copy compare-number-without-better
drop "$conf" '        better: lower'
refused '`assessments.conformance.measurements.failed` states no `better`, and `requirements.failed-does-not-rise` compares it with a reference' "a number that is compared with a reference states no better"

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

# A row whose cell <n> is <text>: cell 1 is the name.
cell() {
  edit "$page" "$the_row"' { n = split($0, cell, /\|/); cell['"$(($1 + 1))"'] = "'"$2"'"; printf "|%s|%s|%s|%s|%s|\n", cell[2], cell[3], cell[4], cell[5], cell[6]; next } { print }'
}

copy row-direction-empty
cell 2 ' '
refused 'the cell `Direction` of the row `conformance-cases@1/conformance/skipped` is empty' "the direction of a row is empty"

copy row-unit-empty
cell 3 ''
refused 'the cell `Unit` of the row `conformance-cases@1/conformance/skipped` is empty' "the unit of a row is empty"

copy row-tolerance-empty
cell 4 '  '
refused 'the cell `Tolerance` of the row `conformance-cases@1/conformance/skipped` is empty' "the tolerance of a row is empty"

copy row-evidence-empty
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

copy row-in-code-fence
edit "$page" "$the_row"' { row = $0; next } { print } END { printf "\n```text\n'"$table"'%s\n```\n", row }'
refused 'the measurement `conformance-cases@1/conformance/skipped` has no row on a page of the directory' "the row of a measurement stands in a code fence"

copy row-in-tilde-fence
edit "$page" "$the_row"' { row = $0; next } { print } END { printf "\n~~~\n'"$table"'%s\n~~~\n", row }'
refused 'the measurement `conformance-cases@1/conformance/skipped` has no row on a page of the directory' "the row of a measurement stands in a code fence of tildes"

copy row-in-html-comment
edit "$page" "$the_row"' { row = $0; next } { print } END { printf "\n<!--\n'"$table"'%s\n-->\n", row }'
refused 'the measurement `conformance-cases@1/conformance/skipped` has no row on a page of the directory' "the row of a measurement stands in an HTML comment"

copy row-after-html-comment
edit "$page" "$the_row"' { print "<!-- " $0 " -->" $0; next } { print }'
accepts "a row follows an HTML comment that ends on its line"

copy row-on-another-page
edit "$page" "$the_row"' { next } { print }'
{
  printf '# Other\n\n'"$table"
  grep -F '| `conformance-cases@1/conformance/skipped` |' "$catalog/functional.md"
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
