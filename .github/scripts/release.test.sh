#!/bin/sh
# The release procedure of AGENTS.md § "Release", checked without a network, a build, a tag or
# the real `gh`: the files a release is cut from, and the scripts the tag workflow and the
# release steps run.
#
#   - CHANGELOG.md is in the Keep a Changelog form: `# Changelog`, a link to version 1.1.0,
#     `## [Unreleased]` first, every other section `## [<version>] - <YYYY-MM-DD>`, only the six
#     headings below a section, one bullet per change on one line. The same check refuses five
#     broken copies.
#   - AGENTS.md has a section "Release" that names the scripts, the workflow and the steps.
#   - release-check.sh: a tag equal to the workspace version passes; another tag, a tag that is
#     no bare version and a manifest without a workspace version fail. A tag with a dated
#     section in the changelog passes; one without a section and one whose section has no date
#     or a date of another form fail.
#   - release-package.sh: the notes cut for a tag equal its section, and a tag without a
#     section has none; the archive built from a stub binary holds `ratchet`, `LICENSE` and
#     `README.md` and verifies against the `SHA256SUMS` written beside it; a binary that prints
#     another version, another target, a file that is no executable, a version of another form
#     and a directory that lacks an archive are refused.
#   - release-verify.sh: a recorded release description with the bot as author beside a
#     directory of its three assets passes. It fails for another author, a draft, a
#     description that names no draft state, is of another release or is no JSON object, an
#     asset that is not uploaded, not attached or not in the directory, a `SHA256SUMS` that
#     does not name an archive, a changed archive, an archive that holds another file and a
#     binary that prints another version. With `--description` and `--assets` it calls no `gh`;
#     without them it reads the release through `gh release view` and `gh release download`,
#     here a stand-in first in PATH, and fails when either fails.
#   - .github/workflows/release.yml runs on a bare version tag with `contents: read` and no
#     write permission, calls the scripts, builds every target the scripts name, and pins the
#     tools of the gate as .github/workflows/pages.yml does.
#
# Every file the script writes is under a directory it creates with `mktemp -d` inside
# ${TMPDIR:-target} and removes.
#
# Exit 0: one `ok` line per case, the last line is `release: <n> of <n> cases pass`.
# Exit 1: each case that went the other way is a `FAIL` line with the output it read.
# Needs `jq`, `tar` and `sha256sum`.
set -u

root=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
scripts=$root/.github/scripts
workflow=$root/.github/workflows/release.yml
bot='b10x-bot[bot]'
version=1.2.3

for tool in jq tar sha256sum; do
  command -v "$tool" > /dev/null 2>&1 || { echo "release: $tool is not installed" >&2; exit 1; }
done

base=${TMPDIR:-$root/target}
mkdir -p "$base"
work=$(mktemp -d "$base/release-test.XXXXXX") || { echo "release: mktemp -d in $base failed" >&2; exit 1; }
trap 'rm -rf "$work"' EXIT
trap 'exit 1' HUP INT TERM

cases=0 failed=0

ok() {
  cases=$((cases + 1))
  echo "ok   $1"
}

# bad <case> [<file>]: the case failed; the file is what it read.
bad() {
  cases=$((cases + 1))
  failed=$((failed + 1))
  echo "FAIL $1"
  if [ -n "${2-}" ] && [ -f "$2" ]; then sed 's/^/     /' "$2"; fi
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
  while IFS= read -r text; do
    [ -n "$text" ] || continue
    [ -z "$why" ] || break
    grep -qF -- "$text" "$work/out" || why="the output lacks: $text"
  done << TEXTS
$texts
TEXTS
  if [ -z "$why" ]; then
    ok "$label"
  else
    bad "$label: $why" "$work/out"
  fi
}

