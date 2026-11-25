---
format: aep.planning-md/3
id: story:coverage-count-lower-bound
kind: story
status: draft
title: A coverage count the source does not hold is a lower bound or not known
summary: EvidenceCoverage without inventing the counts an imported report lacks.
relations:
- decomposes: epic:format-gaps-first-format-consumer
revision: 2
---
## Context

The repository `beyond10x/inference` wrote its quality definition against the formats at
commit `f139ecc` (2026-11-25): 3 `ratchet/1` files, 8 `ratchet-assessor/1` declarations and 15
`ratchet-evidence/1` records. It is the first consumer of the formats outside this repository
and of this story. Line numbers below are those of `f139ecc`.

Finding 5. An imported report states that at least 472 units ran and gives no count of
skipped or not run units. `ratchet.evidence.EvidenceCoverage` requires six integers
(`spec/domains/evidence.yaml:220-250`), and `at_least` exists on a result only. The consumer
must write a count it does not have. Its example: `"executed_at_least": 472`.

Also seen with the second quality unit of the consumer: the declaration side has the same
gap. "A count it does not report is 0 in its documents"
(`ratchet.assessor.Assessor.coverage`, `spec/domains/assessor.yaml:182-187`), so an
assessor that covers a subset of the packages and reports no `skipped` writes a 0 it did
not observe. The answer of this story covers a count the assessor does not report.

## Acceptance

A record states a coverage count as a lower bound or as not known, it decodes under the
specification, and a plan whose coverage bound needs the missing count gets insufficient
evidence with a cause that names the count; before the story the record is refused because a
required integer is absent.

## Notes

- The form shown is the consumer's proposal. The story decides the form, declares it in
  `spec/` first (`ess specify validate` passes), and writes it into `docs/design.md` or
  `docs/evidence-format.md` in the same change.
- A new value or field of a released format is an addition: a file written for the format
  before the change stays valid.
- The story is a draft. It was there before the planned waves to 0.1.0 and waits for them.
