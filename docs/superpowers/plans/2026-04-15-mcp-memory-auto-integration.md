# MCP Memory Auto-Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enable automatic memory capture and retrieval across all 3 Claude Code profiles (personal, roku, blend) with isolated SQLite-vec databases per profile.

**Architecture:** Hybrid approach with SessionStart/SessionEnd hooks for automatic context retrieval and harvest, plus CLAUDE.md instructions for real-time capture during work. Each profile gets isolated memory-db to prevent data leakage between personal/work contexts.

**Tech Stack:** mcp-memory-service v10.36.7, SQLite-vec, bash hooks, JSON configuration

---

## File Structure

**Created:**
- `~/.personal-claude/hooks/session-start-memory.sh` - SessionStart hook for context search
- `~/.personal-claude/hooks/session-end-harvest.sh` - SessionEnd hook for learning extraction
- `~/.roku-claude/hooks/session-start-memory.sh` - Same for roku profile
- `~/.roku-claude/hooks/session-end-harvest.sh` - Same for roku profile
- `~/.blend-claude/hooks/session-start-memory.sh` - Same for blend profile
- `~/.blend-claude/hooks/session-end-harvest.sh` - Same for blend profile
- `~/.personal-claude/memory-db/` - SQLite-vec database directory (auto-created by MCP)
- `~/.personal-claude/memory-backups/` - Backup directory
- `~/.roku-claude/memory-db/` - Isolated roku database
- `~/.roku-claude/memory-backups/` - Roku backups
- `~/.blend-claude/memory-db/` - Isolated blend database
- `~/.blend-claude/memory-backups/` - Blend backups

**Modified:**
- `~/.personal-claude/settings.json` - Update memory MCP paths + add hooks
- `~/.roku-claude/settings.json` - Update memory MCP paths + add hooks
- `~/.blend-claude/settings.json` - Update memory MCP paths + add hooks
- `~/.personal-claude/CLAUDE.md` - Add memory auto-capture section
- `~/.roku-claude/CLAUDE.md` - Add memory auto-capture section
- `~/.blend-claude/CLAUDE.md` - Add memory auto-capture section

---

## Task 1: Backup Existing Shared Database

**Files:**
- Read: `/Users/germanabuarab/Library/Application Support/mcp-memory/chroma_db/`
- Create: `/Users/germanabuarab/Library/Application Support/mcp-memory/chroma_db.backup-YYYYMMDD/`

- [ ] **Step 1: Check if shared DB exists**

```bash
ls -la "/Users/germanabuarab/Library/Application Support/mcp-memory/chroma_db/" 2>&1
```

Expected: Directory exists (even if empty) or "No such file or directory"

- [ ] **Step 2: Create timestamped backup**

```bash
BACKUP_DIR="/Users/germanabuarab/Library/Application Support/mcp-memory/chroma_db.backup-$(date +%Y%m%d)"
if [ -d "/Users/germanabuarab/Library/Application Support/mcp-memory/chroma_db" ]; then
  cp -r "/Users/germanabuarab/Library/Application Support/mcp-memory/chroma_db" "$BACKUP_DIR"
  echo "Backup created at: $BACKUP_DIR"
else
  echo "No existing DB to backup (fresh install)"
fi
```

Expected: Backup created or confirmation of fresh install

- [ ] **Step 3: Verify backup**

```bash
BACKUP_DIR="/Users/germanabuarab/Library/Application Support/mcp-memory/chroma_db.backup-$(date +%Y%m%d)"
if [ -d "$BACKUP_DIR" ]; then
  ls -lh "$BACKUP_DIR"
else
  echo "No backup needed"
fi
```

Expected: Backup directory listed or "No backup needed"

---

## Task 2: Create Directory Structure for All Profiles

**Files:**
- Create: `~/.personal-claude/memory-db/`
- Create: `~/.personal-claude/memory-backups/`
- Create: `~/.roku-claude/memory-db/`
- Create: `~/.roku-claude/memory-backups/`
- Create: `~/.blend-claude/memory-db/`
- Create: `~/.blend-claude/memory-backups/`

- [ ] **Step 1: Create personal profile directories**

```bash
mkdir -p ~/.personal-claude/memory-db
mkdir -p ~/.personal-claude/memory-backups
echo "Created personal memory directories"
```

Expected: Directories created

- [ ] **Step 2: Create roku profile directories**

```bash
mkdir -p ~/.roku-claude/memory-db
mkdir -p ~/.roku-claude/memory-backups
echo "Created roku memory directories"
```

Expected: Directories created

- [ ] **Step 3: Create blend profile directories**

```bash
mkdir -p ~/.blend-claude/memory-db
mkdir -p ~/.blend-claude/memory-backups
echo "Created blend memory directories"
```

Expected: Directories created

- [ ] **Step 4: Set restrictive permissions on roku memory-db (corporate data)**

```bash
chmod 700 ~/.roku-claude/memory-db
chmod 700 ~/.roku-claude/memory-backups
ls -ld ~/.roku-claude/memory-db ~/.roku-claude/memory-backups
```

Expected: `drwx------` permissions (user-only access)

- [ ] **Step 5: Verify all directories exist**

```bash
for profile in personal roku blend; do
  echo "--- $profile profile ---"
  ls -ld ~/."$profile"-claude/memory-db ~/."$profile"-claude/memory-backups
done
```

Expected: All 6 directories listed

---

## Task 3: Create SessionStart Hook Script (Template)

