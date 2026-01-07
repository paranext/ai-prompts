#!/bin/bash
# Hook: SubagentStop - Log when a subagent completes
source "$(dirname "$0")/lib/audit-utils.sh"

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id')

AGENT=$(get_current_agent)
ensure_dirs
log_entry "$SESSION_ID" "SUBAGENT_STOP" "$AGENT" "" ""

# Clear agent state (back to parent context)
echo "" > "$STATE_DIR/current_agent"

echo '{"continue": true}'
