#!/bin/sh
# The release procedure of AGENTS.md § "Release", checked without a network, a build, a tag or
# the real `gh`: the files a release is cut from, and the scripts the tag workflow and the
# release steps run.
#
#   - CHANGELOG.md is in the Keep a Changelog form: `# Changelog`, a link to version 1.1.0 and
#     nothing but text before `## [Unreleased]`, which is the first section; every other
#     section is `## [<version>] - <YYYY-MM-DD>` with a date of the calendar, each version once,
#     the newest first (compared as three numbers); only the six headings below a section, each
#     with a bullet, one bullet per change on one line. The same check refuses 12 broken copies,
#     each for its defect.
#   - AGENTS.md has a section "Release" that names the scripts, the workflow, the steps and
#     what happens to a tag whose run fails.
#   - release-check.sh: a tag equal to the workspace version passes; another tag, a tag that is
#     no bare version and a manifest without a workspace version fail. A tag with a dated
#     section that holds a change passes; one without a section, one whose section has no date,
#     a date of another form or a date that is none, and one whose section holds no bullet
#     under a heading fail. A version cut after a tag that was not released passes.
#   - release-package.sh: the notes cut for a tag equal its section, and a tag without a
#     section or with a section of headings alone has none; the archive built from a stub
#     binary holds `ratchet`, `LICENSE` and `README.md` with owner 0 and the modes 755 and 644
#     and verifies against the `SHA256SUMS` written beside it; a binary that prints anything
#     but `ratchet <version>` or does not exit 0, another target, a file that is no executable,
#     a version of another form and a directory that lacks an archive are refused.
#   - release-verify.sh: a recorded release description with the bot as author beside a
#     directory of its three assets passes. It fails for another author, a draft, a
#     prerelease, a description that names neither state, is of another release or is no JSON
#     object, an asset that is not uploaded, not attached or not in the directory, a fourth
#     asset, a `SHA256SUMS` that does not name an archive once, a changed archive, an archive
#     that holds another file, a path outside its directory, a link or a directory in the
#     place of a file, and a binary that prints anything but `ratchet <version>` or does not
#     exit 0. It runs no file a link points to and leaves no file behind. With `--description`
#     and `--assets` it calls no `gh`; without them it reads the release through `gh release
#     view` and `gh release download`, here a stand-in first in PATH, and fails when either
#     fails. The stand-in answers only a call with `--repo`, the `--json` fields it is asked
#     for and the files of the `--pattern` values, and refuses every other call.
#   - .github/workflows/release.yml is read as a structure: its trigger is the bare version
#     tag alone, every permission is `contents: read`, it reads no token and publishes
#     nothing; the jobs are Gate, Package and Bundle with their `needs` and runners, every
#     step always runs and no result is discarded; the commands, the matrix, the artifact
#     names and the upload and download paths fit each other and the scripts; the steps that
#     install the tools of the gate equal those of .github/workflows/pages.yml.
#   - Mutants: a copy of the workflow or of a script with one change is refused by the cases
#     above, one `ok` line per mutant. A mutant that the cases accept is a `FAIL` line, and so
#     is one whose change no longer applies to the file. The cases stand in groups, each run
#     alone in a directory of its own, on the files and on the copy alike; a mutant names the
#     group whose cases refuse it.
#
# Every file the script writes is under a directory it creates with `mktemp -d` inside
# ${TMPDIR:-target} and removes.
#
# Exit 0: one `ok` line per case, the last line is `release: <n> of <n> cases pass`.
# Exit 1: each case that went the other way is a `FAIL` line with the output it read.
# Needs `jq`, `tar`, `sha256sum` and GNU `date` (`date -d`: the CI runners are Ubuntu, and a
# workstation that runs the gate has GNU date too).
set -u

root=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
scripts=$root/.github/scripts
workflow=$root/.github/workflows/release.yml
pages=$root/.github/workflows/pages.yml
bot='b10x-bot[bot]'
repository=beyond10x/ratchet
version=1.2.3
x86_64=ratchet-$version-x86_64-unknown-linux-gnu
aarch64=ratchet-$version-aarch64-unknown-linux-gnu

for tool in jq tar sha256sum; do
  command -v "$tool" > /dev/null 2>&1 || { echo "release: $tool is not installed" >&2; exit 1; }
done
[ "$(date -u -d 2000-02-29 +%Y-%m-%d 2> /dev/null)" = 2000-02-29 ] \
  || { echo "release: \`date -d\` reads no date: GNU date is needed" >&2; exit 1; }

base=${TMPDIR:-$root/target}
mkdir -p "$base"
top=$(mktemp -d "$base/release-test.XXXXXX") || { echo "release: mktemp -d in $base failed" >&2; exit 1; }
trap 'rm -rf "$top"' EXIT
trap 'exit 1' HUP INT TERM

# work: where the cases of a group write, a directory per group (`alone`, below). fix: the
# fixtures, written once.
work=$top/work
fix=$top/fixture
mkdir -p "$work" "$fix"

# inside: the mutant the cases run on, empty for the files of the repository. On a mutant a
# case prints nothing, and the first case that fails ends the run.
inside=
cases=0 failed=0

ok() {
  [ -z "$inside" ] || return 0
  cases=$((cases + 1))
  echo "ok   $1"
}

# bad <case> [<file>]: the case failed; the file is what it read.
bad() {
  echo "FAIL $1"
  if [ -n "${2-}" ] && [ -f "$2" ]; then sed 's/^/     /' "$2"; fi
  [ -z "$inside" ] || exit 1
  cases=$((cases + 1))
  failed=$((failed + 1))
}

# check <case> <pass|refuse> [<text>...] -- <command>...: run the command, compare its exit
# with the wanted one, and look for each text in what it printed.
check() {
  label=$1 want=$2
  shift 2
  texts=
  while [ "$1" != -- ]; do
    texts="$texts$1
"
    shift
  done
  shift
  if "$@" > "$work/out" 2>&1 < /dev/null; then got=pass; else got=refuse; fi
  why=
  [ "$got" = "$want" ] || why="answered $got, not $want"
  if [ -z "$why" ] && [ -n "$texts" ]; then
    printed=$(cat "$work/out")
    while IFS= read -r text; do
      [ -n "$text" ] || continue
      case $printed in
        *"$text"*) ;;
        *) why="the output lacks: $text"; break ;;
      esac
    done << TEXTS
$texts
TEXTS
  fi
  if [ -z "$why" ]; then
    ok "$label"
  else
    bad "$label: $why" "$work/out"
  fi
}

# same <what> <wanted> <read>: the two texts are equal.
same() {
  [ "$2" = "$3" ] && return 0
  echo "$1:"
  printf '%s\n' "$3" | sed 's/^/  /'
  echo "wanted:"
  printf '%s\n' "$2" | sed 's/^/  /'
  return 1
}

# A stand-in for `gh`, first in PATH for every command below. It writes the arguments of each
# call as one line to GH_CALLS and answers the two calls release-verify.sh is meant to make,
# for the repository GH_REPOSITORY, from the directory GH_RELEASE:
#
#   gh release view <tag> --repo <repository> --json <fields>
#       the description with the fields asked for, and no other
#   gh release download <tag> --repo <repository> --dir <directory> --pattern <name>...
#       the assets a pattern names, into the directory
#
# Every other call, a call without `--repo`, without `--json` or without a pattern, and a call
# for another repository exits 2 with its arguments on standard error. Without GH_RELEASE, or
# for another tag, it finds no release; with GH_NO_DOWNLOAD the download fails.
mkdir -p "$top/bin"
cat > "$top/bin/gh" << 'GH'
#!/bin/sh
arguments=$*
printf '%s\n' "$arguments" >> "$GH_CALLS"
unknown() {
  echo "gh stand-in: $1: gh $arguments" >&2
  exit 2
}
[ "${1-}" = release ] || unknown "no call of a release script"
case ${2-} in
  view | download) command=$2 ;;
  *) unknown "no call of a release script" ;;
esac
[ $# -ge 3 ] || unknown "no tag"
tag=$3
shift 3
repo= json= dir= patterns=
while [ $# -gt 0 ]; do
  [ $# -ge 2 ] || unknown "an option without a value"
  case $command$1 in
    view--repo | download--repo) repo=$2 ;;
    view--json) json=$2 ;;
    download--dir) dir=$2 ;;
    download--pattern) patterns="$patterns$2
" ;;
    *) unknown "an argument $command does not take here" ;;
  esac
  shift 2
done
[ -n "$repo" ] || unknown "no --repo"
[ "$repo" = "${GH_REPOSITORY-}" ] || unknown "--repo is not ${GH_REPOSITORY-}"
case $command in
  view) [ -n "$json" ] || unknown "no --json" ;;
  download)
    [ -n "$dir" ] || unknown "no --dir"
    [ -n "$patterns" ] || unknown "no --pattern"
    ;;
esac
[ -n "${GH_RELEASE-}" ] && [ "$(jq -r '.tagName // ""' "$GH_RELEASE/description.json")" = "$tag" ] \
  || { echo "release not found" >&2; exit 1; }
case $command in
  view)
    jq --arg fields "$json" '
      . as $release
      | ($fields | split(",")) as $names
      | ($names - ["assets", "author", "isDraft", "isPrerelease", "tagName"]) as $unknown
      | if ($unknown | length) > 0 then error("Unknown JSON field: \($unknown[0])") else . end
      | reduce $names[] as $name ({}; .[$name] = $release[$name])' "$GH_RELEASE/description.json"
    ;;
  download)
    [ -z "${GH_NO_DOWNLOAD-}" ] || { echo "download failed" >&2; exit 1; }
    mkdir -p "$dir"
    copied=0
    for file in "$GH_RELEASE"/assets/*; do
      name=${file##*/}
      while IFS= read -r pattern; do
        [ -n "$pattern" ] || continue
        # shellcheck disable=SC2254
        case $name in
          $pattern) cp "$file" "$dir/" && copied=$((copied + 1)); break ;;
        esac
      done << PATTERNS
