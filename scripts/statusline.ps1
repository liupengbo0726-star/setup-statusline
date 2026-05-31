# Claude Code Status Line (Windows PowerShell)
# Reads session JSON from stdin, outputs: model | context% | git-branch | cwd | output-style
# ANSI-colored for readability

$json = [Console]::In.ReadToEnd()

if ([string]::IsNullOrWhiteSpace($json)) {
    Write-Output "Claude Code"
    exit 0
}

try {
    $data = $json | ConvertFrom-Json -ErrorAction Stop
} catch {
    Write-Output "Claude Code"
    exit 0
}

# ----- Extract fields -----
$model   = $data.model.display_name
$cwd     = $data.workspace.current_dir
$tokens  = $data.context_window.total_input_tokens
$ctxSize = $data.context_window.context_window_size
try { $outputStyle = $data.output_style.name } catch { $outputStyle = "?" }

# ----- Context usage percentage -----
if ($ctxSize -gt 0) {
    $ctxPct = [math]::Round(($tokens / $ctxSize) * 100, 1)
} else {
    $ctxPct = 0
}

# ----- Git branch -----
try {
    $branch = $(git branch --show-current 2>$null)
    if (-not $branch) { $branch = "no-branch" }
} catch {
    $branch = "no-git"
}

# ----- ANSI color codes -----
$e = [char]27
$res  = "${e}[0m"
$bold = "${e}[1m"
$dim  = "${e}[2m"
$cyan    = "${e}[36m"
$green   = "${e}[32m"
$yellow  = "${e}[33m"
$red     = "${e}[31m"
$magenta = "${e}[35m"
$blue    = "${e}[34m"
$gray    = "${e}[90m"

# ----- Color context by usage level -----
if ($ctxPct -gt 70) {
    $ctxColor = $red
} elseif ($ctxPct -gt 30) {
    $ctxColor = $yellow
} else {
    $ctxColor = $green
}

# ----- Build output -----
$output = "$bold$cyan$model$res$dim |$res $ctxColor${ctxPct}%$res$dim |$res $magenta$branch$res$dim |$res $blue$cwd$res$dim |$res $gray$outputStyle$res"

Write-Output $output
