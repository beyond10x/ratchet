#!/bin/sh
# The coverage a `ratchet` command reports holds every member of the coverage an assessment run
# records: each field of `ratchet.evidence.EvidenceCoverage` (spec/domains/evidence.yaml) is a
# field of `ratchet.cli.CoverageRow` (spec/domains/cli.yaml), under the same name.
#
# `CoverageRow` stands in for `EvidenceCoverage` in `ratchet.cli.RunSummary.coverage` (the result
# of `ratchet assess`) and `ratchet.cli.VerdictRow.coverage` (the gate report), because ess-cli
# refuses a struct with invariants in a payload. A member the row lacks is a member no command
# reports.
#
# Exit 0: the last line is `cli-coverage-row: <n> of <n> coverage fields reported`.
# Exit 1: a field is not reported (each is named), or one of the two types has no field.
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
evidence=$root/spec/domains/evidence.yaml
cli=$root/spec/domains/cli.yaml

for f in "$evidence" "$cli"; do
  [ -r "$f" ] || { echo "cli-coverage-row: cannot read ${f#"$root"/}" >&2; exit 1; }
done

awk '
  /^  - name: / { type = $3; in_fields = 0; next }
  /^    fields:/ { in_fields = 1; next }
  /^    [a-z_]+:/ { in_fields = 0; next }
  in_fields && /^      - name: / {
    if (type == "ratchet.evidence.EvidenceCoverage") { recorded[++n] = $3 }
    if (type == "ratchet.cli.CoverageRow") { reported[$3] = 1; m++ }
  }
  END {
    if (n == 0) { print "cli-coverage-row: ratchet.evidence.EvidenceCoverage has no field"; exit 1 }
    if (m == 0) { print "cli-coverage-row: ratchet.cli.CoverageRow has no field"; exit 1 }
    for (i = 1; i <= n; i++) {
      if (!(recorded[i] in reported)) {
        printf "missing: ratchet.evidence.EvidenceCoverage.%s is not a field of ratchet.cli.CoverageRow\n", recorded[i]
        missing++
      }
    }
    if (missing > 0) {
      printf "cli-coverage-row: %d of %d coverage fields reported, %d missing\n", n - missing, n, missing
      exit 1
    }
    printf "cli-coverage-row: %d of %d coverage fields reported\n", n, n
  }
' "$evidence" "$cli"
