#!/bin/sh
# A generated crate of this repository is byte for byte what its generator writes.
#
# One line per generated crate, in `lines` below: the directory, a `|`, and the generator line,
# in which `{out}` stands for the directory the generator writes into. A second generated crate
# is one more line and no other edit: .github/scripts/check-generated.test.sh takes its cases
# from `--list`.
#
#   check-generated.sh           compare each crate with a fresh generation
#   check-generated.sh --write   replace each crate with a fresh generation
#   check-generated.sh --list    print the lines
#
# A fresh generation goes into the ignored target/check-generated/<name>. The comparison covers
# every file of both directories: a file that differs, a file the generator did not write and a
# file it wrote that the tree lacks are each a difference. `.ess-output/`, the generator's own
# record of what it wrote, holds an id that is new in each generation; it is left out of the
# comparison and never copied into the tree.
#
# Exit 0: one line `check-generated: <directory>: <n> files as generated` per crate.
# Exit 1: each difference is named (of the files that were not generated, the first 20), with
# the command that regenerates.
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
cd "$root"

lines() {
  cat << 'LINES'
crates/ratchet-cli-contract|ess generate cli --path spec --binding spec/cli.yaml --out {out}
LINES
}

mode=${1:-check}
case $mode in
  check | --write) ;;
  --list) lines; exit 0 ;;
  *) echo "check-generated: unknown argument $mode" >&2; exit 2 ;;
esac

# files <directory>: its files, sorted, without the generator's own record.
files() {
  (cd "$1" && find . -type f ! -path './.ess-output/*' | LC_ALL=C sort)
}

work=target/check-generated
fail=0
while IFS='|' read -r dir generator; do
  [ -n "$dir" ] || continue
  fresh=$work/${dir##*/}
  rm -rf "$fresh"
  mkdir -p "$work"
  line=$(printf '%s\n' "$generator" | sed "s|{out}|$fresh|")
  [ "$line" != "$generator" ] || { echo "check-generated: the line of $dir names no {out}" >&2; exit 1; }
  if ! sh -c "$line" > "$fresh.txt" 2>&1 < /dev/null; then
    cat "$fresh.txt"
    echo "check-generated: $dir: the generator failed: $line" >&2
    exit 1
  fi

  if [ "$mode" = --write ]; then
    rm -rf "$fresh/.ess-output" "$dir"
    mkdir -p "$(dirname -- "$dir")"
    cp -R "$fresh" "$dir"
    echo "check-generated: $dir: $(files "$dir" | grep -c .) files written"
    continue
  fi

  [ -d "$dir" ] || { echo "check-generated: $dir: no such directory; run: task generate"; fail=1; continue; }
  files "$fresh" > "$fresh.generated"
  files "$dir" > "$fresh.tree"
  differences=0
  while IFS= read -r file; do
    if [ ! -f "$dir/$file" ]; then
      echo "check-generated: $dir/${file#./}: generated, and not in the tree"
    elif ! cmp -s "$fresh/$file" "$dir/$file"; then
      echo "check-generated: $dir/${file#./}: differs from what the generator writes"
    else
      continue
    fi
    differences=$((differences + 1))
  done < "$fresh.generated"
  extra=0
  while IFS= read -r file; do
    [ -f "$fresh/$file" ] && continue
    differences=$((differences + 1))
    extra=$((extra + 1))
    if [ "$extra" -le 20 ]; then
      echo "check-generated: $dir/${file#./}: in the tree, and not generated"
    fi
  done < "$fresh.tree"
  if [ "$extra" -gt 20 ]; then
    echo "check-generated: $dir: $((extra - 20)) more file(s) in the tree, and not generated"
  fi
  if [ "$differences" = 0 ]; then
    echo "check-generated: $dir: $(grep -c . "$fresh.generated") files as generated"
  else
    echo "check-generated: $dir: $differences difference(s). A generated file is never edited: change the specification and run: task generate"
    fail=1
  fi
done << LINES
$(lines)
LINES
exit $fail
