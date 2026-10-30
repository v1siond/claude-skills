#!/usr/bin/env node
// Make post media with Playwright and sharp. Writes only the outputs named; refuses to overwrite them.
//
//   node media.mjs shot <url> <out.png> [--size 1440x900] [--scale 1] [--selector css] [--hide css,css]
//                       [--wait-for css] [--full]
//   node media.mjs shots <shots.json>       one browser for a list of {url, out, size?, scale?, selector?,
//                                           hide?, waitFor?, click?, wait?, full?}
//   node media.mjs clip <url> <out.webm> [--size 1280x720] [--seconds 6] [--steps steps.json] [--hide css]
//                       steps: [{"click": css} | {"hover": css} | {"scroll": px} | {"wait": ms} | {"type": [css, text]}]
//   node media.mjs svg <in.svg> <out.png> [--width 1600]      sharp, no browser
//   node media.mjs preview <post-folder> <out.png> [--size 390x844]   post.md as a plain page, full length
//   node media.mjs --self-test                                 svg route only (no browser)
//
// Needs node 18 or newer (v24 under ~/.nvm). Playwright and sharp resolve from the project's node_modules
// unless PLAYWRIGHT_FROM names another package.json. Check that no browser is running before a browser mode.
import { createRequire } from 'node:module'
import fs from 'node:fs'
import os from 'node:os'
import path from 'node:path'
import { pathToFileURL } from 'node:url'

const require = createRequire(process.env.PLAYWRIGHT_FROM || path.join(process.cwd(), 'package.json'))
const args = process.argv.slice(2)
const flag = (name, fallback) => { const i = args.indexOf(name); return i === -1 ? fallback : args[i + 1] }
const dims = (s) => s.split('x').map(Number)
const refuse = (f) => { if (fs.existsSync(f)) { console.error(`refusing to overwrite ${f}`); process.exit(1) } }
const usage = () => { console.error(fs.readFileSync(new URL(import.meta.url), 'utf8').split('\n').slice(1, 14).join('\n')); process.exit(2) }

async function browser() {
  const { chromium } = require('playwright')
  return chromium.launch({ args: ['--force-color-profile=srgb', '--hide-scrollbars'] })
}

async function settle(page, { hide, waitFor, click, wait }) {
  await page.evaluate(() => document.fonts.ready)
  if (hide) await page.addStyleTag({ content: `${[].concat(hide).join(',')} { display: none !important; }` })
  if (waitFor) await page.waitForSelector(waitFor, { timeout: 15000 })
  if (click) await page.click(click, { timeout: 15000 })
  if (wait) await page.waitForTimeout(wait)
}

async function shoot(b, s) {
  refuse(s.out)
  const [width, height] = dims(s.size || '1440x900')
  const ctx = await b.newContext({ viewport: { width, height }, deviceScaleFactor: Number(s.scale || 1) })
  const page = await ctx.newPage()
  await page.goto(s.url, { waitUntil: 'networkidle', timeout: 30000 })
  await settle(page, s)
  fs.mkdirSync(path.dirname(s.out), { recursive: true })
  const target = s.selector ? page.locator(s.selector).first() : page
  await target.screenshot({ path: s.out, fullPage: s.selector ? undefined : Boolean(s.full), timeout: 15000 })
  const box = s.selector ? await page.locator(s.selector).first().boundingBox({ timeout: 15000 }) : { width, height }
  console.log(`${s.out} ${Math.round(box.width)}x${Math.round(box.height)} css px at scale ${s.scale || 1}`)
  await ctx.close()
}

async function clip(url, out) {
  refuse(out)
  const [width, height] = dims(flag('--size', '1280x720'))
  const steps = flag('--steps', null) ? JSON.parse(fs.readFileSync(flag('--steps'), 'utf8')) : []
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'clip-'))
  const b = await browser()
  const ctx = await b.newContext({ viewport: { width, height }, recordVideo: { dir, size: { width, height } } })
  const page = await ctx.newPage()
  const t0 = Date.now()
  await page.goto(url, { waitUntil: 'networkidle', timeout: 30000 })
  await settle(page, { hide: flag('--hide', null)?.split(',') })
  for (const s of steps) {
    if (s.click) await page.click(s.click, { timeout: 15000 })
    if (s.hover) await page.hover(s.hover, { timeout: 15000 })
    if (s.scroll) await page.mouse.wheel(0, s.scroll)
    if (s.type) await page.locator(s.type[0]).pressSequentially(s.type[1], { delay: 80, timeout: 15000 })
    if (s.wait) await page.waitForTimeout(s.wait)
    console.log(`step ${JSON.stringify(s)} at ${((Date.now() - t0) / 1000).toFixed(2)} s`)
  }
  await page.waitForTimeout(Number(flag('--seconds', 6)) * 1000)
  const video = page.video()
  await ctx.close()
  await b.close()
  fs.mkdirSync(path.dirname(out), { recursive: true })
  fs.copyFileSync(await video.path(), out)
  console.log(`${out} take ${((Date.now() - t0) / 1000).toFixed(1)} s by the wall clock. Step times are approximate under load:`)
  console.log(`find the start with web.sh strip ${out} strip.png <about the last step time minus 2>, then web.sh clip <in> <base> <start> <len>`)
}