$patterns
PATTERNS
    done
    [ "$copied" != 0 ] || { echo "no assets match the file pattern" >&2; exit 1; }
    ;;
esac
GH
chmod +x "$top/bin/gh"
PATH=$top/bin:$PATH
GH_CALLS=$work/gh-calls
GH_REPOSITORY=$repository
export PATH GH_CALLS GH_REPOSITORY
unset GH_RELEASE GH_NO_DOWNLOAD
: > "$GH_CALLS"

# --- CHANGELOG.md -------------------------------------------------------------------------

# changelog_form <file>: print each line that leaves the Keep a Changelog form; exit 1 on any.
# Whether a date is one of the calendar is asked of GNU date: it prints a date it reads back
# unchanged and reads no 2026-02-30.
changelog_form() {
  awk '
    function defect(text) { print "CHANGELOG.md:" NR ": " text; defects++ }
    function calendar(day,    command, back) {
      command = "date -u -d " day " +%Y-%m-%d 2> /dev/null"
      back = ""
      command | getline back
      close(command)
      return back == day
    }
    # The heading and the section that end here each hold a bullet.
    function heading_ends() {
      if (kind != "" && !kind_bullets) { print "CHANGELOG.md:" kind_line ": the heading `" kind "` has no bullet"; defects++ }
      kind = ""
    }
    function section_ends() {
      heading_ends()
      if (released != "" && !section_bullets) { print "CHANGELOG.md:" section_line ": the section `" released "` holds no change"; defects++ }
      released = ""
    }
    BEGIN {
      count = split("Added Changed Deprecated Removed Fixed Security", names, " ")
      for (i = 1; i <= count; i++) kinds["### " names[i]] = 1
    }
    NR == 1 { if ($0 != "# Changelog") defect("the first line is not `# Changelog`"); next }
    /^## / {
      section_ends()
      sections++
      section_bullets = 0
      if ($0 == "## [Unreleased]") {
        unreleased++
        if (sections != 1) defect("`## [Unreleased]` is not the first section")
      } else if ($0 ~ /^## \[[0-9]+\.[0-9]+\.[0-9]+\] - [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$/) {
        released = $0
        section_line = NR
        number = substr($2, 2, length($2) - 2)
        split(number, part, ".")
        if (!calendar($4)) defect("`" $4 "` is no date of the calendar")
        if (number in seen) {
          defect("the version " number " has two sections")
        } else if (versions && !(part[1] + 0 < major || (part[1] + 0 == major && (part[2] + 0 < minor || (part[2] + 0 == minor && part[3] + 0 < patch))))) {
          defect("the version " number " is not below " previous ": the newest release stands first")
        }
        seen[number] = 1
        versions++
        previous = number
        major = part[1] + 0
        minor = part[2] + 0
        patch = part[3] + 0
      } else {
        defect("a section is `## [Unreleased]` or `## [<version>] - <YYYY-MM-DD>`")
      }
      next
    }
    !sections {
      if (index($0, "https://keepachangelog.com/en/1.1.0/")) named = 1
      if ($0 ~ /^(#|[-*+] |[ \t])/) defect("before `## [Unreleased]` stands only the title and its text, no heading and no bullet")
      next
    }
    /^### / {
      heading_ends()
      if (!($0 in kinds)) defect("a heading is one of Added, Changed, Deprecated, Removed, Fixed, Security")
      kind = $0
      kind_line = NR
      kind_bullets = 0
      next
    }
    /^$/ { next }
    /^- / {
      if (kind == "") defect("a bullet stands under none of the six headings")
      else { kind_bullets++; section_bullets++ }
      next
    }
    { defect("the line is no heading and starts no bullet: a change is one bullet on one line") }
    END {
      section_ends()
      if (!named) { print "CHANGELOG.md: no link to Keep a Changelog 1.1.0 before the first section"; defects++ }
      if (unreleased != 1) { print "CHANGELOG.md: " (unreleased + 0) " sections `## [Unreleased]`, not 1"; defects++ }
      exit defects ? 1 : 0
    }' "$1"
}

# The changelog of the fixtures: an open section, the release under test and an older one.
changelog=$fix/CHANGELOG.md
cat > "$changelog" << 'CHANGELOG'
# Changelog

All notable changes to this project are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- a change that is not released

## [1.2.3] - 2026-01-02

### Added

- the first change of 1.2.3
- the second change of 1.2.3

### Fixed

- a fix of 1.2.3

## [1.2.2] - 2026-01-01

### Added

- an older change
CHANGELOG

# Twelve copies of it, each with one defect of form, and the text the form check names it with.
mkdir -p "$fix/broken"
: > "$fix/broken.list"
# broken <name> <text>: the copy on standard input is refused with that text.
broken() {
  cat > "$fix/broken/$1"
  printf '%s|%s\n' "$1" "$2" >> "$fix/broken.list"
}
sed 's/^## \[Unreleased\]$/## Unreleased/' "$changelog" \
  | broken no-unreleased-section 'a section is `## [Unreleased]` or `## [<version>] - <YYYY-MM-DD>`'
sed 's/^## \[1\.2\.3\] - 2026-01-02$/## [1.2.3]/' "$changelog" \
  | broken section-without-date 'a section is `## [Unreleased]` or `## [<version>] - <YYYY-MM-DD>`'
sed 's/^### Fixed$/### Improved/' "$changelog" \
  | broken unknown-heading 'a heading is one of Added, Changed, Deprecated, Removed, Fixed, Security'
sed 's/^- the first change of 1\.2\.3$/- the first change of 1.2.3,\
  continued on a second line/' "$changelog" \
  | broken bullet-on-two-lines 'the line is no heading and starts no bullet'
awk '$0 == "### Added" && !done { done = 1; next } { print }' "$changelog" \
  | broken bullet-under-no-heading 'a bullet stands under none of the six headings'
sed -e 's/^## \[1\.2\.3\] - /## [1.2.9] - /' -e 's/^## \[1\.2\.2\] - /## [1.2.10] - /' "$changelog" \
  | broken oldest-first 'the version 1.2.10 is not below 1.2.9: the newest release stands first'
sed 's/^## \[1\.2\.2\] - /## [1.2.3] - /' "$changelog" \
  | broken version-twice 'the version 1.2.3 has two sections'
sed 's/^## \[1\.2\.3\] - 2026-01-02$/## [1.2.3] - 2026-02-30/' "$changelog" \
  | broken date-of-no-calendar '`2026-02-30` is no date of the calendar'
awk 'NR == 3 { print "- a bullet before the first section" } { print }' "$changelog" \
  | broken bullet-before-the-first-section 'before `## [Unreleased]` stands only the title and its text'
awk 'NR == 3 { print "### Added" } { print }' "$changelog" \
  | broken heading-before-the-first-section 'before `## [Unreleased]` stands only the title and its text'
sed '/^## \[1\.2\.2\] - /q' "$changelog" \
  | broken section-without-change 'the section `## [1.2.2] - 2026-01-01` holds no change'
grep -v '^- a fix of 1\.2\.3$' "$changelog" \
  | broken heading-without-bullet 'the heading `### Fixed` has no bullet'

# form_refuses: the form check refuses each broken copy, and names its defect.
form_refuses() {
  status=0 count=0
  while IFS='|' read -r name text; do
    count=$((count + 1))
    if cmp -s "$changelog" "$fix/broken/$name"; then
      echo "$name: the copy equals the fixture"
      status=1
    elif changelog_form "$fix/broken/$name" > "$work/form" 2>&1; then
      echo "$name: accepted"
      status=1
    elif ! grep -qF -- "$text" "$work/form"; then
      echo "$name: refused, but not with: $text"
      sed 's/^/  /' "$work/form"
      status=1
    fi
  done < "$fix/broken.list"
  [ "$count" = 12 ] || { echo "$count broken changelogs, not 12"; status=1; }
  return "$status"
}

# A changelog whose versions only a comparison of numbers puts in order.
sed -e 's/^## \[1\.2\.3\] - /## [1.10.0] - /' -e 's/^## \[1\.2\.2\] - /## [1.9.9] - /' "$changelog" > "$fix/numbers"

# The changelog after a tag whose run failed (AGENTS.md § "Release", "A tag whose run fails"):
# 1.2.3 was tagged and not released, and 1.2.4 is cut with the correction.
mkdir -p "$fix/tagged"
awk '
  $0 == "## [1.2.3] - 2026-01-02" {
    print "## [1.2.4] - 2026-01-03"
    print ""
    print "### Changed"
    print ""
    print "- `1.2.3` was tagged and not released; this release holds its changes too"
    print ""
    print "### Fixed"
    print ""
    print "- the defect that failed the run of the tag 1.2.3"
    print ""
  }
  { print }' "$changelog" > "$fix/tagged/CHANGELOG.md"
cat > "$fix/tagged/notes-wanted" << 'NOTES'
### Changed

- `1.2.3` was tagged and not released; this release holds its changes too

### Fixed

- the defect that failed the run of the tag 1.2.3
NOTES

group_changelog() {
  if [ -f "$root/CHANGELOG.md" ]; then
    check 'CHANGELOG.md has `## [Unreleased]` in the Keep a Changelog form' pass -- changelog_form "$root/CHANGELOG.md"
  else
    bad "CHANGELOG.md has \`## [Unreleased]\` in the Keep a Changelog form: no CHANGELOG.md"
  fi
  check "the form check passes the changelog of the fixtures" pass -- changelog_form "$changelog"
  check "the form check refuses 12 broken changelogs, each for its defect" pass -- form_refuses
  check "the form check compares versions as numbers: 1.10.0 above 1.9.9 passes" pass -- changelog_form "$fix/numbers"
  check "the form check passes a version cut after a tag that was not released" pass -- changelog_form "$fix/tagged/CHANGELOG.md"
}

