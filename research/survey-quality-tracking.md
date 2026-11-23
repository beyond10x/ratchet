# Survey: how does your project track quality?

Asked by the `ratchet` repository (design phase). Ratchet will be a format and a CLI for declaring
what quality means for a project, measuring it, and refusing regressions. Before designing it
further we want to know how projects track quality today, where that hurts, and how they would
describe quality in plain words.

## How to answer

- Answer for the repository, project or product you work in. If you work in several, answer for
  the one you know best and say so in A1.
- Answer from what is in the repository and what you have run or seen in this session. Cite a
  `file:line`, a command and its output, or a CI job name where you can. Write "I don't know"
  rather than guess.
- Label each claim **seen** (you read or ran it) or **inferred**.
- Short answers. Bullets. Numbers over adjectives.
- 15 minutes at most. Skip a question that does not apply and write "n/a".
- **Confidentiality.** If your project is not a beyond10x repository, it is internal company work:
  do not name the company, customers, the product, teams, people, hosts, URLs, ticket keys,
  repository paths or internal tools. Describe it by kind and stack only ("backend service, Go";
  "web front end, Vue"). Your answer is published in a public repository.

## A. The project

- **A1.** What kind of project is it? Kind (library, CLI, backend service, front end, platform,
  infrastructure, docs site, other), main languages, rough size (files or lines), and who uses it
  (end users, developers, other services, coding agents).
- **A2.** What is its product scope in one or two sentences: what does it do for whom?
- **A3.** Who works on it: people, agent sessions, both? How many commits or merged changes in a
  typical week, if you can tell?

## B. What you track today

For each area, list what is measured or checked, where (local gate, CI, after deploy, production),
and whether it blocks anything. Write "nothing" if nothing.

- **B1. Code and repository**: tests, coverage, lint, static analysis, security scans, dependency
  count or age, complexity, build warnings, generated files in sync, docs build.
- **B2. Development process**: build time (clean, incremental), test step time, gate time, flaky
  tests, time an agent or person waits for a verdict.
- **B3. Delivery process**: CI duration, time to first failing signal, merge queue wait, release
  frequency, lead time from commit to release, failed or rolled-back releases.
- **B4. Product**: functional behaviour (scenarios, conformance, end-to-end), performance (latency,
  throughput, size), accessibility, UI or visual checks, errors in production, SLOs, user-facing
  incidents.
- **B5.** Which of these have a **threshold**? For each: the value, where it is written, and what
  happens when it is crossed.
- **B6.** Which compare against a **baseline** (a previous run, `main`, an accepted value) rather
  than a fixed number? How is the baseline stored and updated?
- **B7.** Is anything recorded **over time** (history, trend, dashboard)? Where?

## C. What went wrong

- **C1.** The last regression that reached `main`, a release or users: what got worse, how it was
  noticed, how long after the change, and which check could have caught it.
- **C2.** A check that went red when nothing was wrong (flaky, noisy, environment-dependent): which
  one and how often.
- **C3.** A rule or threshold that was loosened to get a change through (a raised timeout, a skipped
  test, an allowlist entry, a raised limit). Was it ever tightened again?

## D. Friction

- **D1.** What costs you the most time when dealing with quality checks today? One or two items,
  with a number if you have one (minutes per run, runs per day, hours lost).
- **D2.** What do you know about this project's quality that no check records? Where does that
  knowledge live (a person, an `AGENTS.md` rule, a review habit, nowhere)?
- **D3.** Which check do you not trust, and why?
- **D4.** If you track little or nothing: why? (No time, no tool fits, not needed yet, nobody asked,
  other.)

## E. Quality in plain words

- **E1.** In three to five plain sentences: what does "good quality" mean for this project? Say it
  as you would to a new team member, without tool names.
- **E2.** Which of those sentences could be checked by a machine today, which could be with work,
  and which never?
- **E3.** For each audience that matters (end users, developers, coding agents, operators,
  consumers of an API), name one thing that would make them say quality got worse.
- **E4.** If you could add one enforced rule tomorrow that stops quality from getting worse, what
  would it be? Write it as one line: what is measured, the limit or comparison, and when it is
  checked.

## Answer template

Copy this, fill it in, and return it.

```markdown
# Response: <repository name, or ext-?? for non-beyond10x work>

- kind and stack: <generic description>
- answered by: <session role, not a person>
- date: <YYYY-MM-DD>

## A. The project
A1:
A2:
A3:

## B. What you track today
B1:
B2:
B3:
B4:
B5:
B6:
B7:

## C. What went wrong
C1:
C2:
C3:

## D. Friction
D1:
D2:
D3:
D4:

## E. Quality in plain words
E1:
E2:
E3:
E4:
```
