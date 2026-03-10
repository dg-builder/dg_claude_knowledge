# Learnings

## User Working Style
- Hands-on, correction-driven. Launches into tasks without detailed specs and course-corrects aggressively. When redirected, take the correction seriously and don't repeat the mistake.
- Values efficiency above all — don't tolerate wasted cycles. Never run unnecessary work (full test suites, broad searches) when targeted work is possible.
- Monitors Claude's work closely. Show diffs before committing bug fixes. Don't make large changes without checking in.
- Treats Claude as a powerful accelerator for genuinely difficult systems work — not for trivial tasks. Match that level.
- When user says "let's talk through" something, present options concisely and let them pick — don't just implement.

## Domain Knowledge (Cross-Project)
- ...

## Patterns & Conventions
- When fixing bugs, make ONLY the minimal fix and necessary comments. No debug instrumentation, safety guards, or refactoring alongside bug fixes.
- When merging branches, KEEP all incoming test code by default. Never drop tests from the incoming branch unless explicitly told to.
- Never add "Co-Authored-By: Claude" to commits.
- Fix failing tests one at a time, not all at once. Diagnose -> fix -> verify each before moving to the next.
- Before making changes in any worktree, confirm: (1) which directory is the source, (2) which build file to use, (3) current git branch. Don't assume paths.
- After a multi-fix push, do a dedup pass: look for identical patterns that appear 2+ times. Fix-by-fix is correct for correctness, but consolidate before PR.

## Anti-Patterns
- Don't theorize about performance bottlenecks — measure first. Add timing instrumentation, collect data, then diagnose.
- When a project has duplicate source files, always verify which copy gets compiled. Editing the wrong copy wastes an entire debug cycle.
- Don't edit files outside the current working directory without asking.
- Don't start exploring or solving before confirming you're in the right directory and on the right branch. Multiple worktrees with different branches may exist.
- Don't try to fix multiple failing tests simultaneously. Iterate one at a time.
- Don't introduce abstractions, helpers, or "improvements" alongside bug fixes. Separate concerns into separate commits/PRs.
- Don't assume which build file to use — multiple may exist across worktrees. Always verify with `ls` first.
- Minimize tool calls. Batch work, use what you already know, do one Write instead of many Edits when making multiple changes.
- NEVER spawn Task tool agents for search/grep operations — each agent spawn triggers a permission approval prompt. Use Grep, Glob, and Read tools directly. Only use Task agents for genuine multi-step autonomous work.

## Document Writing Style
- For persuasive docs, lead with a punchy hook — short declarative sentences, not academic. Then back it up with stats and evidence.
- Use direct quotes from postmortems/Slack — they're more convincing than paraphrasing.
- Bullet lists > tables when the doc will be shared (tables render poorly in many contexts).
- Keep paragraphs tight — user will ask to condense multi-paragraph sections into single paragraphs.

## Tool & Workflow Notes
- For complex diagnostic tools, write output to files instead of console. File-based output allows detailed inspection, side-by-side comparison, and doesn't clutter console.
- User uses git worktrees extensively for multi-branch work. May have multiple worktrees for the same repo on different branches.
- Always verify project paths (build files, test roots, schema locations) before executing builds.
- Debugging workflow is: catalog failures -> isolate failing case -> diagnose root cause -> write targeted fix -> verify. Follow this loop.
- When generating PR descriptions, read the full commit history from branch divergence point — not just the latest commit.
- This knowledge system itself is git-controlled. Edit the knowledge repo files directly — they're symlinked into ~/.claude/. Commit and push after updates.
- When user corrects a factual assumption, fix it everywhere in the knowledge base — not just one file. Grep for the incorrect statement across all files.

## Memory System
- Memory updates get dropped after task completion because attention shifts to "done" state. The post-task update is the hardest moment to remember — there's no hard trigger, just a soft instruction buried in a long rules file.