async function svg(input, out, width) {
  refuse(out)
  const sharp = require('sharp')
  const info = await sharp(fs.readFileSync(input), { density: 300 }).resize({ width }).png().toFile(out)
  console.log(`${out} ${info.width}x${info.height} ${info.size} bytes`)
}

// A plain renderer for the subset a post uses: headings, paragraphs, lists, images, video, links, code.
function toHtml(md) {
  const esc = (s) => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
  const inline = (s) => esc(s).replace(/!\[([^\]]*)\]\(([^)]+)\)/g, '<img alt="$1" src="$2">')
    .replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2">$1</a>').replace(/`([^`]+)`/g, '<code>$1</code>')
    .replace(/\*\*([^*]+)\*\*/g, '<b>$1</b>')
  const out = []
  let code = null, list = false
  for (const line of md.split('\n')) {
    if (line.startsWith('```')) { if (code) { out.push(`<pre><code>${esc(code.join('\n'))}</code></pre>`); code = null } else code = []; continue }
    if (code) { code.push(line); continue }
    if (/^\s*[-*] /.test(line)) { if (!list) { out.push('<ul>'); list = true } out.push(`<li>${inline(line.replace(/^\s*[-*] /, ''))}</li>`); continue }
    if (list) { out.push('</ul>'); list = false }
    const h = line.match(/^(#{1,4}) (.*)/)
    if (h) out.push(`<h${h[1].length}>${inline(h[2])}</h${h[1].length}>`)
    else if (/^<(video|figure|picture)/.test(line.trim())) out.push(line)
    else if (line.trim()) out.push(`<p>${inline(line)}</p>`)
  }
  return `<!doctype html><meta charset="utf-8"><style>body{font:17px/1.6 system-ui,sans-serif;margin:16px;color:#1f2328;background:#fff}
img,video{max-width:100%;height:auto}pre{overflow-x:auto;background:#f6f8fa;padding:12px;font-size:13px}code{font-family:ui-monospace,monospace}</style>${out.join('\n')}`
}

async function preview(folder, out) {
  refuse(out)
  const html = path.join(folder, '.preview.html')
  fs.writeFileSync(html, toHtml(fs.readFileSync(path.join(folder, 'post.md'), 'utf8')))
  try { await withBrowser((b) => shoot(b, { url: pathToFileURL(html).href, out, size: flag('--size', '390x844'), full: true })) }
  finally { fs.rmSync(html) }
}

async function withBrowser(fn) { const b = await browser(); try { await fn(b) } finally { await b.close() } }

async function selfTest() {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'media-'))
  const input = path.join(dir, 'a.svg')
  fs.writeFileSync(input, '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 200"><rect width="400" height="200" fill="#ddf4ff"/><text x="20" y="100" font-family="sans-serif" font-size="32">ok</text></svg>')
  await svg(input, path.join(dir, 'a.png'), 800)
  const html = toHtml('# T\n\n![alt](media/a.webp)\n\n```ts\nconst a = 1 < 2\n```\n- one\n')
  if (!html.includes('<h1>T</h1>') || !html.includes('<img alt="alt"') || !html.includes('1 &lt; 2') || !html.includes('<li>one</li>')) throw new Error('toHtml')
  fs.rmSync(dir, { recursive: true })
  console.log('self-test ok')
}

const [mode, a, b] = args
if (mode === '--self-test') await selfTest()
else if (mode === 'shot' && a && b) await withBrowser((br) => shoot(br, { url: a, out: b, size: flag('--size'), scale: flag('--scale'),
  selector: flag('--selector'), hide: flag('--hide', null)?.split(','), waitFor: flag('--wait-for'), full: args.includes('--full') }))
else if (mode === 'shots' && a) await withBrowser(async (br) => { for (const s of JSON.parse(fs.readFileSync(a, 'utf8'))) await shoot(br, s) })
else if (mode === 'clip' && a && b) await clip(a, b)
else if (mode === 'svg' && a && b) await svg(a, b, Number(flag('--width', 1600)))
else if (mode === 'preview' && a && b) await preview(path.resolve(a), b)
else usage()
