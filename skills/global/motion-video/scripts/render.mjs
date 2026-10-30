#!/usr/bin/env node
// Capture frames of a page with Playwright. Writes PNGs into --out and nothing else.
//
//   node render.mjs <page.html|url> --out DIR --stills 0,1.2,2.5      stills at key times, still_<t>.png
//   node render.mjs <page.html|url> --out DIR --duration 4 --fps 30   every frame, f_<index>.png
//        [--subframes 4 --shutter 0.5]   N captures per frame, spread over the shutter, blended by encode.sh
//        [--from 1.0 --to 2.0]           only that window, same file numbers as a full run
//   node render.mjs <page.html|url> --purity 1.2   seek 1.2, then 0 and the end, then 1.2 again; exit 1 if
//                                                   the two captures of 1.2 differ (state leaks between frames)
//   --live      the page has no seek(t) (a running app, the engine's own canvas): Playwright's fake clock
//               drives Date, timers and requestAnimationFrame, and time only moves forward
//               [--settle 1.0] seconds of page time to run before t = 0
//   common:     --size 1920x1080  --scale 1 (2 supersamples)  --timeout 30000
//
// Seek page contract (references/engine-contract.md): window.seek(t), sync or async, draws time t from t
// alone; window.ready becomes true once fonts and images are loaded. A local file gets ?render=1 so the page
// can skip its preview clock. Needs node 18 or newer (v24 is under ~/.nvm). Playwright resolves from
// the node_modules of the folder it runs in unless PLAYWRIGHT_FROM names another package.json.
import { createRequire } from 'node:module'
import fs from 'node:fs'
import path from 'node:path'
import { pathToFileURL } from 'node:url'

const require = createRequire(process.env.PLAYWRIGHT_FROM || path.join(process.cwd(), 'package.json'))
const { chromium } = require('playwright')

const args = process.argv.slice(2)
const flag = (name, fallback) => {
  const i = args.indexOf(name)
  return i === -1 ? fallback : args[i + 1]
}
const target = args[0]
if (!target || target.startsWith('--')) {
  console.error('usage: render.mjs <page.html|url> --out DIR (--stills t,t | --duration T [--fps N] | --purity t) [--live]')
  process.exit(2)
}
const LIVE = args.includes('--live')
const [W, H] = flag('--size', '1920x1080').split('x').map(Number)
const SCALE = Number(flag('--scale', 1))
const TIMEOUT = Number(flag('--timeout', 30000))
const OUT = flag('--out', null)
const purity = flag('--purity', null)
if (!OUT && purity === null) { console.error('--out DIR is required'); process.exit(2) }
if (LIVE && purity !== null) { console.error('--purity checks a seek page; a --live page has no seek'); process.exit(2) }

const url = /^https?:|^file:/.test(target) ? target : `${pathToFileURL(path.resolve(target)).href}?render=1`

// Flags that keep two runs of the same frame pixel identical.
const browser = await chromium.launch({
  args: ['--font-render-hinting=none', '--force-color-profile=srgb', '--disable-threaded-animation',
    '--disable-checker-imaging', '--hide-scrollbars'],
})
const page = await browser.newPage({ viewport: { width: W, height: H }, deviceScaleFactor: SCALE })
const errors = []
page.on('pageerror', (e) => errors.push(e.message))
const started = Date.now()

const fail = async (message) => {
  console.error(message)
  errors.forEach((m) => console.error(`page error: ${m}`))
  await browser.close()
  process.exit(1)
}
const done = async (summary, code = 0) => {
  errors.forEach((m) => console.error(`page error: ${m}`))
  console.log(JSON.stringify({ ...summary, live: LIVE, pageErrors: errors.length, ms: Date.now() - started }))
  await browser.close()
  process.exit(errors.length ? 1 : code)
}

// Installed and paused before the page loads, so page time is 0 at load and moves only through runFor.
if (LIVE) { await page.clock.install({ time: 0 }); await page.clock.pauseAt(0) }
try {
  await page.goto(url, { waitUntil: 'load', timeout: TIMEOUT })
  if (!LIVE) await page.waitForFunction(() => window.ready === true && typeof window.seek === 'function', null, { timeout: TIMEOUT })
} catch (e) {
  await fail(`page never became ready${LIVE ? '' : ' (window.ready and window.seek)'}: ${e.message.split('\n')[0]}`)
}

// Seek mode: freeze anything on the browser's own clock, so only seek(t) moves the picture.
if (!LIVE) {
  await page.evaluate(async () => {
    await document.fonts.ready
    const style = document.createElement('style')
    style.textContent = '*,*::before,*::after{transition:none!important;animation-play-state:paused!important}'
    document.head.appendChild(style)
    document.getAnimations().forEach((a) => a.pause())
  })
}

// Live mode: the fake clock only moves forward, so page time is tracked here.
let liveNow = 0
if (LIVE) await page.clock.runFor(Math.round(Number(flag('--settle', 1)) * 1000))
const moveTo = async (t) => {
  if (!LIVE) return page.evaluate(async (time) => {
    await window.seek(time)
    await new Promise((r) => requestAnimationFrame(() => requestAnimationFrame(r)))
  }, t)
  const ms = Math.round(t * 1000)
  if (ms < liveNow) await fail(`--live cannot go back in time (asked ${t}s after ${liveNow / 1000}s)`)
  if (ms > liveNow) await page.clock.runFor(ms - liveNow)
  liveNow = ms
}
const shoot = async (t, file) => {
  await moveTo(t)
  return page.screenshot(file ? { path: file } : {})
}

if (purity !== null) {
  const t = Number(purity)
  const end = Number(flag('--duration', t * 2 || 1))
  const first = await shoot(t)
  await shoot(0)
  await shoot(end)
  const again = await shoot(t)
  const same = Buffer.compare(first, again) === 0
  if (!same) console.error(`seek(${t}) drew a different frame the second time: the page keeps state between frames`)
  await done({ mode: 'purity', t, same }, same ? 0 : 1)
}

fs.mkdirSync(OUT, { recursive: true })
const stills = flag('--stills', null)
if (stills !== null) {
  const times = stills.split(',').map(Number).sort((a, b) => a - b)
  for (const t of times) await shoot(t, path.join(OUT, `still_${t.toFixed(3).padStart(8, '0')}.png`))
  await done({ mode: 'stills', out: OUT, count: times.length })
}

const DURATION = Number(flag('--duration', NaN))
if (!(DURATION > 0)) await fail('give --stills, --purity, or --duration T')
const FPS = Number(flag('--fps', 30))
const SUB = Math.max(1, Number(flag('--subframes', 1)))
const SHUTTER = Number(flag('--shutter', 0.5))
const total = Math.round(DURATION * FPS)
const firstFrame = Math.max(0, Math.floor(Number(flag('--from', 0)) * FPS))
const lastFrame = Math.min(total, Math.ceil(Number(flag('--to', DURATION)) * FPS))
// Subframe k of frame i sits inside the shutter, centred on the frame time.
const subTime = (i, k) => (SUB === 1 ? i / FPS : i / FPS + ((k + 0.5) / SUB - 0.5) * SHUTTER / FPS)
let count = 0
for (let i = firstFrame; i < lastFrame; i++) {
  for (let k = 0; k < SUB; k++) {
    await shoot(Math.max(0, subTime(i, k)), path.join(OUT, `f_${String(i * SUB + k).padStart(6, '0')}.png`))
    count++
  }
}
await done({ mode: 'frames', out: OUT, fps: FPS, subframes: SUB, frames: lastFrame - firstFrame, files: count })
