#!/bin/sh
# The local gate runs the `ess` release the forge runs and the specification requires.
#
# The pin of the local gate is `ESS_TOOLCHAIN` in the root `env:` of Taskfile.yml. The `ess`
# dispatcher reads it, so a host whose `ess` in PATH is a newer release delegates each call to
# the pinned one, which it holds beside it; where the pinned release is the `ess` in PATH, as on
# the forge, it runs itself. The forge's copy is `ESS_VERSION` of .github/workflows/pages.yml
# (release.test.sh holds that of release.yml equal to it), and spec/ess-inputs.yaml holds the
# requirement `ess <major>.<minor>`. The script checks, on the tree and on broken copies:
#
#   - Taskfile.yml names `ESS_TOOLCHAIN` once, in its root `env:`, as a version
#     `<major>.<minor>.<patch>`: a task that sets it again overrides the pin;
#   - it is the one `ESS_VERSION` of pages.yml;
#   - its major and minor are the requirement of spec/ess-inputs.yaml;
#   - every call of `ess` that `task check:spec` and `task check:generated` make is started with
#     that value. Each task runs in the copy to its end with a stand-in `ess` first in PATH that
#     writes the value and the command of each call into a file it names itself, so a call that
#     empties its environment (`env -i`) is recorded too, and succeeds: it makes the directory of
#     `--out` and prints the line of `ess generate synthesize` that `check:spec` reads. A copy
#     holds a stand-in that exits 0 for each `sh spec/<name>.test.sh` of Taskfile.yml and an empty
#     directory for each generated crate, so a task fails only where an `ess` call of it is no
#     longer reached. The caller's own `ESS_TOOLCHAIN`, which `task` would put before the
#     Taskfile's, is unset for these runs.
#
# The pin is read with or without its double or single quotes. The copies are under a
# directory the script creates with `mktemp -d` inside the ignored target/ and removes. Each
# broken copy has to be refused with the message of its rule, and a change that no longer
# applies to the file is a `FAIL` line.
#
# Exit 0: one `ok` line per case, the last line is `ess-pin: <n> of <n> cases pass`.
# Exit 1: each case that went the other way is a `FAIL` line with the output it read.
# Needs `task` and `jq` (the first step of `check:spec`).
set -u

root=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
taskfile=Taskfile.yml
pages=.github/workflows/pages.yml
inputs=spec/ess-inputs.yaml
generated=.github/scripts/check-generated.sh

for tool in task jq; do
  command -v "$tool" > /dev/null 2>&1 || { echo "ess-pin: $tool is not installed" >&2; exit 1; }
done

mkdir -p "$root/target"
top=$(mktemp -d "$root/target/ess-pin-test.XXXXXX") || { echo "ess-pin: mktemp -d in target/ failed" >&2; exit 1; }
trap 'rm -rf "$top"' EXIT
trap 'exit 1' HUP INT TERM

# A stand-in for `ess`: it appends `<ESS_TOOLCHAIN>|<first two words>` of each call to the
# file whose path it holds, makes the directory of `--out`, prints the line of a synthesis
# without a refusal, and exits 0.
record=$top/record
case $record in
  *"'"*) echo "ess-pin: the path of the tree holds a single quote: $record" >&2; exit 1 ;;
esac
mkdir -p "$top/bin"
printf '%s\n' \
  '#!/bin/sh' \
  "printf '%s|%s %s\\n' \"\${ESS_TOOLCHAIN-(unset)}\" \"\${1-}\" \"\${2-}\" >> '$record'" \
  'case "${1-} ${2-}" in "generate synthesize") echo "0 capabilities: 0 generated, 0 obligation(s), 0 refused" ;; esac' \
  'while [ "$#" -gt 1 ]; do' \
  '  [ "$1" != --out ] || mkdir -p "$2"' \
  '  shift' \
  'done' \
  'exit 0' > "$top/bin/ess"
