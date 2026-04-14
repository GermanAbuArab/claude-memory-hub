# Claude Memory Hub Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Set up a 4-layer persistent memory system for Claude Code using an Obsidian vault, semantic memory (ChromaDB), and codebase knowledge graphs across 3 profiles (personal, roku, blend).

**Architecture:** One shared Obsidian vault (`~/obsidian-vault/`) with per-project folders, accessed by MCPVault MCP server. Semantic memory via mcp-memory-service with embedded ChromaDB. Codebase graphs via Graphify. All 3 Claude Code profiles share the same vault and memory store, scoped via CLAUDE.md instructions.

**Tech Stack:** MCPVault (`@bitbonsai/mcpvault`), mcp-memory-service (Python/ChromaDB), Graphify (`graphifyy` PyPI), Obsidian

**Spec:** `docs/superpowers/specs/2026-04-14-claude-memory-obsidian-hub-design.md`

---

## File Map

### Files to Create
- `~/obsidian-vault/` — entire vault directory structure
- `~/obsidian-vault/templates/adr-template.md` — Architecture Decision Record template
- `~/obsidian-vault/templates/context-template.md` — Project context template
- `~/obsidian-vault/templates/pattern-template.md` — Pattern documentation template
- `~/obsidian-vault/projects/roku/context.md` — Roku project context
- `~/obsidian-vault/projects/sir-loin/context.md` — D&D campaign context
- `~/obsidian-vault/projects/blend/context.md` — Blend project context
- `~/obsidian-vault/_shared/README.md` — Shared knowledge index

### Files to Modify
- `~/.personal-claude/settings.json` — Add obsidian + memory MCP servers
- `~/.roku-claude/settings.json` — Add obsidian + memory MCP servers
- `~/.blend-claude/settings.json` — Add obsidian + memory MCP servers
- `~/.personal-claude/CLAUDE.md` — Add Obsidian Memory section
- `~/.roku-claude/CLAUDE.md` — Add Obsidian Memory section
- `~/.blend-claude/CLAUDE.md` — Add Obsidian Memory section

---

### Task 1: Create Obsidian Vault Directory Structure

**Files:**
- Create: `~/obsidian-vault/` and all subdirectories

- [ ] **Step 1: Create the vault directory tree**

```bash
mkdir -p ~/obsidian-vault/{_shared/{patterns,conventions,tools,learnings},projects/{roku/{decisions,patterns,runbooks},sir-loin/{campaign,npcs},blend/{decisions,patterns},personal-projects},personal,daily,templates}
```

- [ ] **Step 2: Verify the structure**

```bash
find ~/obsidian-vault -type d | sort
```

Expected output should show all directories listed above.

- [ ] **Step 3: Create the ADR template**

Create `~/obsidian-vault/templates/adr-template.md`:

```markdown
---
date: {{date}}
status: accepted
tags: [decision]
---

# ADR: {{title}}

## Context

What is the issue that we're seeing that is motivating this decision or change?

## Decision

What is the change that we're proposing and/or doing?

## Consequences

What becomes easier or more difficult to do because of this change?
```

- [ ] **Step 4: Create the context template**

Create `~/obsidian-vault/templates/context-template.md`:

```markdown
---
project: {{project-name}}
updated: {{date}}
tags: [context]
---

# {{project-name}}

## Overview

One paragraph describing what this project is.

## Tech Stack

- Language:
- Framework:
- Database:
- Hosting:

## Key Patterns

- Pattern 1
- Pattern 2

## Important Paths

- Entry point:
- Config:
- Tests:

## Current Status

What's being worked on right now.
```

- [ ] **Step 5: Create the pattern template**

Create `~/obsidian-vault/templates/pattern-template.md`:

```markdown
---
date: {{date}}
tags: [pattern]
applies-to: [project-name]
---

# Pattern: {{title}}

## Problem

What problem does this pattern solve?

## Solution

How to apply this pattern. Include code examples.

## When to Use

When this pattern is appropriate.

## When NOT to Use

When this pattern should be avoided.
```

- [ ] **Step 6: Create initial context files for existing projects**

Create `~/obsidian-vault/projects/roku/context.md`:

```markdown
---
project: roku
updated: 2026-04-14
tags: [context]
---

# Roku

## Overview

Work projects at Roku. Multiple repos and services.

## Key Info

- Claude profile: roku (~/.roku-claude/)
- Base URL: ai-hub-lite.msc.rokulabs.net
- Git strategy: squash before rebase
- MCPs: trino, trino_dev, gitlab, playwright

## Current Status

To be filled in during work sessions.
```

