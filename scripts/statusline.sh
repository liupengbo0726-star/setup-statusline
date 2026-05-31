#!/usr/bin/env bash
# Claude Code Status Line (Linux / macOS)
# Reads session JSON from stdin, outputs: model | context% | git-branch | cwd | output-style
# ANSI-colored for readability. Requires: jq, git

set -euo pipefail

json=$(cat)

if [ -z "$json" ]; then
    echo "Claude Code"
    exit 0
fi

# ----- Parse JSON fields (jq handles missing fields gracefully) -----
model=$(echo "$json"        | jq -r '.model.display_name // "Claude Code"')
cwd=$(echo "$json"          | jq -r '.workspace.current_dir // "?"')
tokens=$(echo "$json"       | jq -r '.context_window.total_input_tokens // 0')
ctx_size=$(echo "$json"     | jq -r '.context_window.context_window_size // 1')
output_style=$(echo "$json" | jq -r '.output_style.name // "?"')

# ----- Context usage percentage -----
if [ "$ctx_size" -gt 0 ] 2>/dev/null; then
    ctx_pct=$(awk "BEGIN { printf \"%.1f\", ($tokens / $ctx_size) * 100 }")
else
    ctx_pct="0.0"
fi

# ----- Git branch -----
branch=$(git branch --show-current 2>/dev/null || true)
[ -z "$branch" ] && branch="no-branch"

# ----- ANSI color codes -----
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
MAGENTA='\033[35m'
BLUE='\033[34m'
GRAY='\033[90m'

# ----- Color context by usage level -----
gt() { echo "$1 > $2" | bc -l | grep -q 1; }

if   gt "$ctx_pct" 70; then  CTX_COLOR="$RED"
elif gt "$ctx_pct" 30; then  CTX_COLOR="$YELLOW"
else                          CTX_COLOR="$GREEN"
fi

# ----- Build output -----
echo -e "${BOLD}${CYAN}${model}${RESET}${DIM} |${RESET} ${CTX_COLOR}${ctx_pct}%${RESET}${DIM} |${RESET} ${MAGENTA}${branch}${RESET}${DIM} |${RESET} ${BLUE}${cwd}${RESET}${DIM} |${RESET} ${GRAY}${output_style}${RESET}"
