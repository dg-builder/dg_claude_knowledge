#!/bin/bash
# Setup script: symlinks Claude Code config files from this repo into ~/.claude/
# Run this once after cloning, or after adding new config files.

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# Symlink settings.json
mkdir -p ~/.claude
if [ -f ~/.claude/settings.json ] && [ ! -L ~/.claude/settings.json ]; then
    echo "Backing up existing ~/.claude/settings.json to ~/.claude/settings.json.bak"
    mv ~/.claude/settings.json ~/.claude/settings.json.bak
fi
ln -sf "$REPO_DIR/settings.json" ~/.claude/settings.json
echo "Linked: ~/.claude/settings.json -> $REPO_DIR/settings.json"

# Symlink memory.md into rules/
mkdir -p ~/.claude/rules
if [ -f ~/.claude/rules/memory.md ] && [ ! -L ~/.claude/rules/memory.md ]; then
    echo "Backing up existing ~/.claude/rules/memory.md to ~/.claude/rules/memory.md.bak"
    mv ~/.claude/rules/memory.md ~/.claude/rules/memory.md.bak
fi
ln -sf "$REPO_DIR/memory.md" ~/.claude/rules/memory.md
echo "Linked: ~/.claude/rules/memory.md -> $REPO_DIR/memory.md"

echo "Done. Claude Code will now use config from $REPO_DIR"