**Files:**
- Create: `~/.personal-claude/hooks/session-start-memory.sh`

- [ ] **Step 1: Write session-start-memory.sh for personal profile**

```bash
cat > ~/.personal-claude/hooks/session-start-memory.sh <<'EOF'
#!/bin/bash

# Get current working directory name (project name)
PROJECT_NAME=$(basename "$PWD")

# Only run if we're in a project directory (not home)
if [[ "$PWD" == "$HOME" ]]; then
  exit 0
fi

# Output context for Claude
cat <<INNER_EOF
<session-start-memory-context>
Searching memory for project: $PROJECT_NAME

Use the memory MCP to search for:
1. Past decisions about this project
2. Important configurations or data
3. Patterns or conventions established

Example query: "Search memory for '$PROJECT_NAME' project decisions and configurations"
</session-start-memory-context>
INNER_EOF
EOF
```

- [ ] **Step 2: Make script executable**

```bash
chmod +x ~/.personal-claude/hooks/session-start-memory.sh
ls -l ~/.personal-claude/hooks/session-start-memory.sh
```

Expected: `-rwxr-xr-x` permissions

- [ ] **Step 3: Test script manually**

```bash
cd /Users/germanabuarab/proyectos/claude-memory-hub
bash ~/.personal-claude/hooks/session-start-memory.sh
```

Expected: Outputs `<session-start-memory-context>` XML with project name "claude-memory-hub"

- [ ] **Step 4: Copy to roku profile**

```bash
cp ~/.personal-claude/hooks/session-start-memory.sh ~/.roku-claude/hooks/session-start-memory.sh
chmod +x ~/.roku-claude/hooks/session-start-memory.sh
echo "Copied to roku profile"
```

Expected: Script copied and executable

- [ ] **Step 5: Copy to blend profile**

```bash
cp ~/.personal-claude/hooks/session-start-memory.sh ~/.blend-claude/hooks/session-start-memory.sh
chmod +x ~/.blend-claude/hooks/session-start-memory.sh
echo "Copied to blend profile"
```

Expected: Script copied and executable

- [ ] **Step 6: Verify all 3 copies exist and are executable**

```bash
for profile in personal roku blend; do
  ls -l ~/."$profile"-claude/hooks/session-start-memory.sh
done
```

Expected: All 3 scripts with `-rwxr-xr-x` permissions

---

## Task 4: Create SessionEnd Hook Script (Template)

**Files:**
- Create: `~/.personal-claude/hooks/session-end-harvest.sh`

- [ ] **Step 1: Write session-end-harvest.sh for personal profile**

```bash
cat > ~/.personal-claude/hooks/session-end-harvest.sh <<'EOF'
#!/bin/bash

# Get project name
PROJECT_NAME=$(basename "$PWD")
PROFILE_NAME=$(basename "$(dirname "$(dirname "$0")")" | sed 's/-claude//')

cat <<INNER_EOF
<session-end-harvest>
Session ended. Run memory harvest workflow:

**Step 1: Preview (dry_run=True)**
Use memory_harvest tool:
{
  "sessions": 1,
  "dry_run": true,
  "min_confidence": 0.7,
  "types": ["decision", "bug", "convention", "learning", "context"]
}

**Step 2: Review candidates**
- Check for duplicates with existing memories (search first)
- Remove noise/trivial entries
- Validate quality and relevance

**Step 3: Store approved memories (dry_run=False)**
Only if candidates look good:
{
  "sessions": 1,
  "dry_run": false,
  "min_confidence": 0.7
}

Tag all harvested memories with:
- project: "$PROJECT_NAME"
- profile: "$PROFILE_NAME"
- session_date: "$(date +%Y-%m-%d)"

Note: Semantic dedup will merge with any manual saves from this session.
</session-end-harvest>
INNER_EOF
EOF
```

- [ ] **Step 2: Make script executable**

```bash
chmod +x ~/.personal-claude/hooks/session-end-harvest.sh
ls -l ~/.personal-claude/hooks/session-end-harvest.sh
```

Expected: `-rwxr-xr-x` permissions

- [ ] **Step 3: Test script manually**

```bash
cd /Users/germanabuarab/proyectos/claude-memory-hub
bash ~/.personal-claude/hooks/session-end-harvest.sh
```

Expected: Outputs `<session-end-harvest>` XML with project name, profile "personal", and today's date

- [ ] **Step 4: Copy to roku profile**

```bash
cp ~/.personal-claude/hooks/session-end-harvest.sh ~/.roku-claude/hooks/session-end-harvest.sh
chmod +x ~/.roku-claude/hooks/session-end-harvest.sh
echo "Copied to roku profile"
```

Expected: Script copied and executable

- [ ] **Step 5: Copy to blend profile**

```bash
cp ~/.personal-claude/hooks/session-end-harvest.sh ~/.blend-claude/hooks/session-end-harvest.sh
chmod +x ~/.blend-claude/hooks/session-end-harvest.sh
echo "Copied to blend profile"
```

Expected: Script copied and executable

- [ ] **Step 6: Verify all 3 copies exist and are executable**

```bash
for profile in personal roku blend; do
  ls -l ~/."$profile"-claude/hooks/session-end-harvest.sh
done
```

Expected: All 3 scripts with `-rwxr-xr-x` permissions

---

## Task 5: Update Personal Profile settings.json

