import type { Register, RenderChildren } from 'claude-code'

// `**`[ks]`**` or `**`[ksj]`**`, optionally after a header or bullet marker; see output-styles/terse.md.
const TAG = /^(#{1,6}\s+|[-*]\s+)?\*\*`\[([a-z]{2,3})\]`\*\*\s?(.*)$/
const FENCE = /^\s*(```|~~~)/
// Tables and quotes only render as whole blocks, so they keep Markdown even with code inside.
const BLOCK = /^\s*(\||>)/
const LEAD = /^(\s*)(#{1,6}\s+|[-*+]\s+|\d+[.)]\s+)?(.*)$/
// Code first, so a link written inside code stays code.
const SPAN = /(`+)(.+?)\1|\*\*(.+?)\*\*|\[([^\]]+)\]\(([^)\s]+)\)/g
const INLINE = /`[^`]+`|\[[^\]]+\]\([^)\s]+\)/

// Raw colors on purpose: theme overrides don't reach markdown, and named colors follow the terminal palette.
const HEADER_COLOR = 'magenta'
const ITEM_COLOR = 'magentaBright'
const CODE_COLOR = 'yellow'
const LINK_COLOR = 'blueBright'
const FENCE_COLOR = 'greenBright'

type Row =
  | { kind: 'md'; text: string }
  | { kind: 'fence'; text: string }
  | { kind: 'tag'; lead: string; tag: string; text: string }

const parse = (src: string): Row[] => {
  const rows: Row[] = []
  let block: string[] | null = null
  for (const line of src.split('\n')) {
    if (FENCE.test(line)) {
      if (block) rows.push({ kind: 'fence', text: block.join('\n') })
      block = block ? null : []
      continue
    }
    if (block) {
      block.push(line)
      continue
    }
    const m = TAG.exec(line)
    const last = rows[rows.length - 1]
    if (m) {
      rows.push({ kind: 'tag', lead: m[1] ?? '', tag: m[2]!, text: m[3]! })
    } else if (line.trim() === '') {
      rows.push({ kind: 'md', text: '' })
    } else if (last && (last.kind === 'tag' || (last.kind === 'md' && last.text !== ''))) {
      // Continuation: wrapped paragraph lines stay with the row above.
      last.text += '\n' + line
    } else {
      rows.push({ kind: 'md', text: line })
    }
  }
  // Still streaming: the open block shows as far as it got.
  if (block) rows.push({ kind: 'fence', text: block.join('\n') })
  // Blank rows only separate; collapse them into spacing.
  return rows.filter(r => r.kind !== 'md' || r.text !== '')
}

const hasInline = (text: string) => INLINE.test(text) && !text.split('\n').some(l => BLOCK.test(l))

export const register: Register = on => {
  on('ui.render', { component: 'AssistantMessage' }, async ($, e, next) => {
    const src = e.props.text
    if (!src.includes('`') && !src.includes('](')) return next(e)

    const rows = parse(src)
    if (!rows.some(r => r.kind !== 'md' || hasInline(r.text))) return next(e)

    const { Box, Text, Link, Markdown } = $.ui.resolve(e)

    // Only `code`, **bold** and [links](url) survive; other inline markdown shows as written.
    const parts = (s: string): RenderChildren[] => {
      const out: RenderChildren[] = []
      let at = 0
      for (const m of s.matchAll(SPAN)) {
        if (m.index! > at) out.push(s.slice(at, m.index))
        // Bold recurses so code inside it still gets colored.
        out.push(
          m[2] !== undefined ? (
            <Text color={CODE_COLOR}>{m[2]}</Text>
          ) : m[3] !== undefined ? (
            <Text weight="bold">{parts(m[3])}</Text>
          ) : (
            <Text color={LINK_COLOR} underline>
              <Link href={m[5]!}>{m[4]}</Link>
            </Text>
          ),
        )
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
      hasInline(text) ? (
        <Box flexDirection="column">{text.split('\n').map(l => line(l, bold))}</Box>
      ) : (
        <Markdown text={bold ? `**${text}**` : text} />
      )

    return (
      <Box flexDirection="column" gap={1}>
        {rows.map(r => {
          if (r.kind === 'md') return content(r.text)
          if (r.kind === 'fence') return <Text color={FENCE_COLOR}>{r.text}</Text>
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
