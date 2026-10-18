
# Expose the gh keyring token as GH_TOKEN so Claude Code can mask it for sandboxed gh calls.
# Only set it when unset, so a masked placeholder inside the sandbox is never overwritten.
if [ -z "${GH_TOKEN:-}" ] && command -v gh >/dev/null 2>&1; then
  _gh_token="$(gh auth token 2>/dev/null)" && [ -n "$_gh_token" ] && export GH_TOKEN="$_gh_token"
  unset _gh_token
fi