#!/bin/sh
# The scripts of `task check:spec` refuse a broken input that an edit of the form hides.
#
# Each script finds what it reads by a form: spec/record-fields.test.sh and
# spec/record-types.test.sh by the number of a section (`## 3. `, `## 10. `) and the header
# `| Field | Type | Required |`; spec/record-examples.test.sh by the fence ```json in § 6;
# spec/contract-examples.test.sh by the fence ```yaml in § 10; spec/cli-coverage-row.test.sh by
# the names of two structs; spec/cli-errors.test.sh by the words of a row of docs/design.md.
# A table, a section or an example that an edit moves out of that form is no longer read. Each
# script therefore states how much it reads, and this script holds them to it.
#
# Each case below is a copy of spec/, docs/evidence-format.md and docs/design.md under the
# ignored target/gate-inputs/<case>, with one hidden defect. The scripts run on the copy, and
# the case holds when at least one of them exits non-zero, as the gate then does. The unchanged
# copy runs first and has to pass all of them.
#
# Exit 0: the last line is `gate-inputs: <n> of <n> broken inputs refused`.
# Exit 1: each case that every script accepts is named with the last line of each script.
# Needs `jq`, as spec/record-examples.test.sh does.
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
work=$root/target/gate-inputs
scripts="record-fields record-types record-examples contract-examples cli-coverage-row cli-errors"

command -v jq > /dev/null 2>&1 || { echo "gate-inputs: jq is not installed" >&2; exit 1; }
for s in $scripts; do
  [ -r "$root/spec/$s.test.sh" ] || { echo "gate-inputs: cannot read spec/$s.test.sh" >&2; exit 1; }
done

rm -rf "$work"
mkdir -p "$work"

# copy <case>: a fresh copy; sets $c, $doc, $cli, $assessor, $binding.
copy() {
  c=$work/$1
  mkdir -p "$c/docs"
  cp -R "$root/spec" "$c/spec"
  cp "$root/docs/evidence-format.md" "$root/docs/design.md" "$c/docs/"
  doc=$c/docs/evidence-format.md
  cli=$c/spec/domains/cli.yaml
  assessor=$c/spec/domains/assessor.yaml
  binding=$c/spec/cli.yaml
}

# edit <file> <awk program>: an edit that has to change the file.
edit() {
  awk "$2" "$1" > "$1.new"
  if cmp -s "$1" "$1.new"; then
    echo "gate-inputs: the edit of case $(basename -- "$c") changes nothing in $(basename -- "$1")" >&2
    exit 1
  fi
  mv "$1.new" "$1"
}

# run_all: the scripts on the copy; sets $failing to the number that exit non-zero.
run_all() {
  failing=0
  for s in $scripts; do
    if sh "$c/spec/$s.test.sh" > "$c/$s.out" 2>&1; then :; else failing=$((failing + 1)); fi
  done
}

cases=0
accepted=0

# expect_refused <what the copy hides>
expect_refused() {
  cases=$((cases + 1))
  run_all
  if [ "$failing" -eq 0 ]; then
    accepted=$((accepted + 1))
    echo "accepted: $(basename -- "$c"): $1"
    for s in $scripts; do echo "  $(tail -n 1 "$c/$s.out")"; done
  fi
}

copy unchanged
run_all
if [ "$failing" -ne 0 ]; then
  echo "gate-inputs: the unchanged copy fails $failing script(s); run task check:spec first"
  for s in $scripts; do echo "  $(tail -n 1 "$c/$s.out")"; done
  exit 1
fi

copy section-renumbered
edit "$doc" '
  /^## 11\. / { sub(/^## 11\. /, "## 12. ") }
  /^## 10\. / { sub(/^## 10\. /, "## 11. ") }
  /^\| `identity_key` \| / { sub(/`identity_key`/, "`identity_keys`") }
  { print }'
expect_refused "the assessor contract is § 11 and its row \`identity_keys\` is no declared field"

copy table-header
edit "$doc" '
  /^An output, / { f = 1 }
  f && /^\| Field \| Type \| Required \|/ { sub(/^\| Field /, "| Member "); f = 0 }
  /^\| `kind` \| text \| yes \| `exact` or `sampled` \| spec: `AssessorOutput.kind`/ { sub(/`kind`/, "`kinds`") }
  { print }'
