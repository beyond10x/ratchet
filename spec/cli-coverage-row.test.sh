#!/bin/sh
# The coverage a `ratchet` command reports holds every member of the coverage an assessment run
# records: each field of `ratchet.evidence.EvidenceCoverage` (spec/domains/evidence.yaml) is a
# field of `ratchet.cli.CoverageRow` (spec/domains/cli.yaml), under the same name and with the
# same type, and the two places a command reports coverage are typed with that row.
#
# `CoverageRow` stands in for `EvidenceCoverage` in `ratchet.cli.RunSummary.coverage` (the result
# of `ratchet assess`) and `ratchet.cli.VerdictRow.coverage` (the gate report), because ess-cli
# refuses a struct with invariants in a payload. A member the row lacks, or holds with another
# type, is a member no command reports as the run recorded it; and a row that neither place uses
# reports nothing.
#
# Exit 0: the last line is
#   `cli-coverage-row: <n> of <n> coverage fields reported with their type, in 2 of 2 places`.
# Exit 1: a field is not reported or has another type (each is named), one of the two types has
# no field, or `RunSummary.coverage` or `VerdictRow.coverage` is not a `ratchet.cli.CoverageRow`.
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
evidence=$root/spec/domains/evidence.yaml
cli=$root/spec/domains/cli.yaml

for f in "$evidence" "$cli"; do
  [ -r "$f" ] || { echo "cli-coverage-row: cannot read ${f#"$root"/}" >&2; exit 1; }
done

awk '
  function unopt(t) { return (t ~ /^Optional</) ? substr(t, 10, length(t) - 10) : t }

  BEGIN {
    # The places a command reports the coverage of a run.
    users[1] = "ratchet.cli.RunSummary"
    users[2] = "ratchet.cli.VerdictRow"
    nusers = 2
  }

  /^  - name: / { type = $3; in_fields = 0; field = ""; next }
  /^    fields:/ { in_fields = 1; next }
  /^    [a-z_]+:/ { in_fields = 0; next }
  in_fields && /^      - name: / {
    field = $3
    if (type == "ratchet.evidence.EvidenceCoverage") { recorded[++n] = field }
    if (type == "ratchet.cli.CoverageRow") { reported[field] = 1; m++ }
    next
  }
  in_fields && field != "" && /^        type: / {
    t = $0; sub(/^        type: /, "", t)
    ftype[type SUBSEP field] = t
  }

  END {
    if (n == 0) { print "cli-coverage-row: ratchet.evidence.EvidenceCoverage has no field"; exit 1 }
    if (m == 0) { print "cli-coverage-row: ratchet.cli.CoverageRow has no field"; exit 1 }
    for (i = 1; i <= n; i++) {
      f = recorded[i]
      if (!(f in reported)) {
        printf "missing: ratchet.evidence.EvidenceCoverage.%s is not a field of ratchet.cli.CoverageRow\n", f
        missing++
        continue
      }
      want = ftype["ratchet.evidence.EvidenceCoverage" SUBSEP f]
      got = ftype["ratchet.cli.CoverageRow" SUBSEP f]
      if (want == "" || got != want) {
        printf "type: ratchet.evidence.EvidenceCoverage.%s is `%s` and ratchet.cli.CoverageRow.%s is `%s`\n", f, want, f, got
        missing++
      }
    }
    for (i = 1; i <= nusers; i++) {
      got = ftype[users[i] SUBSEP "coverage"]
      if (unopt(got) != "ratchet.cli.CoverageRow") {
        printf "not used: %s.coverage is `%s`, not a ratchet.cli.CoverageRow\n", users[i], (got == "" ? "not declared" : got)
        unused++
      }
    }
    if (missing > 0 || unused > 0) {
      printf "cli-coverage-row: %d of %d coverage fields reported with their type, in %d of %d places\n", n - missing, n, nusers - unused, nusers
      exit 1
    }
    printf "cli-coverage-row: %d of %d coverage fields reported with their type, in %d of %d places\n", n, n, nusers, nusers
  }
' "$evidence" "$cli"
