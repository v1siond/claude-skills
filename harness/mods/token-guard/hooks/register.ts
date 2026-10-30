import type { Register, SessionRateLimit, SessionUsage } from 'claude-code'

type Reading = { at: number; percent: number }

const ALERT_STEPS = [50, 75, 90] as const
const BURN_WINDOW_MS = 15 * 60 * 1000

// Compaction is only worth it if the next turn can pick the work back up without
// rereading everything, so the summary is told what the work needs to survive.
export const KEEP_ON_COMPACT = [
  'Keep, word for word: every correction and decision the user gave in this conversation, with their exact quotes.',
  'Keep: each ticket and its status in run order, running agent ids and what each is doing, uncommitted files and their state, the next step.',
  'Drop: tool output, file dumps, test logs, anything already written to a file on disk (name the file instead).',
  'End the summary with a "Recover" line: read STATE.md, then the handoff note for the current ticket; grep SESSION-NOTES.md, never read it whole.',
].join('\n')

export const tokens = (n?: number): string => {
  if (n === undefined) return '?'
  if (n >= 1000) return `${Math.round(n / 1000)}k`
  return String(n)
}

const shortKind = (kind: string): string => ({ five_hour: '5h', seven_day: '7d', spend_limit: 'spend' })[kind] ?? kind

export const burnPerQuarterHour = (history: readonly Reading[], now: number): number | undefined => {
  const recent = history.filter(r => now - r.at <= BURN_WINDOW_MS)
  if (recent.length < 2) return undefined
  const first = recent[0]
  const last = recent[recent.length - 1]
  const elapsed = last.at - first.at
  if (elapsed < 60_000) return undefined
  return Math.round(((last.percent - first.percent) / elapsed) * BURN_WINDOW_MS * 10) / 10
}

export const meterText = (usage: Pick<SessionUsage, 'context' | 'rateLimits' | 'cost'>, burn?: number): string => {
  const { context, rateLimits, cost } = usage
  const parts = [`ctx ${tokens(context.tokens)} (${context.percent ?? '?'}%)`]
  for (const limit of rateLimits) parts.push(`${shortKind(limit.kind)} ${limit.percentUsed}%`)
  if (burn !== undefined) parts.push(`+${burn}pt/15m`)
  if (cost) parts.push(`$${cost.usd.toFixed(2)}`)
  return parts.join(' | ')
}

export const crossedStep = (before: number | undefined, after: number): number | undefined => {
  if (before === undefined) return undefined
  return [...ALERT_STEPS].reverse().find(step => before < step && after >= step)
}

const fiveHour = (limits: readonly SessionRateLimit[]) => limits.find(l => l.kind === 'five_hour')

export const register: Register = on => {
  let history: Reading[] = []

  on('session.measure', async ($, e, next) => {
    const now = $.clock.now()
    const window = fiveHour(e.rateLimits)
    const previous = history[history.length - 1]?.percent
    if (window) history = [...history.filter(r => now - r.at <= BURN_WINDOW_MS), { at: now, percent: window.percentUsed }]
    $.ui.status(meterText(e, burnPerQuarterHour(history, now)))
    const step = window && crossedStep(previous, window.percentUsed)
    if (step) $.ui.toast(`Plan usage passed ${step}% of the 5h window`)
    return next(e)
  })

  on('session.compact', ($, e, next) => {
    const instructions = e.instructions ? `${e.instructions}\n\n${KEEP_ON_COMPACT}` : KEEP_ON_COMPACT
    return next({ ...e, instructions })
  })
}
