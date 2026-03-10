#!/bin/bash
# SessionStart hook: Injects key knowledge files into the conversation context.
# This ensures every agent session — regardless of which repo it's in — starts
# with accumulated learnings, project status, and recent history.

KNOWLEDGE_DIR=~/dg_claude_knowledge/knowledge

echo "=== KNOWLEDGE REPO: ~/dg_claude_knowledge/ ==="

# Symlink health check
if ! test -L ~/.claude/settings.json || ! test -L ~/.claude/rules/memory.md; then
  echo "WARNING: ~/.claude symlinks broken — run ~/dg_claude_knowledge/setup.sh to restore"
fi

# Active context: project index + status (always small)
if [ -f "$KNOWLEDGE_DIR/active-context.md" ]; then
  echo ""
  echo "--- active-context.md ---"
  cat "$KNOWLEDGE_DIR/active-context.md"
fi

# Learnings: accumulated patterns, anti-patterns, user preferences.
# THIS IS THE MOST IMPORTANT FILE — contains corrections from past sessions
# that prevent repeating mistakes. Read it carefully.
if [ -f "$KNOWLEDGE_DIR/learnings.md" ]; then
  echo ""
  echo "--- learnings.md (MUST READ — accumulated corrections & patterns) ---"
  cat "$KNOWLEDGE_DIR/learnings.md"
fi

# Session log: recent work history for continuity (first 25 lines = header + ~3 recent entries)
if [ -f "$KNOWLEDGE_DIR/session-log.md" ]; then
  echo ""
  echo "--- session-log.md (recent entries) ---"
  head -25 "$KNOWLEDGE_DIR/session-log.md"
fi

echo ""
echo "--- Next: Read the matched project file from active-context.md if task needs project context. ---"