**Files:**
- Modify: `~/.personal-claude/settings.json:89-97` (memory MCP env paths)
- Modify: `~/.personal-claude/settings.json:23-47` (add SessionStart/SessionEnd hooks)

- [ ] **Step 1: Backup current settings.json**

```bash
cp ~/.personal-claude/settings.json ~/.personal-claude/settings.json.backup-$(date +%Y%m%d)
echo "Backup created"
```

Expected: Backup file created

- [ ] **Step 2: Update memory MCP paths in settings.json**

Use Edit tool to replace:

OLD:
```json
    "memory": {
      "command": "/Users/germanabuarab/anaconda3/bin/memory",
      "args": [
        "server"
      ],
      "env": {
        "MCP_MEMORY_CHROMA_PATH": "/Users/germanabuarab/Library/Application Support/mcp-memory/chroma_db",
        "MCP_MEMORY_BACKUPS_PATH": "/Users/germanabuarab/Library/Application Support/mcp-memory/backups"
      }
    }
```

NEW:
```json
    "memory": {
      "command": "/Users/germanabuarab/anaconda3/bin/memory",
      "args": [
        "server"
      ],
      "env": {
        "MCP_MEMORY_CHROMA_PATH": "/Users/germanabuarab/.personal-claude/memory-db",
        "MCP_MEMORY_BACKUPS_PATH": "/Users/germanabuarab/.personal-claude/memory-backups"
      }
    }
```

- [ ] **Step 3: Add SessionStart and SessionEnd hooks**

Find the existing `"hooks"` section (around line 16-47) and ADD two new hooks to the existing arrays.

For `"SessionStart"` array, ADD:
```json
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash /Users/germanabuarab/.personal-claude/hooks/session-start-memory.sh"
          }
        ]
      }
```

Create NEW `"SessionEnd"` array in the hooks object:
```json
    "SessionEnd": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash /Users/germanabuarab/.personal-claude/hooks/session-end-harvest.sh"
          }
        ]
      }
    ]
```

- [ ] **Step 4: Validate JSON syntax**

```bash
python3 -m json.tool ~/.personal-claude/settings.json > /dev/null && echo "✓ Valid JSON" || echo "✗ Invalid JSON"
```

Expected: `✓ Valid JSON`

- [ ] **Step 5: Verify changes**

```bash
cat ~/.personal-claude/settings.json | jq '.mcpServers.memory.env'
cat ~/.personal-claude/settings.json | jq '.hooks.SessionStart[-1]'
cat ~/.personal-claude/settings.json | jq '.hooks.SessionEnd[0]'
```

Expected:
- Memory env shows new paths with `/.personal-claude/memory-db`
- SessionStart shows session-start-memory.sh command
- SessionEnd shows session-end-harvest.sh command

---

## Task 6: Update Roku Profile settings.json

**Files:**
- Modify: `~/.roku-claude/settings.json:98-105` (memory MCP env paths)
- Modify: `~/.roku-claude/settings.json:23-47` (add SessionStart/SessionEnd hooks)

- [ ] **Step 1: Backup current settings.json**

```bash
cp ~/.roku-claude/settings.json ~/.roku-claude/settings.json.backup-$(date +%Y%m%d)
echo "Backup created"
```

Expected: Backup file created

- [ ] **Step 2: Update memory MCP paths in settings.json**

Use Edit tool to replace:

OLD:
```json
    "memory": {
      "command": "/Users/germanabuarab/anaconda3/bin/memory",
      "args": ["server"],
      "env": {
        "MCP_MEMORY_CHROMA_PATH": "/Users/germanabuarab/Library/Application Support/mcp-memory/chroma_db",
        "MCP_MEMORY_BACKUPS_PATH": "/Users/germanabuarab/Library/Application Support/mcp-memory/backups"
      }
    }
```

NEW:
```json
    "memory": {
      "command": "/Users/germanabuarab/anaconda3/bin/memory",
      "args": ["server"],
      "env": {
        "MCP_MEMORY_CHROMA_PATH": "/Users/germanabuarab/.roku-claude/memory-db",
        "MCP_MEMORY_BACKUPS_PATH": "/Users/germanabuarab/.roku-claude/memory-backups"
      }
    }
```

- [ ] **Step 3: Add SessionStart and SessionEnd hooks**

Same approach as personal profile, but with roku paths:

For `"SessionStart"` array, ADD:
```json
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash /Users/germanabuarab/.roku-claude/hooks/session-start-memory.sh"
          }
        ]
      }
```

Create NEW `"SessionEnd"` array:
```json
    "SessionEnd": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash /Users/germanabuarab/.roku-claude/hooks/session-end-harvest.sh"
          }
        ]
      }
    ]
```

- [ ] **Step 4: Validate JSON syntax**

```bash
python3 -m json.tool ~/.roku-claude/settings.json > /dev/null && echo "✓ Valid JSON" || echo "✗ Invalid JSON"
```

Expected: `✓ Valid JSON`

- [ ] **Step 5: Verify changes**

```bash
cat ~/.roku-claude/settings.json | jq '.mcpServers.memory.env'
cat ~/.roku-claude/settings.json | jq '.hooks.SessionStart[-1]'
cat ~/.roku-claude/settings.json | jq '.hooks.SessionEnd[0]'
```

Expected:
- Memory env shows `/.roku-claude/memory-db`
- SessionStart shows roku session-start-memory.sh
- SessionEnd shows roku session-end-harvest.sh

---

## Task 7: Update Blend Profile settings.json

