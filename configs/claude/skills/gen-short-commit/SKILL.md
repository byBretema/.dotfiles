---
name: gen-short-commit
description: Generate a one-line commit message summarizing the current git changes, in the form "type: change 1 / change 2 / change 3". Use when the user asks for a short commit message or commit line.
allowed-tools: Bash(git status:*) Bash(git diff:*) Bash(git log:*)
---

# Generate a short commit message

## Changes

Staged files:
!`git diff --cached --stat`

Unstaged and untracked files:
!`git status --short`

## Instructions

1. Use the staged diff if anything is staged; otherwise use all uncommitted changes, untracked files included.
2. Read the actual diff (`git diff --cached` or `git diff`, and the untracked files) before writing. Do not guess from file names.
3. Output exactly one line, nothing before or after it:

   `type: change 1 / change 2 / change 3`

   - `type` is one of `feat`, `fix`, `refactor`, `perf`, `docs`, `style`, `test`, `build`, `ci`, `chore`. Pick the one that fits the most significant change.
   - Each change is a short lowercase phrase naming what changed and where (e.g. `tmux native regex search`, `helix 4-space json`). No trailing period.
   - Order changes by importance. Merge related edits into one change; omit trivial ones (whitespace, comment typos) unless they are the only change.
   - Keep the whole line under about 100 characters when possible.
4. Do not commit, stage, or modify anything. Only print the line.
5. If there are no changes, say so in one line.
