# Consumer input: ux-ui (2026-11-23)

Sent by the session working on the beyond10x `ux-ui` repository, after survey 1. Recorded as
sent; it is design input, not a decision.

## Offer

`ux-ui` is being specified (ESS specification and docs) as a UX layer on Ratchet, not a second
ratchet: a UX search engine that generates design variants of an `ess-ui/1` document, evaluates
them with no I/O over the UI state space, and emits Ratchet evidence. It offers to be the first
consumer of the "ESS UI behavior" integration (`docs/design.md` § 7), with a preset family
`web-ux@1` (draft planned at `presets/web-ux.ratchet.yaml` in that repository) and an assessor
`ux-eval@1`.

## Four gaps from a real round (R-01 in that repository)

1. **Trade-offs.** An in-page navigation cut moved one value from 23 to 0 but made 20 of 168
   values worse (one extra click per task, 12 Tab stops). Per-requirement references can only
   pass it by a decision. Proposal: a declared trade-off (a requirement group or Pareto set), or
   a reference change that names the gain it buys.
2. **Result scope.** A page-level result (an accessibility rule) was summed per journey, so one
   defect counted 12 times. Measurements need a scope (state, journey, page, variant) and an
   aggregation that respects it.
3. **Noisy vs exact.** Exact counts and modelled metrics are deterministic; wall-clock ones need a
   median of N runs and a sample count. Keep the two kinds apart in the format.
4. **Finding identity for UI.** Rule id + `ess-ui` node path + environment (viewport, theme, input
   mode), for "no new findings".

## Second input: gaps from the first assessor (2026-11-24)

The repository, now named `uxui`, built its first assessor `ux-static@1` against the draft
(design § 3 example, § 6 assessment run). It writes evidence in the draft's shape on its branch
`ux-static` (`docs/ux-static.md` there; not pushed at the time of writing). Writing it hit nine
gaps. Status is against design revision 4.

| # | Gap | What `uxui` did meanwhile | Status in revision 4 |
| --- | --- | --- | --- |
| U1 | No evidence document schema and no format name | Format `ratchet-evidence/draft` with field names of its own | Open. The assessment run is an entity in `spec/`; no serialized evidence format is named or projected from it yet. |
| U2 | No target kind for a design variant or a document | Target kind `ui-variant` | In part. "Design variant" is a scope (§ 1, § 3); no target kind names it. |
| U3 | Coverage counts only passed and failed; no W3C ACT `cantTell` or `inapplicable` | `cantTell` counted as unsupported, record made insufficient | Open. `executed`, `skipped`, `unsupported` and `not_run` exist; a rule outcome of "cannot tell" or "inapplicable" has no mapping. |
| U4 | No field for findings and their identity | `findings: [{rule, node_path}]` | In part. Identity sets with an identity key and items `{identity, reason?, owner?}` (G28, § 3); no findings list on the evidence of a run. |
| U5 | No vocabulary for insufficient causes | `insufficient.cause`: coverage, input, declaration | Closed in the design. § 5 lists 13 causes (`coverage_below_plan`, `not_assessable_here`, `incompatible_target`, ...). The assessor's three map onto them; the mapping is not written down. |
| U6 | No way to say "at least N failed" | `value_at_least` | Open. A value is exact or sampled; a lower bound from a run that stopped early is neither. |
| U7 | A measurement has no direction | none | Closed. `better: lower` or `better: higher` (revision 3, § 3). |
| U8 | § 6 asks for timestamps, which break byte-identical evidence for identical inputs | Timestamps left out | Open. § 6 lists "timestamps or window bounds"; it does not say whether they sit outside the digested part. |
| U9 | The document digest is over file bytes; ESS has no canonical form | Digest over bytes | Open, and depends on ESS (filed there). |

U3 to U6 touch the four gaps of the first input above (trade-offs, result scope, exact vs
sampled, finding identity). `uxui` asked for no answer now; these go into the format when it
settles.