**Files:**
- Modify: `~/.blend-claude/settings.json:32-39` (memory MCP env paths)
- Modify: `~/.blend-claude/settings.json:2-13` (add SessionStart/SessionEnd hooks)

- [ ] **Step 1: Backup current settings.json**

```bash
cp ~/.blend-claude/settings.json ~/.blend-claude/settings.json.backup-$(date +%Y%m%d)
echo "Backup created"
```

Expected: Backup file created

- [ ] **Step 2: Update memory MCP paths in settings.json**

Use Edit tool to replace:

OLD:
```json
    "memory": {
      "command": "/Users/germanabuarab/anaconda3/bin/memory",
      "args": ["server"],
      "env": {
        "MCP_MEMORY_CHROMA_PATH": "/Users/germanabuarab/Library/Application Support/mcp-memory/chroma_db",
        "MCP_MEMORY_BACKUPS_PATH": "/Users/germanabuarab/Library/Application Support/mcp-memory/backups"
      }
    }
```

NEW:
```json
    "memory": {
      "command": "/Users/germanabuarab/anaconda3/bin/memory",
      "args": ["server"],
      "env": {
        "MCP_MEMORY_CHROMA_PATH": "/Users/germanabuarab/.blend-claude/memory-db",
        "MCP_MEMORY_BACKUPS_PATH": "/Users/germanabuarab/.blend-claude/memory-backups"
      }
    }
```

- [ ] **Step 3: Add SessionStart and SessionEnd hooks**

Blend profile has minimal hooks config. Create or extend the `"hooks"` object:

```json
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash /Users/germanabuarab/.blend-claude/hooks/session-start-memory.sh"
          }
        ]
      }
    ],
    "SessionEnd": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash /Users/germanabuarab/.blend-claude/hooks/session-end-harvest.sh"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "input=$(cat); cmd=$(echo \"$input\" | jq -r '.tool_input.command // \"\"'); if echo \"$cmd\" | grep -qE 'rm[[:space:]]+-[a-zA-Z]*f'; then echo '{\"continue\": false, \"stopReason\": \"BLOQUEADO: rm -f y rm -rf estan prohibidos. Usa alternativas mas seguras o pregunta primero.\"}'; fi"
          }
        ]
      }
    ]
  }
```

- [ ] **Step 4: Validate JSON syntax**

```bash
python3 -m json.tool ~/.blend-claude/settings.json > /dev/null && echo "✓ Valid JSON" || echo "✗ Invalid JSON"
```

Expected: `✓ Valid JSON`

- [ ] **Step 5: Verify changes**

```bash
cat ~/.blend-claude/settings.json | jq '.mcpServers.memory.env'
cat ~/.blend-claude/settings.json | jq '.hooks.SessionStart[0]'
cat ~/.blend-claude/settings.json | jq '.hooks.SessionEnd[0]'
```

Expected:
- Memory env shows `/.blend-claude/memory-db`
- SessionStart shows blend session-start-memory.sh
- SessionEnd shows blend session-end-harvest.sh

---

## Task 8: Update Personal Profile CLAUDE.md

**Files:**
- Modify: `~/.personal-claude/CLAUDE.md` (append new section)

- [ ] **Step 1: Backup current CLAUDE.md**

```bash
cp ~/.personal-claude/CLAUDE.md ~/.personal-claude/CLAUDE.md.backup-$(date +%Y%m%d)
echo "Backup created"
```

Expected: Backup file created

- [ ] **Step 2: Append MCP Memory Auto-Capture section**

```bash
cat >> ~/.personal-claude/CLAUDE.md <<'EOF'

## MCP Memory Auto-Capture

You have access to semantic memory via the `memory` MCP server.

### When to Search Memory (Automatic via SessionStart)
- At session start, you'll receive a reminder to search for project context
- Use `memory_search` with the project name to find:
  - Past architectural decisions
  - Important configurations (API endpoints, DB names, etc.)
  - Established patterns and conventions
  - Known issues or gotchas

### When to Save to Memory (During Work)

**Guideline:** Save when you make or discover something **significant and reusable**. Use your contextual judgment — not every change deserves a memory, only those that:
- Would be valuable to recall in future sessions
- Represent a decision point (not just implementation details)
- Contain non-obvious project-specific knowledge

**Save these categories:**

**Architectural Decisions:**
- Technology choices (libraries, frameworks, tools) — save ONLY if non-trivial
- Design patterns chosen that deviate from defaults
- Trade-offs made between approaches (document WHY)
- System architecture changes (new services, major refactors)

**Important Project Data:**
- API endpoints and integration URLs (non-secret, production/staging URLs)
- Configuration values that aren't in code (feature flags, external IDs)
- Database/table/schema names for key entities
- Service names and their purposes (microservices, background jobs)
- Environment-specific details (dev, staging, prod) that aren't obvious

**Conventions Established:**
- Naming conventions agreed upon (especially if project-specific)
- Code organization patterns (folder structure, module boundaries)
- Git workflow decisions (branching strategy, PR requirements)
- Testing strategies (coverage thresholds, test data approach)

**When NOT to save:**
- Trivial implementation details ("added a function called getUserById")
- Things already in code/docs/CLAUDE.md
- Obvious choices ("used React for UI" in a React project)
- Temporary decisions or experiments

**Use this format:**
```
mcp__memory__memory_store({
  "content": "Clear description of what was decided/discovered and WHY",
  "metadata": {
    "tags": "decision,project-name,relevant-tech",
    "type": "decision" | "project-data" | "convention",
    "project": "<current-project-name>",
    "profile": "personal"
  }
})
```

**Deduplication note:** Don't worry about duplicates — semantic dedup will catch them. If unsure, save it. memory_harvest at session end will catch anything you miss.

### SessionEnd Harvest (Automatic)
- At session end, you'll receive a reminder to run `memory_harvest`
- This extracts learnings from the entire session transcript
- Tag all harvested memories with project, profile, and date

### Search Priority
1. **Structured knowledge:** Check Obsidian vault first (`projects/<project>/`)
2. **Semantic recall:** Use memory MCP for fuzzy/conceptual searches
3. **Past conversations:** Use episodic-memory MCP for "what did we discuss"
EOF
```

