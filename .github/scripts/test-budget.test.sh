#!/bin/sh
# The test step keeps its budget: a test is ended at 60 s, the run at 120 s, each as a failure,
# and the step prints its ten slowest tests.
#
# The script reads two files, first as they are and then in broken copies:
#
# 1. .config/nextest.toml. `[profile.default]` holds a `slow-timeout` whose `period` times
#    `terminate-after` is at most 60 s, and a `global-timeout` of at most 120 s. No other line
#    of the file (another profile, an override) sets one of the two to more. cargo-nextest ends
#    such a test and such a run and exits non-zero. Each of the two is read as `<key> = ...` on
#    one line; a line that names one in another form (dotted keys, a table of its own) is
#    refused, and so are `on-timeout`, with which an ended test can count as passed, and a
#    `grace-period` over the 10 s cargo-nextest gives by default.
# 2. The task `test` of Taskfile.yml, run with a stand-in for `cargo` first in PATH, so nothing
#    is built. The stand-in prints twelve test lines in the form cargo-nextest prints them and
#    exits as told. The task has to call `cargo nextest run` without naming another
#    configuration file, call `cargo` for nothing else (`cargo test` reads no
#    .config/nextest.toml), print the ten slowest of the twelve, slowest first, after the line
#    `test: the ten slowest tests`, and exit non-zero when the stand-in does. Each run is made
#    three times, in the environments `step` names: that of a workstation, CI=true, in which
#    task writes its own lines in colour, and CI=true with GITHUB_ACTIONS=true, the environment
#    of the forge, in which task also prints one more line after a failed command.
#
# Each broken copy under the ignored target/test-budget-test/<case> holds the two files with one
# of these missing, and has to be refused.
#
# Exit 0: the last line is `test-budget: <n> of <n> broken copies refused`.
# Exit 1: the reasons the tree is refused, or each broken copy that was accepted.
# Needs `task`.
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
work=$root/target/test-budget-test
header='test: the ten slowest tests'

command -v task > /dev/null 2>&1 || { echo "test-budget: task is not installed" >&2; exit 1; }
for f in .config/nextest.toml Taskfile.yml; do
  [ -r "$root/$f" ] || { echo "test-budget: cannot read $f" >&2; exit 1; }
done

rm -rf "$work"
mkdir -p "$work/bin"

cat > "$work/bin/cargo" << 'CARGO'
#!/bin/sh
printf '%s\n' "$*" >> "$BUDGET_CALLS"
[ "${1-} ${2-}" = "nextest run" ] || exit 0
case " $* " in *" --no-run "*) exit 0 ;; esac
cat "$BUDGET_OUTPUT"
exit "$BUDGET_EXIT"
CARGO
chmod +x "$work/bin/cargo"

cat > "$work/nextest-output" << 'OUTPUT'
    Finished `test` profile [unoptimized] target(s) in 0.05s
────────────
 Nextest run ID 00000000-0000-4000-8000-000000000000 with nextest profile: default
    Starting 12 tests across 2 binaries
        PASS [   0.004s] ( 1/12) fixture::main alpha::quick
        PASS [   1.250s] ( 2/12) fixture::main alpha::reads_a_file
        PASS [   0.300s] ( 3/12) fixture::main beta::third
        PASS [  12.000s] ( 4/12) fixture::main beta::long
        PASS [   0.002s] ( 5/12) fixture::main beta::quickest
        PASS [   0.750s] ( 6/12) fixture::main gamma::sixth
        PASS [   3.100s] ( 7/12) other::main delta::seventh
        PASS [   0.090s] ( 8/12) other::main delta::eighth
        FAIL [   2.500s] ( 9/12) other::main delta::fails
        PASS [   5.000s] (10/12) other::main epsilon::tenth
        SLOW [> 60.000s] (─────) other::main epsilon::hangs
     TIMEOUT [  60.004s] (11/12) other::main epsilon::hangs
        PASS [   0.040s] (12/12) other::main epsilon::twelfth
────────────
     Summary [  60.310s] 12 tests run: 10 passed, 1 failed, 1 timed out, 0 skipped
        FAIL [   2.500s] ( 9/12) other::main delta::fails
     TIMEOUT [  60.004s] (11/12) other::main epsilon::hangs
error: test run failed
OUTPUT

