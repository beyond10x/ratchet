#!/bin/sh
# Prose of docs/design.md and of the pages of presets/ that the specification contradicts.
#
# Written by the adversary pass of wave ahead 2: units 12 (`Condition.against`) and 27
# (`AdoptionSource` `assessment`, `RatchetPolicy.assessment`) made forms expressible that
# sentences outside their scope still call inexpressible. A step of `task check:spec`. Each
# check holds only while the specification declares the form, read from
# spec/domains/specification.yaml. On each page of presets/ it reads point 1 of "Not
# expressible yet" and the sentences of point 2 that name one measurement of a requirement.
#
# Exit 0: the last line is `design-drift: <n> of <n> sentences agree with the specification`.
# Exit 1: each sentence that disagrees is named with its file.
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
spec=$root/spec/domains/specification.yaml
checked=0
failed=0

# joined <file>: the text of the file with its line feeds as spaces, so a phrase that wraps is
# found.
joined() { tr -s '\n ' '  ' < "$1"; }

# absent <file> <phrase> <why>: the file does not state the phrase.
absent() {
  checked=$((checked + 1))
  if joined "$1" | grep -q -F -- "$2"; then
    failed=$((failed + 1))
    echo "${1#"$root"/}: states \"$2\", and $3"
  fi
}

grep -q -F 'variants: [same_change, trusted_revision, assessment]' "$spec" || {
  echo "design-drift: ratchet.specification.AdoptionSource has no variant assessment; nothing to compare"
  exit 1
}
grep -q -F 'type: Optional<ratchet.specification.MeasurementRef>' "$spec" || {
  echo "design-drift: ratchet.specification.Condition has no member against; nothing to compare"
  exit 1
}

adopt='ratchet.specification.RatchetPolicy names the plan and the measurement of `from: assessment` (story:reference-from-another-plan)'
two='ratchet.specification.Condition.against names a second measurement (story:requirement-over-two-measurements)'

absent "$root/docs/design.md" 'It has no adoption that names the plan the value comes from' "$adopt"
absent "$root/docs/design.md" 'within a preset that comparison waits for a reference from another plan' "$adopt"
absent "$root/docs/design.md" 'names what `ratchet/1` cannot say here under “Not expressible yet”: a reference adopted from the evidence of another plan, a requirement over two measurements' "$adopt; $two; and presets/functional.md marks both points answered"
for page in "$root"/presets/*.md; do
  absent "$page" '`ratchet.specification.RatchetPolicy` names no assessment' "$adopt"
  absent "$page" '`ratchet.specification.QualityRequirement` names one (' "$two"
  absent "$page" '`ratchet.specification.QualityRequirement` names one measurement' "$two"
  absent "$page" 'waits for a reference from another plan' "$adopt"
done

if [ "$failed" -gt 0 ]; then
  echo "design-drift: $((checked - failed)) of $checked sentences agree with the specification, $failed do not"
  exit 1
fi
echo "design-drift: $checked of $checked sentences agree with the specification"
