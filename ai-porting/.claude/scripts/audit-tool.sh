#!/bin/bash
# Hook: PreToolUse - Log tool calls with formatted input
source "$(dirname "$0")/lib/audit-utils.sh"

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id')
TOOL=$(echo "$INPUT" | jq -r '.tool_name')
TOOL_INPUT=$(echo "$INPUT" | jq -c '.tool_input')

AGENT=$(get_current_agent)

# If Task tool, extract and track the subagent
if [[ "$TOOL" == "Task" ]]; then
  SUBAGENT=$(echo "$TOOL_INPUT" | jq -r '.subagent_type // empty')
  if [[ -n "$SUBAGENT" ]]; then
    echo "$SUBAGENT" > "$STATE_DIR/current_agent"
    AGENT="$SUBAGENT"
  fi
fi

# Format the input for readable logging
DETAILS=$(format_input "$TOOL" "$TOOL_INPUT")

ensure_dirs
log_entry "$SESSION_ID" "TOOL" "$AGENT" "$TOOL" "$DETAILS"
echo '{"continue": true}'
