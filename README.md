# crypto_rules-image

## Introduction

Downstream repository to build an image with proprietary crypto rules from <https://github.com/scanoss/crypto_rules/>

This is being published in a private repo in <docker://quay.io/exd-guild-security/crypto-rules-image:latest>

This repository is enrolled in [Fullsend](https://fullsend.dev) for automated issue triage and implementation.

## Fullsend agents

`.github/workflows/fullsend.yaml` is a shim that forwards GitHub events to the
upstream `reusable-dispatch.yml` workflow at a pinned revision, and that pinned
revision decides which agent runs. The summary below describes the revision
pinned today (v0.54.0); re-check it against the pin after a version bump.

### What runs on a bot pull request

Renovate and MintMaker pull requests are routed the same way as any other
bot-authored pull request:

- **review** — on `opened`, `synchronize` and `ready_for_review`. A PR whose
  author login ends in `[bot]` is dispatched to review unconditionally, so
  every push to a rolling Renovate branch starts a fresh review.
- **retro** — when the PR is closed.
- **fix** — dispatched when the review agent requests changes, but it stops at
  the eligibility check for any bot other than the Fullsend coder bot unless
  the PR carries the `fullsend-fix` label.

Triage and code act on issues, not pull requests, so neither runs on a bot PR.

### Labels the dispatcher acts on

Only these labels affect routing:

- `ready-for-triage`, `ready-to-code`, `ready-for-review` — dispatch triggers.
- `fullsend-no-fix` — suppresses the bot-triggered fix agent on a PR.
- `fullsend-fix` — opts a PR in to the bot-triggered fix agent.

Any other `fullsend-*` label is inert. In particular, **there is no
label that skips review.** `renovate.json` used to add a `fullsend-skip` label
to every Renovate PR; the dispatcher never recognised it, so review ran anyway,
and the label has been removed. Per-PR review opt-out is tracked upstream in
[fullsend-ai/fullsend#7401](https://github.com/fullsend-ai/fullsend/issues/7401).

The only repo-side controls that work today are repo-wide: `kill_switch` in
`.fullsend/config.yaml` stops every agent, and an `agents` entry with
`enabled: false` in the same file turns one agent off — for human pull
requests as well as bot ones.
