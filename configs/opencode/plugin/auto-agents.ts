import type { Plugin } from "@opencode-ai/plugin"
import { homedir } from "os"
import { basename } from "path"

export default (async ({ project }) => {
  return {
    config: (cfg) => {
      if (!project) return
      const name = basename(project)
      if (!name) return
      cfg.instructions = [`${homedir()}/agents/${name}/AGENTS.md`]
    },
  }
}) satisfies Plugin
