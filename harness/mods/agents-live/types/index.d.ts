export type FeedKind = 'says' | 'tool' | 'error'

// One thing an agent did: what it said, or a call with its input and the tail of its output.
export type FeedEntry = { kind: FeedKind; label: string; title: string; input: string[]; output: string[] }

export type AgentFeed = { id: string; description: string; status: string; entries: FeedEntry[] }

declare module 'claude-code' {
  interface PluginState {
    'agents-live': { feeds: AgentFeed[] }
  }
}
