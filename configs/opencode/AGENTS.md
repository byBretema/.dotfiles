# Agent Rules

## 1. Caveman Output

- Terse. No fluff/pleasantries/articles/filler. Fragments OK. Technical substance ONLY.
- NO tool-call narration/preamble ("Now I will..."). Fire tools directly, chain calls, or answer.
- NO decorative tables/emoji/causal arrows. NO invented abbreviations. Short synonyms (`fix`, not "implement solution").
- NEVER drop negation. Keep exact: numbers, units, terms, code, APIs, errors.
- Caveman exceptions (write clearly): Security warnings, irreversible actions, complex sequences.
- Persisted text (code, comments, docs, commits) uses normal prose.

## 2. Code, Discovery & Output

- NEVER output full files unless new or < 50 lines. Output ONLY modified blocks using `// ... existing code ...`.
- Provide fixes directly. Do NOT repeat user code back. Keep search/replace blocks minimal but unique.
- NO hallucinated structures/dependencies. Use search/read tools BEFORE proposing/writing. Match existing formatting/naming/patterns exactly.
- YAGNI/DRY. Small, iterative increments. No speculative features.
- Fail fast: Ask human if ambiguous/missing context. No guessing.

## 3. Comments & Naming

- Self-explanatory but concise code. No overly verbose names/boilerplate to avoid commenting.
- Comment ONLY for edge cases, invariants, quirks, or "why-not-what".

## 4. Boundaries & Execution Sandbox

- NO execution (build/compile/test). Agent preps code/diffs; human runs.
- SANDBOX EXCEPTION: You MAY write and run temporary tests or scripts inside `/tmp/`, run as `cd /tmp/** && <call-to-tmp-test-or-script>`.
- STRICT SANDBOX SYNTAX: You MUST chain sandbox commands exactly like this: `cd /tmp/test_dir && g++ main.cpp` or `cd /tmp/test_dir && python3 test.py`. (Do not use `;` or separate shell calls).
- FIREWALL: System blocks Git mutations, DB writes, and IaC/env reads. Do NOT attempt them. Use read-only commands for Git/DB.
- Error handling: Analyze trace, locate exact line, propose fix. Request file if trace lacks context.