Create `~/obsidian-vault/projects/sir-loin/context.md`:

```markdown
---
project: sir-loin
updated: 2026-04-14
tags: [context]
---

# Sir Loin y sus Amigos — D&D Campaign

## Overview

D&D campaign planning and management.

## Key Info

- Claude profile: personal (~/.personal-claude/)
- Repo: ~/proyectos/Sir Loin y sus amigos/
- Specialized agents: Narrative Designer, Anthropologist, Geographer, Historian, Psychologist

## Current Status

To be filled in during sessions.
```

Create `~/obsidian-vault/projects/blend/context.md`:

```markdown
---
project: blend
updated: 2026-04-14
tags: [context]
---

# Blend

## Overview

Blend projects.

## Key Info

- Claude profile: blend (~/.blend-claude/)

## Current Status

To be filled in during sessions.
```

- [ ] **Step 6b: Create personal-projects placeholder**

Create `~/obsidian-vault/projects/personal-projects/context.md`:

```markdown
---
project: personal-projects
updated: 2026-04-14
tags: [context]
---

# Personal Projects

## Overview

Side projects, experiments, and personal development work.

## Projects

- alfred
- polymarket bot
- fairtrade-uy
- riftbound tracker
- Mulligan Elo Tracking

## Current Status

To be filled in during sessions.
```

- [ ] **Step 7: Create shared knowledge index**

Create `~/obsidian-vault/_shared/README.md`:

```markdown
# Shared Knowledge

Cross-project knowledge used by all Claude Code profiles.

## Folders

- **patterns/** — Reusable code patterns (auth, error handling, testing, etc.)
- **conventions/** — Naming, git, style conventions
- **tools/** — Notes about tools and configurations
- **learnings/** — Curated lessons promoted from semantic memory
```

- [ ] **Step 8: Commit vault structure to the project repo**

```bash
cd ~/proyectos/claude-memory-hub
# Copy the vault structure as documentation
echo "~/obsidian-vault/" > .vault-path
git add .vault-path
git commit -m "Add vault path reference"
```

---

### Task 2: Install and Configure MCPVault (Obsidian MCP Server)

**Files:**
- Modify: `~/.personal-claude/settings.json`
- Modify: `~/.roku-claude/settings.json`
- Modify: `~/.blend-claude/settings.json`

- [ ] **Step 1: Verify npx can run MCPVault**

```bash
npx @bitbonsai/mcpvault@latest --help
```

Expected: Help text showing MCPVault options. If it fails, check Node.js version and npm registry access.

- [ ] **Step 2: Test MCPVault reads the vault**

```bash
# Quick smoke test — run the server and see if it starts
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}}}' | npx @bitbonsai/mcpvault@latest ~/obsidian-vault 2>/dev/null | head -1
```

Expected: A JSON response with server capabilities (or at minimum, no crash/error).

- [ ] **Step 3: Add MCPVault to personal profile settings.json**

Edit `~/.personal-claude/settings.json`. Add to the existing `mcpServers` object:

```json
"obsidian": {
  "command": "npx",
  "args": ["@bitbonsai/mcpvault@latest", "/Users/germanabuarab/obsidian-vault"]
}
```

> **Important:** This file already has `supabase` and `playwright` MCP servers. Add `obsidian` alongside them, do NOT replace them.

- [ ] **Step 4: Add MCPVault to roku profile settings.json**

Edit `~/.roku-claude/settings.json`. Add to the existing `mcpServers` object:

```json
"obsidian": {
  "command": "npx",
  "args": ["@bitbonsai/mcpvault@latest", "/Users/germanabuarab/obsidian-vault"]
}
```

> **Important:** This file already has `playwright`, `trino`, `trino_dev`, and `gitlab` MCP servers. Add alongside them.

- [ ] **Step 5: Add MCPVault to blend profile settings.json**

Edit `~/.blend-claude/settings.json`. Add to the existing `mcpServers` object:

```json
"obsidian": {
  "command": "npx",
  "args": ["@bitbonsai/mcpvault@latest", "/Users/germanabuarab/obsidian-vault"]
}
```

> **Important:** This file already has `playwright`. Add alongside it.

- [ ] **Step 6: Verify MCPVault works from Claude Code**

