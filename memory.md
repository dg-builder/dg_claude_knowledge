## Persistent Memory System

You have access to a knowledge repository at `~/dg_claude_knowledge/` that persists across Claude Code sessions. This is a git repo — commit and push all changes.

### Repo Structure
```
~/dg_claude_knowledge/
├── memory.md              # THIS FILE — global rule for all Claude instances
├── settings.json          # Claude Code settings (model, hooks, permissions)
├── setup.sh               # Creates symlinks (run once per machine)
├── README.md
├── hooks/                 # Claude Code hook scripts
│   ├── session-start.sh   # SessionStart: injects knowledge files into context
│   ├── post-compact-context.sh  # SessionStart(compact): re-injects after compaction
│   ├── pre-compact.sh     # PreCompact: reminds to save state before summarization
│   └── memory-reminder.sh # Stop: blocks exit if memory needs updating
├── scripts/               # Analysis & maintenance scripts
│   └── extract-knowledge-usage.sh  # Analyze knowledge file reads from JSONL logs
└── knowledge/             # All accumulated knowledge
    ├── active-context.md  # Lightweight index of all projects + status
    ├── session-log.md     # Reverse-chronological log of all sessions
    ├── learnings.md       # Accumulated patterns, preferences, & domain knowledge
    └── projects/          # Per-project notes (all detail lives here)
        ├── <name>.md
        └── archive/       # Completed projects
```

**Symlinks**: `~/.claude/settings.json` and `~/.claude/rules/memory.md` are symlinks pointing into this repo. Editing the repo files directly updates the live Claude Code config.

### What You Can Modify
- **Knowledge files** (`knowledge/`): Update freely during normal work (see sections below)
- **settings.json**: Edit to add permissions, hooks, or change settings. Changes take effect on the next Claude Code session.
- **memory.md** (this file): Edit to improve these instructions — e.g., add new rules, refine the session workflow, adjust growth limits. You ARE allowed to improve your own instructions.
- **New files**: Add new config files or knowledge files as needed. Update `setup.sh` if new files need symlinks.

All changes to any file in this repo should be committed and pushed.

### Session Start
The SessionStart hook automatically injects `active-context.md`, `learnings.md`, and recent `session-log.md` entries into your context. After context compaction, a post-compact hook re-injects `active-context.md` and `learnings.md`. **These are already loaded — do not re-read them.**

**After reviewing the injected context:**
1. **Internalize `learnings.md`** — it contains user corrections, anti-patterns, and working style preferences accumulated across all past sessions. Violating these is the #1 source of user frustration. Pay special attention to the Anti-Patterns and Patterns & Conventions sections.
2. **If the task needs project context** (debugging, multi-file changes, continuing prior work): Read the matched project file from `~/dg_claude_knowledge/knowledge/projects/`. Match on repo name, directory name, or build file heuristics. The project mapping table in `active-context.md` tells you which file to read.
3. **If you need more session history**: Read `session-log.md` for full trajectory (the hook only shows recent entries).

Skip step 2 for simple, self-contained tasks (e.g., "change this function name", "fix this typo").

### During Work

**IMMEDIATE updates (do right away, don't wait to be asked):**
- **User corrections**: When the user corrects your behavior, approach, or a factual assumption, IMMEDIATELY update `learnings.md` and commit/push. These corrections are exactly what future instances need most.
- **Session log**: After completing a meaningful unit of work (not every small change, but after finishing a task or set of related changes), add an entry to `session-log.md`. Don't wait for session end — sessions often end abruptly and the update gets lost.
- **Project file**: Update `Active Workstreams` when branch/PR status changes (new branch, PR created, PR merged, etc.).
- **Feature/capability added**: When you add a new feature, command, option, or task to a project:
  1. Update the project file's **Build & Test** section with usage (command, flags, when to use it)
  2. Update any existing README in the affected project directory
  3. If the feature solves a recurring workflow problem, add a usage recommendation to `learnings.md`
  This is the most commonly missed update — the session log captures *what* was built but not *how to use it*.

**Opportunistic updates (when you notice something worth capturing):**
- A debugging insight or root cause that was non-obvious → add to the **project file**, not learnings.md
- A project convention or path that was initially confusing → project file
- A cross-project workflow pattern that works well (or doesn't) → learnings.md

Don't update notes for routine work. Only capture things that would help a future Claude instance avoid mistakes or work faster.

### How to Update This Repo
Any file in `~/dg_claude_knowledge/` can be edited directly. Key files:

- `active-context.md` — Project index. Update only your project's entry; carry forward others.
- `session-log.md` — Rolling log. **1-2 lines per entry**: date, project, what + key outcome. Implementation details go in project files. Prune at ~50 entries.
- `learnings.md` — Cross-project patterns only (not project-specific architecture). Date-stamped. Sections: User Working Style, Domain Knowledge, Patterns & Conventions, Anti-Patterns, Document Writing Style, Tool & Workflow Notes.
- `projects/<name>.md` — All project detail: Context, Active Workstreams, Key Paths, Build & Test, Known Issues. Project-specific debugging insights and architecture notes go here, not in learnings.md. Completed projects go in `projects/archive/`.
- Config: `settings.json` (permissions/hooks), `memory.md` (these instructions), `setup.sh` (symlinks).

To persist: `git -C ~/dg_claude_knowledge add -A && git -C ~/dg_claude_knowledge commit -m "<summary>" && git -C ~/dg_claude_knowledge push`

### Session End
If the user signals they're wrapping up, do a final sweep — but most updates should already be done by now:
1. Verify session-log.md has an entry for this session (add one if not)
2. Update active-context.md if project status changed
3. Commit and push any pending changes

### Growth Management
- `active-context.md`: Keep under 50 lines. It's an index — one entry per project, no detail.
- `session-log.md`: Keep under 50 entries (~60 lines). Prune oldest entries when it grows. This is a rolling window, not a permanent archive.
- `learnings.md`: Keep under 200 lines. Consolidate related entries when it grows.
- Project files: Keep under 100 lines each. Focus on what's actionable.
- If any file exceeds these limits, tell the user it needs condensing and offer to do it.

### Format
- Concise bullet points, not prose
- Date-stamp entries in learnings.md (YYYY-MM-DD)
- Actionable entries: "Use X instead of Y because Z" not "Discovered that X exists"
