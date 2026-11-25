#!/bin/sh
# The preset catalog `presets/` is what the specification declares (spec/domains/*.yaml), and
# every measurement of a preset has its row on a page of the directory.
#
# Nothing else in the gate reads a `ratchet/1` file. A field renamed in the specification, a
# preset that names an output its assessor no longer declares, and a measurement that the page
# of its family leaves out would each stay green.
#
# What a directory of the catalog holds, and what is checked:
#   file      every entry is a regular file: `README.md`, a page `<family>.md`, or a file
#             `<name>@<version>.<kind>.yaml` whose kind is a value of
#             `ratchet.config.CatalogFileKind` and whose name and version are those the file
#             states. The directory holds a `README.md` and at least one preset
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
#             text, so `version: 1` is refused and `version: "1"` is read. An enum: one of
#             its variants. List: a list. Map and struct: a mapping
#   required  a mapping of a struct has every field that is not `Optional<...>`. A requirement
#             may leave `serves` out (spec/README.md)
#   inputs    no input of a preset is local. A scalar that holds `${` is `${inputs.<name>}`
#             alone, `<name>` is a declared input of the preset, and the type of the input
#             fits the place (`ratchet.specification.InputReference`)
#   names     a requirement names an assessment of its preset and a measurement of that
#             assessment, and the statements it serves are statements of the preset
#   assessor  the assessor of an assessment has its declaration in the directory, and an input
#             the assessment passes is an input of the declaration. A measurement names an
#             output of it, the unit of that output or none where it has none, the scope `run`
#             or one the output declares, the identity key the output declares, and in a
#             `filter` only fields the output declares for its items
#   row       a measurement is named `<name>@<version>/<assessment>/<measurement>`. It has one
#             row in the tables of the pages, the rows of one preset stand on one page, the
#             four cells after the name are not empty, and a row names a measurement. A table
#             is found by its header line `| Measurement | Direction | Unit | Tolerance |
#             Evidence |`, and a page holds at least one with a row
# Not checked: the invariants of the types, which `ess generate synthesize` writes as Rust;
# the value of a `Json`; the text of the four cells against the preset; a boundary against
# the declaration; that an assessment passes every required input of its assessor; the values
# of a `filter`, which no declaration lists.
#
# This is no YAML reader. It reads the forms the catalog is written in and fails on a line of
# another form: a mapping by indentation (`key:` and `key: value`), a flow mapping
# `{key: value, ...}` and a flow list `[...]` on one line, plain scalars, and quoted scalars
# without an escape. A list is a flow list; a comment has a line of its own.
#
# Usage:
#   sh spec/presets.test.sh                      `presets/`, then one broken copy per rule
#   sh spec/presets.test.sh --catalog <directory> [--spec <directory>]
#                                                one directory, against `spec/domains` or the
#                                                named directory of domain files; no copy
# Work files go to the ignored target/presets. It needs nothing but POSIX sh and awk.
#
# Exit 0: the last line is
#   `presets: <f> of <f> file(s) valid, <r> of <r> measurement(s) with a row, <c> of <c> broken copies refused`
# (with `--catalog`, without the third count). `<f>` counts the presets, the declarations and
# the pages, and not `README.md`; `<r>` counts the measurements of the presets.
# Exit 1: each failure is named with its file and line; or a broken copy is accepted, or
# refused without the message of its rule.
set -eu

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