- [ ] **Step 3: Verify section was added**

```bash
tail -50 ~/.personal-claude/CLAUDE.md | head -20
```

Expected: Shows "## MCP Memory Auto-Capture" section at the end

---

## Task 9: Update Roku Profile CLAUDE.md

**Files:**
- Modify: `~/.roku-claude/CLAUDE.md` (append new section)

- [ ] **Step 1: Backup current CLAUDE.md**

```bash
cp ~/.roku-claude/CLAUDE.md ~/.roku-claude/CLAUDE.md.backup-$(date +%Y%m%d)
echo "Backup created"
```

Expected: Backup file created

- [ ] **Step 2: Append MCP Memory Auto-Capture section (roku variant)**

```bash
cat >> ~/.roku-claude/CLAUDE.md <<'EOF'

## MCP Memory Auto-Capture

You have access to semantic memory via the `memory` MCP server.

### When to Search Memory (Automatic via SessionStart)
- At session start, you'll receive a reminder to search for project context
- Use `memory_search` with the project name to find:
  - Past architectural decisions
  - Important configurations (API endpoints, DB names, etc.)
  - Established patterns and conventions
  - Known issues or gotchas

### When to Save to Memory (During Work)

**Guideline:** Save when you make or discover something **significant and reusable**. Use your contextual judgment — not every change deserves a memory, only those that:
- Would be valuable to recall in future sessions
- Represent a decision point (not just implementation details)
- Contain non-obvious project-specific knowledge

**Save these categories:**

**Architectural Decisions:**
- Technology choices (libraries, frameworks, tools) — save ONLY if non-trivial
- Design patterns chosen that deviate from defaults
- Trade-offs made between approaches (document WHY)
- System architecture changes (new services, major refactors)

**Important Project Data:**
- API endpoints and integration URLs (non-secret, production/staging URLs)
- Configuration values that aren't in code (feature flags, external IDs)
- Database/table/schema names for key entities
- Service names and their purposes (microservices, background jobs)
- Environment-specific details (dev, staging, prod) that aren't obvious

**Conventions Established:**
- Naming conventions agreed upon (especially if project-specific)
- Code organization patterns (folder structure, module boundaries)
- Git workflow decisions (branching strategy, PR requirements)
- Testing strategies (coverage thresholds, test data approach)

**When NOT to save:**
- Trivial implementation details ("added a function called getUserById")
- Things already in code/docs/CLAUDE.md
- Obvious choices ("used React for UI" in a React project)
- Temporary decisions or experiments

**Use this format:**
```
mcp__memory__memory_store({
  "content": "Clear description of what was decided/discovered and WHY",
  "metadata": {
    "tags": "decision,project-name,relevant-tech",
    "type": "decision" | "project-data" | "convention",
    "project": "<current-project-name>",
    "profile": "roku"
  }
})
```

**Deduplication note:** Don't worry about duplicates — semantic dedup will catch them. If unsure, save it. memory_harvest at session end will catch anything you miss.

### SessionEnd Harvest (Automatic)
- At session end, you'll receive a reminder to run `memory_harvest`
- This extracts learnings from the entire session transcript
- Tag all harvested memories with project, profile, and date

### Search Priority
1. **Structured knowledge:** Check Obsidian vault first (`projects/roku/`)
2. **Semantic recall:** Use memory MCP for fuzzy/conceptual searches
3. **Past conversations:** Use episodic-memory MCP for "what did we discuss"
EOF
```

- [ ] **Step 3: Verify section was added**

```bash
tail -50 ~/.roku-claude/CLAUDE.md | head -20
```

Expected: Shows "## MCP Memory Auto-Capture" section with `"profile": "roku"`

---

## Task 10: Update Blend Profile CLAUDE.md

**Files:**
- Modify: `~/.blend-claude/CLAUDE.md` (append new section)

- [ ] **Step 1: Backup current CLAUDE.md**

```bash
cp ~/.blend-claude/CLAUDE.md ~/.blend-claude/CLAUDE.md.backup-$(date +%Y%m%d)
echo "Backup created"
```

Expected: Backup file created

- [ ] **Step 2: Append MCP Memory Auto-Capture section (blend variant)**