# One status in colour, as cargo-nextest writes it to a terminal.
esc=$(printf '\033')
sed "s/^        PASS \[  12/        ${esc}[32;1mPASS${esc}[0m [  12/" "$work/nextest-output" > "$work/nextest-output.new"
if cmp -s "$work/nextest-output" "$work/nextest-output.new"; then
  echo "test-budget: no line of the stand-in's output got a colour" >&2
  exit 1
fi
mv "$work/nextest-output.new" "$work/nextest-output"

cat > "$work/expected" << 'EXPECTED'
60.004s other::main epsilon::hangs
12.000s fixture::main beta::long
5.000s other::main epsilon::tenth
3.100s other::main delta::seventh
2.500s other::main delta::fails
1.250s fixture::main alpha::reads_a_file
0.750s fixture::main gamma::sixth
0.300s fixture::main beta::third
0.090s other::main delta::eighth
0.040s other::main epsilon::twelfth
EXPECTED

# limits <nextest.toml>: 0 when the file ends a test within 60 s and the run within 120 s.
limits() {
  awk '
    function seconds(text) { return text ~ /^[0-9]+s$/ ? substr(text, 1, length(text) - 1) + 0 : -1 }
    # quoted(key): the text in quotes after `key =`, where the key follows `{`, `,` or a blank,
    # so `period` is not read out of `grace-period`; "" when the line has none.
    function quoted(key,   t) {
      if (!match($0, "[{, \t]" key "[ \t]*=[ \t]*\"[^\"]*\"")) return ""
      t = substr($0, RSTART, RLENGTH); sub(/^[^"]*"/, "", t); sub(/"$/, "", t)
      return t
    }
    /^[ \t]*#/ { next }
    /on-timeout/ {
      print "nextest.toml line " NR ": on-timeout can let a test that was ended count as passed"; bad = 1
    }
    /^[ \t]*\[/ {
      section = $0; gsub(/[ \t]/, "", section)
      if (section ~ /slow-timeout|global-timeout/) {
        print "nextest.toml line " NR ": a table of its own is a form of slow-timeout this script does not read"; bad = 1
      }
      next
    }
    /^[ \t]*slow-timeout[ \t]*=/ {
      period = seconds(quoted("period")); after = -1; grace = 0
      if (match($0, /[{, \t]terminate-after[ \t]*=[ \t]*[0-9]+[ \t]*[,}]/)) {
        t = substr($0, RSTART, RLENGTH); sub(/^[^0-9]*/, "", t); after = t + 0
      }
      if ($0 ~ /grace-period/) grace = seconds(quoted("grace-period"))
      if (period < 1 || after < 1 || period * after > 60) {
        print "nextest.toml line " NR ": this slow-timeout does not end a test within 60 s"; bad = 1
      } else if (grace < 0 || grace > 10) {
        print "nextest.toml line " NR ": this grace-period gives a test that ignores the first signal more than the 10 s cargo-nextest gives by default"; bad = 1
      } else if (section == "[profile.default]") kill = period * after
      next
    }
    /^[ \t]*global-timeout[ \t]*=/ {
      t = $0; sub(/^[^"]*"/, "", t); sub(/".*$/, "", t); bound = seconds(t)
      if (bound < 1 || bound > 120) {
        print "nextest.toml line " NR ": this global-timeout does not end the run within 120 s"; bad = 1
      } else if (section == "[profile.default]") run = bound
      next
    }
    /slow-timeout|global-timeout/ {
      print "nextest.toml line " NR ": this script reads slow-timeout and global-timeout as `<key> = ...` on one line, not in this form"; bad = 1
    }
    END {
      if (!kill) { print "nextest.toml: [profile.default] has no slow-timeout with period and terminate-after"; bad = 1 }
      if (!run) { print "nextest.toml: [profile.default] has no global-timeout"; bad = 1 }
      exit bad
    }
  ' "$1"
}

# step <dir> <exit> <where>: 0 when the task `test` of <dir> calls cargo nextest run, lists the
# ten slowest tests and exits zero exactly when cargo nextest run exits <exit> = 0.
#
# <where> is the environment `task` runs in. It is set here whatever the caller's is, so this
# script makes the same runs on a workstation and on the forge. Each run starts without the
# variables that change what task prints: GITHUB_ACTIONS, CI, FORCE_COLOR, NO_COLOR, CLICOLOR,
# CLICOLOR_FORCE and every TASK_* (TASK_COLOR, TASK_VERBOSE, TASK_SILENT, TASK_OUTPUT, ...).
#   host    None of them is set. After a failed command task prints one line,
#           `task: Failed to run task "test": exit status 100`.
#   colour  CI=true, as a runner of any forge sets it. task then writes its own lines in colour,
#           also into a file: that line starts with an escape sequence, ESC[31m.
#   forge   CI=true and GITHUB_ACTIONS=true, as a runner of the forge sets them. task then also
#           prints the line `::error title=Task 'test' failed::exit status 100` before that one.
step() {
  : > "$work/calls"
  status=0
  (
    cd "$1" || exit 125
    for name in $(env | sed -n 's/^\(TASK_[A-Za-z0-9_]*\)=.*/\1/p'); do
      unset "$name"
    done
    unset GITHUB_ACTIONS CI FORCE_COLOR NO_COLOR CLICOLOR CLICOLOR_FORCE
    case $3 in
      host) ;;
      colour) CI=true; export CI ;;
      forge) CI=true; GITHUB_ACTIONS=true; export CI GITHUB_ACTIONS ;;
      *) exit 125 ;;
    esac
    PATH="$work/bin:$PATH" BUDGET_CALLS="$work/calls" BUDGET_OUTPUT="$work/nextest-output" \
      BUDGET_EXIT="$2" task test
  ) > "$work/task-output" 2>&1 < /dev/null || status=$?
  case $3 in
    host) where='CI and GITHUB_ACTIONS unset' ;;
    colour) where='CI=true, GITHUB_ACTIONS unset' ;;
    *) where='CI=true, GITHUB_ACTIONS=true' ;;
  esac
  held=0
  if ! grep '^nextest run' "$work/calls" | grep -q -v -e '--no-run'; then
    echo "Taskfile.yml: the task test does not call cargo nextest run"; held=1
  fi
  if grep -q -v '^nextest run' "$work/calls"; then
    echo "Taskfile.yml: the task test calls \`cargo $(grep -v '^nextest run' "$work/calls" | head -n 1)\`: only cargo nextest run reads .config/nextest.toml, so no file bounds that call"; held=1
  fi
  if grep -q -e '--config-file' -e '--tool-config-file' "$work/calls"; then
    echo "Taskfile.yml: the task test names another configuration file than .config/nextest.toml"; held=1
  fi
  if [ "$2" = 0 ] && [ "$status" != 0 ]; then
    echo "Taskfile.yml: the task test exits $status when cargo nextest run exits 0 ($where)"; held=1
  fi
  if [ "$2" != 0 ] && [ "$status" = 0 ]; then
    echo "Taskfile.yml: the task test exits 0 when cargo nextest run exits $2 ($where)"; held=1
  fi
  # The list ends at the first line task writes itself: `task: ...` or, on the forge, `::error ...`.
  # A line is read without its colour: task is not told to leave it out, so each run reads what
  # task prints in that environment.
  awk -v header="$header" '
    { gsub(/\033\[[0-9;:]*m/, "") }
    listing && (/^task: / || /^::/) { exit }
    listing { print $1, $2, $3 }
    $0 == header { listing = 1 }
  ' "$work/task-output" > "$work/listed"
  if ! cmp -s "$work/listed" "$work/expected"; then
    echo "Taskfile.yml: the task test does not print the ten slowest of the twelve tests after the line \"$header\" (cargo nextest run exits $2, $where)"; held=1
  fi
  return $held
}

