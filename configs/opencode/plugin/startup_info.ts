import type { Plugin } from "@opencode-ai/plugin";

export default (async ({ client }) => {
  let info = "";

  return {
    config: (cfg) => {
      info = `Instructions:\n${cfg.instructions.map(i => `\n  ${i}`).join("")}`;
      setTimeout(() => {
        client.tui
          .showToast({
            body: {
              title: "Info",
              message: `${info}`,
              variant: "info",
              duration: 10000,
            },
          })
          .catch(() => {});
      }, 1000);
    },
  };
}) satisfies Plugin;