# --- AGENTS.md ----------------------------------------------------------------------------

# release_section: the lines of AGENTS.md § "Release", up to the next section.
release_section() {
  awk '
    /^## / { inside = ($0 == "## Release"); next }
    inside { print }' "$root/AGENTS.md"
}

# section_names <text>...: each text is in § "Release".
section_names() {
  release_section > "$work/section"
  [ -s "$work/section" ] || { echo "AGENTS.md has no section \`## Release\`"; return 1; }
  missing=0
  for text in "$@"; do
    grep -qF -- "$text" "$work/section" || { echo "§ Release does not name: $text"; missing=1; }
  done
  return "$missing"
}

group_agents() {
  check 'AGENTS.md has a section "Release" with the steps, the scripts and the changelog rule' pass -- \
    section_names '## [Unreleased]' 'release/<version>' '.github/workflows/release.yml' \
    'release-check.sh' 'release-package.sh' 'release-verify.sh' 'sha256sum -c SHA256SUMS' \
    'release create <version> --verify-tag' "$bot"
  check 'AGENTS.md § "Release" says what happens to a tag whose run fails' pass -- \
    section_names '### A tag whose run fails' 'run rerun <run>' 'never moved or deleted' \
    'no release is created' 'was tagged and not released'
}

# --- release-check.sh ---------------------------------------------------------------------

# manifest <version>: a root manifest with that workspace version and another version beside it.
manifest() {
  mkdir -p "$fix/$1"
  cat > "$fix/$1/Cargo.toml" << MANIFEST
[workspace]
resolver = "3"
members = ["crates/*"]

[workspace.metadata.other]
version = "9.9.8"

[workspace.package]
edition = "2024"
version = "$1"
license = "Apache-2.0"

[workspace.dependencies]
other = { path = "crates/other", version = "9.9.9" }
MANIFEST
}

manifest 1.2.3
manifest 1.2.4
manifest 1.2.5
manifest 1.2.6
manifest 1.2.7
sed 's/^## \[Unreleased\]$/## [1.2.5]/' "$changelog" > "$fix/1.2.5/CHANGELOG.md"
sed 's/^## \[Unreleased\]$/## [1.2.6] - 2 January 2026/' "$changelog" > "$fix/1.2.6/CHANGELOG.md"
grep -v '^version = "1\.2\.7"$' "$fix/1.2.7/Cargo.toml" > "$fix/1.2.7/Cargo.toml.new"
mv "$fix/1.2.7/Cargo.toml.new" "$fix/1.2.7/Cargo.toml"

# Three changelogs whose section of 1.2.3 holds no change: the heading put below its lines,
# headings without a bullet, and bullets under no heading.
awk '
  /^## / { skip = 0 }
  $0 == "## [1.2.3] - 2026-01-02" { print; print ""; skip = 1; next }
  !skip { print }' "$changelog" > "$fix/section-empty"
grep -v ' of 1\.2\.3$' "$changelog" > "$fix/section-of-headings"
awk '
  /^## / { inside = ($0 == "## [1.2.3] - 2026-01-02") }
  inside && /^### / { next }
  { print }' "$changelog" > "$fix/section-of-bullets"

release_check() {
  sh "$scripts/release-check.sh" --manifest "$fix/$1/Cargo.toml" --changelog "$2" "$3"
}

# group_tag: the tag and the workspace version.
group_tag() {
  check "the tag check passes for a tag equal to the workspace version" pass \
    'release-check: tag 1.2.3 equals the workspace version' -- \
    release_check 1.2.3 "$changelog" 1.2.3
  check "the tag check fails for another tag" refuse \
    'release-check: tag 1.2.2 is not the workspace version 1.2.3' \
    'release-check: CHANGELOG.md has the section `## [1.2.2] - 2026-01-01`' -- \
    release_check 1.2.3 "$changelog" 1.2.2
  check "the tag check fails for a tag that is no bare version" refuse \
    'release-check: v1.2.3 is no version of the form <major>.<minor>.<patch>' -- \
    release_check 1.2.3 "$changelog" v1.2.3
  check "the tag check fails for a manifest without a workspace version" refuse \
    'release-check: Cargo.toml has no version in [workspace.package]' -- \
    release_check 1.2.7 "$changelog" 1.2.3
}

# group_section: the section of the tag in the changelog.
group_section() {
  check "the changelog check fails for a tag whose section has a date that is none" refuse \
    'release-check: tag 1.2.3 equals the workspace version' \
    'release-check: date-of-no-calendar: the section `## [1.2.3] - 2026-02-30` names no date of the calendar' -- \
    release_check 1.2.3 "$fix/broken/date-of-no-calendar" 1.2.3
  check "the changelog check fails for a tag whose section holds no line" refuse \
    'release-check: tag 1.2.3 equals the workspace version' \
    'release-check: section-empty: the section `## [1.2.3] - 2026-01-02` holds no change line under a heading' -- \
    release_check 1.2.3 "$fix/section-empty" 1.2.3
  check "the changelog check fails for a tag whose section holds bullets under no heading" refuse \
    'release-check: section-of-bullets: the section `## [1.2.3] - 2026-01-02` holds no change line under a heading' -- \
    release_check 1.2.3 "$fix/section-of-bullets" 1.2.3
  check "the changelog check fails for a tag whose section holds headings and no bullet" refuse \
    'release-check: section-of-headings: the section `## [1.2.3] - 2026-01-02` holds no change line under a heading' -- \
    release_check 1.2.3 "$fix/section-of-headings" 1.2.3
  check "the changelog check fails for a tag whose section has a date of another form" refuse \
    'release-check: tag 1.2.6 equals the workspace version' \
    'release-check: CHANGELOG.md has no section `## [1.2.6] - <YYYY-MM-DD>`' -- \
    release_check 1.2.6 "$fix/1.2.6/CHANGELOG.md" 1.2.6
  check "the changelog check fails for a tag whose section has no date" refuse \
    'release-check: tag 1.2.5 equals the workspace version' \
    'release-check: CHANGELOG.md has no section `## [1.2.5] - <YYYY-MM-DD>`' -- \
    release_check 1.2.5 "$fix/1.2.5/CHANGELOG.md" 1.2.5
  check "the changelog check fails for a tag without a section" refuse \
    'release-check: tag 1.2.4 equals the workspace version' \
    'release-check: CHANGELOG.md has no section `## [1.2.4] - <YYYY-MM-DD>`' -- \
    release_check 1.2.4 "$changelog" 1.2.4
  check "the changelog check passes for a tag with a section that holds a change" pass \
    'release-check: CHANGELOG.md has the section `## [1.2.3] - 2026-01-02`, changes: 3' -- \
    release_check 1.2.3 "$changelog" 1.2.3
  check "release-check.sh passes for a version cut after a tag that was not released" pass \
    'release-check: tag 1.2.4 equals the workspace version' \
    'release-check: CHANGELOG.md has the section `## [1.2.4] - 2026-01-03`, changes: 2' -- \
    release_check 1.2.4 "$fix/tagged/CHANGELOG.md" 1.2.4
}

# --- release-package.sh: the notes --------------------------------------------------------

cat > "$fix/notes-wanted" << 'NOTES'
### Added

- the first change of 1.2.3
- the second change of 1.2.3

### Fixed

- a fix of 1.2.3
NOTES

# notes_equal <version> <changelog> <wanted>: the notes cut for the version are the wanted ones.
notes_equal() {
  sh "$scripts/release-package.sh" notes "$1" "$2" > "$work/notes" || return 1
  cmp "$work/notes" "$3"
}

group_notes() {
  check "the notes cut for a tag equal that section" pass -- notes_equal 1.2.3 "$changelog" "$fix/notes-wanted"
  check "the notes of a tag without a section are refused" refuse \
    'release-package: CHANGELOG.md has no notes for 1.2.4' -- \
    sh "$scripts/release-package.sh" notes 1.2.4 "$changelog"
  check "the notes of a section that holds no line are refused" refuse \
    'release-package: section-empty has no notes for 1.2.3' -- \
    sh "$scripts/release-package.sh" notes 1.2.3 "$fix/section-empty"
  check "the notes of a section that holds headings and no bullet are refused" refuse \
    'release-package: the section of 1.2.3 in section-of-headings holds no change line under a heading' -- \
    sh "$scripts/release-package.sh" notes 1.2.3 "$fix/section-of-headings"
  check "the notes of a section that holds bullets under no heading are refused" refuse \
    'release-package: the section of 1.2.3 in section-of-bullets holds no change line under a heading' -- \
    sh "$scripts/release-package.sh" notes 1.2.3 "$fix/section-of-bullets"
  check "the notes of a version cut after a tag that was not released are its section alone" pass -- \
    notes_equal 1.2.4 "$fix/tagged/CHANGELOG.md" "$fix/tagged/notes-wanted"
}

# --- release-package.sh: the archives and their checksums ---------------------------------

# stub <directory> <text> [<status>]: a `ratchet` that prints the text for `--version` and
# exits with the status, 0 without one. Only its owner may run it: the archive says 755.
stub() {
  mkdir -p "$1"
  cat > "$1/ratchet" << STUB
#!/bin/sh
[ "\${1-}" = --version ] || exit 1
echo "$2"
exit ${3-0}
STUB
  chmod 700 "$1/ratchet"
}

stub "$fix/stub" "ratchet $version"
stub "$fix/stub-other" "ratchet 9.9.9"
stub "$fix/stub-among-text" "ratchet 9.9.9 built for $version"
stub "$fix/stub-bare" "$version"
stub "$fix/stub-failing" "ratchet $version" 3
stub "$fix/stub-error" "error: unexpected argument, this is ratchet $version" 2
targets=$(sh "$scripts/release-package.sh" targets 2> "$fix/targets") || targets=
first_target=${targets%%
*}

