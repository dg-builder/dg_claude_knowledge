#!/bin/bash
# Post-compaction context injection: Fires as a SessionStart hook with
# "compact" matcher after context compaction. Re-injects the key knowledge
# files that would otherwise be lost in the compacted summary.
#
# Injects: active-context.md (full) + learnings.md (full)
# Skips session-log.md — recent session history is in the compacted summary.

KNOWLEDGE_DIR=~/dg_claude_knowledge/knowledge

echo "=== POST-COMPACTION CONTEXT RE-INJECTION ==="
echo "The following knowledge files were re-injected after context compaction."
echo "Your compacted summary has session history. These have durable knowledge."

if [ -f "$KNOWLEDGE_DIR/active-context.md" ]; then
  echo ""
  echo "--- active-context.md ---"
  cat "$KNOWLEDGE_DIR/active-context.md"
fi

if [ -f "$KNOWLEDGE_DIR/learnings.md" ]; then
  echo ""
  echo "--- learnings.md (MUST READ — accumulated corrections & patterns) ---"
  cat "$KNOWLEDGE_DIR/learnings.md"
fi

echo ""
echo "--- Next: Read the matched project file if you need project-specific context. ---"
