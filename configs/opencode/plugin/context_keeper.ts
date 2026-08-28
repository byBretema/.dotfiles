import type { Plugin } from "@opencode-ai/plugin";

export default (async () => {
  const IDLE_THRESHOLD = 8;

  let turnCount = 0;
  let pendingInject = false;
  let activeTask: string | null = null;

  const fs = await import("fs/promises");
  const path = await import("path");
  const stateFile = path.join(
    process.env.HOME || "~",
    ".config/opencode/context_keeper_state.json"
  );

  try {
    const data = await fs.readFile(stateFile, "utf-8");
    const state = JSON.parse(data);
    turnCount = state.turnCount ?? 0;
    activeTask = state.activeTask ?? null;
  } catch {}

  const saveState = async () => {
    try {
      await fs.writeFile(stateFile, JSON.stringify({ turnCount, activeTask }));
    } catch {}
  };

  const INSTRUCTION = (task: string) =>
    `<update_context>` +
    `Session has ~${IDLE_THRESHOLD}+ turns. ` +
    `Read ~/agents/${task}/context.md, update it with current session progress ` +
    `(move completed items to Done, update In Progress/Blocked/Next Steps/Key Decisions), ` +
    `then write it back silently before addressing the user's message.` +
    `</update_context>`;

  return {
    // --- Track active task from /hi args ---
    "command.execute.before": async (input) => {
      if (input.command === "hi") {
        const args = input.arguments?.trim();
        if (args) {
          activeTask = args;
          turnCount = 0;
          pendingInject = false;
          await saveState();
        }
      }
      if (input.command === "bye") {
        turnCount = 0;
        pendingInject = false;
        await saveState();
      }
    },

    // --- Detect active task from context.md reads ---
    "tool.execute.after": async (input) => {
      if (input.tool === "read") {
        const filePath = input.args?.filePath as string;
        if (filePath?.includes("/agents/") && filePath?.includes("context.md")) {
          const match = filePath.match(
            /\/agents\/([^/]+(?:\/[^/]+)*)\/context\.md/
          );
          if (match && match[1] !== activeTask) {
            activeTask = match[1];
            turnCount = 0;
            pendingInject = false;
            await saveState();
          }
        }
      }
    },

    // --- Count idle turns, flag injection when threshold hit ---
    event: async ({ event }) => {
      if (event.type === "session.idle") {
        turnCount++;

        if (turnCount >= IDLE_THRESHOLD && activeTask) {
          pendingInject = true;
        }

        await saveState();
      }
    },

    // --- Inject context-save instruction before user prompt ---
    "chat.message": async (input, output) => {
      if (!activeTask || !pendingInject) return;

      pendingInject = false;
      turnCount = 0;
      await saveState();

      output.parts.unshift({
        id: `ctx-${Date.now()}`,
        sessionID: input.sessionID,
        messageID: input.messageID ?? "",
        type: "text",
        text: INSTRUCTION(activeTask),
        synthetic: true,
      });
    },
  };
}) satisfies Plugin;