expect_refused "the header of the output table of § 10 starts \`| Member |\` and its row \`kinds\` is no declared field"

copy table-emptied
edit "$doc" '
  /^An output, / { f = 1 }
  f && /^\| `/ { next }
  f && /^The declaration of/ { f = 0 }
  { print }'
expect_refused "the output table of § 10 keeps its header and holds no row"

copy example-fence
edit "$doc" '
  /^## / { s = ($0 ~ /^## 6\. /) }
  s && !done && /^```json$/ { print "```jsonc"; done = 1; first = 1; next }
  first && /^```$/ { first = 0 }
  first { sub(/"candidate":/, "\"candidat\":") }
  { print }'
expect_refused "the first example of § 6 is fenced \`jsonc\` and holds the member \`candidat\`"

copy examples-deleted
edit "$doc" '
  /^## / { s = ($0 ~ /^## 6\. /) }
  s && /^```json$/ { n++ }
  s && n >= 2 && (/^```/ || inside) { if (/^```json$/) inside = 1; else if (/^```$/) inside = 0; next }
  { print }'
expect_refused "§ 6 holds one example, the second and the third are deleted"

copy contract-example
edit "$assessor" '
  /^      - name: identity_key$/ { sub(/identity_key/, "key_fields") }
  { gsub(/defined\(identity_key\)/, "defined(key_fields)"); print }'
edit "$doc" '
  /^\| `identity_key` \| list of text/ { sub(/`identity_key`/, "`key_fields`") }
  { print }'
expect_refused "\`identity_key\` is \`key_fields\` in the specification and in its row, and the YAML example of § 10 still writes \`identity_key\`"

copy contract-example-fence
edit "$doc" '
  /^## / { s = ($0 ~ /^## 10\. /) }
  s && !done && /^```yaml$/ { print "```yml"; done = 1; first = 1; next }
  first && /^```$/ { first = 0 }
  first { sub(/^target_input:/, "target_inputs:") }
  { print }'
expect_refused "the first example of § 10 is fenced \`yml\` and holds the key \`target_inputs\`"

copy row-type
edit "$cli" '
  /^  - name: / { t = $3; f = 0 }
  t == "ratchet.cli.CoverageRow" && $0 == "      - name: not_executed" { f = 1 }
  f && /^        type: / { print "        type: Optional<List<String>>"; f = 0; next }
  { print }'
expect_refused "CoverageRow.not_executed is a list of text, and EvidenceCoverage.not_executed a list of units"

copy row-unused
edit "$cli" '
  /^  - name: ratchet.cli.CoverageRow$/ {
    print "  - name: ratchet.cli.CoverageCounts"
    print "    kind: struct"
    print "    naming:"
    print "      summary: The counts of a run."
    print "    fields:"
    print "      - name: unit"
    print "        type: ratchet.assessor.CoverageUnit"
    n = split("executed skipped not_run unsupported passed failed", k, " ")
    for (i = 1; i <= n; i++) { print "      - name: " k[i]; print "        type: Integer" }
    print ""
  }
  { sub(/type: ratchet\.cli\.CoverageRow$/, "type: ratchet.cli.CoverageCounts")
    sub(/type: Optional<ratchet\.cli\.CoverageRow>$/, "type: Optional<ratchet.cli.CoverageCounts>")
    print }'
expect_refused "RunSummary.coverage and VerdictRow.coverage are a struct without the two lists, and CoverageRow is used nowhere"

copy binding-error
edit "$binding" '
  /^      candidate_unresolved: ratchet\.cli\.Refusal$/ { next }
  { print }'
expect_refused "\`candidate_unresolved\` is no error of \`assess\` in spec/cli.yaml, and docs/design.md § 5 names it"

if [ "$accepted" -gt 0 ]; then
  echo "gate-inputs: $((cases - accepted)) of $cases broken inputs refused, $accepted accepted"
  exit 1
fi
echo "gate-inputs: $cases of $cases broken inputs refused"
