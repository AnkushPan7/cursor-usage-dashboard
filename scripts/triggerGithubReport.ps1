# Triggers the daily report workflow on GitHub at an exact local time.
# Use Windows Task Scheduler weekdays only (Mon–Fri) at 10:55 AM IST.
#
# Setup once:
#   1. Create a GitHub PAT with "repo" + "workflow" scopes.
#   2. Set env var:  [System.Environment]::SetEnvironmentVariable("GITHUB_PAT", "ghp_...", "User")
#   3. Task Scheduler → Create Task → Weekly Mon–Fri 10:55 AM → Action:
#        Program: powershell.exe
#        Args: -NoProfile -ExecutionPolicy Bypass -File "C:\path\to\scripts\triggerGithubReport.ps1"

$ErrorActionPreference = "Stop"

$pat = $env:GITHUB_PAT
if (-not $pat) {
  Write-Error "GITHUB_PAT is not set. Create a PAT with workflow scope and set it as a user environment variable."
}

$repo = if ($env:GITHUB_REPO) { $env:GITHUB_REPO } else { "AnkushPan7/cursor-usage-dashboard" }
$workflow = "daily-report.yml"

$uri = "https://api.github.com/repos/$repo/actions/workflows/$workflow/dispatches"
$headers = @{
  Authorization = "Bearer $pat"
  Accept        = "application/vnd.github+json"
  "X-GitHub-Api-Version" = "2022-11-28"
}

Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body '{"ref":"main"}' -ContentType "application/json"
Write-Host "Triggered $workflow on $repo. Screenshot should arrive in Google Chat in ~2 minutes."
