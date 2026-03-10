# Claude Code Persistent Knowledge

Persistent knowledge base for [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Every Claude instance reads from and writes to this repo, compounding knowledge across sessions.

## What This Does

Claude Code is stateless — each session starts fresh. This repo gives it long-term memory:
- **Hooks** inject accumulated knowledge into every conversation automatically
- **Rules** (`memory.md`) teach Claude how to maintain its own knowledge base
- **Knowledge files** store learnings, project context, and session history

The result: Claude remembers your corrections, knows your codebase conventions, and builds on past work instead of starting from scratch.

## Structure

```
├── memory.md              # Global rule (symlinked to ~/.claude/rules/memory.md)
├── settings.json          # Claude Code settings (symlinked to ~/.claude/settings.json)
├── setup.sh               # Run once to create symlinks
├── hooks/
│   ├── session-start.sh   # SessionStart: injects knowledge files into context
│   ├── post-compact-context.sh  # Re-injects knowledge after context compaction
│   ├── pre-compact.sh     # Reminds to save state before compaction
│   └── memory-reminder.sh # Stop: blocks exit if memory needs updating
├── scripts/
│   └── extract-knowledge-usage.sh  # Analyze knowledge file reads from JSONL logs
└── knowledge/
    ├── active-context.md  # Project index + status
    ├── session-log.md     # Reverse-chronological work log
    ├── learnings.md       # Accumulated patterns, corrections, & anti-patterns
    └── projects/          # Per-project notes
        ├── <name>.md
        └── archive/       # Completed projects
```

## Setup

1. Clone this repo to your home directory:
   ```bash
   git clone git@github.com:dg-builder/dg_claude_knowledge.git ~/dg_claude_knowledge
   ```

2. Run the setup script to create symlinks:
   ```bash
   cd ~/dg_claude_knowledge && ./setup.sh
   ```

3. Start a Claude Code session — the hooks will automatically inject knowledge context.

## How It Works

1. **`memory.md`** is loaded as a global rule on every Claude Code session. It teaches Claude how to read and update the knowledge base.
2. **`SessionStart` hook** injects `active-context.md`, `learnings.md`, and recent `session-log.md` directly into the conversation — Claude doesn't need to read them manually.
3. **`PreCompact` hook** reminds Claude to save important context before it gets compacted away.
4. **`PostCompact` hook** re-injects durable knowledge after context compaction.
5. **`Stop` hook** blocks exit if substantive work was done without updating knowledge files.
6. Claude reads relevant project notes before starting work, updates all knowledge files during/after.
7. Changes are committed and pushed to this repo for persistence across machines.

## Customization

### settings.json

The included `settings.json` has minimal permissions and hooks pre-configured. You'll want to customize:
- **`permissions.allow`** — Add tool permissions for your workflow (build commands, git operations, etc.)
- **`hooks`** — The knowledge hooks are pre-configured; add your own as needed
- **`enabledPlugins`** — Enable Claude Code plugins you use

### Knowledge Files

- **`active-context.md`** — Add your projects to the mapping table
- **`learnings.md`** — Will grow automatically as Claude learns your preferences
- **`projects/`** — Create `<project-name>.md` files for each project you work on

See `knowledge/projects/example-web-app.md` for an example project file.

## Tips

- **Correct Claude aggressively** — corrections get saved to `learnings.md` and persist across all future sessions
- **Keep files concise** — the system has built-in growth limits to prevent bloat
- **Commit often** — Claude will commit/push knowledge updates, but you can also edit files directly
- **Use project files** for project-specific context; use `learnings.md` for cross-project patterns only
