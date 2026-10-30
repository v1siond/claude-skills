import { expect, mock, test } from 'claude-code/testing'

import type { On } from 'claude-code'

import { entriesOf, newestRows, rowsPerAgent } from '../hooks/register'

const PANE = {
  plugin: 'agents-live',
  component: 'Pane',
  requestId: 'agents-live',
  props: { title: 'Agents', isFocused: false, bodyColumns: 100, placement: 'dock', scroll: { offset: 0, bodyRows: 30 }, view: {} },
} as const

test('the pane says so when the session has no agents yet', async $ => {
  for (const surface of ['terminal', 'desktop'] as const) {
    const ui = await $.ui.mount({ ...PANE, surface })
    expect(await ui.find({ type: 'Text', text: /No agents in this session yet/ })).toBeDefined()
    await ui.unmount()
  }
})

test('a call shows why, the real command and the tail of its output', () => {
  const output = Array.from({ length: 20 }, (_, i) => `line ${i + 1}`).join('\n')
  const [said, bash, read] = entriesOf({
    role: 'assistant',
    text: 'Red for the right reason.\n\nNow green.',
    toolUses: [
      { tool_use_id: 't1', tool: 'Bash', input: { command: 'mix test test/a_test.exs', description: 'Run step 1 spec' }, text: output },
      { tool_use_id: 't2', tool: 'Read', input: { file_path: '/x/README.md' }, text: 'no such file', isError: true },
    ],
  })
  expect(said).toEqual({ kind: 'says', label: 'says', title: '', input: ['Red for the right reason.', 'Now green.'], output: [] })
  expect(bash?.title).toBe('Run step 1 spec')
  expect(bash?.input).toEqual(['$ mix test test/a_test.exs'])
  expect(bash?.output).toEqual(['line 13', 'line 14', 'line 15', 'line 16', 'line 17', 'line 18', 'line 19', 'line 20'])
  expect(read).toEqual({ kind: 'error', label: 'Read FAILED', title: '', input: ['/x/README.md'], output: ['no such file'] })
  expect(entriesOf({ role: 'user', text: 'hi', toolUses: [] })).toEqual([])
})

test('one long step never takes more than its agent share of rows', () => {
  const huge = { kind: 'tool' as const, label: 'Bash', title: 'heredoc', input: Array(6).fill('$ x'), output: Array(8).fill('o') }
  const small = { kind: 'tool' as const, label: 'Read', title: 'last', input: ['/a'], output: [] }
  const rows = newestRows([huge, small], 5)
  expect(rows).toHaveLength(5)
  expect(rows.at(-2)?.text).toBe('Read  last')
  expect(rows.at(-1)?.text).toBe('  /a')
})

test('every running agent fits: headers, gaps and shares add up to the pane height', () => {
  for (const [bodyRows, agents] of [[30, 2], [12, 2], [40, 3], [9, 1]] as const) {
    const share = rowsPerAgent(bodyRows, agents)
    expect(agents * (1 + share) + (agents - 1)).toBeLessThanOrEqual(bodyRows)
  }
})

const START = { cwd: '/tmp', surface: 'terminal', isInteractive: true } as const

// A prompt the person typed in the prompt box.
const typed = (text: string) => ({ text, wait: false, origin: { kind: 'composer' } }) as const

type Pane = { id: string; title: string; isShown: boolean; isFocused: boolean; isPlaced: boolean }
const pane = (isPlaced: boolean): Pane => ({ id: 'agents-live', title: 'Agents', isShown: isPlaced, isFocused: false, isPlaced })

// Stands in for the engine: `panes` is its record of this plugin's panes, as `$.ui.panes()` reads it.
const engine = (on: On, panes: Pane[]) => {
  const opens: string[] = []
  mock.clock(on)
  on('prompt.submit', (_$, e) => ({ text: e.text }))
  on('ui.panes' as never, (() => ({ value: panes })) as never)
  on('ui.open', { id: 'agents-live' }, () => {
    opens.push('agents-live')
    return { value: { isPlaced: true } as never }
  })
  return opens
}

test('a prompt draws the pane the session start left waiting on a narrow terminal', async ($, on) => {
  const opens = engine(on, [pane(false)])

  await $.prompt.submit(typed('go'))

  expect(opens).toEqual(['agents-live'])
})

test('a pane already drawn is not reopened on every prompt', async ($, on) => {
  const opens = engine(on, [pane(true)])

  await $.prompt.submit(typed('one'))
  await $.prompt.submit(typed('two'))

  expect(opens).toEqual([])
})

test('a pane the person closed stays closed', async ($, on) => {
  const opens = engine(on, [])

  await $.prompt.submit(typed('go'))

  expect(opens).toEqual([])
})

test('the prompt goes through as typed', async ($, on) => {
  engine(on, [pane(false)])

  const submitted = await $.prompt.submit(typed('go'))

  expect('text' in submitted && submitted.text).toBe('go')
})
