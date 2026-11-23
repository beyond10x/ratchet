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
