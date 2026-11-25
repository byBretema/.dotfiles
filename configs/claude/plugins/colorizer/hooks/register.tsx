import type { Register, RenderChildren } from 'claude-code'

// `**`[ks]`**` or `**`[ksj]`**`, optionally after a header or bullet marker; see output-styles/terse.md.
const TAG = /^(#{1,6}\s+|[-*]\s+)?\*\*`\[([a-z]{2,3})\]`\*\*\s?(.*)$/
const FENCE = /^\s*(```|~~~)/
// Tables and quotes only render as whole blocks, so they keep Markdown even with code inside.
const BLOCK = /^\s*(\||>)/
const LEAD = /^(\s*)(#{1,6}\s+|[-*+]\s+|\d+[.)]\s+)?(.*)$/
const SPAN = /(`+)(.+?)\1|\*\*(.+?)\*\*/g
const CODE = /`[^`]+`/

// Raw colors on purpose: theme overrides don't reach markdown, and named colors follow the terminal palette.
const HEADER_COLOR = 'magenta'
const ITEM_COLOR = 'yellow'
const CODE_COLOR = 'green'

type Row = { kind: 'md'; text: string } | { kind: 'tag'; lead: string; tag: string; text: string }

const parse = (src: string): Row[] => {
  const rows: Row[] = []
  let fence = false
  for (const line of src.split('\n')) {
    if (FENCE.test(line)) fence = !fence
    const m = fence ? null : TAG.exec(line)
    const last = rows[rows.length - 1]
    if (m) {
      rows.push({ kind: 'tag', lead: m[1] ?? '', tag: m[2]!, text: m[3]! })
    } else if (line.trim() === '' && !fence) {
      rows.push({ kind: 'md', text: '' })
    } else if (last && (last.kind === 'md' ? last.text !== '' : true)) {
      // Continuation: wrapped paragraph lines stay with the row above.
      last.text += '\n' + line
    } else {
      rows.push({ kind: 'md', text: line })
    }
  }
  // Blank rows only separate; collapse them into spacing.
  return rows.filter(r => r.kind === 'tag' || r.text !== '')
}

const hasInlineCode = (text: string) => {
  const lines = text.split('\n')
  return CODE.test(text) && !lines.some(l => FENCE.test(l) || BLOCK.test(l))
}

export const register: Register = on => {
  on('ui.render', { component: 'AssistantMessage' }, async ($, e, next) => {
    const src = e.props.text
    if (!src.includes('`')) return next(e)

    const rows = parse(src)
    if (!rows.some(r => r.kind === 'tag' || hasInlineCode(r.text))) return next(e)

    const { Box, Text, Markdown } = $.ui.resolve(e)

    // Only `code` and **bold** survive; other inline markdown shows as written.
    const parts = (s: string): RenderChildren[] => {
      const out: RenderChildren[] = []
      let at = 0
      for (const m of s.matchAll(SPAN)) {
        if (m.index! > at) out.push(s.slice(at, m.index))
        // Bold recurses so code inside it still gets colored.
        out.push(m[2] !== undefined ? <Text color={CODE_COLOR}>{m[2]}</Text> : <Text weight="bold">{parts(m[3]!)}</Text>)
        at = m.index! + m[0].length
      }
      if (at < s.length) out.push(s.slice(at))
      return out
    }
    const spans = (s: string, bold: boolean) => <Text weight={bold ? 'bold' : undefined}>{parts(s)}</Text>

    const line = (l: string, bold: boolean) => {
      const [, indent, marker = '', body] = LEAD.exec(l)!
      if (marker.startsWith('#')) return spans(body!, true)
      if (!marker) return spans(indent + body!, bold)
      return (
        <Box flexDirection="row">
          <Text>{indent}{marker.trim() === '*' || marker.trim() === '+' ? '- ' : marker}</Text>
          <Box flexGrow={1} flexShrink={1}>{spans(body!, bold)}</Box>
        </Box>
      )
    }

    const content = (text: string, bold = false) =>
      hasInlineCode(text) ? (
        <Box flexDirection="column">{text.split('\n').map(l => line(l, bold))}</Box>
      ) : (
        <Markdown text={bold ? `**${text}**` : text} />
      )

    return (
      <Box flexDirection="column" gap={1}>
        {rows.map(r => {
          if (r.kind === 'md') return content(r.text)
          const isHeader = r.lead.startsWith('#')
          const isBullet = !isHeader && r.lead !== ''
          return (
            <Box flexDirection="row">
              {isBullet ? <Text>- </Text> : null}
              <Text color={isHeader ? HEADER_COLOR : ITEM_COLOR} weight="bold">
                [{r.tag}]{' '}
              </Text>
              <Box flexGrow={1} flexShrink={1}>
                {content(r.text, isHeader)}
              </Box>
            </Box>
          )
        })}
      </Box>
    )
  })
}
