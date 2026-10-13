<#
Link every skill in skills\ and vendor\ into one or more skills folders (Windows).
  .\install.ps1                          -> ~\.agents\skills (Copilot in VS Code, Cursor, Codex)
  .\install.ps1 ~\.claude\skills         -> any other folder(s) you name
  .\install.ps1 -Copy <dir>...           -> copy instead of link (e.g. a repo's .github\skills)
Links are directory junctions: no admin rights or Developer Mode needed.
Anything already in a target folder that this repo did not put there is left alone.
If scripts are blocked: powershell -ExecutionPolicy Bypass -File .\install.ps1
#>
param([switch]$Copy, [Parameter(ValueFromRemainingArguments)][string[]]$Dest)
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
if (-not $Dest) { $Dest = @(Join-Path $HOME '.agents\skills') }
$skills = Get-ChildItem -Directory (Join-Path $root 'skills'), (Join-Path $root 'vendor')

function Test-Ours($item) { "$($item.Target)".StartsWith($root, [StringComparison]::OrdinalIgnoreCase) }

foreach ($d in $Dest) {
  New-Item -ItemType Directory -Force -Path $d | Out-Null
  $n = 0
  foreach ($s in $skills) {
    $target = Join-Path $d $s.Name
    $item = Get-Item -LiteralPath $target -Force -ErrorAction SilentlyContinue
    if ($item) {
      if ($item.LinkType) {
        if (-not (Test-Ours $item)) { Write-Host "skip $target (links elsewhere)"; continue }
        [IO.Directory]::Delete($target, $false)  # removes the link, never what it points to
      } elseif (Test-Path -LiteralPath (Join-Path $target '.heroloop')) {
        Remove-Item -LiteralPath $target -Recurse -Force
      } else { Write-Host "skip $target (not installed by heroloop)"; continue }
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
    ForEach-Object { [IO.Directory]::Delete($_.FullName, $false) }
  Write-Host "installed $n skills into $d"
}
