#!/bin/bash

echo "=== Testing Cross-Profile Isolation ==="
echo ""

# Store test memory in current profile
echo "📝 Storing test memory in PERSONAL profile..."
# This would need to be done in actual Claude session

echo ""
echo "✅ Configuration verification:"
echo ""

echo "1. Personal profile memory path:"
grep -A 2 "MCP_MEMORY_CHROMA_PATH" ~/.personal-claude/settings.json | grep personal-claude

echo ""
echo "2. Roku profile memory path:"
grep -A 2 "MCP_MEMORY_CHROMA_PATH" ~/.roku-claude/settings.json | grep roku-claude

echo ""
echo "3. Blend profile memory path:"
grep -A 2 "MCP_MEMORY_CHROMA_PATH" ~/.blend-claude/settings.json | grep blend-claude

echo ""
echo "4. Database directories exist:"
ls -ld ~/.personal-claude/memory-db/ ~/.roku-claude/memory-db/ ~/.blend-claude/memory-db/

echo ""
echo "5. Roku has restrictive permissions:"
ls -ld ~/.roku-claude/memory-db/ | grep "drwx------"

echo ""
echo "=== Manual Testing Steps ==="
echo ""
echo "To fully test isolation, run these commands in separate terminals:"
echo ""
echo "Terminal 1 (personal profile):"
echo "  claude"
echo "  # Then use memory_store to save a test memory"
echo "  # Then use memory_search to verify it exists"
echo ""
echo "Terminal 2 (roku profile):"
echo "  claude-roku"
echo "  # Then use memory_search for the same query"
echo "  # Result: should be EMPTY (no personal memories)"
echo ""
echo "Terminal 3 (blend profile):"
echo "  claude-blend"
echo "  # Then use memory_search for the same query"
echo "  # Result: should be EMPTY (no personal memories)"
echo ""
echo "✅ If searches in roku/blend return EMPTY, isolation is verified"
