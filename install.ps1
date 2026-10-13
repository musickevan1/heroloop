<#
Link every skill in skills\ and vendor\ into one or more skills folders (Windows).
  .\install.ps1                          -> ~\.agents\skills (Copilot in VS Code, Cursor, Codex)
  .\install.ps1 ~\.claude\skills         -> any other folder(s) you name
  .\install.ps1 -Copy <dir>...           -> copy instead of link (e.g. a repo's .github\skills)
  .\install.ps1 -Uninstall [dir...]      -> remove what this script installed there
Links are directory junctions: no admin rights or Developer Mode needed.
Anything in a target folder that this repo did not put there is left alone.
If scripts are blocked: powershell -ExecutionPolicy Bypass -File .\install.ps1
#>
param([switch]$Copy, [switch]$Uninstall, [Parameter(ValueFromRemainingArguments)][string[]]$Dest)
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
if (-not $Dest) { $Dest = @(Join-Path $HOME '.agents\skills') }

# Ours: a link into this repo, or a copy carrying the .heroloop marker.
function Test-Ours($item) {
  if ($item.LinkType) { return "$($item.Target)".StartsWith($root, [StringComparison]::OrdinalIgnoreCase) }
  Test-Path -LiteralPath (Join-Path $item.FullName '.heroloop')
}
# Removes a link without touching what it points to; removes a copy completely.
function Remove-Ours($item) {
  if ($item.LinkType) { [IO.Directory]::Delete($item.FullName, $false) }
  else { Remove-Item -LiteralPath $item.FullName -Recurse -Force }
}

foreach ($d in $Dest) {
  $n = 0
  if ($Uninstall) {
    if (Test-Path -LiteralPath $d) {
      Get-ChildItem -LiteralPath $d -Directory -Force | Where-Object { Test-Ours $_ } | ForEach-Object { Remove-Ours $_; $n++ }
    }
    Write-Host "removed $n skills from $d"
    continue
  }
  New-Item -ItemType Directory -Force -Path $d | Out-Null
  foreach ($s in Get-ChildItem -Directory (Join-Path $root 'skills'), (Join-Path $root 'vendor')) {
    $target = Join-Path $d $s.Name
    $item = Get-Item -LiteralPath $target -Force -ErrorAction SilentlyContinue
    if ($item) {
      if (-not (Test-Ours $item)) { Write-Host "skip $target (not installed by heroloop)"; continue }
      Remove-Ours $item
    }
    if ($Copy) {
      Copy-Item -Recurse -LiteralPath $s.FullName -Destination $target
      New-Item -ItemType File -Path (Join-Path $target '.heroloop') | Out-Null
    } else {
      New-Item -ItemType Junction -Path $target -Target $s.FullName | Out-Null
    }
    $n++
  }
  # Drop links to skills that no longer exist in this repo.
  Get-ChildItem -LiteralPath $d -Directory -Force |
    Where-Object { $_.LinkType -and (Test-Ours $_) -and -not (Test-Path -LiteralPath "$($_.Target)") } |
    ForEach-Object { Remove-Ours $_ }
  Write-Host "installed $n skills into $d"
}
