---
name: ticket
description: Plan, implement, iterate and commit one ticket.
argument-hint: <ticket text or link> [--map | --map-visual] | resume <slug>
disable-model-invocation: true
---

# Ticket workflow

Ticket: $ARGUMENTS. Skip steps that don't fit; say which and why.

State file: `~/agents/<project>/tasks/<slug>.md`, in the same format as the existing ones (Status, Pending, Done, Current Rules, Key Files, Tests). Link it under `## Tasks` in `~/agents/<project>/AGENTS.md`.
Write to it as soon as something is decided, not at the end. On `resume`, read it first and continue from Pending.

## 1. Map (only with --map or --map-visual; omi defaults to --map)

Mermaid diagram of the modules/files/functions the ticket touches and how they connect. Read the code before drawing.
Copy `map.html` from this skill's base directory to `~/agents/<project>/tasks/<slug>.map.html` and replace `__TITLE__` with the ticket title and `__MERMAID__` with the diagram.
- `--map`: replace `__NOTES__` with nothing.
- `--map-visual`: replace `__NOTES__` with one `<section id="...">` per main node: what it does, inputs/outputs, key files as `<code>path:line</code>`, and what the ticket changes there (`<span class="new">`) or risks (`<span class="risk">`). End with a step-by-step section walking the data flow for the ticket's case. Add `click <Node> href "#<id>"` lines so diagram nodes jump to their sections.
Then `xdg-open` it. Don't print the diagram or notes in chat; give the file path.

## 2. Clarify

List what's underspecified: scope, edge cases, error handling, compatibility, performance.
Ask at most 5 questions, multiple choice, recommended option first. Decide the rest yourself and log each as
`Ruling: <decision> — <why> — <cost if wrong>` under Current Rules.

## 3. Plan and choose

Give the options with a one-line trade-off each, and your recommendation with the reason.
If the ticket is complex or outside my usual stack, explain the options well enough for me to choose.
STOP: ask me to pick. No code before I answer. If I say "you choose", recommend and wait for my OK.
For the chosen option, list cons and side effects in detail: behaviour changes, callers, data/config, performance, migration. Add them to Pending.

## 4. Implement and test

fix tickets: write a failing test that reproduces the bug before changing code.
Add a test for each con or side effect that can be tested; mark the rest "untested" in the state file.
Fill the Tests section of the state file, one line per tier, cheapest first:
`<tier>: <command> — <what it covers> — <rough time>`, e.g. targeted (touched files), unit (full suite), e2e (renders, hardware, external services).
Ask me before running a tier that takes over 5 minutes, needs a GPU or device, or costs money.
Run every tier you can now. Report each command and its result; never say "tests pass" without a fresh run.
omi: also add or update `scripts/run_<workflow>.sh` so I can check the renders myself.
Then END THE TURN.

## 5. Iterate

Apply my feedback. Each round: run the targeted tier, re-check Pending, update the state file. Log small choices as Rulings.
Run a wider tier in the round when the change touches shared code, config, build files or a public interface.
After each run, write under Tests: `Last <tier>: <date> <result>` and `Stale: <tiers> — <files changed since their last pass>`. Never drop a stale tier without running it.
Go to step 6 only when I say done / lgtm / commit.

## 6. Review

Run /simplify, then /code-review at medium. Show the findings and ask: fix now, fix later (add to Pending), or ignore.

## 7. Docs and references

Update the docs the project already keeps for the changed items; no new doc files.
Grep the whole repo (docs, JSON, configs, scripts) for changed names. LSP misses references outside code.
Cross-check: every con has a test or an "untested" note, and every renamed item was grepped.
Run every tier still listed under Stale. For the expensive ones, give me the commands and wait for my results; log them. Skip a tier only if I say so, and keep it under Stale.

## 8. Commit (after my approval in step 5)

Title per /gen-short-commit; follow the project's own convention where it differs.
Body: Rulings that matter, untested cons, tiers not re-run after the last change, how to test.
Move Pending items to Done in the state file.

## 9. No push

I push, so it can still be reverted without rewriting history if the ticket changes.
