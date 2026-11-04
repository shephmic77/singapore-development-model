param([string]$Message = ('Update SODA 308 research - ' + (Get-Date -Format 'yyyy-MM-dd HH:mm')))
$ErrorActionPreference = 'Stop'
$projectRoot = $PSScriptRoot
function Invoke-Git {
 param([Parameter(ValueFromRemainingArguments=$true)][string[]]$GitArguments)
 & git -c "safe.directory=$projectRoot" -C $projectRoot @GitArguments
 if ($LASTEXITCODE -ne 0) { throw "Git failed: $($GitArguments -join ' ')" }
}
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw 'Install Git for Windows first.' }
$expected = 'https://github.com/shephmic77/singapore-development-model.git'
$remote = (Invoke-Git remote get-url origin | Out-String).Trim()
if ($remote -ne $expected) { throw 'Unexpected remote. Check origin before syncing.' }
$branch = (Invoke-Git branch --show-current | Out-String).Trim()
if ($branch -ne 'main') { throw 'Sync is limited to main. Review your current branch first.' }
$tracked = @(Invoke-Git ls-files)
$blocked = @($tracked | Where-Object { $_ -match '(^data/raw/|^[.]R-library/|^[.]Rproj[.]user/|(^|/)[.]env($|[.])|[.]pem$|[.]key$|original_request[.]txt$)' })
if ($blocked.Count) { throw "Local-only files are tracked: $($blocked -join ', '). Review before uploading." }
Invoke-Git fetch origin main
$remoteHead = (Invoke-Git rev-parse origin/main | Out-String).Trim()
& git -c "safe.directory=$projectRoot" -C $projectRoot merge-base --is-ancestor $remoteHead HEAD
if ($LASTEXITCODE -ne 0) { throw 'GitHub contains changes missing locally. Review and merge them before syncing; no force push was attempted.' }
Invoke-Git add --all
& git -c "safe.directory=$projectRoot" -C $projectRoot diff --cached --quiet
$diffStatus = $LASTEXITCODE
if ($diffStatus -eq 1) { Invoke-Git commit -m $Message }
elseif ($diffStatus -ne 0) { throw 'Unable to inspect staged changes.' }
Invoke-Git push origin main
$localHead = (Invoke-Git rev-parse HEAD | Out-String).Trim()
$published = (Invoke-Git ls-remote origin refs/heads/main | Out-String).Trim().Split()[0]
if ($localHead -ne $published) { throw 'Remote verification did not match the local commit.' }
Write-Output "SODA folder synced to GitHub: $localHead"