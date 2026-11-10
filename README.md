# crypto_rules-image

## Introduction

Downstream repository to build an image with proprietary crypto rules from <https://github.com/scanoss/crypto_rules/>

This is being published in a private repo in <docker://quay.io/exd-guild-security/crypto-rules-image:latest>

This repository is enrolled in [Fullsend](https://fullsend.dev) for automated issue triage and implementation.

## Fullsend agents

`.github/workflows/fullsend.yaml` is a shim that forwards GitHub events to the
upstream `reusable-dispatch.yml` workflow at a pinned revision, and that pinned
revision decides which agent runs. The summary below describes the revision
pinned today, `90b7310` (v0.54.0); re-check it against the pin after a version
bump, and treat it as stale if the pinned SHA in the shim no longer matches.

### What runs on a bot pull request

Renovate and MintMaker pull requests are routed the same way as any other
bot-authored pull request:

- **review** — on `opened`, `synchronize` and `ready_for_review`. A pull
  request whose author login ends in `[bot]` is dispatched to review
  unconditionally, so every push to a rolling Renovate branch starts a fresh
  review.
- **retro** — when the pull request is closed.
- **fix** — dispatched when the review agent requests changes, but it stops at
  the eligibility check for any bot other than the Fullsend coder bot unless
  the pull request carries the `fullsend-fix` label.

### Slash commands on a pull request

A `/fs-*` comment posted by a bot is always ignored. `/fs-code` is the only
command the dispatcher guards so that it never runs on a pull request; the
rest are available on one, subject to the commenter's permission:

| Command | On a pull request? | Commenter needs |
| --- | --- | --- |
| `/fs-review` | yes | triage or higher |
| `/fs-fix` | yes | write or higher |
| `/fs-triage` | yes — not restricted to issues | triage or higher |
| `/fs-retro` | yes — not restricted to issues | write or higher |
| `/fs-prioritize` | yes — not restricted to issues | write or higher |
| `/fs-code` | no — issues only | write or higher |
| `/fs-fix-stop` | yes | write or higher, or the pull request author |

`/fs-fix-stop` is the one command above the upstream dispatcher does not
handle. The `stop-fix` job in this repo's own
`.github/workflows/fullsend.yaml` answers it: the comment body must be
exactly `/fs-fix-stop`, and the job adds the `fullsend-no-fix` label
described below.

### Labels the dispatcher acts on

Only these labels affect routing:

- `ready-for-triage`, `ready-to-code`, `ready-for-review` — dispatch triggers.
- `fullsend-no-fix` — suppresses the bot-triggered fix agent on a pull
  request. Commenting `/fs-fix-stop` adds it; it can also be added by hand.
- `fullsend-fix` — opts a pull request in to the bot-triggered fix agent. On a
  human-authored pull request the author must also hold write access; the
  label on its own is not enough there.

Any other `fullsend-*` label is inert. In particular, **there is no
label that skips review.** `renovate.json` used to add a `fullsend-skip` label
to every Renovate pull request; the dispatcher never recognised it, so review
ran anyway, and the label has been removed. Label-based review skip is
tracked upstream in
[fullsend-ai/fullsend#7401](https://github.com/fullsend-ai/fullsend/issues/7401).

### Repo-side controls

None of the controls below is enabled in this repository. Neither issue #40
nor its triage recommended turning review off on bot pull requests — they are
recorded here so that a maintainer who revisits the question can see the
mechanisms and their trade-offs without diffing the upstream workflow.

Two controls in `.fullsend/config.yaml` are repo-wide:

- `kill_switch` stops every agent.
- An `agents` entry with `enabled: false` turns one agent off — for human pull
  requests as well as bot ones. The entry must also carry a `name` matching the
  agent/stage name (`review`, `fix`, `triage`, `code`, `retro`, `prioritize`);
  a disabled entry without a `name` fails the dispatcher's config validation
  and blocks dispatch entirely. This repo's `.fullsend/config.yaml` has no
  `agents:` key yet, so the block would have to be added:

  ```yaml
  agents:
    - name: review
      enabled: false
  ```

A third control decides per event rather than repo-wide: a CEL `trigger:`
expression on the `review` entry in `.fullsend/config.yaml`
([fullsend-ai/fullsend#8726](https://github.com/fullsend-ai/fullsend/issues/8726)),
available at the pinned revision. It is evaluated against each event and can
keep review off bot pull requests while leaving it on for human ones.

A trigger is not a drop-in narrowing of the default rules: it replaces them
for review, so an expression that does not match a route described above
(the `ready-for-review` label, a `/fs-review` comment) silently turns that
route off, and it changes how fix-agent pushes, fork pull requests and
sender-versus-author identity are handled. Note also that the two failure
modes differ — a failing `cel-*` step (config checkout, CLI install, an
expression that does not compile) leaves the default route in place and
review still runs, but an expression that compiles and then fails to
evaluate against the event returns a `skip`, which clears the stage so
review does **not** run. Consult the upstream CEL trigger reference at the
pinned revision and validate any expression against every event it must
cover before relying on it.