# archives: build the archive of each target from the stub, with a umask that leaves a file
# to its owner alone, then compare what each holds: the names, the owner and the modes, the
# bytes of the first, and that nothing else is left beside the archives.
archives() {
  dist=$work/dist
  [ -n "$targets" ] || { echo "release-package.sh targets names no target"; cat "$fix/targets"; return 1; }
  : > "$work/dist-wanted"
  for target in $targets; do
    name=ratchet-$version-$target
    (umask 077 && sh "$scripts/release-package.sh" archive "$version" "$target" "$fix/stub/ratchet" "$dist") || return 1
    [ -f "$dist/$name.tar.gz" ] || { echo "no $dist/$name.tar.gz"; return 1; }
    echo "$name.tar.gz" >> "$work/dist-wanted"
  done
  for target in $targets; do
    name=ratchet-$version-$target
    tar --numeric-owner -tvzf "$dist/$name.tar.gz" | awk '{ print $1, $2, $NF }' | LC_ALL=C sort > "$work/members"
    printf '%s\n' "-rw-r--r-- 0/0 $name/LICENSE" "-rw-r--r-- 0/0 $name/README.md" \
      "-rwxr-xr-x 0/0 $name/ratchet" "drwxr-xr-x 0/0 $name/" > "$work/members-wanted"
    cmp -s "$work/members" "$work/members-wanted" || { echo "$name.tar.gz holds:"; cat "$work/members"; echo "wanted:"; cat "$work/members-wanted"; return 1; }
  done
  ls -A "$dist" | LC_ALL=C sort > "$work/dist-holds"
  LC_ALL=C sort -o "$work/dist-wanted" "$work/dist-wanted"
  cmp -s "$work/dist-holds" "$work/dist-wanted" || { echo "$dist holds:"; cat "$work/dist-holds"; return 1; }
  name=ratchet-$version-$first_target
  rm -rf "$work/unpacked"
  mkdir -p "$work/unpacked"
  tar -xzf "$dist/$name.tar.gz" -C "$work/unpacked" || return 1
  cmp "$work/unpacked/$name/LICENSE" "$root/LICENSE" || return 1
  cmp "$work/unpacked/$name/README.md" "$root/README.md" || return 1
  cmp "$work/unpacked/$name/ratchet" "$fix/stub/ratchet" || return 1
}

# sums: write SHA256SUMS beside the archives. The script verifies it itself, and it names
# each archive once and nothing else.
sums() {
  dist=$work/dist
  sh "$scripts/release-package.sh" sums "$version" "$dist" > "$work/sums" 2>&1 || { cat "$work/sums"; return 1; }
  for target in $targets; do
    grep -qxF "ratchet-$version-$target.tar.gz: OK" "$work/sums" || { echo "release-package.sh sums did not verify ratchet-$version-$target.tar.gz:"; cat "$work/sums"; return 1; }
    lines=$(grep -c "  ratchet-$version-$target\.tar\.gz\$" "$dist/SHA256SUMS")
    [ "$lines" = 1 ] || { echo "SHA256SUMS names ratchet-$version-$target.tar.gz $lines times"; return 1; }
  done
  [ "$(grep -c . "$dist/SHA256SUMS")" = "$(printf '%s\n' "$targets" | grep -c .)" ] || { echo "SHA256SUMS has other lines"; cat "$dist/SHA256SUMS"; return 1; }
  (cd "$dist" && sha256sum -c SHA256SUMS)
}

# refused_archive <stub>: the archive of the first target from that stub binary.
refused_archive() {
  sh "$scripts/release-package.sh" archive "$version" "${first_target:-none}" "$fix/$1/ratchet" "$work/dist-other"
}

# group_binary: what `archive` asks of the binary before it packs it.
group_binary() {
  check "an archive of a binary that prints the version and exits 3 is refused" refuse \
    'release-package: `ratchet --version` exits 3' -- \
    refused_archive stub-failing
  check "an archive of a binary that prints the version among other text is refused" refuse \
    'release-package: the binary prints "ratchet 9.9.9 built for 1.2.3", not "ratchet 1.2.3"' -- \
    refused_archive stub-among-text
  check "an archive of a binary that prints another version is refused" refuse \
    'release-package: the binary prints "ratchet 9.9.9", not "ratchet 1.2.3"' -- \
    refused_archive stub-other
  check "an archive of a binary that prints the version without its name is refused" refuse \
    'release-package: the binary prints "1.2.3", not "ratchet 1.2.3"' -- \
    refused_archive stub-bare
  check "an archive of a binary that ends an error line with the version and exits 2 is refused" refuse \
    'release-package: `ratchet --version` exits 2' -- \
    refused_archive stub-error
}

# group_package: the archives, their checksums and the calls `release-package.sh` refuses.
group_package() {
  check "a version with a leading v is refused" refuse \
    'release-package: v1.2.3 is no version of the form <major>.<minor>.<patch>' -- \
    sh "$scripts/release-package.sh" assets v1.2.3
  check "a version that is no bare version is refused" refuse \
    'release-package: 1.2 is no version of the form <major>.<minor>.<patch>' -- \
    sh "$scripts/release-package.sh" assets 1.2
  check "the archive built from a stub binary holds ratchet, LICENSE and README.md with owner 0 and the modes 755 and 644" pass -- archives
  check "the archive verifies against the SHA256SUMS written beside it" pass -- sums
  check "an archive for a target no release is built for is refused" refuse \
    'release-package: x86_64-apple-darwin is no target of a release' -- \
    sh "$scripts/release-package.sh" archive "$version" x86_64-apple-darwin "$fix/stub/ratchet" "$work/dist-other"
  check "an archive of a file that is no executable is refused" refuse \
    'release-package: ' ' is no executable file' -- \
    sh "$scripts/release-package.sh" archive "$version" "${first_target:-none}" "$fix/notes-wanted" "$work/dist-other"
  mkdir -p "$work/dist-short"
  [ -n "$first_target" ] && cp "$work/dist/ratchet-$version-$first_target.tar.gz" "$work/dist-short/" 2> /dev/null
  check "checksums of a directory that lacks an archive are refused" refuse \
    'release-package: no ratchet-1.2.3-' -- \
    sh "$scripts/release-package.sh" sums "$version" "$work/dist-short"
}

# --- release-verify.sh --------------------------------------------------------------------

assets=$(sh "$scripts/release-package.sh" assets "$version" 2> /dev/null) || assets=

# The description of a release as `gh release view <version> --json
# assets,author,isDraft,isPrerelease,tagName` prints it: the bot as author, published, the
# three assets uploaded.
# shellcheck disable=SC2086
printf '%s\n' $assets | jq -R . | jq -s --arg login "$bot" --arg tag "$version" '{
  assets: map({name: ., state: "uploaded", contentType: "application/octet-stream", label: ""}),
  author: {id: "BOT_0000000000", login: $login},
  isDraft: false,
  isPrerelease: false,
  tagName: $tag
}' > "$fix/description.json"

