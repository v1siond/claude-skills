import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register, SessionMessage, ToolUseSummary } from 'claude-code'

import type { AgentFeed, FeedEntry, FeedKind } from '../types'

const PANE = 'agents-live'
const POLL_MS = 3000
const ENTRIES_KEPT = 30
const OUTPUT_TAIL = 8
const INPUT_HEAD = 6
const feeds = atom({ plugin: 'agents-live', key: 'feeds' } as const, [])

const linesOfText = (text: string) => text.split('\n').map(line => line.trimEnd()).filter(line => line.length > 0)
const head = (text: string, count: number) => linesOfText(text).slice(0, count)
const tail = (text: string, count: number) => linesOfText(text).slice(-count)
const field = (input: Record<string, unknown>, key: string) => (input[key] === undefined ? '' : String(input[key]))

// What each tool was actually asked to do, the way a log would print it.
const inputShownBy: Record<string, (input: Record<string, unknown>) => string[]> = {
  Bash: input => head(`$ ${field(input, 'command')}`, INPUT_HEAD),
  Read: input => [`${field(input, 'file_path')}${input.offset ? ` from line ${field(input, 'offset')}` : ''}`],
  Write: input => [field(input, 'file_path')],
  Edit: input => [field(input, 'file_path'), ...head(`- ${field(input, 'old_string')}`, 2), ...head(`+ ${field(input, 'new_string')}`, 2)],
  Grep: input => [`/${field(input, 'pattern')}/ in ${field(input, 'path') || '.'}`],
  Glob: input => [field(input, 'pattern')],
}

const inputOf = (use: ToolUseSummary) => {
  const shown = inputShownBy[use.tool]
  return shown ? shown(use.input) : head(JSON.stringify(use.input), INPUT_HEAD)
}

// The agent's own short description of a call says why it ran it.
const titleOf = (use: ToolUseSummary) => {
  const description = use.input.description
  return description === undefined ? '' : String(description)
}

const callEntry = (use: ToolUseSummary): FeedEntry => {
  const kind: FeedKind = use.isError ? 'error' : 'tool'
  return {
    kind,
    label: use.isError ? `${use.tool} FAILED` : use.tool,
    title: titleOf(use),
    input: inputOf(use),
    output: tail(use.text ?? '', OUTPUT_TAIL),
  }
}

export const entriesOf = (message: SessionMessage): FeedEntry[] => {
  if (message.role !== 'assistant') return []
  const said: FeedEntry[] = message.text
    ? [{ kind: 'says', label: 'says', title: '', input: linesOfText(message.text), output: [] }]
    : []
  return [...said, ...message.toolUses.map(callEntry)]
}

const feedOf = async ($: EngineInterface, agent: { id: string; description: string; status: string }) => {
  const messages = await $.session.messages({ agentId: agent.id })
  const entries = 'deny' in messages ? [] : messages.flatMap(entriesOf).slice(-ENTRIES_KEPT)
  return { ...agent, entries }
}

const refresh = async ($: EngineInterface) => {
  const agents = await $.agent.list()
  const next: AgentFeed[] = await Promise.all(
    agents.map(agent => feedOf($, { id: agent.id, description: agent.description, status: agent.status })),
  )
  await update($, feeds, () => next)
}

export type FeedRow = { text: string; color?: string; bold?: boolean }

const labelColor: Record<FeedKind, string> = { says: 'white', tool: 'cyan', error: 'red' }

const rowsOf = (entry: FeedEntry): FeedRow[] => [
  { text: `${entry.label}${entry.title ? `  ${entry.title}` : ''}`, color: labelColor[entry.kind], bold: true },
  ...entry.input.map(line => ({ text: `  ${line}`, color: entry.kind === 'says' ? undefined : 'yellow' })),
  ...entry.output.map(line => ({ text: `  | ${line}`, color: entry.kind === 'error' ? 'red' : 'gray' })),
]

// The newest rows of an agent's log, cut to exactly its share so no agent pushes another off the pane.
export const newestRows = (entries: FeedEntry[], rows: number) => entries.flatMap(rowsOf).slice(-rows)

// Each agent gets a header row and an equal share of what is left; agents are separated by one blank row.
export const rowsPerAgent = (bodyRows: number, agents: number) =>
  Math.max(1, Math.floor((bodyRows - agents - (agents - 1)) / agents))

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    const started = await next(e)
    await $.command.register({ name: 'agents-live', description: 'Show what each background agent is doing, live' })
    void $.ui.open({ id: PANE, title: 'Agents' })
    $.clock.every(POLL_MS, () => void refresh($))
    void refresh($)
    return started
  })

  // Opened at session start the pane is unasked, and the engine leaves it undrawn under 144
  // columns. A typed prompt counts as asked, so the first one draws it at any width. A pane the
  // person closed is no longer listed, so it stays closed.
  on('prompt.submit', async ($, e, next) => {
    const waiting = (await $.ui.panes()).some(pane => pane.id === PANE && !pane.isPlaced)
    if (waiting) await $.ui.open({ id: PANE, title: 'Agents' })
    return next(e)
  })

  on('command.run', { command: 'agents-live' }, async $ => {
    await refresh($)
    await $.ui.open({ id: PANE, title: 'Agents' })
    return { text: 'Agents pane opened.' }
  })

  on('ui.render', { component: 'Pane', requestId: PANE }, async ($, e) => {
    const { Box, Text } = $.ui.resolve(e)
    const list = await read($, feeds)
    if (list.length === 0) return <Text dimColor>No agents in this session yet.</Text>

    const running = list.filter(feed => feed.status === 'running')
    const shown = running.length > 0 ? running : list
    const share = rowsPerAgent(e.props.scroll.bodyRows, shown.length)
    return (
      <Box flexDirection="column">
        {shown.map((feed, index) => (
          <Box flexDirection="column" marginTop={index === 0 ? 0 : 1}>
            <Text bold color={feed.status === 'running' ? 'green' : 'gray'} wrap="truncate-end">
              == {feed.description} [{feed.status}]
            </Text>
            {newestRows(feed.entries, share).map(row => (
              <Text color={row.color} bold={row.bold} wrap="truncate-end">
                {row.text}
              </Text>
            ))}
          </Box>
        ))}
      </Box>
    )
  })
}