# A stand-in for `gh`, first in PATH for every command below. It writes each call to GH_CALLS
# and answers `release view` and `release download` from the directory GH_RELEASE; without
# GH_RELEASE it finds no release, and with GH_NO_DOWNLOAD the download fails.
mkdir -p "$work/bin"
cat > "$work/bin/gh" << 'GH'
#!/bin/sh
printf '%s\n' "$*" >> "$GH_CALLS"
[ -n "${GH_RELEASE-}" ] || { echo "release not found" >&2; exit 1; }
case "${1-} ${2-}" in
  "release view") cat "$GH_RELEASE/description.json" ;;
  "release download")
    [ -z "${GH_NO_DOWNLOAD-}" ] || { echo "download failed" >&2; exit 1; }
    dir= previous=
    for argument in "$@"; do
      [ "$previous" = --dir ] && dir=$argument
      previous=$argument
    done
    [ -n "$dir" ] || exit 1
    mkdir -p "$dir"
    cp "$GH_RELEASE"/assets/* "$dir/"
    ;;
  *) exit 1 ;;
esac
GH
chmod +x "$work/bin/gh"
PATH=$work/bin:$PATH
GH_CALLS=$work/gh-calls
export PATH GH_CALLS
unset GH_RELEASE
: > "$GH_CALLS"

# --- CHANGELOG.md -------------------------------------------------------------------------

# changelog_form <file>: print each line that leaves the Keep a Changelog form; exit 1 on any.
changelog_form() {
  awk '
    function defect(text) { print "CHANGELOG.md:" NR ": " text; defects++ }
    BEGIN {
      count = split("Added Changed Deprecated Removed Fixed Security", names, " ")
      for (i = 1; i <= count; i++) kinds["### " names[i]] = 1
    }
    NR == 1 { if ($0 != "# Changelog") defect("the first line is not `# Changelog`"); next }
    /^## / {
      sections++
      kind = ""
      if ($0 == "## [Unreleased]") {
        unreleased++
        if (sections != 1) defect("`## [Unreleased]` is not the first section")
      } else if ($0 !~ /^## \[[0-9]+\.[0-9]+\.[0-9]+\] - [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$/) {
        defect("a section is `## [Unreleased]` or `## [<version>] - <YYYY-MM-DD>`")
      }
      next
    }
    !sections { if (index($0, "https://keepachangelog.com/en/1.1.0/")) named = 1; next }
    /^### / {
      if (!($0 in kinds)) defect("a heading is one of Added, Changed, Deprecated, Removed, Fixed, Security")
      kind = $0
      next
    }
    /^$/ { next }
    /^- / { if (kind == "") defect("a bullet stands under none of the six headings"); next }
    { defect("the line is no heading and starts no bullet: a change is one bullet on one line") }
    END {
      if (!named) { print "CHANGELOG.md: no link to Keep a Changelog 1.1.0 before the first section"; defects++ }
      if (unreleased != 1) { print "CHANGELOG.md: " (unreleased + 0) " sections `## [Unreleased]`, not 1"; defects++ }
      exit defects ? 1 : 0
    }' "$1"
}

if [ -f "$root/CHANGELOG.md" ]; then
  check 'CHANGELOG.md has `## [Unreleased]` in the Keep a Changelog form' pass -- changelog_form "$root/CHANGELOG.md"
else
  bad "CHANGELOG.md has \`## [Unreleased]\` in the Keep a Changelog form: no CHANGELOG.md"
fi

# The changelog of the fixtures: an open section, the release under test and an older one.
mkdir -p "$work/fixture"
changelog=$work/fixture/CHANGELOG.md
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

# Five copies of it, each with one defect of form.
mkdir -p "$work/broken"
sed 's/^## \[Unreleased\]$/## Unreleased/' "$changelog" > "$work/broken/no-unreleased-section"
sed 's/^## \[1\.2\.3\] - 2026-01-02$/## [1.2.3]/' "$changelog" > "$work/broken/section-without-date"
sed 's/^### Fixed$/### Improved/' "$changelog" > "$work/broken/unknown-heading"
sed 's/^- the first change of 1\.2\.3$/- the first change of 1.2.3,\
  continued on a second line/' "$changelog" > "$work/broken/bullet-on-two-lines"
awk '$0 == "### Added" && !done { done = 1; next } { print }' "$changelog" > "$work/broken/bullet-under-no-heading"
broken=0 refused=0
: > "$work/form"
if changelog_form "$changelog" > "$work/out" 2>&1; then
  for copy in "$work"/broken/*; do
    broken=$((broken + 1))
    if cmp -s "$changelog" "$copy"; then
      echo "${copy##*/}: the copy equals the fixture" >> "$work/form"
    elif changelog_form "$copy" > "$work/out" 2>&1; then
      echo "${copy##*/}: accepted" >> "$work/form"
    else
      refused=$((refused + 1))
    fi
  done