chmod +x "$top/bin/ess"

# toolchain <dir>: the value of ESS_TOOLCHAIN in the root `env:` of its Taskfile.yml, without
# its quotes.
toolchain() {
  awk -v q="'" '
    /^env:[ \t]*$/ { inside = 1; next }
    /^[^ \t#]/ { inside = 0 }
    inside && /^  ESS_TOOLCHAIN:/ {
      value = $0
      sub(/^  ESS_TOOLCHAIN:[ \t]*/, "", value)
      sub(/[ \t]*$/, "", value)
      gsub(/"/, "", value)
      gsub(q, "", value)
      print value
    }' "$1/$taskfile"
}

# started <dir> <task>: run the task in the directory with the stand-in `ess` and print the
# calls it recorded, `<ESS_TOOLCHAIN>|<command>`; non-zero when the task failed.
started() {
  : > "$record"
  (
    cd "$1" || exit 1
    unset ESS_TOOLCHAIN
    PATH=$top/bin:$PATH task "$2"
  ) > "$top/task-out" 2>&1 < /dev/null
  status=$?
  LC_ALL=C sort -u "$record"
  return "$status"
}

# pin <dir>: 0 when the pin of the local gate holds in the directory, else 1 with the defect.
pin() {
  d=$1
  for file in "$taskfile" "$pages" "$inputs" "$generated"; do
    [ -r "$d/$file" ] || { echo "ess-pin: cannot read $file"; return 1; }
  done
  named=$(grep -c ESS_TOOLCHAIN "$d/$taskfile")
  value=$(toolchain "$d")
  [ -n "$value" ] || { echo "ess-pin: $taskfile sets no ESS_TOOLCHAIN in its root env:"; return 1; }
  [ "$named" = 1 ] || {
    echo "ess-pin: $taskfile names ESS_TOOLCHAIN $named times: the pin is the one entry of its root env:, and a task that sets it again overrides it"
    return 1
  }
  printf '%s\n' "$value" | grep -q -x '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*' \
    || { echo "ess-pin: ESS_TOOLCHAIN of $taskfile is $value, not a release <major>.<minor>.<patch>"; return 1; }
  forge=$(sed -n "s/^ *ESS_VERSION: *[\"']\{0,1\}\([^\"' ]*\)[\"']\{0,1\} *\$/\1/p" "$d/$pages" | LC_ALL=C sort -u)
  [ -n "$forge" ] || { echo "ess-pin: $pages sets no ESS_VERSION"; return 1; }
  [ "$(printf '%s\n' "$forge" | grep -c .)" = 1 ] || { echo "ess-pin: $pages sets more than one ESS_VERSION:" $forge; return 1; }
  [ "$value" = "$forge" ] || {
    echo "ess-pin: ESS_TOOLCHAIN of $taskfile is $value and ESS_VERSION of $pages is $forge: the local gate would run another ess than the forge"
    return 1
  }
  required=$(sed -n 's/^requires: *ess \([0-9][0-9]*\.[0-9][0-9]*\) *$/\1/p' "$d/$inputs")
  [ -n "$required" ] || { echo "ess-pin: $inputs names no requirement ess <major>.<minor>"; return 1; }
  [ "${value%.*}" = "$required" ] || {
    echo "ess-pin: $inputs requires ess $required and ESS_TOOLCHAIN of $taskfile is $value: the pinned release is not the one the specification requires"
    return 1
  }
  for task in check:spec check:generated; do
    if ! started "$d" "$task" > "$top/calls"; then
      echo "ess-pin: task $task failed with a stand-in ess that succeeds, so not every call of ess was seen:"
      sed 's/^/  /' "$top/task-out"
      return 1
    fi
    [ -s "$top/calls" ] || { echo "ess-pin: task $task started no ess"; return 1; }
    awk -F '|' -v want="$value" -v task="$task" -v file="$taskfile" '
      $1 != want {
        printf "ess-pin: task %s started `ess %s` with ESS_TOOLCHAIN %s, not %s of %s\n", task, $2, $1, want, file
        wrong = 1
      }
      END { exit wrong + 0 }' "$top/calls" || return 1
  done
}

cases=0 failed=0

# expect <case> <pass|refuse> <text> <dir>: run the check on the directory, compare its exit
# with the wanted one, and look for the text in what it printed.
expect() {
  cases=$((cases + 1))
  if pin "$4" > "$top/out" 2>&1; then got=pass; else got=refuse; fi
  why=
  if [ "$got" != "$2" ]; then
    why="answered $got, not $2"
  elif [ -n "$3" ] && ! grep -q -F -e "$3" "$top/out"; then
    why="the output lacks: $3"
  fi
  if [ -z "$why" ]; then
    echo "ok   $1"
    [ "$got" = pass ] || sed 's/^/     /' "$top/out"
  else
    echo "FAIL $1: $why"
    sed 's/^/     /' "$top/out"
    failed=$((failed + 1))
  fi
}

# copy <name>: a copy of the files the check reads, in a directory of its own, with a script
# that exits 0 for each `sh spec/<name>.test.sh` of Taskfile.yml and an empty directory for each
# generated crate; prints its path.
copy() {
  c=$top/copy-$1
  mkdir -p "$c/.github/workflows" "$c/.github/scripts" "$c/spec"
  for file in "$taskfile" "$pages" "$inputs" "$generated"; do
    cp "$root/$file" "$c/$file"
  done
  sed -n 's/^ *- sh \(spec\/[A-Za-z0-9_.-]*\.test\.sh\) *$/\1/p' "$root/$taskfile" | while IFS= read -r script; do
    printf '%s\n' '#!/bin/sh' 'exit 0' > "$c/$script"
  done
  sh "$root/$generated" --list | while IFS='|' read -r dir line; do
    [ -z "$dir" ] || mkdir -p "$c/$dir"
  done
  printf '%s\n' "$c"
}

# change <dir> <file> <sed script>: change the file of the copy; 1 when the file stays as it was.
change() {
  sed "$3" "$1/$2" > "$1/$2.new" && mv "$1/$2.new" "$1/$2"
  ! cmp -s "$1/$2" "$root/$2"
}

# variant <case> <pass|refuse> <text> <dir> <file> <sed script> [<file> <sed script>]...: a
# copy with each change, answered as wanted, a refusal with the text.
variant() {
  label=$1 want=$2 text=$3 c=$4
  shift 4
  while [ "$#" -ge 2 ]; do
    change "$c" "$1" "$2" || {
      cases=$((cases + 1)) failed=$((failed + 1))
      echo "FAIL $label: the change no longer applies to $1: $2"
      return
    }
    shift 2
  done
  expect "$label" "$want" "$text" "$c"
}

# broken <case> <text> <dir> <file> <sed script>...: a copy with each change, refused with the
# text.
broken() {
  label=$1 text=$2
  shift 2
  variant "$label" refuse "$text" "$@"
}

# The tree is judged on an unchanged copy: `task check:generated` writes under target/.
expect "the tree: Taskfile.yml pins the ess of pages.yml and spec/ess-inputs.yaml, and the tasks that run ess read it" pass "" "$(copy tree)"

pinned=$(toolchain "$root")
[ -n "$pinned" ] || pinned=0.0.0
other=${pinned%.*}.9999

broken "a copy whose ESS_TOOLCHAIN of Taskfile.yml differs from ESS_VERSION of pages.yml" \
  "ESS_TOOLCHAIN of $taskfile is $other and ESS_VERSION of $pages is $pinned" "$(copy toolchain)" \
  "$taskfile" "s/^\(  ESS_TOOLCHAIN:\).*/\1 \"$other\"/"

broken "a copy whose ESS_VERSION of pages.yml differs and Taskfile.yml follows it" \
  "$inputs requires ess ${pinned%.*} and ESS_TOOLCHAIN of $taskfile is 9999.0.0" "$(copy forge)" \
  "$pages" "s/^\( *ESS_VERSION:\).*/\1 \"9999.0.0\"/" \
  "$taskfile" "s/^\(  ESS_TOOLCHAIN:\).*/\1 \"9999.0.0\"/"

broken "a copy whose requirement of spec/ess-inputs.yaml is not the major and minor of ESS_TOOLCHAIN" \
  "$inputs requires ess 9999.0 and ESS_TOOLCHAIN of $taskfile is $pinned" "$(copy requirement)" \
  "$inputs" "s/^requires: ess .*/requires: ess 9999.0/"

broken "a copy whose Taskfile.yml has no ESS_TOOLCHAIN" \
  "$taskfile sets no ESS_TOOLCHAIN in its root env:" "$(copy absent)" \
  "$taskfile" "/^  ESS_TOOLCHAIN:/d"

broken "a copy whose task check:spec sets ESS_TOOLCHAIN again" \
  "$taskfile names ESS_TOOLCHAIN 2 times" "$(copy override)" \
  "$taskfile" "s/^  check:spec:\$/&\\
    env:\\
      ESS_TOOLCHAIN: \"$other\"/"

broken "a copy whose pages.yml installs no ess by version" \
  "$pages sets no ESS_VERSION" "$(copy unpinned)" \
  "$pages" "/^ *ESS_VERSION:/d"

broken "a copy whose pages.yml sets two values of ESS_VERSION" \
  "$pages sets more than one ESS_VERSION" "$(copy forges)" \
  "$pages" "/^ *ESS_VERSION:/{p;s/\"[^\"]*\"/\"$other\"/;}"

broken "a copy whose ESS_TOOLCHAIN and ESS_VERSION are no release" \
  "ESS_TOOLCHAIN of $taskfile is ${pinned%.*}.x, not a release" "$(copy form)" \
  "$taskfile" "s/^\(  ESS_TOOLCHAIN:\).*/\1 \"${pinned%.*}.x\"/" \
  "$pages" "s/^\( *ESS_VERSION:\).*/\1 \"${pinned%.*}.x\"/"

# The pin in the quotes the tree does not use: single quotes, or double where the tree has single.
if grep -q "^  ESS_TOOLCHAIN: *'" "$root/$taskfile"; then quoted="\"$pinned\""; else quoted="'$pinned'"; fi
variant "a copy whose ESS_TOOLCHAIN is in the other quotes, $quoted" pass "" "$(copy quotes)" \
  "$taskfile" "s/^\(  ESS_TOOLCHAIN:\).*/\1 $quoted/"

broken "a copy whose call ess specify cli of check:spec empties its environment" \
  "task check:spec started \`ess specify cli\` with ESS_TOOLCHAIN (unset)" "$(copy spec-cli)" \
  "$taskfile" 's/^      - ess specify cli /      - env -i PATH="$PATH" HOME="$HOME" ess specify cli /'

broken "a copy whose call ess generate synthesize of check:spec empties its environment" \
  "task check:spec started \`ess generate synthesize\` with ESS_TOOLCHAIN (unset)" "$(copy synthesize)" \
  "$taskfile" 's/if ! ess generate synthesize /if ! env -i PATH="$PATH" HOME="$HOME" ess generate synthesize /'

broken "a copy whose check-generated.sh starts ess without ESS_TOOLCHAIN" \
  "task check:generated started \`ess generate cli\` with ESS_TOOLCHAIN (unset)" "$(copy dropped)" \
  "$generated" "s/|ess generate/|env -u ESS_TOOLCHAIN ess generate/"

if [ "$failed" = 0 ]; then
  echo "ess-pin: $cases of $cases cases pass"
  exit 0
fi
echo "ess-pin: $failed of $cases cases fail"
exit 1
