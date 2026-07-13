import type { Plugin } from "@opencode-ai/plugin"
import { homedir } from "os"
import { basename } from "path"

export default (async ({ project, directory, client }) => {
  let agentsPath = ""

  return {
    config: (cfg) => {
      if (!project) return
      const name = basename(project.worktree || directory)
      if (!name) return
      agentsPath = `${homedir()}/agents/${name}/AGENTS.md`
      cfg.instructions = [...(cfg.instructions || []), agentsPath]
      setTimeout(() => {
        client.tui.showToast({
          body: {
            title: "AGENTS.md",
            message: `Active: ${agentsPath}`,
            variant: "info",
            duration: 10000,
          },
        }).catch(() => {})
      }, 1000)
    },
    "experimental.chat.system.transform": async (_input, output) => {
      if (!agentsPath) return
      output.system = [
        `## Active session context\n${agentsPath}`,
        ...output.system,
      ]
    },
  }
}) satisfies Plugin
