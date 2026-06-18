# Claude Code Status Line (Windows PowerShell)
# Reads session JSON from stdin, outputs: model | ███░░░░░░░ percent% | git-branch | cwd | output-style
# ANSI-colored for readability. Supports Chinese paths (UTF-8).

# Fix encoding for Chinese paths
try { [Console]::InputEncoding = [System.Text.Encoding]::UTF8 } catch {}
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}
$json = $null
try { $json = [Console]::In.ReadToEnd() } catch {}

if ([string]::IsNullOrWhiteSpace($json)) { Write-Output "Claude Code"; exit 0 }

try { $data = $json | ConvertFrom-Json -ErrorAction Stop } catch { Write-Output "Claude Code"; exit 0 }

# Extract fields safely
$model   = try { $data.model.display_name }        catch { "Claude Code" }
$cwd     = try { $data.workspace.current_dir }     catch { "?" }
$tokens  = try { $data.context_window.total_input_tokens }    catch { 0 }
$ctxSize = try { $data.context_window.context_window_size }   catch { 1 }
$style   = try { $data.output_style.name }         catch { "?" }

if (-not $model) { $model = "Claude Code" }
if (-not $cwd)   { $cwd = "?" }
if (-not $tokens)  { $tokens = 0 }
if (-not $ctxSize -or $ctxSize -le 0) { $ctxSize = 1 }
if (-not $style) { $style = "?" }

# Context percentage
$ctxPct = [math]::Round(($tokens / $ctxSize) * 100, 1)

# Git branch
$branch = try { $b = $(git branch --show-current 2>$null); if ($b) { $b } else { "no-branch" } } catch { "no-branch" }

# ANSI colors
$e = [char]27
$res  = "${e}[0m";  $bold = "${e}[1m"; $dim = "${e}[2m"
$cyan    = "${e}[36m"; $green = "${e}[32m"; $yellow = "${e}[33m"
$red     = "${e}[31m"; $magenta = "${e}[35m"; $blue = "${e}[34m"
$gray    = "${e}[90m"; $ltblue = "${e}[96m"

$ctxColor = if ($ctxPct -gt 70) { $red } elseif ($ctxPct -gt 30) { $yellow } else { $green }

# Progress bar (10 blocks)
$barWidth = 10
$filled = if ($ctxSize -gt 0) { [int][math]::Round(($tokens / $ctxSize) * $barWidth) } else { 0 }
if ($filled -gt $barWidth) { $filled = $barWidth }
$empty = [int]($barWidth - $filled)

# Use Unicode blocks, with ASCII fallback
try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $block = "$([char]0x2588)"
    $shade = "$([char]0x2591)"
} catch {
    $block = "#"
    $shade = "-"
}

$bar = "${ltblue}$($block * $filled)$($shade * $empty)$res"

# Final output
Write-Output "$bold$cyan$model$res$dim |$res $bar $ctxColor${ctxPct}%$res$dim |$res $magenta$branch$res$dim |$res $blue$cwd$res$dim |$res $gray$style$res"
