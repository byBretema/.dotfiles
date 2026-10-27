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

// Drawing the line ourselves loses the engine's styling, so the mode label gets its color back here.
const modeColor = (mode: string) =>
  mode.startsWith('plan') ? 'planMode' : mode.startsWith('auto') ? 'warning' : 'autoAccept'

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
    const hint = e.props.hint.replace(/\s*\(shift\+tab to cycle\)/, '')
    const m = /^(.*?\b(\S+) mode on)(.*)$/.exec(hint)

    return (
      <Box>
        {m ? (
          <Text>
            <Text color={modeColor(m[2]!)}>{m[1]}</Text>
            <Text dimColor>{m[3]}</Text>
          </Text>
        ) : (
          <Text dimColor>{hint}</Text>
        )}
        <Text dimColor> | </Text>
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