```bash
cat >> ~/.blend-claude/CLAUDE.md <<'EOF'

## MCP Memory Auto-Capture

You have access to semantic memory via the `memory` MCP server.

### When to Search Memory (Automatic via SessionStart)
- At session start, you'll receive a reminder to search for project context
- Use `memory_search` with the project name to find:
  - Past architectural decisions
  - Important configurations (API endpoints, DB names, etc.)
  - Established patterns and conventions
  - Known issues or gotchas

### When to Save to Memory (During Work)

**Guideline:** Save when you make or discover something **significant and reusable**. Use your contextual judgment — not every change deserves a memory, only those that:
- Would be valuable to recall in future sessions
- Represent a decision point (not just implementation details)
- Contain non-obvious project-specific knowledge

**Save these categories:**

**Architectural Decisions:**
- Technology choices (libraries, frameworks, tools) — save ONLY if non-trivial
- Design patterns chosen that deviate from defaults
- Trade-offs made between approaches (document WHY)
- System architecture changes (new services, major refactors)

**Important Project Data:**
- API endpoints and integration URLs (non-secret, production/staging URLs)
- Configuration values that aren't in code (feature flags, external IDs)
- Database/table/schema names for key entities
- Service names and their purposes (microservices, background jobs)
- Environment-specific details (dev, staging, prod) that aren't obvious

**Conventions Established:**
- Naming conventions agreed upon (especially if project-specific)
- Code organization patterns (folder structure, module boundaries)
- Git workflow decisions (branching strategy, PR requirements)
- Testing strategies (coverage thresholds, test data approach)

**When NOT to save:**
- Trivial implementation details ("added a function called getUserById")
- Things already in code/docs/CLAUDE.md
- Obvious choices ("used React for UI" in a React project)
- Temporary decisions or experiments

**Use this format:**
```
mcp__memory__memory_store({
  "content": "Clear description of what was decided/discovered and WHY",
  "metadata": {
    "tags": "decision,project-name,relevant-tech",
    "type": "decision" | "project-data" | "convention",
    "project": "<current-project-name>",
    "profile": "blend"
  }
})
```

**Deduplication note:** Don't worry about duplicates — semantic dedup will catch them. If unsure, save it. memory_harvest at session end will catch anything you miss.

### SessionEnd Harvest (Automatic)
- At session end, you'll receive a reminder to run `memory_harvest`
- This extracts learnings from the entire session transcript
- Tag all harvested memories with project, profile, and date

### Search Priority
1. **Structured knowledge:** Check Obsidian vault first (`projects/blend/`)
2. **Semantic recall:** Use memory MCP for fuzzy/conceptual searches
3. **Past conversations:** Use episodic-memory MCP for "what did we discuss"
EOF
```

- [ ] **Step 3: Verify section was added**

```bash
tail -50 ~/.blend-claude/CLAUDE.md | head -20
```

Expected: Shows "## MCP Memory Auto-Capture" section with `"profile": "blend"`

---

## Task 11: Test Personal Profile - SessionStart Hook

**Files:**
- Test: `~/.personal-claude/hooks/session-start-memory.sh`
- Test: `~/.personal-claude/settings.json` (SessionStart hook config)

**Prerequisites:** Personal profile settings.json updated with SessionStart hook

- [ ] **Step 1: Simulate SessionStart hook manually**

```bash
cd /Users/germanabuarab/proyectos/claude-memory-hub
bash ~/.personal-claude/hooks/session-start-memory.sh
```

Expected: Outputs XML with `<session-start-memory-context>` and project name "claude-memory-hub"

- [ ] **Step 2: Start a test Claude Code session in personal profile**

```bash
# In a new terminal, from this project directory:
cd /Users/germanabuarab/proyectos/claude-memory-hub
claude
```

Expected: Session starts and shows SessionStart hook output in system reminder

- [ ] **Step 3: Verify memory MCP is accessible**

In the Claude session, run:
```
Use memory_health tool to verify MCP is connected
```

Expected: memory_health returns status "healthy" with personal memory-db path

- [ ] **Step 4: Exit session**

Expected: No errors

---

## Task 12: Test Personal Profile - Memory Isolation

**Files:**
- Test: `~/.personal-claude/memory-db/` (SQLite-vec database)

**Prerequisites:** Personal profile fully configured

- [ ] **Step 1: Store a test memory in personal profile**

In a personal profile Claude session:
```
Use memory_store to save:
{
  "content": "Test memory for personal profile isolation check",
  "metadata": {
    "tags": "test,isolation",
    "type": "learning",
    "project": "test",
    "profile": "personal"
  }
}
```

Expected: Memory stored successfully

- [ ] **Step 2: Search for the test memory**

```
Use memory_search with query "test isolation personal"
```

Expected: Returns the test memory

- [ ] **Step 3: Verify database file was created**

```bash
ls -lh ~/.personal-claude/memory-db/
```

Expected: SQLite database file(s) present (e.g., `chroma.sqlite3`)

- [ ] **Step 4: Check database is NOT in old shared location**

```bash
ls -lh "/Users/germanabuarab/Library/Application Support/mcp-memory/chroma_db/" 2>&1 | head -5
```

Expected: Either empty or shows old backup data (not updated)

---

## Task 13: Test Roku Profile - Full Integration

**Files:**
- Test: `~/.roku-claude/hooks/session-start-memory.sh`
- Test: `~/.roku-claude/hooks/session-end-harvest.sh`
- Test: `~/.roku-claude/memory-db/`

**Prerequisites:** Roku profile fully configured

- [ ] **Step 1: Start Claude session in roku profile**

```bash
cd /Users/germanabuarab/proyectos/test-project
claude-roku
```

Expected: SessionStart hook shows context reminder

- [ ] **Step 2: Verify memory MCP uses roku database**

```
Use memory_health tool
```

Expected: Backend shows `SqliteVecMemoryStorage` and database path is `~/.roku-claude/memory-db/`

