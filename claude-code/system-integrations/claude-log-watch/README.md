# claude-log-watch

Live-tails the tool-call log that [`../hooks/log-tools.sh`](../hooks/log-tools.sh) writes for the
current Claude Code session, so you can watch what Claude is doing in a second terminal.

## Setup

1. Make sure [`log-tools.sh`](../hooks/log-tools.sh) is wired up as a `SessionStart` /
   `PreToolUse` hook (see [`../settings.hooks.snippet.json`](../settings.hooks.snippet.json)).
   It writes JSON Lines logs to `<project>/.claude-logs/`.
2. Install this script on `PATH`:

   ```sh
   mkdir -p "$HOME/.local/bin"
   cp claude-log-watch "$HOME/.local/bin/"
   ```

3. Add `$HOME/.local/bin` to `PATH` if it isn't already (e.g. in `~/.bashrc` or `~/.zshrc`):

   ```sh
   export PATH="$HOME/.local/bin:$PATH"
   ```

   Reload your shell (`source ~/.bashrc`) or open a new terminal.

## Usage

Run from the project you want to watch (or pass its path as `DIR`):

```sh
claude-log-watch [-n LINES] [-p] [-c] [DIR]
```

- `-n LINES` — number of lines to show (default 30)
- `-p` — pretty one-line-per-entry view (requires `jq`)
- `-c` — only shell commands (`Bash` tool calls)
- `DIR` — workspace to watch (default: current directory)

It follows `.claude-logs/last-log.txt`, so it automatically switches to the new log file when a
new Claude session starts. Uses `inotifywait` if available (`sudo apt install inotify-tools`),
otherwise polls once per second.
