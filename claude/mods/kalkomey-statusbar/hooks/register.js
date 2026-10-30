// A one-line status bar above the prompt in the Claude desktop app (the Code tab):
//   [Sonnet] ▓▓▓░░░░░░░ 37% ctx | $1.23 | 12m 34s
// It shows what claude/statusline.sh shows in the terminal. The terminal already has
// that script, so this draws only where e.surface is 'desktop'.
//
// Every value is read defensively: a field the app does not provide is left out of the
// line instead of breaking it. Nothing here reads files, runs processes or uses the network.

const BAR_WIDTH = 10

function bar(percent) {
  const filled = Math.max(0, Math.min(BAR_WIDTH, Math.round((percent / 100) * BAR_WIDTH)))
  return '▓'.repeat(filled) + '░'.repeat(BAR_WIDTH - filled)
}

// "claude-sonnet-5-5", "Sonnet 5.5" -> "Sonnet"
function shortModel(name) {
  if (typeof name !== 'string' || !name) return ''
  const m = name.match(/opus|sonnet|haiku|fable/i)
  if (!m) return name
  return m[0][0].toUpperCase() + m[0].slice(1).toLowerCase()
}

// The cost may arrive as a number or as an object; accept the usual spellings.
function costUsd(cost) {
  if (typeof cost === 'number') return cost
  if (cost && typeof cost === 'object') {
    for (const k of ['total_cost_usd', 'totalCostUsd', 'totalUsd', 'usd', 'total']) {
      if (typeof cost[k] === 'number') return cost[k]
    }
  }
  return null
}

function elapsedMs(usage) {
  const s = usage && usage.startedAt
  const start = typeof s === 'number' ? s : typeof s === 'string' ? Date.parse(s) : NaN
  if (!Number.isFinite(start)) return null
  // Epoch seconds and epoch milliseconds both occur in the wild; tell them apart.
  const startMs = start < 1e12 ? start * 1000 : start
  return Math.max(0, Date.now() - startMs)
}

function duration(ms) {
  const total = Math.floor(ms / 1000)
  const h = Math.floor(total / 3600)
  const m = Math.floor((total % 3600) / 60)
  const s = total % 60
  return h > 0 ? h + 'h ' + m + 'm' : m + 'm ' + s + 's'
}

async function line($) {
  const parts = []

  let model = ''
  try {
    model = shortModel(await $.session.model())
  } catch {}
  if (model) parts.push('[' + model + ']')

  let usage = null
  try {
    usage = await $.session.usage()
  } catch {}

  const pct = usage && usage.context && usage.context.percent
  if (typeof pct === 'number') {
    parts.push(bar(pct) + ' ' + Math.round(pct) + '% ctx')
  }

  const cost = usage ? costUsd(usage.cost) : null
  const left = []
  if (cost !== null) left.push('$' + cost.toFixed(2))
  const ms = usage ? elapsedMs(usage) : null
  if (ms !== null) left.push(duration(ms))

  return parts.concat(left.length ? ['| ' + left.join(' | ')] : []).join(' ')
}

export function register(on) {
  // The band is drawn when something changes; ask for a redraw on a slow timer so the
  // duration moves, and after each turn so context and cost are current.
  on('session.start', async ($, e, next) => {
    $.clock.every(15000, () => $.ui.invalidate('ui.render'))
    return next(e)
  })
  on('turn.complete', async ($, e, next) => {
    $.ui.invalidate('ui.render')
    return next(e)
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    if (e.surface !== 'desktop') return next(e)
    const text = await line($)
    if (!text) return next(e)
    const { Box, Text } = $.ui.resolve(e)
    // Keep whatever mods after this one draw in the band, and add our line above it.
    const theirs = await next(e)
    return Box({
      flexDirection: 'column',
      children: theirs ? [Text({ dimColor: true, children: [text] }), theirs] : [Text({ dimColor: true, children: [text] })],
    })
  })
}
