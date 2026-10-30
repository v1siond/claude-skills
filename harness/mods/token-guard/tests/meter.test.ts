import { expect, test } from 'claude-code/testing'

import { burnPerQuarterHour, crossedStep, meterText, tokens } from '../hooks/register'

test('the meter shows context, each plan window, the burn and the cost', () => {
  const text = meterText(
    { context: { tokens: 142_300, window: 1_000_000, percent: 14 }, rateLimits: [{ kind: 'five_hour', percentUsed: 64 }, { kind: 'seven_day', percentUsed: 30 }], cost: { usd: 12.5 } },
    6,
  )
  expect(text).toBe('ctx 142k (14%) | 5h 64% | 7d 30% | +6pt/15m | $12.50')
})

test('the meter reads before the first response reports anything', () => {
  expect(meterText({ context: { window: 1_000_000 }, rateLimits: [] })).toBe('ctx ? (?%)')
  expect(tokens(900)).toBe('900')
})

test('burn is the 5h climb scaled to a quarter hour, and needs a real interval', () => {
  expect(burnPerQuarterHour([{ at: 0, percent: 60 }, { at: 5 * 60_000, percent: 62 }], 5 * 60_000)).toBe(6)
  expect(burnPerQuarterHour([{ at: 0, percent: 60 }], 0)).toBeUndefined()
  expect(burnPerQuarterHour([{ at: 0, percent: 60 }, { at: 30_000, percent: 61 }], 30_000)).toBeUndefined()
})

test('an alert fires once, on the highest step crossed', () => {
  expect(crossedStep(48, 51)).toBe(50)
  expect(crossedStep(70, 91)).toBe(90)
  expect(crossedStep(51, 60)).toBeUndefined()
  expect(crossedStep(undefined, 95)).toBeUndefined()
})
