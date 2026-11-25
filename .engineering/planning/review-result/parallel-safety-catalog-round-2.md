---
format: aep.planning-md/3
id: review-result:parallel-safety-catalog-round-2
kind: review-result
status: active
title: parallel-safety critic on the preset catalog drafts, round 2
relations:
- reviews: epic:preset-catalog
revision: 1
---
Recorded by the coordinator from the critic's report on `epic:preset-catalog` and its four draft stories, verbatim except that absolute paths of the workstation are replaced by `<tree>` and `<scratch>`.

approve

Round-1 findings, each checked against the revised drafts:

1. **Closed.** `story:preset-catalog-functional` now has `depends_on story:changelog-release-procedure` (`aep plan artifact show story:preset-catalog-functional`, relations). The epic says `story:release-0-1-0` cuts `## [Unreleased]` "as it then stands, with or without lines of this epic" (`.engineering/planning/epic/preset-catalog.md:111-113`). The collision with the release cut is now named and accepted.
2. **Closed, with a limit.** The epic § "Order" (`:114-117`) names `Taskfile.yml` and the `AGENTS.md` ownership table as shared with `story:cli-skeleton-validate` and `story:acceptance-in-gate`. It adds the rule that a catalog story starts between two waves, from the `main` of that moment. This is a start-time rule, not an edge, so `aep plan artifact waves` will not enforce it. The rule is a person's decision, which is allowed here. It sits in the epic and not in the functional story's own Notes.
3. **Closed.** The epic (`:118-120`) says whichever of `story:cli-skeleton-validate` and the functional story lands second runs `task generate`. The functional scope records `crates/ratchet-cli-contract` as inferred (`preset-catalog-functional.md:92-94`). I named `crates/ratchet-model` in round 1, and this scope still does not. The epic rule covers any generated crate, so I do not count that as open.
4. **Closed.** `story:preset-catalog-factory` depends on `story:preset-catalog-runtime` and the notes give the reason (`preset-catalog-factory.md:65-66`). The waves are now a chain: functional (1), runtime (2), factory (3), binding resolution (4). `spec/presets.test.sh` is gone from the runtime scope, which is now `CHANGELOG.md` and `presets`.
5. **Closed.** The same factory edge and the functional edge to `story:changelog-release-procedure` cover the `CHANGELOG.md` collision.
6. **Closed.** `crates/ratchet-core` is recorded as inferred (`preset-binding-resolution.md:64`). The fixtures directory, `examples/preset-binding` and `examples/README.md` are recorded too.
7. **Closed.** `story:preset-binding-resolution` now depends on `story:preset-catalog-factory`, with the reason in its Notes (`:79-81`). The epic names the same shared files (`:105-107`).

New collisions: none. The draft-only waves listing still shows 13 `collision:` lines. All of them lie between stories of the chain, and an edge orders each pair.

Counts: 4 stories placed cited, 2 inferred surfaces (`crates/ratchet-cli-contract`, `crates/ratchet-core`), 0 unplaceable. 4 acceptance reads traced to a producer in the set, 4 recorded by an edge. One of them, the read of `ratchet validate`, is only transitive, through `story:release-0-1-0`.

What I could not establish:
- Whether the functional story's `spec/domains/*.yaml` edit changes any generated file. Its scope says "inferred", and the `task generate` rule covers it either way.
- Whether `crates/ratchet-core/tests/invariants/` needs an entry for a new invariant. Only the story's author can say.
- Out of my lane: nothing new.

```findings
[]
```