else
  cp "$work/out" "$work/form"
  echo "the fixture itself is refused" >> "$work/form"
fi
if [ "$broken" = 5 ] && [ "$refused" = 5 ]; then
  ok "the form check refuses 5 of 5 broken changelogs"
else
  bad "the form check refuses $refused of $broken broken changelogs, not 5 of 5" "$work/form"
fi

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

check 'AGENTS.md has a section "Release" with the steps, the scripts and the changelog rule' pass -- \
  section_names '## [Unreleased]' 'release/<version>' '.github/workflows/release.yml' \
  'release-check.sh' 'release-package.sh' 'release-verify.sh' 'sha256sum -c SHA256SUMS' \
  'release create <version> --verify-tag' "$bot"

# --- release-check.sh ---------------------------------------------------------------------

# manifest <version>: a root manifest with that workspace version and another version beside it.
manifest() {
  mkdir -p "$work/fixture/$1"
  cat > "$work/fixture/$1/Cargo.toml" << MANIFEST
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
sed 's/^## \[Unreleased\]$/## [1.2.5]/' "$changelog" > "$work/fixture/1.2.5/CHANGELOG.md"
sed 's/^## \[Unreleased\]$/## [1.2.6] - 2 January 2026/' "$changelog" > "$work/fixture/1.2.6/CHANGELOG.md"
grep -v '^version = "1\.2\.7"$' "$work/fixture/1.2.7/Cargo.toml" > "$work/fixture/1.2.7/Cargo.toml.new"
mv "$work/fixture/1.2.7/Cargo.toml.new" "$work/fixture/1.2.7/Cargo.toml"

release_check() {
  sh "$scripts/release-check.sh" --manifest "$work/fixture/$1/Cargo.toml" --changelog "$2" "$3"
}

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
check "the changelog check passes for a tag with a section" pass \
  'release-check: CHANGELOG.md has the section `## [1.2.3] - 2026-01-02`' -- \
  release_check 1.2.3 "$changelog" 1.2.3
check "the changelog check fails for a tag without a section" refuse \
  'release-check: tag 1.2.4 equals the workspace version' \
  'release-check: CHANGELOG.md has no section `## [1.2.4] - <YYYY-MM-DD>`' -- \
  release_check 1.2.4 "$changelog" 1.2.4
check "the changelog check fails for a tag whose section has no date" refuse \
  'release-check: tag 1.2.5 equals the workspace version' \
  'release-check: CHANGELOG.md has no section `## [1.2.5] - <YYYY-MM-DD>`' -- \
  release_check 1.2.5 "$work/fixture/1.2.5/CHANGELOG.md" 1.2.5
check "the changelog check fails for a tag whose section has a date of another form" refuse \
  'release-check: tag 1.2.6 equals the workspace version' \
  'release-check: CHANGELOG.md has no section `## [1.2.6] - <YYYY-MM-DD>`' -- \
  release_check 1.2.6 "$work/fixture/1.2.6/CHANGELOG.md" 1.2.6
check "the tag check fails for a manifest without a workspace version" refuse \
  'release-check: Cargo.toml has no version in [workspace.package]' -- \
  release_check 1.2.7 "$changelog" 1.2.3

# --- release-package.sh: the notes --------------------------------------------------------

cat > "$work/fixture/notes-wanted" << 'NOTES'
### Added

- the first change of 1.2.3
- the second change of 1.2.3

### Fixed

- a fix of 1.2.3
NOTES

notes_equal() {
  sh "$scripts/release-package.sh" notes "$1" "$changelog" > "$work/notes" || return 1
  cmp "$work/notes" "$work/fixture/notes-wanted"
}

check "the notes cut for a tag equal that section" pass -- notes_equal 1.2.3
check "the notes of a tag without a section are refused" refuse \
  'release-package: CHANGELOG.md has no notes for 1.2.4' -- \
  sh "$scripts/release-package.sh" notes 1.2.4 "$changelog"

# --- release-package.sh: the archives and their checksums ---------------------------------

# stub <directory> <version>: a `ratchet` that prints the version for `--version`.
stub() {
  mkdir -p "$1"
  cat > "$1/ratchet" << STUB
#!/bin/sh
[ "\${1-}" = --version ] || exit 1
echo "ratchet $2"
STUB
  chmod +x "$1/ratchet"
}

stub "$work/stub" "$version"
stub "$work/stub-other" 9.9.9
dist=$work/dist
targets=$(sh "$scripts/release-package.sh" targets 2> "$work/targets") || targets=
first_target=${targets%%
*}

# archives: build the archive of each target from the stub, then compare what one holds.
archives() {
  [ -n "$targets" ] || { echo "release-package.sh targets names no target"; cat "$work/targets"; return 1; }
  for target in $targets; do
    sh "$scripts/release-package.sh" archive "$version" "$target" "$work/stub/ratchet" "$dist" || return 1
    [ -f "$dist/ratchet-$version-$target.tar.gz" ] || { echo "no $dist/ratchet-$version-$target.tar.gz"; return 1; }
  done
  name=ratchet-$version-$first_target
  tar -tzf "$dist/$name.tar.gz" | sed 's|/$||' | LC_ALL=C sort > "$work/members"
  printf '%s\n' "$name" "$name/LICENSE" "$name/README.md" "$name/ratchet" > "$work/members-wanted"
  cmp "$work/members" "$work/members-wanted" || { cat "$work/members"; return 1; }
  rm -rf "$work/unpacked"
  mkdir -p "$work/unpacked"
  tar -xzf "$dist/$name.tar.gz" -C "$work/unpacked" || return 1
  cmp "$work/unpacked/$name/LICENSE" "$root/LICENSE" || return 1
  cmp "$work/unpacked/$name/README.md" "$root/README.md" || return 1
  cmp "$work/unpacked/$name/ratchet" "$work/stub/ratchet" || return 1
  [ -x "$work/unpacked/$name/ratchet" ] || { echo "$name/ratchet is not executable"; return 1; }
}

# sums: write SHA256SUMS beside the archives; it names each archive once and verifies.
sums() {
  sh "$scripts/release-package.sh" sums "$version" "$dist" || return 1
  for target in $targets; do
    lines=$(grep -c "  ratchet-$version-$target\.tar\.gz\$" "$dist/SHA256SUMS")
    [ "$lines" = 1 ] || { echo "SHA256SUMS names ratchet-$version-$target.tar.gz $lines times"; return 1; }
  done
  [ "$(grep -c . "$dist/SHA256SUMS")" = "$(printf '%s\n' "$targets" | grep -c .)" ] || { echo "SHA256SUMS has other lines"; cat "$dist/SHA256SUMS"; return 1; }
  (cd "$dist" && sha256sum -c SHA256SUMS)
}

check "the archive built from a stub binary holds ratchet, LICENSE and README.md" pass -- archives
check "the archive verifies against the SHA256SUMS written beside it" pass -- sums
check "an archive of a binary that prints another version is refused" refuse \
  'release-package: the binary prints 9.9.9, not 1.2.3' -- \
  sh "$scripts/release-package.sh" archive "$version" "${first_target:-none}" "$work/stub-other/ratchet" "$work/dist-other"
check "an archive for a target no release is built for is refused" refuse \
  'release-package: x86_64-apple-darwin is no target of a release' -- \
  sh "$scripts/release-package.sh" archive "$version" x86_64-apple-darwin "$work/stub/ratchet" "$work/dist-other"
check "an archive of a file that is no executable is refused" refuse \
  'release-package: ' ' is no executable file' -- \
  sh "$scripts/release-package.sh" archive "$version" "${first_target:-none}" "$work/fixture/notes-wanted" "$work/dist-other"
check "a version that is no bare version is refused" refuse \
  'release-package: 1.2 is no version of the form <major>.<minor>.<patch>' -- \
  sh "$scripts/release-package.sh" assets 1.2

mkdir -p "$work/dist-short"
[ -n "$first_target" ] && cp "$dist/ratchet-$version-$first_target.tar.gz" "$work/dist-short/" 2> /dev/null
check "checksums of a directory that lacks an archive are refused" refuse \
  'release-package: no ratchet-1.2.3-' -- \
  sh "$scripts/release-package.sh" sums "$version" "$work/dist-short"

# --- release-verify.sh --------------------------------------------------------------------

# describe <login> <draft> <asset>...: a release description in the form
# `gh release view <version> --json assets,author,isDraft,tagName` prints it.
describe() {
  login=$1 draft=$2
  shift 2
  printf '%s\n' "$@" | jq -R . | jq -s --arg login "$login" --argjson draft "$draft" --arg tag "$version" '{
    assets: map({name: ., state: "uploaded", contentType: "application/octet-stream", label: ""}),
    author: {id: "BOT_0000000000", login: $login},
    isDraft: $draft,
    tagName: $tag
  }'
}

