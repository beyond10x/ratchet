#!/bin/sh
# Every assessor that an example names has its `ratchet-assessor/1` declaration, and every
# measurement of an example reads that declaration as it is written.
#
# An example is a file `examples/*.ratchet.yaml`, and no file of a directory below `examples/`.
# The two catalog sources of `examples/ratchet.toml` are the directory `quality/assessors` of the
# examples and `presets/` of this repository. For each plan of an example whose assessor is not
# `record-series@1`, the declaration is the file `<name>@<version>.assessor.yaml` in
# `examples/quality/assessors/` or, when that directory holds none, in `presets/`.
#
# Refused, each with the file and the line of the plan or the measurement:
#   1  an assessor without a declaration file in either directory; the message names the id
#   2  a measurement that names an output its assessor does not declare. `coverage.<count>` is
#      an output of Ratchet itself where the assessor lists the count under `coverage`: it
#      has the scope `run` and no unit, read by rules 5 and 6 (docs/design.md § 3 "Evidence
#      coverage")
#   3  a measurement that states no unit for an output that declares one (`unit_missing`)
#   4  a measurement that states another unit than the output declares (`unit_mismatch`)
#   5  a measurement that states a unit for an output that declares none (`unit_not_declared`)
#   6  a measurement with a scope other than `run` that the output does not list; `run` is the
#      scope every assessor has, and no declaration lists it ("does not declare the scope")
#   7  a measurement of a plan of `record-series@1` that does not keep the unit or the scope of
#      the measurement of its source plan that it names as its `output`. Such a measurement
#      is not checked against a declaration: `record-series@1` is built in and has none
#      (spec/domains/assessor.yaml), and its outputs are the measurements of the source plan
#   8  a directory of the examples that holds no file `*.ratchet.yaml`
#   9  a binding under `presets:` whose `use:` names no file `<name>@<version>.preset.yaml` of
#      the catalog directory of the presets, `presets/` (a name that is no `<name>@<version>`
#      of letters, digits, `.`, `_` and `-` names none), and one whose `digest` is not
#      `sha256:` and the SHA-256 that `sha256sum` gives over that file; with the line of the
#      `use:` or of the `digest`
# and, so that no plan and no measurement passes unread: an `assessments` that is no mapping, a
# plan that is no mapping, and a `measurements` that is no mapping; a plan without `assessor`; an
# assessor id that is no `<name>@<version>` of letters, digits, `.`, `_` and `-` (it names a
# file); a measurement without `output`; a plan of `record-series@1` without
# `observation.population.runs_of`; a `runs_of` that names no plan of its file; an `output` of
# such a plan that is no measurement of its source plan; an entry `*.ratchet.yaml` of the
# examples or `<id>.assessor.yaml` of a catalog directory that is no regular file; a pending
# key, `key:` with nothing under it; and a line in a form this script does not read (`not
# read:`).
#
# Not checked, each with its reason:
#   - a declaration's own keys and types against `ratchet.assessor.Assessor`: spec/presets.test.sh
#     checks the files of `presets/` only, and a declaration of `examples/quality/assessors/`
#     is read here for its outputs, units and scopes
#   - the kind (`kind_mismatch`), the boundary, the identity key and the `filter` fields of a
#     measurement, the target kind, the inputs and the conditions of a plan, and its coverage
#     counts against the declaration: the story that wrote this script asks for outputs, units
#     and scopes
#   - the kind, the boundary and the identity key of a measurement of a plan of
#     `record-series@1` against its source measurement
#   - that a plan over `runs_of` names `record-series@1`, and every other invariant of
#     `ratchet.specification.AssessmentPlan`: a plan of another assessor is checked against
#     its declaration, with or without `runs_of`
#   - a source plan in another file: `runs_of` names a plan of the same file, or it is refused
#   - a declaration that no example names
#   - `examples/ratchet.toml` itself: the script takes the two directories it names, by option
#   - which of the two directories wins for an id that both hold: docs/design.md § 5 sets no
#     precedence between the sources, and the script reads `examples/quality/assessors/` first
#   - the bytes of a file (UTF-8, characters that hide text) and every key the rules above do
#     not read: these are the gate's for `presets/` alone
#   - that a declaration is what its program does: none of the ten assessors is a program here
#   - of a binding, everything but the file its `use:` names and its `digest`: the inputs it
#     passes (`with`) against the preset, and the plans and requirements of the bound preset,
#     which spec/presets.test.sh checks in `presets/`. The resolution of a binding by
#     `ratchet validate`, with the code `unresolved_reference`, is not built yet
#
# This is no YAML reader. It reads the forms the examples and the catalog are written in and
# fails on a line of another form: a mapping by indentation (`key:` and `key: value`), a flow
# mapping `{key: value, ...}` and a flow list `[...]` on one line, a block list whose items are
# `- <scalar>` or `- <flow collection>`, plain scalars, and quoted scalars without an escape. A
# line that holds only a comment is skipped. Refused: a comment after a value, a tab, a control
# character, a quote inside a plain scalar, a folded or literal scalar (`>`, `|`), a text over
# two lines, a document marker (`---`), a block list item that is a mapping or a list, a block
# list at the indentation of its key (`key:` then `- item` with no more indentation), a flow
# list or a flow mapping with a comma after its last item (`[a, ]`), and a key that YAML reads
# as a number, a boolean or null. YAML 1.2 takes the two forms before the last; the examples
# and the catalog do not write them.
#
# Usage:
#   sh spec/example-declarations.test.sh       `examples/` with `examples/quality/assessors/` and
#                                              `presets/`, then one defect per rule in copies of
#                                              a set of its files (`set_examples` and
#                                              `set_declarations`)
#   sh spec/example-declarations.test.sh [--examples <directory>] [--declarations <directory>]
#                                        [--presets <directory>]
#                                              one check, no copy; the declarations default to
#                                              `<examples>/quality/assessors`
# Work files go to the ignored target/example-declarations. It needs POSIX sh and awk, and of the
# other utilities `cat`, `cmp`, `cp`, `dirname`, `grep`, `ln`, `mkdir`, `mv`, `rm`, `sed`,
# `sha256sum` and `tail`. `sha256sum` gives the digest of the file a binding names.
#
# Exit 0: the line of the check is
#   `example-declarations: <e> example file(s), <d> declaration(s) read, <m> of <m> measurement(s) as declared`
# and without an option the last line is
#   `example-declarations: <c> of <c> broken copies refused`
# Exit 1: each failure is named with its file and line; or a copy is accepted, or refused
# without the message of its rule; or the harness of the copies fails a case of its own; or the
# examples lack a file of the set; or a case edits a file its copy does not hold.
set -eu

# Bytes, not characters of the locale of the caller: the same reading under every awk.
LC_ALL=C
export LC_ALL

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
self=$root/spec/example-declarations.test.sh
examples=$root/examples
declarations=
presets=$root/presets
work=$root/target/example-declarations
copies=1

