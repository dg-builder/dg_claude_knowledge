#!/bin/bash
# Stop hook: Reminds the main agent to update memory after substantive work.
# Reads hook input JSON from stdin. Checks transcript for work vs memory updates.
# Exits 2 (block stop) with a reminder if memory needs updating.

INPUT=$(cat)

# Prevent infinite loops: if stop hook already fired, let Claude stop
STOP_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')
if [ "$STOP_ACTIVE" = "true" ]; then
  exit 0
fi

TRANSCRIPT=$(echo "$INPUT" | jq -r '.transcript_path // empty')
if [ -z "$TRANSCRIPT" ] || [ ! -f "$TRANSCRIPT" ]; then
  exit 0
fi

# Check if substantive work was done (Write/Edit to non-knowledge-repo files, or meaningful Bash)
TOTAL_WRITES=$(grep -cE '"(Write|Edit)"' "$TRANSCRIPT" 2>/dev/null | head -1)
KNOWLEDGE_WRITES=$(grep -E '"(Write|Edit)"' "$TRANSCRIPT" 2>/dev/null | grep -c 'dg_claude_knowledge' | head -1)
# Substantive work = writes that aren't to the knowledge repo
NON_KNOWLEDGE_WRITES=$(( ${TOTAL_WRITES:-0} - ${KNOWLEDGE_WRITES:-0} ))

BASH_WORK=$(grep -cE '(cargo |gradlew |npm |git commit|make )' "$TRANSCRIPT" 2>/dev/null | head -1)

if [ "${NON_KNOWLEDGE_WRITES:-0}" -le 0 ] && [ "${BASH_WORK:-0}" -le 0 ]; then
  exit 0  # No substantive work, no reminder needed
fi

# Check if memory was already updated (writes targeting knowledge/ files)
MEMORY_UPDATED=$(grep -E '"(Write|Edit)"' "$TRANSCRIPT" 2>/dev/null | grep -c 'dg_claude_knowledge/' | head -1)

if [ "${MEMORY_UPDATED:-0}" -gt 0 ]; then
  exit 0  # Memory was updated, no reminder needed
fi

# Memory needs updating — block stop with reminder
cat >&2 <<'MSG'
MEMORY UPDATE NEEDED: You completed substantive work this session but haven't updated the knowledge repository.

Checklist before stopping:
1. session-log.md — Add 1-2 line entry (date | project | what + key outcome)
2. Project file — Update Active Workstreams (branch/PR status changes)
3. learnings.md — Cross-project patterns only. Reflect on this session:
   - User corrections or critiques — these are the HIGHEST VALUE learnings
   - Cross-project workflow patterns or anti-patterns to avoid
   - Project-specific debugging/architecture notes go in the PROJECT FILE, not here
   Only add entries that would change future behavior. Skip if nothing novel.
4. Feature docs — If you added new features/commands/options, update:
   - Project file Build & Test section with usage
   - Any existing README in the affected project
5. Commit and push ~/dg_claude_knowledge/
MSG
exit 2
