#!/bin/sh
# Every error or refusal that the command table of docs/design.md § 5 ("Proposed CLI") names for
# a command is declared on that command in spec/cli.yaml.
#
# A row names one with the words "the error `<name>`" or "the refusal `<name>`". It binds the
# command of the row, and every other command the row names in the form `ratchet <words>`:
# the row of `ratchet reference propose` says that it and `ratchet reference adopt` return
# `requirement_without_reference`. A command `ratchet a b --flag <x>` is the callable `a-b`.
#
# Nothing else in `task check:spec` compares the documents with the binding, so a name removed
# from `errors:` of one command alone leaves the gate green.
#
# The table names 3: `candidate_unresolved` for `assess`, and `requirement_without_reference`
# for `reference-propose` and for `reference-adopt`; `want_named` below states the number. A row
# reworded so that this script no longer reads its error changes the number, and the script
# fails until the line here says the new one.
#
# Exit 0: the last line is `cli-errors: <n> of <n> named errors declared on their command`.
# Exit 1: each name a command lacks is named, the table is not found, or it names another
# number of errors than stated.
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
design=$root/docs/design.md
binding=$root/spec/cli.yaml

for f in "$design" "$binding"; do
  [ -r "$f" ] || { echo "cli-errors: cannot read ${f#"$root"/}" >&2; exit 1; }
done

awk -v want_named=3 '
  # `ratchet a b --flag <x>` -> a-b
  function callable(text,    n, w, i, out) {
    n = split(text, w, " ")
    out = ""
    for (i = 2; i <= n; i++) {
      if (w[i] ~ /^--/ || w[i] ~ /^</) break
      out = out (out == "" ? "" : "-") w[i]
    }
    return out
  }

  # spec/cli.yaml: the names under `errors:` of each callable.
  FILENAME != DESIGN {
    if ($0 ~ /^callables:/) { in_callables = 1; next }
    if (!in_callables) next
    if ($0 ~ /^  [a-z][a-z-]*:/) { cur = $1; sub(/:.*$/, "", cur); known[cur] = 1; in_errors = 0; next }
    if ($0 ~ /^    errors:/) { in_errors = 1; next }
    if ($0 ~ /^    [a-z_]+:/) { in_errors = 0; next }
    if (in_errors && $0 ~ /^      [a-z_]+:/) { name = $1; sub(/:.*$/, "", name); declared[cur SUBSEP name] = 1 }
    next
  }

  # docs/design.md: the rows of the table under "### Proposed CLI".
  /^#/ { in_table = ($0 == "### Proposed CLI"); next }
  in_table && /^\| `ratchet / {
    rows++
    row = $0
    # the commands the row names
    delete cmds; nc = 0
    rest = row
    while (match(rest, /`ratchet [^`]+`/)) {
      c = callable(substr(rest, RSTART + 1, RLENGTH - 2))
      if (c != "") cmds[++nc] = c
      rest = substr(rest, RSTART + RLENGTH)
    }
    # the errors and refusals the row names
    rest = row
    while (match(rest, /the (error|refusal) `[a-z_]+`/)) {
      name = substr(rest, RSTART, RLENGTH)
      sub(/^[^`]*`/, "", name); sub(/`$/, "", name)
      for (i = 1; i <= nc; i++) {
        named++
        if (!(cmds[i] in known)) {
          printf "unknown: the row names `%s` for the command `%s`, which spec/cli.yaml does not declare\n", name, cmds[i]
          missing++
        } else if (!((cmds[i] SUBSEP name) in declared)) {
          printf "missing: docs/design.md names `%s` for the command `%s`, and `errors:` of `%s` in spec/cli.yaml does not hold it\n", name, cmds[i], cmds[i]
          missing++
        }
      }
      rest = substr(rest, RSTART + RLENGTH)
    }
  }

  END {
    if (rows == 0) { print "cli-errors: no command row found under \"### Proposed CLI\" in docs/design.md"; exit 1 }
    if (named == 0) { print "cli-errors: the command table of docs/design.md names no error or refusal"; exit 1 }
    if (named != want_named) {
      printf "cli-errors: the command table of docs/design.md names %d error(s) for its commands, and spec/cli-errors.test.sh states %d\n", named, want_named
      exit 1
    }
    if (missing > 0) {
      printf "cli-errors: %d of %d named errors declared on their command, %d missing\n", named - missing, named, missing
      exit 1
    }
    printf "cli-errors: %d of %d named errors declared on their command\n", named, named
  }
' DESIGN="$design" "$binding" "$design"