assets=$(sh "$scripts/release-package.sh" assets "$version" 2> /dev/null) || assets=
x86_64=ratchet-$version-x86_64-unknown-linux-gnu

# release <name>: a directory with the description of the release and a copy of its assets.
release() {
  mkdir -p "$work/release/$1/assets"
  for asset in $assets; do cp "$dist/$asset" "$work/release/$1/assets/" 2> /dev/null; done
  # shellcheck disable=SC2086
  describe "$bot" false $assets > "$work/release/$1/description.json"
}

verify() {
  sh "$scripts/release-verify.sh" "$version" --description "$work/release/$1/description.json" --assets "$work/release/$1/assets"
}

release good
check "release-verify.sh passes for a description with the bot as author beside its three assets" pass \
  'release-verify: the release 1.2.3 is published' \
  "release-verify: its author is $bot" \
  'release-verify: its 3 assets are attached' \
  'release-verify: sha256sum -c SHA256SUMS passes' \
  'release-verify: the ratchet of the x86_64 archive prints 1.2.3' -- \
  verify good
read_from_disk=$got

release author
# shellcheck disable=SC2086
describe b10x-bot false $assets > "$work/release/author/description.json"
check "release-verify.sh fails for another author" refuse \
  "release-verify: the author of the release is b10x-bot, not $bot" -- \
  verify author

