#!/bin/bash
# Shared utilities for Claude Code audit trail hooks

AUDIT_DIR="${CLAUDE_PROJECT_DIR:-.}/.context/audit-logs"
STATE_DIR="/tmp/claude-audit-state"

get_timestamp() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }
get_current_agent() { cat "$STATE_DIR/current_agent" 2>/dev/null || echo ""; }
ensure_dirs() { mkdir -p "$AUDIT_DIR/sessions" "$STATE_DIR"; }

log_entry() {
  local session_id="$1" event="$2" agent="$3" tool="$4" details="$5"
  local ts=$(get_timestamp)
  echo "$ts|$session_id|$event|$agent|$tool|$details" >> "$AUDIT_DIR/sessions/${session_id}.log"
}

# Format tool input for readable logging
format_input() {
  local tool="$1" input="$2"
  case "$tool" in
    Read)
      local file=$(echo "$input" | jq -r '.file_path // empty')
      local offset=$(echo "$input" | jq -r '.offset // empty')
      local limit=$(echo "$input" | jq -r '.limit // empty')
      if [[ -n "$offset" || -n "$limit" ]]; then
        echo "file=$file (lines ${offset:-1}-${limit:-end})"
      else
        echo "file=$file (full)"
      fi
      ;;
    Glob)
      local pattern=$(echo "$input" | jq -r '.pattern // empty')
      local path=$(echo "$input" | jq -r '.path // "."')
      echo "pattern=$pattern path=$path"
      ;;
    Grep)
      local pattern=$(echo "$input" | jq -r '.pattern // empty')
      local path=$(echo "$input" | jq -r '.path // "."')
      echo "pattern=\"$pattern\" path=$path"
      ;;
    Task)
      local subagent=$(echo "$input" | jq -r '.subagent_type // empty')
      local prompt=$(echo "$input" | jq -r '.prompt // empty' | cut -c1-80)
      echo "subagent=$subagent prompt=\"$prompt...\""
      ;;
    Edit|Write)
      local file=$(echo "$input" | jq -r '.file_path // empty')
      echo "file=$file"
      ;;
    Bash)
      local cmd=$(echo "$input" | jq -r '.command // empty' | cut -c1-100)
      echo "cmd=\"$cmd\""
      ;;
    *)
      echo "$input" | jq -c '.' 2>/dev/null | cut -c1-150 || echo "(unparseable)"
      ;;
  esac
}
