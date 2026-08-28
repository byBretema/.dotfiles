---
description: "Save session progress to the current task's context.md in @ag."
---

## Goal

Update the task's `context.md` with progress made this session.

## Behavior

1. Identify the active task from the current session context (look for loaded context.md path or ask user)
2. Read the current `context.md` from `~/agents/<task>/context.md`
3. Review the session conversation for:
   - Completed items → move to "Done"
   - New blockers → add to "Blocked"
   - Work still pending → update "In Progress" or "Next Steps"
   - New key decisions → append to "Key Decisions"
   - New relevant files → update "Relevant Files"
4. Write the updated `context.md` back to the same path
5. Present a brief diff summary of what changed

## Rules

- Preserve existing sections and structure
- Never delete "Done" items — only append
- Keep entries concise (1 line each)
- If no task is active, ask user which task to save to using `question` tool with available tasks from `~/agents/`