# budget <dir>: 0 when the two files of <dir> keep the budget; the reasons otherwise.
budget() {
  kept=0
  limits "$1/.config/nextest.toml" || kept=1
  for environment in host colour forge; do
    step "$1" 0 "$environment" || kept=1
    step "$1" 100 "$environment" || kept=1
  done
  return $kept
}

# copy <case>: a fresh copy of the two files; sets $c, $nextest, $taskfile.
copy() {
  c=$work/$1
  mkdir -p "$c/.config"
  cp "$root/.config/nextest.toml" "$c/.config/nextest.toml"
  cp "$root/Taskfile.yml" "$c/Taskfile.yml"
  nextest=$c/.config/nextest.toml
  taskfile=$c/Taskfile.yml
}

# edit <file> <awk program>: an edit that has to change the file.
edit() {
  awk "$2" "$1" > "$1.new"
  if cmp -s "$1" "$1.new"; then
    echo "test-budget: the edit of case $(basename -- "$c") changes nothing in $(basename -- "$1")" >&2
    exit 1
  fi
  mv "$1.new" "$1"
}

fail=0 cases=0 refused=0

# broken <what>: the copy $c has to be refused.
broken() {
  cases=$((cases + 1))
  if budget "$c" > "$c/reasons" 2>&1; then
    echo "FAIL refuse <- $1: accepted"
    fail=1
  else
    echo "ok   refuse <- $1"
    refused=$((refused + 1))
  fi
}

