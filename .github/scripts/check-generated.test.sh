#!/bin/sh
# `task check:generated` passes on the tree and refuses a generated crate that was changed.
#
# The cases come from the lines of .github/scripts/check-generated.sh (`--list`): one set per
# generated crate, so a second crate needs no edit here. The script copies the tree into the
# ignored target/check-generated-test/tree, without target/, .git and website/ (a generator
# that reads one of them fails on the copy, which this script reports), and runs
# `task check:generated` in the copy:
#
#   - unchanged: exit 0;
#   - per crate, one byte of its first file replaced: non-zero;
#   - per crate, its last file removed: non-zero;
#   - per crate, one file added: non-zero;
#   - per crate, all three undone: exit 0.
#
# Exit 0: the last line is `check-generated: <n> of <n> changes refused in <m> generated crate(s)`.
# Exit 1: each case that went the other way is named with the output of the task.
# Needs `task` and what the generator lines call.
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
work=$root/target/check-generated-test
copy=$work/tree
script=.github/scripts/check-generated.sh

command -v task > /dev/null 2>&1 || { echo "check-generated: task is not installed" >&2; exit 1; }
[ -r "$root/$script" ] || { echo "check-generated: cannot read $script" >&2; exit 1; }

rm -rf "$work"
mkdir -p "$copy"
for entry in "$root"/* "$root"/.[!.]*; do
  [ -e "$entry" ] || continue
  case ${entry##*/} in target | .git | website) continue ;; esac
  cp -R "$entry" "$copy/"
done

sh "$copy/$script" --list > "$work/lines"
crates=$(grep -c . "$work/lines" || true)
[ "$crates" -gt 0 ] || { echo "check-generated: $script --list names no generated crate" >&2; exit 1; }

fail=0 cases=0 refused=0

# expect <pass|refuse> <case>: run the task in the copy and compare its exit with the wanted one.
expect() {
  if (cd "$copy" && task check:generated) > "$work/out" 2>&1 < /dev/null; then got=pass; else got=refuse; fi
  if [ "$got" = "$1" ]; then
    echo "ok   $1 <- $2"
    return 0
  fi
  echo "FAIL $1 <- $2: task check:generated answered $got"
  sed 's/^/     /' "$work/out"
  fail=1
  return 1
}

# changed <case>: a case in which the task has to exit non-zero.
changed() {
  cases=$((cases + 1))
  if expect refuse "$1"; then refused=$((refused + 1)); fi
}

expect pass "the unchanged copy" || { echo "check-generated: the unchanged copy is refused" >&2; exit 1; }

while IFS='|' read -r dir generator; do
  [ -n "$dir" ] || continue
  [ -d "$copy/$dir" ] || { echo "check-generated: $dir is no directory of the tree" >&2; exit 1; }
  (cd "$copy/$dir" && find . -type f ! -path './.ess-output/*' | LC_ALL=C sort) > "$work/files"
  first=$(sed -n '1s|^\./||p' "$work/files")
  last=$(sed -n '$s|^\./||p' "$work/files")
  [ -n "$first" ] || { echo "check-generated: $dir holds no file" >&2; exit 1; }

  cp "$copy/$dir/$first" "$work/saved"
  if [ "$(dd if="$work/saved" bs=1 count=1 2> /dev/null)" = X ]; then byte=Y; else byte=X; fi
  printf '%s' "$byte" | dd of="$copy/$dir/$first" bs=1 count=1 conv=notrunc 2> /dev/null
  differing=$(cmp -l "$work/saved" "$copy/$dir/$first" | grep -c . || true)
  [ "$differing" = 1 ] || { echo "check-generated: the edit of $dir/$first changed $differing bytes, not 1" >&2; exit 1; }
  changed "$dir: one byte of $first replaced"
  cp "$work/saved" "$copy/$dir/$first"

  cp "$copy/$dir/$last" "$work/saved"
  rm "$copy/$dir/$last"
  changed "$dir: $last removed"
  cp "$work/saved" "$copy/$dir/$last"

  echo "not generated" > "$copy/$dir/not-generated.txt"
  changed "$dir: not-generated.txt added"
  rm "$copy/$dir/not-generated.txt"

  expect pass "$dir: the three changes undone" || true
done < "$work/lines"

if [ "$fail" != 0 ]; then
  echo "check-generated: $refused of $cases changes refused in $crates generated crate(s)" >&2
  exit 1
fi
echo "check-generated: $refused of $cases changes refused in $crates generated crate(s)"