Start a new Claude Code session with personal profile. Ask:
```
List the files in my Obsidian vault using the obsidian MCP.
```

Expected: Claude uses the MCPVault tools to list vault contents. Should show the directories and files created in Task 1.

- [ ] **Step 7: Log config changes**

```bash
cd ~/proyectos/claude-memory-hub
echo "$(date +%Y-%m-%d) - MCPVault (@bitbonsai/mcpvault) added to personal, roku, blend profiles" >> CHANGELOG.md
git add CHANGELOG.md
git commit -m "Log MCPVault configuration for all 3 profiles"
```

> Note: The settings.json files live outside this repo (in ~/.xxx-claude/). This commit just logs what was done.

---

### Task 3: Install and Configure mcp-memory-service

**Files:**
- Modify: `~/.personal-claude/settings.json`
- Modify: `~/.roku-claude/settings.json`
- Modify: `~/.blend-claude/settings.json`

- [ ] **Step 1: Install mcp-memory-service via pip**

```bash
pip install mcp-memory-service
```

Expected: Successfully installs mcp-memory-service and its dependencies (including ChromaDB, sentence-transformers with ONNX). ChromaDB is embedded — no separate install needed.

> **Note:** If `pip` resolves to a system Python, use `pip3` or `python3 -m pip install mcp-memory-service`.

- [ ] **Step 2: Verify the `memory` command is available and capture its absolute path**

```bash
which memory
memory --help
```

Expected: Shows the path to the `memory` binary (e.g., `/opt/homebrew/bin/memory`) and help text.

> **Important:** Note the full absolute path from `which memory`. Use this absolute path in the settings.json config below instead of the bare `"memory"` command. This ensures the MCP server can find the binary even if Claude Code subprocesses don't inherit the full shell PATH.

- [ ] **Step 3: Test the memory server starts**

```bash
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}}}' | memory server 2>/dev/null | head -1
```

Expected: A JSON response with server capabilities.

- [ ] **Step 3.5: Create storage directories for ChromaDB**

```bash
mkdir -p "$HOME/Library/Application Support/mcp-memory/chroma_db"
mkdir -p "$HOME/Library/Application Support/mcp-memory/backups"
```

- [ ] **Step 4: Add mcp-memory-service to personal profile settings.json**

Edit `~/.personal-claude/settings.json`. Add to the existing `mcpServers` object.

> **Replace `/ABSOLUTE/PATH/TO/memory`** with the full path from Step 2 (e.g., `/opt/homebrew/bin/memory`).

```json
"memory": {
  "command": "/ABSOLUTE/PATH/TO/memory",
  "args": ["server"],
  "env": {
    "MCP_MEMORY_CHROMA_PATH": "/Users/germanabuarab/Library/Application Support/mcp-memory/chroma_db",
    "MCP_MEMORY_BACKUPS_PATH": "/Users/germanabuarab/Library/Application Support/mcp-memory/backups"
  }
}
```

- [ ] **Step 5: Add mcp-memory-service to roku profile settings.json**

Edit `~/.roku-claude/settings.json`. Add to the existing `mcpServers` object (same config as personal):

```json
"memory": {
  "command": "/ABSOLUTE/PATH/TO/memory",
  "args": ["server"],
  "env": {
    "MCP_MEMORY_CHROMA_PATH": "/Users/germanabuarab/Library/Application Support/mcp-memory/chroma_db",
    "MCP_MEMORY_BACKUPS_PATH": "/Users/germanabuarab/Library/Application Support/mcp-memory/backups"
  }
}
```

- [ ] **Step 6: Add mcp-memory-service to blend profile settings.json**

Edit `~/.blend-claude/settings.json`. Add to the existing `mcpServers` object (same config):

```json
"memory": {
  "command": "/ABSOLUTE/PATH/TO/memory",
  "args": ["server"],
  "env": {
    "MCP_MEMORY_CHROMA_PATH": "/Users/germanabuarab/Library/Application Support/mcp-memory/chroma_db",
    "MCP_MEMORY_BACKUPS_PATH": "/Users/germanabuarab/Library/Application Support/mcp-memory/backups"
  }
}
```

> All 3 profiles share the same ChromaDB. Memories are tagged with metadata (source profile, project) via CLAUDE.md instructions.

- [ ] **Step 7: Verify mcp-memory-service works from Claude Code**

