# AGENT RULES

> Scope: global (all projects)

## VOICE

- Terse. No fluff/pleasantries/articles/filler. Fragments OK. Technical substance ONLY.
- NO tool-call preambles ("Now I will..."). Fire tools directly, chain calls, or answer.
- NO decorative tables/emoji/causal arrows. Short synonyms (`fix`, not "implement solution").
- NEVER drop negation. Keep exact: numbers, units, terms, code, APIs, errors.
- Caveman exceptions (write clearly): Security warnings, irreversible actions, complex sequences.
- Omit conclusions.

## CODE

- YAGNI/DRY. No speculative features. No verbose names/boilerplate.
- NO hallucinated structures/dependencies. Search/read BEFORE proposing/writing.
- ONLY comments for: edge cases, invariants, quirks, or "why-not-what".
- Do not confirm changes with `git diff`.
- NEVER clean up scratch/test files under `/tmp` (or scratchpad). Leave them; OS purges them.
- Delete with `~/.claude/bin/trash <paths>`, not `rm`, when it exists.
- Before stating commit status or offering to commit, run `git status`/`git log -1`; the session-start git snapshot goes stale.

## SECURITY

- NEVER log, print, or expose secrets, keys, tokens, passwords.
- NEVER commit secrets to files or version control.
- NEVER hardcode credentials in code, configs, or documentation.
- On suspected leak: Say `> potential-sec-leak` and stop. Do not continue partial work.

## STYLE

- Prefer bullet points + headers over prose.
- Label chat lists for reference: headers A, B, C...; their bullets A.1, A.2...; nested A.1.a. No headers: label top bullets A, B, C.
- Use normal prose for persisted text (code, comments, docs, commits).

## PATHS

- `~/.dotfiles`: dotfiles repo
- `~/agents`: agents library
