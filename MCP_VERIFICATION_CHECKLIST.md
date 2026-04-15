# MCP Verification Checklist

## Profile: Personal (`~/.personal-claude/`)

### 1. Start Session
```bash
claude-code --profile personal
```

### 2. Verify MCPs Loaded
- [ ] Ask Claude: "What MCP tools do you have available?"
- [ ] Expected: `mcp__obsidian__*`, `mcp__memory__*` tools visible

### 3. Test Obsidian MCP
- [ ] **List vault files**: "Lista archivos de mi vault con el MCP obsidian"
  - Expected: Shows files from all folders: `projects/`, `personal/`, `_shared/`
- [ ] **Read a file**: "Lee projects/claude-memory-hub/context.md"
  - Expected: Successfully reads the file
- [ ] **Search vault**: "Busca notas sobre 'decisions' en el vault"
  - Expected: Returns search results

### 4. Test Memory MCP
- [ ] **Store memory**: "Guarda una memoria de prueba: 'El perfil personal tiene acceso completo al vault' con tag source:personal y project:memory-hub"
  - Expected: Memory stored successfully
- [ ] **Search memory**: "Busca 'memory hub' en tu memoria semántica"
  - Expected: Returns the memory just stored
- [ ] **Search by tag**: "Busca todas las memorias con tag source:personal"
  - Expected: Returns all personal memories

### 5. Test Gmail MCP
- [ ] **List drafts**: "Lista mis borradores de Gmail"
  - Expected: Shows Gmail drafts (if any)

---

## Profile: Roku (`~/.roku-claude/`)

### 1. Start Session
```bash
claude-code --profile roku
```

### 2. Verify MCPs Loaded
- [ ] Ask Claude: "What MCP tools do you have available?"
- [ ] Expected: `mcp__obsidian__*`, `mcp__memory__*` tools visible

### 3. Test Obsidian MCP - **RESTRICTED ACCESS**
- [ ] **List vault files**: "Lista archivos de mi vault con el MCP obsidian"
  - Expected: Shows ONLY files from `projects/roku/` (NOT personal/, NOT _shared/)
- [ ] **Try reading restricted file**: "Lee personal/journal/2026-04-14.md"
  - Expected: Should FAIL or return empty (access denied)
- [ ] **Read allowed file**: "Lee projects/roku/context.md"
  - Expected: Successfully reads the file

### 4. Test Memory MCP
- [ ] **Store memory**: "Guarda una memoria de prueba: 'El perfil roku solo ve projects/roku/' con tag source:roku y project:roku-work"
  - Expected: Memory stored successfully
- [ ] **Search memory**: "Busca 'roku' en tu memoria semántica"
  - Expected: Returns the memory just stored
- [ ] **Verify isolation**: "Busca memorias con tag source:personal"
  - Expected: Should NOT see memories from personal profile (isolated ChromaDB)

---

## Profile: Blend (`~/.blend-claude/`)

### 1. Start Session
```bash
claude-code --profile blend
```

### 2. Verify MCPs Loaded
- [ ] Ask Claude: "What MCP tools do you have available?"
- [ ] Expected: `mcp__obsidian__*`, `mcp__memory__*` tools visible

### 3. Test Obsidian MCP - **RESTRICTED ACCESS**
- [ ] **List vault files**: "Lista archivos de mi vault con el MCP obsidian"
  - Expected: Shows ONLY files from `projects/blend/` (NOT personal/, NOT _shared/)
- [ ] **Try reading restricted file**: "Lee personal/journal/2026-04-14.md"
  - Expected: Should FAIL or return empty (access denied)
- [ ] **Read allowed file**: "Lee projects/blend/context.md"
  - Expected: Successfully reads the file

### 4. Test Memory MCP
- [ ] **Store memory**: "Guarda una memoria de prueba: 'El perfil blend solo ve projects/blend/' con tag source:blend y project:blend-work"
  - Expected: Memory stored successfully
- [ ] **Search memory**: "Busca 'blend' en tu memoria semántica"
  - Expected: Returns the memory just stored
- [ ] **Verify isolation**: "Busca memorias con tag source:personal o source:roku"
  - Expected: Should NOT see memories from other profiles (isolated ChromaDB)

---

## Common Issues & Solutions

### MCPs Not Loading
**Symptom**: Claude says "I don't see those MCP tools"

**Checks**:
1. Verify `settings.json` has `mcpServers` section
2. Check binaries exist:
   ```bash
   ls -la /Users/germanabuarab/anaconda3/bin/memory
   npx @bitbonsai/mcpvault --version
   ```
3. Restart Claude Code completely (exit and relaunch)
4. Check Claude Code logs for MCP initialization errors

### Obsidian Access Not Restricted
**Symptom**: Roku/Blend profiles can see all vault folders

**Fix**: Check if MCPVault supports path restrictions in config
- May need to configure vault subpath per profile
- Or use different vault paths per profile in `mcpServers.obsidian` config

### Memory Not Isolated Between Profiles
**Symptom**: Can see memories from other profiles

**Fix**: Each profile should use different ChromaDB paths:
- Personal: `~/Library/Application Support/mcp-memory/chroma_db`
- Roku: `~/Library/Application Support/mcp-memory-roku/chroma_db`
- Blend: `~/Library/Application Support/mcp-memory-blend/chroma_db`

Update each profile's `settings.json` accordingly.

---

## Expected MCP Tools

### Obsidian MCP (`@bitbonsai/mcpvault`)
- `mcp__obsidian__list_files`
- `mcp__obsidian__read_file`
- `mcp__obsidian__write_file`
- `mcp__obsidian__search`
- `mcp__obsidian__append_to_file`

### Memory MCP (`mcp-memory`)
- `mcp__memory__store`
- `mcp__memory__search`
- `mcp__memory__query`
- `mcp__memory__delete`

### Gmail MCP (already working)
- `mcp__claude_ai_Gmail__*` (various Gmail operations)