# release <name> [<jq filter>]: a directory with the description of the release, changed by
# the filter, and a copy of its assets. The assets are those the group of the archives wrote
# with the scripts of the repository.
release() {
  mkdir -p "$work/release/$1/assets"
  # shellcheck disable=SC2086
  (cd "$good" && cp $assets "$work/release/$1/assets/") 2> /dev/null
  if [ $# = 2 ]; then
    jq "$2" "$fix/description.json" > "$work/release/$1/description.json"
  else
    cp "$fix/description.json" "$work/release/$1/description.json"
  fi
}

# verify <name>: release-verify.sh on that directory. Its files go to an own directory, which
# a run leaves empty.
verify() {
  [ -d "$work/tmp" ] || mkdir -p "$work/tmp"
  TMPDIR=$work/tmp sh "$scripts/release-verify.sh" "$version" \
    --description "$work/release/$1/description.json" --assets "$work/release/$1/assets"
}

# nothing_left: no run of the group left a file in that directory.
nothing_left() {
  [ -d "$work/tmp" ] || { echo "no run wrote under $work/tmp"; return 1; }
  [ -z "$(ls -A "$work/tmp")" ] || { echo "left behind:"; ls -A "$work/tmp"; return 1; }
}

# quiet: no run of the group left a file there, and none called gh.
quiet() {
  nothing_left || return 1
  [ ! -s "$GH_CALLS" ] || { echo "gh was called:"; cat "$GH_CALLS"; return 1; }
}

# unpack <archive name>: that archive of the good release as a directory the caller changes.
unpack() {
  rm -rf "$work/repack"
  mkdir -p "$work/repack"
  tar -xzf "$good/$1.tar.gz" -C "$work/repack" 2> /dev/null
}

# repack <release> <archive name> [<member>...]: that directory as the archive of the
# release, with the members after its own, and with checksums that match it.
repack() {
  to=$work/release/$1/assets archive=$2
  shift 2
  tar -P -czf "$to/$archive.tar.gz" -C "$work/repack" "$archive" "$@" 2> /dev/null \
    && (cd "$to" && sha256sum ratchet-*.tar.gz > SHA256SUMS)
}

# not_run: the program outside the archives, the target of the link, was never started.
not_run() {
  verify link
  status=$?
  if [ -f "$work/outside/ran" ]; then
    echo "release-verify.sh ran the target of the link, a file in no archive"
    return 0
  fi
  return "$status"
}

# group_verify_state: the description of the release: its tag, its state and its author.
group_verify_state() {
  release good
  check "release-verify.sh passes for a description with the bot as author beside its three assets" pass \
    'release-verify: the release 1.2.3 is published' \
    "release-verify: its author is $bot" \
    'release-verify: its 3 assets are attached' \
    'release-verify: sha256sum -c SHA256SUMS passes' \
    'release-verify: each archive holds ratchet, LICENSE and README.md' \
    'release-verify: the ratchet of the x86_64 archive prints "ratchet 1.2.3" and exits 0' -- \
    verify good
  check "release-verify.sh with --description and --assets leaves no file behind and calls no gh" pass -- quiet

  release prerelease '.isPrerelease = true'
  check "release-verify.sh fails for a prerelease" refuse \
    'release-verify: the release 1.2.3 is a prerelease' -- \
    verify prerelease

  release unsaid 'del(.isPrerelease)'
  check "release-verify.sh fails for a description that does not say whether it is a prerelease" refuse \
    'release-verify: the description does not say whether the release 1.2.3 is a prerelease' -- \
    verify unsaid

  release draft '.isDraft = true'
  check "release-verify.sh fails for a draft" refuse \
    'release-verify: the release 1.2.3 is a draft' -- \
    verify draft

  release undecided 'del(.isDraft)'
  check "release-verify.sh fails for a description that does not say whether it is a draft" refuse \
    'release-verify: the description does not say whether the release 1.2.3 is a draft' -- \
    verify undecided

  release author '.author.login = "b10x-bot"'
  check "release-verify.sh fails for another author" refuse \
    "release-verify: the author of the release is b10x-bot, not $bot" -- \
    verify author

  release other '.tagName = "1.2.2"'
  check "release-verify.sh fails for the description of another release" refuse \
    'release-verify: the description is of the release 1.2.2, not 1.2.3' -- \
    verify other

  release text
  echo "release not found" > "$work/release/text/description.json"
  check "release-verify.sh fails for a description that is no JSON object" refuse \
    'release-verify: the description ' ' is no JSON object' -- \
    verify text
  check "release-verify.sh leaves no file behind and calls no gh when it fails at the description" pass -- quiet
}

# group_verify_assets: which assets the release carries, and that each is in the directory.
group_verify_assets() {
  release fourth '.assets += [.assets[0] | .name = "ratchet-1.2.3-x86_64-pc-windows-msvc.zip"]'
  echo "not of the release" > "$work/release/fourth/assets/ratchet-1.2.3-x86_64-pc-windows-msvc.zip"
  check "release-verify.sh fails for a release with a fourth asset" refuse \
    'release-verify: the release carries an asset that is none of its 3: ratchet-1.2.3-x86_64-pc-windows-msvc.zip' -- \
    verify fourth

  release uploading '.assets[0].state = "open"'
  check "release-verify.sh fails for an asset that is not uploaded" refuse \
    'release-verify: the asset ratchet-1.2.3-x86_64-unknown-linux-gnu.tar.gz is not attached' -- \
    verify uploading

  release unattached 'del(.assets[1])'
  check "release-verify.sh fails for an asset that is not attached" refuse \
    'release-verify: the asset ratchet-1.2.3-aarch64-unknown-linux-gnu.tar.gz is not attached' -- \
    verify unattached

  release absent
  rm -f "$work/release/absent/assets/SHA256SUMS"
  check "release-verify.sh fails for an asset that is not in the directory" refuse \
    'release-verify: the asset SHA256SUMS is not in ' -- \
    verify absent
  check "release-verify.sh leaves no file behind and calls no gh when it fails at the assets" pass -- quiet
}

# group_verify_sums: the checksums of the archives.
group_verify_sums() {
  release twice
  (cd "$work/release/twice/assets" && sha256sum "$x86_64.tar.gz" >> SHA256SUMS) 2> /dev/null
  check "release-verify.sh fails for a SHA256SUMS that names an archive twice" refuse \
    'release-verify: SHA256SUMS does not name ratchet-1.2.3-x86_64-unknown-linux-gnu.tar.gz once' -- \
    verify twice

  release unnamed
  (cd "$work/release/unnamed/assets" && sha256sum "$x86_64.tar.gz" > SHA256SUMS) 2> /dev/null
  check "release-verify.sh fails for a SHA256SUMS that does not name an archive" refuse \
    'release-verify: SHA256SUMS does not name ratchet-1.2.3-aarch64-unknown-linux-gnu.tar.gz once' -- \
    verify unnamed

  release changed
  printf 'x' >> "$work/release/changed/assets/$x86_64.tar.gz"
  check "release-verify.sh fails for a changed archive" refuse \
    'release-verify: sha256sum -c SHA256SUMS fails' -- \
    verify changed
  check "release-verify.sh leaves no file behind and calls no gh when it fails at the checksums" pass -- quiet
}

# group_verify_members: what each archive holds.
group_verify_members() {
  # A `ratchet` that is a link to a program in no archive. The program prints the version, so
  # only the kind of the member tells the archive from a good one, and it records that it ran.
  release link
  mkdir -p "$work/outside"
  rm -f "$work/outside/ran"
  cat > "$work/outside/ratchet" << OUTSIDE
#!/bin/sh
echo ran >> "$work/outside/ran"
echo "ratchet $version"
OUTSIDE
  chmod +x "$work/outside/ratchet"
  unpack "$x86_64" && rm "$work/repack/$x86_64/ratchet" \
    && ln -s "$work/outside/ratchet" "$work/repack/$x86_64/ratchet" && repack link "$x86_64"
  check "release-verify.sh fails for an archive whose ratchet is a link, and does not run its target" refuse \
    'release-verify: sha256sum -c SHA256SUMS passes' \
    'release-verify: ratchet-1.2.3-x86_64-unknown-linux-gnu.tar.gz holds a member that is no regular file' -- \
    not_run

  release second
  unpack "$aarch64" && echo "not of the release" > "$work/repack/$aarch64/NOTICE" && repack second "$aarch64"
  check "release-verify.sh fails for another file in the archive it does not run" refuse \
    'release-verify: ratchet-1.2.3-aarch64-unknown-linux-gnu.tar.gz does not hold ratchet, LICENSE and README.md' -- \
    verify second

  release extra
  unpack "$x86_64" && echo "not of the release" > "$work/repack/$x86_64/NOTICE" && repack extra "$x86_64"
  check "release-verify.sh fails for an archive that holds another file" refuse \
    'release-verify: sha256sum -c SHA256SUMS passes' \
    'release-verify: ratchet-1.2.3-x86_64-unknown-linux-gnu.tar.gz does not hold ratchet, LICENSE and README.md' -- \
    verify extra

  release outside
  unpack "$x86_64" && echo "not of the release" > "$work/repack/beside" && repack outside "$x86_64" "../repack/beside"
  check "release-verify.sh fails for an archive with a path outside its directory" refuse \
    'release-verify: ratchet-1.2.3-x86_64-unknown-linux-gnu.tar.gz does not hold ratchet, LICENSE and README.md' -- \
    verify outside

  release directory
  unpack "$x86_64" && rm "$work/repack/$x86_64/LICENSE" && mkdir "$work/repack/$x86_64/LICENSE" && repack directory "$x86_64"
  check "release-verify.sh fails for an archive whose LICENSE is a directory" refuse \
    'release-verify: ratchet-1.2.3-x86_64-unknown-linux-gnu.tar.gz does not hold ratchet, LICENSE and README.md' -- \
    verify directory
  check "release-verify.sh leaves no file behind and calls no gh when it fails at a member" pass -- quiet
}

# group_verify_binary: what the binary of the x86_64 archive prints.
group_verify_binary() {
  release failing
  unpack "$x86_64" && cp "$fix/stub-failing/ratchet" "$work/repack/$x86_64/ratchet" && repack failing "$x86_64"
  check "release-verify.sh fails for a binary that prints the version and exits 3" refuse \
    'release-verify: `ratchet --version` of the x86_64 archive exits 3' -- \
    verify failing

  release among
  unpack "$x86_64" && cp "$fix/stub-among-text/ratchet" "$work/repack/$x86_64/ratchet" && repack among "$x86_64"
  check "release-verify.sh fails for a binary that prints the version among other text" refuse \
    'release-verify: the ratchet of the x86_64 archive prints "ratchet 9.9.9 built for 1.2.3", not "ratchet 1.2.3"' -- \
    verify among

  release binary
  unpack "$x86_64" && cp "$fix/stub-other/ratchet" "$work/repack/$x86_64/ratchet" && repack binary "$x86_64"
  check "release-verify.sh fails for a binary that prints another version" refuse \
    'release-verify: sha256sum -c SHA256SUMS passes' \
    'release-verify: the ratchet of the x86_64 archive prints "ratchet 9.9.9", not "ratchet 1.2.3"' -- \
    verify binary

  check "release-verify.sh leaves no file behind and calls no gh when it fails at the binary" pass -- quiet
}

# through_gh [<argument>...]: release-verify.sh without the two options, so that it reads the
# release through the stand-in.
through_gh() {
  [ -d "$work/tmp" ] || mkdir -p "$work/tmp"
  TMPDIR=$work/tmp sh "$scripts/release-verify.sh" "$version" "$@"
}

# gh_reads: the stand-in serves the good release, and was asked twice: for the description
# with the repository of Cargo.toml, then for the three assets by name.
gh_reads() {
  : > "$GH_CALLS"
  GH_RELEASE=$work/release/good through_gh || return 1
  [ "$(grep -c . "$GH_CALLS")" = 2 ] || { echo "gh was not called twice:"; cat "$GH_CALLS"; return 1; }
  sed -n 1p "$GH_CALLS" | grep -q "^release view $version " || { echo "the first call is no gh release view $version:"; cat "$GH_CALLS"; return 1; }
  sed -n 2p "$GH_CALLS" | grep -q "^release download $version " || { echo "the second call is no gh release download $version:"; cat "$GH_CALLS"; return 1; }
  [ "$(grep -c -- " --repo $repository " "$GH_CALLS")" = 2 ] || { echo "a call without --repo $repository:"; cat "$GH_CALLS"; return 1; }
  for asset in $assets; do
    sed -n 2p "$GH_CALLS" | grep -qE -- " --pattern $asset( |\$)" || { echo "the download does not name $asset:"; cat "$GH_CALLS"; return 1; }
  done
}

# gh_reads_another: `--repository` names the repository the release is read from.
gh_reads_another() {
  : > "$GH_CALLS"
  GH_RELEASE=$work/release/good GH_REPOSITORY=beyond10x/another through_gh --repository beyond10x/another || return 1
  [ "$(grep -c -- " --repo beyond10x/another " "$GH_CALLS")" = 2 ] || { echo "a call without --repo beyond10x/another:"; cat "$GH_CALLS"; return 1; }
}

# gh_downloads_nothing: the description is served, the download fails.
gh_downloads_nothing() {
  GH_RELEASE=$work/release/good GH_NO_DOWNLOAD=1 through_gh
}

# gh_not_published: the release gh serves is a prerelease.
gh_not_published() {
  GH_RELEASE=$work/release/prerelease through_gh
}

# stand_in_refuses: the stand-in answers none of these calls, each a call release-verify.sh
# must not make, and prints the arguments of each on standard error.
stand_in_refuses() {
  status=0
  while IFS= read -r call; do
    [ -n "$call" ] || continue
    # shellcheck disable=SC2086
    if GH_RELEASE=$work/release/good gh $call > "$work/stand-in" 2> "$work/stand-in-error"; then
      echo "answered: gh $call"
      status=1
    elif ! grep -qF -- "gh $call" "$work/stand-in-error"; then
      echo "refused without its arguments on standard error: gh $call"
      status=1
    fi
  done << CALLS
release view $version --json assets,author,isDraft,isPrerelease,tagName
release view $version --repo $repository
release view $version --repo beyond10x/another --json assets,author,isDraft,isPrerelease,tagName
release view $version --repo $repository --json assets --web
release download $version --dir $work/stand-in-assets --pattern SHA256SUMS
release download $version --repo $repository --dir $work/stand-in-assets
release download $version --repo $repository --pattern SHA256SUMS
release delete $version --repo $repository
release create $version --repo $repository
api repos/$repository/releases
CALLS
  return "$status"
}

# stand_in_answers: it prints the fields it is asked for and no other, and copies the assets
# a pattern names and no other.
stand_in_answers() {
  fields=$(GH_RELEASE=$work/release/good gh release view "$version" --repo "$repository" --json assets,author | jq -c 'keys') || return 1
  [ "$fields" = '["assets","author"]' ] || { echo "asked for assets,author, the stand-in printed $fields"; return 1; }
  rm -rf "$work/stand-in-assets"
  GH_RELEASE=$work/release/good gh release download "$version" --repo "$repository" \
    --dir "$work/stand-in-assets" --pattern SHA256SUMS || return 1
  [ "$(ls -A "$work/stand-in-assets")" = SHA256SUMS ] || { echo "asked for SHA256SUMS, the stand-in copied:"; ls -A "$work/stand-in-assets"; return 1; }
}

group_stand_in() {
  release good
  check "the stand-in for gh answers with the fields and the assets it is asked for" pass -- stand_in_answers
  check "the stand-in for gh refuses a call without --repo, --json or a pattern, and every other call" pass -- stand_in_refuses
}

group_gh() {
  release good
  release prerelease '.isPrerelease = true'
  check "release-verify.sh without them reads the release with gh release view and gh release download" pass \
    "release-verify: its author is $bot" \
    'release-verify: the ratchet of the x86_64 archive prints "ratchet 1.2.3" and exits 0' -- \
    gh_reads
  check "release-verify.sh --repository reads the release of that repository" pass \
    "release-verify: its author is $bot" -- \
    gh_reads_another
  : > "$GH_CALLS"
  check "release-verify.sh fails while gh finds no release" refuse \
    'release-verify: gh release view 1.2.3 found no release in beyond10x/ratchet' -- \
    through_gh
  check "release-verify.sh fails when gh release download fails" refuse \
    "release-verify: its author is $bot" \
    'release-verify: gh release download 1.2.3 failed' -- \
    gh_downloads_nothing
  check "release-verify.sh fails for a prerelease that gh serves" refuse \
    'release-verify: the release 1.2.3 is a prerelease' -- \
    gh_not_published
  check "release-verify.sh leaves no file behind after a run through gh" pass -- nothing_left
}

# --- .github/workflows/release.yml --------------------------------------------------------

# facts: the workflow as one line per fact, `<job>|<kind>|<text>`, read by the indentation of
# the file as it is written (two blanks a level). `-` stands for no job.
#
#   -|top|<line>            a top-level key
#   -|on|<line>             a line below `on:`, with its indentation
#   -|permissions|<line>    a line below the top-level `permissions:`, with its indentation
#   <job>|job|              the job
#   <job>|key|<line>        a key of the job with its value
#   <job>|permissions|…     a line below the `permissions:` of the job
#   <job>|strategy|…        a line below `strategy:` that is no pair of the matrix
#   <job>|matrix|<target> <runner>
#   <job>|uses|<action>@<commit>
#   <job>|with|<action>|<line>    an input of the step that uses the action
#   <job>|env|<line>        a variable of a step
#   <job>|block|<line>      the first line of a `run: |` block
#   <job>|run|<line>        a command line: of a block, or the value of a `run:` on one line
#   <job>|stepkey|<line>    a key of a step other than name, id, uses, with, env and run
#   <job>|other|<line>      a line that is none of these
facts() {
  [ -f "$workflow" ] || { echo "no .github/workflows/release.yml"; return 1; }
  awk '
    /^ *$/ { next }
    {
      depth = match($0, /[^ ]/) - 1
      line = substr($0, depth + 1)
      if (running && depth > 8) {
        if (!started) { print job "|block|" line; started = 1 }
        print job "|run|" line
        next
      }
      running = 0
      if (depth == 0) {
        top = line
        sub(/:.*$/, "", top)
        job = "-"
        print "-|top|" line
        next
      }
      if (top == "on" || top == "permissions") { print "-|" top "|" $0; next }
      if (top != "jobs") { print "-|other|" $0; next }
      if (depth == 2) {
        job = line
        sub(/:$/, "", job)
        part = ""
        print job "|job|"
        next
      }
      if (depth == 4) {
        part = line
        sub(/:.*$/, "", part)
        if (line != "permissions:" && line != "strategy:" && line != "steps:") { print job "|key|" line; part = "" }
        next
      }
      if (part == "permissions") { print job "|permissions|" line; next }
      if (part == "strategy") {
        if (line ~ /^- target: /) { target = substr(line, 11); next }
        if (line ~ /^runner: / && target != "") { print job "|matrix|" target " " substr(line, 9); target = ""; next }
        print job "|strategy|" line
        next
      }
      if (part == "steps") {
        if (depth == 6 && line ~ /^- /) {
          depth = 8
          line = substr(line, 3)
          uses = ""
          under = ""
        }
        if (depth == 8) {
          key = line
          sub(/:.*$/, "", key)
          value = line
          sub(/^[^:]*: */, "", value)
          under = ""
          if (key == "name" || key == "id") next
          if (key == "uses") { uses = value; sub(/@.*$/, "", uses); print job "|uses|" value; next }
          if ((key == "with" || key == "env") && value == "") { under = key; next }
          if (key == "run") {
            if (value ~ /^[|>]/) { running = 1; started = 0 } else print job "|run|" value
            next
          }
          print job "|stepkey|" line
          next
        }
        if (depth == 10 && under == "with") { print job "|with|" uses "|" line; next }
        if (depth == 10 && under == "env") { print job "|env|" line; next }
      }
      print job "|other|" $0
    }' "$workflow" > "$work/facts"
}

# of <job> <kind>: the texts of the facts of that kind.
of() {
  awk -v start="$1|$2|" 'index($0, start) == 1 { print substr($0, length(start) + 1) }' "$work/facts"
}

# with <job> <action>: the inputs of the step of the job that uses the action.
with() {
  of "$1" with | awk -v start="$2|" 'index($0, start) == 1 { print substr($0, length(start) + 1) }'
}

# sequence <job>: its actions, without their commits, and the first lines of its blocks, in
# the order of the steps.
sequence() {
  awk -F'|' -v job="$1" '$1 == job && ($2 == "uses" || $2 == "block") { sub(/@.*$/, "", $3); print $2, $3 }' "$work/facts"
}

# workflow_trigger: a bare version tag starts it and nothing else does; it may read the
# repository, holds no other permission, reads no token and publishes nothing.
workflow_trigger() {
  facts || return 1
  same "the top-level keys" "name: Release
on:
permissions:
jobs:" "$(of - top)" || return 1
  same "the trigger" "  push:
    tags: ['[0-9]+.[0-9]+.[0-9]+']" "$(of - on)" || return 1
  same "the top-level permissions" "  contents: read" "$(of - permissions)" || return 1
  for job in $(awk -F'|' '$2 == "job" { print $1 }' "$work/facts"); do
    same "the permissions of the job $job" "contents: read" "$(of "$job" permissions)" || return 1
  done
  if grep -n -e 'permissions: ' -e ': write' -e 'write-all' "$workflow"; then echo "a permission other than contents: read"; return 1; fi
  if grep -n -e 'secrets' -e 'GITHUB_TOKEN' -e 'github\.token' "$workflow"; then echo "the workflow reads a token"; return 1; fi
  if grep -n -e 'release create' -e 'gh release' -e 'git push' -e 'git tag' -e 'api\.github\.com' "$workflow"; then echo "the workflow publishes"; return 1; fi
  if grep -F '|other|' "$work/facts"; then echo "lines that are in no job, step or block the test knows"; return 1; fi
}

# workflow_jobs: Gate, then Package on the runner of each target, then Bundle. Every step of
# every job runs, and no command may fail without failing its job.
workflow_jobs() {
  facts || return 1
  same "the jobs" "gate package bundle" "$(awk -F'|' '$2 == "job" { printf "%s%s", sep, $1; sep = " " }' "$work/facts")" || return 1
  same "the job gate: what it needs and where it runs" "runs-on: ubuntu-latest" \
    "$(of gate key | grep -v -e '^name: ' -e '^timeout-minutes: ')" || return 1
  same "the job package: what it needs and where it runs" "needs: gate
runs-on: \${{ matrix.runner }}" \
    "$(of package key | grep -v -e '^name: ' -e '^timeout-minutes: ')" || return 1
  same "the job bundle: what it needs and where it runs" "needs: package
runs-on: ubuntu-latest" \
    "$(of bundle key | grep -v -e '^name: ' -e '^timeout-minutes: ')" || return 1
  [ -n "$targets" ] || { echo "release-package.sh targets names no target"; return 1; }
  matrix=
  for target in $targets; do
    case $target in
      x86_64-*) runner=ubuntu-22.04 ;;
      aarch64-*) runner=ubuntu-22.04-arm ;;
      *) echo "the test knows no runner for the target $target"; return 1 ;;
    esac
    matrix="$matrix$target $runner