release draft
# shellcheck disable=SC2086
describe "$bot" true $assets > "$work/release/draft/description.json"
check "release-verify.sh fails for a draft" refuse \
  'release-verify: the release 1.2.3 is a draft' -- \
  verify draft

release undecided
jq 'del(.isDraft)' "$work/release/good/description.json" > "$work/release/undecided/description.json"
check "release-verify.sh fails for a description that does not say whether it is a draft" refuse \
  'release-verify: the description does not say whether the release 1.2.3 is a draft' -- \
  verify undecided

release other
jq '.tagName = "1.2.2"' "$work/release/good/description.json" > "$work/release/other/description.json"
check "release-verify.sh fails for the description of another release" refuse \
  'release-verify: the description is of the release 1.2.2, not 1.2.3' -- \
  verify other

release text
echo "release not found" > "$work/release/text/description.json"
check "release-verify.sh fails for a description that is no JSON object" refuse \
  'release-verify: the description ' ' is no JSON object' -- \
  verify text

release uploading
jq '.assets[0].state = "open"' "$work/release/good/description.json" > "$work/release/uploading/description.json"
check "release-verify.sh fails for an asset that is not uploaded" refuse \
  'release-verify: the asset ratchet-1.2.3-x86_64-unknown-linux-gnu.tar.gz is not attached' -- \
  verify uploading

release unattached
describe "$bot" false "$x86_64.tar.gz" SHA256SUMS > "$work/release/unattached/description.json"
check "release-verify.sh fails for an asset that is not attached" refuse \
  'release-verify: the asset ratchet-1.2.3-aarch64-unknown-linux-gnu.tar.gz is not attached' -- \
  verify unattached