Start a new Claude Code session with personal profile. Ask:
```
Store a test memory: "The Claude Memory Hub project uses a 4-layer architecture." Tag it with source:personal, project:claude-memory-hub.
```

Then ask:
```
Search your memory for "memory architecture".
```

Expected: Claude uses the memory MCP tools to store and retrieve the test memory.

- [ ] **Step 8: Log config changes**

```bash
cd ~/proyectos/claude-memory-hub
echo "$(date +%Y-%m-%d) - mcp-memory-service added to personal, roku, blend profiles" >> CHANGELOG.md
git add CHANGELOG.md
git commit -m "Log mcp-memory-service configuration for all 3 profiles"
```

> **Deferred:** The spec mentions a SessionEnd hook for `memory_harvest`. This is intentionally deferred because `memory_harvest` is an MCP tool (not a CLI command) and cannot be called from a shell hook. Instead, the CLAUDE.md instructions (Task 5) tell Claude to consolidate valuable memories into vault notes during sessions. A prompt-type SessionEnd hook may be added later if supported.

---

### Task 4: Install and Configure Graphify

**Files:**
- No profile settings changes (Graphify runs per-project via CLI or its own `graphify claude install`)

- [ ] **Step 1: Install Graphify**

```bash
pip install graphifyy
```

> **Critical:** The PyPI package is `graphifyy` (double Y). `pip install graphify` installs an unrelated package.

Expected: Graphify installs successfully and `graphify --help` works.

> **Note:** Do NOT run bare `graphify install` — the Claude Code integration is done via `graphify claude install` in Step 6.

- [ ] **Step 2: Verify Graphify runs**

```bash
graphify --version
```

Expected: Shows version (should be 0.4.x).

- [ ] **Step 3: Run Graphify on a test project**

Pick a project to test with. Use the claude-memory-hub project itself (small, good for testing):

```bash
cd ~/proyectos/claude-memory-hub
graphify .
```

Expected: Creates `graphify-out/` directory with:
- `GRAPH_REPORT.md`
- `graph.html`
- `graph.json`

