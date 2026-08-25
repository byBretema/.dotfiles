import type { Plugin } from "@opencode-ai/plugin";

export default (async ({ client }) => {
  let info = "";
  let toastShown = false;

  return {
    // --- Gather data during configuration phase ---

    config: (cfg) => {
      // Instructions files
      info = `Instructions:${cfg.instructions.map((i) => `\n• ${i}`).join("")}`;
    },

    // --- Subscribe to the internal event bus ---

    event: async ({ event }) => {
      // Event type
      const isIdle = event.type === "session.idle";
      const isStatus = event.type === "session.status";

      // Trigger toast once
      if (!toastShown && (isIdle || isStatus)) {
        toastShown = true;

        client.tui
          .showToast({
            body: {
              title: "Some agent info",
              message: info,
              variant: "info",
              duration: 6000,
            },
          })
          .catch(() => {});
      }
    },
  };
}) satisfies Plugin;
