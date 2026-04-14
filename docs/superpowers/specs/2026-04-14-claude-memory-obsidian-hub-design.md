# Claude Memory Hub — Obsidian-Centric Design Spec

**Date:** 2026-04-14
**Status:** Draft
**Project location:** `~/proyectos/claude-memory-hub/`

## Problem Statement

Claude Code has no persistent memory across sessions. Each conversation starts fresh, causing:
1. **Lost decisions:** Architectural choices, conventions, and patterns discussed in past sessions are forgotten
2. **No access to personal knowledge:** Claude cannot reference the user's notes, ideas, or research
3. **Codebase re-discovery:** Every session wastes tokens re-exploring project structure via Glob/Grep
4. **No semantic recall:** Cannot answer "what did we discuss about X?" beyond what's in CLAUDE.md

## Current State

The user already has:
- **episodic-memory** plugin (Superpowers): Semantic search across 1,320+ archived conversations. SQLite + sqlite-vec. Local embeddings via Transformers.js.
- **CLAUDE.md** per profile/project: Static instructions loaded at session start
- **Auto-memory (MEMORY.md):** Claude's self-written notes (not yet created/used)
- **3 Claude Code profiles:** personal (`~/.personal-claude/`), roku (`~/.roku-claude/`), blend (`~/.blend-claude/`)
- **Obsidian:** Installed but not heavily used

## Solution: 4-Layer Memory Architecture

```
┌─────────────────────────────────────────────────────────────┐
│           3 Perfiles (personal / roku / blend)               │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  settings.json (per profile, shared MCP config)       │  │
│  │  ├── MCP: obsidian (vault read/write)                 │  │
│  │  ├── MCP: memory-service (semantic memory)            │  │
│  │  └── Plugin: episodic-memory (conversation recall)    │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                              │
│  CLAUDE.md (per profile) → vault scoping per project         │
│  CLAUDE.md (per project) → Graphify graph path               │
└──────────────────────────┬───────────────────────────────────┘
                           │
               ┌───────────┼───────────┐
               ▼           ▼           ▼
       ~/obsidian-vault  ChromaDB    graphify-out/
       (curated          (semantic   (per-project
        knowledge)       memory)     codebase graph)
```

### Layer 1: Conversation Recall (episodic-memory) — EXISTING

- **What:** Semantic search across all past Claude Code conversations
- **Storage:** SQLite with sqlite-vec, 384-dim embeddings via Transformers.js
- **Status:** Already installed and working
- **Action:** No changes needed. Keep as-is.

### Layer 2: Curated Knowledge Base (Obsidian Vault + MCP-Obsidian.org)

- **What:** Structured knowledge base for decisions, patterns, runbooks, personal notes
- **Storage:** Markdown files in `~/obsidian-vault/`
- **MCP server:** MCP-Obsidian.org (reads directly from disk, no Obsidian running required)
- **Tools:** 14 tools — read, write, create, search (BM25), move, list, etc.

#### Vault Structure

```
~/obsidian-vault/
├── .obsidian/                     # Obsidian app config
├── _shared/                       # Cross-project knowledge
│   ├── patterns/                  # Reusable code patterns
│   ├── conventions/               # Naming, git, style conventions
│   ├── tools/                     # Notes about tools and configs
│   └── learnings/                 # Lessons learned across projects
├── projects/
│   ├── roku/
│   │   ├── decisions/             # Architecture Decision Records
│   │   ├── patterns/              # Project-specific patterns
│   │   ├── runbooks/              # How-tos (deploy, debug, etc.)
│   │   └── context.md             # Project summary for Claude
│   ├── sir-loin/
│   │   ├── campaign/
│   │   ├── npcs/
│   │   └── context.md
│   ├── blend/
│   │   ├── decisions/
│   │   ├── patterns/
│   │   └── context.md
│   └── ...                        # Other projects as needed
├── personal/                      # Personal notes, ideas, research
├── daily/                         # Daily notes (optional)
└── templates/                     # Templates for ADRs, notes, etc.
```

#### Scoping per Profile

Each Claude Code profile's CLAUDE.md includes vault scope instructions:

- **roku profile:** Focus on `projects/roku/` + `_shared/`
- **blend profile:** Focus on `projects/blend/` + `_shared/`
- **personal profile:** Access all of `projects/` + `personal/`

### Layer 3: Semantic Memory (mcp-memory-service + ChromaDB)

- **What:** Deep semantic search and temporal recall across all knowledge
- **Storage:** ChromaDB vector store with sentence-transformer embeddings
- **MCP server:** mcp-memory-service by doobidoo
- **Key capabilities:**
  - Semantic search: "how did we handle auth?" finds relevant memories even without keyword match
  - Temporal recall: "what did I work on last week?" works
  - `memory_harvest`: Extracts learnings from Claude Code session transcripts
  - Automatic consolidation: Groups similar memories to avoid duplicates
  - 100% local: No API keys, no GPU required (ONNX lightweight mode)
  - Dashboard: Web UI for direct ChromaDB queries

