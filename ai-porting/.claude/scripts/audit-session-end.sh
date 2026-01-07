#!/bin/bash
# Hook: SessionEnd - Finalize session log and update summary
source "$(dirname "$0")/lib/audit-utils.sh"

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id')

# Count tools used in this session
TOOL_COUNT=$(grep -c "|TOOL|" "$AUDIT_DIR/sessions/${SESSION_ID}.log" 2>/dev/null || echo "0")

ensure_dirs
log_entry "$SESSION_ID" "SESSION_END" "" "" "tools=$TOOL_COUNT"

# Append to summary log
echo "$(get_timestamp)|$SESSION_ID|$TOOL_COUNT tools" >> "$AUDIT_DIR/summary.log"

# Cleanup temp state
rm -rf "$STATE_DIR"

echo '{"continue": true}'