# check_catalog <directory>: the failures of the directory and the line with the two counts.
check_catalog() {
  dir=$1
  if [ ! -d "$dir" ]; then
    echo "presets: $dir is no directory; the catalog is the directory presets/ of the repository"
    return 1
  fi
  [ -d "$spec" ] || { echo "presets: $spec is no directory of domain files"; return 1; }
  # Absolute paths: awk reads an operand of the form `name=value` as an assignment.
  dir=$(CDPATH= cd -- "$dir" && pwd)
  spec=$(CDPATH= cd -- "$spec" && pwd)
  others=
  readme=0
  set --
  for f in "$spec"/*.yaml; do
    [ -r "$f" ] || { echo "presets: cannot read the specification, $spec/*.yaml"; return 1; }
    set -- "$@" reading=spec "$f"
  done
  for f in "$dir"/* "$dir"/.[!.]*; do
    [ -e "$f" ] || [ -L "$f" ] || continue
    name=${f##*/}
    if [ -L "$f" ] || [ ! -f "$f" ] || [ ! -s "$f" ]; then
      others="$others/$name"
      continue
    fi
    case $name in
      *[!A-Za-z0-9@._-]*) others="$others/$name" ;;
      README.md) readme=1 ;;
      *.yaml) set -- "$@" reading=yaml "$f" ;;
      *.md) set -- "$@" reading=page "$f" ;;
      *) others="$others/$name" ;;
    esac
  done

  awk -v others="$others" -v readme="$readme" '
  function unopt(t) { return (t ~ /^Optional</) ? substr(t, 10, length(t) - 10) : t }
  function base(t) { while (kind[t] == "newtype") t = of[t]; return t }
  function is_struct(t) { return kind[t] == "struct" || kind[t] == "entity" }
  function trim(s) { sub(/^ +/, "", s); sub(/ +$/, "", s); return s }
  function short(f) { sub(/^.*\//, "", f); return f }
  function shown(path) { gsub(SEP "\\[", "[", path); gsub(SEP, ".", path); return path }
  function under(path, step) { return path == "" ? step : path SEP step }
  function fail(file, line, msg) { printf "%s:%d: %s\n", short(file), line, msg; failed++; bad[file] = 1 }
  function norule(msg) { fail(FILE, FNR, "not read: " msg) }
  function text(file, path) { return ((file, path) in at) ? n_text[at[file, path]] : "" }
  # The items of the list at `path`, as `[a, b]`.
  function items(file, path,    j, s) {
    s = ""
    for (j = 1; ((file, path SEP "[" j "]") in at); j++) s = s (j > 1 ? ", " : "") text(file, path SEP "[" j "]")
    return "[" s "]"
  }
  function variants(type,    i, s) {
    s = ""
    for (i = 1; i <= vcount[type]; i++) s = s (i > 1 ? ", " : "") "`" vorder[type, i] "`"
    return s
  }

  # ---- the YAML forms this script reads -------------------------------------------------

  # A node of the file at `path`: a mapping, a list or a scalar. A key without a value on
  # its line is `pending` until the first line under it says what it holds.
  function node(path, k, x, q,    id) {
    if ((FILE, path) in at) id = at[FILE, path]
    else { id = ++nn; at[FILE, path] = id; n_file[id] = FILE; n_line[id] = FNR; n_path[id] = path }
    n_kind[id] = k; n_text[id] = x; n_quoted[id] = q
  }

  # The path of the key `key` in the mapping at `parent`; "" when the key stands there twice.
  function child(parent, key,    p) {
    p = under(parent, key)
    if ((FILE, p) in at) { norule("the key `" shown(p) "` stands twice in its mapping"); return "" }
    nkeys[FILE, parent]++
    return p
  }

  # 1 when the line holds a comment after a value: ` #` outside a quoted scalar.
  function comment(s,    i, c, q, prev) {
    q = ""; prev = " "
    for (i = 1; i <= length(s); i++) {
      c = substr(s, i, 1)
      if (q != "") { if (c == q) q = "" }
      else if ((c == "\"" || c == "\047") && (prev == " " || prev == "[" || prev == "{" || prev == ",")) q = c
      else if (c == "#" && prev == " ") return 1
      prev = c
    }
    return 0
  }

  # The parts of `s` between commas that lie in no bracket and no quote; the number of parts,
  # -1 when a bracket or a quote does not close.
  function parts(s, out,    n, i, c, depth, quote, cur, prev) {
    split("", out)
    n = 0; depth = 0; quote = ""; cur = ""; prev = " "
    for (i = 1; i <= length(s); i++) {
      c = substr(s, i, 1)
      if (quote != "") { if (c == quote) quote = ""; cur = cur c; prev = c; continue }
      if ((c == "\"" || c == "\047") && (prev == " " || prev == "[" || prev == "{" || prev == ",")) { quote = c; cur = cur c; prev = c; continue }
      if (c == "{" || c == "[") depth++
      if (c == "}" || c == "]") depth--
      if (depth < 0) return -1
      if (c == "," && depth == 0) { out[++n] = trim(cur); cur = ""; prev = c; continue }
      cur = cur c; prev = c
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

  function scalar(path, s, inflow,    c, inner) {
    c = substr(s, 1, 1)
    if (c == "\"" || c == "\047") {
      inner = substr(s, 2, length(s) - 2)
      if (length(s) < 2 || substr(s, length(s), 1) != c || index(inner, c) > 0 || (c == "\"" && index(inner, "\\") > 0)) {
        norule("the quoted scalar of `" shown(path) "` does not end at its quote, or holds a quote or an escape")
        return
      }
      node(path, "str", inner, 1)
      return
    }
    if (s ~ /^[]|>&*!%@`,}#]/ || s ~ /^[-?:]( |$)/) { norule("the value `" s "` of `" shown(path) "` is in a form this script does not read"); return }
    if (index(s, ": ") > 0 || s ~ /:$/) { norule("the plain scalar of `" shown(path) "` holds `: `; quote it"); return }
    if (inflow && s ~ /[][{}]/) { norule("the plain scalar `" s "` of `" shown(path) "` holds a bracket or a brace inside a flow collection; quote it"); return }
    node(path, plain_kind(s), s, 0)
  }

  function value(s, path, inflow) {
    if (s ~ /^[{]/) flow_map(s, path)
    else if (s ~ /^\[/) flow_list(s, path)
    else scalar(path, s, inflow)
  }

  function flow_map(s, path,    n, i, item, k, rest, p) {
    if (s !~ /[}]$/) { norule("the flow mapping of `" shown(path) "` does not close on its line"); return }
    n = parts(substr(s, 2, length(s) - 2), item)
    if (n < 0) { norule("a bracket or a quote of `" shown(path) "` does not close"); return }
    node(path, "map", "", 0)
    for (i = 1; i <= n; i++) {
      if (!match(item[i], /^[A-Za-z0-9_.@-]+:( |$)/)) { norule("`" item[i] "` in the flow mapping of `" shown(path) "` is no `key: value`"); continue }
      k = substr(item[i], 1, RLENGTH); sub(/: ?$/, "", k)
      rest = trim(substr(item[i], RLENGTH + 1))
      p = child(path, k)
      if (p == "") continue
      if (rest == "") { norule("`" shown(p) "` has no value"); continue }
      value(rest, p, 1)
    }
  }

  function flow_list(s, path,    n, i, item) {
    if (s !~ /\]$/) { norule("the flow list of `" shown(path) "` does not close on its line"); return }
    n = parts(substr(s, 2, length(s) - 2), item)
    if (n < 0) { norule("a bracket or a quote of `" shown(path) "` does not close"); return }
    node(path, "list", "", 0)
    for (i = 1; i <= n; i++) {
      if (item[i] == "") { norule("the flow list of `" shown(path) "` holds an empty item"); continue }
      value(item[i], path SEP "[" i "]", 1)
    }
  }

  # ---- the declared type of a node --------------------------------------------------------

  # The declared type at `path` of a file of the kind `fk`; "Json" under free JSON; "" with
  # `why` set where the last step has no place, and "" without it where an earlier step has
  # none (that step is named at its own node).
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
        if (t !~ /^List</) { why = (i == n) ? "is an item of a list where `" t "` is declared" : ""; return "" }
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
      } else { why = (i == n) ? "is a key of a mapping where `" t "` is declared" : ""; return "" }
    }
    return t
  }

  function kind_name(k) { return k == "int" ? "integer" : k == "float" ? "number" : k == "bool" ? "boolean" : k }

  # "" when the node fits the declared type `t`, or what is wrong.
  function misfit(t, k, x, q,    b) {
    t = unopt(t)
    if (t == "Json") return ""
    if (k == "null") return "is null; an absent member is left out"
    if (t ~ /^List</) return k == "list" ? "" : "is not a list (`" t "`)"
    if (t ~ /^Map<String, / || is_struct(t)) return k == "map" ? "" : "is not a mapping (`" t "`)"
    if (k == "map" || k == "list") return "is a " (k == "map" ? "mapping" : "list") " where `" t "` is declared"
    b = base(t)
    if (b == "Integer") return (k == "int" && x ~ /^-?[0-9]+$/) ? "" : "is not an integer (`" t "`)"
    if (b == "Boolean") return (k == "bool" && (x == "true" || x == "false")) ? "" : "is not `true` or `false` (`" t "`)"
    if (b == "Decimal") return ((k == "int" || k == "float" || (k == "str" && q)) && x ~ /^-?[0-9]+([.][0-9]+)?$/) ? "" : "is not a decimal without exponent and sign `+` (`" t "`)"
    if (kind[b] == "enum") {
      if (k != "str") return "is a YAML " kind_name(k) " where a value of " b " is declared"
      return ((b, x) in variant) ? "" : "is `" x "`, which is no value of " b
    }
    if (b == "String" || b == "Timestamp" || b == "Duration") return k == "str" ? "" : "is a YAML " kind_name(k) " where text is declared (`" t "`); quote it"
    return "has the declared type `" t "`, which spec/presets.test.sh has no rule for"
  }

  # The fields the struct `u` requires, at the mapping of the node at `path`.
  function required(F, line, path, u,    j, f) {
    for (j = 1; j <= count[u]; j++) {
      f = order[u, j]
      if (ftype[u, f] ~ /^Optional</) continue
      if ((u in entry) && f == "project") continue
      if ((u, f) in may_be_absent) continue
      if (!((F, under(path, f)) in at)) fail(F, line, "`" (path == "" ? "(root)" : shown(path)) "` has no `" f "`, which " u " requires")
    }
  }

  # A scalar that holds `${`: a reference to an input of the preset.
  function reference(i, F, fk, path, t,    x, name, ip, it, il, u, e, b, ok, here) {
    x = n_text[i]
    here = "`" shown(path) "` "
    if (x !~ /^[$][{]inputs[.][A-Za-z0-9_-]+[}]$/) { fail(F, n_line[i], here "holds `${` and is not `${inputs.<name>}` alone: a reference to an input is the whole of a value"); return }
    name = substr(x, 10, length(x) - 10)
    if (fk != "preset") { fail(F, n_line[i], here "refers to the input `" name "`, and only a preset declares inputs to refer to"); return }
    if (path == "preset" || index(path, "preset" SEP) == 1) { fail(F, n_line[i], here "is a reference inside the `preset` block, which holds none"); return }
    ip = "preset" SEP "inputs" SEP name
    if (!((F, ip) in at)) { fail(F, n_line[i], here "refers to the input `" name "`, which the preset does not declare"); return }
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

  BEGIN {
    SEP = "\037"
    HEADER = "| Measurement | Direction | Unit | Tolerance | Evidence |"
    # spec/README.md, "How a `ratchet/1` file differs from the declared entities".
    may_be_absent["ratchet.specification.QualityRequirement", "serves"] = 1
  }

  # ---- spec/domains/*.yaml: kinds, newtypes, variants, fields and relations ----------------
  reading == "spec" {
    if ($0 ~ /^entities:/) { in_entities = 1; next }
    if ($0 ~ /^types:/) { in_entities = 0; next }
    if ($0 ~ /^  - name: /) {
      type = $3; in_fields = 0; in_variants = 0; in_relations = 0; field = ""; rel = ""
      kind[type] = in_entities ? "entity" : ""
      next
    }
    if ($0 ~ /^    kind: / && !in_entities) { kind[type] = $2; next }
    if ($0 ~ /^    of: /) { of[type] = $2; next }
    if ($0 ~ /^    variants: \[/) {
      v = $0; sub(/^    variants: \[/, "", v); sub(/\].*$/, "", v)
      n = split(v, list, / *, */)
      for (i = 1; i <= n; i++) { variant[type, list[i]] = 1; vorder[type, ++vcount[type]] = list[i] }
      next
    }
    if ($0 ~ /^    variants:/) { in_variants = 1; in_fields = 0; in_relations = 0; next }
    if ($0 ~ /^    undeclared_fields: ignored/) { open[type] = 1; next }
    if ($0 ~ /^    fields:/) { in_fields = 1; in_variants = 0; in_relations = 0; next }
    if ($0 ~ /^    relations:/) { in_relations = 1; in_fields = 0; in_variants = 0; next }
    if ($0 ~ /^    [a-z_]+:/) { in_fields = 0; in_variants = 0; in_relations = 0; next }
    if (in_variants && $0 ~ /^      - /) { variant[type, $2] = 1; vorder[type, ++vcount[type]] = $2; next }
    if (in_fields && $0 ~ /^      - name: /) { field = $3; order[type, ++count[type]] = field; next }
    if (in_fields && field != "" && $0 ~ /^        type: /) {
      t = $0; sub(/^        type: /, "", t)
      ftype[type, field] = t
      next
    }
    if (in_relations && $0 ~ /^      - name: /) { rel = $3; next }
    if (in_relations && rel != "" && $0 ~ /^        target: /) { target[type, rel] = $2; next }
    next
  }

  # The lists of the specification this script reads, once, before the first file of the
  # directory.
  (reading == "yaml" || reading == "page") && !lists_read {
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

  # ---- a YAML file of the directory -----------------------------------------------------
  reading == "yaml" {
    if (FNR == 1) {
      FILE = FILENAME; depth = 0
      yf[++ny] = FILE
      node("", "map", "", 0)
      b = short(FILE); stem = b; sub(/[.]yaml$/, "", stem)
      k = stem; sub(/^.*[.]/, "", k)
      if (index(stem, ".") == 0 || !(("ratchet.config.CatalogFileKind", k) in variant)) {
        fkind[FILE] = "unknown"
        fail(FILE, 1, "the file is no `<name>@<version>.<kind>.yaml` with a kind of ratchet.config.CatalogFileKind: " variants("ratchet.config.CatalogFileKind"))
      } else { fkind[FILE] = k; ident[FILE] = substr(stem, 1, length(stem) - length(k) - 1) }
    }
    if ($0 ~ /^ *$/ || $0 ~ /^ *#/) next
    if (index($0, "\t") > 0) { norule("a tab"); next }
    if (comment($0)) { norule("a comment after a value; a comment has a line of its own"); next }
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
    p = child(parent, k)
    if (p == "") next
    depth++; ind[depth] = indent; pth[depth] = p; opens[depth] = (rest == ""); state[depth] = ""; cind[depth] = ""
    if (rest == "") node(p, "pending", "", 0)
    else value(rest, p, 0)
    next
  }

  # ---- a page of the directory: the rows of its tables --------------------------------------
  reading == "page" {
    if (FNR == 1) { FILE = FILENAME; pg[++np] = FILE; in_table = 0 }
    if ($0 == HEADER) { in_table = 1; ruled = 0; tables[FILE]++; next }
    if (!in_table) next
    if ($0 !~ /^\|/) { in_table = 0; next }
    if (!ruled) {
      ruled = 1
      if ($0 !~ /^\|( *:?-+:? *\|)+ *$/) fail(FILE, FNR, "the line under the header of a table is no `| --- | ... |`")
      next
    }
    rows_in[FILE]++
    line = $0
    if (line !~ /\| *$/) { fail(FILE, FNR, "a row does not end with `|`"); next }
    sub(/^\| */, "", line); sub(/ *\| *$/, "", line)
    n = split(line, cell, /\|/)
    if (n != 5) { fail(FILE, FNR, "a row has " n " cells; a row has 5, and no cell holds `|`"); next }
    for (i = 1; i <= 5; i++) cell[i] = trim(cell[i])
    if (cell[1] !~ /^`[^`]+`$/) { fail(FILE, FNR, "the first cell of a row is `" cell[1] "`; it is the name of a measurement between backticks, `<name>@<version>/<assessment>/<measurement>`"); next }
    id = substr(cell[1], 2, length(cell[1]) - 2)
    rw[++nr] = id; rw_file[nr] = FILE; rw_line[nr] = FNR
    row_count[id]++
    row_page[id] = FILE
    filled = 1
    for (i = 2; i <= 5; i++) if (cell[i] == "") {
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

    # The entries that are no file of a catalog.
    no = split(others, other, "/")
    for (i = 2; i <= no; i++) {
      printf "%s: the entry is no regular file with text in it and a name of letters, digits, `@`, `.`, `_` and `-`, or it is no preset, no declaration and no page\n", other[i]
      failed++; bad_others++
    }
    if (!readme) { print "README.md: the directory holds no README.md"; failed++ }

    # The name and the version a file states.
    for (y = 1; y <= ny; y++) {
      F = yf[y]; fk = fkind[F]
      if (fk == "preset") { id = text(F, "preset" SEP "name") "@" text(F, "preset" SEP "version"); presets++ }
      else if (fk == "assessor") id = text(F, "name") "@" text(F, "version")
      else continue
      stated[F] = id
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
          if (!((F, "format") in at)) fail(F, 1, "`(root)` has no `format`")
          else if (text(F, "format") != "ratchet/1") fail(F, n_line[at[F, "format"]], "`format` is not `ratchet/1`")
          if (!((F, "preset") in at)) fail(F, 1, "`(root)` has no `preset` block")
        }
        continue
      }
      why = ""
      t = decl_type(fk, path)
      if (t == "") { if (why != "") fail(F, n_line[i], "`" shown(path) "` " why); continue }
      k = n_kind[i]
      if (k == "pending") { fail(F, n_line[i], "`" shown(path) "` has no value"); continue }
      if (k != "map" && k != "list" && index(n_text[i], "${") > 0) { reference(i, F, fk, path, t); continue }
      m = misfit(t, k, n_text[i], n_quoted[i])
      if (m != "") { fail(F, n_line[i], "`" shown(path) "` " m); continue }
      u = unopt(t)
      if (is_struct(u)) required(F, n_line[i], path, u)
    }

    # What joins two places of the directory.
    for (i = 1; i <= nn; i++) {
      F = n_file[i]
      if (fkind[F] != "preset") continue
      path = n_path[i]
      n = split(path, s, SEP)

      if (n == 4 && s[1] == "preset" && s[2] == "inputs" && s[4] == "local" && n_text[i] == "true")
        fail(F, n_line[i], "the input `" s[3] "` is local, and a preset declares no local input (`preset_input_local`)")

      if (n == 3 && s[1] == "assessments" && s[3] == "assessor" && !(n_text[i] in declaration))
        fail(F, n_line[i], "`" shown(path) "` names the assessor `" n_text[i] "`, and the directory holds no `" n_text[i] ".assessor.yaml`")

      if (n == 4 && s[1] == "assessments" && s[3] == "inputs") {
        a = text(F, "assessments" SEP s[2] SEP "assessor")
        if ((a in declaration) && !((declaration[a], "inputs" SEP s[4]) in at))
          fail(F, n_line[i], "`" shown(path) "` passes the input `" s[4] "`, which `" a "` does not declare")
      }

      if (n == 4 && s[1] == "assessments" && s[3] == "measurements") {
        id = stated[F] "/" s[2] "/" s[4]
        ms[++nm] = id; ms_file[nm] = F; ms_line[nm] = n_line[i]; ms_preset[nm] = stated[F]
        is_measurement[id] = 1
        a = text(F, "assessments" SEP s[2] SEP "assessor")
        o = text(F, path SEP "output")
        if (!(a in declaration) || o == "") continue
        D = declaration[a]
        op = "outputs" SEP o
        if (!((D, op) in at)) { fail(F, n_line[i], "`" shown(path) "` names the output `" o "`, which `" a "` does not declare"); continue }
        has_du = ((D, op SEP "unit") in at); du = text(D, op SEP "unit")
        has_mu = ((F, path SEP "unit") in at); mu = text(F, path SEP "unit")
        if (has_du && !has_mu) fail(F, n_line[i], "`" shown(path) "` has no `unit`, and the output `" o "` of `" a "` declares `" du "` (`unit_missing`)")
        else if (has_du && mu != du) fail(F, n_line[i], "`" shown(path) "` states the unit `" mu "`, and the output `" o "` of `" a "` declares `" du "` (`unit_mismatch`)")
        else if (!has_du && has_mu) fail(F, n_line[i], "`" shown(path) "` states the unit `" mu "`, and the output `" o "` of `" a "` declares none (`unit_not_declared`)")
        sc = text(F, path SEP "scope")
        if (sc != "" && sc != "run") {
          found = 0
          for (j = 1; ((D, op SEP "scopes" SEP "[" j "]") in at); j++) if (text(D, op SEP "scopes" SEP "[" j "]") == sc) found = 1
          if (!found) fail(F, n_line[i], "`" shown(path) "` has the scope `" sc "`, which the output `" o "` of `" a "` does not declare")
        }
        if ((F, path SEP "identity") in at) {
          mk = items(F, path SEP "identity"); dk = items(D, op SEP "identity_key")
          if (!((D, op SEP "identity_key") in at)) fail(F, n_line[i], "`" shown(path) "` states an identity key, and the output `" o "` of `" a "` declares none")
          else if (mk != dk) fail(F, n_line[i], "`" shown(path) "` states the identity key `" mk "`, and the output `" o "` of `" a "` declares `" dk "`")
        }
      }

      if (n == 6 && s[1] == "assessments" && s[3] == "measurements" && s[5] == "filter") {
        a = text(F, "assessments" SEP s[2] SEP "assessor")
        o = text(F, "assessments" SEP s[2] SEP "measurements" SEP s[4] SEP "output")
        op = "outputs" SEP o
        if (!(a in declaration) || o == "" || !((declaration[a], op) in at)) continue
        D = declaration[a]
        found = 0
        for (j = 1; ((D, op SEP "item_fields" SEP "[" j "]") in at); j++) if (text(D, op SEP "item_fields" SEP "[" j "]") == s[6]) found = 1
        if (!found) fail(F, n_line[i], "`" shown(path) "` filters by the field `" s[6] "`, which the output `" o "` of `" a "` does not declare for its items")
      }

      if (n == 2 && s[1] == "requirements") {
        ra = text(F, path SEP "assessment")
        if (ra != "") {
          if (!((F, "assessments" SEP ra) in at)) fail(F, n_line[i], "`" shown(path) "` names the assessment `" ra "`, which the preset does not hold")
          else if ((F, path SEP "measurement") in at) {
            rm = text(F, path SEP "measurement")
            if (!((F, "assessments" SEP ra SEP "measurements" SEP rm) in at)) fail(F, n_line[i], "`" shown(path) "` names the measurement `" rm "`, which the assessment `" ra "` does not hold")
          } else if (nkeys[F, "assessments" SEP ra SEP "measurements"] != 1)
            fail(F, n_line[i], "`" shown(path) "` names no measurement, and the assessment `" ra "` holds " (nkeys[F, "assessments" SEP ra SEP "measurements"] + 0))
        }
        for (j = 1; ((F, path SEP "serves" SEP "[" j "]") in at); j++) {
          st = text(F, path SEP "serves" SEP "[" j "]")
          if (!((F, "statements" SEP st) in at)) fail(F, n_line[i], "`" shown(path) "` serves the statement `" st "`, which the preset does not hold")
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

    total = ny + np + no - 1
    if (no == 0) total = ny + np
    good = total - bad_others
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
  check_catalog "$catalog"
  exit $?
fi

rm -rf "$work"
mkdir -p "$work"

if check_catalog "$catalog" > "$work/catalog.out" 2>&1; then :; else
  cat "$work/catalog.out"
  exit 1
fi
summary=$(tail -n 1 "$work/catalog.out")

# ---- one broken copy per rule ---------------------------------------------------------------
#
# Each case is a copy of presets/ under target/presets/<case> with one defect. The case holds
# when the check of the copy exits non-zero and names the defect with the words of its rule.

# copy <case>: a fresh copy; sets $c.
copy() {
  c=$work/$1
  mkdir -p "$c"
  cp -R "$catalog" "$c/presets"
  cp -R "$root/spec/domains" "$c/domains"
}

# edit <file of the copy> <awk program>: an edit that has to change the file.
edit() {
  [ -f "$c/$1" ] || { echo "presets: the case $(basename -- "$c") edits $1, which the copy does not hold" >&2; exit 1; }
  awk "$2" "$c/$1" > "$c/edit.new"
  if cmp -s "$c/$1" "$c/edit.new"; then
    echo "presets: the edit of the case $(basename -- "$c") changes nothing in $1" >&2
    exit 1
  fi
  mv "$c/edit.new" "$c/$1"
}

cases=0
accepted=0

# refused <the message of the rule> <what the copy holds>
refused() {
  cases=$((cases + 1))
  if sh "$self" --catalog "$c/presets" --spec "$c/domains" > "$c/check.out" 2>&1; then
    accepted=$((accepted + 1))
    echo "accepted: $(basename -- "$c"): $2"
    echo "  $(tail -n 1 "$c/check.out")"
  elif grep -F -q -e "$1" "$c/check.out"; then :
  else
    accepted=$((accepted + 1))
    echo "refused without the message of its rule: $(basename -- "$c"): $2"
    echo "  wanted: $1"
    sed 's/^/  /' "$c/check.out"
  fi
}

copy unchanged
if sh "$self" --catalog "$c/presets" --spec "$c/domains" > "$c/check.out" 2>&1; then :; else
  echo "presets: the unchanged copy of presets/ fails"
  cat "$c/check.out"
  exit 1
fi

cases_preset='conformance-cases@1.preset.yaml'
cases_declaration='conformance-report@1.assessor.yaml'
differential='differential-equality@1.preset.yaml'
page='functional.md'

# -- file ------------------------------------------------------------------------------------

copy file-of-no-kind
printf 'A note.\n' > "$c/presets/notes.txt"
refused "notes.txt: the entry is no regular file" "the directory holds notes.txt"

copy file-kind-undeclared
mv "$c/presets/$cases_preset" "$c/presets/conformance-cases@1.presets.yaml"
refused "is no \`<name>@<version>.<kind>.yaml\` with a kind of ratchet.config.CatalogFileKind" "a preset is named conformance-cases@1.presets.yaml"

copy file-name-preset
mv "$c/presets/$cases_preset" "$c/presets/conformance@1.preset.yaml"
refused "the file is named \`conformance@1.preset.yaml\` and states the name and the version \`conformance-cases@1\`" "the preset conformance-cases@1 is the file conformance@1.preset.yaml"

copy file-name-declaration
edit "presets/$cases_declaration" '
  /^version: "1"$/ { print "version: \"2\""; next }
  { print }'
refused "the file is named \`conformance-report@1.assessor.yaml\` and states the name and the version \`conformance-report@2\`" "the declaration conformance-report@1.assessor.yaml states the version 2"

copy file-readme-absent
rm "$c/presets/README.md"
refused "README.md: the directory holds no README.md" "the directory holds no README.md"

copy file-directory
mkdir "$c/presets/functional"
mv "$c/presets/$differential" "$c/presets/functional/"
refused "functional: the entry is no regular file" "a preset lies in a directory of the catalog"

# -- form ------------------------------------------------------------------------------------

copy form-block-list
edit "presets/$cases_preset" '
  /^        identity: \[case_id\]$/ { print "        identity:"; print "          - case_id"; next }
  { print }'
refused "not read: a block list" "an identity key is written as a block list"

copy form-key-twice
edit "presets/$cases_preset" '
  /^        output: passed$/ { print; print "        output: failed"; next }
  { print }'
refused "stands twice in its mapping" "a measurement holds the key output twice"

copy form-unquoted-reference
edit "presets/$cases_preset" '
  /^      report: [$][{]inputs[.]report[}]$/ { print "      {report: ${inputs.report}}"; next }
  { print }'
refused "holds a bracket or a brace inside a flow collection; quote it" "a reference stands plain in a flow mapping"

# -- place, type, required --------------------------------------------------------------------

copy key-preset
edit "presets/$cases_preset" '
  /^        better: higher$/ { sub(/better/, "improves") }
  { print }'
refused "\`assessments.conformance.measurements.passed.improves\` is not a field of ratchet.specification.Measurement" "a measurement holds the key improves"

copy key-declaration
edit "presets/$cases_declaration" '
  /^coverage_unit: / { sub(/coverage_unit/, "coverage_units") }
  { print }'
refused "\`coverage_units\` is not a field of ratchet.assessor.Assessor" "a declaration holds the key coverage_units"

copy key-renamed-in-specification
edit "domains/specification.yaml" '
  /^  - name: / { t = $3 }
  t == "ratchet.specification.Measurement" && $0 == "      - name: better" { print "      - name: improves"; next }
  { print }'
refused "\`assessments.conformance.measurements.passed.better\` is not a field of ratchet.specification.Measurement" "the specification names the field improves and the presets still write better"

copy value-preset
edit "presets/$cases_preset" '
  /operator: no_lost_items/ { sub(/no_lost_items/, "no_lost_item") }
  { print }'
refused "is \`no_lost_item\`, which is no value of ratchet.specification.ComparisonOperator" "a condition has the operator no_lost_item"

copy value-declaration
edit "presets/$cases_declaration" '
  /^    value_type: identity_set$/ { sub(/identity_set/, "set") }
  { print }'
refused "is \`set\`, which is no value of ratchet.specification.ValueType" "an output has the value type set"

copy value-format
edit "presets/$cases_preset" '
  /^format: ratchet\/1$/ { print "format: ratchet/2"; next }
  { print }'
refused "\`format\` is not \`ratchet/1\`" "a preset has the format ratchet/2"

copy type-text
edit "presets/$cases_preset" '
  /^  version: "1"$/ { print "  version: 1"; next }
  { print }'
refused "\`preset.version\` is a YAML integer where text is declared" "the version of a preset is the integer 1"

copy required-field
edit "presets/$cases_preset" '
  /^        output: passed$/ { next }
  { print }'
refused "\`assessments.conformance.measurements.passed\` has no \`output\`, which ratchet.specification.Measurement requires" "a measurement names no output"

# -- what a preset does not hold ---------------------------------------------------------------

copy preset-gate
printf '\ngates:\n  merge:\n    stage: pre-merge\n    qualifying_environments: [ci]\n    requires: [no-case-lost]\n' >> "$c/presets/$cases_preset"
refused "\`gates\` is no member of a preset" "a preset holds a gate"

copy preset-exception
printf '\nexceptions:\n  known-failing:\n    requirement: no-case-lost\n    item: {case_id: case-0042}\n    reason: The fix is planned.\n    owner: story:case-0042\n    expires: 2027-01-31\n' >> "$c/presets/$cases_preset"
refused "\`exceptions\` is no member of a preset" "a preset holds an exception"

copy preset-binding
printf '\npresets:\n  inner:\n    use: known-failures@1\n    digest: sha256:0000\n' >> "$c/presets/$cases_preset"
refused "\`presets\` is no member of a preset" "a preset binds a preset"

copy preset-project
edit "presets/$cases_preset" '
  /^  conformance:$/ { print; print "    project: orders-api"; next }
  { print }'
refused "\`assessments.conformance.project\` is the \`project\` of an entry" "an assessment of a preset states a project"

copy preset-local-input
edit "presets/$cases_preset" '
  /^    report: [{]type: path, required: true[}]$/ { print "    report: {type: path, required: true, local: true}"; next }
  { print }'
refused "the input \`report\` is local, and a preset declares no local input" "an input of a preset is local"

# -- references to inputs ----------------------------------------------------------------------

copy input-undeclared
edit "presets/$cases_preset" '
  /^      report: [$][{]inputs[.]report[}]$/ { print "      report: ${inputs.reports}"; next }
  { print }'
refused "refers to the input \`reports\`, which the preset does not declare" "an assessment refers to the input reports"

copy input-beside-text
edit "presets/$cases_preset" '
  /^      report: [$][{]inputs[.]report[}]$/ { print "      report: target/${inputs.report}"; next }
  { print }'
refused "is not \`\${inputs.<name>}\` alone" "a reference stands beside text"

copy input-type
edit "presets/$cases_preset" '
  /^      environments: [$][{]inputs[.]environments[}]$/ { print "      environments: ${inputs.report}"; next }
  { print }'
refused "takes a list (\`List<ratchet.specification.TargetClass>\`), and the input \`report\` declares no \`list\`" "the classes of a target are one path"

copy input-in-declaration
edit "presets/$cases_declaration" '
  /^command: / { print "command: ${inputs.command}"; next }
  { print }'
refused "refers to the input \`command\`, and only a preset declares inputs to refer to" "a declaration refers to an input"

# -- names inside a preset -----------------------------------------------------------------------

copy name-assessment
edit "presets/$cases_preset" '
  /^  no-case-lost:$/ { f = 1 }
  f && /^    assessment: conformance$/ { print "    assessment: conformances"; f = 0; next }
  { print }'
refused "\`requirements.no-case-lost\` names the assessment \`conformances\`, which the preset does not hold" "a requirement names the assessment conformances"

copy name-measurement
edit "presets/$cases_preset" '
  /^    measurement: passing-cases$/ { print "    measurement: passing"; next }
  { print }'
refused "names the measurement \`passing\`, which the assessment \`conformance\` does not hold" "a requirement names the measurement passing"

# -- a preset against the declaration of its assessor -------------------------------------------

copy assessor-absent
rm "$c/presets/$cases_declaration"
refused "names the assessor \`conformance-report@1\`, and the directory holds no \`conformance-report@1.assessor.yaml\`" "the declaration of conformance-report@1 is absent"

copy assessor-input
edit "presets/$cases_preset" '
  /^      report: [$][{]inputs[.]report[}]$/ { print "      reports: ${inputs.report}"; next }
  { print }'
refused "passes the input \`reports\`, which \`conformance-report@1\` does not declare" "an assessment passes the input reports"

copy assessor-output
edit "presets/$cases_preset" '
  /^        output: passing_cases$/ { print "        output: passing"; next }
  { print }'
refused "names the output \`passing\`, which \`conformance-report@1\` does not declare" "a measurement names the output passing"

copy assessor-unit-other
edit "presets/$cases_preset" '
  /^  passed:$/ { f = 0 }
  /^      passed:$/ { f = 1 }
  f && /^        unit: cases$/ { print "        unit: case"; f = 0; next }
  { print }'
refused "states the unit \`case\`, and the output \`passed\` of \`conformance-report@1\` declares \`cases\`" "a measurement has the unit case"

copy assessor-unit-absent
edit "presets/$cases_preset" '
  /^      passed:$/ { f = 1 }
  f && /^        unit: cases$/ { f = 0; next }
  { print }'
refused "has no \`unit\`, and the output \`passed\` of \`conformance-report@1\` declares \`cases\`" "a measurement of a count has no unit"

copy assessor-unit-undeclared
edit "presets/$cases_preset" '
  /^        identity: \[case_id\]$/ { print; print "        unit: cases"; next }
  { print }'
refused "states the unit \`cases\`, and the output \`passing_cases\` of \`conformance-report@1\` declares none" "a measurement of a set has a unit"

copy assessor-scope
edit "presets/$cases_preset" '
  /^      passed:$/ { f = 1 }
  f && /^        scope: run$/ { print "        scope: case"; f = 0; next }
  { print }'
refused "has the scope \`case\`, which the output \`passed\` of \`conformance-report@1\` does not declare" "a measurement has the scope case"

copy assessor-identity-key
edit "presets/$cases_preset" '
  /^        identity: \[case_id\]$/ { print "        identity: [case_id, suite]"; next }
  { print }'
refused "states the identity key \`[case_id, suite]\`, and the output \`passing_cases\` of \`conformance-report@1\` declares \`[case_id]\`" "a measurement has the identity key case_id and suite"

copy assessor-filter-field
edit "presets/$differential" '
  /^        filter: [{]class: \[different\][}]$/ { print "        filter: {result: [different]}"; next }
  { print }'
refused "filters by the field \`result\`, which the output \`cases\` of \`comparison-report@1\` does not declare for its items" "a measurement filters by the field result"

# -- rows ----------------------------------------------------------------------------------------

copy row-absent
edit "presets/$page" '
  index($0, "| `conformance-cases@1/conformance/skipped` |") == 1 { next }
  { print }'
refused "the measurement \`conformance-cases@1/conformance/skipped\` has no row on a page of the directory" "the page has no row for a measurement"

copy row-of-no-measurement
edit "presets/$page" '
  index($0, "| `conformance-cases@1/conformance/skipped` |") == 1 { sub(/conformance\/skipped/, "conformance/ignored") }
  { print }'
refused "the row \`conformance-cases@1/conformance/ignored\` names no measurement of a preset of the directory" "a row names a measurement that no preset holds"

copy row-twice
edit "presets/$page" '
  index($0, "| `conformance-cases@1/conformance/skipped` |") == 1 { print }
  { print }'
refused "the measurement \`conformance-cases@1/conformance/skipped\` has 2 rows" "a measurement has two rows"

copy row-cell-empty
edit "presets/$page" '
  index($0, "| `conformance-cases@1/conformance/skipped` |") == 1 {
    n = split($0, cell, /\|/)
    printf "|%s|%s| |%s|%s|\n", cell[2], cell[3], cell[5], cell[6]
    next
  }
  { print }'
refused "the cell \`Unit\` of the row \`conformance-cases@1/conformance/skipped\` is empty" "the unit of a row is empty"

copy row-on-another-page
edit "presets/$page" '
  index($0, "| `conformance-cases@1/conformance/skipped` |") == 1 { next }
  { print }'
{
  printf '# Other\n\n| Measurement | Direction | Unit | Tolerance | Evidence |\n| --- | --- | --- | --- | --- |\n'
  grep -F '| `conformance-cases@1/conformance/skipped` |' "$catalog/$page"
} > "$c/presets/other.md"
refused "stands on another page than the rows of its preset" "one row of a preset stands on a second page"

copy row-header
edit "presets/$page" '
  $0 == "| Measurement | Direction | Unit | Tolerance | Evidence |" { print "| Criterion | Direction | Unit | Tolerance | Evidence |"; next }
  { print }'
refused "the page holds no table with the header" "the header of the tables starts with Criterion"

copy page-without-table
printf '# Notes\n\nA page that lists no measurement.\n' > "$c/presets/notes.md"
refused "notes.md:1: the page holds no table with the header" "a page of the directory holds no table"

if [ "$accepted" -gt 0 ]; then
  echo "$summary, $((cases - accepted)) of $cases broken copies refused, $accepted accepted"
  exit 1
fi
echo "$summary, $cases of $cases broken copies refused"