release absent
rm -f "$work/release/absent/assets/SHA256SUMS"
check "release-verify.sh fails for an asset that is not in the directory" refuse \
  'release-verify: the asset SHA256SUMS is not in ' -- \
  verify absent

release changed
printf 'x' >> "$work/release/changed/assets/$x86_64.tar.gz"
check "release-verify.sh fails for a changed archive" refuse \
  'release-verify: sha256sum -c SHA256SUMS fails' -- \
  verify changed

release unnamed
(cd "$work/release/unnamed/assets" && sha256sum "$x86_64.tar.gz" > SHA256SUMS) 2> /dev/null
check "release-verify.sh fails for a SHA256SUMS that does not name an archive" refuse \
  'release-verify: SHA256SUMS does not name ratchet-1.2.3-aarch64-unknown-linux-gnu.tar.gz once' -- \
  verify unnamed

# unpack: the x86_64 archive as a directory the caller changes.
unpack() {
  rm -rf "$work/repack"
  mkdir -p "$work/repack"
  tar -xzf "$dist/$x86_64.tar.gz" -C "$work/repack" 2> /dev/null
}

# repack <release>: that directory as the x86_64 archive of the release, with checksums that
# match it.
repack() {
  tar -czf "$work/release/$1/assets/$x86_64.tar.gz" -C "$work/repack" "$x86_64" 2> /dev/null \
    && (cd "$work/release/$1/assets" && sha256sum ratchet-*.tar.gz > SHA256SUMS)
}

release extra
unpack && echo "not of the release" > "$work/repack/$x86_64/NOTICE" && repack extra
check "release-verify.sh fails for an archive that holds another file" refuse \
  'release-verify: sha256sum -c SHA256SUMS passes' \
  'release-verify: ratchet-1.2.3-x86_64-unknown-linux-gnu.tar.gz does not hold ratchet, LICENSE and README.md' -- \
  verify extra

release binary
unpack && cp "$work/stub-other/ratchet" "$work/repack/$x86_64/ratchet" && repack binary
check "release-verify.sh fails for a binary that prints another version" refuse \
  'release-verify: sha256sum -c SHA256SUMS passes' \
  'release-verify: the ratchet of the x86_64 archive prints 9.9.9, not 1.2.3' -- \
  verify binary

if [ "$read_from_disk" != pass ]; then
  bad "release-verify.sh with --description and --assets calls no gh: no such run passed"
elif [ -s "$GH_CALLS" ]; then
  bad "release-verify.sh with --description and --assets calls no gh" "$GH_CALLS"
else
  ok "release-verify.sh with --description and --assets calls no gh"
fi

# Without the two options the release is read through gh: the stand-in serves the good one.
gh_reads() {
  GH_RELEASE=$work/release/good sh "$scripts/release-verify.sh" "$version" || return 1
  [ "$(grep -c . "$GH_CALLS")" = 2 ] || { echo "gh was not called twice:"; cat "$GH_CALLS"; return 1; }
  grep -q "^release view $version " "$GH_CALLS" || { echo "no gh release view $version:"; cat "$GH_CALLS"; return 1; }
  grep -q "^release download $version " "$GH_CALLS" || { echo "no gh release download $version:"; cat "$GH_CALLS"; return 1; }
}
check "release-verify.sh without them reads the release with gh release view and gh release download" pass \
  "release-verify: its author is $bot" \
  'release-verify: the ratchet of the x86_64 archive prints 1.2.3' -- \
  gh_reads
check "release-verify.sh fails while gh finds no release" refuse \
  'release-verify: gh release view 1.2.3 found no release' -- \
  sh "$scripts/release-verify.sh" "$version"
gh_downloads_nothing() {
  GH_RELEASE=$work/release/good GH_NO_DOWNLOAD=1 sh "$scripts/release-verify.sh" "$version"
}
check "release-verify.sh fails when gh release download fails" refuse \
  "release-verify: its author is $bot" \
  'release-verify: gh release download 1.2.3 failed' -- \
  gh_downloads_nothing

# --- .github/workflows/release.yml --------------------------------------------------------

