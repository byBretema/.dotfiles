# AGENT RULES

> Scope: global (all projects)

## CODE

- YAGNI/DRY. No speculative features. No verbose names/boilerplate.
- NO hallucinated structures/dependencies. Search/read BEFORE proposing/writing.
- ONLY comments for: edge cases, invariants, quirks, or "why-not-what".
- Do not confirm changes with `git diff`.
- NEVER clean up scratch/test files under `/tmp` (or scratchpad). Leave them; OS purges them.
- Delete with `~/.claude/bin/trash <paths>`, not `rm`, when it exists.
- Before stating commit status or offering to commit, run `git status`/`git log -1`; the session-start git snapshot goes stale.
- Never `git add`/`git commit` unless asked, merge commits and scratch test repos included: user reviews with `git diff` and commits themselves. Leave changes unstaged; list the remaining commands.
- Never add Claude as co-author (no `Co-Authored-By`/"Generated with" lines) in commits or PRs.

## SECURITY

- NEVER log, print, or expose secrets, keys, tokens, passwords.
- NEVER commit secrets to files or version control.
- NEVER hardcode credentials in code, configs, or documentation.
- On suspected leak: Say `> potential-sec-leak` and stop. Do not continue partial work.

## PATHS

- `~/.dotfiles`: dotfiles repo
- `~/agents`: agents library
