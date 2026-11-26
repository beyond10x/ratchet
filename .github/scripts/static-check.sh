#!/bin/sh
# A binary is static: it names no shared library and asks for no program interpreter, so it
# runs on a host with any C library or none.
#
#   static-check.sh <binary>
#
# `readelf -d <binary>` shows no `(NEEDED)` entry, and `readelf -l <binary>` no program header
# of the type `INTERP`. A static-pie binary, which the musl target of Rust builds, has a dynamic
# section without a NEEDED entry and passes; a binary without a dynamic section passes too.
#
# Exit 0: one line, the binary is static. Exit 1: one line on standard error per NEEDED entry
# and per INTERP header, each named, or one line that names what could not be read: a call of
# readelf that fails, or one that writes a `readelf: Error:` line and exits 0. Exit 2: the
# call is wrong. Needs `readelf` (GNU binutils).
set -eu

usage() {
  echo "usage: static-check.sh <binary>" >&2
  exit 2
}

refuse() {
  echo "static-check: $binary: $1" >&2
  exit 1
}

[ $# = 1 ] || usage
binary=$1
command -v readelf > /dev/null 2>&1 || refuse "readelf is not installed"
[ -f "$binary" ] || refuse "no such file"

# GNU readelf exits 0 on a truncated file and writes `readelf: Error:` lines beside what it
# could read; such an answer is refused like a failed call.
status=0
dynamic=$(LC_ALL=C readelf -d "$binary" 2>&1) || status=$?
[ "$status" = 0 ] || refuse "readelf -d cannot read it: $(printf '%s\n' "$dynamic" | sed -n 1p)"
error=$(printf '%s\n' "$dynamic" | sed -n '/^readelf: Error:/{p;q;}')
[ -z "$error" ] || refuse "readelf -d exits 0 and reports an error: $error"
headers=$(LC_ALL=C readelf -l "$binary" 2>&1) || status=$?
[ "$status" = 0 ] || refuse "readelf -l cannot read it: $(printf '%s\n' "$headers" | sed -n 1p)"
error=$(printf '%s\n' "$headers" | sed -n '/^readelf: Error:/{p;q;}')
[ -z "$error" ] || refuse "readelf -l exits 0 and reports an error: $error"

# needed: the library of each NEEDED entry, one per line. interp: the interpreter of each
# INTERP program header, one per line, `an unnamed interpreter` when readelf names none.
needed= interp=
needed=$(printf '%s\n' "$dynamic" | awk '$2 == "(NEEDED)" { name = $0; if (match(name, /\[.*\]/)) name = substr(name, RSTART + 1, RLENGTH - 2); print name }')
interp=$(printf '%s\n' "$headers" | awk '$1 == "INTERP" { if (open) print "an unnamed interpreter"; open = 1; next } open && match($0, /\[Requesting program interpreter: .*\]/) { print substr($0, RSTART + 33, RLENGTH - 34); open = 0 } END { if (open) print "an unnamed interpreter" }')

[ -n "$needed$interp" ] || {
  echo "static-check: $binary: static, no NEEDED entry and no INTERP program header"
  exit 0
}
printf '%s\n' "$needed" | while IFS= read -r library; do
  [ -z "$library" ] || echo "static-check: $binary: needs the shared library $library (a NEEDED entry of readelf -d)" >&2
done
printf '%s\n' "$interp" | while IFS= read -r program; do
  [ -z "$program" ] || echo "static-check: $binary: asks for the program interpreter $program (an INTERP program header of readelf -l)" >&2
done
exit 1
