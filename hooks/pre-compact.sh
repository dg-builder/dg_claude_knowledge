#!/bin/bash
# PreCompact hook: Fires before context compaction. Reminds the agent to
# save any important state to the knowledge repo before it gets summarized away.
# Cannot block compaction — output is informational only.

KNOWLEDGE_DIR=~/dg_claude_knowledge/knowledge

cat <<'MSG'
CONTEXT COMPACTION IMMINENT — Save state before it's lost:

1. If you have unsaved debugging insights, root causes, or important context
   from this session, update learnings.md or the project file NOW.
2. If you've completed work that isn't logged yet, add a session-log.md entry.
3. Commit and push ~/dg_claude_knowledge/ if you made updates.

After compaction, learnings.md and active-context.md will be re-injected
automatically. But session-specific context (what you tried, what failed,
intermediate state) will be lost unless you save it.
MSG