"
  done
  same "the matrix of the job package: each target of release-package.sh on the runner of its architecture" \
    "${matrix%?}" "$(of package matrix)" || return 1
  same "the strategy of the job package" "fail-fast: false
matrix:
include:" "$(of package strategy)" || return 1
  if grep -F '|stepkey|' "$work/facts"; then echo "a step has a key other than name, id, uses, with, env and run"; return 1; fi
  if grep -n -e 'continue-on-error' -e '^ *if:' "$workflow"; then echo "a job or a step that may be skipped or may fail"; return 1; fi
  if awk -F'|' '$2 == "block"' "$work/facts" | grep -vxF -e 'gate|block|set -euo pipefail' -e 'package|block|set -euo pipefail' -e 'bundle|block|set -euo pipefail'; then
    echo "a block that does not start with set -euo pipefail"
    return 1
  fi
  if awk -F'|' '$2 == "run"' "$work/facts" | grep -e '||' -e 'set +e' -e '; *true'; then echo "a command whose failure is discarded"; return 1; fi
  for job in gate package bundle; do
    checkouts=$(of "$job" uses | grep -c '^actions/checkout@')
    unpersisted=$(with "$job" actions/checkout | grep -cxF 'persist-credentials: false')
    [ "$checkouts" = 1 ] && [ "$unpersisted" = 1 ] || { echo "the job $job: $checkouts checkouts, $unpersisted with persist-credentials: false; wanted 1 and 1"; return 1; }
  done
  same "the steps of the job package" "uses actions/checkout
