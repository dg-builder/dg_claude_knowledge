#!/bin/bash
# Extract all Read/Write/Edit tool calls on dg_claude_knowledge/knowledge/ files
# from Claude Code conversation logs (JSONL files under ~/.claude/projects/).
#
# This finds actual tool_use invocations — not system-reminder context injection
# or hook messages. Useful for analyzing when agents looked up knowledge files
# for context vs. when they updated them.
#
# USAGE:
#   ./scripts/extract-knowledge-usage.sh                  # outputs to /tmp/
#   ./scripts/extract-knowledge-usage.sh /path/to/outdir  # outputs to custom dir
#
# OUTPUTS:
#   <outdir>/knowledge_reads.csv   — Read tool calls (agent looked up context)
#   <outdir>/knowledge_writes.csv  — Write/Edit tool calls (agent updated files)
#
# CSV COLUMNS (reads):
#   jsonl_file, line_num, session_id, git_branch, target_knowledge_file
#
# CSV COLUMNS (writes):
#   jsonl_file, line_num, session_id, git_branch, operation, target_knowledge_file
#
# EXAMPLES:
#   # Run and inspect reads
#   ./scripts/extract-knowledge-usage.sh
#   column -t -s, /tmp/knowledge_reads.csv | less
#
#   # Count reads per knowledge file
#   tail -n+2 /tmp/knowledge_reads.csv | cut -d, -f5 | sort | uniq -c | sort -rn
#
#   # Find all reads in a specific session
#   grep "50345b40" /tmp/knowledge_reads.csv

set -euo pipefail

OUTDIR="${1:-/tmp}"
OUTPUT="${OUTDIR}/knowledge_reads.csv"
OUTPUT_WRITES="${OUTDIR}/knowledge_writes.csv"

echo "jsonl_file,line_num,session_id,git_branch,target_knowledge_file" > "$OUTPUT"

# Find all JSONL files under .claude/projects
find ~/.claude/projects -name "*.jsonl" -type f 2>/dev/null | while read -r jsonl; do
  grep -n '"name":"Read"' "$jsonl" 2>/dev/null | grep "dg_claude_knowledge/knowledge/" | grep '"tool_use"' | while read -r match; do
    line_num=$(echo "$match" | cut -d: -f1)
    session_id=$(echo "$match" | grep -o '"sessionId":"[^"]*"' | head -1 | cut -d'"' -f4)
    git_branch=$(echo "$match" | grep -o '"gitBranch":"[^"]*"' | head -1 | cut -d'"' -f4)
    target_file=$(echo "$match" | grep -o '"file_path":"[^"]*dg_claude_knowledge/knowledge/[^"]*"' | head -1 | cut -d'"' -f4)
    short_jsonl=$(basename "$jsonl")
    echo "${short_jsonl},${line_num},${session_id},${git_branch},${target_file}" >> "$OUTPUT"
  done
done

# Also check Write/Edit tool_use calls
echo "jsonl_file,line_num,session_id,git_branch,operation,target_knowledge_file" > "$OUTPUT_WRITES"

find ~/.claude/projects -name "*.jsonl" -type f 2>/dev/null | while read -r jsonl; do
  grep -n '"tool_use"' "$jsonl" 2>/dev/null | grep "dg_claude_knowledge/knowledge/" | grep -E '"name":"(Write|Edit)"' | while read -r match; do
    line_num=$(echo "$match" | cut -d: -f1)
    session_id=$(echo "$match" | grep -o '"sessionId":"[^"]*"' | head -1 | cut -d'"' -f4)
    git_branch=$(echo "$match" | grep -o '"gitBranch":"[^"]*"' | head -1 | cut -d'"' -f4)
    op=$(echo "$match" | grep -o '"name":"[^"]*"' | head -1 | cut -d'"' -f4)
    target_file=$(echo "$match" | grep -oE '"file_path":"[^"]*dg_claude_knowledge/knowledge/[^"]*"' | head -1 | cut -d'"' -f4)
    if [ -z "$target_file" ]; then
      target_file=$(echo "$match" | grep -oE 'dg_claude_knowledge/knowledge/[^"\\]*' | head -1)
    fi
    short_jsonl=$(basename "$jsonl")
    echo "${short_jsonl},${line_num},${session_id},${git_branch},${op},${target_file}" >> "$OUTPUT_WRITES"
  done
done

reads=$(( $(wc -l < "$OUTPUT") - 1 ))
writes=$(( $(wc -l < "$OUTPUT_WRITES") - 1 ))
echo "Done: ${reads} reads → ${OUTPUT}"
echo "      ${writes} writes → ${OUTPUT_WRITES}"
