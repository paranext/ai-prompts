#!/bin/bash
# Hook: SessionStart - Initialize audit trail for new session
source "$(dirname "$0")/lib/audit-utils.sh"

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id')
CWD=$(echo "$INPUT" | jq -r '.cwd')

ensure_dirs
echo "" > "$STATE_DIR/current_agent"

log_entry "$SESSION_ID" "SESSION_START" "" "" "cwd=$CWD"
echo '{"continue": true}'