> If the project is too small to produce meaningful output (it's just markdown), try a larger project like one of the repos in `~/proyectos/`.

- [ ] **Step 4: Review the GRAPH_REPORT.md**

```bash
cat ~/proyectos/claude-memory-hub/graphify-out/GRAPH_REPORT.md
```

Verify it contains useful structural information about the project.

- [ ] **Step 5: Add graphify-out to .gitignore**

Create/edit `~/proyectos/claude-memory-hub/.gitignore`:

```
graphify-out/
```

- [ ] **Step 6: Test `graphify claude install` on the test project**

```bash
cd ~/proyectos/claude-memory-hub
graphify claude install
```

This should automatically:
- Add a section to the project's `CLAUDE.md` about reading GRAPH_REPORT.md
- Add a PreToolUse hook to the local settings

Review what it added and verify it looks correct.

- [ ] **Step 7: Commit**

```bash
cd ~/proyectos/claude-memory-hub
git add .gitignore CLAUDE.md
git commit -m "Add Graphify integration with gitignore and CLAUDE.md instructions"
```

---

### Task 5: Update CLAUDE.md for All 3 Profiles

**Files:**
- Modify: `~/.personal-claude/CLAUDE.md`
- Modify: `~/.roku-claude/CLAUDE.md`
- Modify: `~/.blend-claude/CLAUDE.md`

- [ ] **Step 1: Add Obsidian Memory section to personal profile CLAUDE.md**

Append to `~/.personal-claude/CLAUDE.md`:

```markdown
## Obsidian Memory

You have access to an Obsidian vault via the `obsidian` MCP server and semantic memory via the `memory` MCP server.

### Vault (obsidian MCP)
- The vault is at `~/obsidian-vault/`
- As the personal profile, you have access to ALL folders: `projects/`, `personal/`, `_shared/`
- WHEN you make an architectural decision, WRITE it to `projects/<project>/decisions/YYYY-MM-DD-<topic>.md` using the ADR template
- WHEN you discover a reusable pattern, WRITE it to the appropriate `patterns/` folder
- WHEN starting a session for a project, CHECK its `context.md` for current status
- Check `_shared/` for cross-project patterns and conventions

### Semantic Memory (memory MCP)
- Use for fuzzy/conceptual searches ("how did we handle X?")
- Tag all stored memories with metadata: `{source: "personal"}`
- When working on a specific project, also tag with `{project: "<project-name>"}`
- If you find a valuable memory, consider promoting it to a vault note for permanence

### Search Priority
- Structured/factual questions → vault (obsidian MCP search)
- Conceptual/fuzzy questions → memory MCP (semantic search)
- Past conversations → episodic-memory MCP
```

- [ ] **Step 2: Add Obsidian Memory section to roku profile CLAUDE.md**

Append to `~/.roku-claude/CLAUDE.md`:

```markdown
## Obsidian Memory

You have access to an Obsidian vault via the `obsidian` MCP server and semantic memory via the `memory` MCP server.

### Vault (obsidian MCP)
- The vault is at `~/obsidian-vault/`
- Focus on `projects/roku/` for project-specific knowledge
- Check `_shared/` for cross-project patterns and conventions
- WHEN you make an architectural decision, WRITE it to `projects/roku/decisions/YYYY-MM-DD-<topic>.md`
- WHEN you discover a reusable pattern, WRITE it to `projects/roku/patterns/<name>.md`
- Do NOT read or write to other project folders (blend, personal, sir-loin)

### Semantic Memory (memory MCP)
- Use for fuzzy/conceptual searches ("how did we handle X?")
- Tag all stored memories with metadata: `{source: "roku"}`
- When working on a specific repo, also tag with `{project: "<repo-name>"}`
- If you find a valuable memory, consider promoting it to a vault note

### Search Priority
- Structured/factual questions → vault (obsidian MCP search)
- Conceptual/fuzzy questions → memory MCP (semantic search)
- Past conversations → episodic-memory MCP
```

- [ ] **Step 3: Add Obsidian Memory section to blend profile CLAUDE.md**

Append to `~/.blend-claude/CLAUDE.md`:

```markdown
## Obsidian Memory

You have access to an Obsidian vault via the `obsidian` MCP server and semantic memory via the `memory` MCP server.

### Vault (obsidian MCP)
- The vault is at `~/obsidian-vault/`
- Focus on `projects/blend/` for project-specific knowledge
- Check `_shared/` for cross-project patterns and conventions
- WHEN you make an architectural decision, WRITE it to `projects/blend/decisions/YYYY-MM-DD-<topic>.md`
- WHEN you discover a reusable pattern, WRITE it to `projects/blend/patterns/<name>.md`
- Do NOT read or write to other project folders (roku, personal, sir-loin)

### Semantic Memory (memory MCP)
- Use for fuzzy/conceptual searches ("how did we handle X?")
- Tag all stored memories with metadata: `{source: "blend"}`
- When working on a specific repo, also tag with `{project: "<repo-name>"}`
- If you find a valuable memory, consider promoting it to a vault note

### Search Priority
- Structured/factual questions → vault (obsidian MCP search)
- Conceptual/fuzzy questions → memory MCP (semantic search)
- Past conversations → episodic-memory MCP
```

- [ ] **Step 4: Verify CLAUDE.md changes look correct**

Read each file and confirm the new section is properly appended without breaking existing content:

```bash
tail -30 ~/.personal-claude/CLAUDE.md
tail -30 ~/.roku-claude/CLAUDE.md
tail -30 ~/.blend-claude/CLAUDE.md
```

- [ ] **Step 5: Commit CLAUDE.md changes to project repo**

```bash
cd ~/proyectos/claude-memory-hub
# Document what was added
echo "CLAUDE.md sections added to all 3 profiles on $(date +%Y-%m-%d)" >> CHANGELOG.md
git add CHANGELOG.md
git commit -m "Document CLAUDE.md updates for all 3 profiles"
```

---

### Task 6: Open Vault in Obsidian

- [ ] **Step 1: Open Obsidian and add the vault**

```bash
open -a Obsidian ~/obsidian-vault
```

This will either open the vault directly or prompt to "Open folder as vault." Accept.

- [ ] **Step 2: Verify vault structure in Obsidian**

In Obsidian, check:
- All folders appear in the file tree
- Template files are readable
- Context files display properly with frontmatter

- [ ] **Step 3: Install recommended Obsidian community plugins (optional)**

Consider installing:
- **Templater** — for using the templates with dynamic dates
- **Calendar** — for daily notes
- **Graph View** — built-in, just verify it shows the vault structure

> This step is optional and can be done later.

---

### Task 7: End-to-End Validation (Smoke Test)

- [ ] **Step 1: Start a NEW personal Claude Code session**

```bash
claude --profile personal
```

- [ ] **Step 2: Test vault access**

Ask Claude:
```
What notes do I have in my Obsidian vault? Use the obsidian MCP to list files.
```

Expected: Claude uses MCPVault tools and lists the vault contents (templates, context files, _shared/).

- [ ] **Step 3: Test vault write**

Ask Claude:
```
Write a test note to the vault at _shared/learnings/2026-04-14-memory-hub-setup.md with a brief note about setting up the memory hub today.
```

Expected: Claude creates the file in the vault. Verify it appears in Obsidian.

- [ ] **Step 4: Test semantic memory store**

Ask Claude:
```
Store a memory: "We set up the Claude Memory Hub on April 14, 2026. It uses MCPVault for Obsidian access and mcp-memory-service for semantic search." Tag with source:personal, project:claude-memory-hub.
```

Expected: Claude uses the memory MCP to store the memory.

- [ ] **Step 5: Test semantic memory search**

Ask Claude:
```
Search your semantic memory for "memory hub architecture".
```

Expected: Claude retrieves the memory stored in step 4.

- [ ] **Step 6: Test episodic memory (existing)**

Ask Claude:
```
Search your episodic memory for conversations about "obsidian memory".
```

Expected: Finds this current conversation (or recent ones about the memory hub project).

- [ ] **Step 7: Test profile scoping (roku)**

Start a new roku profile session:
```bash
claude --profile roku
```

Ask:
```
What's in my Obsidian vault under projects/roku/?
```

Expected: Claude accesses only roku-scoped content. Should show the roku context.md and empty decisions/patterns/runbooks folders.

- [ ] **Step 8: Verify session startup time**

Time a fresh session start:
```bash
time claude --profile personal -c "echo hello"
```

Compare with baseline (without the new MCP servers). Should add less than 5 seconds of startup time.

- [ ] **Step 9: Document results**

```bash
cd ~/proyectos/claude-memory-hub
cat > VALIDATION.md << 'EOF'
# Validation Results — 2026-04-14

## Smoke Test Results

| Test | Status | Notes |
|------|--------|-------|
| Vault list files | | |
| Vault write note | | |
| Memory store | | |
| Memory search | | |
| Episodic memory | | |
| Roku scoping | | |
| Startup time | | |

## Issues Found

(none yet)
EOF
git add VALIDATION.md
git commit -m "Add validation template"
```

- [ ] **Step 10: Push all changes to GitHub**

```bash
cd ~/proyectos/claude-memory-hub
git push origin main
```

---

## Execution Order and Dependencies

```
Task 1 (Vault Structure)
    ↓
Task 2 (MCPVault) ──────────┐
    ↓                        │
Task 3 (mcp-memory-service)  │ (independent, can run in parallel)
    ↓                        │
Task 4 (Graphify) ───────────┘
    ↓
Task 5 (CLAUDE.md updates) — depends on Tasks 2, 3, 4 being configured
    ↓
Task 6 (Obsidian app) — depends on Task 1
    ↓
Task 7 (Validation) — depends on all above
```

Tasks 2, 3, and 4 are independent of each other and can be done in any order after Task 1. Task 5 should be done after the MCP servers are confirmed working. Task 7 is the final validation.

## Rollback Plan

If something breaks or you want to undo:

```bash
# Remove MCP servers from each profile (edit settings.json, delete "obsidian" and "memory" keys)
# Uninstall Python packages
pip uninstall mcp-memory-service graphifyy -y
# The vault stays on disk (it's just markdown files) — delete manually if unwanted:
# rm -r ~/obsidian-vault  (ONLY if you want to remove it)
# Revert CLAUDE.md changes: remove the "## Obsidian Memory" section from each profile
```

## Spec Update (Bookkeeping)

After implementation, update the spec to reflect final package names:
- `@mcp-obsidian/server` → `@bitbonsai/mcpvault`
- `"command": "uvx"` → `"command": "/absolute/path/to/memory"`
- `"memory-service"` MCP key → `"memory"`

## Estimated Time

| Task | Estimate |
|------|----------|
| Task 1: Vault structure | 5 min |
| Task 2: MCPVault | 10 min |
| Task 3: mcp-memory-service | 15 min (includes first-run model download) |
| Task 4: Graphify | 10 min |
| Task 5: CLAUDE.md updates | 5 min |
| Task 6: Obsidian app setup | 5 min |
| Task 7: Validation | 15 min |
| **Total** | **~65 min** |
