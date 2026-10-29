import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register } from 'claude-code'

import type { Info } from '../types'

const info = atom({ plugin: 'footer-tail', key: 'info' } as const, null)

// claude-opus-5-5[1m] -> Opus 5.5
const pretty = (id: string) => {
  const m = /^claude-([a-z]+)-(\d+)-(\d+)/.exec(id)
  return m ? `${m[1]![0]!.toUpperCase()}${m[1]!.slice(1)} ${m[2]}.${m[3]}` : id
}

const refresh = async ($: EngineInterface) => {
  const [model, root] = await Promise.all([$.session.model(), $.session.root()])
  const git = await $.process
    .run(['git', '-C', root, 'branch', '--show-current'])
    .catch(() => null)
  const branch = git?.exitCode === 0 ? git.stdout.trim() : ''
  const next: Info = { model: pretty(model), branch }
  await update($, info, () => next)
}

const HIDDEN = ['install gh', 'esc to interrupt']

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await refresh($).catch(() => {})
    return next(e)
  })

  // Git runs once per turn, not per redraw; a turn can switch branch or model.
  on('turn.complete', async ($, e, next) => {
    await refresh($).catch(() => {})
    return next(e)
  })

  on('ui.render', { component: 'PromptHint' }, async ($, e, next) => {
    const cur = await read($, info)
    if (!cur) return next(e)

    const { Box, Text } = $.ui.resolve(e)
    const hint = e.props.hint
      .replace(/\s*\(shift\+tab to cycle\)/, '')
      .split('·')
      .map(s => s.trim())
      .filter(s => s && !HIDDEN.some(h => s.startsWith(h)))
      .join(' · ')

    return (
      <Box>
        {/* The mode label and the "·" after it are the engine's, drawn before this line; with no hint left, that "·" is the separator. */}
        {hint ? <Text dimColor>{hint} | </Text> : null}
        <Text color="#cba6f7">{cur.model}</Text>
        {cur.branch ? (
          <Text>
            <Text dimColor> | </Text>
            <Text color="#a6e3a1">{cur.branch}</Text>
          </Text>
        ) : null}
      </Box>
    )
  })
}
