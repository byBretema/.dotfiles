---
description: "Load task context from @ag. Pick from list or pass task name as argument."
---

## Goal

Load a task's `context.md` from the `@ag` agents library.

## Behavior

### If $ARGUMENTS is provided:

1. Read `~/agents/$ARGUMENTS/context.md`
2. If found: summarize it and confirm task loaded
3. If not found: list available tasks and ask user to pick

### If $ARGUMENTS is empty:

1. Run `find ~/agents -name "context.md" -printf "%P\n" | sed 's|/context.md||' | sort` to list all task paths
2. Use the `question` tool to present them as selectable options (single choice)
3. Read the selected task's `~/agents/<choice>/context.md`
4. Summarize it and confirm task loaded

## Context Summary Format

After loading, present:

- **Task:** <folder name>
- **Goal:** <from context.md>
- **Status:** done / in-progress / blocked items
- **Next:** <next steps>
- **Relevant notes:** <other notes or previous research notes from the contex.md relevant to the pending tasks>