block set -euo pipefail
uses dtolnay/rust-toolchain
block set -euo pipefail
uses actions/upload-artifact" "$(sequence package)" || return 1
  same "the steps of the job bundle" "uses actions/checkout
uses actions/download-artifact
block set -euo pipefail
uses actions/upload-artifact" "$(sequence bundle)" || return 1
}

# workflow_calls: the commands are those of the scripts, and what one job writes is what the
# next reads: the directory of the archives, the names of the artifacts, the paths.
workflow_calls() {
  facts || return 1
  of gate run > "$work/runs"
  [ "$(sed -n 1p "$work/runs")" = 'sh .github/scripts/release-check.sh "$GITHUB_REF_NAME"' ] \
    || { echo "the first command of the job gate is not release-check.sh on the tag:"; sed -n 1p "$work/runs"; return 1; }
  [ "$(tail -n 1 "$work/runs")" = 'task check' ] \
    || { echo "the last command of the job gate is not task check:"; tail -n 1 "$work/runs"; return 1; }
  if awk -F'|' '$2 == "run"' "$work/facts" | grep -E '(^|[;&|( ])cargo ' | grep -Ev -- ' --locked( |$)'; then echo "a cargo call without --locked"; return 1; fi

  of package run > "$work/runs"
  build='cargo build --locked --release --bin ratchet --target "$TARGET"'
  archive='sh .github/scripts/release-package.sh archive "$GITHUB_REF_NAME" "$TARGET" "target/$TARGET/release/ratchet" '
  same "the cargo calls of the job package" "$build" "$(grep -E '(^|[;&|( ])cargo ' "$work/runs")" || return 1
  same "the variables of the job package" 'TARGET: ${{ matrix.target }}' "$(of package env)" || return 1
  line=$(grep -F -- 'release-package.sh' "$work/runs")
  dir=${line#"$archive"}
  case $dir in
    '' | *[!a-z]*) echo "the job package does not write the archive of the built binary into one directory:"; echo "$line"; return 1 ;;
  esac
  same "the commands of the job package, the build first" "$build
$archive$dir" "$(grep -xF -e "$build" -e "$archive$dir" "$work/runs")" || return 1
  same "what the job package uploads" "name: release-\${{ matrix.target }}
path: $dir/*.tar.gz
if-no-files-found: error" "$(with package actions/upload-artifact)" || return 1

  same "what the job bundle downloads: every artifact of the job package, into the directory of the archives" "pattern: release-*
path: $dir
merge-multiple: true" "$(with bundle actions/download-artifact)" || return 1
  same "the commands of the job bundle" "set -euo pipefail
sh .github/scripts/release-package.sh sums \"\$GITHUB_REF_NAME\" $dir
sh .github/scripts/release-package.sh notes \"\$GITHUB_REF_NAME\" CHANGELOG.md > $dir/notes.md
cat $dir/notes.md" "$(of bundle run)" || return 1
  same "what the job bundle uploads" "name: ratchet-\${{ github.ref_name }}-release
path: $dir/*
if-no-files-found: error" "$(with bundle actions/upload-artifact)" || return 1
}

# pins <workflow>: the versions and checksums of the tools it installs.
pins() {
  grep -E '^ *([A-Z_]+_(VERSION|SHA256)|version|node-version): ' "$1" | sed 's/^ *//' | LC_ALL=C sort -u
}

# step <workflow> <name>: the first step of that name, without an `if:`.
step() {
  awk -v name="      - name: $2" '
    $0 == name { inside = 1; print; next }
    !inside { next }
    /^ *$/ { print; next }
    match($0, /[^ ]/) && RSTART <= 7 { exit }
    /^        if: / { next }
    { print }' "$1"
}

# installs <workflow>: the names of its steps that install a tool or read the compiler.
installs() {
  sed -n -e 's/^      - name: \(Install .*\)$/\1/p' -e 's/^      - name: \(.*rustc.*\)$/\1/p' "$1" | LC_ALL=C sort -u
}

# workflow_pins: the gate of the tag runs with the tools of the gate of a pull request. Each
# step that installs one equals the step of that name in pages.yml, less its `if:`, so a new
# version or digest in one file alone is a difference. Every action is pinned by a commit,
# the same commit where pages.yml uses the action too.
workflow_pins() {
  [ -f "$workflow" ] || { echo "no .github/workflows/release.yml"; return 1; }
  installs "$pages" > "$work/installs-pages"
  installs "$workflow" > "$work/installs-release"
  [ -s "$work/installs-pages" ] || { echo "pages.yml installs no tool"; return 1; }
  cmp -s "$work/installs-pages" "$work/installs-release" || { echo "release.yml installs:"; cat "$work/installs-release"; echo "pages.yml installs:"; cat "$work/installs-pages"; return 1; }
  while IFS= read -r name; do
    step "$pages" "$name" > "$work/step-pages"
    step "$workflow" "$name" > "$work/step-release"
    [ -s "$work/step-pages" ] || { echo "pages.yml has no step: $name"; return 1; }
    cmp -s "$work/step-pages" "$work/step-release" || { echo "the step \`$name\` of release.yml is not that of pages.yml:"; diff "$work/step-pages" "$work/step-release"; return 1; }
  done < "$work/installs-pages"
  pins "$pages" > "$work/pins-pages"
  pins "$workflow" > "$work/pins-release"
  [ -s "$work/pins-pages" ] || { echo "pages.yml pins no tool"; return 1; }
  cmp -s "$work/pins-pages" "$work/pins-release" || { echo "release.yml pins:"; cat "$work/pins-release"; echo "pages.yml pins:"; cat "$work/pins-pages"; return 1; }
  sed -n 's/^ *-* *uses: *//p' "$workflow" | LC_ALL=C sort -u > "$work/uses"
  [ -s "$work/uses" ] || { echo "release.yml uses no action"; return 1; }
  while IFS= read -r action; do
    printf '%s\n' "$action" | grep -Eq '^[^@ ]+@[0-9a-f]{40}$' || { echo "not pinned by a commit: $action"; return 1; }
    other=$(sed -n 's/^ *-* *uses: *//p' "$pages" | grep -F -- "${action%@*}@" | LC_ALL=C sort -u)
    [ -z "$other" ] || [ "$other" = "$action" ] || { echo "release.yml uses $action, pages.yml $other"; return 1; }
  done < "$work/uses"
}

# One group per case of the workflow: a mutant of the workflow names the case that refuses it.
group_trigger() {
  check "release.yml runs on a bare version tag alone, with contents: read, no token, and publishes nothing" pass -- workflow_trigger
}
group_jobs() {
  check "release.yml: Gate, then Package on the runner of each target, then Bundle; every step runs and no failure is discarded" pass -- workflow_jobs
}
group_calls() {
  check "release.yml runs release-check.sh, the gate and release-package.sh, and each job reads what the one before wrote" pass -- workflow_calls
}
group_pins() {
  check "release.yml installs the tools of the gate by the steps of pages.yml and pins every action by a commit" pass -- workflow_pins
}

# --- the cases on the files of the repository ---------------------------------------------

# alone <directory> <group>: the cases of the group, in that directory, made new. A group
# reads the fixtures, the archives of group_package and what it writes itself, and nothing
# another group wrote: so it passes or fails the same way wherever it runs.
alone() {
  work=$1
  rm -rf "$work"
  mkdir -p "$work"
  GH_CALLS=$work/gh-calls
  "$2"
}

# The archives and the checksums the verify groups copy: those group_package writes below.
good=$top/work/group_package/dist

