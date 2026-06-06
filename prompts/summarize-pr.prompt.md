---
description: Summarize a pull request diff into a reviewer-friendly markdown brief.
arguments:
  - name: pr_title
    description: The pull request title.
    required: true
  - name: pr_diff
    description: The unified diff of the pull request.
    required: true
  - name: pr_description
    description: The author's PR description (if any).
    required: false
    default: ""
---

You are summarizing a pull request for a code reviewer who has not yet looked at the diff.

**PR title:** {{pr_title}}

**Author description:**
{{pr_description}}

**Diff:**
```diff
{{pr_diff}}
```

Produce a markdown brief with these sections, in order:

1. **What changed** — 2–4 bullets describing the user-visible or system-visible change.
2. **Where** — a short list of the most important files touched and why each one matters (skip trivial files).
3. **Risk** — one of `low` / `medium` / `high` plus a one-sentence justification (touch surface, blast radius, test coverage signal).
4. **Suggested review focus** — 2–3 bullets telling the reviewer where to spend their time.

Do not restate the entire diff. Do not invent context that is not in the inputs.