- [ ] **Step 3: Store a test memory in roku profile**

```
Use memory_store:
{
  "content": "Test memory for roku profile - should be isolated from personal",
  "metadata": {
    "tags": "test,roku,isolation",
    "type": "learning",
    "project": "test",
    "profile": "roku"
  }
}
```

Expected: Memory stored

- [ ] **Step 4: Search for roku test memory**

```
Use memory_search with query "roku isolation"
```

Expected: Returns roku test memory only

- [ ] **Step 5: Verify roku database file was created**

```bash
ls -lh ~/.roku-claude/memory-db/
```

Expected: SQLite database file(s) present

- [ ] **Step 6: Verify permissions on roku memory-db**

```bash
ls -ld ~/.roku-claude/memory-db/
```

Expected: `drwx------` (user-only access for corporate data)

---

## Task 14: Test Blend Profile - Full Integration

**Files:**
- Test: `~/.blend-claude/hooks/session-start-memory.sh`
- Test: `~/.blend-claude/hooks/session-end-harvest.sh`
- Test: `~/.blend-claude/memory-db/`

**Prerequisites:** Blend profile fully configured

- [ ] **Step 1: Start Claude session in blend profile**

```bash
cd /Users/germanabuarab/proyectos/test-project
claude-blend
```

Expected: SessionStart hook shows context reminder

- [ ] **Step 2: Verify memory MCP uses blend database**

```
Use memory_health tool
```

Expected: Database path is `~/.blend-claude/memory-db/`

- [ ] **Step 3: Store a test memory in blend profile**

```
Use memory_store:
{
  "content": "Test memory for blend profile - third isolated database",
  "metadata": {
    "tags": "test,blend,isolation",
    "type": "learning",
    "project": "test",
    "profile": "blend"
  }
}
```

Expected: Memory stored

- [ ] **Step 4: Verify blend database file was created**

```bash
ls -lh ~/.blend-claude/memory-db/
```

Expected: SQLite database file(s) present

---

## Task 15: Verify Cross-Profile Isolation

**Files:**
- Test: All 3 profile memory-db directories

**Prerequisites:** All 3 profiles have test memories stored

- [ ] **Step 1: Search for personal memory in roku profile**

In roku profile session:
```
Use memory_search with query "personal profile isolation"
```

Expected: NO results (personal memory should not appear)

- [ ] **Step 2: Search for roku memory in personal profile**

In personal profile session:
```
Use memory_search with query "roku isolation"
```

Expected: NO results (roku memory should not appear)

- [ ] **Step 3: Search for blend memory in personal profile**

In personal profile session:
```
Use memory_search with query "blend isolated"
```

Expected: NO results (blend memory should not appear)

- [ ] **Step 4: Verify separate database files**

```bash
for profile in personal roku blend; do
  echo "--- $profile ---"
  ls -lh ~/."$profile"-claude/memory-db/ | grep -E '\.sqlite|chroma'
done
```

Expected: Each profile has its own database file(s), different sizes/timestamps

- [ ] **Step 5: Count total memories per profile**

In each profile session:
```
Use memory_health to see total_memories count
```

Expected:
- personal: 1 memory
- roku: 1 memory
- blend: 1 memory

---

## Task 16: Test SessionEnd Hook and memory_harvest

**Files:**
- Test: `~/.personal-claude/hooks/session-end-harvest.sh`

**Prerequisites:** Personal profile configured and has an active session with some work done

- [ ] **Step 1: Do meaningful work in a personal profile session**

```
Create a simple Python function, make an architectural decision (e.g., "decided to use pytest for testing"), and document it
```

Expected: Some work done that could be harvested

- [ ] **Step 2: End the session**

Expected: SessionEnd hook fires and shows harvest workflow instructions

- [ ] **Step 3: Follow harvest workflow - preview first**

```
Use memory_harvest with dry_run=true:
{
  "sessions": 1,
  "dry_run": true,
  "min_confidence": 0.7
}
```

Expected: Returns candidate memories extracted from session (might be empty if session was trivial)

- [ ] **Step 4: If candidates look good, store them**

```
Use memory_harvest with dry_run=false:
{
  "sessions": 1,
  "dry_run": false,
  "min_confidence": 0.7
}
```

Expected: Memories stored with session_date tag

- [ ] **Step 5: Verify harvested memories**

```
Use memory_search to find memories with today's session_date
```

Expected: Harvested memories appear in search results

---

## Task 17: Clean Up Test Memories

**Files:**
- Modify: All 3 profile memory databases

- [ ] **Step 1: Delete test memories from personal profile**

In personal profile session:
```
Use memory_delete to remove test memories by searching for tag "test"
```

Expected: Test memories deleted

- [ ] **Step 2: Delete test memories from roku profile**

In roku profile session:
```
Use memory_delete to remove test memories by tag "test"
```

Expected: Test memories deleted

- [ ] **Step 3: Delete test memories from blend profile**

In blend profile session:
```
Use memory_delete to remove test memories by tag "test"
```

Expected: Test memories deleted

- [ ] **Step 4: Verify all test memories removed**

In each profile:
```
Use memory_search with query "test isolation"
```

Expected: No results in any profile

---

## Task 18: Document Changes and Commit

**Files:**
- Create: `docs/MCP_MEMORY_INTEGRATION_COMPLETE.md` (completion report)

- [ ] **Step 1: Create completion report**

