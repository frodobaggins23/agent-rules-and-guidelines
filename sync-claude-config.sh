#!/usr/bin/env bash
# Syncs Claude Code config files between this repo's claude-code/ dir and ~/.claude/.
#
# Usage:
#   ./sync-claude-config.sh to-home [--dry-run] [--yes]   # claude-code/ -> ~/.claude/
#   ./sync-claude-config.sh to-repo [--dry-run] [--yes]   # ~/.claude/ -> claude-code/
#
# Always shows what would change first; asks for confirmation before copying
# unless --yes is given. --dry-run only shows the preview, never copies.
#
# settings.hooks.snippet.json is intentionally never synced: it must be merged
# by hand into ~/.claude/settings.json (see README's "Quick migration" section).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/claude-code"
HOME_DIR="$HOME/.claude"

# Relative to both REPO_DIR and HOME_DIR. Trailing slash = directory contents.
ITEMS=(
  "CLAUDE.md"
  "commandments.md"
  "rules/"
  "hooks/"
)

usage() {
  cat <<EOF
Usage: $(basename "$0") <to-home|to-repo> [--dry-run] [--yes]

  to-home    copy claude-code/ -> ~/.claude/
  to-repo    copy ~/.claude/ -> claude-code/

  --dry-run  only show what would change, never copy
  --yes      skip the confirmation prompt

Synced: ${ITEMS[*]}
Skipped (never synced): settings.hooks.snippet.json (merge by hand into
~/.claude/settings.json), templates/ (project scaffolding, not a home config),
system-integrations/ (installed elsewhere, see its own README).
EOF
}

direction="${1:-}"
[[ $# -gt 0 ]] && shift

dry_run=0
assume_yes=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) dry_run=1 ;;
    --yes) assume_yes=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; usage; exit 1 ;;
  esac
done

case "$direction" in
  to-home) src="$REPO_DIR"; dst="$HOME_DIR" ;;
  to-repo) src="$HOME_DIR"; dst="$REPO_DIR" ;;
  -h|--help|"") usage; exit 0 ;;
  *) echo "Unknown direction: $direction" >&2; usage; exit 1 ;;
esac

if ! command -v rsync >/dev/null 2>&1; then
  echo "rsync is required but not found on PATH." >&2
  exit 1
fi

echo "Direction: $src -> $dst"
echo

rsync_for() {
  local item="$1" flags=(-a --itemize-changes)
  [[ -n "${2:-}" ]] && flags+=("$2")
  if [[ "$item" == */ ]]; then
    mkdir -p "$dst/$item"
    rsync "${flags[@]}" "$src/$item" "$dst/$item"
  else
    mkdir -p "$dst/$(dirname "$item")"
    rsync "${flags[@]}" "$src/$item" "$dst/$item"
  fi
}

preview=""
for item in "${ITEMS[@]}"; do
  if [[ ! -e "${src%/}/$item" && ! -e "$src/$item" ]]; then
    echo "skip (missing in source): $item"
    continue
  fi
  out="$(rsync_for "$item" --dry-run)"
  if [[ -n "$out" ]]; then
    preview+="$out"$'\n'
  fi
done

if [[ -z "$preview" ]]; then
  echo "Already in sync, nothing to do."
  exit 0
fi

echo "Changes:"
echo "$preview"

if [[ $dry_run -eq 1 ]]; then
  echo "(dry run, nothing copied)"
  exit 0
fi

if [[ $assume_yes -eq 0 ]]; then
  read -r -p "Apply these changes? [y/N] " reply
  case "$reply" in
    y|Y|yes|YES) ;;
    *) echo "Aborted."; exit 1 ;;
  esac
fi

for item in "${ITEMS[@]}"; do
  [[ -e "${src%/}/$item" || -e "$src/$item" ]] || continue
  rsync_for "$item" >/dev/null
done

echo "Done."
