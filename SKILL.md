---
name: setup-statusline
description: >
  Set up or configure Claude Code's statusLine to show model, context usage, git branch,
  working directory, and output style in the bottom status bar. Use this skill whenever
  the user asks to install, configure, set up, or customize the status line / status bar
  in Claude Code. Also use it when the user runs /setup-statusline or mentions wanting
  a status bar with any combination of model, context, tokens, git branch, or directory info.
---

# Setup StatusLine for Claude Code

Install a custom, ANSI-colored status bar that shows five items at a glance:

```
model-name | ███░░░░░░░ 12.5% | main | /home/project | markdown
```

Each item has a distinct color so you can scan them quickly. Context percentage changes color based on usage level (green → yellow → red). A 10-block progress bar (light blue `█` filled / `░` empty, rounded) gives a quick visual read on context usage.

## Supported platforms

| Platform | Script | Dependencies |
|---|---|---|
| Windows (PowerShell) | `statusline.ps1` | PowerShell, Git |
| Linux / macOS (Bash) | `statusline.sh` | bash, jq, git, bc |

## Setup steps (Claude must follow these exactly)

### Step 1: Detect platform

Check the environment where this command is running. Look at the shell being used:
- If running in PowerShell → use `scripts/statusline.ps1`
- If running in bash/zsh → use `scripts/statusline.sh`

### Step 2: Read the bundled script

Read the appropriate script from this skill's `scripts/` directory. The skill directory is located next to this SKILL.md file.

### Step 3: Write the script to the user's home directory

- **Windows**: `~\.claude\statusline.ps1`
- **Linux/macOS**: `~/.claude/statusline.sh`

First ensure the `~/.claude/` directory exists (create it if missing).

For Linux/macOS, also make the script executable: `chmod +x ~/.claude/statusline.sh`

### Step 4: Read the existing settings.json

Read `~/.claude/settings.json`. If it doesn't exist, start with `{}`.

Parse it as JSON:
- If it already has a `statusLine` key, replace it
- If it doesn't have one, add it

### Step 5: Add the statusLine config

Update the settings object by adding (or replacing) a top-level `statusLine` key:

**On Windows (PowerShell):**
```json
{
  "statusLine": {
    "type": "command",
    "command": "powershell -NoProfile -ExecutionPolicy Bypass -File \"<absolute-path-to-home>\\.claude\\statusline.ps1\""
  }
}
```

**On Linux/macOS (Bash):**
```json
{
  "statusLine": {
    "type": "command",
    "command": "bash <absolute-path-to-home>/.claude/statusline.sh"
  }
}
```

Important: convert `~` to the actual absolute home directory path before writing. The `command` field must contain a full absolute path.

### Step 6: Merge and save

Merge the new `statusLine` key into the existing settings (keep all other settings unchanged). Write the result back to `~/.claude/settings.json` with proper JSON formatting (2-space indentation).

### Step 7: Confirmation

Tell the user:
- What was installed and where
- To restart Claude Code for the status bar to appear
- What the status bar will look like: `model | ███░░░░░░░ context% | git-branch | cwd | output-style`
- Show which script was used (PowerShell or Bash)

## What the status bar displays

| Position | Field | Color | Example |
|---|---|---|---|
| 1 | Model display name | Cyan bold | `deepseek-v4-pro[1m]` |
| 2 | Progress bar + context % | Light blue bar, Green/Yellow/Red % | `█████░░░░░ 50%` |
| 3 | Git branch | Magenta | `main` |
| 4 | Working directory | Blue | `D:\桌面` |
| 5 | Output style | Gray | `default` |

Progress bar: 10 blocks, rounded (not floored). Already-used context = `█` (light blue), remaining = `░`. Falls back to `#` / `-` if terminal can't render Unicode.
Context colors: ≤30% green, 30-70% yellow, >70% red.

## Troubleshooting

- **Nothing shows up**: Restart Claude Code completely (quit and re-open).
- **"jq not found"** (Linux/macOS): Install with `brew install jq` (macOS) or `apt install jq` (Linux).
- **"bc not found"** (Linux): `apt install bc` or `yum install bc`.
- **Shows briefly then reverts to "Claude Code"**: The working directory contains non-ASCII characters (e.g. Chinese). The PowerShell script now sets `InputEncoding`/`OutputEncoding` to UTF-8 to fix this — make sure you have the latest version of the script.
- **Progress bar shows garbled characters**: Terminal doesn't support Unicode. The script auto-falls back to ASCII `#`/`-` characters.
- **Shows "no-branch"**: You're not inside a Git repository.
