# Claude Memory Hub

Automatic memory capture and retrieval system for Claude Code using mcp-memory-service.

## What This Does

- **SessionStart**: Automatically searches memory for project context
- **SessionEnd**: Guides memory harvest workflow with safe deduplication
- **Real-time capture**: Claude saves important decisions during work
- **Cross-profile isolation**: Personal/roku/blend memories never mix

## Architecture

- **3 isolated SQLite-vec databases** (one per profile)
- **Hybrid approach**: Hooks for automation + Claude's judgment for what's important
- **Safe deduplication**: dry_run preview before storing harvested memories
- **Technology**: mcp-memory-service v10.36.7, all-MiniLM-L6-v2 embeddings

## Files

- `docs/superpowers/specs/` - Design specification
- `docs/superpowers/plans/` - Implementation plan
- `docs/MCP_MEMORY_INTEGRATION_COMPLETE.md` - Completion report
- `test-cross-profile-isolation.sh` - Verification script

## Usage

Already configured in all 3 profiles. Just restart Claude Code to activate hooks.

**Search memory:**
```
Use memory_search with query "project-name decisions"
```

**Save memory:**
```
Use memory_store with content and metadata (tags, type, project, profile)
```

**Harvest at end:**
SessionEnd hook guides you through the workflow.

## Verification

Run `./test-cross-profile-isolation.sh` to verify isolation is working.

## Documentation

- ADR: `~/obsidian-vault/projects/claude-memory-hub/decisions/2026-04-16-mcp-memory-auto-integration.md`
- Memory stored in MCP with tags: decision,claude-memory-hub,mcp,architecture