#### Complementarity with Vault

| Obsidian Vault | mcp-memory-service |
|---|---|
| Curated, human-organized knowledge | Automatic, diffuse memory |
| BM25 keyword search | Semantic vector search |
| Explicit write (user or Claude writes notes) | Implicit capture (harvested from sessions) |
| Structured by folders | Searchable by meaning and time |

**Flow:** Claude searches vault first (structured knowledge). If not found, falls back to mcp-memory-service (semantic recall). Valuable findings from memory-service get consolidated as permanent vault notes.

### Layer 4: Codebase Knowledge Graph (Graphify)

- **What:** AST-based knowledge graph of codebase structure
- **Storage:** `graphify-out/GRAPH_REPORT.md` per project repo
- **Tool:** Graphify (tree-sitter AST extraction, no LLM needed)
- **Supports:** 23 languages (JS/TS, Python, Java, Go, Rust, etc.)
- **Key output:** GRAPH_REPORT.md containing:
  - Project structure (modules, dependencies)
  - Classes, functions, interfaces and their relationships
  - Import/export graph
  - Detected patterns

#### Usage

Run once per project (and after significant changes):
```bash
graphify analyze ./my-project --output ./my-project/graphify-out/
```

Per-project CLAUDE.md instructs Claude to read `graphify-out/GRAPH_REPORT.md` before using Glob/Grep.

Optional PreToolUse hook reminds Claude to check the graph before brute-force searching.

**Note:** Graphify is the newest, least-proven component. If it doesn't provide enough value, it can be removed without affecting the other 3 layers.

## Configuration

### MCP Servers (added to each profile's settings.json)

```json
{
  "mcpServers": {
    "obsidian": {
      "command": "npx",
      "args": ["-y", "@mcp-obsidian/server", "--vault-path", "/Users/germanabuarab/obsidian-vault"]
    },
    "memory-service": {
      "command": "uvx",
      "args": ["mcp-memory-service"]
    }
  }
}
```

> Note: Exact command/args to be verified during implementation against each tool's README.

### Hooks

#### SessionEnd Hook (all profiles)
Runs `memory_harvest` to extract learnings from the completed session and optionally write key decisions to the vault.

#### PreToolUse Hook (per project, optional)
For projects with Graphify: reminds Claude to check GRAPH_REPORT.md before Glob/Grep operations.

### CLAUDE.md Additions

Each profile gets an `## Obsidian Memory` section with:
- Vault scope (which project folder to focus on)
- Memory tagging convention (tag memories with source profile)
- Graphify instructions (if applicable)

## Installation Steps (High-Level)

### Phase 1: Obsidian Vault Setup
1. Create vault directory at `~/obsidian-vault/`
2. Initialize folder structure
3. Create template files (ADR template, context template, etc.)
4. Open vault in Obsidian app to initialize `.obsidian/` config

### Phase 2: MCP-Obsidian.org
1. Install MCP-Obsidian.org
2. Add to settings.json of all 3 profiles
3. Test vault read/write from Claude Code
4. Add scoping instructions to each profile's CLAUDE.md

### Phase 3: mcp-memory-service
1. Install ChromaDB (via pip or standalone)
2. Install mcp-memory-service
3. Add to settings.json of all 3 profiles
4. Configure SessionEnd hook for memory_harvest
5. Test semantic search and temporal recall

### Phase 4: Graphify
1. Install Graphify
2. Run on one project as proof of concept
3. Add CLAUDE.md instructions for the test project
4. Evaluate value — keep or remove

### Phase 5: Validation
1. End-to-end test: start new session, verify Claude uses vault + memory
2. Cross-profile test: verify scoping works (roku sees roku, personal sees all)
3. Performance test: verify session startup is not noticeably slower
4. Document the setup for future reference

## Success Criteria

- [ ] Claude remembers architectural decisions from previous sessions without being told
- [ ] Claude can access personal notes and project context from the vault
- [ ] Semantic search finds relevant memories even without exact keyword match
- [ ] Each profile is scoped to its own project area in the vault
- [ ] No noticeable increase in session startup time
- [ ] Each layer can be disabled independently without breaking the others
- [ ] The vault is browsable and editable in Obsidian by the user

## Risks and Mitigations

| Risk | Mitigation |
|------|-----------|
| Context window bloat from too much memory | Vault scoping limits what Claude reads. CLAUDE.md stays under 100 lines. |
| ChromaDB process management | Install as user service or use ONNX lightweight mode |
| Graphify adds little value | It's the last phase and can be removed without affecting other layers |
| MCP server conflicts between profiles | Each profile has independent settings.json, shared servers are stateless |
| Obsidian vault gets messy over time | Templates and conventions keep structure clean. Periodic review. |

## Out of Scope

- Knowledge graph with Neo4j (evaluated as Approach C, rejected for complexity)
- Multiple Obsidian vaults per project (single vault with folder scoping chosen)
- Automatic note generation from conversations (beyond memory_harvest)
- Sync to cloud (everything stays local)
