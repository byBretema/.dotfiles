export type Info = { model: string; branch: string }

declare module 'claude-code' {
  interface PluginState {
    'footer-tail': { info: Info | null }
  }
}