for group in group_changelog group_agents group_tag group_section group_notes group_binary \
  group_package group_verify_state group_verify_assets group_verify_sums group_verify_members \
  group_verify_binary group_stand_in group_gh group_trigger group_jobs group_calls group_pins; do
  alone "$top/work/$group" "$group"
done

# --- mutants ------------------------------------------------------------------------------

# The tree a mutant is in: the root of the repository with a copy of `.github/scripts` and
# `.github/workflows` and a link to everything else, so a script finds beside the copy what
# it finds beside the original. One file of the copy differs from the repository at a time.
tree=$top/mutant
mkdir -p "$tree/.github"
cp -R "$root/.github/scripts" "$root/.github/workflows" "$tree/.github/" 2> /dev/null
for entry in "$root"/* "$root"/.[!.]*; do
  case ${entry##*/} in
    .github | '*' | '.[!.]*') ;;
    *) ln -s "$entry" "$tree/" ;;
  esac
done

# on_copy <id> <group>: the cases of the group on the copy, alone like the run above, with the
# fixtures and the archives of the repository. It ends at the first case that fails; the case
# and what it read are in $top/mutant-out.
on_copy() {
  (
    inside=$1
    scripts=$tree/.github/scripts
    workflow=$tree/.github/workflows/release.yml
    pages=$tree/.github/workflows/pages.yml
    alone "$top/mutant-work" "$2"
    exit 0
  ) > "$top/mutant-out" 2>&1
}

# mutant <id> <group> <file> <change> <sed expression>: the file with that one change. At
# least one case of the group fails on the copy.
mutant() {
  id=$1 group=$2 file=$3 change=$4
  if ! sed "$5" "$root/$file" > "$tree/$file" 2> "$top/mutant-out" || cmp -s "$root/$file" "$tree/$file"; then
    bad "mutant $id ($change): the change applies to nothing in $file" "$top/mutant-out"
    cp "$root/$file" "$tree/$file"
    return
  fi
  if on_copy "$id" "$group"; then
    bad "mutant $id is accepted: $change"
  else
    ok "mutant $id is refused: $change"
  fi
  cp "$root/$file" "$tree/$file"
}

w=.github/workflows/release.yml
g=.github/workflows/pages.yml
c=.github/scripts/release-check.sh
p=.github/scripts/release-package.sh
v=.github/scripts/release-verify.sh

mutant W1 group_jobs $w "the job package loses needs: gate" '/^    needs: gate$/d'
mutant W2 group_jobs $w "the job bundle loses needs: package" '/^    needs: package$/d'
mutant W3 group_calls $w "the download pattern is archive-*, not release-*" 's/pattern: release-\*/pattern: archive-*/'
mutant W4 group_calls $w "merge-multiple is false" 's/merge-multiple: true/merge-multiple: false/'
mutant W5 group_calls $w "cargo build loses --locked" 's/cargo build --locked /cargo build /'
mutant W6 group_jobs $w "the aarch64 target runs on ubuntu-22.04" 's/runner: ubuntu-22.04-arm/runner: ubuntu-22.04/'
mutant W7 group_calls $w "the job bundle uploads dist/*.tar.gz alone" 's|path: dist/\*$|path: dist/*.tar.gz|'
mutant W8 group_jobs $w "the gate is task check || true" 's/run: task check$/run: task check || true/'
mutant W9 group_jobs $w "the result of release-check.sh is discarded" 's/release-check.sh "$GITHUB_REF_NAME"$/release-check.sh "$GITHUB_REF_NAME" || true/'
mutant W10 group_jobs $w "a checkout loses persist-credentials: false" '/persist-credentials: false/d'
mutant W11 group_trigger $w "a second trigger: every push to main" 's/^    tags: .*$/&\
    branches: [main]/'
mutant W12 group_calls $w "the archive is written to out, dist is uploaded" 's|release/ratchet" dist$|release/ratchet" out|'
mutant W13 group_calls $w "cargo build loses --bin ratchet" 's/ --bin ratchet / /'
mutant W14 group_jobs $w "the result of release-package.sh sums is discarded" 's/release-package.sh sums "$GITHUB_REF_NAME" dist$/& || true/'
mutant W15 group_trigger $w "a job with permissions: write-all" 's/^    name: Bundle the release assets$/&\
    permissions: write-all/'
mutant W16 group_trigger $w "a step that posts a release with a secret token" 's|^          cat dist/notes.md$|          curl -X POST -H "Authorization: Bearer ${{ secrets.RELEASE_TOKEN }}" https://uploads.example/releases|'
mutant W17 group_jobs $w "the job gate may fail: continue-on-error" 's/^    name: Gate$/&\
    continue-on-error: true/'
mutant W18 group_jobs $w "the step of release-check.sh is skipped: if: false" 's/^      - name: The tag, the workspace version and the changelog agree$/&\
        if: false/'
mutant W19 group_pins $w "release.yml alone installs task with another digest" 's/^          GO_TASK_SHA256: 6/          GO_TASK_SHA256: 7/'
mutant W20 group_pins $g "pages.yml alone installs another version of task" 's/^          GO_TASK_VERSION: "3\./          GO_TASK_VERSION: "4./'
mutant W21 group_pins $g "pages.yml alone installs ess with another digest" 's/^          ESS_SHA256: c/          ESS_SHA256: d/'
mutant W22 group_trigger $w "a step that creates the release" 's|^          cat dist/notes.md$|          gh release create "$GITHUB_REF_NAME" dist/*|'

mutant C1 group_section $c "the date of the section is any text" 's/ && substr(\$0, length(start) + 1) ~ [^{]*{/ {/'
mutant C2 group_tag $c "the version is the first of any table" 's/table == "\[workspace.package\]" && //'
mutant C3 group_tag $c "the form of the tag is not checked" 's/^if ! printf .*$/if false; then/'
mutant C4 group_section $c "a section needs no change line" 's/^  if \[ "$changes" = 0 \]; then$/  if false; then/'
mutant C5 group_section $c "the date of the section is not asked of the calendar" 's/^  if \[ "$(date -u -d "$day" .*$/  if false; then/'
mutant C6 group_section $c "a bullet under no heading is a change" 's|^  inside && /^- / && headed { changes++; next }$|  inside \&\& /^- / { changes++; next }|'

if [ "$(id -u)" = 0 ]; then
  echo "skip mutant P1: as uid 0 an archive has the owner 0 with the flags and without"
else
  mutant P1 group_package $p "the archive keeps the builder as owner" 's/ --owner=0 --group=0 --numeric-owner//'
fi
mutant P2 group_package $p "no chmod 755 of the directory and the binary" '/chmod 755/d'
mutant P3 group_package $p "no chmod 644 of LICENSE and README.md" '/chmod 644/d'
mutant P4 group_package $p "the unpacked directory is left beside the archive" '/^    tar -C /,/^    echo /{/rm -rf/d;}'
mutant P5 group_package $p "SHA256SUMS is not verified after it is written" '/^    sha256sum -c SHA256SUMS$/d'
mutant P6 group_notes $p "the notes end only at the end of the file" '/inside && \/^## \/ { exit }/d'
mutant P7 group_package $p "a version may start with v" "s/grep -Eq '^\[0-9\]/grep -Eq '^v?[0-9]/"
mutant P8 group_notes $p "notes: a bullet under no heading is a change" 's|^      inside && /^- / && headed { changes++ }$|      inside \&\& /^- / { changes++ }|'
mutant P9 group_notes $p "notes: a section needs no change line" 's/^        exit changes ? 0 : 3$/        exit 0/'
mutant P10 group_binary $p "archive: the exit status of the binary is not read" '/^    \[ "$status" = 0 \] || refuse/d'
mutant P11 group_binary $p "archive: the version is the last word the binary prints" 's/^    \[ "$printed" = "ratchet $version" \] \\$/    [ "${printed##* }" = "$version" ] \\/'

mutant V1 group_gh $v "gh release view asks for assets,author alone" 's/--json assets,author,isDraft,isPrerelease,tagName/--json assets,author/'
mutant V2 group_gh $v "the gh calls lose --repo" 's/ --repo "$repository"//'
mutant V3 group_gh $v "gh release download loses the patterns" 's/ --dir "$directory" "$@" \\$/ --dir "$directory" \\/'
mutant V4 group_verify_sums $v "SHA256SUMS may name an archive more than once" 's/exit found == 1 ? 0 : 1/exit found >= 1 ? 0 : 1/'
mutant V5 group_verify_state $v "the work directory is not removed" "/^trap 'rm -rf \"\$work\"' EXIT\$/d"
mutant V6 group_verify_members $v "the members of the x86_64 archive alone are read" '/^# 5\. /,/^# 6\. /s/^for archive in $archives; do$/for archive in ratchet-$version-$run_target.tar.gz; do/'
mutant V7 group_gh $v "the repository is read from another key of Cargo.toml" 's/s|^repository = /s|^homepage = /'
mutant V8 group_verify_state $v "isPrerelease is not read" 's/^for state in isDraft:draft isPrerelease:prerelease; do$/for state in isDraft:draft; do/'
mutant V9 group_verify_assets $v "an asset beside the three is accepted" '/^\[ -z "$other" \] || refuse/d'
mutant V10 group_verify_members $v "the kind of a member is not read" "s/^    END { exit (NR == 4 .*\$/    END { exit 0 }' \\\\/"
mutant V11 group_verify_binary $v "the exit status of the binary is not read" '/^\[ "$status" = 0 \] || refuse/d'
mutant V12 group_verify_binary $v "the version is the last word the binary prints" 's/^\[ "$printed" = "ratchet $version" \] \\$/[ "${printed##* }" = "$version" ] \\/'

# ------------------------------------------------------------------------------------------

if [ "$failed" != 0 ]; then
  echo "release: $((cases - failed)) of $cases cases pass" >&2
  exit 1
fi
echo "release: $cases of $cases cases pass"
