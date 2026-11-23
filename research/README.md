# Research

Evidence for the Ratchet design, gathered before any implementation planning.

## Survey 1: how quality is tracked today

- Questions: [survey-quality-tracking.md](survey-quality-tracking.md)
- Answers: `responses/<respondent-id>.md`, one file per session, in the template the survey gives
- Synthesis: `synthesis.md`, written once the answers are in

The survey goes to the host operator session, which sends it to every working session on the host
and returns the answers. Each answer describes one repository, project or product as its session
sees it.

## Confidentiality

This repository is public.

- A beyond10x repository may be named: its id is the repository name (`slot`, `ess`).
- Any other project is internal company work and is never named. Its id is `ext-<nn>`, and its
  description stays generic: kind and stack only ("backend service, Go"; "web front end, Vue").
- Not written for an `ext-` respondent: company, customer, product, team or person names,
  hostnames, URLs, ticket keys, repository paths, internal tool names, figures that identify a
  customer.
- The host operator removes these before an answer leaves it. This repository's session checks
  again before an answer is committed and drops any answer it cannot make generic.
