# Response: ext-01

- kind and stack: backend service, Go, event-sourced, with a key-value store and a message bus; deployed on a container orchestrator
- answered by: a requirements-extraction session reading this service for a clean-room rewrite (read-only; I did not run its gates)
- date: 2026-11-23

## A. The project
A1: Backend service, Go. About 430 source files (seen: file count). Its users are other services: one main backend sends it requests and gets answers back, one web front end reads a metrics stream, and an operator reads health endpoints (seen).
A2: It queues incoming work items per tenant and hands each one to one available worker by eligibility and priority rules, then reports the outcome back to the caller (seen).
A3: Both people and agent sessions (seen: agent docs, wave branches). About 150 commits in 5 weeks, so roughly 30 a week (seen: `git rev-list --count` between two refs).

## B. What you track today
B1: Unit and integration tests, an end-to-end suite and a conformance suite generated from an executable specification. Coverage output is committed in the repository (seen: a coverage file at the root). I don't know about lint, security or dependency checks in CI. Overall that is about 900 test scenarios (seen: catalogue built by a reader).
B2: I don't know.
B3: About 5 minor releases in 5 weeks (seen: tags). Production runs the last tag, while main is 12 commits ahead (seen). I don't know the CI duration or lead time.
B4: The conformance reports are committed per storage backend (seen). The service has liveness and readiness endpoints, but the deployment chart wires no probes (seen). Alert rules exist on 6 service metrics (seen). There is no SLO document (seen: none found).
B5: I don't know of any threshold. The conformance reports have pass counts but no gate (inferred).
B6: Nothing (inferred).
B7: Metrics dashboards exist (inferred from the alert rules). Nothing in the repository records a trend.

## C. What went wrong
C1: A resource leak grew until the process was killed for exceeding its memory limit. With one replica, every kill was a full outage. It was noticed in production from user impact, several days after the change (seen: an incident doc). A soak test, or an alert on goroutine or memory growth, could have caught it. The fix was not verified in production (seen).
C2: I don't know.
C3: The container memory limit was raised to stop the kills (seen). I don't know whether it was lowered again.

## D. Friction
D1: Docs and code disagree on the wire contract: a time unit (seconds in docs, milliseconds in code) and several status codes (seen). A reader cannot tell which is right without reading the consumer's code.
D2: The undocumented answers the main consumer branches on, for example a conflict code it treats as "stop retrying", live only in the consumer's code (seen). Neither repository has a check for them.
D3: The conformance suite. 18 of 50 matching scenarios fail on every backend, and nothing records which ones or why (seen). So a green or red run says little.
D4: n/a

## E. Quality in plain words
E1: Every accepted work item reaches exactly one worker or a clear end state, never zero and never two. Answers to the main consumer do not change their meaning between releases. Losing one instance does not lose accepted work and does not stop service for long. An operator can tell from outside whether the service is healthy. The docs describe what the code does.
E2: A machine can check today: one item to one worker (scenario tests). A machine can check with work: answer stability (a consumer-driven contract test), instance loss (a fault-injection test in CI), docs matching code (generate the docs from the contract). The operator view can be checked partly.
E3: Main backend: an answer code or unit changes, or a duplicate request is treated differently. Front end: the metrics stream drops a field or a window. Operators: a restart loses queued work, or health says OK while routing is stuck. Coding agents: docs that contradict the code. End users (indirectly): callers wait longer, or work goes to the wrong worker.
E4: Every answer the main consumer branches on (status class, codes, fields, units) is pinned by a contract test that runs in CI on each merge request, and any change to one fails the merge.