copy unchanged
if ! budget "$c" > "$c/reasons" 2>&1; then
  echo "test-budget: the tree does not keep the test budget" >&2
  sed 's/^/  /' "$c/reasons" >&2
  exit 1
fi
echo "ok   accept <- .config/nextest.toml and the task test as they are"

copy no-kill
edit "$nextest" '/^slow-timeout/ { sub(/, *terminate-after *= *[0-9]+/, "") } { print }'
broken "slow-timeout without terminate-after: a slow test is reported and not ended"

copy late-kill
edit "$nextest" '/^slow-timeout/ { sub(/"[0-9]+s"/, "\"61s\"") } { print }'
broken "slow-timeout with a period of 61 s"

copy no-run-bound
edit "$nextest" '!/^global-timeout/'
broken "no global-timeout: the run has no bound"

copy late-run-bound
edit "$nextest" '/^global-timeout/ { sub(/"[0-9]+s"/, "\"121s\"") } { print }'
broken "global-timeout of 121 s"

copy override
edit "$nextest" '{ print } END { print ""; print "[[profile.default.overrides]]"; print "filter = \"all()\""; print "slow-timeout = { period = \"300s\", terminate-after = 1 }" }'
broken "an override that gives every test 300 s"

copy grace-period-first
edit "$nextest" '/^slow-timeout/ { print "slow-timeout = { grace-period = \"1s\", period = \"600s\", terminate-after = 1 }"; next } { print }'
broken "slow-timeout with a period of 600 s written after a grace-period of 1 s"

copy dotted-override
edit "$nextest" '{ print } END { print ""; print "[[profile.default.overrides]]"; print "filter = \"all()\""; print "slow-timeout.period = \"300s\""; print "slow-timeout.terminate-after = 1" }'
broken "an override that gives every test 300 s, written with dotted keys"

copy table-of-its-own
edit "$nextest" '{ print } END { print ""; print "[profile.other.slow-timeout]"; print "period = \"300s\""; print "terminate-after = 1" }'
broken "another profile whose slow-timeout is a table of its own with a period of 300 s"

copy on-timeout-pass
edit "$nextest" '/^slow-timeout/ { sub(/terminate-after *= *1/, "terminate-after = 1, on-timeout = \"pass\"") } { print }'
broken "slow-timeout with on-timeout = pass: a test ended at 60 s counts as passed"

copy long-grace-period
edit "$nextest" '/^slow-timeout/ { sub(/terminate-after *= *1/, "terminate-after = 1, grace-period = \"600s\"") } { print }'
broken "slow-timeout with a grace-period of 600 s: a test that ignores the first signal runs on"

copy no-list
edit "$taskfile" '
  /^  test:$/ { print; print "    cmds:"; print "      - cargo nextest run --workspace --locked"; inside = 1; next }
  inside && /^  [^ ]/ { inside = 0 }
  inside && /^[^ ]/ { inside = 0 }
  !inside { print }'
broken "a task test that runs the tests and lists none"

copy status-lost
edit "$taskfile" '{ sub(/exit "\$status"/, "exit 0") } { print }'
broken "a task test that exits 0 when the run failed"

copy other-config
edit "$taskfile" '{ sub(/cargo nextest run --workspace --locked >/, "cargo nextest run --workspace --locked --config-file other.toml >") } { print }'
broken "a task test that reads another configuration file"

copy cargo-test-beside
edit "$taskfile" '{ print } /^      - cargo nextest run --workspace --locked --no-run$/ { print "      - cargo test --workspace --locked --doc" }'
broken "a task test that also runs cargo test, which no file bounds"

if [ "$fail" != 0 ]; then
  echo "test-budget: $refused of $cases broken copies refused" >&2
  exit 1
fi
echo "test-budget: $refused of $cases broken copies refused"
