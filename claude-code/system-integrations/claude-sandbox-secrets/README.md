# claude-sandbox-secrets

Exposes secrets as environment variables so tools work inside Claude Code's Bash sandbox without
the sandbox ever seeing the real values.

## Why

- CLI tools usually keep their secrets in the system keyring or a config file under `~`. The
  sandbox hides those (`sandbox.filesystem.denyRead`), so sandboxed tools run unauthenticated.
- `sandbox.credentials.envVars` fixes this, but only for secrets held in **environment
  variables**. Claude Code reads each listed variable from its own environment, gives sandboxed
  commands a masked placeholder, and swaps in the real value only on requests to that secret's
  `injectHosts`.
- [`script.sh`](script.sh) exports those variables from `~/.bashrc`, so they are set when Claude
  Code starts. Without it there is nothing to mask and the tools fail in the sandbox.

Each export only runs when its variable is unset, so a sandboxed shell that sources `~/.bashrc`
keeps the placeholder instead of trying to fetch the real secret.

## Secrets

| Variable   | Source           | `injectHosts`                          | Used by |
|------------|------------------|----------------------------------------|---------|
| `GH_TOKEN` | `gh auth token`  | `api.github.com`, `uploads.github.com` | `gh`    |

Matching `~/.claude/settings.json` entry:

```json
"credentials": {
  "envVars": [
    { "name": "GH_TOKEN", "mode": "mask", "injectHosts": ["api.github.com", "uploads.github.com"] }
  ]
}
```

## Setup

1. Log in to each tool once (e.g. `gh auth login`).
2. Append the script to `~/.bashrc`:

   ```sh
   cat script.sh >> ~/.bashrc
   ```

3. Open a new terminal and restart Claude Code from it so it inherits the variables.
   For the VS Code extension, fully quit VS Code and relaunch it. Launching from the desktop menu
   works (VS Code loads your login shell's environment at startup); launching from a terminal
   (`code .`) is the fallback if a secret does not come through.

## Verify

Ask Claude to run a command that needs the secret, e.g. `gh api user --jq .login`, which should
print your GitHub login.

## Adding a secret

1. Add an export block to [`script.sh`](script.sh), guarded by an "only if unset" check like the
   existing one, and re-append it to `~/.bashrc`.
2. Add an `envVars` entry in `~/.claude/settings.json` with `"mode": "mask"` and only the hosts
   that need the secret in `injectHosts`.
3. Make sure those hosts are also in `sandbox.network.allowedDomains`.
4. Add a row to the [Secrets](#secrets) table and restart Claude Code.

## Trade-off

Every exported secret is set in every shell you open, not just in Claude Code. Any program started
from those shells can read it. Export only what sandboxed tools actually need.
