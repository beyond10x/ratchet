#!/bin/sh
# What a release is made of: the archives, their checksums and the notes.
#
#   release-package.sh targets
#       the targets a release is built for, one per line
#   release-package.sh assets <version>
#       the names of the files a release carries: one archive per target, then SHA256SUMS
#   release-package.sh archive <version> <target> <binary> <directory>
#       write <directory>/ratchet-<version>-<target>.tar.gz. It holds one directory,
#       ratchet-<version>-<target>, with the binary as `ratchet`, LICENSE and README.md, each
#       with owner 0, the directory and the binary with mode 755, the two files with 644.
#       Refused unless `<binary> --version` prints `ratchet <version>`, that line and no
#       other, and exits 0
#   release-package.sh sums <version> <directory>
#       write <directory>/SHA256SUMS over the archive of every target and verify it.
#       Refused when an archive is not there
#   release-package.sh notes <version> [<CHANGELOG.md>]
#       print the section `## [<version>] - <YYYY-MM-DD>` of the changelog without its
#       heading and without the empty lines around it. Refused when it holds no change: no
#       `- ` line under a `### ` heading
#
# LICENSE, README.md and the default changelog are those of the repository this script is in.
# .github/workflows/release.yml calls `archive` once per target, then `sums` and `notes`.
#
# Exit 0: done. Exit 1: refused, with one line on standard error. Exit 2: the call is wrong.
# Needs `tar` and `sha256sum`.
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
targets='x86_64-unknown-linux-gnu aarch64-unknown-linux-gnu x86_64-unknown-linux-musl'

usage() {
  echo "usage: release-package.sh targets" >&2
  echo "       release-package.sh assets <version>" >&2
  echo "       release-package.sh archive <version> <target> <binary> <directory>" >&2
  echo "       release-package.sh sums <version> <directory>" >&2
  echo "       release-package.sh notes <version> [<CHANGELOG.md>]" >&2
  exit 2
}

refuse() {
  echo "release-package: $1" >&2
  exit 1
}

# version_of <text>: refuse a text that is no bare version.
version_of() {
  printf '%s\n' "$1" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$' \
    || refuse "$1 is no version of the form <major>.<minor>.<patch>"
}

command=${1-}
[ $# -gt 0 ] && shift

case $command in
  targets)
    [ $# = 0 ] || usage
    for target in $targets; do echo "$target"; done
    ;;

  assets)
    [ $# = 1 ] || usage
    version_of "$1"
    for target in $targets; do echo "ratchet-$1-$target.tar.gz"; done
    echo SHA256SUMS
    ;;

  archive)
    [ $# = 4 ] || usage
    version=$1 target=$2 binary=$3 directory=$4
    version_of "$version"
    case " $targets " in
      *" $target "*) ;;
      *) refuse "$target is no target of a release: $targets" ;;
    esac
    [ -f "$binary" ] && [ -x "$binary" ] || refuse "$binary is no executable file"
    case $binary in
      */*) ;;
      *) binary=./$binary ;;
    esac
    status=0
    printed=$("$binary" --version 2> /dev/null) || status=$?
    [ "$status" = 0 ] || refuse "\`ratchet --version\` exits $status"
    [ "$printed" = "ratchet $version" ] \
      || refuse "the binary prints \"$(printf '%s\n' "$printed" | sed -n 1p)\", not \"ratchet $version\""
    name=ratchet-$version-$target
    rm -rf "${directory:?}/$name"
    mkdir -p "$directory/$name"
    cp "$binary" "$directory/$name/ratchet"
    cp "$root/LICENSE" "$root/README.md" "$directory/$name/"
    chmod 755 "$directory/$name" "$directory/$name/ratchet"
    chmod 644 "$directory/$name/LICENSE" "$directory/$name/README.md"
    tar -C "$directory" --owner=0 --group=0 --numeric-owner -czf "$directory/$name.tar.gz" "$name"
    rm -rf "${directory:?}/$name"
    echo "release-package: $name.tar.gz holds ratchet ($version), LICENSE and README.md"
    ;;

  sums)
    [ $# = 2 ] || usage
    version=$1 directory=$2
    version_of "$version"
    set --
    for target in $targets; do
      [ -f "$directory/ratchet-$version-$target.tar.gz" ] \
        || refuse "no ratchet-$version-$target.tar.gz in $directory"
      set -- "$@" "ratchet-$version-$target.tar.gz"
    done
    cd "$directory"
    sha256sum "$@" > SHA256SUMS
    sha256sum -c SHA256SUMS
    ;;

  notes)
    [ $# = 1 ] || [ $# = 2 ] || usage
    version=$1 changelog=${2:-$root/CHANGELOG.md}
    version_of "$version"
    [ -r "$changelog" ] || refuse "cannot read $changelog"
    status=0
    notes=$(awk -v start="## [$version] - " '
      inside && /^## / { exit }
      inside && /^### / { headed = 1 }
      inside && /^- / && headed { changes++ }
      inside { lines[++count] = $0; next }
      index($0, start) == 1 && substr($0, length(start) + 1) ~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$/ { inside = 1 }
      END {
        first = 1
        while (first <= count && lines[first] ~ /^[ \t]*$/) first++
        last = count
        while (last >= first && lines[last] ~ /^[ \t]*$/) last--
        for (i = first; i <= last; i++) print lines[i]
        exit changes ? 0 : 3
      }' "$changelog") || status=$?
    [ -n "$notes" ] || refuse "${changelog##*/} has no notes for $version"
    [ "$status" = 0 ] \
      || refuse "the section of $version in ${changelog##*/} holds no change line under a heading"
    printf '%s\n' "$notes"
    ;;

  *) usage ;;
esac