```bash
REPORT_DATE=$(date +%Y-%m-%d)
cat > docs/MCP_MEMORY_INTEGRATION_COMPLETE.md <<EOF
# MCP Memory Auto-Integration - Completion Report

**Date:** $REPORT_DATE
**Status:** ✅ Complete

## Summary

Successfully integrated automatic memory capture and retrieval across all 3 Claude Code profiles (personal, roku, blend) with isolated SQLite-vec databases.

## What Was Implemented

### 1. Isolated Memory Databases
- **personal:** `~/.personal-claude/memory-db/`
- **roku:** `~/.roku-claude/memory-db/` (restrictive permissions for corporate data)
- **blend:** `~/.blend-claude/memory-db/`

Each profile has its own SQLite-vec instance with mcp-memory-service v10.36.7.

### 2. Automatic Hooks
- **SessionStart:** Prompts Claude to search memory for project context
- **SessionEnd:** Guides memory_harvest workflow with safe deduplication (dry_run preview)

### 3. CLAUDE.md Instructions
All 3 profiles updated with:
- When to search memory (automatic via SessionStart)
- When to save during work (significant decisions, project data, conventions)
- Deduplication strategy (semantic dedup built-in, conservative parameters)
- Search priority (Obsidian vault → memory MCP → episodic-memory)

### 4. Configuration Changes
- `settings.json` updated with isolated memory paths for all 3 profiles
- SessionStart and SessionEnd hooks added to all profiles
- Hook scripts created and made executable

## Testing Results

✅ All profiles tested independently
✅ Cross-profile isolation verified (no data leakage)
✅ SessionStart hook triggers correctly
✅ SessionEnd hook provides harvest workflow
✅ memory_harvest preview (dry_run) works
✅ Semantic deduplication prevents spam

## Migration Notes

- Original shared database backed up to:
  `/Users/germanabuarab/Library/Application Support/mcp-memory/chroma_db.backup-YYYYMMDD/`
- Started fresh with empty databases per profile (recommended approach)

## Deduplication Strategy

- **memory_store:** Semantic dedup enabled by default (cosine similarity on embeddings)
- **conversation_id bypass:** For incremental notes within same session
- **memory_harvest:** Safe workflow with dry_run=true preview, min_confidence=0.7
- **Conservative defaults:** Prevents false positives and spam

## Next Steps (Optional)

1. After 1-2 weeks of use, evaluate memory quality
2. Consider enabling use_llm=true in harvest for better dedup
3. Promote high-value memories to Obsidian vault notes
4. Set up periodic backup of memory-db directories

## Files Modified

- `~/.personal-claude/settings.json`
- `~/.roku-claude/settings.json`
- `~/.blend-claude/settings.json`
- `~/.personal-claude/CLAUDE.md`
- `~/.roku-claude/CLAUDE.md`
- `~/.blend-claude/CLAUDE.md`

## Files Created

- `~/.personal-claude/hooks/session-start-memory.sh`
- `~/.personal-claude/hooks/session-end-harvest.sh`
- `~/.roku-claude/hooks/session-start-memory.sh`
- `~/.roku-claude/hooks/session-end-harvest.sh`
- `~/.blend-claude/hooks/session-start-memory.sh`
- `~/.blend-claude/hooks/session-end-harvest.sh`
- `~/.personal-claude/memory-db/` (directory)
- `~/.personal-claude/memory-backups/` (directory)
- `~/.roku-claude/memory-db/` (directory)
- `~/.roku-claude/memory-backups/` (directory)
- `~/.blend-claude/memory-db/` (directory)
- `~/.blend-claude/memory-backups/` (directory)
EOF
```

- [ ] **Step 2: Commit all plan and spec files**

```bash
cd /Users/germanabuarab/proyectos/claude-memory-hub
git add docs/
git commit -m "Complete MCP memory auto-integration for all profiles

- Add isolated SQLite-vec databases per profile (personal/roku/blend)
- Create SessionStart/SessionEnd hooks for automatic capture
- Update CLAUDE.md with memory usage instructions
- Implement safe deduplication strategy (dry_run preview)
- Verify cross-profile isolation

Resolves: Automatic memory integration requirement"
```

Expected: Changes committed

---

## Success Criteria

✅ **Automatic Context Retrieval:**
- Starting a session in any project shows memory search reminder
- Relevant past decisions/data retrievable via memory_search

✅ **Real-Time Capture:**
- Claude can save decisions during work via memory_store
- Important project data gets captured with proper metadata

✅ **Session Harvest:**
- SessionEnd hook provides harvest workflow instructions
- memory_harvest preview (dry_run) works before storing
- Harvested memories tagged with project, profile, date

✅ **Profile Isolation:**
- Roku memories never appear in personal profile searches
- Each profile has separate SQLite-vec database
- Roku memory-db has restrictive permissions (700)

✅ **Search Quality:**
- Semantic search finds relevant memories with different wording
- Memories properly tagged for filtering by project/profile

✅ **Deduplication:**
- Semantic dedup prevents identical/similar memories
- conversation_id bypass available for incremental notes
- memory_harvest uses conservative parameters (min_confidence=0.7)

---

## Notes

- This plan uses configuration management (JSON, bash scripts) rather than traditional code, so "testing" is verification-based
- Hook scripts are identical across profiles (DRY principle) but in separate directories
- Settings changes are profile-specific (memory paths, hook paths)
- CLAUDE.md sections are nearly identical except for profile name in metadata examples
