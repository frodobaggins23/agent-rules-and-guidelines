#!/usr/bin/env bash
# Claude Code hook: logs every tool call to <project>/.claude-logs/
#
#   <project>/.claude-logs/<YYYY-MM-DD_HH-MM-SS>.json   one JSON object per line (JSON Lines)
#   <project>/.claude-logs/last-log.txt                 name of the most recently active log
#
# Handles the SessionStart and PreToolUse events (wire both to this script).
# Shell commands (Bash tool) get "is_command": true so they're easy to filter.
# Requires: jq (sudo apt install jq)

set -uo pipefail

input="$(cat)"
command -v jq >/dev/null 2>&1 || exit 0   # never break Claude if jq is missing

event=$(jq -r '.hook_event_name // empty' <<<"$input")
session=$(jq -r '.session_id // "unknown"' <<<"$input")
cwd=$(jq -r '.cwd // empty' <<<"$input")

project="${CLAUDE_PROJECT_DIR:-${cwd:-$PWD}}"
logdir="$project/.claude-logs"
mapdir="$logdir/.sessions"            # session_id -> log file name
mkdir -p "$mapdir" || exit 0

new_log() {
  local stamp name
  stamp="$(date '+%Y-%m-%d_%H-%M-%S')"
  name="$stamp.json"
  # two sessions starting in the same second shouldn't share a file
  [[ -e "$logdir/$name" ]] && name="${stamp}_${session:0:8}.json"
  : > "$logdir/$name"
  printf '%s\n' "$name" > "$mapdir/$session"
}

# Start a fresh file on a new session or /clear; reuse it on resume/compact.
if [[ "$event" == "SessionStart" ]]; then
  source_=$(jq -r '.source // "startup"' <<<"$input")
  case "$source_" in
    startup|clear) new_log ;;
    *) [[ -s "$mapdir/$session" ]] || new_log ;;
  esac
fi

# Lazily create a log if this session has none yet (e.g. hooks added mid-session).
[[ -s "$mapdir/$session" ]] || new_log
log="$(head -n1 "$mapdir/$session")"

printf '%s\n' "$log" > "$logdir/last-log.txt"

jq -c --arg ts "$(date '+%Y-%m-%dT%H:%M:%S%z')" '
  # keep lines readable: shorten huge strings (e.g. Write/Edit file contents)
  def short: walk(if type == "string" and length > 500
                  then .[:500] + "…[truncated]" else . end);
  {
    ts:         $ts,
    event:      .hook_event_name,
    session:    .session_id,
    source:     .source,
    tool:       .tool_name,
    is_command: (.tool_name == "Bash"),
    command:    (if .tool_name == "Bash" then .tool_input.command else null end),
    input:      (.tool_input | short)
  }
  | with_entries(select(.value != null))
' <<<"$input" >> "$logdir/$log"

exit 0
