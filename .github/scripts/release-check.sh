#!/bin/sh
# A tag may be released: it is the workspace version, and the changelog has its dated section
# with the changes of the release.
#
#   release-check.sh [--manifest <Cargo.toml>] [--changelog <CHANGELOG.md>] <tag>
#
# 1. The tag is a bare version, <major>.<minor>.<patch>, and equals `version` in
#    `[workspace.package]` of the manifest.
# 2. The changelog has the line `## [<tag>] - <YYYY-MM-DD>`, the date is a date of the
#    calendar, and the section below the line holds a change: at least one `- ` line under a
#    `### ` heading. A section without one has no release notes, and the tag workflow would
#    fail in its last job, after the tag is pushed.
#
# Without the options it reads Cargo.toml and CHANGELOG.md of the repository this script is in.
# Both checks run; each prints one line, a pass on standard output and a failure on standard
# error. The script reads no tag and no release: a version below the tag may have a section
# and a tag and no release (AGENTS.md § "Release", "A tag whose run fails").
#
# Exit 0: both hold. Exit 1: one does not. Exit 2: the call is wrong, a file is unreadable or
# `date` is not GNU date.
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
manifest=$root/Cargo.toml
changelog=$root/CHANGELOG.md
tag=

usage() {
  echo "usage: release-check.sh [--manifest <Cargo.toml>] [--changelog <CHANGELOG.md>] <tag>" >&2
  exit 2
}

while [ $# -gt 0 ]; do
  case $1 in
    --manifest) [ $# -ge 2 ] || usage; manifest=$2; shift 2 ;;
    --changelog) [ $# -ge 2 ] || usage; changelog=$2; shift 2 ;;
    -*) usage ;;
    *) [ -z "$tag" ] || usage; tag=$1; shift ;;
  esac
done
[ -n "$tag" ] || usage
for file in "$manifest" "$changelog"; do
  [ -r "$file" ] || { echo "release-check: cannot read $file" >&2; exit 2; }
done
[ "$(date -u -d 2000-02-29 +%Y-%m-%d 2> /dev/null)" = 2000-02-29 ] \
  || { echo "release-check: \`date -d\` reads no date: GNU date is needed" >&2; exit 2; }

if ! printf '%s\n' "$tag" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  echo "release-check: $tag is no version of the form <major>.<minor>.<patch>" >&2
  exit 1
fi

fail=0

workspace=$(awk '
  /^\[/ { table = $0; next }
  table == "[workspace.package]" && /^version[ \t]*=/ {
    value = $0
    sub(/^version[ \t]*=[ \t]*"/, "", value)
    sub(/".*$/, "", value)
    print value
    exit
  }' "$manifest")
if [ -z "$workspace" ]; then
  echo "release-check: ${manifest##*/} has no version in [workspace.package]" >&2
  fail=1
elif [ "$workspace" = "$tag" ]; then
  echo "release-check: tag $tag equals the workspace version"
else
  echo "release-check: tag $tag is not the workspace version $workspace" >&2
  fail=1
fi

# The section of the tag: the number of its `- ` lines under a `### ` heading, then its
# heading. No line when the changelog has no such section.
section=$(awk -v start="## [$tag] - " '
  inside && /^## / { exit }
  inside && /^### / { headed = 1; next }
  inside && /^- / && headed { changes++; next }
  !inside && index($0, start) == 1 && substr($0, length(start) + 1) ~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$/ { inside = 1; heading = $0 }
  END { if (inside) print (changes + 0) " " heading }' "$changelog")
if [ -z "$section" ]; then
  echo "release-check: ${changelog##*/} has no section \`## [$tag] - <YYYY-MM-DD>\`" >&2
  fail=1
else
  changes=${section%% *}
  heading=${section#* }
  day=${heading##* }
  sound=1
  # Whether the date is one of the calendar is asked of `date -d`, which is GNU date: it
  # prints a date it reads back unchanged and reads no 2026-02-30. The CI runners are Ubuntu,
  # and a workstation that runs the gate has GNU date too.
  if [ "$(date -u -d "$day" +%Y-%m-%d 2> /dev/null)" != "$day" ]; then
    echo "release-check: ${changelog##*/}: the section \`$heading\` names no date of the calendar" >&2
    sound=0
  fi
  if [ "$changes" = 0 ]; then
    echo "release-check: ${changelog##*/}: the section \`$heading\` holds no change line under a heading" >&2
    sound=0
  fi
  if [ "$sound" = 1 ]; then
    echo "release-check: ${changelog##*/} has the section \`$heading\`, changes: $changes"
  else
    fail=1
  fi
fi

exit "$fail"