# workflow_trigger: a bare version tag starts it, it may read the repository and write nothing.
workflow_trigger() {
  [ -f "$workflow" ] || { echo "no .github/workflows/release.yml"; return 1; }
  grep -qxF "    tags: ['[0-9]+.[0-9]+.[0-9]+']" "$workflow" || { echo "the tag pattern is not [0-9]+.[0-9]+.[0-9]+"; return 1; }
  grep -qxF "  contents: read" "$workflow" || { echo "no top-level contents: read"; return 1; }
  if grep -n ': write' "$workflow"; then echo "a write permission"; return 1; fi
  if grep -n -e 'release create' -e 'gh release' -e 'git push' -e 'git tag' "$workflow"; then echo "the workflow publishes"; return 1; fi
}

# workflow_calls: its steps run the scripts, for every target they name.
workflow_calls() {
  [ -f "$workflow" ] || { echo "no .github/workflows/release.yml"; return 1; }
  for call in 'sh .github/scripts/release-check.sh "$GITHUB_REF_NAME"' \
    'sh .github/scripts/release-package.sh archive "$GITHUB_REF_NAME" "$TARGET"' \
    'sh .github/scripts/release-package.sh sums "$GITHUB_REF_NAME" dist' \
    'sh .github/scripts/release-package.sh notes "$GITHUB_REF_NAME" CHANGELOG.md > dist/notes.md' \
    'task check' \
    'name: ratchet-${{ github.ref_name }}-release'; do
    grep -qF -- "$call" "$workflow" || { echo "the workflow lacks: $call"; return 1; }
  done
  [ -n "$targets" ] || { echo "release-package.sh targets names no target"; return 1; }
  sed -n 's/^ *- target: *//p' "$workflow" | LC_ALL=C sort > "$work/built"
  printf '%s\n' "$targets" | LC_ALL=C sort > "$work/named"
  cmp "$work/built" "$work/named" || { echo "the targets of the workflow:"; cat "$work/built"; return 1; }
}

# pins <workflow>: the versions and checksums of the tools it installs.
pins() {
  grep -E '^ *([A-Z]+_(VERSION|SHA256)|version|node-version): ' "$1" | sed 's/^ *//' | LC_ALL=C sort -u
}

# workflow_pins: the gate of the tag runs with the tools of the gate of a pull request, and
# every action is pinned by a commit, the same commit where pages.yml uses the action too.
workflow_pins() {
  [ -f "$workflow" ] || { echo "no .github/workflows/release.yml"; return 1; }
  pages=$root/.github/workflows/pages.yml
  pins "$pages" > "$work/pins-pages"
  pins "$workflow" > "$work/pins-release"
  [ -s "$work/pins-pages" ] || { echo "pages.yml pins no tool"; return 1; }
  cmp "$work/pins-pages" "$work/pins-release" || { echo "release.yml pins:"; cat "$work/pins-release"; return 1; }
  sed -n 's/^ *-* *uses: *//p' "$workflow" | LC_ALL=C sort -u > "$work/uses"
  [ -s "$work/uses" ] || { echo "release.yml uses no action"; return 1; }
  while IFS= read -r action; do
    printf '%s\n' "$action" | grep -Eq '^[^@ ]+@[0-9a-f]{40}$' || { echo "not pinned by a commit: $action"; return 1; }
    other=$(sed -n 's/^ *-* *uses: *//p' "$pages" | grep -F -- "${action%@*}@" | LC_ALL=C sort -u)
    [ -z "$other" ] || [ "$other" = "$action" ] || { echo "release.yml uses $action, pages.yml $other"; return 1; }
  done < "$work/uses"
}

check "release.yml runs on a bare version tag with contents: read and publishes nothing" pass -- workflow_trigger
check "release.yml runs the gate, release-check.sh and release-package.sh for each target" pass -- workflow_calls
check "release.yml pins the tools of the gate and the actions as pages.yml does" pass -- workflow_pins

# ------------------------------------------------------------------------------------------

if [ "$failed" != 0 ]; then
  echo "release: $((cases - failed)) of $cases cases pass" >&2
  exit 1
fi
echo "release: $cases of $cases cases pass"
