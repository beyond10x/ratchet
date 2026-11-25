#!/bin/sh
# A tag may be released: it is the workspace version, and the changelog has its dated section.
#
#   release-check.sh [--manifest <Cargo.toml>] [--changelog <CHANGELOG.md>] <tag>
#
# 1. The tag is a bare version, <major>.<minor>.<patch>, and equals `version` in
#    `[workspace.package]` of the manifest.
# 2. The changelog has the line `## [<tag>] - <YYYY-MM-DD>`.
#
# Without the options it reads Cargo.toml and CHANGELOG.md of the repository this script is in.
# Both checks run; each prints one line, a pass on standard output and a failure on standard
# error.
#
# Exit 0: both hold. Exit 1: one does not. Exit 2: the call is wrong or a file is unreadable.
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

heading=$(awk -v start="## [$tag] - " '
  index($0, start) == 1 && substr($0, length(start) + 1) ~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$/ {
    print
    exit
  }' "$changelog")
if [ -n "$heading" ]; then
  echo "release-check: ${changelog##*/} has the section \`$heading\`"
else
  echo "release-check: ${changelog##*/} has no section \`## [$tag] - <YYYY-MM-DD>\`" >&2
  fail=1
fi

exit "$fail"