usage() {
  echo "usage: example-declarations.test.sh [--examples <directory>] [--declarations <directory>] [--presets <directory>]" >&2
  exit 1
}

while [ $# -gt 0 ]; do
  case $1 in
    --examples) [ $# -ge 2 ] || usage; examples=$2; copies=0; shift 2 ;;
    --declarations) [ $# -ge 2 ] || usage; declarations=$2; copies=0; shift 2 ;;
    --presets) [ $# -ge 2 ] || usage; presets=$2; copies=0; shift 2 ;;
    *) usage ;;
  esac
done
[ -n "$declarations" ] || declarations=$examples/quality/assessors

# check <examples> <declarations> <presets>: the failures and the line of the check.
check() {
  ex_dir=$1
  decl_dir=$2
  presets_dir=$3
  if [ ! -d "$ex_dir" ]; then
    echo "example-declarations: $ex_dir is no directory of examples"
    return 1
  fi
  # The entries, as pairs of words for awk: what the entry is, and its path. awk runs its
  # BEGIN alone and reads no operand as a file.
  set --
  for f in "$ex_dir"/*.ratchet.yaml; do
    [ -e "$f" ] || [ -L "$f" ] || continue
    if [ -f "$f" ]; then set -- "$@" example "$f"; else set -- "$@" example-other "$f"; fi
  done
  for source in declarations presets; do
    if [ "$source" = declarations ]; then d=$decl_dir; else d=$presets_dir; fi
    [ -d "$d" ] || continue
    for f in "$d"/*.assessor.yaml; do
      [ -e "$f" ] || [ -L "$f" ] || continue
      if [ -f "$f" ]; then set -- "$@" "$source" "$f"; else set -- "$@" "$source-other" "$f"; fi
    done
  done

  awk -v pdir="$presets_dir" '
  function trim(s) { sub(/^ +/, "", s); sub(/ +$/, "", s); return s }
  function short(f) { sub(/^.*\//, "", f); return f }
  function shown(p) { gsub(/\037\[/, "[", p); gsub(/\037/, ".", p); return p }
  function named(p) { return "`" shown(p) "` " }
  function under(p, step) { return p == "" ? step : p SEP step }
  function fail(file, line, msg) { printf "%s:%d: %s\n", short(file), line, msg; failed++ }
  function entry_fail(file) { printf "%s: the entry is no regular file\n", short(file); failed++ }
  function norule(msg) { fail(FILE, LN, "not read: " msg) }
  function has(file, p) { return (file, p) in at }
  function text(file, p) { return ((file, p) in at) ? n_text[at[file, p]] : "" }
  function line_of(file, p) { return ((file, p) in at) ? n_line[at[file, p]] : 0 }
  # 1 when the list at `p` holds the text `x`.
  function holds(file, p, x,    j) {
    for (j = 1; has(file, p SEP "[" j "]"); j++) if (text(file, p SEP "[" j "]") == x) return 1
    return 0
  }

  # ---- the YAML forms this script reads -------------------------------------------------

  # A node of the file at `p`: a mapping, a list or a scalar. A key without a value on its
  # line is `pending` until the first line under it says what it holds.
  function node(p, k, x,    id) {
    if ((FILE, p) in at) id = at[FILE, p]
    else { id = ++nn; at[FILE, p] = id; n_file[id] = FILE; n_line[id] = LN; n_path[id] = p }
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
  # after `: `, `- ` at the start of a line, `[`, `{` and `,`.
  function scan(s,    i, n, c, q) {
    q = ""; n = length(s)
    for (i = 1; i <= n; i++) {
      c = substr(s, i, 1)
      if (q != "") { if (c == q) q = ""; continue }
      if (c == "\"" || c == "\047") {
        if (substr(s, 1, i - 1) !~ /(^ *- |^|[{,[]|: ) *$/) return 2
        q = c
      } else if (c == "#" && substr(s, i - 1, 1) == " ") return 1
    }
    return 0
  }

  # The parts of `s` between commas that lie in no bracket and no quote; the number of parts,
  # -1 when a bracket or a quote does not close.
  function parts(s, out,    n, i, c, depth_, quote, cur) {
    split("", out)
    n = 0; depth_ = 0; quote = ""; cur = ""
    for (i = 1; i <= length(s); i++) {
      c = substr(s, i, 1)
      if (quote != "") { if (c == quote) quote = ""; cur = cur c; continue }
      if (c == "\"" || c == "\047") { quote = c; cur = cur c; continue }
      if (c == "{" || c == "[") depth_++
      if (c == "}" || c == "]") depth_--
      if (depth_ < 0) return -1
      if (c == "," && depth_ == 0) { out[++n] = trim(cur); cur = ""; continue }
      cur = cur c
    }
    if (depth_ != 0 || quote != "") return -1
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

  # A key is text. YAML reads `15` and `0o17` as one integer, and `true` as a boolean.
  function text_key(k) {
    if (plain_kind(k) != "str") norule("the key `" k "` is a YAML " plain_kind(k) " and no text; a key is text")
  }

  function scalar(p, s, inflow,    c, inner) {
    c = substr(s, 1, 1)
    if (c == "\"" || c == "\047") {
      inner = substr(s, 2, length(s) - 2)
      if (length(s) < 2 || substr(s, length(s), 1) != c) { norule("the quoted scalar of `" shown(p) "` does not end at its quote"); return }
      if (c == "\"" && index(inner, "\\") > 0) { norule("the quoted scalar of `" shown(p) "` holds an escape, `\\`, and this script reads none"); return }
      node(p, "str", inner)
      return
    }
    if (s ~ /^[]|>&*!%@`,}#]/ || s ~ /^[-?:]( |$)/) { norule("the value `" s "` of `" shown(p) "` is in a form this script does not read"); return }
    if (index(s, ": ") > 0 || s ~ /:$/) { norule("the plain scalar of `" shown(p) "` holds `: `; quote it"); return }
    if (inflow && s ~ /[][{}]/) { norule("the plain scalar `" s "` of `" shown(p) "` holds a bracket or a brace inside a flow collection; quote it"); return }
    node(p, plain_kind(s), s)
  }

  function value(s, p, inflow) {
    if (s ~ /^[{]/) flow_map(s, p)
    else if (s ~ /^\[/) flow_list(s, p)
    else scalar(p, s, inflow)
  }

  function flow_map(s, p,    n, i, item, k, rest, q) {
    if (s !~ /[}]$/) { norule("the flow mapping of `" shown(p) "` does not close on its line"); return }
    n = parts(substr(s, 2, length(s) - 2), item)
    if (n < 0) { norule("a bracket or a quote in the flow mapping of `" shown(p) "` does not close"); return }
    node(p, "map", "")
    for (i = 1; i <= n; i++) {
      if (!match(item[i], /^[A-Za-z0-9_.@-]+:( |$)/)) { norule("`" item[i] "` in the flow mapping of `" shown(p) "` is no `key: value`"); continue }
      k = substr(item[i], 1, RLENGTH); sub(/: ?$/, "", k)
      rest = trim(substr(item[i], RLENGTH + 1))
      text_key(k)
      q = child(p, k)
      if (q == "") continue
      if (rest == "") { norule("`" shown(q) "` has no value in its flow mapping"); continue }
      value(rest, q, 1)
    }
  }

  function flow_list(s, p,    n, i, item) {
    if (s !~ /\]$/) { norule("the flow list of `" shown(p) "` does not close on its line"); return }
    n = parts(substr(s, 2, length(s) - 2), item)
    if (n < 0) { norule("a bracket or a quote in the flow list of `" shown(p) "` does not close"); return }
    node(p, "list", "")
    for (i = 1; i <= n; i++) {
      if (item[i] == "") { norule("the flow list of `" shown(p) "` holds an empty item"); continue }
      value(item[i], p SEP "[" i "]", 1)
    }
  }

  # One line of the file that is read; the state is the stack of open keys, `depth`.
  function read_line(s,    found, indent, content, parent, k, rest, p) {
    if (s ~ /^ *$/) return
    if (index(s, "\t") > 0) { norule("a tab"); return }
    if (s ~ /[\001-\037\177]/) { norule("a control character; a line ends with a line feed"); return }
    if (s ~ /^ *#/) return
    if (s ~ /[#"\047]/) {
      found = scan(s)
      if (found == 1) { norule("a comment after a value"); return }
      if (found == 2) { norule("a quote inside a plain scalar; a scalar that holds a quote is quoted whole, in the other kind of quote"); return }
    }
    indent = match(s, /[^ ]/) - 1
    content = substr(s, indent + 1); sub(/ +$/, "", content)
    # `key:` and then `- item` at the indentation of the key: YAML reads a list, and this
    # script does not. The key is `unread` and not pending, so no message says it has no value.
    if (content ~ /^-( |$)/ && depth > 0 && ind[depth] == indent && opens[depth] && (state[depth] == "" || state[depth] == "compact")) {
      if (state[depth] == "") { state[depth] = "compact"; n_kind[at[FILE, pth[depth]]] = "unread" }
      norule("a block list at the indentation of its key `" shown(pth[depth]) "`")
      return
    }
    while (depth > 0 && ind[depth] >= indent) depth--
    parent = depth > 0 ? pth[depth] : ""
    if (depth == 0 && indent > 0) { norule("`" content "` is indented at the root of the file"); return }
    if (depth > 0 && !opens[depth]) { norule("`" content "` is indented under `" shown(parent) "`, which has a value on its line"); return }
    if (depth > 0) {
      if (cind[depth] == "") cind[depth] = indent
      else if (cind[depth] != indent) { norule("`" content "` is not indented as the line before it under `" shown(parent) "`"); return }
    }
    if (content ~ /^[{[]/) {
      if (depth == 0 || state[depth] != "") { norule("a flow collection that is the value of no key"); return }
      state[depth] = "flow"
      value(content, parent, 0)
      return
    }
    if (content ~ /^-( |$)/) {
      if (depth == 0 || (state[depth] != "" && state[depth] != "list")) { norule("`" content "` is a block list item that is the value of no key"); return }
      if (state[depth] == "") { state[depth] = "list"; n_kind[at[FILE, parent]] = "list"; n_text[at[FILE, parent]] = "" }
      rest = trim(substr(content, 2))
      p = parent SEP "[" (++items[depth]) "]"
      if (rest == "") { norule("an empty block list item under `" shown(parent) "`"); return }
      if (rest ~ /^-( |$)/ || match(rest, /^[A-Za-z0-9_.@-]+:( |$)/)) { norule("the block list item `" rest "` under `" shown(parent) "` is a mapping or a list; an item is a scalar or a flow collection"); return }
      value(rest, p, 0)
      return
    }
    if (!match(content, /^[A-Za-z0-9_.@-]+:( |$)/)) { norule("`" content "` is no `key:` and no `key: value`"); return }
    if (depth > 0 && state[depth] == "flow") { norule("`" content "` follows the flow collection of `" shown(parent) "`"); return }
    if (depth > 0 && (state[depth] == "list" || state[depth] == "compact")) { norule("`" content "` follows the block list of `" shown(parent) "`"); return }
    if (depth > 0 && state[depth] == "") { state[depth] = "map"; n_kind[at[FILE, parent]] = "map" }
    k = substr(content, 1, RLENGTH); sub(/: ?$/, "", k)
    rest = trim(substr(content, RLENGTH + 1))
    text_key(k)
    p = child(parent, k)
    if (p == "") return
    depth++; ind[depth] = indent; pth[depth] = p; opens[depth] = (rest == ""); state[depth] = ""; cind[depth] = ""; items[depth] = 0
    if (rest == "") node(p, "pending", "")
    else value(rest, p, 0)
  }

  # Reads the file at `path` into the nodes, keyed by that path.
  function read_yaml(path,    r, s, first, id) {
    FILE = path; LN = 0; depth = 0
    node("", "map", "")
    first = nn
    while ((r = (getline s < path)) > 0) { LN++; read_line(s) }
    if (r < 0) fail(path, 0, "the file cannot be read")
    close(path)
    for (id = first; id <= nn; id++)
      if (n_kind[id] == "pending") fail(n_file[id], n_line[id], "`" shown(n_path[id]) "` has no value on its line and nothing under it")
  }

  # ---- the declarations -------------------------------------------------------------------

  # The path of the declaration of the assessor `a`, read once; "" without one, and "-" where
  # its entry is no regular file (named once).
  function declaration(a,    b, k, src) {
    if (a in decl) return decl[a]
    b = a ".assessor.yaml"
    decl[a] = ""
    for (k = 1; k <= 2; k++) {
      src = (k == 1) ? "declarations" : "presets"
      if ((src, b) in other) { entry_fail(other[src, b]); decl[a] = "-"; break }
      if ((src, b) in regular) { read_yaml(regular[src, b]); nread++; decl[a] = regular[src, b]; break }
    }
    return decl[a]
  }

  # 1 when the node at `p` is a mapping or absent; else 0, and the node is named, unless it is
  # pending or unread, which has a message of its own. `words` name the node, with a space after.
  function mapping(F, p, words,    k) {
    if (!has(F, p)) return 1
    k = n_kind[at[F, p]]
    if (k == "map") return 1
    if (k != "pending" && k != "unread") fail(F, line_of(F, p), words "is no mapping, and this script reads its entries only from a mapping")
    return 0
  }

  # A unit or a scope as the message shows it: between backticks, or `none`.
  function stated(file, p) { return has(file, p) ? "`" text(file, p) "`" : "none" }

  # ---- the rules ------------------------------------------------------------------------------

  # The measurements of a plan of `record-series@1`: rule 7.
  function check_series(F, P, pp,    rp, S, sp, j, M, mp, O, sm, before) {
    rp = pp SEP "observation" SEP "population" SEP "runs_of"
    if (!has(F, rp)) { fail(F, line_of(F, pp SEP "assessor"), "the plan `" P "` names `" SERIES "` and has no `observation.population.runs_of`"); return }
    S = text(F, rp); sp = "assessments" SEP S
    if (S == "" || !has(F, sp) || S == P) { fail(F, line_of(F, rp), "`runs_of` of the plan `" P "` names `" S "`, which is no other plan of the file"); return }
    for (j = 1; j <= nkeys[F, pp SEP "measurements"]; j++) {
      M = keyof[F, pp SEP "measurements", j]; mp = pp SEP "measurements" SEP M
      before = failed
      if (!has(F, mp SEP "output")) { fail(F, line_of(F, mp), named(mp) "names no output"); continue }
      O = text(F, mp SEP "output"); sm = sp SEP "measurements" SEP O
      if (O == "" || !has(F, sm)) { fail(F, line_of(F, mp), named(mp) "names the output `" O "`, which is no measurement of its source plan `" S "`"); continue }
      if (has(F, mp SEP "unit") != has(F, sm SEP "unit") || text(F, mp SEP "unit") != text(F, sm SEP "unit"))
        fail(F, line_of(F, mp), named(mp) "does not keep the unit of the measurement `" O "` of its source plan `" S "`: it states " stated(F, mp SEP "unit") ", and that measurement " stated(F, sm SEP "unit"))
      if (has(F, mp SEP "scope") != has(F, sm SEP "scope") || text(F, mp SEP "scope") != text(F, sm SEP "scope"))
        fail(F, line_of(F, mp), named(mp) "does not keep the scope of the measurement `" O "` of its source plan `" S "`: it states " stated(F, mp SEP "scope") ", and that measurement " stated(F, sm SEP "scope"))
      if (failed == before) good++
    }
  }

  # One plan of an example: rules 1 to 7.
  function check_plan(F, P,    pp, A, al, D, j, M, mp, O, op, cc, what, has_du, du, has_mu, mu, sc, before) {
    pp = "assessments" SEP P
    if (!mapping(F, pp, "the plan `" P "` ")) return
    if (!mapping(F, pp SEP "measurements", named(pp SEP "measurements"))) return
    total += nkeys[F, pp SEP "measurements"]
    if (!has(F, pp SEP "assessor")) { fail(F, line_of(F, pp), "the plan `" P "` names no assessor"); return }
    A = text(F, pp SEP "assessor"); al = line_of(F, pp SEP "assessor")
    if (A == SERIES) { check_series(F, P, pp); return }
    if (A !~ /^[A-Za-z0-9_][A-Za-z0-9._-]*@[A-Za-z0-9._-]+$/) { fail(F, al, "the plan `" P "` names the assessor `" A "`, which is no `<name>@<version>` of letters, digits, `.`, `_` and `-`"); return }
    D = declaration(A)
    if (D == "-") return
    if (D == "") { fail(F, al, "the assessor `" A "` of the plan `" P "` has no declaration file: neither catalog directory holds `" A ".assessor.yaml`"); return }
    for (j = 1; j <= nkeys[F, pp SEP "measurements"]; j++) {
      M = keyof[F, pp SEP "measurements", j]; mp = pp SEP "measurements" SEP M
      before = failed
      if (!has(F, mp SEP "output")) { fail(F, line_of(F, mp), named(mp) "names no output"); continue }
      O = text(F, mp SEP "output"); op = "outputs" SEP O
      # `coverage.<count>` is an output of Ratchet itself: a count of the coverage of the run
      # that the declaration lists under `coverage`, at the scope `run` and without a unit
      # (docs/design.md § 3 "Evidence coverage").
      cc = (substr(O, 1, 9) == "coverage." && !has(D, op) && holds(D, "coverage", substr(O, 10)))
      if (!cc && (O == "" || !has(D, op))) { fail(F, line_of(F, mp), named(mp) "names the output `" O "`, which `" A "` does not declare"); continue }
      what = cc ? "the coverage count `" O "` of `" A "`" : "the output `" O "` of `" A "`"
      has_du = has(D, op SEP "unit"); du = text(D, op SEP "unit")
      has_mu = has(F, mp SEP "unit"); mu = text(F, mp SEP "unit")
      if (has_du && !has_mu) fail(F, line_of(F, mp), named(mp) "has no `unit`, and " what " declares `" du "` (`unit_missing`)")
      else if (has_du && mu != du) fail(F, line_of(F, mp), named(mp) "states the unit `" mu "`, and " what " declares `" du "` (`unit_mismatch`)")
      else if (!has_du && has_mu) fail(F, line_of(F, mp), named(mp) "states the unit `" mu "`, and " what " declares none (`unit_not_declared`)")
      sc = text(F, mp SEP "scope")
      if (has(F, mp SEP "scope") && sc != "run" && !holds(D, op SEP "scopes", sc))
        fail(F, line_of(F, mp), named(mp) "has the scope `" sc "`, and " what " does not declare the scope `" sc "`")
      if (failed == before) good++
    }
  }

  # A path as one word of a shell command, between quotes (the byte 047).
  function shell_word(s,    out, i, c, len) {
    out = ""; len = length(s)
    for (i = 1; i <= len; i++) { c = substr(s, i, 1); out = out (c == "\047" ? "\047\\\047\047" : c) }
    return "\047" out "\047"
  }

  # The bindings under `presets:` of an example: rule 9. The file a binding names and the
  # digest it states, and nothing else of the binding.
  function check_bindings(F,    j, B, bp, U, look, sum) {
    if (!mapping(F, "presets", "`presets` ")) return
    for (j = 1; j <= nkeys[F, "presets"]; j++) {
      B = keyof[F, "presets", j]; bp = "presets" SEP B
      if (!mapping(F, bp, "the binding `" B "` ")) continue
      U = text(F, bp SEP "use"); sum = ""
      # A name that is no `<name>@<version>` of these characters names no file of the directory.
      if (U ~ /^[A-Za-z0-9_][A-Za-z0-9._-]*@[A-Za-z0-9._-]+$/) {
        look = "sha256sum " shell_word(pdir "/" U ".preset.yaml") " 2> /dev/null"
        look | getline sum
        close(look)
        sub(/^\\/, "", sum); sub(/ .*$/, "", sum)
      }
      if (sum !~ /^[0-9a-f]+$/) {
        fail(F, has(F, bp SEP "use") ? line_of(F, bp SEP "use") : line_of(F, bp), "the binding `" B "` names the preset `" U "`, and the catalog directory of the presets holds no file `" U ".preset.yaml`")
        continue
      }
      if (text(F, bp SEP "digest") != "sha256:" sum)
        fail(F, has(F, bp SEP "digest") ? line_of(F, bp SEP "digest") : line_of(F, bp), "the binding `" B "` states the digest " stated(F, bp SEP "digest") ", and `sha256sum` gives `sha256:" sum "` over `" U ".preset.yaml`")
    }
  }

  BEGIN {
    SEP = "\037"
    # The assessor of Ratchet itself that reads the runs of another plan
    # (spec/domains/assessor.yaml); no file declares it.
    SERIES = "record-series@1"
    nex = 0
    for (i = 1; i + 1 < ARGC; i += 2) {
      w = ARGV[i]; f = ARGV[i + 1]
      if (w == "example") ex[++nex] = f
      else if (w == "example-other") entry_fail(f)
      else if (w == "declarations" || w == "presets") regular[w, short(f)] = f
      else { sub(/-other$/, "", w); other[w, short(f)] = f }
    }
    if (nex == 0) { print "example-declarations: the directory of the examples holds no file `*.ratchet.yaml`"; failed++ }
    for (e = 1; e <= nex; e++) {
      read_yaml(ex[e])
      if (mapping(ex[e], "assessments", "`assessments` ")) for (j = 1; j <= nkeys[ex[e], "assessments"]; j++) check_plan(ex[e], keyof[ex[e], "assessments", j])
      check_bindings(ex[e])
    }
    if (failed > 0) {
      printf "example-declarations: %d example file(s), %d declaration(s) read, %d of %d measurement(s) as declared, %d failure(s)\n", nex, nread, good, total, failed
      exit 1
    }
    printf "example-declarations: %d example file(s), %d declaration(s) read, %d of %d measurement(s) as declared\n", nex, nread, total, total
  }
  ' "$@"
}

if [ "$copies" -eq 0 ]; then
  check "$examples" "$declarations" "$presets"
  exit $?
fi

rm -rf "$work"
mkdir -p "$work"

if check "$examples" "$declarations" "$presets" > "$work/tree.out" 2>&1; then :; else
  cat "$work/tree.out"
  exit 1
fi
cat "$work/tree.out"

# ---- one defect per rule, in copies of a set of files of examples/ ----------------------------
#
# Each case is one defect in a copy of the set, the directory target/example-declarations/<case>,
# which stands where `examples/` stands: the examples of the set, and its declarations under
# `quality/assessors/`. The second catalog directory of a copy is empty,
# target/example-declarations/no-presets, unless the case gives it one of its own,
# <case>.presets: a copy reads nothing of `presets/`. The case holds when the check of the copy
# exits non-zero and names the defect with the words of its rule, so a case fails when its
# rule is taken out of the check, also where another rule refuses the copy then. One start of
# this script checks every copy: `check` is a function and runs once per copy. A rule without
# a case here is not guarded: a new rule gets its case.

stop() {
  echo "example-declarations: $1"
  exit 1
}

# The set: three examples and the four declarations they name. Between them they hold a plan
# of `record-series@1`, a unit on every output that has one, an output without a unit, and the
# scopes `run`, `test`, `task`, `journey` and `page`. A file of the set that the tree does not
# hold stops the run.
turn='ci-turnaround.ratchet.yaml'
ui='ess-ui-behavior.ratchet.yaml'
host='host-caused-limit.ratchet.yaml'
forge_d='quality/assessors/forge-workflow-timing@1.assessor.yaml'
timing_d='quality/assessors/command-timing@1.assessor.yaml'
report_d='quality/assessors/ess-ui-report@1.assessor.yaml'
ux_d='quality/assessors/ux-eval@1.assessor.yaml'
set_examples="$turn $ui $host"
set_declarations="$forge_d $timing_d $report_d $ux_d"
set_dir=$work/set
mkdir -p "$set_dir/quality/assessors" "$work/no-presets"
for set_file in $set_examples; do
  [ -f "$examples/$set_file" ] || stop "examples/ holds no $set_file, a file of the set that every copy of this script holds ($set_examples)"
  cp "$examples/$set_file" "$set_dir/$set_file"
done
for set_file in $set_declarations; do
  [ -f "$declarations/${set_file#quality/assessors/}" ] || stop "the declarations hold no ${set_file#quality/assessors/}, a file of the set that every copy of this script holds"
  cp "$declarations/${set_file#quality/assessors/}" "$set_dir/$set_file"
done

# copy <case>: a fresh copy of the set as the directory $c; sets $c, $name and $case_presets.
copy() {
  name=$1
  c=$work/$1
  cp -R "$set_dir" "$c"
  case_presets=$work/no-presets
}

# own_presets: the copy gets a second catalog directory of its own, $c.presets.
own_presets() {
  mkdir "$c.presets"
  case_presets=$c.presets
}

# An edit that changes nothing stops the run: its case would test the unchanged set.
nothing() {
  echo "example-declarations: the edit of the case $name changes nothing in $1" >&2
  exit 1
}

# An edit of a file that the copy does not hold stops the run.
holds() {
  [ -f "$c/$1" ] && return 0
  echo "example-declarations: the case $name edits $1, and its copy holds no $1: a copy holds the set ($set_examples $set_declarations)" >&2
  exit 1
}

# edit <file of the copy> <awk program>
edit() {
  holds "$1"
  awk "$2" "$c/$1" > "$c.new"
  if cmp -s "$c/$1" "$c.new"; then nothing "$1"; fi
  mv "$c.new" "$c/$1"
}

# swap <file of the copy> <line> <text>: the first line that is <line> becomes <text>.
swap() {
  holds "$1"
  awk -v old="$2" -v new="$3" '
    ($0 "") == (old "") && !swapped_ { print new; swapped_ = 1; changed = ((new "") != (old "")); next }
    { print }
    END { exit !changed }' "$c/$1" > "$c.new" || nothing "$1"
  mv "$c.new" "$c/$1"
}

# drop <file of the copy> <line>: the first line that is <line> is taken out.
drop() {
  holds "$1"
  awk -v old="$2" '
    ($0 "") == (old "") && !dropped { dropped = 1; next }
    { print }
    END { exit !dropped }' "$c/$1" > "$c.new" || nothing "$1"
  mv "$c.new" "$c/$1"
}

# check_copy: the check of the copy, once: its output is $c.out, its exit status $checked.
check_copy() {
  if check "$c" "$c/quality/assessors" "$case_presets" > "$c.out" 2>&1; then checked=0; else checked=1; fi
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

# The counts: `broken` are the copies that hold a defect, `kept` those of them that were
# accepted or refused without the message of their rule.
broken=0
kept=0

# refused <the message of the rule> <what the copy holds>: checks the copy and judges its case.
refused() {
  check_copy
  judge "$1"
  broken=$((broken + 1))
  case $verdict in
    refused) ;;
    accepted)
      kept=$((kept + 1))
      echo "accepted: $name: $2"
      echo "  $(tail -n 1 "$c.out")" ;;
    *)
      kept=$((kept + 1))
      echo "refused without the message of its rule: $name: $2"
      echo "  wanted: $1"
      sed 's/^/  /' "$c.out" ;;
  esac
}

# accepts <what the copy holds>: a copy with forms that are valid; a refusal stops the run.
accepts() {
  check_copy
  judge 'example-declarations:'
  if [ "$verdict" != accepted ]; then
    echo "example-declarations: refused, and it is valid: $name: $1"
    sed 's/^/  /' "$c.out"
    exit 1
  fi
}

# result: the last line; fails when a copy was accepted or was refused without the message of
# its rule.
result() {
  if [ "$kept" -gt 0 ]; then
    echo "example-declarations: $((broken - kept)) of $broken broken copies refused, $kept accepted"
    return 1
  fi
  echo "example-declarations: $broken of $broken broken copies refused"
}

# -- the harness of the copies ------------------------------------------------------------------
#
# The cases of the harness itself, none counted as a copy: without them every case below could
# pass for a reason that is no refusal.

# An edit that changes nothing stops the run, with each of the three ways to edit.
copy harness-edit
if (swap "$host" 'a line the file does not hold' 'another line') 2> /dev/null; then
  stop "a swap of a line the file does not hold does not stop the run"
fi
if (swap "$host" 'format: ratchet/1' 'format: ratchet/1') 2> /dev/null; then
  stop "a swap of a line for itself does not stop the run"
fi
if (drop "$host" 'a line the file does not hold') 2> /dev/null; then
  stop "a drop of a line the file does not hold does not stop the run"
fi
if (edit "$host" '{ print }') 2> /dev/null; then
  stop "an edit that changes nothing does not stop the run"
fi

# An edit of a file that the copy does not hold stops the run and names the case and the file.
outside='analyzer-findings.ratchet.yaml'
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
  grep -F -q "example-declarations: the case harness-edit edits $outside, and its copy holds no $outside" "$c.outside" || {
    cat "$c.outside"
    stop "the $way of a file that the copy does not hold does not name the case and the file"
  }
done

# The unchanged set is accepted, also through the options, and is not counted as refused.
copy harness-unchanged
accepts 'the unchanged set'
set_summary=$(tail -n 1 "$c.out")
if sh "$self" --examples "$c" --presets "$work/no-presets" > "$c.options" 2>&1 && [ "$(cat "$c.options")" = "$set_summary" ]; then :; else
  cat "$c.options"
  stop "the unchanged copy of the set fails with --examples and --presets, or prints another line than: $set_summary"
fi

# `--declarations` and `--presets` name the directories that are read: the unchanged copy is
# refused with both empty, and accepted with its declarations given as the second directory.
if sh "$self" --examples "$c" --declarations "$work/no-presets" --presets "$work/no-presets" > "$c.options" 2>&1; then
  cat "$c.options"
  stop "--declarations is not read: the copy is accepted with an empty directory of declarations"
fi
grep -F -q 'the assessor `ux-eval@1` of the plan `walks` has no declaration file' "$c.options" || {
  cat "$c.options"
  stop "with an empty directory of declarations the copy is refused for another reason than a missing declaration"
}
if sh "$self" --examples "$c" --declarations "$work/no-presets" --presets "$c/quality/assessors" > "$c.options" 2>&1 && [ "$(cat "$c.options")" = "$set_summary" ]; then :; else
  cat "$c.options"
  stop "--presets is not read: the copy is refused with its declarations as the second directory"
fi

# The run without options fails where the examples of its tree are refused: this script in a
# tree of its own, target/example-declarations/harness-tree, whose examples/ is the set without
# one declaration and whose presets/ is empty.
mkdir -p "$work/harness-tree/spec" "$work/harness-tree/presets"
cp "$self" "$work/harness-tree/spec/example-declarations.test.sh"
cp -R "$set_dir" "$work/harness-tree/examples"
rm "$work/harness-tree/examples/$ux_d"
if sh "$work/harness-tree/spec/example-declarations.test.sh" > "$work/harness-tree.out" 2>&1; then
  cat "$work/harness-tree.out"
  stop "the run in a tree whose examples name an assessor without a declaration exits 0"
fi
grep -F -q 'the assessor `ux-eval@1` of the plan `walks` has no declaration file' "$work/harness-tree.out" || {
  cat "$work/harness-tree.out"
  stop "the run in a tree whose examples name an assessor without a declaration does not name it"
}

# A refusal counts only with the message of the rule of its case.
copy harness-message
rm "$c/$ux_d"
check_copy
judge 'the message of no rule'
[ "$verdict" = other ] || stop "a refusal without the message of its rule counts as the refusal of its case"

# An accepted copy, and a copy refused without the message of its rule, give exit 1.
if (broken=0; kept=0; copy harness-accepted; refused 'the message of no rule' 'the unchanged set'; result) > "$work/harness.out" 2>&1; then
  stop "an accepted copy does not fail the run"
fi
grep -q '^accepted: harness-accepted: ' "$work/harness.out" || stop "an accepted copy is not named"
grep -q '^example-declarations: 0 of 1 broken copies refused, 1 accepted$' "$work/harness.out" || stop "an accepted copy is not counted as accepted in the last line"
if (broken=0; kept=0; name=harness-message; c=$work/harness-message; case_presets=$work/no-presets; refused 'the message of no rule' 'the set without the declaration of ux-eval@1'; result) > "$work/harness.out" 2>&1; then
  stop "a copy refused without the message of its rule does not fail the run"
fi
grep -q '^refused without the message of its rule: harness-message: ' "$work/harness.out" || stop "a copy refused without the message of its rule is not named"

# A copy that is refused stops the run where its case says that it is valid.
if (name=harness-message; c=$work/harness-message; case_presets=$work/no-presets; accepts 'the set without the declaration of ux-eval@1') > /dev/null 2>&1; then
  stop "a refused copy passes as a valid form"
fi

# -- forms that are valid --------------------------------------------------------------------------

# A declaration that the first directory does not hold is read from the second.
copy valid-second-directory
own_presets
mv "$c/$ux_d" "$c.presets/"
accepts 'the declaration of ux-eval@1 in the second catalog directory alone'

# The first directory wins: the second holds a declaration of ux-eval@1 without the output
# `steps`, and the first the declaration of the set.
copy valid-first-directory-wins
own_presets
awk '$0 != "  steps: {value_type: number, kind: exact, scopes: [journey], unit: steps}"' "$c/$ux_d" > "$c.presets/ux-eval@1.assessor.yaml"
cmp -s "$c/$ux_d" "$c.presets/ux-eval@1.assessor.yaml" && nothing "$ux_d"
accepts 'a declaration of ux-eval@1 in both directories, the one of the second without the output steps'

# A comment on a line of its own, a file below the directory of the examples, which is no
# example, a declaration that no example names, and a measurement of `coverage.executed`, a
# count that ux-eval@1 lists under `coverage`.
copy valid-forms
swap "$ui" 'assessments:' '# The plans.\nassessments:'
swap "$ui" '      steps:' '      walks-executed:\n        {kind: exact, output: coverage.executed, scope: run, better: higher}\n      steps:'
mkdir "$c/nested"
printf 'not: [a ratchet/1 file\n' > "$c/nested/broken.ratchet.yaml"
printf 'not: [a declaration\n' > "$c/quality/assessors/unnamed@1.assessor.yaml"
accepts 'a comment on a line of its own, a broken file in a directory below the examples, a broken declaration that no example names, and a measurement of the count executed of the coverage'

# -- one defect per rule ---------------------------------------------------------------------------

# 1 an assessor without a declaration file in either directory
copy rule-1-no-declaration
rm "$c/$ux_d"
refused 'ess-ui-behavior.ratchet.yaml:27: the assessor `ux-eval@1` of the plan `walks` has no declaration file: neither catalog directory holds `ux-eval@1.assessor.yaml`' "the declaration of ux-eval@1 is removed"

# 2 a measurement that names an output its assessor does not declare
copy rule-2-output
swap "$ui" '        output: task_completed' '        output: task_complete'
refused 'ess-ui-behavior.ratchet.yaml:20: `assessments.keyboard-task-completion.measurements.task-completes` names the output `task_complete`, which `ess-ui-report@1` does not declare' "a measurement names the output task_complete"

# 2 a count of the coverage that the assessor does not list under `coverage`
copy rule-2-coverage-count
swap "$ui" '      steps:' '      walks-passed:\n        {kind: exact, output: coverage.passed, scope: run, better: higher}\n      steps:'
refused 'ess-ui-behavior.ratchet.yaml:35: `assessments.walks.measurements.walks-passed` names the output `coverage.passed`, which `ux-eval@1` does not declare' "a measurement names the count passed of the coverage, which ux-eval@1 does not list"

# 3 unit_missing
copy rule-3-unit-missing
swap "$host" '        {kind: sampled, output: duration, boundary: run_time, scope: run, unit: s, better: lower}' '        {kind: sampled, output: duration, boundary: run_time, scope: run, better: lower}'
refused 'host-caused-limit.ratchet.yaml:25: `assessments.test-steps.measurements.step-time` has no `unit`, and the output `duration` of `command-timing@1` declares `s` (`unit_missing`)' "the step time states no unit"

# 4 unit_mismatch
copy rule-4-unit-mismatch
swap "$ui" '        {kind: exact, output: steps, scope: journey, unit: steps, better: lower}' '        {kind: exact, output: steps, scope: journey, unit: step, better: lower}'
refused 'ess-ui-behavior.ratchet.yaml:35: `assessments.walks.measurements.steps` states the unit `step`, and the output `steps` of `ux-eval@1` declares `steps` (`unit_mismatch`)' "the steps state the unit step"

# 5 unit_not_declared
copy rule-5-unit-not-declared
swap "$ui" '        {kind: exact, output: layout_shift, scope: journey, better: lower}' '        {kind: exact, output: layout_shift, scope: journey, unit: px, better: lower}'
refused 'ess-ui-behavior.ratchet.yaml:41: `assessments.walks.measurements.layout-shift` states the unit `px`, and the output `layout_shift` of `ux-eval@1` declares none (`unit_not_declared`)' "the layout shift states the unit px"

# 6 a scope the output does not list
copy rule-6-scope
swap "$ui" '        scope: page' '        scope: screen'
refused 'ess-ui-behavior.ratchet.yaml:43: `assessments.walks.measurements.findings` has the scope `screen`, and the output `findings` of `ux-eval@1` does not declare the scope `screen`' "the findings have the scope screen"

# 5 and 6 on a count of the coverage, which has no unit and the scope `run` alone
copy rule-5-coverage-count-unit
swap "$ui" '      steps:' '      walks-executed:\n        {kind: exact, output: coverage.executed, scope: run, unit: walks, better: higher}\n      steps:'
refused 'ess-ui-behavior.ratchet.yaml:35: `assessments.walks.measurements.walks-executed` states the unit `walks`, and the coverage count `coverage.executed` of `ux-eval@1` declares none (`unit_not_declared`)' "a count of the coverage states the unit walks"

copy rule-6-coverage-count-scope
swap "$ui" '      steps:' '      walks-executed:\n        {kind: exact, output: coverage.executed, scope: journey, better: higher}\n      steps:'
refused 'ess-ui-behavior.ratchet.yaml:35: `assessments.walks.measurements.walks-executed` has the scope `journey`, and the coverage count `coverage.executed` of `ux-eval@1` does not declare the scope `journey`' "a count of the coverage has the scope journey"

# 7 a measurement over `runs_of` that does not keep the unit, or the scope, of its source
copy rule-7-series-unit
swap "$turn" '        unit: min' '        unit: s'
refused 'ci-turnaround.ratchet.yaml:94: `assessments.ci-gate-queue-wait.measurements.p90` does not keep the unit of the measurement `queue-wait` of its source plan `ci-gate-timing`: it states `s`, and that measurement `min`' "the p90 of the window states the unit s"

copy rule-7-series-scope
swap "$turn" '        scope: run' '        scope: test'
refused 'ci-turnaround.ratchet.yaml:94: `assessments.ci-gate-queue-wait.measurements.p90` does not keep the scope of the measurement `queue-wait` of its source plan `ci-gate-timing`: it states `test`, and that measurement `run`' "the p90 of the window has the scope test"

# 8 a directory that holds no file `*.ratchet.yaml`; a file below it is no example
copy rule-8-no-example
mkdir "$c/nested"
for set_file in $set_examples; do mv "$c/$set_file" "$c/nested/$set_file"; done
refused 'example-declarations: the directory of the examples holds no file `*.ratchet.yaml`' "the examples stand in a directory below"

# 9 a binding under `presets:` whose `use:` names no preset of the catalog directory of the
# presets, and one whose `digest` is not the SHA-256 of that file
copy rule-9-binding-preset
own_presets
printf 'presets:\n  probes:\n    use: missing-preset@1\n    digest: sha256:0000000000000000000000000000000000000000000000000000000000000000\n' >> "$c/$host"
refused 'host-caused-limit.ratchet.yaml:50: the binding `probes` names the preset `missing-preset@1`, and the catalog directory of the presets holds no file `missing-preset@1.preset.yaml`' "a binding names a preset the catalog does not hold"

copy rule-9-binding-digest
own_presets
cp "$presets/conformance-cases@1.preset.yaml" "$c.presets/"
printf 'presets:\n  functional:\n    use: conformance-cases@1\n    digest: sha256:0000000000000000000000000000000000000000000000000000000000000000\n' >> "$c/$host"
refused 'host-caused-limit.ratchet.yaml:51: the binding `functional` states the digest `sha256:0000000000000000000000000000000000000000000000000000000000000000`, and `sha256sum` gives `sha256:' "a binding states a digest that is not the SHA-256 of the preset file"

# -- what keeps a plan or a measurement from passing unread ------------------------------------

copy guard-no-assessor
drop "$ui" '    assessor: ux-eval@1'
refused 'ess-ui-behavior.ratchet.yaml:25: the plan `walks` names no assessor' "the plan walks names no assessor"

copy guard-assessor-id
swap "$ui" '    assessor: ux-eval@1' '    assessor: ../assessors/ux-eval@1'
refused 'ess-ui-behavior.ratchet.yaml:27: the plan `walks` names the assessor `../assessors/ux-eval@1`, which is no `<name>@<version>`' "the assessor id holds a path"

copy guard-no-output
drop "$ui" '        output: task_completed'
refused 'ess-ui-behavior.ratchet.yaml:20: `assessments.keyboard-task-completion.measurements.task-completes` names no output' "a measurement names no output"

copy guard-series-without-runs-of
drop "$turn" '      population: {runs_of: ci-gate-timing, from: any_revision}'
refused 'ci-turnaround.ratchet.yaml:86: the plan `ci-gate-queue-wait` names `record-series@1` and has no `observation.population.runs_of`' "the window plan has no runs_of"

copy guard-runs-of-no-plan
swap "$turn" '      population: {runs_of: ci-gate-timing, from: any_revision}' '      population: {runs_of: ci-gate-timings, from: any_revision}'
refused 'ci-turnaround.ratchet.yaml:91: `runs_of` of the plan `ci-gate-queue-wait` names `ci-gate-timings`, which is no other plan of the file' "runs_of names no plan of the file"

copy guard-series-output
swap "$turn" '        output: queue-wait' '        output: queue-waits'
refused 'ci-turnaround.ratchet.yaml:94: `assessments.ci-gate-queue-wait.measurements.p90` names the output `queue-waits`, which is no measurement of its source plan `ci-gate-timing`' "the p90 names no measurement of its source plan"

copy guard-example-entry
mkdir "$c/more.ratchet.yaml"
refused 'more.ratchet.yaml: the entry is no regular file' "an entry *.ratchet.yaml is a directory"

copy guard-declaration-entry
rm "$c/$ux_d"
mkdir "$c/$ux_d"
refused 'ux-eval@1.assessor.yaml: the entry is no regular file' "the entry of the declaration of ux-eval@1 is a directory"

copy guard-pending-key
swap "$ui" '    subject: reader-tasks' '    subject:'
refused 'ess-ui-behavior.ratchet.yaml:11: `assessments.keyboard-task-completion.subject` has no value on its line and nothing under it' "a key has no value and nothing under it"

copy guard-comment-after-value
swap "$ui" '    assessor: ux-eval@1' '    assessor: ux-eval@1 # pinned'
refused 'ess-ui-behavior.ratchet.yaml:27: not read: a comment after a value' "a comment after the assessor of walks"

copy guard-block-list-mapping
swap "$ui" '      - every-task-completes' '      - requirement: every-task-completes'
refused 'ess-ui-behavior.ratchet.yaml:81: not read: the block list item `requirement: every-task-completes` under `gates.merge.requires` is a mapping or a list' "a block list item is a mapping"

copy guard-assessments-not-a-mapping
printf 'format: ratchet/1\nproject: extra\nassessments:\n  - {subject: x, assessor: no-such-assessor@1, measurements: {m: {kind: exact, output: nothing, scope: run}}}\n' > "$c/extra.ratchet.yaml"
refused 'extra.ratchet.yaml:3: `assessments` is no mapping' "an example whose assessments are a block list"

copy guard-plan-not-a-mapping
printf 'format: ratchet/1\nproject: extra\nassessments:\n  a-plan: no-such-assessor@1\n' > "$c/extra.ratchet.yaml"
refused 'extra.ratchet.yaml:4: the plan `a-plan` is no mapping' "an example whose plan is a scalar"

copy guard-measurements-not-a-mapping
edit "$ui" 'NR == 20 { print "      - {kind: exact, output: no_such_output, scope: no_such_scope, unit: px}"; next } NR >= 21 && NR <= 23 { next } { print }'
refused 'ess-ui-behavior.ratchet.yaml:19: `assessments.keyboard-task-completion.measurements` is no mapping' "the measurements of a plan are a block list"

copy guard-duplicate-key
swap "$ui" '        {kind: exact, output: steps, scope: journey, unit: steps, better: lower}' '        {kind: exact, output: no_such, output: steps, scope: journey, unit: steps, better: lower}'
refused 'ess-ui-behavior.ratchet.yaml:36: not read: the key `assessments.walks.measurements.steps.output` stands twice in its mapping' "a measurement states output twice"

copy guard-example-link
ln -s nowhere.yaml "$c/dangling.ratchet.yaml"
refused 'dangling.ratchet.yaml: the entry is no regular file' "an entry *.ratchet.yaml is a symbolic link to nothing"

copy guard-declaration-link
own_presets
cp "$c/$ux_d" "$c.presets/"
rm "$c/$ux_d"
ln -s nowhere.yaml "$c/$ux_d"
refused 'ux-eval@1.assessor.yaml: the entry is no regular file' "the declaration of ux-eval@1 is a symbolic link to nothing, and the second directory holds the file"

copy guard-runs-of-own-plan
swap "$turn" '      population: {runs_of: ci-gate-timing, from: any_revision}' '      population: {runs_of: ci-gate-queue-wait, from: any_revision}'
swap "$turn" '        output: queue-wait' '        output: p90'
refused 'ci-turnaround.ratchet.yaml:91: `runs_of` of the plan `ci-gate-queue-wait` names `ci-gate-queue-wait`, which is no other plan of the file' "a window plan reads its own runs"

copy guard-integer-key
swap "$ui" '      task-completes:' '      1:'
refused 'ess-ui-behavior.ratchet.yaml:20: not read: the key `1` is a YAML int and no text; a key is text' "a measurement key that YAML reads as an integer"

copy guard-escape
swap "$ui" '    inputs: {report: target/ess-ui/report.json}' '    inputs: {report: "target\\ess-ui"}'
refused 'ess-ui-behavior.ratchet.yaml:13: not read: the quoted scalar of `assessments.keyboard-task-completion.inputs.report` holds an escape' "a double-quoted scalar holds a backslash"

copy guard-key-under-a-scalar
swap "$ui" '        output: findings' '        output: findings\n          unit: px'
refused 'ess-ui-behavior.ratchet.yaml:46: not read: `unit: px` is indented under `assessments.walks.measurements.findings.output`, which has a value on its line' "a unit indented under output: findings"

copy guard-block-list-at-key-indentation
edit "$ui" '/^      - / { sub(/^      - /, "    - ") } { print }'
refused 'ess-ui-behavior.ratchet.yaml:81: not read: a block list at the indentation of its key `gates.merge.requires`' "the requires of the merge gate stand at the indentation of their key"
# The key of such a list has a value YAML reads, and no message says it has none.
if grep -F -q 'has no value on its line' "$c.out"; then
  sed 's/^/  /' "$c.out"
  stop "a block list at the indentation of its key is named as a key without a value"
fi

result
